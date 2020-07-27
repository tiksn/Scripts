
<#PSScriptInfo

.VERSION 1.0

.GUID 9c2f9703-953f-4765-933b-c1bfd3bdb2b9

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


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Spell out the password 

#> 

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Password
)

Import-Module -Name PowerShellHumanizer

if (-not $Password) {
    $Password = Read-Host -Prompt "Password"
}
$chars = $Password.ToCharArray()

foreach ($char in $chars) {
    $category = [System.Char]::GetUnicodeCategory($char)
    $category = $category.ToString().Humanize()
    Write-Host -Object "$char`t$category"
}
