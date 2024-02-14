
<#PSScriptInfo

.VERSION 1.0.0

.GUID 60c7add9-8abb-413c-aadc-9f3643e1e56e

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
 Creates Integer Snowflake based on seconds

#>
Param()


$epochStarts = Get-Date -Year 2024 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$epochStartsString = $epochStarts | Get-Date -Format 'u'
Write-PSFMessage -Level Important -Message "Epoch starts $epochStartsString"

$epochEnds = $epochStarts + [System.TimeSpan]::FromSeconds([System.Int32]::MaxValue)
$epochEndsString = $epochEnds | Get-Date -Format 'u'
Write-PSFMessage -Level Important -Message "Epoch ends $epochEndsString"

$instantNow = Get-Date
$instantNowString = $instantNow | Get-Date -Format 'u'
Write-PSFMessage -Level Important -Message "Now is $instantNowString"

$passed = $instantNow - $epochStarts
$passedTotalSeconds = [int]$passed.TotalSeconds

Write-PSFMessage -Level Important -Message "Total $passedTotalSeconds Seconds passed"
$passedTotalSeconds | Set-Clipboard
Write-PSFMessage -Level Important -Message "Copied $passedTotalSeconds to Clipboard"
