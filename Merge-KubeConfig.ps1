[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $Source,
    [Parameter(Mandatory = $true)]
    [string]
    $Target
)

# Import-Module -Name PSKubectl
Import-Module -Name powershell-yaml
$sourceContent = Get-Content -Path $Source -Raw
$targetContent = Get-Content -Path $Target -Raw

$sourceYaml = ConvertFrom-Yaml -Yaml $sourceContent -Ordered
$targetYaml = ConvertFrom-Yaml -Yaml $targetContent -Ordered

# $sourceYaml['clusters']
# $sourceYaml['contexts']
# $sourceYaml['current-context']
# $sourceYaml['kind']
# $sourceYaml['preferences']
# $sourceYaml['users']

if ( $sourceYaml['kind'] -ne 'Config') {
    throw 'Source is not kubectl config file'
}

if ( $targetYaml['kind'] -ne 'Config') {
    throw 'Target is not kubectl config file'
}

if ($sourceYaml['apiVersion'] -ne $targetYaml['apiVersion']) {
    throw 'API Version is not the same'
}

foreach ($sourceUser in $sourceYaml['users']) {
    $targetUser = $targetYaml['users'] | Where-Object { $_['name'] -eq $sourceUser['name'] }

    if ($null -eq $targetUser) {
        $targetYaml['users'] += $sourceUser
    }
    else {
        $targetUser['user'] = $sourceUser['user']
    }
}

$targetContent = ConvertTo-Yaml -Data $targetYaml
Set-Content -Path $Target -Value $targetContent
