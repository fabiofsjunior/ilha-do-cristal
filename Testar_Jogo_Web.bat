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

echo Build Web nao encontrada. Vou tentar exportar com Godot 4.7.2...
set "GODOT_PATH_FILE=%TEMP%\ilha-do-cristal-godot-path.txt"
set "GODOT_EXE="

rem O Python testa --version e ignora executaveis quebrados antes de retornar o caminho.
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%" --print-godot > "%GODOT_PATH_FILE%"
if errorlevel 1 goto select_godot
set /p "GODOT_EXE="<"%GODOT_PATH_FILE%"
del "%GODOT_PATH_FILE%" >nul 2>&1
if not defined GODOT_EXE goto select_godot
echo Godot 4.7.2 valido: "%GODOT_EXE%"

:export_web
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%" --godot "%GODOT_EXE%" --check-web-templates
if errorlevel 1 goto web_templates_missing
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%" --godot "%GODOT_EXE%"
if errorlevel 1 goto export_failed
if not exist "%WEB_DIR%\index.html" goto build_missing
goto start_server

:web_templates_missing
echo.
echo O launcher precisa dos templates Web do Godot 4.7.2.
echo Na janela do editor: Editor ^> Gerenciar modelos de exportacao ^(Manage Export Templates...^), marque somente Web.
echo Clique em Instalar modelos selecionados ^(Install Selected Templates^).
echo O Godot baixara apenas os templates dessa plataforma.
choice /C SN /N /M "Abrir o Godot 4.7.2 para instalar agora? [S/N] "
if errorlevel 2 goto web_templates_manual
echo.
echo Instale os templates Web na janela que sera aberta e feche o editor para continuar.
start "" /wait "%GODOT_EXE%" --editor --path "%~dp0"
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%" --godot "%GODOT_EXE%" --check-web-templates
if errorlevel 1 goto web_templates_manual
goto export_web

:web_templates_manual
echo.
echo Templates ainda ausentes. Instale-os pelo menu Editor ^> Gerenciar modelos de exportacao do Godot 4.7.2.
echo Selecione somente Web; nao baixe o arquivo TPZ completo de todas as plataformas.
echo Depois execute Testar_Jogo_Web.bat novamente.
pause
exit /b 1

:select_godot
del "%GODOT_PATH_FILE%" >nul 2>&1
echo.
echo Se voce tem o Godot 4.7.2, selecione o executavel para esta exportacao.
echo ZIP oficial do Godot 4.7.2 x64: https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip
echo O caminho escolhido sera salvo localmente para os proximos testes.
for /f "usebackq delims=" %%G in (`powershell -NoProfile -STA -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.OpenFileDialog; $d.Title = 'Selecione o executavel Godot 4.7.2'; $d.Filter = 'Godot console (*_console.exe)|*_console.exe|Todos os executaveis (*.exe)|*.exe'; if ($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Write-Output $d.FileName }"`) do set "GODOT_EXE=%%G"
if not defined GODOT_EXE goto godot_missing
%PYTHON_CMD% %PYTHON_ARGS% "%EXPORT_SCRIPT%" --godot "%GODOT_EXE%" --save-godot
if errorlevel 1 goto export_failed
if not exist "%WEB_DIR%\index.html" goto build_missing
goto start_server

:start_server
%PYTHON_CMD% %PYTHON_ARGS% "%SERVER_SCRIPT%" --web-dir "%WEB_DIR%"
set "LAUNCH_EXIT=%errorlevel%"
if not "%LAUNCH_EXIT%"=="0" pause
exit /b %LAUNCH_EXIT%

:build_missing
echo Build Web nao encontrada em:
echo "%WEB_DIR%"
echo Exporte o preset Web no Godot 4.7.2 com os templates Web instalados.
echo O executavel tenta exportar automaticamente se o Godot e os templates estiverem disponiveis.
pause
exit /b 1

:export_failed
echo A exportacao Web falhou. Confira a mensagem acima.
echo Se faltarem templates, instale os templates de exportacao Web do Godot 4.7.2.
pause
exit /b 1

:godot_missing
echo.
echo Nao foi possivel selecionar o Godot 4.7.2.
echo Instale ou extraia o Godot 4.7.2, ou defina GODOT_BIN com o caminho do executavel.
pause
exit /b 1

:python_missing
echo Python 3 nao foi encontrado. Instale Python 3 ou adicione-o ao PATH.
pause
exit /b 1
