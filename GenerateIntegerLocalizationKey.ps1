<#PSScriptInfo

.VERSION 1.1.1

.GUID 837753cd-b9c6-4c7e-a5aa-49cb20972b57

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
 Generates an integer localization key.

#>
[CmdletBinding()]
param(
    [switch]$CopyToClipboard
)

$epochStarts = Get-Date -Year 2024 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$epochStartsString = $epochStarts | Get-Date -Format 'u'
Write-PSFMessage -Level Verbose -Message "Epoch starts $epochStartsString"

$minimum = 100000000
$maximum = 1000000000

$epochEnds = $epochStarts + [System.TimeSpan]::FromSeconds($maximum - $minimum)
$epochEndsString = $epochEnds | Get-Date -Format 'u'
Write-PSFMessage -Level Verbose -Message "Epoch ends $epochEndsString"

$instantNow = Get-Date
$instantNowString = $instantNow | Get-Date -Format 'u'
Write-PSFMessage -Level Verbose -Message "Now is $instantNowString"

$passed = $instantNow - $epochStarts
$passedTotalSeconds = [int]$passed.TotalSeconds

Write-PSFMessage -Level Verbose -Message "Total $passedTotalSeconds Seconds passed"
$key = $minimum + $passedTotalSeconds
Write-PSFMessage -Level Verbose -Message "Generated key is $key"

if ($CopyToClipboard) {
    $key | Set-Clipboard
    Write-PSFMessage -Level Important -Message "Copied $key to Clipboard"
}

Write-Output $key

Start-Sleep -Seconds 1
