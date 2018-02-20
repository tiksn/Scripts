Start-Process -FilePath 'C:\Program Files\Git\bin\git.exe' -ArgumentList 'pull -r -p' -WorkingDirectory '..\..\github\gitignore' -Wait

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Cmdlets\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Samples\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Grocery-Checklist\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Pushalot\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\PushalotPS\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Scripts\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\TIKSN-Exchange\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\TIKSN-Framework\.gitignore -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\Console Screen\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\CrashCourse Lessons\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\CSV Converter\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\Locale Graph\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\PenPalsNow Parser\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\Terminology Translator\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\TIKSN Blog\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\UkrGoCommander\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\Ամեն ինչի մասին\Code\.gitignore' -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\..\..\GitLab\tiksn\economics-and-finance\.gitignore -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\Grocery Checklist\Code\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\Spender\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\TIKSN Exchange\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\TIKSN Home Website\Code\.gitignore' -Confirm
