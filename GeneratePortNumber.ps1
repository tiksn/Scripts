$port = Get-Random -Minimum 49152 -Maximum 65535

Set-Clipboard -Value $port

Write-Output "Generated port number is $port. Port number copied to clipboard"
