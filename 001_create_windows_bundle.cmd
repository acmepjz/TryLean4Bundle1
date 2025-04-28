@echo off

:::::::: download components ::::::::

echo ::group::download components

call 000_setup_urls.cmd

mkdir Downloads

cd Downloads

echo downloading PortableGit
curl --retry 5 -L -o "PortableGit.exe" "%PORTABLE_GIT_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading VSCodium
curl --retry 5 -L -o "VSCodium.zip" "%VSCODIUM_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading lean4ext
curl --retry 5 -L -o "lean4ext.zip" "%LEAN4EXT_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading 7-zip
curl --retry 5 -L -o "7zr.exe" "%SEVENZIP_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
:: TODO add option to force mathlib version
echo downloading lean-toolchain
curl --retry 5 -L -o "lean-toolchain" "%LEAN_TOOLCHAIN_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo the lean-toolchain is:
type lean-toolchain
echo downloading elan-init
curl --retry 5 -L -o "elan-init.sh" "%ELAN_INIT_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading leantar
curl --retry 5 -L -o "leantar.zip" "%LEANTAR_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading Glimpse Of Lean
curl --retry 5 -L -o "GlimpseOfLean.zip" "%GOL_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading mathematics in lean
curl --retry 5 -L -o "mathematics_in_lean.zip" "%MIL_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo downloading formalising mathematics 2024
curl --retry 5 -L -o "formalising-mathematics-2024.zip" "%FM2024_URL%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)

cd ..

echo ::endgroup::

:::::::: install components ::::::::

echo ::group::install components

mkdir TryLean4Bundle\PortableGit
mkdir TryLean4Bundle\VSCodium\data\extensions
mkdir TryLean4Bundle\VSCodium\data\user-data\User
mkdir TryLean4Bundle\Cache\mathlib
mkdir TryLean4Bundle\Elan\bin
mkdir TryLean4Bundle\scripts
mkdir TryLean4Bundle\projects

Downloads\7zr.exe x "Downloads\PortableGit.exe" -o"TryLean4Bundle\PortableGit"
tar -x -f "Downloads\VSCodium.zip" -C "TryLean4Bundle\VSCodium"
tar -x -f "Downloads\leantar.zip" -C "Downloads"
move "Downloads\leantar-v%LEANTAR_VERSION%-x86_64-pc-windows-msvc\leantar.exe" "TryLean4Bundle\Cache\mathlib\leantar-%LEANTAR_VERSION%.exe"
rmdir "Downloads\leantar-v%LEANTAR_VERSION%-x86_64-pc-windows-msvc"

echo ::endgroup::

:: copy default settings

echo ::group::configure vscodium

copy /y Resources\vscodium_settings.json TryLean4Bundle\VSCodium\data\user-data\User\settings.json

:: Unfortunately, lean4 extension can't be installed using command line, but only in GUI mode
:: so we have to install it in ad ad-hoc way

mkdir Downloads\lean4ext
tar -x -f "Downloads\lean4ext.zip" -C "Downloads\lean4ext"
move /y "Downloads\lean4ext\extension" "TryLean4Bundle\VSCodium\data\extensions\leanprover.lean4-%LEAN4EXT_VERSION%"
rmdir /s /q Downloads\lean4ext

echo ::endgroup::

:: copy install scripts

echo ::group::copy install scripts

copy Resources\unpack_cache.cmd TryLean4Bundle\scripts\
copy Resources\start_Lean_VSCode.cmd TryLean4Bundle\scripts\
copy Resources\start_Lean_bash.cmd TryLean4Bundle\scripts\

echo ::endgroup::

:::::::: setup environment variable ::::::::

echo ::group::setup environment variable

cd Downloads

set /p LEAN_TOOLCHAIN_VERSION=<lean-toolchain

cd ..

copy /y Resources\setup_env_variables_template.txt TryLean4Bundle\scripts\setup_env_variables.cmd
echo set LEAN_TOOLCHAIN_VERSION=%LEAN_TOOLCHAIN_VERSION%>>TryLean4Bundle\scripts\setup_env_variables.cmd

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

echo ::endgroup::

:::::::: install elan ::::::::

echo ::group::install elan

".\PortableGit\bin\bash.exe" -c "../Downloads/elan-init.sh -y --no-modify-path --default-toolchain %LEAN_TOOLCHAIN_VERSION%"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::install failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)

echo ::endgroup::

:::::::: create demo project ::::::::

echo ::group::create demo project

".\PortableGit\bin\bash.exe" -c "cd projects && lake +%LEAN_TOOLCHAIN_VERSION% new LeanPlayground math"

echo ::endgroup::

:: download mathlib, run 3 times as it errors randomly

echo ::group::download mathlib

set MATHLIB_NO_CACHE_ON_UPDATE=1
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)

echo ::endgroup::

:: download mathlib cache, run 3 times as it errors randomly

echo ::group::download mathlib cache

".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"
if %ERRORLEVEL% NEQ 0 (
	echo ::error::download failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)

echo ::endgroup::

:: TODO overwrite LeanPlayground.lean with an example file

:::::::: setup learning materials ::::::::

cd ..

:: setup Glimpse of Lean

echo ::group::setup Glimpse of Lean

tar -x -f "Downloads\GlimpseOfLean.zip" -C "Downloads"
move /y "Downloads\GlimpseOfLean-master\GlimpseOfLean" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\GlimpseOfLean-master\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
move /y "Downloads\GlimpseOfLean-master\LICENSE" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
move /y "Downloads\GlimpseOfLean-master\tactics.pdf" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
rmdir /s /q "Downloads\GlimpseOfLean-master"
"TryLean4Bundle\PortableGit\bin\bash.exe" -c "cd TryLean4Bundle/projects/LeanPlayground/LeanPlayground && ../../../../Resources/patch_import.sh GlimpseOfLean"

echo ::endgroup::

:: setup Mathematics in Lean

echo ::group::setup Mathematics in Lean

tar -x -f "Downloads\mathematics_in_lean.zip" -C "Downloads"
move /y "Downloads\mathematics_in_lean-master\MIL" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\mathematics_in_lean-master\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\MIL\"
move /y "Downloads\mathematics_in_lean-master\mathematics_in_lean.pdf" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\MIL\"
rmdir /s /q "Downloads\mathematics_in_lean-master"
"TryLean4Bundle\PortableGit\bin\bash.exe" -c "cd TryLean4Bundle/projects/LeanPlayground/LeanPlayground && ../../../../Resources/patch_import.sh MIL"

echo ::endgroup::

:: setup Formalising Mathematics 2024

echo ::group::setup Formalising Mathematics 2024

tar -x -f "Downloads\formalising-mathematics-2024.zip" -C "Downloads"
move /y "Downloads\formalising-mathematics-2024-main\FormalisingMathematics2024" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\formalising-mathematics-2024-main\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\FormalisingMathematics2024\"
move /y "Downloads\formalising-mathematics-2024-main\LICENSE" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\FormalisingMathematics2024\"
rmdir /s /q "Downloads\formalising-mathematics-2024-main"
:: no need to patch import for this

echo ::endgroup::

:::::::: compile launcher ::::::::

echo ::group::compile launcher

cmd /C 001a_compile_launcher.cmd

echo ::endgroup::

:::::::: package ::::::::

echo ::group::package TryLean4Bundle.7z

del TryLean4Bundle.7z

cd TryLean4Bundle

..\Downloads\7zr.exe a -mx9 ..\TryLean4Bundle.7z *

cd ..

echo ::endgroup::

:: TODO error handle

exit /b 0
