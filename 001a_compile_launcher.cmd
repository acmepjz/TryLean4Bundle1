:: install python

curl --retry 5 -L -o "Downloads\Winpython64-3.13.2.0dot.7z" "https://github.com/winpython/winpython/releases/download/13.1.202502222final/Winpython64-3.13.2.0dot.7z"
Downloads\7zr.exe x "Downloads\Winpython64-3.13.2.0dot.7z" -o"Downloads"

set PATH=%CD%\Downloads\WPy64-31320\python;%CD%\Downloads\WPy64-31320\python\Scripts;%PATH%
set PYTHON=%CD%\Downloads\WPy64-31320\python\python.exe

:: install pyinstaller

pip install pyinstaller

:: compile launcher

cd TryLean4Launcher

pyinstaller TryLean4Launcher.py

:: move exe

cd ..
move /y TryLean4Launcher\dist\TryLean4Launcher\TryLean4Launcher.exe TryLean4Bundle\
move /y TryLean4Launcher\dist\TryLean4Launcher\_internal TryLean4Bundle\
robocopy TryLean4Launcher\locale TryLean4Bundle\locale /S
