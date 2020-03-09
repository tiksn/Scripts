$WindowsTerminalMode_Load = {

}

. (Join-Path $PSScriptRoot 'WindowsTerminalMode.designer.ps1')

$WindowsTerminalMode.ShowDialog()

