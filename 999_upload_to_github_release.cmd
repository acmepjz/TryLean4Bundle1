@echo off
gh release upload nightly TryLean4Bundle.7z OfflineMathlibHelp.7z doc_version.txt --clobber
if %ERRORLEVEL% NEQ 0 (
	echo ::error::upload failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
echo Test>release_notes.txt
echo.>>release_notes.txt
echo ## Offline mathlib docs version>>release_notes.txt
echo.>>release_notes.txt
type doc_version.txt>>release_notes.txt
gh release edit nightly -F release_notes.txt
if %ERRORLEVEL% NEQ 0 (
	echo ::error::modify release notes failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
