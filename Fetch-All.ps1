param
(
    [switch]$Personal = $true,
    [switch]$Corporate = $false,
    [switch]$GC = $false
)

$gitServiceFolders = New-Object System.Collections.ArrayList

if ($Personal.IsPresent) {
    $gitServiceFolders.Add("Bitbucket") | Out-Null
    $gitServiceFolders.Add("GitHub") | Out-Null
    $gitServiceFolders.Add("GitLab") | Out-Null
    $gitServiceFolders.Add("VSTS") | Out-Null
}

if ($Corporate.IsPresent) {
    $gitServiceFolders.Add("Chudovo") | Out-Null
}

$rootFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\..\.." -Resolve

$gitFolders = New-Object System.Collections.ArrayList

Function ScanDirectory($Folder, $RootScanFolder, $PercentComplete) {
    $FoundGitFolders = New-Object System.Collections.ArrayList

    Write-Progress -Id 1 -Activity "Detecting git folders" -Status "Scanning service folder $RootScanFolder" -CurrentOperation "Scanning $Folder" -PercentComplete $PercentComplete

    $gitFolder = Join-Path -Path $Folder -ChildPath '.git'
    if (Test-Path $gitFolder) {
        $FoundGitFolders.Add($Folder);
    }
    else {
        $childFolders = Get-ChildItem -Path $Folder -Directory

        foreach ($childFolder in $childFolders) {
            $childFoundGitFolders = ScanDirectory -Folder $childFolder.FullName -RootScanFolder $RootScanFolder -PercentComplete $PercentComplete

            if ($childFoundGitFolders -ne $null) {
                $FoundGitFolders.AddRange($childFoundGitFolders)
            }
        }
    }

    return $FoundGitFolders
}

function FetchGitRepository($Folder, $PercentComplete) {
    Write-Progress -Id 1 -Activity "Fetching git repository" -Status "Folder $Folder" -PercentComplete $PercentComplete
    Start-Process -FilePath 'C:\Program Files\Git\bin\git.exe' -ArgumentList 'fetch --all --prune' -WorkingDirectory $Folder -Wait -NoNewWindow
}

function GcGitRepository($Folder, $PercentComplete) {
    Write-Progress -Id 1 -Activity "Cleanup unnecessary files and optimize the local repository" -Status "Folder $Folder" -PercentComplete $PercentComplete
    Start-Process -FilePath 'C:\Program Files\Git\bin\git.exe' -ArgumentList 'gc' -WorkingDirectory $Folder -Wait -NoNewWindow
}

$processed = 0
foreach ($gitServiceFolder in $gitServiceFolders) {
    $processed = $processed + 1
    $folderToScan = Join-Path -Path $rootFolder -ChildPath $gitServiceFolder
    $scannedGitFolders = ScanDirectory -Folder (Get-Item $folderToScan) -RootScanFolder $folderToScan -FoundGitFolders $gitFolders -PercentComplete ($processed * 100 / $gitServiceFolders.Count)

    if ($scannedGitFolders -ne $null) {
        $gitFolders.AddRange($scannedGitFolders)
    }
}

$processed = 0
foreach ($gitFolder in $gitFolders) {
    $processed = $processed + 1

    Write-Host "Folder: $gitFolder"
    FetchGitRepository -Folder $gitFolder -PercentComplete ($processed * 100 / $gitFolders.Count)

    if ($GC.IsPresent) {
        GcGitRepository -Folder $gitFolder -PercentComplete ($processed * 100 / $gitFolders.Count)
    }
}

Write-Progress -Id 1 -Activity "Fetching git repository" -Completed
