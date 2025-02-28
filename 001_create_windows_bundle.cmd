:: download components

mkdir Downloads

cd Downloads

curl -L -o "PortableGit.exe" "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/PortableGit-2.48.1-64-bit.7z.exe"
curl -L -o "VSCodium.zip" "https://github.com/VSCodium/vscodium/releases/download/1.97.2.25045/VSCodium-win32-x64-1.97.2.25045.zip"
curl -L -o "lean4ext.zip" "https://github.com/leanprover/vscode-lean4/releases/download/v0.0.195/lean4-0.0.195.vsix"

curl -L -o "7zr.exe" "https://www.7-zip.org/a/7zr.exe"
:: TODO add option to force mathlib version
curl -L -o "lean-toolchain" "https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain"
curl -L -o "elan-init.sh" "https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh"
curl -L -o "leantar.zip" "https://github.com/digama0/leangz/releases/download/v0.1.14/leantar-v0.1.14-x86_64-pc-windows-msvc.zip"

cd ..

:: install components

mkdir TryLean4Bundle
mkdir TryLean4Bundle\PortableGit
mkdir TryLean4Bundle\VSCodium
mkdir TryLean4Bundle\VSCodium\data
mkdir TryLean4Bundle\VSCodium\data\extensions
mkdir TryLean4Bundle\VSCodium\data\user-data
mkdir TryLean4Bundle\VSCodium\data\user-data\User
mkdir TryLean4Bundle\Cache
mkdir TryLean4Bundle\Cache\mathlib
mkdir TryLean4Bundle\Elan
mkdir TryLean4Bundle\Elan\bin
mkdir TryLean4Bundle\scripts
mkdir TryLean4Bundle\projects

Downloads\7zr.exe x "Downloads\PortableGit.exe" -o"TryLean4Bundle\PortableGit"
tar -x -f "Downloads\VSCodium.zip" -C "TryLean4Bundle\VSCodium"
tar -x -f "Downloads\leantar.zip" -C "Downloads"
move "Downloads\leantar-v0.1.14-x86_64-pc-windows-msvc\leantar.exe" "TryLean4Bundle\Cache\mathlib\leantar-0.1.14.exe"
rmdir "Downloads\leantar-v0.1.14-x86_64-pc-windows-msvc"

:: copy default settings

copy /y vscodium_settings.json TryLean4Bundle\VSCodium\data\user-data\User\settings.json

:: Unfortunately, lean4 extension can't be installed using command line, but only in GUI mode
:: so we have to install it in ad ad-hoc way

mkdir Downloads\lean4ext
tar -x -f "Downloads\lean4ext.zip" -C "Downloads\lean4ext"
move /y "Downloads\lean4ext\extension" TryLean4Bundle\VSCodium\data\extensions\leanprover.lean4-0.0.195
rmdir /s /q Downloads\lean4ext

:: setup environment variable

cd Downloads

set /p LEAN_TOOLCHAIN_VERSION=<lean-toolchain

cd ..

copy /y setup_env_variables_template.txt TryLean4Bundle\scripts\setup_env_variables.cmd
echo set LEAN_TOOLCHAIN_VERSION=%LEAN_TOOLCHAIN_VERSION%>>TryLean4Bundle\scripts\setup_env_variables.cmd

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

:: install elan

".\PortableGit\bin\bash.exe" -c "../Downloads/elan-init.sh -y --no-modify-path --default-toolchain %LEAN_TOOLCHAIN_VERSION%"

:: Create demo Project

".\PortableGit\bin\bash.exe" -c "cd projects && lake +%LEAN_TOOLCHAIN_VERSION% new Trylean math"

:: download mathlib, run 3 times as it errors randomly

set MATHLIB_NO_CACHE_ON_UPDATE=1
".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake update"

:: download mathlib cache, run 3 times as it errors randomly

".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/Trylean && lake exe cache get-"

:: TODO package it with install script and run script
