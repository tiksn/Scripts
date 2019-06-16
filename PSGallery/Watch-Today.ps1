
<#PSScriptInfo

.VERSION 1.0

.GUID 410b07e3-0f11-4621-aa96-f1e47a7e24c5

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME 

.COPYRIGHT TIKSN Lab

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Today's info 

#> 
Param(
    [Parameter(Mandatory=$true)]
    [TimeSpan]$WorkdayBegin,
    [Parameter(Mandatory=$true)]
    [TimeSpan]$WorkdayEnd
)


do {
    Clear-Host

    $date = Get-Date
    # Write-Host $date.ToLongDateString()
    # Write-Host $date.ToShortTimeString()

    if ($date.TimeOfDay -lt $WorkdayBegin) {
        $PercentComplete = 0
        $SecondsRemaining = 0
    } elseif ($date.TimeOfDay -gt $WorkdayEnd ) {
        $PercentComplete = 100
        $SecondsRemaining = 0
    } else {
        $PercentComplete = ($date.TimeOfDay - $WorkdayBegin) * 100 / ($WorkdayEnd - $WorkdayBegin)
        $Remaining = (($WorkdayEnd - $WorkdayBegin) - ($date.TimeOfDay - $WorkdayBegin))
        # Write-Host "Remaining $Remaining"
        $SecondsRemaining = $Remaining.TotalSeconds
    }

    Write-Progress -Activity $date.ToLongDateString() -Status $date.ToShortTimeString() -PercentComplete $PercentComplete -SecondsRemaining $SecondsRemaining

    Start-Sleep -Seconds 60
} until ($false)
