
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
    # Parameter help description
    [Parameter()]
    [string]
    $Path = (Get-Location).Path
)

$parentDirectory = Get-Item $Path
if ($null -eq $parentDirectory) {
    Write-Error -Message "Path $Path is not accessible." -Category ObjectNotFound
}
else {
    if ($parentDirectory.PSIsContainer) {

    }
    Write-Error -Message "Path $Path is not a directory." -Category InvalidArgument
}

