
<#PSScriptInfo

.VERSION 1.1.2

.GUID 3aedfc83-f65b-4724-b810-9d849563645d

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT TIKSN Lab

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

#Requires -Module PSWindowsUpdate



<# 

.DESCRIPTION 
 Update whole System

#> 

#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
Param ()
Write-Progress -Activity 'Updating PowerShell Modules for Current Users' -Id 1478576163
Update-Module -Scope CurrentUser -AcceptLicense
Write-Progress -Activity 'Updating PowerShell Modules for All Users' -Id 1478576163
Update-Module -Scope AllUsers -AcceptLicense
Write-Progress -Activity 'Updating PowerShell Scripts' -Id 1478576163
Update-Script -AcceptLicense
Write-Progress -Activity 'Updating PowerShell Help files' -Id 1478576163
Update-Help

if ($IsWindows) {
    Import-Module -Name PSWindowsUpdate

    Set-Alias -Name 'PythonAlias' -Value 'py'

    Write-Progress -Activity 'Updating Defender signatures' -Id 1478576163
    Update-MpSignature

    Write-Progress -Activity 'Updating Windows Package Manager all sources' -Id 1478576163
    winget source update

    Write-Progress -Activity 'Updating Windows Package Manager all sources' -Id 1478576163
    winget upgrade --all

    Write-Progress -Activity 'Updating Chocolatey packages' -Id 1478576163
    if ($PSCmdlet.ShouldProcess('Chocolatey packages', 'Update all packages')) {
        choco upgrade --confirm all
    }

    Write-Progress -Activity 'Updating Scoop packages' -Id 1478576163
    if ($PSCmdlet.ShouldProcess('Scoop packages', 'Update all packages')) {
        scoop update
        scoop update '*'
    }
    
    Write-Progress -Activity 'Updating Windows' -Id 1478576163
    Get-WUServiceManager | ForEach-Object { Install-WindowsUpdate -ServiceID $_.ServiceID -AcceptAll }
}

if ($IsMacOS) {
    Write-Progress -Activity 'Updating Homebrew packages' -Id 1478576163
    brew upgrade --cask
}

if ($IsLinux) {
    Set-Alias -Name 'PythonAlias' -Value 'python3'

    $release = Get-Content -Path /etc/os-release
    $release = $release.Split([Environment]::NewLine) | Where-Object { $_.StartsWith('ID=') }
    $release = $release.Substring(3)

    $IsFedora = ($release -eq 'Fedora')
    $IsDebian = ($release -eq 'Debian')
    $IsUbuntu = ($release -eq 'Ubuntu')

    if ($IsFedora) {
        dnf check-update
        dnf update --assumeyes --best --allowerasing

        flatpak update --assumeyes
    }

    if ($IsUbuntu -or $IsDebian) {
        apt update
        apt upgrade
    }

    if (Get-Command -Name brew -ErrorAction SilentlyContinue) {
        Write-Progress -Activity 'Updating Homebrew packages' -Id 1478576163
        brew upgrade --cask
    }
}

Write-Progress -Activity 'Updating all .NET Core Global Tools' -Id 1478576163

dotnet tool list --global | Out-Null

foreach ($package in $(dotnet tool list --global | Select-Object -Skip 2)) {
    $parts = $package.Split(' ', 2)
    $tool = $parts[0]
    $parts = $parts[1].TrimStart().Split(' ', 2)
    $installedVersion = $parts[0]

    Write-Progress -Activity 'Updating all .NET Core Global Tools' -Status "Checking updates for $tool" -Id 1478576163

    foreach ($searchResult in $(dotnet tool search $tool | Select-Object -Skip 2)) {
        $parts = $searchResult.Split(' ', 2)
        $resultTool = $parts[0]
        $parts = $parts[1].TrimStart().Split(' ', 2)
        $resultVersion = $parts[0]

        if ($tool -eq $resultTool) {
            if ($installedVersion -ne $resultVersion) {
                if ($PSCmdlet.ShouldProcess("DotNet global tool $tool", 'Update global tool')) {
                    dotnet tool update --global $tool
                }
            }
        }
    }
}

Write-Progress -Activity 'Update .NET Workloads' -Id 1478576163
dotnet workload update
Write-Progress -Activity 'Checking for .NET template updates' -Id 1478576163
dotnet new --update-check
Write-Progress -Activity 'Applying .NET template updates' -Id 1478576163
dotnet new --update-apply

Write-Progress -Activity 'Updating NPM Global Packages' -Id 1478576163
if ($PSCmdlet.ShouldProcess('NPM Global Packages', 'Update all packages')) {
    npm update --global
}

Write-Progress -Activity 'Updating all Rust Cargo Crates' -Id 1478576163
$installList = cargo install --list
if ($?) {
    $packages = $installList | Where-Object { -not $_.StartsWith( ' ') } | ForEach-Object { ($_ -split ' ')[0] }

    foreach ($package in $packages) {
        if ($PSCmdlet.ShouldProcess("Rust Cargo Crate $package", 'Update Rust Cargo Crate')) {
            Write-Progress -Activity "Updating Rust Cargo Crate $package" -Id 1478576163 -CurrentOperation "Installing Crate $package ..."
            cargo install $package
        }
    }
}

Write-Progress -Activity 'Updating all Python PIP packages' -Id 1478576163

$installList = PythonAlias -m pip freeze
if ($?) {
    if ($PSCmdlet.ShouldProcess('Python PIP', 'Update')) {
        Write-Progress -Activity 'Updating Python PIP' -Id 1478576163 -CurrentOperation 'Update Python PIP ...'
        PythonAlias -m pip install --upgrade pip
    }

    $packages = $installList | ForEach-Object { $_.split('==')[0] }
    foreach ($package in $packages) {
        if ($PSCmdlet.ShouldProcess("Python PIP package $package", 'Update Python PIP package')) {
            Write-Progress -Activity "Updating Python PIP package $package" -Id 1478576163 -CurrentOperation "Installing Python PIP package $package ..."
            PythonAlias -m pip install --upgrade $package
        }
    }
}

Write-Progress -Activity 'The End.' -Completed -Id 1478576163
