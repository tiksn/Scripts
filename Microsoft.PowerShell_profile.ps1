Import-Module ObjectiveGit
Import-Module posh-git

$formattedDate = (Get-Date).ToString("f")
$formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue

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

    if ($percentage -gt 0) {
        $percentage = "+$percentage"
    }
    elseif ($percentage -lt 0) {
        $percentage = $percentage.ToString()
    }
    else {
        $percentage = " $percentage"
    }

    $percentage = "$percentage%"
    return New-Object PSObject -Property @{
        Sign       = $sign
        Percentage = $percentage
    }
}
$xml = New-Object xml
$xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
$rates = $xml.exchange | Select-Object -ExpandProperty currency
$usduahToday = $rates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
$euruahToday = $rates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

$yesterdaysDatePattern = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

$xml.Load("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=$yesterdaysDatePattern")
$rates = $xml.exchange | Select-Object -ExpandProperty currency
$usduahYesterday = $rates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
$euruahYesterday = $rates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

$usduahDelta = $usduahToday - $usduahYesterday
$euruahDelta = $euruahToday - $euruahYesterday

$usduahFluctuation = GetCurrencyFluctuation -total $usduahToday -delta $usduahDelta
$euruahFluctuation = GetCurrencyFluctuation -total $euruahToday -delta $euruahDelta

Write-Host -Object "💵 USD/UAH $usduahToday $($usduahFluctuation.Sign) $($usduahFluctuation.Percentage) 💵" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host -Object "💶 EUR/UAH $euruahToday $($euruahFluctuation.Sign) $($euruahFluctuation.Percentage) 💶" -BackgroundColor Black -ForegroundColor DarkGreen

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
