$port = Get-Random -Minimum 49152 -Maximum 65535

Set-Clipboard -Value $key

Write-Output "Generated port number is $port. Port number copied to clipboard"
