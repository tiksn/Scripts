$cancelButton_Click = {
    $WindowsTerminalMode.Close()
}

Import-Module -Name posh-git
# Import-Module -Name ObjectiveGit

function GetCurrentBranchValue {
    $wtPackage = Get-AppPackage -Name Microsoft.WindowsTerminal
    $packagesPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Packages'
    $wtPackageDateFolder = Join-Path -Path $packagesPath -ChildPath $wtPackage.PackageFamilyName
    $wtGitRepoPath = Join-Path -Path $wtPackageDateFolder -ChildPath "LocalState"
    $branches = Get-Branch -Repository $wtGitRepoPath
    $currentBranch = $branches | Where-Object { $_.Current }

    $currentBranchValueLabel.Text = $currentBranch.Name
}

$WindowsTerminalMode_Load = {
    GetCurrentBranchValue
}

. (Join-Path $PSScriptRoot 'WindowsTerminalMode.designer.ps1')

$WindowsTerminalMode.ShowDialog()

