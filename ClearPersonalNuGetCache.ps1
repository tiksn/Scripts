$UserFolder = [Environment]::GetFolderPath('UserProfile')

$NuGetPackagesFolder = Join-Path -Path $UserFolder -ChildPath ".nuget\packages"

$PackagePaths = @()

$PackagePaths += Join-Path -Path $NuGetPackagesFolder -ChildPath "tiksn-framework"
$PackagePaths += Join-Path -Path $NuGetPackagesFolder -ChildPath "tiksn-cake"
$PackagePaths += Join-Path -Path $NuGetPackagesFolder -ChildPath "tiksn-habitica"
$PackagePaths += Join-Path -Path $NuGetPackagesFolder -ChildPath "ROFSDB"
$PackagePaths += Join-Path -Path $NuGetPackagesFolder -ChildPath "smite-cli"

foreach($PackagePath in $PackagePaths) {
    if (Test-Path -Path $PackagePath) {
        Write-Host "Deleting $PackagePath"
        Remove-Item -Path $PackagePath -Force -Recurse
    }
}
