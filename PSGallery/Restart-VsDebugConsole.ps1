[CmdletBinding()]
param(

)

function KillProcessTree {
    Param(
        [int]$ProcessId
    )
    Get-CimInstance Win32_Process | Where-Object { $_.ParentProcessId -eq $ProcessId } | ForEach-Object { KillProcessTree $_.ProcessId }
    Stop-Process -Id $ProcessId
}

function CheckProcessAncestor {
    param (
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process]
        $Process,
        [Parameter(Mandatory = $true)]
        [string]
        $AncestorName
    )
    
    if ($null -eq $Process.Parent) {
        return $false
    }

    if ($AncestorName -eq $Process.Parent.Name) {
        return $true
    }

    return CheckProcessAncestor -Process $Process.Parent -AncestorName $AncestorName
}

$Processes = Get-Process

$vsDebugConsoleProcesses = $Processes | Where-Object { $_.Name -eq 'VsDebugConsole' }
$vsDebugConsoleProcess = $vsDebugConsoleProcesses | Where-Object { (CheckProcessAncestor -Process $_ -AncestorName 'devenv') -and (-not (CheckProcessAncestor -Process $_ -AncestorName 'WindowsTerminal')) }

if ($null -ne $vsDebugConsoleProcess) {
    Write-Debug "ID: $($vsDebugConsoleProcess.Id), Name: $($vsDebugConsoleProcess.Name)"
    $winProcesses = Get-CimInstance Win32_Process
    $vsDebugConsoleWinProcess = $winProcesses | Where-Object { $_.ProcessId -eq $vsDebugConsoleProcess.Id }
    $vsDebugConsoleProcess | Stop-Process
    KillProcessTree $vsDebugConsoleProcess.Id
    # if ($?) {
    #     Start-Process $vsDebugConsoleWinProcess.CommandLine
    # }
}
