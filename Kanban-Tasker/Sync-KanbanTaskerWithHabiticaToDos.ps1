[CmdletBinding()]
param()

Import-Module -Name Habitica
Import-Module -Name SQLiteModule

$ktPackage = Get-AppPackage -Name 17325HunterJohnson.KanbanTasker
$packagesPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Packages'
$ktPackageDateFolder = Join-Path -Path $packagesPath -ChildPath $ktPackage.PackageFamilyName
$ktLocalState = Join-Path -Path $ktPackageDateFolder -ChildPath "LocalState"
$ktdatabase = Join-Path -Path $ktLocalState -ChildPath "ktdatabase.db"

$habiticaBoard = Invoke-SQLiteQuery -Database $ktdatabase -Query "SELECT Id, Name, Notes FROM `"main`".`"tblBoards`" WHERE Name = 'Habitica'"

if ($null -eq $habiticaBoard) {
    throw 'Habitica board is not found'
}

$habiticaBoardId = $habiticaBoard[0]

Write-Verbose "Habitica board Id $habiticaBoardId"
Write-Verbose "Habitica board Name $($habiticaBoard[1])"
Write-Verbose "Habitica board Notes $($habiticaBoard[2])"

$habiticaCredentialsFilePath = Join-Path -Path $HOME -ChildPath "HabiticaCredentials"
Connect-Habitica -Path $habiticaCredentialsFilePath
$todos = Get-HabiticaTask -Type todos

foreach ($todo in $todos) {
    $description = $todo.description ?? ""

    if ($todo.checklist) {
        $description += [System.Environment]::NewLine

        foreach ($subTask in $todo.checklist) {
            $description += [System.Environment]::NewLine
            if ($subTask.completed) {
                $description += "✔"
            }
            else {
                $description += "❌"
            }
            $description += " "
            $description += $subTask.text
        }
    }
    
    $sqlParameters = @{
        BoardID = $habiticaBoardId
        Title   = $todo.text
    }
    $todoInDb = Invoke-SQLiteQuery -Database $ktdatabase -Query "SELECT Id, BoardID, DateCreated, Title, Description, Category, ColumnIndex, ColorKey, Tags, DueDate, FinishDate, TimeDue, ReminderTime, StartDate FROM `"main`".`"tblTasks`" WHERE BoardID = @BoardID AND Title = @Title" -SqlParameters $sqlParameters
    $todoInDb = $todoInDb[2]
    if ($null -eq $todoInDb ) {
        Write-Verbose "Create To-Do for $($todo.text)"

        $sqlParameters = @{
            BoardID      = $habiticaBoardId
            DateCreated  = $todo.createdAt.ToString()
            Title        = $todo.text
            Description  = $description
            Category     = "Backlog"
            ColumnIndex  = '0'
            ColorKey     = "Normal"
            Tags         = ""
            DueDate      = ""
            FinishDate   = ""
            TimeDue      = ""
            ReminderTime = "None"
            StartDate    = ""
        }

        Invoke-SQLiteQuery -Database $ktdatabase -Query "INSERT INTO `"main`".`"tblTasks`"(`"Id`",`"BoardID`",`"DateCreated`",`"Title`",`"Description`",`"Category`",`"ColumnIndex`",`"ColorKey`",`"Tags`",`"DueDate`",`"FinishDate`",`"TimeDue`",`"ReminderTime`",`"StartDate`") VALUES (NULL, @BoardID, @DateCreated, @Title, @Description, @Category, @ColumnIndex, @ColorKey, @Tags, @DueDate, @FinishDate, @TimeDue, @ReminderTime, @StartDate );" -SqlParameters $sqlParameters | Out-Null
    }
    else {
        Write-Verbose "Update To-Do description for $($todo.text)"

        $taskID = $todoInDb[0]
        $sqlParameters = @{
            Id          = $taskID
            Description = $description
        }

        Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"Description`"=@Description WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null
    }
}