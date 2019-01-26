function prompt {
    $formattedDate = (Get-Date).ToString("f");
    $formattedDate = "[$(($formattedDate | Out-String).trim())]";
    $folderName = Split-Path $executionContext.SessionState.Path.CurrentLocation -Leaf
    Try
    {
        $repoStatus = Get-RepositoryStatus;
        $host.UI.RawUI.WindowTitle = "$($folderName) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count)";
        return "GIT $($executionContext.SessionState.Path.CurrentLocation) | $($repoStatus.CurrentBranch) $($repoStatus.Files.Count) $('>' * ($nestedPromptLevel + 1)) ";
    }
    Catch
    {
        $repoStatus = $null;
        $host.UI.RawUI.WindowTitle = "$($folderName)";
        return "PSC $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
    }
}
