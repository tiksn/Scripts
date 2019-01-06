function prompt {
    $formattedDate = (Get-Date).ToString("f");
    Try
    {
        $repoStatus = Get-RepositoryStatus;
        return "GIT [$(($formattedDate | Out-String).trim())] $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count) $('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch
    {
        $repoStatus = $null;
        return "PSC [$(($formattedDate | Out-String).trim())] $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
    }
}