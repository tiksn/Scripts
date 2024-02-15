if ($IsWindows) {
    Import-Module -Name Recycle
}
elseif ($IsLinux) {
    Set-Alias -Name 'Remove-ItemSafely' -Value 'trash' -Option Private -Scope Private
}
elseif ($IsMacOS) {
    Set-Alias -Name 'Remove-ItemSafely' -Value 'trash' -Option Private -Scope Private
}

$PowerShellTranscriptsPath = Join-Path -Path $HOME -ChildPath "PowerShellTranscripts"

$TranscriptFilePaths = Get-ChildItem $PowerShellTranscriptsPath -File

$TranscriptAgeThreshold = New-TimeSpan -Hours (7 * 24)

foreach ($TranscriptFilePath in $TranscriptFilePaths) {
    $parts = $TranscriptFilePath.BaseName -split '--'
    $dateParts = $parts[0] -split '-'
    $timeParts = $parts[1] -split '-'
    $TranscriptDate = Get-Date -Year $dateParts[0] -Month $dateParts[1] -Day $dateParts[2] -Hour $timeParts[0] -Minute $timeParts[1] -Second $timeParts[2]
    $TranscriptAge = New-TimeSpan -Start $TranscriptDate -End (Get-Date)
    if ($TranscriptAge -gt $TranscriptAgeThreshold) {
        Write-Host "Removing $TranscriptFilePath"
        Remove-ItemSafely $TranscriptFilePath
    }
}