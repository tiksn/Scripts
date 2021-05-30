[CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact = 'High'
)]
param (
)


function Set-RegValue {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High'
    )]
    param (
        [Parameter()]
        [string]
        $Key,
        [Parameter()]
        [string]
        $ValueName,
        [Parameter()]
        [object]
        $Value
    )

    $currentValue = Get-ItemProperty -Path $Key -Name $ValueName | Select-Object -ExpandProperty $ValueName

    if ($currentValue) {
        Write-Host "Current Value for ($Key):($ValueName) is $currentValue"
    }

    $target = "($Key):($ValueName)"
    if ($PSCmdlet.ShouldProcess($target, 'Set Value')) {
        Set-ItemProperty -Path $Key -Name $ValueName -Value $Value
    }
}

Set-RegValue -Key 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' -ValueName 'PeopleBand' -Value 0

Stop-Process -Name explorer
Start-Process -Name explorer
