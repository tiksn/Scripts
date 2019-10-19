#Requires -RunAsAdministrator

[CmdletBinding()]
Param ()

Update-Module -Scope AllUsers -AcceptLicense -Confirm:$false
Update-Script -AcceptLicense -Confirm:$false
Update-Help -Confirm:$false

if ($IsWindows) {
    Update-MpSignature

    choco upgrade all
}

if ($IsLinux) {
    $release = Get-Content -Path /etc/os-release
    $release = $release.Split([Environment]::NewLine) | Where-Object { $_.StartsWith("ID=") }
    $release = $release.Substring(3)

    $IsFedora = ($release -eq "Fedora")
    $IsUbuntu = ($release -eq "Ubuntu")

    if ($IsFedora) {
        dnf check-update
        dnf update

        flatpak update
    }
}

Write-Verbose 'Updating all .NET Core Global Tools'

foreach ($package in $(dotnet tool list --global | Select-Object -Skip 2)) {
    dotnet tool update --global $($package.Split(" ", 2)[0])
}

