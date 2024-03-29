
<#PSScriptInfo

.VERSION 1.1.0

.GUID ae0a8e93-0a77-4fb7-9837-64776641fc34

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT

.TAGS git

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Update one or more Git repositories 

#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
Param(
    # Path to the folder that contains one ore more Git repositories
    [Parameter()]
    [string]
    $Path = (Get-Location).Path,
    # Gets the Git repositories in the specified locations and in all sub-directories.
    [Parameter()]
    [switch]
    $Recurse,
    # Cleanup unnecessary files and optimize the local repository.
    [Parameter()]
    [switch]
    $CollectGarbage
)

function IsGitRepository {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to one locations.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )
    $gitDirectoryPath = Join-Path -Path $Path -ChildPath '.git'
    if (Test-Path -Path $gitDirectoryPath) {
        $gitItem = Get-Item -Path $gitDirectoryPath -Force

        if ($gitItem.PSIsContainer) {
            return $true
        }
        else {
            return $false
        }
    }
    else {
        return $false
    }
}

function UpdateGitRepository {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to one locations.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $ScriptCmdlet,
        [Parameter()]
        [switch]
        $CollectGarbage
    )
    
    Push-Location
    try {
        Set-Location $Path
        Write-Verbose -Message "Changed working directory to $Path"

        Write-Progress -Id 2087581109 -Activity "Fetching $Path"
        git fetch --all --prune --tags --recurse-submodules=yes
        if ($?) {
            if ($ScriptCmdlet.ShouldProcess($Path, 'Pull Git remote changes')) {
                Write-Progress -Id 2087581109 -Activity "Pulling $Path"
                git pull --recurse-submodules=yes --ff-only --rebase=true
            }
        }

        if ($CollectGarbage.IsPresent) {
            Write-Progress -Id 2087581109 -Activity "Collect Garbage $Path"
            git gc
        }
    }
    finally {
        
        Pop-Location
    }
}

function UpdateGitRepositories {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to one locations.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [object]
        $ScriptCmdlet,
        [Parameter()]
        [switch]
        $CollectGarbage
    )

    $subDirectories = Get-ChildItem -Path $Path -Directory
    foreach ($subDirectory in $subDirectories) {
        if (IsGitRepository -Path $subDirectory) {
            UpdateGitRepository -Path $subDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
        else {
            UpdateGitRepositories -Path $subDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
    }
}

$resolvedPath = Resolve-Path -Path $Path
if ($?) {
    $parentDirectory = Get-Item -Path $resolvedPath
    if ($null -eq $parentDirectory) {
        Write-Error -Message "Path $resolvedPath is not accessible." -Category ObjectNotFound
    }
    else {
        $ScriptCmdlet = $PSCmdlet
        if ($parentDirectory.PSIsContainer) {
            if (IsGitRepository -Path $parentDirectory) {
                UpdateGitRepository -Path $parentDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
            }
            elseif ($Recurse) {
                UpdateGitRepositories -Path $parentDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
            }
            else {
                Write-Error -Message "$resolvedPath is not a git repository directory." -Category InvalidArgument
            }
        }
        else {
            Write-Error -Message "Path $resolvedPath is not a directory." -Category InvalidArgument
        }
    }
}
Write-Progress -Id 2087581109 -Activity 'Finished' -Completed
