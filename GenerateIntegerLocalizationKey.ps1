$key = Get-Random -Minimum 100000000 -Maximum 1000000000

Set-Clipboard -Value $key

Write-Output "Generated key is $key. Key copied to clipboard"
