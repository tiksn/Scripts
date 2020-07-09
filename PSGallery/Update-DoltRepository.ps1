
<#PSScriptInfo

.VERSION 1.0.0

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
[CmdletBinding()]
Param(
    # Path to the folder that contains one ore more dolt repositories
    [Parameter()]
    [string]
    $Path = (Get-Location).Path,
    # Gets the Dolt repositories in the specified locations and in all sub-directories.
    [Parameter()]
    [switch]
    $Recurse
)

# Update-DoltRepository

function IsDoltRepository {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Path to one locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )
    $doltDirectoryPath = Join-Path -Path $Path -ChildPath ".dolt"
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
        [Parameter(Mandatory = $true, HelpMessage = "Path to one locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )
    
    Push-Location
    try {
        Set-Location $Path
        Write-Verbose -Message "Changed working directory to $Path"

        dolt fetch
        if ($?) {
            dolt pull
        }
    }
    finally {
        Pop-Location
    }
}

function UpdateDoltRepositories {
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Path to one locations.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    throw 'not implemented'
}

$parentDirectory = Get-Item $Path
if ($null -eq $parentDirectory) {
    Write-Error -Message "Path $Path is not accessible." -Category ObjectNotFound
}
else {
    if ($parentDirectory.PSIsContainer) {
        if (IsDoltRepository -Path $parentDirectory) {
            UpdateDoltRepository -Path $parentDirectory
        }
        elseif ($Recurse) {
            UpdateDoltRepositories -Path $parentDirectory
        }
        else {
            Write-Error -Message "$Path is not a dolt repository directory." -Category InvalidArgument
        }
    }
    else {
        Write-Error -Message "Path $Path is not a directory." -Category InvalidArgument
    }
}
