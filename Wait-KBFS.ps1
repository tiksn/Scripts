[CmdletBinding()]
param (
)

while ($true) {
    try {
        $drive = keybase kbfsmount get
        $drivePath = Resolve-Path -Path $drive

        if (-not $drivePath) {
            throw 'KBFS drive path could not br resolved'
        }

        break
    }
    catch {
        Write-Warning -Message "Waiting for KBFS. Please start Keybase manually if it takes too long."
        Start-Sleep -Seconds 10
    }
}