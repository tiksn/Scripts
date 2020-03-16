[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$WindowsTerminalMode = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$applyButton = $null
[System.Windows.Forms.Button]$cancelButton = $null
[System.Windows.Forms.Label]$currentBranchLabel = $null
[System.Windows.Forms.ComboBox]$branchesComboBox = $null
[System.Windows.Forms.Label]$currentBranchValueLabel = $null
function InitializeComponent
{
$applyButton = (New-Object -TypeName System.Windows.Forms.Button)
$cancelButton = (New-Object -TypeName System.Windows.Forms.Button)
$currentBranchLabel = (New-Object -TypeName System.Windows.Forms.Label)
$currentBranchValueLabel = (New-Object -TypeName System.Windows.Forms.Label)
$branchesComboBox = (New-Object -TypeName System.Windows.Forms.ComboBox)
$WindowsTerminalMode.SuspendLayout()
#
#applyButton
#
$applyButton.Enabled = $false
$applyButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]216,[System.Int32]126))
$applyButton.Name = [System.String]'applyButton'
$applyButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$applyButton.TabIndex = [System.Int32]0
$applyButton.Text = [System.String]'Apply'
$applyButton.UseVisualStyleBackColor = $true
$applyButton.add_Click($applyButton_Click)
#
#cancelButton
#
$cancelButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]297,[System.Int32]126))
$cancelButton.Name = [System.String]'cancelButton'
$cancelButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]23))
$cancelButton.TabIndex = [System.Int32]1
$cancelButton.Text = [System.String]'Cancel'
$cancelButton.UseVisualStyleBackColor = $true
$cancelButton.add_Click($cancelButton_Click)
#
#currentBranchLabel
#
$currentBranchLabel.AutoSize = $true
$currentBranchLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]20,[System.Int32]21))
$currentBranchLabel.Name = [System.String]'currentBranchLabel'
$currentBranchLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]84,[System.Int32]13))
$currentBranchLabel.TabIndex = [System.Int32]2
$currentBranchLabel.Text = [System.String]'Current Branch: '
#
#currentBranchValueLabel
#
$currentBranchValueLabel.AutoSize = $true
$currentBranchValueLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]110,[System.Int32]21))
$currentBranchValueLabel.Name = [System.String]'currentBranchValueLabel'
$currentBranchValueLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]0,[System.Int32]13))
$currentBranchValueLabel.TabIndex = [System.Int32]3
#
#branchesComboBox
#
$branchesComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$branchesComboBox.FormattingEnabled = $true
$branchesComboBox.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]37))
$branchesComboBox.Name = [System.String]'branchesComboBox'
$branchesComboBox.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]360,[System.Int32]21))
$branchesComboBox.TabIndex = [System.Int32]4
$branchesComboBox.add_SelectedIndexChanged($branchesComboBox_SelectedIndexChanged)
#
#WindowsTerminalMode
#
$WindowsTerminalMode.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]384,[System.Int32]161))
$WindowsTerminalMode.Controls.Add($branchesComboBox)
$WindowsTerminalMode.Controls.Add($currentBranchValueLabel)
$WindowsTerminalMode.Controls.Add($currentBranchLabel)
$WindowsTerminalMode.Controls.Add($cancelButton)
$WindowsTerminalMode.Controls.Add($applyButton)
$WindowsTerminalMode.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$WindowsTerminalMode.Name = [System.String]'WindowsTerminalMode'
$WindowsTerminalMode.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$WindowsTerminalMode.Text = [System.String]'Windows Terminal Mode'
$WindowsTerminalMode.add_Load($WindowsTerminalMode_Load)
$WindowsTerminalMode.ResumeLayout($false)
$WindowsTerminalMode.PerformLayout()
Add-Member -InputObject $WindowsTerminalMode -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $WindowsTerminalMode -Name applyButton -Value $applyButton -MemberType NoteProperty
Add-Member -InputObject $WindowsTerminalMode -Name cancelButton -Value $cancelButton -MemberType NoteProperty
Add-Member -InputObject $WindowsTerminalMode -Name currentBranchLabel -Value $currentBranchLabel -MemberType NoteProperty
Add-Member -InputObject $WindowsTerminalMode -Name branchesComboBox -Value $branchesComboBox -MemberType NoteProperty
Add-Member -InputObject $WindowsTerminalMode -Name currentBranchValueLabel -Value $currentBranchValueLabel -MemberType NoteProperty
}
. InitializeComponent
