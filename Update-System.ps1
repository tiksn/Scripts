#Requires -RunAsAdministrator

Update-Module -Scope AllUsers
Update-Script

if ($IsWindows) {

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


