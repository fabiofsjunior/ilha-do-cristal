@echo off
setlocal

set "SERVER_SCRIPT=%~dp0tools\web\serve_web_build.py"
set "WEB_DIR=%~dp0build\web"
if exist "%~dp0index.html" set "WEB_DIR=%~dp0."
if not exist "%SERVER_SCRIPT%" (
    echo Nao encontrei o servidor local em:
    echo "%SERVER_SCRIPT%"
    pause
    exit /b 1
)

where py >nul 2>&1
if not errorlevel 1 goto use_py_launcher

where python >nul 2>&1
if errorlevel 1 goto python_missing
python "%SERVER_SCRIPT%" --web-dir "%WEB_DIR%"
goto finished

:use_py_launcher
py -3 "%SERVER_SCRIPT%" --web-dir "%WEB_DIR%"
goto finished

:finished
set "LAUNCH_EXIT=%errorlevel%"
if not "%LAUNCH_EXIT%"=="0" pause
exit /b %LAUNCH_EXIT%

:python_missing
echo Python 3 nao foi encontrado. Instale Python 3 ou adicione-o ao PATH.
pause
exit /b 1
