function Test-InteractiveConsole {
    $Host.Name -eq 'ConsoleHost' -and
    -not [System.Console]::IsInputRedirected -and
    -not [System.Console]::IsOutputRedirected
}

function Import-OptionalModule {
    param (
        [Parameter(Mandatory)]
        [string] $Name
    )

    Import-Module -Name $Name -ErrorAction SilentlyContinue
    $null -ne (Get-Module -Name $Name)
}

function Invoke-CachedCompletionScript {
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [scriptblock] $Generator,

        [TimeSpan] $MaxAge = [TimeSpan]::FromDays(7)
    )

    $cacheRoot = if ($env:LOCALAPPDATA) {
        Join-Path -Path $env:LOCALAPPDATA -ChildPath 'PowerShell\CompletionCache'
    }
    else {
        Join-Path -Path $HOME -ChildPath '.cache/powershell/completions'
    }

    $cachePath = Join-Path -Path $cacheRoot -ChildPath "$Name.ps1"
    $cacheItem = Get-Item -LiteralPath $cachePath -ErrorAction SilentlyContinue
    if ($null -eq $cacheItem -or ((Get-Date) - $cacheItem.LastWriteTime) -gt $MaxAge) {
        New-Item -Path $cacheRoot -ItemType Directory -Force | Out-Null
        $completionScript = try {
            & $Generator 2>$null | Out-String
        }
        catch {
            $null
        }
        if (-not [string]::IsNullOrWhiteSpace($completionScript)) {
            Set-Content -LiteralPath $cachePath -Value $completionScript -Encoding utf8
        }
    }

    if (Test-Path -LiteralPath $cachePath) {
        . $cachePath
    }
}

$script:IsInteractiveConsole = Test-InteractiveConsole
$script:IsTerminalSession = $script:IsInteractiveConsole -and (
    ($env:WT_SESSION -and $null -eq $env:TERM_PROGRAM) -or
    $env:TERMINATOR_UUID -or
    $env:GNOME_TERMINAL_SCREEN -or
    ($env:TERM_PROGRAM -eq 'FluentTerminal') -or
    ($env:TERM_PROGRAM -eq 'Apple_Terminal') -or
    ($env:TERM_PROGRAM -eq 'iTerm.app')
)

if ($script:IsInteractiveConsole) {
    if ((Import-OptionalModule -Name SecretManagementArgumentCompleter) -and (Get-Command -Name Import-SecretManagementArgumentCompleter -ErrorAction SilentlyContinue)) {
        Import-SecretManagementArgumentCompleter
    }

    if (Import-OptionalModule -Name PSReadLine) {
        # Import-Module -Name Az.Tools.Predictor
        # Enable-AzPredictor
        $predictionSource = if (Import-OptionalModule -Name CompletionPredictor) { 'HistoryAndPlugin' } else { 'History' }
        try {
            Set-PSReadLineOption -PredictionSource $predictionSource -ErrorAction Stop
            Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
        }
        catch {
            Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        }

        Set-PSReadLineOption -EditMode Windows

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

    [System.Console]::InputEncoding = [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
}

if ($script:IsTerminalSession) {
    # PowerShell parameter completion shim for the WinGet
    if (Get-Command -Name winget -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
            $Local:word = $wordToComplete.Replace('"', '""')
            $Local:ast = $commandAst.ToString().Replace('"', '""')
            winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }

    if (Get-Command -Name gh -ErrorAction SilentlyContinue) {
        Invoke-CachedCompletionScript -Name gh -Generator { gh completion --shell powershell }
    }

    if (Get-Command -Name dapr -ErrorAction SilentlyContinue) {
        Invoke-CachedCompletionScript -Name dapr -Generator { dapr completion powershell }
    }

    if (Get-Command rustup -ErrorAction Ignore) {
        Invoke-CachedCompletionScript -Name rustup -Generator { rustup completions powershell rustup }
        Invoke-CachedCompletionScript -Name cargo -Generator { rustup completions powershell cargo }
    }

    # PowerShell parameter completion shim for the dotnet CLI
    if (Get-Command -Name dotnet -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
            param($commandName, $wordToComplete, $cursorPosition)
            dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }

    if (Get-Command -Name az -ErrorAction SilentlyContinue) {
        Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
            param($commandName, $wordToComplete, $cursorPosition)
            $completion_file = New-TemporaryFile
            try {
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
            }
            finally {
                Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL -ErrorAction SilentlyContinue
            }
        }
    }
}

if ($script:IsInteractiveConsole -and (Get-Command -Name zoxide -ErrorAction SilentlyContinue)) {
    Invoke-CachedCompletionScript -Name zoxide-init -MaxAge ([TimeSpan]::FromDays(30)) -Generator { zoxide init powershell }
}

if ($script:IsInteractiveConsole -and $env:WT_PROFILE_ID -eq '{2595cd9c-8f05-55ff-a1d4-93f3041ca67f}' -and (Get-Command -Name starship -ErrorAction SilentlyContinue)) {
    # PowerShell Preview
    Invoke-CachedCompletionScript -Name starship-init -MaxAge ([TimeSpan]::FromDays(30)) -Generator { starship init powershell }
}
elseif ($script:IsInteractiveConsole -and (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue)) {
    if ($IsMacOS) {
        if (Get-Command -Name brew -ErrorAction SilentlyContinue) {
            $env:POSH_THEMES_PATH = "$(brew --prefix oh-my-posh)/themes"
        }
        $env:PATH += ":$HOME/.aspire/bin"
        $env:PATH += ":$HOME/.local/bin"
    }

    $ompThemePath = if (Test-Path -LiteralPath (Join-Path -Path $HOME -ChildPath 'theme.omp.json')) {
        Join-Path -Path $HOME -ChildPath 'theme.omp.json'
    }
    elseif ($env:POSH_THEMES_PATH) {
        $themePath = Join-Path -Path $env:POSH_THEMES_PATH -ChildPath 'powerlevel10k_rainbow.omp.json'
        if (Test-Path -LiteralPath $themePath) {
            $themePath
        }
    }

    if ($ompThemePath) {
        $ompCacheName = if ((Split-Path -Path $ompThemePath -Leaf) -eq 'theme.omp.json') { 'oh-my-posh-init-custom' } else { 'oh-my-posh-init-source' }
        Invoke-CachedCompletionScript -Name $ompCacheName -MaxAge ([TimeSpan]::FromDays(30)) -Generator { oh-my-posh init pwsh --config $ompThemePath }
    }
    else {
        Invoke-CachedCompletionScript -Name oh-my-posh-init -MaxAge ([TimeSpan]::FromDays(30)) -Generator { oh-my-posh init pwsh }
    }
}
