[CmdletBinding()]
param (
)

$allModules = Get-Module -ListAvailable
$moduleGroups = $allModules | Group-Object -Property Name
$multiversionModuleGroups = $moduleGroups | Where-Object { $_.Count -gt 1 }

for ($i = 0; $i -lt $multiversionModuleGroups.Count; $i++) {
    $multiversionModuleGroup = $multiversionModuleGroups[$i]
    $multiversionPID = Get-Random
    Write-Progress -Id $multiversionPID -Activity 'Uninstalling older versions' -Status $multiversionModuleGroup.Name -PercentComplete (($i + 1) * 100 / $multiversionModuleGroups.Count)
    $latestVersionModule = $multiversionModuleGroup.Group | Sort-Object -Descending -Property Version | Select-Object -First 1
    $olderModules = $multiversionModuleGroup.Group | Where-Object { $_.Version -lt $latestVersionModule.Version } | Sort-Object -Property Version
    for ($j = 0; $j -lt $olderModules.Count; $j++) {
        $olderModule = $olderModules[$j]
        Write-Verbose -Message "Uninstalling older version of $($olderModule.Name) $($olderModule.Version) (latest $($latestVersionModule.Version))"
        $versionPID = Get-Random
        Write-Progress -Id $versionPID -ParentId $multiversionPID -Activity 'Uninstalling older version' -Status "$($olderModule.Version) (latest $($latestVersionModule.Version))" -PercentComplete (($j + 1) * 100 / $olderModules.Count)
        Uninstall-Module -Name $olderModule.Name -RequiredVersion $olderModule.Version
        Write-Progress -Id $versionPID -Activity 'Uninstalling older version' -Completed
    }
    Write-Progress -Id $multiversionPID -Activity 'Uninstalling older versions' -Completed
}
