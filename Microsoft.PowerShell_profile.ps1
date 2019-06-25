Import-Module ObjectiveGit
Import-Module posh-git

$formattedDate = (Get-Date).ToString("f")
$formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue

$xml = New-Object xml
$xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
$rates = $xml.exchange | Select-Object -ExpandProperty currency
$usduah = $rates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_,2) }
$euruah = $rates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_,2) }

Write-Host -Object "💵 USD/UAH $usduah 💵" -BackgroundColor Black -ForegroundColor DarkGreen
Write-Host -Object "💶 EUR/UAH $euruah 💶" -BackgroundColor Black -ForegroundColor DarkGreen

function prompt {
    $formattedTime = (Get-Date).ToShortTimeString()
    # $formattedTime = "[$(($formattedDate | Out-String).trim())]"
    Try
    {
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
    Catch
    {
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

if ($IsWindows) {
    $PowerShellTranscriptsPath = Join-Path -Path $env:userprofile -ChildPath "PowerShellTranscripts"
} elseif ($IsLinux) {
    $PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath "PowerShellTranscripts"
}

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format "yyyy-MM-dd--hh-mm-ss"

$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate.txt"

Start-Transcript -Path $TranscriptFilePath -Append
