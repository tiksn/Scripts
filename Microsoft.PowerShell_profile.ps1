Import-Module ObjectiveGit
Import-Module posh-git

$formattedDate = (Get-Date).ToString("f")
$formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue

# function GetSignedChange {
#     param (
#         $change
#     )
    
#     if ($change -gt 0) {
#         return "+$change"
#     }
#     elseif ($change -lt 0) {
#         return $change.ToString()
#     }
#     else {
#         return " $change"
#     }
# }

# function GetCurrencyFluctuation {
#     param (
#         $total,
#         $delta
#     )
    
#     if ($delta -gt 0) {
#         $sign = "🔼"
#     }
#     elseif ($delta -lt 0) {
#         $sign = "🔽"
#     }
#     else {
#         $sign = "≡"
#     }

#     $percentage = ($delta * 100) / $total
#     $percentage = [math]::Round($percentage, 2)
    
#     $percentage = GetSignedChange( $percentage )
#     $percentage = "$percentage%"
#     return New-Object PSObject -Property @{
#         Sign       = $sign
#         Percentage = $percentage
#     }
# }
# $xml = New-Object xml
# $xml.Load('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange')
# $rates = $xml.exchange | Select-Object -ExpandProperty currency
# $usduahToday = $rates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
# $euruahToday = $rates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

# $yesterdaysDatePattern = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

# $xml.Load("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=$yesterdaysDatePattern")
# $rates = $xml.exchange | Select-Object -ExpandProperty currency
# $usduahYesterday = $rates | Where-Object { $_.cc -eq 'USD' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }
# $euruahYesterday = $rates | Where-Object { $_.cc -eq 'EUR' } | Select-Object -ExpandProperty rate | ForEach-Object { [math]::Round($_, 2) }

# $usduahDelta = $usduahToday - $usduahYesterday
# $euruahDelta = $euruahToday - $euruahYesterday

# $usduahFluctuation = GetCurrencyFluctuation -total $usduahToday -delta $usduahDelta
# $euruahFluctuation = GetCurrencyFluctuation -total $euruahToday -delta $euruahDelta

# $usduahDelta = GetSignedChange ( [math]::Round($usduahDelta, 2) )
# $euruahDelta = GetSignedChange ( [math]::Round($euruahDelta, 2) )

# Write-Host -Object "💵 USD/UAH $usduahToday $($usduahFluctuation.Sign) $($usduahFluctuation.Percentage) ($usduahDelta) 💵" -BackgroundColor Black -ForegroundColor DarkGreen
# Write-Host -Object "💶 EUR/UAH $euruahToday $($euruahFluctuation.Sign) $($euruahFluctuation.Percentage) ($euruahDelta) 💶" -BackgroundColor Black -ForegroundColor DarkGreen

$habiticaCredentialsFilePath = Join-Path -Path $HOME -ChildPath "HabiticaCredentials"
Connect-Habitica -Path $habiticaCredentialsFilePath

$dueDailiesCount = (Get-HabiticaTask -Type dailys | Where-Object { $_.IsDue -and (-not $_.completed) } | Measure-Object).Count
$dueToDoCount = (Get-HabiticaTask -Type todos | Measure-Object).Count
$dueHabitCount = (Get-HabiticaTask -Type habits | Where-Object { ($_.counterUp -eq 0) -and ($_.counterDown -eq 0) } | Measure-Object).Count
$habiticaUser =  Get-HabiticaUser

Write-Host -Object "⚒ " -NoNewline
Write-Host -Object (Get-Culture).TextInfo.ToTitleCase($habiticaUser.stats.class) -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Class " -NoNewline
Write-Host -Object $habiticaUser.stats.lvl -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Level " -NoNewline
Write-Host -Object ($habiticaUser.stats.gp.ToString("N2")) -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Gold " -NoNewline
Write-Host -Object $dueHabitCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Habits (inacted) " -NoNewline
Write-Host -Object $dueDailiesCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " Dailies (left) " -NoNewline
Write-Host -Object $dueToDoCount -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
Write-Host -Object " To-Dos ⚒"


$release = Get-PSReleaseCurrent

if (($release.Version -ne $release.LocalVersion) -and ($release.Version -ne "v$($release.LocalVersion)")) {
    Write-Host -Object "🆕 New " -NoNewline -BackgroundColor White -ForegroundColor Black
    Write-Host -Object $release.Version -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
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
