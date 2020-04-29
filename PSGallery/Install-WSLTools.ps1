
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


$distributions = wsl --list | Where-Object { $_ -ne $null -and $_ -ne "" } | Select-Object -Skip 1 | ForEach-Object { ($_ -split " ")[0] }

# https://github.com/wslutilities/wslu

$commands = @{
    "Ubuntu" = @{
        InstallWsluCommands = @(
            "sudo apt update",
            "sudo apt install ubuntu-wsl"
        )
    }
    "Debian" = @{
        InstallWsluCommands = @(
            "sudo apt install gnupg2 apt-transport-https",
            "wget -O - https://access.patrickwu.space/wslu/public.asc | sudo apt-key add -",
            "echo `"deb https://access.patrickwu.space/wslu/debian buster main`" | sudo tee -a /etc/apt/sources.list",
            "sudo apt update",
            "sudo apt install wslu"
        )
    }
}

foreach ($distribution in $distributions) {
    $distributionCommands = $commands[$distribution]

    foreach ($installWsluCommand in $distributionCommands.InstallWsluCommands) {
        Write-Verbose "$distribution`: $installWsluCommand"
        wsl --exec $installWsluCommand --distribution $distribution
    }

    wsl --exec "wslfetch" --distribution $distribution
}
