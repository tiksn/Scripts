Import-Module ObjectiveGit
Import-Module posh-git

function prompt {
    $formattedDate = (Get-Date).ToString("f");
    $formattedDate = "[$(($formattedDate | Out-String).trim())]";
    Try
    {
        $repoStatus = Get-RepositoryStatus;
        # return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)`n$('>' * ($nestedPromptLevel + 1)) ";
        return "GIT $($executionContext.SessionState.Path.CurrentLocation) $(Write-VcsStatus)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch
    {
        $repoStatus = $null;
        return "PSC $($executionContext.SessionState.Path.CurrentLocation)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
}


$PowerShellTranscriptsPath = Join-Path -Path $env:userprofile -ChildPath "PowerShellTranscripts"

if (-not (Test-Path -Path $PowerShellTranscriptsPath)) {
    New-Item -Path $PowerShellTranscriptsPath -ItemType Directory
}

$TranscriptDate = Get-Date -Format "yyyy-MM-dd--hh-mm-ss"

$TranscriptFilePath = Join-Path -Path $PowerShellTranscriptsPath -ChildPath "$TranscriptDate.txt"

Start-Transcript -Path $TranscriptFilePath -Append
