[CmdletBinding()]
param(
)

$forkRootFolder = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Fork' -Resolve

$forkDevSettingsFile = Join-Path -Path $forkRootFolder -ChildPath 'settings.json' -Resolve
$forkDevSettings = Get-Content -Path $forkDevSettingsFile | ConvertFrom-Json -Depth 100

$forkDevSettings.Fetch_FetchAllRemotes = $true
$forkDevSettings.Pull_Rebase = $true
$forkDevSettings.Pull_StashAndReapply = $true
$forkDevSettings.CommitSpellCheckingMode = 1
$forkDevSettings.CreateBranch_Checkout = $true
$forkDevSettings.InteractiveRebase_CreateBackup = $true
$forkDevSettings.ShellTool = @{
    'Type'            = 'WindowsTerminal'
    'ApplicationPath' = (Get-Command wt).Source
}

$forkDevSettings | ConvertTo-Json -Depth 100 | Set-Content -Path $forkDevSettingsFile
