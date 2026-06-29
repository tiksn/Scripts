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
                [Parameter(Mandatory, ValueFromRemainingArguments)]
                [object[]] $Path
            )

            Add-Type -AssemblyName Microsoft.VisualBasic
            foreach ($p in $Path) {
                foreach ($resolved in (Resolve-Path $p)) {
                    $full = $resolved.Path
                    if ($PSCmdlet.ShouldProcess($Path, ("Deleting '{0}'" -f $full))) {
                        if (Test-Path $full -PathType Container) {
                            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($full, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        }
                        else {
                            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($full, 'OnlyErrorDialogs', 'SendToRecycleBin')
                        }
                    }
                }
            }
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
