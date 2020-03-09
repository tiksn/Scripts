$branchesComboBox_SelectedIndexChanged = {
    $applyButton.Enabled = $true
}

$applyButton_Click = {
    # Set-Branch
    $branchesComboBox.SelectedItem | Out-GridView -Wait
}

$cancelButton_Click = {
    $WindowsTerminalMode.Close()
}

Import-Module -Name posh-git
# Import-Module -Name ObjectiveGit

function GetGitRepoPath {
    $wtPackage = Get-AppPackage -Name Microsoft.WindowsTerminal
    $packagesPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Packages'
    $wtPackageDateFolder = Join-Path -Path $packagesPath -ChildPath $wtPackage.PackageFamilyName
    $wtGitRepoPath = Join-Path -Path $wtPackageDateFolder -ChildPath "LocalState"
    return $wtGitRepoPath
}
function GetBranchValues {
    $wtGitRepoPath = GetGitRepoPath
    $branches = Get-Branch -Repository $wtGitRepoPath
    $currentBranch = $branches | Where-Object { $_.Current }

    $currentBranchValueLabel.Text = $currentBranch.Name

    if ($currentBranch.Name -eq 'master') {
        $currentBranchValueLabel.ForeColor = [System.Drawing.Color]::Blue
    }
    else {
        $currentBranchValueLabel.ForeColor = [System.Drawing.Color]::Red
    }

    $localBranches = $branches | Where-Object { -not $_.Remote }

    $branchesComboBox.Items.Clear()
    $applyButton.Enabled = $false

    foreach ($branch in $localBranches) {
        $branchesComboBox.Items.Add($branch.Name)
    }
}

$WindowsTerminalMode_Load = {
    GetBranchValues
}

. (Join-Path $PSScriptRoot 'WindowsTerminalMode.designer.ps1')

$WindowsTerminalMode.ShowDialog()

