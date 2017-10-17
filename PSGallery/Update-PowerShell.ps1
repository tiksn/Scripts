
<#PSScriptInfo

.VERSION 1.1.0

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
	.SYNOPSIS
		A brief description of the Update-PowerShell.ps1 file.
	
	.DESCRIPTION
		Updates PowerShell scripts, modules and help
	
	.PARAMETER Verbose
		A description of the Verbose parameter.
	
	.NOTES
		Additional information about the file.
#>
param
(
	[switch]$Verbose
)

Update-Module -Verbose:$Verbose
Update-Script -Verbose:$Verbose
Update-Help
