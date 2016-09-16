cls
$gitServiceFolders = "Beanstalk", "Bitbucket", "GitBook", "GitHub", "GitLab", "VSTS"

ForEach($gitServiceFolder in $gitServiceFolders) {
    #FetchGitRepositories -folder $gitServiceFolder
    Write-Output $gitServiceFolder
    ScanDirectory -folder (Get-Item $gitServiceFolder)
}

Function ScanDirectory([System.IO.DirectoryInfo] $folder) {
    $oldFolder = Get-Location
    Set-Location $folder
    Write-Host Get-Location
    return
    if(Test-Path '.git') {
        $cd = Get-Location
        Set-Location $folder
        Set-Location $cd.Path
    } else {
        #ForEach($subfolder in (Get-ChildItem $folder)) {
            #ScanDirectory -folder $subfolder
        #}
    }

    Set-Location $oldFolder
}

function FetchGitRepositories($folder){
    Set-Location $folder
    Write-Output Get-Location

    ForEach($subfolder in Get-ChildItem -Path $folder) {
        FetchGitRepository -folder $subfolder
    }

    Set-Location ".."
    Write-Output Get-Location
}

function FetchGitRepository($folder){
}

function FetchDirectory(){
}
