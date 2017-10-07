$gitServiceFolders = @("Bitbucket", "Chudovo", "GitHub", "GitLab", "VSTS")

$rootFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\..\.." -Resolve

$gitFolders = New-Object System.Collections.ArrayList

Function ScanDirectory($Folder, $RootScanFolder, $PercentComplete)
{
	$FoundGitFolders = New-Object System.Collections.ArrayList
	
	Write-Progress -Id 1 -Activity "Detecting git folders" -Status "Scanning service folder $RootScanFolder" -CurrentOperation "Scanning $Folder" -PercentComplete $PercentComplete
	
	$gitFolder = Join-Path -Path $Folder -ChildPath '.git'
	if (Test-Path $gitFolder)
	{
		$FoundGitFolders.Add($Folder)
	}
	else
	{
		$childFolders = Get-ChildItem -Path $Folder -Directory
		
		foreach ($childFolder in $childFolders)
		{
			$childFoundGitFolders = ScanDirectory -Folder $childFolder.FullName -RootScanFolder $RootScanFolder -PercentComplete $PercentComplete
			
			if ($childFoundGitFolders -ne $null)
			{
				$FoundGitFolders.AddRange($childFoundGitFolders)
			}
		}
	}
	
	return $FoundGitFolders
}

function FetchGitRepository($Folder, $PercentComplete)
{
	Write-Progress -Id 1 -Activity "Fetching git repository" -Status "Folder $Folder" -PercentComplete $PercentComplete
	Start-Process -FilePath 'C:\Program Files\Git\bin\git.exe' -ArgumentList 'pull -r -p' -WorkingDirectory $Folder -Wait
}

$processed = 0
foreach ($gitServiceFolder in $gitServiceFolders)
{
	$processed++
	$folderToScan = Join-Path -Path $rootFolder -ChildPath $gitServiceFolder
	$gitFolders += ScanDirectory -Folder (Get-Item $folderToScan) -RootScanFolder $folderToScan -FoundGitFolders $gitFolders -PercentComplete ($processed * 100 / $gitServiceFolders.Length)
}

$processed = 0
foreach ($gitFolder in $gitFolders)
{
	$processed++
	FetchGitRepository -Folder $gitFolder -PercentComplete ($processed * 100 / $gitFolders.Length)
}
