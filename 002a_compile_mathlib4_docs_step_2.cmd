:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ASSUME we are in TryLean4Bundle\projects\LeanPlayground\.lake\build\doc ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: delete files which are not going to be packaged

del /S /Q *.hash >NUL 2>&1
del /S /Q *.trace >NUL 2>&1
del declarations\header-data.bmp

:: download resources

cd ..\..\..\..\..\..

curl --retry 5 -L -o "Downloads\lato-font.zip" "https://github.com/betsol/lato-font/archive/refs/heads/master.zip"
tar -x -f "Downloads\lato-font.zip" -C "Downloads"
curl --retry 5 -L -o "Downloads\juliamono.zip" "https://github.com/cormullion/juliamono/archive/refs/heads/master.zip"
tar -x -f "Downloads\juliamono.zip" -C "Downloads"
:: drop IE11 support
curl --retry 5 -L -o "Downloads\MathJax.zip" "https://github.com/mathjax/MathJax/archive/refs/heads/master.zip"
tar -x -f "Downloads\MathJax.zip" -C "Downloads"

cd Downloads\lato-font-master\fonts
del /S /Q *.woff
cd ..\..\..

:: copy resources

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

cd TryLean4Bundle

:: patch style.css

".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground/.lake/build/doc && ../../../../../../Resources/patch_style_css.sh style.css"

:: patch MathJax loader

move projects\LeanPlayground\.lake\build\doc\mathjax-config.js projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1
copy /B projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1 + ..\Resources\mathjax-config-patch.txt projects\LeanPlayground\.lake\build\doc\mathjax-config.js
del projects\LeanPlayground\.lake\build\doc\mathjax-config.js.1

:: download brotli

cd ..

curl --retry 5 -L -o "Downloads\brotli-x64-windows-static.zip" "https://github.com/google/brotli/releases/download/v1.1.0/brotli-x64-windows-static.zip"
tar -x -f "Downloads\brotli-x64-windows-static.zip" -C "Downloads"

:: compress all files using brotli

cd TryLean4Bundle\projects\LeanPlayground\.lake\build\doc

@echo off
echo.
echo Compressing all files using brotli, please wait...
echo.

for /r %%F in (*.*) do (
    if /i not "%%~xF"==".br" (
        "..\..\..\..\..\..\Downloads\brotli.exe" "%%F"
    )
)

echo.
echo ... Done.
echo.
@echo on

:: move them to a new directory

cd ..\..
mkdir build_new
robocopy build\doc build_new\doc *.br /S /MOV /NFL /NDL /NP
cd build_new

:: package

tar -a -c -f doc.zip --options "zip:compression=store" doc

:: add doc.zip to existing try lean bundle file

..\..\..\..\..\Downloads\7zr.exe u -mx0 ..\..\..\..\..\TryLean4Bundle.7z doc.zip

:: TODO error handle

exit /b 0
