@echo off
gh release upload nightly TryLean4Bundle.7z OfflineMathlibHelp.7z --clobber
if %ERRORLEVEL% NEQ 0 (
	echo ::error::upload failed with error code %ERRORLEVEL%
	exit /b %ERRORLEVEL%
)
