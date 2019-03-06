function prompt {
    $formattedDate = (Get-Date).ToString("f");
    $formattedDate = "[$(($formattedDate | Out-String).trim())]";
    Try
    {
        $repoStatus = Get-RepositoryStatus;
        return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch
    {
        $repoStatus = $null;
        return "PSC $($executionContext.SessionState.Path.CurrentLocation)`n$('>' * ($nestedPromptLevel + 1)) ";
    }
}
