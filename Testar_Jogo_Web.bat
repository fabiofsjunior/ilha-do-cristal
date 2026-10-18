@echo off
setlocal

set "SERVER_SCRIPT=%~dp0tools\web\serve_web_build.py"
set "EXPORT_SCRIPT=%~dp0tools\build\export_web.py"
set "WEB_DIR=%~dp0build\web"
if exist "%~dp0index.html" set "WEB_DIR=%~dp0."

if not exist "%SERVER_SCRIPT%" (
    echo Nao encontrei o servidor local em:
    echo "%SERVER_SCRIPT%"
    pause
    exit /b 1
)

where py >nul 2>&1
if not errorlevel 1 (
    set "PYTHON_CMD=py"
    set "PYTHON_ARGS=-3"
    goto check_build
)

where python >nul 2>&1
if errorlevel 1 goto python_missing
set "PYTHON_CMD=python"
set "PYTHON_ARGS="

:check_build
if exist "%WEB_DIR%\index.html" goto start_server
if not exist "%EXPORT_SCRIPT%" goto build_missing

echo Build Web nao encontrada. Vou tentar exportar com Godot 4.5.1...
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%"
if errorlevel 1 goto export_failed
if not exist "%WEB_DIR%\index.html" goto build_missing

:start_server
%PYTHON_CMD% %PYTHON_ARGS% "%SERVER_SCRIPT%" --web-dir "%WEB_DIR%"
set "LAUNCH_EXIT=%errorlevel%"
if not "%LAUNCH_EXIT%"=="0" pause
exit /b %LAUNCH_EXIT%

:build_missing
echo Build Web nao encontrada em:
echo "%WEB_DIR%"
echo Exporte o preset Web no Godot 4.5.1 com os templates Web instalados.
echo O executavel tenta exportar automaticamente se o Godot e os templates estiverem disponiveis.
pause
exit /b 1

:export_failed
echo A exportacao Web falhou. Confira a mensagem acima e instale os templates Web do Godot 4.5.1.
pause
exit /b 1

:python_missing
echo Python 3 nao foi encontrado. Instale Python 3 ou adicione-o ao PATH.
pause
exit /b 1
