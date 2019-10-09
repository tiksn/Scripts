#Requires -RunAsAdministrator

Update-Module -Scope AllUsers -AcceptLicense -Confirm:$false
Update-Script -AcceptLicense -Confirm:$false
Update-Help -Confirm:$false

if ($IsWindows) {
    choco upgrade all

    Import-Module -Name PSWindowsUpdate
    Get-WUServiceManager | ForEach-Object { 
        Install-WindowsUpdate -ServiceID $_.ServiceID -AcceptAll:$AcceptAll -Verbose:$Verbose
    }
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


