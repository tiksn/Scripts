
<#PSScriptInfo

.VERSION 1.0

.GUID a954848e-a6f7-4386-b084-bbd9f5862fb8

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT

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

<# 

.DESCRIPTION 
 Inatall WSL Utilities and other tools 

#>
[CmdletBinding()]
Param()


$distributions = wsl --list | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Skip 1 | ForEach-Object { ($_ -split " ")[0] }
$distributions | Out-GridView -Wait