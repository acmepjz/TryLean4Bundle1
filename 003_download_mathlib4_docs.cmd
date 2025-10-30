@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NOTE run this AFTER packaging demo projects, as it will add files to build folder ::
:: NOTE this only works with GitHub CLI (gh) installed                               ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: download mathlib4 docs archive

echo ::group::download mathlib4 docs archive

cd Downloads

del artifact.tar

set MATHLIB4_DOCS_REPO=leanprover-community/mathlib4_docs
set MATHLIB4_DOCS_WF_NAME=docs.yaml
set MATHLIB4_DOCS_ARTIFACT_NAME=github-pages
for /L %%i in (0, 1, 9) do (
	gh run --repo "%MATHLIB4_DOCS_REPO%" list --workflow "%MATHLIB4_DOCS_WF_NAME%" --json databaseId --jq ".[%%i].databaseId" > MATHLIB4_DOCS_RUN_ID.txt
	if %ERRORLEVEL% NEQ 0 (
		echo ::warning::failed to get RUN_ID for index %%i, error code %ERRORLEVEL%
	) else (
		set /p MATHLIB4_DOCS_RUN_ID=<MATHLIB4_DOCS_RUN_ID.txt
		echo RUN_ID for index %%i is %MATHLIB4_DOCS_RUN_ID%
		gh run --repo "%MATHLIB4_DOCS_REPO%" download "%MATHLIB4_DOCS_RUN_ID%" -n "%MATHLIB4_DOCS_ARTIFACT_NAME%"
		if %ERRORLEVEL% NEQ 0 (
			echo ::warning::download artifact for index %%i failed with error code %ERRORLEVEL%
		) else (
			echo ::warning::download artifact for index %%i successful
			goto :download_loop_end
		)
	)
)
:download_loop_end
if exist "artifact.tar" (
	dir artifact.tar
) else (
	echo ::error::download artifact failed
	exit /b 1
)

echo ::endgroup::

:: extract file "artifact.tar"

echo ::group::extract mathlib4 docs archive

cd ..

mkdir TryLean4Bundle\projects\LeanPlayground\.lake\build\doc

tar -x -f "Downloads\artifact.tar" -C "TryLean4Bundle\projects\LeanPlayground\.lake\build\doc"

echo ::endgroup::

:: setup environment variable

echo ::group::setup environment variable

cd TryLean4Bundle

call scripts\setup_env_variables.cmd

echo ::endgroup::

:: patch html files

echo ::group::patch html files (this may take a long time)

cd projects\LeanPlayground\.lake\build\doc

"..\..\..\..\..\PortableGit\bin\bash.exe" -c "../../../../../../Resources/patch_all_html.sh"

echo ::endgroup::

:: run step 2

cmd /C "..\..\..\..\..\..\002a_compile_mathlib4_docs_step_2.cmd"

cd ..\..\..\..\..\..

:: TODO error handle

exit /b 0
