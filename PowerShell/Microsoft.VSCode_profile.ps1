function Invoke-CachedProfileScript {
    param (
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [scriptblock] $Generator,

        [TimeSpan] $MaxAge = [TimeSpan]::FromDays(30)
    )

    $cacheRoot = if ($env:LOCALAPPDATA) {
        Join-Path -Path $env:LOCALAPPDATA -ChildPath 'PowerShell\ProfileCache'
    }
    else {
        Join-Path -Path $HOME -ChildPath '.cache/powershell/profile'
    }

    $cachePath = Join-Path -Path $cacheRoot -ChildPath "$Name.ps1"
    $cacheItem = Get-Item -LiteralPath $cachePath -ErrorAction SilentlyContinue
    if ($null -eq $cacheItem -or ((Get-Date) - $cacheItem.LastWriteTime) -gt $MaxAge) {
        New-Item -Path $cacheRoot -ItemType Directory -Force | Out-Null
        $script = try {
            & $Generator 2>$null | Out-String
        }
        catch {
            $null
        }

        if (-not [string]::IsNullOrWhiteSpace($script)) {
            Set-Content -LiteralPath $cachePath -Value $script -Encoding utf8
        }
    }

    if (Test-Path -LiteralPath $cachePath) {
        . $cachePath
    }
}

if (Get-Command -Name starship -ErrorAction SilentlyContinue) {
    Invoke-CachedProfileScript -Name starship-init -Generator { starship init powershell }
}

if (Get-Command -Name Register-EditorCommand -ErrorAction SilentlyContinue) {
    Register-EditorCommand -Name IB1 -DisplayName 'Invoke task' -ScriptBlock {
        Invoke-TaskFromVSCode.ps1
    }

    Register-EditorCommand -Name IB2 -DisplayName 'Invoke task in console' -SuppressOutput -ScriptBlock {
        Invoke-TaskFromVSCode.ps1 -Console
    }
}
