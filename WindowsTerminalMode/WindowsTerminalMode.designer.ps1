[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$WindowsTerminalMode = New-Object -TypeName System.Windows.Forms.Form
function InitializeComponent
{
$WindowsTerminalMode.SuspendLayout()
#
#WindowsTerminalMode
#
$WindowsTerminalMode.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]384,[System.Int32]161))
$WindowsTerminalMode.Name = [System.String]'WindowsTerminalMode'
$WindowsTerminalMode.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$WindowsTerminalMode.Text = [System.String]'Windows Terminal Mode'
$WindowsTerminalMode.ResumeLayout($false)
Add-Member -InputObject $WindowsTerminalMode -Name base -Value $base -MemberType NoteProperty
}
. InitializeComponent
