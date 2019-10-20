Import-Module -Name ObjectiveGit
Import-Module -Name posh-git
Import-Module -Name Habitica

$formattedDate = (Get-Date).ToString("f")
$formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue

$PowerShellCachePath = Join-Path -Path $HOME -ChildPath "PowerShellCache"

if (Test-Path -Path $PowerShellCachePath) {
    $ProfileCache = Import-Clixml -Path $PowerShellCachePath
}
else {
    $ProfileCache = [PSCustomObject]@{
        Release                 = $null
        Saved                   = $null
        ExchangeRates           = $null
        YesterdaysExchangeRates = $null
        Habitica                = [PSCustomObject]@{
            DueDailiesCount = $null
            DueToDoCount    = $null
            DueHabitCount   = $null
            HabiticaUser    = $null
        }
        AllCommands = $null
    }
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

if (!$ProfileCache -or !$ProfileCache.Saved -or ((Get-Date) - $ProfileCache.Saved) -gt (New-TimeSpan -Hours 1)) {
    $ProfileCache.Release = Get-PSReleaseCurrent
    $ProfileCache.Saved = Get-Date
    $ProfileCache.AllCommands = Get-Command -All

    $SaveCache = $true

    try {
        $xml = New-Object xml

        $xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
        $ProfileCache.ExchangeRates = $xml.exchange | Select-Object -ExpandProperty currency

        $yesterdaysDatePattern = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

        $xml.Load("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=$yesterdaysDatePattern")
        $ProfileCache.YesterdaysExchangeRates = $xml.exchange | Select-Object -ExpandProperty currency
    }
    catch {
        $SaveCache = $false
    }

    try {
        $habiticaCredentialsFilePath = Join-Path -Path $HOME -ChildPath "HabiticaCredentials"
        Connect-Habitica -Path $habiticaCredentialsFilePath

        $ProfileCache.Habitica.DueDailiesCount = (Get-HabiticaTask -Type dailys | Where-Object { $_.IsDue -and (-not $_.completed) } | Measure-Object).Count
        $ProfileCache.Habitica.DueToDoCount = (Get-HabiticaTask -Type todos | Measure-Object).Count
        $ProfileCache.Habitica.DueHabitCount = (Get-HabiticaTask -Type habits | Where-Object { ($_.counterUp -eq 0) -and ($_.counterDown -eq 0) } | Measure-Object).Count
        $ProfileCache.Habitica.HabiticaUser = Get-HabiticaUser
    }
    catch {
        $SaveCache = $false
    }

    if ($SaveCache) {
        $ProfileCache | Export-Clixml $PowerShellCachePath
    }
}

$usduahToday = $ProfileCache.ExchangeRates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
$euruahToday = $ProfileCache.ExchangeRates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

$usduahYesterday = $ProfileCache.YesterdaysExchangeRates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
$euruahYesterday = $ProfileCache.YesterdaysExchangeRates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

$usduahDelta = $usduahToday - $usduahYesterday
$euruahDelta = $euruahToday - $euruahYesterday

$usduahFluctuation = GetCurrencyFluctuation -total $usduahToday -delta $usduahDelta
$euruahFluctuation = GetCurrencyFluctuation -total $euruahToday -delta $euruahDelta

$usduahDelta = GetSignedChange ( [math]::Round($usduahDelta, 2) )
$euruahDelta = GetSignedChange ( [math]::Round($euruahDelta, 2) )

Write-Host -Object "💵 USD/UAH $usduahToday $($usduahFluctuation.Sign) $($usduahFluctuation.Percentage) ($usduahDelta) 💵" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host -Object "💶 EUR/UAH $euruahToday $($euruahFluctuation.Sign) $($euruahFluctuation.Percentage) ($euruahDelta) 💶" -BackgroundColor Black -ForegroundColor DarkGreen


Write-Host -Object "⚒ " -NoNewline
Write-Host -Object (Get-Culture).TextInfo.ToTitleCase($ProfileCache.Habitica.HabiticaUser.stats.class) -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Class " -NoNewline
Write-Host -Object $ProfileCache.Habitica.HabiticaUser.stats.lvl -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Level " -NoNewline
Write-Host -Object ($ProfileCache.Habitica.HabiticaUser.stats.gp.ToString("N2")) -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Gold " -NoNewline
Write-Host -Object $ProfileCache.Habitica.DueHabitCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Habits (inacted) " -NoNewline
Write-Host -Object $ProfileCache.Habitica.DueDailiesCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Dailies (left) " -NoNewline
Write-Host -Object $ProfileCache.Habitica.DueToDoCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " To-Dos ⚒"

$randomCommand = $ProfileCache.AllCommands | Get-Random

Write-Host -Object "⌨ " -NoNewline
Write-Host -Object $randomCommand.Name -NoNewline
Write-Host -Object ' ' -NoNewline
Write-Host -Object $randomCommand.CommandType.ToString() -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object ' ' -NoNewline
Write-Host -Object $randomCommand.Source -NoNewline
Write-Host -Object " ⌨"

if (($ProfileCache.Release.Version -ne $ProfileCache.Release.LocalVersion) -and ($ProfileCache.Release.Version -ne "v$($ProfileCache.Release.LocalVersion)")) {
    Write-Host -Object "🆕 New " -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host -Object $ProfileCache.Release.Version -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " version is available 🆕" -BackgroundColor White -ForegroundColor Black
}

function prompt {
    $formattedTime = (Get-Date).ToShortTimeString()
    # $formattedTime = "[$(($formattedDate | Out-String).trim())]"
    Try {
        $repoStatus = Get-RepositoryStatus;
        Write-Host -Object "GIT" -NoNewline -BackgroundColor Yellow -ForegroundColor Red
        Write-Host -Object " " -NoNewline
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor DarkBlue
        Write-Host -Object " " -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-VcsStatus
        Write-Host
        # return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch {
        $repoStatus = $null;
        Write-Host -Object "PSC" -NoNewline -BackgroundColor Yellow -ForegroundColor Red
        Write-Host -Object " " -NoNewline
        Write-Host -Object $formattedTime -NoNewline -BackgroundColor Cyan -ForegroundColor DarkBlue
        Write-Host -Object " " -NoNewline
        Write-Host -Object $executionContext.SessionState.Path.CurrentLocation -NoNewline -BackgroundColor Black -ForegroundColor Gray
        Write-Host
    }

    Write-Host -Object "$('>' * ($nestedPromptLevel + 1))" -NoNewline
    return " "
}

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath "PowerShellTranscripts"

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format "yyyy-MM-dd--hh-mm-ss"

$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate.txt"

Start-Transcript -Path $TranscriptFilePath -Append
