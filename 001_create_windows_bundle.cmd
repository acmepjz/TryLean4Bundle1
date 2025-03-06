:::::::: download components ::::::::

mkdir Downloads

cd Downloads

curl --retry 5 -L -o "PortableGit.exe" "https://github.com/git-for-windows/git/releases/download/v2.48.1.windows.1/PortableGit-2.48.1-64-bit.7z.exe"
curl --retry 5 -L -o "VSCodium.zip" "https://github.com/VSCodium/vscodium/releases/download/1.97.2.25045/VSCodium-win32-x64-1.97.2.25045.zip"
curl --retry 5 -L -o "lean4ext.zip" "https://github.com/leanprover/vscode-lean4/releases/download/v0.0.195/lean4-0.0.195.vsix"

curl --retry 5 -L -o "7zr.exe" "https://www.7-zip.org/a/7zr.exe"
:: TODO add option to force mathlib version
curl --retry 5 -L -o "lean-toolchain" "https://raw.githubusercontent.com/leanprover-community/mathlib4/master/lean-toolchain"
curl --retry 5 -L -o "elan-init.sh" "https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh"
curl --retry 5 -L -o "leantar.zip" "https://github.com/digama0/leangz/releases/download/v0.1.14/leantar-v0.1.14-x86_64-pc-windows-msvc.zip"

cd ..

:::::::: install components ::::::::

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

copy /y Resources\vscodium_settings.json TryLean4Bundle\VSCodium\data\user-data\User\settings.json

:: Unfortunately, lean4 extension can't be installed using command line, but only in GUI mode
:: so we have to install it in ad ad-hoc way

mkdir Downloads\lean4ext
tar -x -f "Downloads\lean4ext.zip" -C "Downloads\lean4ext"
move /y "Downloads\lean4ext\extension" TryLean4Bundle\VSCodium\data\extensions\leanprover.lean4-0.0.195
rmdir /s /q Downloads\lean4ext

:: copy install scripts

copy Resources\unpack_cache.cmd TryLean4Bundle\
copy Resources\start_Lean_VSCode.cmd TryLean4Bundle\
copy Resources\start_Lean_bash.cmd TryLean4Bundle\

:::::::: setup environment variable ::::::::

cd Downloads

set /p LEAN_TOOLCHAIN_VERSION=<lean-toolchain

cd ..

copy /y Resources\setup_env_variables_template.txt TryLean4Bundle\scripts\setup_env_variables.cmd
echo set LEAN_TOOLCHAIN_VERSION=%LEAN_TOOLCHAIN_VERSION%>>TryLean4Bundle\scripts\setup_env_variables.cmd

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

:::::::: install elan ::::::::

".\PortableGit\bin\bash.exe" -c "../Downloads/elan-init.sh -y --no-modify-path --default-toolchain %LEAN_TOOLCHAIN_VERSION%"

:::::::: Create demo Project ::::::::

".\PortableGit\bin\bash.exe" -c "cd projects && lake +%LEAN_TOOLCHAIN_VERSION% new LeanPlayground math"

:: download mathlib, run 3 times as it errors randomly

set MATHLIB_NO_CACHE_ON_UPDATE=1
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"

:: download mathlib cache, run 3 times as it errors randomly

".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake exe cache get-"

:: TODO overwrite LeanPlayground.lean with an example file

:::::::: download learning materials ::::::::

cd ..

:: download Glimpse of Lean

curl --retry 5 -L -o "Downloads\GlimpseOfLean.zip" "https://github.com/PatrickMassot/GlimpseOfLean/archive/refs/heads/master.zip"
tar -x -f "Downloads\GlimpseOfLean.zip" -C "Downloads"
move /y "Downloads\GlimpseOfLean-master\GlimpseOfLean" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\GlimpseOfLean-master\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
move /y "Downloads\GlimpseOfLean-master\LICENSE" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
move /y "Downloads\GlimpseOfLean-master\tactics.pdf" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\GlimpseOfLean\"
rmdir /s /q "Downloads\GlimpseOfLean-master"
"TryLean4Bundle\PortableGit\bin\bash.exe" -c "cd TryLean4Bundle/projects/LeanPlayground/LeanPlayground && ../../../../Resources/patch_import.sh GlimpseOfLean"

:: download Mathematics in Lean

curl --retry 5 -L -o "Downloads\mathematics_in_lean.zip" "https://github.com/leanprover-community/mathematics_in_lean/archive/refs/heads/master.zip"
tar -x -f "Downloads\mathematics_in_lean.zip" -C "Downloads"
move /y "Downloads\mathematics_in_lean-master\MIL" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\mathematics_in_lean-master\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\MIL\"
move /y "Downloads\mathematics_in_lean-master\mathematics_in_lean.pdf" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\MIL\"
rmdir /s /q "Downloads\mathematics_in_lean-master"
"TryLean4Bundle\PortableGit\bin\bash.exe" -c "cd TryLean4Bundle/projects/LeanPlayground/LeanPlayground && ../../../../Resources/patch_import.sh MIL"

:: download Formalising Mathematics 2024

curl --retry 5 -L -o "Downloads\formalising-mathematics-2024.zip" "https://github.com/ImperialCollegeLondon/formalising-mathematics-2024/archive/refs/heads/main.zip"
tar -x -f "Downloads\formalising-mathematics-2024.zip" -C "Downloads"
move /y "Downloads\formalising-mathematics-2024-main\FormalisingMathematics2024" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\"
move /y "Downloads\formalising-mathematics-2024-main\README.md" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\FormalisingMathematics2024\"
move /y "Downloads\formalising-mathematics-2024-main\LICENSE" "TryLean4Bundle\projects\LeanPlayground\LeanPlayground\FormalisingMathematics2024\"
rmdir /s /q "Downloads\formalising-mathematics-2024-main"
:: no need to patch import for this

:::::::: compile launcher ::::::::

001a_compile_launcher.cmd

:::::::: package ::::::::

del TryLean4Bundle.7z

cd TryLean4Bundle

..\Downloads\7zr.exe a -mx9 ..\TryLean4Bundle.7z *

cd ..

:: TODO error handle

exit /b 0
