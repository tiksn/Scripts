Import-Module -Name ObjectiveGit
Import-Module -Name posh-git
Import-Module -Name Habitica
Import-Module -Name PSCalendar
Import-Module -Name PSReleaseTools
Import-Module -Name PowerShellHumanizer

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN) {
    $profileRunTime = Get-Date
    $formattedDate = $profileRunTime.ToString("f")
    $formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

    Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue
    Write-Host -Object ' '

    [scriptblock]$readCache = {
        $PowerShellCachePath = Join-Path -Path $HOME -ChildPath "PowerShellCache"

        if (Test-Path -Path $PowerShellCachePath) {
            $ProfileCache = Import-Clixml -Path $PowerShellCachePath
        }
        else {
            $ProfileCache = [PSCustomObject]@{
                Saved                 = $null
                Release               = $null
                ReleasePreview        = $null
                Habitica              = [PSCustomObject]@{
                    DueDailies      = $null
                    DueDailiesCount = $null
                    DueToDos        = $null
                    DueToDoCount    = $null
                    DueHabits       = $null
                    DueHabitsCount  = $null
                    HabiticaUser    = $null
                }
                AllCommands           = $null
                NationalBankOfUkraine = [PSCustomObject]@{
                    ExchangeRates           = $null
                    YesterdaysExchangeRates = $null
                }
            }
        }
    }

    Invoke-Command -ScriptBlock $readCache -NoNewScope

    Start-ThreadJob -Name 'UpdatePowerShellCache' -InitializationScript $readCache -ScriptBlock {
        if (!$ProfileCache -or !$ProfileCache.Saved -or ((Get-Date) - $ProfileCache.Saved) -gt (New-TimeSpan -Hours 1)) {
            $nationalBankOfUkraineJob = Start-ThreadJob -ScriptBlock {
                $xml = New-Object xml

                $xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
                $exchangeRates = $xml.exchange | Select-Object -ExpandProperty currency

                $yesterdaysDatePattern = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

                $xml.Load("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=$yesterdaysDatePattern")
                $yesterdaysExchangeRates = $xml.exchange | Select-Object -ExpandProperty currency

                [PSCustomObject]@{
                    ExchangeRates           = $exchangeRates
                    YesterdaysExchangeRates = $yesterdaysExchangeRates
                } | Write-Output
            }

            $habiticaJob = Start-ThreadJob -ScriptBlock {
                $habiticaCredentialsFilePath = Join-Path -Path $HOME -ChildPath "HabiticaCredentials"
                Connect-Habitica -Path $habiticaCredentialsFilePath

                $dailys = Get-HabiticaTask -Type dailys
                $todos = Get-HabiticaTask -Type todos
                $habits = Get-HabiticaTask -Type habits

                [PSCustomObject]@{
                    DueDailies      = $dailys | Where-Object { $_.IsDue -and (-not $_.completed) } 
                    DueDailiesCount = ($ProfileCache.Habitica.DueDailies | Measure-Object).Count
                    DueToDos        = $todos
                    DueToDoCount    = ($ProfileCache.Habitica.DueToDos | Measure-Object).Count
                    DueHabits       = $habits | Where-Object { ($_.counterUp -eq 0) -and ($_.counterDown -eq 0) }
                    DueHabitsCount  = ($ProfileCache.Habitica.DueHabits | Measure-Object).Count
                    HabiticaUser    = Get-HabiticaUser
                } | Write-Output
            }

            $allCommandsJob = Start-ThreadJob -ScriptBlock {
                $allCommands = Get-Command * | Select-Object -Unique
                Write-Output $allCommands
            }

            $pwshRelease = Start-ThreadJob -ScriptBlock {
                Get-PSReleaseCurrent | Write-Output 
            }

            $pwshPreviewRelease = Start-ThreadJob -ScriptBlock {
                Get-PSReleaseCurrent -Preview | Write-Output 
            }

            $saveCache = $true

            try {
                $ProfileCache.NationalBankOfUkraine = Receive-Job $nationalBankOfUkraineJob -Wait
            }
            catch {
                $saveCache = $false
            }

            try {
                $ProfileCache.Habitica = Receive-Job $habiticaJob -Wait
            }
            catch {
                $saveCache = $false
            }

            try {
                $ProfileCache.AllCommands = Receive-Job $allCommandsJob -Wait
            }
            catch {
                $saveCache = $false
            }

            try {
                $ProfileCache.Release = Receive-Job $pwshRelease -Wait
            }
            catch {
                $saveCache = $false
            }
            
            try {
                $ProfileCache.ReleasePreview = Receive-Job $pwshPreviewRelease -Wait
            }
            catch {
                $saveCache = $false
            }

            if ($saveCache) {
                $ProfileCache.Saved = Get-Date
                $ProfileCache | Export-Clixml -Path $PowerShellCachePath
            }
        }
    } | Out-Null

    function GetSignedChange {
        param (
            $change
        )

        if ($change -gt 0) {
            return "+$change"
        }
        elseif ($change -lt 0) {
            return $change.ToString()
        }
        else {
            return " $change"
        }
    }

    function GetCurrencyFluctuation {
        param (
            $total,
            $delta
        )

        if ($delta -gt 0) {
            $sign = "🔼"
        }
        elseif ($delta -lt 0) {
            $sign = "🔽"
        }
        else {
            $sign = "≡"
        }

        $percentage = ($delta * 100) / $total
        $percentage = [math]::Round($percentage, 2)

        $percentage = GetSignedChange( $percentage )
        $percentage = "$percentage%"
        return New-Object PSObject -Property @{
            Sign       = $sign
            Percentage = $percentage
        }
    }

    if (($null -ne $ProfileCache.NationalBankOfUkraine.ExchangeRates) -and ($null -ne $ProfileCache.NationalBankOfUkraine.YesterdaysExchangeRates)) {
        $usduahToday = $ProfileCache.NationalBankOfUkraine.ExchangeRates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
        $euruahToday = $ProfileCache.NationalBankOfUkraine.ExchangeRates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

        $usduahYesterday = $ProfileCache.NationalBankOfUkraine.YesterdaysExchangeRates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
        $euruahYesterday = $ProfileCache.NationalBankOfUkraine.YesterdaysExchangeRates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

        $usduahDelta = $usduahToday - $usduahYesterday
        $euruahDelta = $euruahToday - $euruahYesterday

        $usduahFluctuation = GetCurrencyFluctuation -total $usduahToday -delta $usduahDelta
        $euruahFluctuation = GetCurrencyFluctuation -total $euruahToday -delta $euruahDelta

        $usduahDelta = GetSignedChange ( [math]::Round($usduahDelta, 2) )
        $euruahDelta = GetSignedChange ( [math]::Round($euruahDelta, 2) )

        Write-Host -Object "💵 USD/UAH $usduahToday $($usduahFluctuation.Sign) $($usduahFluctuation.Percentage) ($usduahDelta) 💵" -BackgroundColor Black -ForegroundColor DarkGreen
        Write-Host -Object "💶 EUR/UAH $euruahToday $($euruahFluctuation.Sign) $($euruahFluctuation.Percentage) ($euruahDelta) 💶" -BackgroundColor Black -ForegroundColor DarkGreen
    }

    Write-Host -Object "⚒ " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.HabiticaUser.stats.lvl) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Level " -NoNewline
    Write-Host -Object " $(($ProfileCache.Habitica.HabiticaUser.stats.gp.ToString("N0"))) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Gold " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueHabitsCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Habits (pending) " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueDailiesCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Dailies (left) " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueToDoCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " To-Dos ⚒"

    if ($null -eq $PSVersionTable.PSVersion.PreReleaseLabel) {
        $PSRelease = $ProfileCache.Release
    }
    else {
        $PSRelease = $ProfileCache.ReleasePreview
    }

    if (($PSRelease.Version -ne $PSRelease.LocalVersion) -and ($PSRelease.Version -ne "v$($PSVersionTable.PSVersion)")) {
        Write-Host -Object "🆕 New " -NoNewline -BackgroundColor White -ForegroundColor Black
        Write-Host -Object $PSRelease.Version -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object " version is available 🆕" -BackgroundColor White -ForegroundColor Black
    }
    
    Show-Calendar
    Write-Host -Object " "

    if ($ProfileCache.AllCommands) {
        $randomCommand = $ProfileCache.AllCommands | Get-Random

        Write-Host -Object "⌨ " -NoNewline
        Write-Host -Object $randomCommand.Name -NoNewline -ForegroundColor Black -BackgroundColor White
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $randomCommand.CommandType.ToString() -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $randomCommand.Source -NoNewline
        Write-Host -Object " ⌨"
        Write-Host -Object " "
    }
    
    if ($randomCommand.CommandType -ne [System.Management.Automation.CommandTypes]::Application) {
        # Get-Command -Name $randomCommand.Name -Syntax
    }
    
    # PowerShell parameter completion shim for the GitHub CLI
    gh completion --shell powershell | Set-Variable -Name ghCompletion

    $ghCompletion = $ghCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
    $ghCompletion = [scriptblock]::Create($ghCompletion)
    Invoke-Command -ScriptBlock $ghCompletion

    # PowerShell parameter completion shim for the Deno
    deno completions powershell | Set-Variable -Name denoCompletion

    $denoCompletion = $denoCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
    $denoCompletion = [scriptblock]::Create($denoCompletion)
    Invoke-Command -ScriptBlock $denoCompletion

    # PowerShell parameter completion shim for the dotnet CLI
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

