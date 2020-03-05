[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]
    $RID
)

Import-Module powershell-yaml

$response = Invoke-RestMethod -Uri "https://raw.githubusercontent.com/dotnet/runtime/master/src/libraries/pkg/Microsoft.NETCore.Platforms/runtime.json"
$runtimes = $response.runtimes

function GetRuntimeTree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $RID
    )
    
    begin {
        
    }
    
    process {
        $runtime = $runtimes.$RID
        $imports = @()
        foreach ($import in $runtime.'#import') {
            $imports += GetRuntimeTree -RID $import
        }
        # @{$RID = $subrids }
        [PSCustomObject]@{
            RID = $RID
            Imports = $imports
        }
    }
    
    end {
        
    }
}

$tree = @()
$tree += GetRuntimeTree -RID $RID
# $tree | Format-Custom -Depth 1000

$tree | ConvertTo-Yaml