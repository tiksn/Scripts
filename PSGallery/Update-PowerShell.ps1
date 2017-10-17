
<#PSScriptInfo

.VERSION 1.1.0.0

.GUID aa6f8439-84b2-42b6-81b3-268677c71402

.AUTHOR Tigran TIKSN Thorosyan

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


#>

#Requires -Module PowerShellGet

<# 

.DESCRIPTION 
 Updates PowerShell scripts, modules and help

#> 
Param()

Update-Module
Update-Script
Update-Help
