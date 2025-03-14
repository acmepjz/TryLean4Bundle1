cd ..
call scripts\setup_env_variables.cmd
cd projects\LeanPlayground
lake exe cache unpack
if /i not "%~1" == "/y" pause
