Invoke-Expression (&starship init powershell)

Register-EditorCommand -Name IB1 -DisplayName 'Invoke task' -ScriptBlock {
    Invoke-TaskFromVSCode.ps1
}

Register-EditorCommand -Name IB2 -DisplayName 'Invoke task in console' -SuppressOutput -ScriptBlock {
    Invoke-TaskFromVSCode.ps1 -Console
}
