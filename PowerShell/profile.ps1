if ($IsWindows) {
    Import-Module -Name Recycle

    Set-Alias -Name trash -Value Remove-ItemSafely    
}
elseif ($IsMacOS) {
    $env:PATH = "$env:PATH`:~/.local/share/powershell/Scripts"
}
elseif ($IsLinux) {
    Get-Command -Name trash | Out-Null

    $env:PATH = "$env:PATH`:~/.local/share/powershell/Scripts"
}

function quit() {
    [CmdletBinding()]
    param (
    )

    $jobs = @(Get-Job | Where-Object { ($_.State -ne 'Completed') -and ($_.State -ne 'Disconnected') -and ($_.State -ne 'Failed') -and ($_.State -ne 'Stopped') }).Count
    if ($jobs -gt 0) {
        throw 'Not all jobs are finished'
    }

    exit
}
