<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.144
	 Created on:   	10/3/2017 12:23 PM
	 Created by:   	Tigran Torosyan
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

Write-Host 'Setup'

Install-Script -Name Update-PowerShell
Install-Script -Name Update-Windows
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host 'Updating PowerShell'
Update-PowerShell

Write-Host 'Updating the antimalware definitions on a computer'
Update-MpSignature

Write-Host 'Updating Windows'
Update-Windows

Write-Host 'Updating Chocolatey packages'
choco upgrade --confirm all

Write-Host 'Done'