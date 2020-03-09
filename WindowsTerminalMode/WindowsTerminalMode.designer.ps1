[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$WindowsTerminalMode = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$WindowsTerminalMode.SuspendLayout()
#
#WindowsTerminalMode
#
$WindowsTerminalMode.Name = 'WindowsTerminalMode'
$WindowsTerminalMode.ResumeLayout($false)
}

InitializeComponent