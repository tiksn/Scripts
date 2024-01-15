
<#PSScriptInfo

.VERSION 1.0.0

.GUID 0c54c8cd-f696-4177-9f02-33cda299da78

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT Copyright © Tigran TIKSN Torosyan

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Module PSFramework

<#

.DESCRIPTION
 Removes Old Module Versions

#>
[CmdletBinding()]
Param()

Write-PSFMessage -Level Debug -Message 'Looking up for all modules'
$allModules = Get-Module -ListAvailable

$modulePaths = $env:PSModulePath -split ';'

foreach ($modulePath in $modulePaths) {
    Write-PSFMessage -Level Verbose -Message "Looking up for module path $modulePath"
    if (Test-Path -Path $modulePath) {
        $singleModulePaths = Get-ChildItem -Path $modulePath -Directory
        foreach ($singleModulePath in $singleModulePaths) {
            $singleModuleName = $singleModulePath.Name
            Write-PSFMessage -Level Verbose -Message "Looking up for '$singleModuleName' module path $singleModulePath"
            if (Test-Path -Path (Join-Path -Path $singleModulePath -ChildPath "$singleModuleName.psd1")) {
                Write-PSFMessage -Level Verbose -Message "'$singleModuleName' has no versions"
            }
            else {
                $singleModuleVersionPaths = Get-ChildItem -Path $singleModulePath -Directory
                $singleModuleVersionList = @()
                foreach ($singleModuleVersionPath in $singleModuleVersionPaths) {
                    $singleModuleVersion = [version]$singleModuleVersionPath.Name
                    Write-PSFMessage -Level Verbose -Message "Looking up for '$singleModuleName' module '$singleModuleVersion' version path $singleModuleVersionPath"
                    $singleModuleVersionList += ([PSCustomObject]@{
                            Name    = $singleModuleName
                            Version = $singleModuleVersion
                            Path    = $singleModuleVersionPath
                        })
                }
                if ($singleModuleVersionList.Count -gt 0) {
                    $singleModuleLatestVersion = ($singleModuleVersionList | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
                    $singleModuleOldestVersionList = $singleModuleVersionList | Where-Object { $PSItem.Version -lt $singleModuleLatestVersion } | Sort-Object -Property Version
                    foreach ($singleModuleOldestVersion in $singleModuleOldestVersionList) {
                        Write-PSFMessage -Level Verbose -Message "Examining '$singleModuleName' module '$($singleModuleOldestVersion.Version)' version path $($singleModuleOldestVersion.Path)"
                        $isRequiredModule = $false
                        foreach ($givenModule in $allModules) {
                            foreach ($givenRequiredModule in $givenModule.RequiredModules) {
                                if (($givenRequiredModule.Name -eq $singleModuleOldestVersion.Name) -and ($givenRequiredModule.Version -eq $singleModuleOldestVersion.Version)) {
                                    $isRequiredModule = $true
                                    Write-PSFMessage -Level Verbose -Message "'$singleModuleName' module '$($singleModuleOldestVersion.Version)' version is required by '$($givenModule.Name)' module '$($givenModule.Version)' version"
                                }
                            }
                        }
                        if (-not $isRequiredModule) {
                            Write-PSFMessage -Level Verbose -Message "Deleting '$singleModuleName' module '$($singleModuleOldestVersion.Version)' version from '$($singleModuleOldestVersion.Path)' path"
                            Remove-Item -Path ($singleModuleOldestVersion.Path) -Recurse -Force
                            Write-PSFMessage -Level Important -Message "Deleted '$singleModuleName' module '$($singleModuleOldestVersion.Version)' version from '$($singleModuleOldestVersion.Path)' path"
                        }
                    }
                }
            }
        }
    }
    else {
        Write-PSFMessage -Level Warning -Message "Module path $modulePath does not exist"
    }
}