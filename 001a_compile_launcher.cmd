@echo off

:: copy files

robocopy TryLean4Launcher TryLean4Bundle\TryLean4Launcher /S /NFL /NDL /NP

:: create script

echo start powershell -ExecutionPolicy Bypass -File TryLean4Launcher\TryLean4Launcher.ps1>TryLean4Bundle\TryLean4Launcher.cmd
echo start powershell -ExecutionPolicy Bypass -File TryLean4Launcher\TryLean4Launcher.ps1 -OnlyOfflineMathlibHelp>TryLean4Bundle\OfflineMathlibHelp.cmd

:: TODO error handle

exit /b 0
