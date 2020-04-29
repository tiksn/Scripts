
<#PSScriptInfo

.VERSION 1.0

.GUID a954848e-a6f7-4386-b084-bbd9f5862fb8

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME

.COPYRIGHT

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

<# 

.DESCRIPTION 
 Inatall WSL Utilities and other tools 

#>

[CmdletBinding()]
Param()


$distributions = wsl --list
| Where-Object { $_ -ne $null -and $_ -ne "" }
| Select-Object -Skip 1
| ForEach-Object { ($_ -split " ")[0].Trim() }
| ForEach-Object { $_.TrimEnd("`0`r`n") }
| ForEach-Object { $_.Replace("`0", "") }

# https://github.com/wslutilities/wslu

$WslCommands = @{
    "Ubuntu" = @{
        InstallWsluCommands       = @(
            "sudo apt update",
            "sudo apt install ubuntu-wsl"
        )
        PowerShellInstallCommands = @(
            "sudo apt-get update",
            "sudo apt-get install -y curl apt-transport-https",
            "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -",
            "sudo sh -c 'echo `"deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main`" > /etc/apt/sources.list.d/microsoft.list'",
            "sudo apt-get update",
            "sudo apt-get install -y powershell",
            "pwsh --version"
        )
    }
    "Debian" = @{
        InstallWsluCommands       = @(
            "sudo apt install gnupg2 apt-transport-https",
            "wget -O - https://access.patrickwu.space/wslu/public.asc | sudo apt-key add -",
            "echo `"deb https://access.patrickwu.space/wslu/debian buster main`" | sudo tee -a /etc/apt/sources.list",
            "sudo apt update",
            "sudo apt install wslu"
        )
        PowerShellInstallCommands = @(
            "wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb",
            "sudo dpkg -i packages-microsoft-prod.deb",
            "sudo apt-get update",
            "sudo apt-get install -y powershell",
            "pwsh --version"
        )
    }
}

foreach ($distribution in $distributions) {
    Write-Verbose "$distribution"
    $distributionCommands = $WslCommands[$distribution]

    foreach ($command in $distributionCommands.InstallWsluCommands) {
        Write-Verbose "$distribution`: WSLU: $command"
        wsl --distribution $distribution bash -c $command
    }

    foreach ($command in $distributionCommands.PowerShellInstallCommands) {
        Write-Verbose "$distribution`: PWSH: $command"
        wsl --distribution $distribution bash -c $command
    }

    wsl --distribution $distribution bash -c "python3 -m pip install wslpy"
    wsl --distribution $distribution wslfetch
}
