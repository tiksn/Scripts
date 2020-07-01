[CmdletBinding()]
param (
    # PartnerTimeZoneId, e.g. 'Mountain Standard Time'
    [Parameter(Mandatory = $true)]
    [string]
    $PartnerTimeZoneId
)

$ErrorActionPreference = 'Stop'

$myTimeZone = Get-TimeZone
$partnerTimeZone = Get-TimeZone -Id $PartnerTimeZoneId
$myDate = Get-Date
$partnerDate = [System.TimeZoneInfo]::ConvertTime($myDate, $partnerTimeZone)

$myWorkHours = [PSCustomObject]@{
    DateFrom = Get-Date -Date $myDate -Hour 8 -Minute 0 -Second 0 -Millisecond 0
    DateTo   = Get-Date -Date $myDate -Hour 20 -Minute 0 -Second 0 -Millisecond 0
    Zone     = $myTimeZone
}

$partnerWorkHours = [PSCustomObject]@{
    DateFrom = Get-Date -Date $partnerDate -Hour 8 -Minute 0 -Second 0 -Millisecond 0
    DateTo   = Get-Date -Date $partnerDate -Hour 20 -Minute 0 -Second 0 -Millisecond 0
    Zone     = $partnerTimeZone
}

$partnerWorkHours = [PSCustomObject]@{
    DateFrom      = $partnerWorkHours.DateFrom
    DateFromLocal = [System.TimeZoneInfo]::ConvertTime($partnerWorkHours.DateFrom, $partnerTimeZone, $myTimeZone)
    DateTo        = $partnerWorkHours.DateTo
    DateToLocal   = [System.TimeZoneInfo]::ConvertTime($partnerWorkHours.DateTo, $partnerTimeZone, $myTimeZone)
    Zone          = $partnerWorkHours.Zone
}

$commonWorkTime = [PSCustomObject]@{
    DateFrom = $myWorkHours.DateFrom -gt $partnerWorkHours.DateFromLocal ? $myWorkHours.DateFrom: $partnerWorkHours.DateFromLocal
    DateTo   = $myWorkHours.DateTo -lt $partnerWorkHours.DateToLocal ? $myWorkHours.DateTo: $partnerWorkHours.DateToLocal
    Zone     = $myTimeZone
}

Write-Output $commonWorkTime
