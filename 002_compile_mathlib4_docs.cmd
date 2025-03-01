::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE run this AFTER packaging demo projects, as it will unpack mathlib cache ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: setup environment variable

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

:: add dependencies

echo.>>projects\LeanPlayground\lakefile.toml
echo [[require]]>>projects\LeanPlayground\lakefile.toml
echo scope = "leanprover">>projects\LeanPlayground\lakefile.toml
echo name = "doc-gen4">>projects\LeanPlayground\lakefile.toml
echo rev = "main">>projects\LeanPlayground\lakefile.toml

:: download and unpack mathlib+cache, run 3 times as it errors randomly

set MATHLIB_NO_CACHE_ON_UPDATE=0
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"
".\PortableGit\bin\bash.exe" -c "cd projects/LeanPlayground && lake update"

cd projects\LeanPlayground

:: create dummy git repo

git init .
git config user.email "mathlib4_docs@leanprover-community.github.io"
git config user.name "mathlib4_docs CI"
git add README.md
git commit -m "workaround"
git remote add origin "https://github.com/leanprover-community/workaround"

:: Copy references

mkdir docs
copy /y .lake\packages\mathlib\docs .\docs

:: build doc-gen4

lake build doc-gen4

:: generate docs

lake build Batteries:docs Qq:docs Aesop:docs ProofWidgets:docs Mathlib:docs Archive:docs Counterexamples:docs docs:docs
lake build Mathlib:docsHeader

:: copy extra files

mkdir .lake\build\doc
copy /y .lake\packages\mathlib\docs .lake\build\doc

:: TODO package etc
