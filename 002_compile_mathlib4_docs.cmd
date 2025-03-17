::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE run this AFTER packaging demo projects, as it will unpack mathlib cache ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: setup environment variable

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

:: add dependencies

move projects\LeanPlayground\lakefile.toml projects\LeanPlayground\lakefile.toml.1
copy /B projects\LeanPlayground\lakefile.toml.1 + ..\Resources\lakefile-toml-patch.txt projects\LeanPlayground\lakefile.toml
del projects\LeanPlayground\lakefile.toml.1

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
copy /y .lake\packages\mathlib\docs\references.bib .\docs\references.bib

:: patch source code of doc-gen4

"..\..\PortableGit\bin\bash.exe" -c "../../../Resources/patch_html.sh .lake/packages/doc-gen4/DocGen4/Output/Template.lean"

:: build doc-gen4

lake build doc-gen4

:: generate docs (will take about 3 hours)

lake build Batteries:docs Qq:docs Aesop:docs ProofWidgets:docs Mathlib:docs Archive:docs Counterexamples:docs docs:docs

:: run step 2

cd .lake\build\doc

cmd /C "..\..\..\..\..\..\002a_compile_mathlib4_docs_step_2.cmd"

cd ..\..\..\..\..\..

:: TODO error handle

exit /b 0
