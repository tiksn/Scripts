Import-Module -Name ObjectiveGit
Import-Module -Name posh-git
Import-Module -Name Habitica
Import-Module -Name PSCalendar
Import-Module -Name PSReleaseTools

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN) {
    $profileRunTime = Get-Date
    $formattedDate = $profileRunTime.ToString("f")
    $formattedDate = "⌚ $(($formattedDate | Out-String).trim()) ⌚"

    Write-Host -Object $formattedDate -BackgroundColor Cyan -ForegroundColor DarkBlue
    Write-Host -Object ' '

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
                DueDailies      = $null
                DueDailiesCount = $null
                DueToDos        = $null
                DueToDoCount    = $null
                DueHabits       = $null
                DueHabitsCount  = $null
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

            $dailys = Get-HabiticaTask -Type dailys
            $todos = Get-HabiticaTask -Type todos
            $habits = Get-HabiticaTask -Type habits

            $ProfileCache.Habitica.DueDailies = $dailys | Where-Object { $_.IsDue -and (-not $_.completed) } 
            $ProfileCache.Habitica.DueDailiesCount = ($ProfileCache.Habitica.DueDailies | Measure-Object).Count
            $ProfileCache.Habitica.DueToDos = $todos
            $ProfileCache.Habitica.DueToDoCount = ($ProfileCache.Habitica.DueToDos | Measure-Object).Count
            $ProfileCache.Habitica.DueHabits = $habits | Where-Object { ($_.counterUp -eq 0) -and ($_.counterDown -eq 0) }
            $ProfileCache.Habitica.DueHabitsCount = ($ProfileCache.Habitica.DueHabits | Measure-Object).Count
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

    $isWorkDay = ($profileRunTime.DayOfWeek -ne [System.DayOfWeek]::Saturday) -and ($profileRunTime.DayOfWeek -ne [System.DayOfWeek]::Sunday)
    $isWorkHour = ($profileRunTime.TimeOfDay -gt [System.TimeSpan]::FromHours(10) -and ($profileRunTime.TimeOfDay -lt [System.TimeSpan]::FromHours(20)))

    if (-not $isWorkDay -or -not $isWorkHour) {
        foreach ($dueDaily in $ProfileCache.Habitica.DueDailies) {
            Write-Host -Object "🍒 " -NoNewline
            Write-Host -Object $dueDaily.text -NoNewline
            if ($dueDaily.notes) {
                Write-Host -Object ' (' -NoNewline
                Write-Host -Object $dueDaily.notes -NoNewline
                Write-Host -Object ')' -NoNewline
            }
            Write-Host -Object " 🍒"

            foreach ($dueDailySubTask in $dueDaily.checklist) {
                #
            }
        }

        # order by $dueHabit.value or $dueHabit.priority
        $topDueHabits = $ProfileCache.Habitica.DueHabits | Sort-Object -Property value -Descending | Select-Object -First 5
        foreach ($dueHabit in $topDueHabits) {
            Write-Host -Object "👑 " -NoNewline
            Write-Host -Object $dueHabit.text -NoNewline
            if ($dueHabit.notes) {
                Write-Host -Object ' (' -NoNewline
                Write-Host -Object $dueHabit.notes -NoNewline
                Write-Host -Object ')' -NoNewline
            }
        
            Write-Host -Object " 👑"
        }

        # order by $dueHabit.value or $dueHabit.priority
        $topDueToDos = $ProfileCache.Habitica.DueToDos | Sort-Object -Property value -Descending | Select-Object -First 5
        foreach ($dueToDo in $topDueToDos) {
            Write-Host -Object "🏆 " -NoNewline
            Write-Host -Object $dueToDo.text -NoNewline
            if ($dueToDo.notes) {
                Write-Host -Object ' (' -NoNewline
                Write-Host -Object $dueToDo.notes -NoNewline
                Write-Host -Object ')' -NoNewline
            }
            Write-Host -Object " 🏆"

            $dueToDoSubTasks = $dueToDo.checklist | Where-Object { -not $_.completed }
            foreach ($dueToDoSubTask in $dueToDoSubTasks) {
                Write-Host -Object "    🏆 " -NoNewline
                Write-Host -Object $dueToDoSubTask.text -NoNewline
                Write-Host -Object " 🏆"
            }
        }
    }
    
    Show-Calendar
    Write-Host -Object " "

    $randomCommand = $ProfileCache.AllCommands | Get-Random

    Write-Host -Object "⌨ " -NoNewline
    Write-Host -Object $randomCommand.Name -NoNewline -ForegroundColor Black -BackgroundColor White
    Write-Host -Object ' ' -NoNewline
    Write-Host -Object $randomCommand.CommandType.ToString() -NoNewline -BackgroundColor Yellow -ForegroundColor Magenta
    Write-Host -Object ' ' -NoNewline
    Write-Host -Object $randomCommand.Source -NoNewline
    Write-Host -Object " ⌨"
    Write-Host -Object " "

    gh completion --shell powershell | Set-Variable -Name ghCompletion

    $ghCompletion = $ghCompletion | ForEach-Object { Write-Output $_ } | Join-String -Separator ([System.Environment]::NewLine)
    $ghCompletion = [scriptblock]::Create($ghCompletion)
    Invoke-Command -ScriptBlock $ghCompletion 
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
$instanceId = $Host.InstanceId
$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate $instanceId.txt"

Start-Transcript -Path $TranscriptFilePath -Append

# Invoke-Expression (&starship init powershell)
