Import-Module -Name posh-git
Import-Module -Name PowerShellHumanizer
Import-Module -Name PSCalendar
Import-Module -Name SecretManagementArgumentCompleter
Import-SecretManagementArgumentCompleter
Import-Module -Name F7History

if ($host.Name -eq 'ConsoleHost') {
    Import-Module -Name PSReadLine

    Import-Module -Name Az.Tools.Predictor
    Enable-AzPredictor
    Import-Module -Name CompletionPredictor
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

    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN -or ($env:TERM_PROGRAM -eq 'FluentTerminal') -or ($env:TERM_PROGRAM -eq 'Apple_Terminal')) {
    Show-Calendar

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

    # Dapr CLI
    $daprCliCompletion = dapr completion powershell | Join-String -Separator ([System.Environment]::NewLine)
    $daprCliCompletion = [scriptblock]::Create($daprCliCompletion)
    Invoke-Command -ScriptBlock $daprCliCompletion

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

    Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $completion_file = New-TemporaryFile
        $env:ARGCOMPLETE_USE_TEMPFILES = 1
        $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        $env:_ARGCOMPLETE = 1
        $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
        $env:_ARGCOMPLETE_IFS = "`n"
        $env:_ARGCOMPLETE_SHELL = 'powershell'
        az 2>&1 | Out-Null
        Get-Content $completion_file | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
        Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL
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
        $repoStatus = Get-GitStatus
        if ($null -eq $repoStatus) {
            throw 'Not a git repository folder.'
        }
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

Invoke-Expression (& { (zoxide init powershell | Out-String) })

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath 'PowerShellTranscripts'

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format 'yyyy-MM-dd--HH-mm-ss'
$instanceId = $Host.InstanceId
$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate--$instanceId.txt"

Start-Transcript -Path $TranscriptFilePath -Append

if ($env:WT_PROFILE_ID -eq '{2595cd9c-8f05-55ff-a1d4-93f3041ca67f}') {
    # PowerShell Preview
    Invoke-Expression (&starship init powershell)
}
else {
    if ($IsMacOS) {
        $env:POSH_THEMES_PATH = "$(brew --prefix oh-my-posh)/themes"
    }

    Copy-Item -Path $env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json -Destination $HOME/theme.omp.json -Force
    # Copy-Item -Path $env:POSH_THEMES_PATH/kushal.omp.json -Destination $HOME/theme.omp.json -Force
    # Copy-Item -Path $env:POSH_THEMES_PATH/free-ukraine.omp.json -Destination $HOME/theme.omp.json -Force
    $ompTheme = Get-Content -Path $HOME/theme.omp.json | ConvertFrom-Json -Depth 100
    $timeSegment = $ompTheme.blocks | Select-Object -ExpandProperty segments | Where-Object { $PSItem.type -eq 'time' }
    if ($null -eq $timeSegment.PSObject.Properties.Item('properties')) {
        $timeSegment | Add-Member -MemberType NoteProperty -Name properties -Value @{
            time_format = '3:04 PM'
        }
    }
    elseif ($null -ne $timeSegment.properties.PSObject.Properties.Item('time_format')) {
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '15:04:05', '3:04:05 PM'
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '_2,15:04', '_2, 3:04 PM'
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '15:04', '3:04 PM'
    }
    $ompTheme.console_title_template = '{{ .Folder }}'
    $ompTheme | ConvertTo-Json -Depth 100 | Set-Content -Path $HOME/theme.omp.json
    oh-my-posh --init --shell pwsh --config $HOME/theme.omp.json | Invoke-Expression
}
