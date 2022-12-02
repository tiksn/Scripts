Import-Module -Name posh-git
Import-Module -Name PowerShellHumanizer
Import-Module -Name PSCalendar
Import-Module -Name SecretManagementArgumentCompleter
Import-SecretManagementArgumentCompleter

function Show-Time {
    [CmdletBinding()]
    param (
        
    )
    
    $timeNow = Get-Date
    $timeNowInKyiv = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($timeNow, 'FLE Standard Time')
    $timeNowInWarsaw = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($timeNow, 'Central European Standard Time')

    $timeInKyiv = $timeNowInKyiv.ToShortTimeString()
    $timeInWarsaw = $timeNowInWarsaw.ToShortTimeString()

    Write-Host "🤍❤️ $timeInWarsaw Warsaw    💙💛 $timeInKyiv Kyiv"
}

if ($host.Name -eq 'ConsoleHost') {
    Import-Module -Name PSReadLine

    # Import-Module -Name Az.Tools.Predictor
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
}

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN -or ($env:TERM_PROGRAM -eq 'FluentTerminal') -or ($env:TERM_PROGRAM -eq 'Apple_Terminal')) {
    Show-Calendar

    Show-Time

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

# For zoxide v0.8.0+
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath 'PowerShellTranscripts'

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format 'yyyy-MM-dd--HH-mm-ss'
$instanceId = $Host.InstanceId
$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate $instanceId.txt"

Start-Transcript -Path $TranscriptFilePath -Append

if ($env:WT_PROFILE_ID -eq '{2595cd9c-8f05-55ff-a1d4-93f3041ca67f}') {
    # PowerShell Preview
    Invoke-Expression (&starship init powershell)
}
else {
    if ($IsMacOS) {
        $env:POSH_THEMES_PATH = "$(brew --prefix oh-my-posh)/themes"
    }

    oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/free-ukraine.omp.json | Invoke-Expression
    # oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/unicorn.omp.json | Invoke-Expression
}
