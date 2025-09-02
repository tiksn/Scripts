Import-Module -Name posh-git
Import-Module -Name PowerShellHumanizer
Import-Module -Name PSCalendar
Import-Module -Name SecretManagementArgumentCompleter
Import-SecretManagementArgumentCompleter

if ($Host.Name -eq 'ConsoleHost') {
    Import-Module -Name PSReadLine

    # Import-Module -Name Az.Tools.Predictor
    # Enable-AzPredictor
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

    [System.Console]::InputEncoding = [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
}

if ($env:WT_SESSION -or $env:TERMINATOR_UUID -or $env:GNOME_TERMINAL_SCREEN -or ($env:TERM_PROGRAM -eq 'FluentTerminal') -or ($env:TERM_PROGRAM -eq 'Apple_Terminal') -or ($env:TERM_PROGRAM -eq 'iTerm.app')) {
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

Invoke-Expression (& { (zoxide init powershell | Out-String) })

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
    oh-my-posh init pwsh --config $HOME/theme.omp.json | Invoke-Expression
}
