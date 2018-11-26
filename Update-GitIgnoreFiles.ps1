Start-Process -FilePath 'C:\Program Files\Git\bin\git.exe' -ArgumentList 'pull -r -p' -WorkingDirectory '..\..\github\gitignore' -Wait

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Cmdlets\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Samples\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Grocery-Checklist\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Pushalot\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\PushalotPS\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\Scripts\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\TIKSN-Exchange\.gitignore -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\TIKSN-Framework\.gitignore -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\Console Screen\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\CrashCourse Lessons\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\CSV Converter\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\Locale Graph\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\PenPalsNow Parser\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\Terminology Translator\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\TIKSN Blog\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\UkrGoCommander\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\Bitbucket\tiksn\Ամեն ինչի մասին\Code\.gitignore' -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination ..\..\..\GitLab\tiksn\economics-and-finance\.gitignore -Confirm

Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\Grocery Checklist\Code\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\Spender\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\TIKSN Exchange\.gitignore' -Confirm
Copy-Item -Path ..\..\github\gitignore\VisualStudio.gitignore -Destination '..\..\..\VSTS\tiksn\TIKSN Home Website\Code\.gitignore' -Confirm
