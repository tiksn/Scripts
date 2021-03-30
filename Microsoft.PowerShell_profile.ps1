Import-Module -Name ObjectiveGit
Import-Module -Name posh-git
Import-Module -Name posh-sshell
Import-Module -Name PowerShellHumanizer
Import-Module -Name PSCalendar

if ($IsWindows) {
    Import-Module -Name Recycle

    Set-Alias -Name trash -Value Remove-ItemSafely    
}
elseif ($IsLinux) {
    Get-Command -Name trash | Out-Null
}

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN -or ($env:TERM_PROGRAM -eq 'FluentTerminal')) {
    Show-Calendar
    Write-Host -Object ' '

    $features = Get-Secret -Name 'PowerShellProfileFeatures'

    $PowerShellCachePath = Join-Path -Path $HOME -ChildPath 'PowerShellCache'

    if (Test-Path -Path $PowerShellCachePath) {
        $ProfileCache = Import-Clixml -Path $PowerShellCachePath
    }
    else {
        $ProfileCache = $null
    }

    if (!$ProfileCache -or !$ProfileCache.Saved -or ((Get-Date) - $ProfileCache.Saved) -gt (New-TimeSpan -Hours 1)) {
        Write-Warning "Profile Cache is outdated. Last time updated on $($ProfileCache.Saved)"
    }

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
            $sign = '🔼'
        }
        elseif ($delta -lt 0) {
            $sign = '🔽'
        }
        else {
            $sign = '≡'
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

    function ConvertToFahrenheit {
        param (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [double]
            $TemperatureInKelvin
        )
        $r = $TemperatureInKelvin / 5 * 9
        return $r - 459.67
    }

    function ConvertToCelcius {
        param (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [double]
            $TemperatureInKelvin
        )
        return $TemperatureInKelvin - 273.15
    }

    if ($features.NationalBankOfUkraineRates -and ($null -ne $ProfileCache.NationalBankOfUkraine.ExchangeRates) -and ($null -ne $ProfileCache.NationalBankOfUkraine.YesterdaysExchangeRates)) {
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

        Write-Host -Object "💵 USD/UAH $usduahToday $($usduahFluctuation.Sign) $($usduahFluctuation.Percentage) ($usduahDelta)" -BackgroundColor Black -ForegroundColor DarkGreen -NoNewline
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object "💶 EUR/UAH $euruahToday $($euruahFluctuation.Sign) $($euruahFluctuation.Percentage) ($euruahDelta)" -BackgroundColor Black -ForegroundColor DarkGreen -NoNewline
        Write-Host -Object ' ' -NoNewline
    }
    if ($features.CentralBankOfArmeniaRates -and ($null -ne $ProfileCache.CentralBankOfArmeniaRates)) {
        $usdamdToday = $ProfileCache.CentralBankOfArmeniaRates | Where-Object { $_.Code -eq 'USD' } | Select-Object -ExpandProperty Rate | ForEach-Object { [math]::Round($_, 2) }
        $euramdToday = $ProfileCache.CentralBankOfArmeniaRates | Where-Object { $_.Code -eq 'EUR' } | Select-Object -ExpandProperty Rate | ForEach-Object { [math]::Round($_, 2) }

        Write-Host -Object "💵 USD/AMD $usdamdToday" -BackgroundColor Black -ForegroundColor DarkGreen -NoNewline
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object "💶 EUR/AMD $euramdToday" -BackgroundColor Black -ForegroundColor DarkGreen -NoNewline
        Write-Host -Object ' ' -NoNewline
    }
    if ($features.NationalBankOfUkraineRates -or $features.CentralBankOfArmeniaRates) {
        Write-Host -Object ' '
    }

    if ($null -ne $ProfileCache.Habitica.HabiticaUser) {
        switch ($ProfileCache.Habitica.HabiticaUser.stats.hp) {
            { $_ -lt 8 } { Write-Host -Object '🖤' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            { $_ -lt 15 } { Write-Host -Object '🤎' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            { $_ -lt 22 } { Write-Host -Object '🧡' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            { $_ -lt 29 } { Write-Host -Object '💜' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            { $_ -lt 36 } { Write-Host -Object '💛' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            { $_ -lt 43 } { Write-Host -Object '💚' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta ; break }
            Default { Write-Host -Object '💙' -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta }
        }
        Write-Host -Object " $($ProfileCache.Habitica.HabiticaUser.stats.hp.ToString('N0')) / 50" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object "🐱‍🏍 $($ProfileCache.Habitica.HabiticaUser.stats.lvl)" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object "🥇 $($ProfileCache.Habitica.HabiticaUser.stats.gp.ToString('N0'))" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
    }
    if ($null -ne $ProfileCache.Habitica.DueHabitsCount) {
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object "🎯 $($ProfileCache.Habitica.DueHabitsCount)" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
    }
    if ($null -ne $ProfileCache.Habitica.DueDailiesCount) {
        Write-Host -Object "🔥 $($ProfileCache.Habitica.DueDailiesCount)" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
    }
    if ($null -ne $ProfileCache.Habitica.DueToDoCount) {
        Write-Host -Object "🌌 $($ProfileCache.Habitica.DueToDoCount)" -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
    }
    Write-Host -Object ' '

    $temperatureInCelcius = $ProfileCache.OpenWeather.TemperatureInKelvin | ConvertToCelcius
    $temperatureInCelcius = [math]::Round($temperatureInCelcius)
    $temperatureInFahrenheit = $ProfileCache.OpenWeather.TemperatureInKelvin | ConvertToFahrenheit
    $temperatureInFahrenheit = [math]::Round($temperatureInFahrenheit)
    $temperatureFeelsInCelcius = $ProfileCache.OpenWeather.TemperatureFeelsInKelvin | ConvertToCelcius
    $temperatureFeelsInCelcius = [math]::Round($temperatureFeelsInCelcius)
    $temperatureFeelsInFahrenheit = $ProfileCache.OpenWeather.TemperatureFeelsInKelvin | ConvertToFahrenheit
    $temperatureFeelsInFahrenheit = [math]::Round($temperatureFeelsInFahrenheit)
    # $ProfileCache.OpenWeather.TemperatureFeelsInKelvin
    Write-Host -Object "$temperatureInCelcius°C / $temperatureInFahrenheit°F" -NoNewline
    Write-Host -Object " (Feels $temperatureFeelsInCelcius°C / $temperatureFeelsInFahrenheit°F)" -NoNewline
    Write-Host -Object " $($ProfileCache.OpenWeather.CityName), $($ProfileCache.OpenWeather.CountryCode)"

    Write-Host -Object ' '

    if ($ProfileCache.AllCommands) {
        $randomCommand = $ProfileCache.AllCommands | Get-Random

        if ($randomCommand.CommandType.ToString() -eq 'Alias') {
            if ($randomCommand.ModuleName) {
                Import-Module -Name $randomCommand.ModuleName
            }
            $alias = Get-Alias -Name $randomCommand.Name
            Write-Host -Object "$($alias.Name) -> $($alias.ResolvedCommandName)" -NoNewline -ForegroundColor Black -BackgroundColor White
        }
        else {
            Write-Host -Object $randomCommand.Name -NoNewline -ForegroundColor Black -BackgroundColor White
        }
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $randomCommand.CommandType.ToString() -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $randomCommand.Source -NoNewline
        Write-Host -Object ' '
    }
    
    if ($randomCommand.CommandType -ne [System.Management.Automation.CommandTypes]::Application) {
        # Get-Command -Name $randomCommand.Name -Syntax
    }
    
    if ($host.Name -eq 'ConsoleHost') {
        Import-Module PSReadLine

        Import-Module Az.Tools.Predictor
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView

        Set-PSReadLineKeyHandler -Key Ctrl+Shift+l `
            -BriefDescription ListCurrentDirectory `
            -LongDescription 'List the current directory' `
            -ScriptBlock {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Get-ChildItem')
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    }

    # PowerShell parameter completion shim for the WinGet
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }

    # PowerShell parameter completion shim for the GitHub CLI
    gh completion --shell powershell | Set-Variable -Name ghCompletion

    $ghCompletion = $ghCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
    $ghCompletion = [scriptblock]::Create($ghCompletion)
    Invoke-Command -ScriptBlock $ghCompletion

    if (Get-Command rustup -ErrorAction Ignore) {
        # PowerShell parameter completion shim for the Rustup
        rustup completions powershell rustup | Set-Variable -Name rustupCompletion

        $rustupCompletion = $rustupCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
        $rustupCompletion = [scriptblock]::Create($rustupCompletion)
        Invoke-Command -ScriptBlock $rustupCompletion

        # PowerShell parameter completion shim for the Cargo
        rustup completions powershell cargo | Set-Variable -Name rustupCompletion

        $rustupCompletion = $rustupCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
        $rustupCompletion = [scriptblock]::Create($rustupCompletion)
        Invoke-Command -ScriptBlock $rustupCompletion
    }
    
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
    $lastCmd = Get-History -Count 1
    if ($null -ne $lastCmd -and $null -ne $lastCmd.Duration -and $lastCmd.Duration.TotalSeconds -gt 1) {
        $lastCmdDuration = $lastCmd.Duration.Humanize()
        Write-Host -Object "$lastCmdDuration" -NoNewline -ForegroundColor Magenta
        Write-Host ' ' -NoNewline
    }

    $jobs = @(Get-Job | Where-Object { $_.State -eq 'Running' }).Count
    if ($jobs -gt 0) {
        1..$jobs | ForEach-Object { Write-Host '🔨' -NoNewline }
        Write-Host ' ' -NoNewline
    }
    
    Try {
        $repoStatus = Get-RepositoryStatus
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor Black
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-VcsStatus | Write-Host -NoNewline
        Write-Host

        $gitRootPath = (Split-Path (Get-GitDirectory) -Parent)
        $gitFolderName = (Split-Path $gitRootPath -Leaf)
        $subPath = $PWD.Path.Substring($gitRootPath.Length)
        $subPath = $gitFolderName + $subPath
        $pathParts = $subPath.Split([IO.Path]::DirectorySeparatorChar)
        [array]::Reverse($pathParts)
        $host.ui.RawUI.WindowTitle = $pathParts -join ' < '
        # return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch {
        $repoStatus = $null;
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor Black
        Write-Host -Object ' ' -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-Host

        $host.ui.RawUI.WindowTitle = (Split-Path $PWD -Leaf)
    }

    Write-Host -Object "$('>' * ($nestedPromptLevel + 1))" -NoNewline

    return ' '
}

function quit {
    $jobs = @(Get-Job | Where-Object { ($_.State -ne 'Completed') -and ($_.State -ne 'Disconnected') -and ($_.State -ne 'Failed') -and ($_.State -ne 'Stopped') }).Count
    if ($jobs -gt 0) {
        throw 'Now all jobs are finished'
    }

    exit
}

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath 'PowerShellTranscripts'

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format 'yyyy-MM-dd--hh-mm-ss'
$instanceId = $Host.InstanceId
$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate $instanceId.txt"

Start-Transcript -Path $TranscriptFilePath -Append

if ($env:WT_PROFILE_ID -eq '{2595cd9c-8f05-55ff-a1d4-93f3041ca67f}') {
    # PowerShell Preview
    Invoke-Expression (&starship init powershell)
}
