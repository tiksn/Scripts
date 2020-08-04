
<#PSScriptInfo

.VERSION 1.0

.GUID d60c3aeb-ffaa-4e56-8ff3-c2f080d06992

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

#Requires -Module BurntToast

<# 

.DESCRIPTION 
 Countdown Timer 

#> 
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [int]
    $Minutes,
    [Parameter()]
    [switch]
    $Wait
)

$job = Start-Job -Name 'Countdown Timer' -ScriptBlock {
    param (
        $Minutes
    )

    $duration = New-TimeSpan -Minutes $Minutes

    $startTime = Get-Date
    $endTime = $startTime.Add($duration)

    do {
        $remainingTime = $endTime.Subtract((Get-Date))
        $remainingTime = New-TimeSpan -Seconds ([math]::Round($remainingTime.TotalSeconds))

        if ($remainingTime -le [timespan]::Zero) {
            break
        }

        Write-Host ($remainingTime.ToString('g'))
        Start-Sleep -Seconds 1
    } until ($remainingTime -le [timespan]::Zero)

    New-BurntToastNotification -Text "Countdown Timer for $Minutes minutes ended." -UniqueIdentifier (New-Guid)
} -ArgumentList $Minutes 

if ($Wait) {
    $job | Receive-Job -Wait
}