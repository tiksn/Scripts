
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
foreach ($distribution in $distributions) {
    switch ($distribution) {
        "Ubuntu" {
            wsl --exec "sudo apt update" --distribution $distribution
            wsl --exec "sudo apt install ubuntu-wsl" --distribution $distribution
        }
        "Debian" { 
            wsl --exec "sudo apt install gnupg2 apt-transport-https" --distribution $distribution
            wsl --exec "wget -O - https://access.patrickwu.space/wslu/public.asc | sudo apt-key add -" --distribution $distribution
            wsl --exec "echo `"deb https://access.patrickwu.space/wslu/debian buster main`" | sudo tee -a /etc/apt/sources.list" --distribution $distribution
            wsl --exec "sudo apt update" --distribution $distribution
            wsl --exec "sudo apt install wslu" --distribution $distribution 
        }
        Default { Write-Error "$distribution is not supported" }
    }
}

# wslfetch
foreach ($distribution in $distributions) {
    switch ($distribution) {
        "Ubuntu" {
            wsl --exec "wslfetch" --distribution $distribution
        }
        "Debian" { 
            wsl --exec "wslfetch" --distribution $distribution
        }
        Default { Write-Error "$distribution is not supported" }
    }
}
