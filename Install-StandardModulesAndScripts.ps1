# Modules
Install-Module -Name ObjectiveGit -Force
Install-Module -Name PSLiteDB -Force
Install-Module -Name PSScriptAnalyzer -Force

if( $PSVersionTable.PSEdition -eq "Core") {
    # Modules

    # Scripts
} elseif($PSVersionTable.PSEdition -eq "Desktop") {
    # Modules
    Install-Module -Name Carbon -Force
    Install-Module -Name CredentialManager -Force
    Install-Module -Name GroceryChecklistToolkit -Force
    Install-Module -Name Microsoft.PowerShell.Archive -Force
    Install-Module -Name Microsoft.WindowsPassportUtilities.Commands -Force
    Install-Module -Name MlkPwgen -Force
    Install-Module -Name NTFSSecurity -Force
    Install-Module -Name Pscx -Force
    Install-Module -Name PSWindowsUpdate -Force
    Install-Module -Name PowerShellCookbook -Force
    Install-Module -Name PowerShellHumanizer -Force
    Install-Module -Name Pushalot -Force
    Install-Module -Name ResolveAlias -Force
    Install-Module -Name SeeShell -Force
    Install-Module -Name TIKSN-PowerShell-Cmdlets -Force
    Install-Module -Name WintellectPowerShell -Force

    # Scripts
    Install-Script -Name Update-PowerShell -Force
    Install-Script -Name Update-Windows -Force
}

