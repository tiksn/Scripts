Import-Module -Name ObjectiveGit
Import-Module -Name posh-git
Import-Module -Name Habitica

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN) {
    $formattedDate = (Get-Date).ToString("f")
    $formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

    Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue

    $PowerShellCachePath = Join-Path -Path $HOME -ChildPath "PowerShellCache"

    if (Test-Path -Path $PowerShellCachePath) {
        $ProfileCache = Import-Clixml -Path $PowerShellCachePath
    }
    else {
        $ProfileCache = [PSCustomObject]@{
            Release        = $null
            ReleasePreview = $null
            Saved          = $null
            Habitica       = [PSCustomObject]@{
                DueDailiesCount = $null
                DueToDoCount    = $null
                DueHabitCount   = $null
                HabiticaUser    = $null
            }
            AllCommands    = $null
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
        $ProfileCache.ReleasePreview = Get-PSReleaseCurrent -Preview
        $ProfileCache.Saved = Get-Date
        $ProfileCache.AllCommands = Get-Command -All

        $SaveCache = $true

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

    Write-Host -Object "⚒ " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.HabiticaUser.stats.lvl) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Level " -NoNewline
    Write-Host -Object " $(($ProfileCache.Habitica.HabiticaUser.stats.gp.ToString("N0"))) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Gold " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueHabitCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Habits (inacted) " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueDailiesCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " Dailies (left) " -NoNewline
    Write-Host -Object " $($ProfileCache.Habitica.DueToDoCount) " -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object " To-Dos ⚒"

    $randomCommand = $ProfileCache.AllCommands | Get-Random

    Write-Host -Object "⌨ " -NoNewline
    Write-Host -Object $randomCommand.Name -NoNewline -ForegroundColor Black -BackgroundColor White
    Write-Host -Object ' ' -NoNewline
    Write-Host -Object $randomCommand.CommandType.ToString() -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object ' ' -NoNewline
    Write-Host -Object $randomCommand.Source -NoNewline
    Write-Host -Object " ⌨"

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
}

function prompt {
    $formattedTime = (Get-Date).ToShortTimeString()
    # $formattedTime = "[$(($formattedDate | Out-String).trim())]"
    Try {
        $repoStatus = Get-RepositoryStatus
        Write-Host -Object "GIT" -NoNewline -BackgroundColor Yellow -ForegroundColor Red
        Write-Host -Object " " -NoNewline
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
        Write-Host -Object "PSC" -NoNewline -BackgroundColor Yellow -ForegroundColor Red
        Write-Host -Object " " -NoNewline
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

$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate.txt"

Start-Transcript -Path $TranscriptFilePath -Append

# Invoke-Expression (&starship init powershell)
