:: copy files

robocopy TryLean4Launcher TryLean4Bundle\TryLean4Launcher /S /NFL /NDL /NP

:: create script

echo powershell -ExecutionPolicy Bypass -File TryLean4Launcher\TryLean4Launcher.ps1>TryLean4Bundle\TryLean4Launcher.cmd

:: TODO error handle

exit /b 0
