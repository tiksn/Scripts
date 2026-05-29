[CmdletBinding(SupportsShouldProcess)]
param (
    [string] $ThemePath,

    [string] $ThemeName = 'powerlevel10k_rainbow.omp.json',

    [string] $DestinationPath = (Join-Path -Path $HOME -ChildPath 'theme.omp.json')
)

if (-not $ThemePath) {
    if ($env:POSH_THEMES_PATH) {
        $ThemePath = Join-Path -Path $env:POSH_THEMES_PATH -ChildPath $ThemeName
    }
    elseif ($IsMacOS -and (Get-Command -Name brew -ErrorAction SilentlyContinue)) {
        $ThemePath = Join-Path -Path "$(brew --prefix oh-my-posh)" -ChildPath "themes/$ThemeName"
    }
}

if (-not $ThemePath) {
    throw 'Could not resolve the oh-my-posh theme path. Set POSH_THEMES_PATH or pass -ThemePath.'
}

if (-not (Test-Path -LiteralPath $ThemePath)) {
    throw "Theme file not found: $ThemePath"
}

$destinationDirectory = Split-Path -Path $DestinationPath -Parent
if ($destinationDirectory -and -not (Test-Path -LiteralPath $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory -Force | Out-Null
}

$ompTheme = Get-Content -Raw -LiteralPath $ThemePath | ConvertFrom-Json -Depth 100
$timeSegments = $ompTheme.blocks | ForEach-Object { $_.segments } | Where-Object { $_.type -eq 'time' }
foreach ($timeSegment in $timeSegments) {
    if ($null -eq $timeSegment.PSObject.Properties.Item('properties')) {
        $timeSegment | Add-Member -MemberType NoteProperty -Name properties -Value @{
            time_format = '3:04 PM'
        }
    }
    elseif ($null -ne $timeSegment.properties.PSObject.Properties.Item('time_format')) {
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '15:04:05', '3:04:05 PM'
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '_2,15:04', '_2, 3:04 PM'
        $timeSegment.properties.time_format = $timeSegment.properties.time_format -replace '15:04', '3:04 PM'
    }
}

$ompTheme.console_title_template = '{{ .Folder }}'

if ($PSCmdlet.ShouldProcess($DestinationPath, 'Write customized oh-my-posh theme')) {
    $ompTheme | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $DestinationPath -Encoding utf8
    Get-Item -LiteralPath $DestinationPath
}
