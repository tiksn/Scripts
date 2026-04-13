<#
.SYNOPSIS
    Uninstalls older duplicate versions of installed PowerShell modules.

.DESCRIPTION
    Scans all installed modules, identifies modules with multiple versions,
    and uninstalls all but the latest version of each. Supports -WhatIf and
    -Confirm for safe operation.

.EXAMPLE
    .\DeduplicateModules.ps1 -Verbose
    Uninstalls older module versions with verbose output.

.EXAMPLE
    .\DeduplicateModules.ps1 -WhatIf
    Shows which modules would be uninstalled without making changes.
#>
[CmdletBinding(SupportsShouldProcess)]
param ()

$allModules = Get-Module -ListAvailable
$multiversionGroups = $allModules |
Group-Object -Property Name |
Where-Object { $PSItem.Count -gt 1 }

if (-not $multiversionGroups) {
    Write-Verbose -Message 'No duplicate module versions found.'
    return
}

$outerProgressId = 1
$innerProgressId = 2

foreach ($group in $multiversionGroups) {
    $outerIndex = [array]::IndexOf($multiversionGroups, $group)
    $sortedModules = $group.Group | Sort-Object -Property Version -Descending
    $latestVersion = $sortedModules | Select-Object -First 1 -ExpandProperty Version
    $allVersions = ($sortedModules | ForEach-Object { $PSItem.Version }) -join ', '
    $outerProgressParams = @{
        Id              = $outerProgressId
        Activity        = 'Uninstalling older versions'
        Status          = "$($group.Name) — versions: $allVersions (keeping $latestVersion)"
        PercentComplete = (($outerIndex + 1) * 100 / $multiversionGroups.Count)
    }
    Write-Progress @outerProgressParams
    $olderModules = $sortedModules |
    Where-Object { $PSItem.Version -lt $latestVersion } |
    Sort-Object -Property Version

    foreach ($olderModule in $olderModules) {
        $innerIndex = [array]::IndexOf($olderModules, $olderModule)
        $innerProgressParams = @{
            Id              = $innerProgressId
            ParentId        = $outerProgressId
            Activity        = 'Uninstalling older version'
            Status          = "$($olderModule.Version) (latest $latestVersion)"
            PercentComplete = (($innerIndex + 1) * 100 / $olderModules.Count)
        }
        Write-Progress @innerProgressParams

        $actionMessage = "Uninstall $($olderModule.Name) $($olderModule.Version) (latest $latestVersion)"
        Write-Verbose -Message "Uninstalling older version of $($olderModule.Name) $($olderModule.Version) (latest $latestVersion)"

        if ($PSCmdlet.ShouldProcess($olderModule.Name, $actionMessage)) {
            Uninstall-PSResource -Name $olderModule.Name -Version $olderModule.Version
        }

        Write-Progress -Id $innerProgressId -Activity 'Uninstalling older version' -Completed
    }

    Write-Progress -Id $outerProgressId -Activity 'Uninstalling older versions' -Completed
}
