@echo off
setlocal

set "SERVER_SCRIPT=%~dp0tools\wiki\serve.js"
if not exist "%SERVER_SCRIPT%" (
    echo Nao encontrei o servidor da wiki em:
    echo "%SERVER_SCRIPT%"
    pause
    exit /b 1
)

where node >nul 2>&1
if errorlevel 1 goto node_missing

pushd "%~dp0"
node "%SERVER_SCRIPT%"
set "SERVER_EXIT=%errorlevel%"
popd
if not "%SERVER_EXIT%"=="0" pause
exit /b %SERVER_EXIT%

:node_missing
echo Node.js nao foi encontrado. Instale Node.js 18 ou superior e adicione-o ao PATH.
pause
exit /b 1
