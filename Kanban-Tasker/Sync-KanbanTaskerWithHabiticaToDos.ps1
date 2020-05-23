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
$completedTodos = Get-HabiticaTask -Type completedTodos

$allTodos = $todos + $completedTodos

foreach ($todo in $allTodos) {
    $description = $todo.description ?? ""
    $dueDate = ""
    $timeDue = ""
    $reminderTime = "None"

    if (($null -ne $todo.date) -and ("" -ne $todo.date)) {
        $dueDate = $todo.date.ToString("yyyy.MM.dd")
        $timeDue = $todo.date.ToString("hh.mm.ss")
        $reminderTime = "At Time of Due Date"
    }

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
    
    if ($todo.completed) {
        $category = "Completed"
    }
    else {
        $category = "Backlog"
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
            Category     = $category
            ColumnIndex  = '0'
            ColorKey     = "Normal"
            Tags         = ""
            DueDate      = $dueDate
            FinishDate   = ""
            TimeDue      = $timeDue
            ReminderTime = $reminderTime
            StartDate    = ""
        }

        Invoke-SQLiteQuery -Database $ktdatabase -Query "INSERT INTO `"main`".`"tblTasks`"(`"Id`",`"BoardID`",`"DateCreated`",`"Title`",`"Description`",`"Category`",`"ColumnIndex`",`"ColorKey`",`"Tags`",`"DueDate`",`"FinishDate`",`"TimeDue`",`"ReminderTime`",`"StartDate`") VALUES (NULL, @BoardID, @DateCreated, @Title, @Description, @Category, @ColumnIndex, @ColorKey, @Tags, @DueDate, @FinishDate, @TimeDue, @ReminderTime, @StartDate );" -SqlParameters $sqlParameters | Out-Null
    }
    else {
        $taskID = $todoInDb[0]

        Write-Verbose "Update To-Do description for $($todo.text)"
        $sqlParameters = @{
            Id          = $taskID
            Description = $description
        }  
        Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"Description`"=@Description WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null

        Write-Verbose "Update To-Do Due Date for $($todo.text)"
        $sqlParameters = @{
            Id      = $taskID
            DueDate = $dueDate
        }
        Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"DueDate`"=@DueDate WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null

        Write-Verbose "Update To-Do Time Due for $($todo.text)"
        $sqlParameters = @{
            Id      = $taskID
            TimeDue = $timeDue
        }
        Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"TimeDue`"=@TimeDue WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null

        Write-Verbose "Update To-Do Reminder Time for $($todo.text)"
        $sqlParameters = @{
            Id           = $taskID
            ReminderTime = $reminderTime
        }
        Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"ReminderTime`"=@ReminderTime WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null

        if ($todo.completed -ne ($todoInDb[5] -eq 'Completed')) {
            Write-Verbose "Update To-Do Category for $($todo.text)"
            $sqlParameters = @{
                Id       = $taskID
                Category = $category
            }
            Invoke-SQLiteQuery -Database $ktdatabase -Query  "UPDATE `"main`".`"tblTasks`" SET `"Category`"=@Category WHERE `"Id`"=@Id;" -SqlParameters $sqlParameters | Out-Null
        }
    }
}