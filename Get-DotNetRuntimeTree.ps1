[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]
    $RID,
    [Parameter()]
    [switch]
    $Reverse
)

Import-Module powershell-yaml

$response = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/dotnet/runtime/main/src/libraries/Microsoft.NETCore.Platforms/src/runtime.json'
$runtimes = $response.runtimes

function GetRuntimeTree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $RID,
        [Parameter()]
        [switch]
        $Reverse
    )

    begin {

    }

    process {
        $runtime = $runtimes.$RID

        if ($Reverse) {
            foreach ($currentRuntimePair in $runtimes.PSObject.Properties) {
                $currentRuntime = $currentRuntimePair.Name
                foreach ($import in $currentRuntimePair.Value.'#import') {
                    if ($RID -eq $import) {
                        [PSCustomObject]@{
                            RID     = $currentRuntime
                            Imports = $currentRuntimePair.Value.'#import'
                        }
                    }
                }
            }
        }
        else {
            $imports = @()
            foreach ($import in $runtime.'#import') {
                $imports += GetRuntimeTree -RID $import
            }
            # @{$RID = $subrids }
            [PSCustomObject]@{
                RID     = $RID
                Imports = $imports
            }
        }
    }

    end {

    }
}

$tree = @()
$tree += GetRuntimeTree -RID $RID -Reverse:$Reverse
# $tree | Format-Custom -Depth 1000

$tree | ConvertTo-Yaml