function prompt {
    $formattedTime = (Get-Date).ToShortTimeString()
    # $formattedTime = "[$(($formattedDate | Out-String).trim())]"
    $lastCmd = Get-History -Count 1
    if ($null -ne $lastCmd -and $null -ne $lastCmd.Duration -and $lastCmd.Duration.TotalSeconds -gt 1) {
        $lastCmdDuration = $lastCmd.Duration.Humanize()
        Write-Host -Object "$lastCmdDuration" -NoNewline -ForegroundColor Magenta
        Write-Host " " -NoNewline
    }

    $jobs = @(Get-Job | Where-Object { $_.State -eq 'Running' }).Count
    if ($jobs -gt 0) {
        1..$jobs | ForEach-Object { Write-Host "🔨" -NoNewline }
        Write-Host " " -NoNewline
    }
    
    Try {
        $repoStatus = Get-RepositoryStatus
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor DarkBlue
        Write-Host -Object " " -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-VcsStatus
        Write-Host

        $gitRootPath = (Split-Path (Get-GitDirectory) -Parent)
        $gitFolderName = (Split-Path $gitRootPath -Leaf)
        $subPath = $PWD.Path.Substring($gitRootPath.Length)
        $subPath = $gitFolderName + $subPath
        $pathParts = $subPath.Split([IO.Path]::DirectorySeparatorChar)
        [array]::Reverse($pathParts)
        $host.ui.RawUI.WindowTitle = $pathParts -join " < "
        # return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch {
        $repoStatus = $null;
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor DarkBlue
        Write-Host -Object " " -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-Host

        $host.ui.RawUI.WindowTitle = (Split-Path $PWD -Leaf)
    }

    Write-Host -Object "$('>' * ($nestedPromptLevel + 1))" -NoNewline

    return " "
}

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath "PowerShellTranscripts"

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format "yyyy-MM-dd--hh-mm-ss"
$instanceId = $Host.InstanceId
$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate $instanceId.txt"

Set-PSReadLineOption -PredictionSource History

Start-Transcript -Path $TranscriptFilePath -Append

# Invoke-Expression (&starship init powershell)
