@echo off

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ASSUME we are in TryLean4Bundle\projects\LeanPlayground\.lake\build\doc ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: delete files which are not going to be packaged

echo ::group::delete files which are not going to be packaged

del /S /Q *.hash >NUL 2>&1
del /S /Q *.trace >NUL 2>&1
del declarations\header-data.bmp

echo ::endgroup::

:: check mathlib doc version

echo ::group::check mathlib doc version

powershell -ExecutionPolicy Bypass -File ..\..\..\..\..\..\Resources\check_mathlib_doc_version.ps1

type doc_version.txt

move doc_version.txt ..\..\..\..\..\..\doc_version.txt

echo ::endgroup::

:: download resources

echo ::group::download resources

cd ..\..\..\..\..\..

call 000_setup_urls.cmd

echo downloading lato-font
curl --retry 5 -L -o "Downloads\lato-font.zip" "%LATO_FONT_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading juliamono
curl --retry 5 -L -o "Downloads\juliamono.zip" "%JULIAMONO_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading MathJax
curl --retry 5 -L -o "Downloads\MathJax.zip" "%MATHJAX_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading brotli
curl --retry 5 -L -o "Downloads\brotli-x64-windows-static.zip" "%BROTLI_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)

echo ::endgroup::

echo ::group::extract resources

tar -x -f "Downloads\lato-font.zip" -C "Downloads"
tar -x -f "Downloads\juliamono.zip" -C "Downloads"
:: drop IE11 support
tar -x -f "Downloads\MathJax.zip" -C "Downloads"
tar -x -f "Downloads\brotli-x64-windows-static.zip" -C "Downloads"

cd Downloads\lato-font-master\fonts
del /S /Q *.woff
cd ..\..\..

echo ::endgroup::

:: copy resources

echo ::group::copy resources

mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\lato-font
move /y Downloads\lato-font-master\css TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\lato-font\
move /y Downloads\lato-font-master\fonts TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\lato-font\
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\juliamono
move /y Downloads\juliamono-master\webfonts TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\juliamono\
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5\output
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5\output\chtml
mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5\output\chtml\fonts
move /y Downloads\MathJax-master\es5\tex-mml-chtml.js TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5\
move /y Downloads\MathJax-master\es5\output\chtml\fonts\woff-v2 TryLean4Bundle\projects\LeanPlayground\.lake\build\doc\MathJax\es5\output\chtml\fonts\
rmdir /s /q "Downloads\lato-font-master"
rmdir /s /q "Downloads\juliamono-master"
rmdir /s /q "Downloads\MathJax-master"

echo ::endgroup::

cd TryLean4Bundle

:: patch style.css

echo ::group::patch style.css

".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground/.lake/build/doc && ../../../../../../Resources/patch_style_css.sh style.css"

echo ::endgroup::

:: patch MathJax loader

echo ::group::patch MathJax loader

move projects\LeanPlayground\.lake\build\doc\mathjax-config.js projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1
copy /B projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1 + ..\Resources\mathjax-config-patch.txt projects\LeanPlayground\.lake\build\doc\mathjax-config.js
del projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1

echo ::endgroup::

:: compress all files using brotli

echo ::group::compress all files using brotli (this may take a long time)

cd projects\LeanPlayground\.lake\build\doc

for /r %%F in (*.*) do (
    if /i not "%%~xF"==".br" (
        "..\..\..\..\..\..\Downloads\brotli.exe" "%%F"
    )
)

echo ::endgroup::

:: move them to a new directory

echo ::group::move files

cd ..\..
mkdir build_new
robocopy build\doc build_new\doc *.br /S /MOV /NFL /NDL /NP
cd build_new

echo ::endgroup::

:: package

echo ::group::package files

copy ..\..\..\..\..\doc_version.txt doc\doc_version.txt
tar -a -c -f doc.zip --options "zip:compression=store" doc

echo ::endgroup::

:: add doc.zip to TryLean4Bundle.7z

echo ::group::add doc.zip to TryLean4Bundle.7z

..\..\..\..\..\Downloads\7zr.exe u -mx0 ..\..\..\..\..\TryLean4Bundle.7z doc.zip

:: move file
move doc.zip ..\..\..\..\..\doc.zip

echo ::endgroup::

:: package offline mathlib help (TODO: this can be done without Lean installed)

echo ::group::package OfflineMathlibHelp.zip (without doc.zip)

cd ..\..\..\..

del ..\OfflineMathlibHelpWindows.zip
tar -a -c -f ..\OfflineMathlibHelpWindows.zip OfflineMathlibHelp.cmd TryLean4Launcher

cd ..

del OfflineMathlibHelpPython.zip
tar -a -c -f OfflineMathlibHelpPython.zip OfflineMathlibHelpPython

echo ::endgroup::

:: TODO error handle

exit /b 0
