$script:IsInteractiveSession = (
    $Host.Name -ne 'ServerRemoteHost' -and
    -not [System.Console]::IsInputRedirected -and
    -not [System.Console]::IsOutputRedirected
)

if ($script:IsInteractiveSession) {
    if ($IsWindows) {
        function trash {
            [CmdletBinding(SupportsShouldProcess)]
            param (
                [Parameter(ValueFromRemainingArguments)]
                [object[]] $Path
            )

            Import-Module -Name Recycle -ErrorAction Stop
            Remove-ItemSafely @Path
        }
    }
    elseif ($IsMacOS -or $IsLinux) {
        $env:PATH = "$env:PATH`:$HOME/.local/share/powershell/Scripts"
    }
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
