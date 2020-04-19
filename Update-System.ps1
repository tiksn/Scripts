#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
Param ()
Write-Progress -Activity "Updating PowerShell Modules for All Users" -Id 1478576163
Update-Module -Scope AllUsers -AcceptLicense
Write-Progress -Activity "Updating PowerShell Modules for Current Users" -Id 1478576163
Update-Module -Scope CurrentUser -AcceptLicense
Write-Progress -Activity "Updating PowerShell Scripts" -Id 1478576163
Update-Script -AcceptLicense
Write-Progress -Activity "Updating PowerShell Help files" -Id 1478576163
Update-Help

if ($IsWindows) {
    Write-Progress -Activity "Updating Defender signatures" -Id 1478576163
    Update-MpSignature

    Write-Progress -Activity "Updating Chocolatey packages" -Id 1478576163
    if ($PSCmdlet.ShouldProcess("Chocolatey packages", "Update all packages")) {
        choco upgrade --confirm all
    }

    Write-Progress -Activity "Updating Scoop packages" -Id 1478576163
    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update all packages")) {
        scoop update
    }
    
    Write-Progress -Activity "Updating Windows" -Id 1478576163
    Get-WUServiceManager | ForEach-Object { Install-WindowsUpdate -ServiceID $_.ServiceID -AcceptAll }
}

if ($IsLinux) {
    $release = Get-Content -Path /etc/os-release
    $release = $release.Split([Environment]::NewLine) | Where-Object { $_.StartsWith("ID=") }
    $release = $release.Substring(3)

    $IsFedora = ($release -eq "Fedora")
    $IsDebian = ($release -eq "Debian")
    $IsUbuntu = ($release -eq "Ubuntu")

    if ($IsFedora) {
        dnf check-update
        dnf update

        flatpak update
    }

    if ($IsUbuntu -or $IsDebian) {
        apt update
        apt upgrade
    }
}

Write-Progress -Activity "Updating all .NET Core Global Tools" -Id 1478576163

foreach ($package in $(dotnet tool list --global | Select-Object -Skip 2)) {
    $tool = $package.Split(" ", 2)[0]
    if ($PSCmdlet.ShouldProcess("DotNet global tool $tool", "Update global tool")) {
        dotnet tool update --global $tool
    }
}

Write-Progress -Activity "The End." -Completed -Id 1478576163
