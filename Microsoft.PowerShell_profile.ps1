function prompt {
    "[$((Get-Date | Out-String).trim())] PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
}