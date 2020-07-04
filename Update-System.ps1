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
    Set-Alias -Name 'PythonAlias' -Value 'py'

    Write-Progress -Activity "Updating Defender signatures" -Id 1478576163
    Update-MpSignature

    Write-Progress -Activity "Updating Chocolatey packages" -Id 1478576163
    if ($PSCmdlet.ShouldProcess("Chocolatey packages", "Update all packages")) {
        choco upgrade --confirm all
    }

    Write-Progress -Activity "Updating Scoop packages" -Id 1478576163
    if ($PSCmdlet.ShouldProcess("Scoop packages", "Update all packages")) {
        scoop update
        scoop update "*"
    }
    
    Write-Progress -Activity "Updating Windows" -Id 1478576163
    Get-WUServiceManager | ForEach-Object { Install-WindowsUpdate -ServiceID $_.ServiceID -AcceptAll }
}

if ($IsLinux) {
    Set-Alias -Name 'PythonAlias' -Value 'python3'

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

Write-Progress -Activity "Updating all Rust Cargo Crates" -Id 1478576163

$installList = cargo install --list
if ($?) {
    $packages = $installList | Where-Object { -not $_.StartsWith( ' ') } | ForEach-Object { ($_ -split ' ')[0] }

    foreach ($package in $packages) {
        if ($PSCmdlet.ShouldProcess("Rust Cargo Crate $package", "Update Rust Cargo Crate")) {
            Write-Progress -Activity "Updating Rust Cargo Crate $package" -Id 1478576163 -CurrentOperation "Installing Crate $package ..."
            cargo install $package
        }
    }
}

Write-Progress -Activity "Updating all Python PIP packages" -Id 1478576163

$installList = PythonAlias -m pip freeze
if ($?) {
    $packages = $installList | ForEach-Object { $_.split('==')[0] }
    foreach ($package in $packages) {
        if ($PSCmdlet.ShouldProcess("Python PIP package $package", "Update Python PIP package")) {
            Write-Progress -Activity "Updating Python PIP package $package" -Id 1478576163 -CurrentOperation "Installing Python PIP package $package ..."
            PythonAlias -m pip install --upgrade $package
        }
    }
}

Write-Progress -Activity "The End." -Completed -Id 1478576163
