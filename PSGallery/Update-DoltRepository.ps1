
<#PSScriptInfo

.VERSION 1.1.0

.GUID 0e6806b4-048d-4d8b-a863-2213301ab18e

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT

.TAGS dolt

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
 Update one or more Dolt repositories 

#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
Param(
    # Path to the folder that contains one ore more dolt repositories
    [Parameter()]
    [string]
    $Path = (Get-Location).Path,
    # Gets the Dolt repositories in the specified locations and in all sub-directories.
    [Parameter()]
    [switch]
    $Recurse,
    # Cleans up unreferenced data from the repository.
    [Parameter()]
    [switch]
    $CollectGarbage
)

function IsDoltRepository {
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to one locations.')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )
    $doltDirectoryPath = Join-Path -Path $Path -ChildPath '.dolt'
    if (Test-Path -Path $doltDirectoryPath) {
        $doltItem = Get-Item $doltDirectoryPath

        if ($doltItem.PSIsContainer) {
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

function UpdateDoltRepository {
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
        dolt fetch
        if ($?) {
            if ($ScriptCmdlet.ShouldProcess($Path, 'Pull Dolt remote changes')) {
                Write-Progress -Id 2087581109 -Activity "Pulling $Path"
                dolt pull
            }
        }

        if ($CollectGarbage.IsPresent) {
            Write-Progress -Id 2087581109 -Activity "Collect Garbage $Path"
            dolt gc
        }
    }
    finally {
        
        Pop-Location
    }
}

function UpdateDoltRepositories {
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
        if (IsDoltRepository -Path $subDirectory) {
            UpdateDoltRepository -Path $subDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
        else {
            UpdateDoltRepositories -Path $subDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
    }
}

$parentDirectory = Get-Item $Path
if ($null -eq $parentDirectory) {
    Write-Error -Message "Path $Path is not accessible." -Category ObjectNotFound
}
else {
    $ScriptCmdlet = $PSCmdlet
    if ($parentDirectory.PSIsContainer) {
        if (IsDoltRepository -Path $parentDirectory) {
            UpdateDoltRepository -Path $parentDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
        elseif ($Recurse) {
            UpdateDoltRepositories -Path $parentDirectory -ScriptCmdlet $ScriptCmdlet -CollectGarbage:$CollectGarbage
        }
        else {
            Write-Error -Message "$Path is not a dolt repository directory." -Category InvalidArgument
        }
    }
    else {
        Write-Error -Message "Path $Path is not a directory." -Category InvalidArgument
    }
}

Write-Progress -Id 2087581109 -Activity 'Finished' -Completed
