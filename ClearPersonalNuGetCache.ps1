$UserFolder = [Environment]::GetFolderPath('UserProfile')

$NuGetPackagesFolder = Join-Path -Path $UserFolder -ChildPath '.nuget\packages'

if (Test-Path -Path $NuGetPackagesFolder) {
    $NuGetPackagesFolders = Get-ChildItem -Path $NuGetPackagesFolder
    $NuSpecPaths = foreach ($NuGetPackageFolder in $NuGetPackagesFolders) {
        if (Test-Path -Path $NuGetPackageFolder) {
            $NuGetPackageVersionFolders = Get-ChildItem -Path $NuGetPackageFolder
            foreach ($NuGetPackageVersionFolder in $NuGetPackageVersionFolders) {
                if (Test-Path -Path $NuGetPackageVersionFolder) {
                    $nuspecFiles = Get-ChildItem -Path $NuGetPackageVersionFolder -Filter *.nuspec
                    $nuspecFiles
                }
            }
        }
    }

    $MyPackageIds = $NuSpecPaths | ForEach-Object {
        [xml]$xml = Get-Content -Path $PSItem
        $packageElement = $xml.DocumentElement | Where-Object { $PSItem.Name -eq 'package' }
        $metadataElement = $packageElement.ChildNodes | Where-Object { $PSItem.Name -eq 'metadata' }
        $idElement = $metadataElement.ChildNodes | Where-Object { $PSItem.Name -eq 'id' }
        $authorsElement = $metadataElement.ChildNodes | Where-Object { $PSItem.Name -eq 'authors' }
        if (('TIKSN' -eq $authorsElement.InnerText) -or ('Tigran TIKSN Torosyan' -eq $authorsElement.InnerText) -or ($authorsElement.InnerText -like 'TIKSN.*')) {
            $idElement.InnerText
        }
    }
    | Select-Object -Unique

    foreach ($MyPackageId in $MyPackageIds) {
        $PackagePath = Join-Path -Path $NuGetPackagesFolder -ChildPath $MyPackageId
        if (Test-Path -Path $PackagePath) {
            Write-Host "Deleting $PackagePath"
            Remove-Item -Path $PackagePath -Force -Recurse
        }
    }
}