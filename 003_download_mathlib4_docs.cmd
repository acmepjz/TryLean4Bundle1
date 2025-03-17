:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE run this AFTER packaging demo projects, as it will add files to build folder ::
:: NOTE this only works with GitHub CLI (gh) installed                               ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: download mathlib4 docs archive

cd Downloads

set MATHLIB4_DOCS_REPO=leanprover-community/mathlib4_docs
set MATHLIB4_DOCS_WF_NAME=docs.yaml
set MATHLIB4_DOCS_ARTIFACT_NAME=github-pages
gh run --repo "%MATHLIB4_DOCS_REPO%" list --workflow "%MATHLIB4_DOCS_WF_NAME%" --json databaseId --jq .[0].databaseId > MATHLIB4_DOCS_RUN_ID.txt
set /p MATHLIB4_DOCS_RUN_ID=<MATHLIB4_DOCS_RUN_ID.txt
gh run --repo "%MATHLIB4_DOCS_REPO%" download "%MATHLIB4_DOCS_RUN_ID%" -n "%MATHLIB4_DOCS_ARTIFACT_NAME%"

:: extract file "artifact.tar"

cd ..

mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc

tar -x -f "Downloads\artifact.tar" -C "TryLean4Bundle\projects\LeanPlayground\.lake\build\doc"

:: setup environment variable

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

:: patch html files

cd projects\LeanPlayground\.lake\build\doc

"..\..\..\..\..\PortableGit\bin\bash.exe" -c "../../../../../../Resources/patch_all_html.sh"

:: run step 2

cmd /C "..\..\..\..\..\..\002a_compile_mathlib4_docs_step_2.cmd"

cd ..\..\..\..\..\..

:: TODO error handle

exit /b 0
