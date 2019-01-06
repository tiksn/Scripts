function prompt {
    $formattedDate = (Get-Date).ToString("f");
    "PSC [$(($formattedDate | Out-String).trim())] $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
}