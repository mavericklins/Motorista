@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ====== AJUSTE AQUI SE PRECISAR ======
set "PROJECT_DIR=D:\AndroidStudioProjects\Motorista"
REM =====================================

REM Normaliza barra final
if not "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR%\"

if not exist "%PROJECT_DIR%pubspec.yaml" (
  echo ERRO: Nao achei pubspec.yaml em "%PROJECT_DIR%".
  echo Verifique a variavel PROJECT_DIR dentro deste BAT.
  exit /b 1
)

echo Projeto: %PROJECT_DIR%
set "STAGING=%PROJECT_DIR%_patch_stage"
set "OUTPUT_ZIP=%PROJECT_DIR%vello_motorista_patch_fix.zip"
set "FILELIST=%STAGING%\filelist.txt"

REM Limpa staging e recria
rd /s /q "%STAGING%" 2>nul
md "%STAGING%" || (echo ERRO ao criar staging & exit /b 1)

REM ===== Lista-alvo =====
> "%FILELIST%" (
  echo lib\theme\app_theme.dart
  echo lib\theme\vello_colors.dart
  echo lib\constants\app_colors.dart
  echo lib\routes\app_routes.dart
  echo lib\screens\coaching\coaching_inteligente_screen.dart
  echo lib\screens\home\home_screen.dart
  echo lib\screens\security\sos_screen.dart
  echo lib\screens\carteira\carteira_digital_screen.dart
  echo lib\screens\gamification\conquistas_screen.dart
  echo lib\screens\ganhos\meus_creditos_screen.dart
  echo lib\screens\corridas_programadas\corridas_programadas_screen.dart
  echo lib\screens\metas\metas_inteligentes_screen.dart
  echo lib\screens\auth\login_screen.dart
  echo lib\screens\auth\register_screen.dart
  echo lib\screens\auth\splash_screen.dart
  echo lib\services\sound_service.dart
  echo lib\services\emergencia_service.dart
  echo lib\services\demand_prediction_service.dart
  echo lib\services\financial_service.dart
  echo lib\services\notification_service.dart
  echo lib\services\analytics_service.dart
  echo lib\services\coaching_inteligente_service.dart
  echo lib\constants\app_colors.dart
  echo lib\theme\vello_colors.dart
  echo lib\theme\app_theme.dart
  echo lib\main.dart
  echo pubspec.yaml
  echo android\gradle.properties
)

set /a FOUND=0
set /a MISS=0

echo Coletando arquivos...
for /f "usebackq delims=" %%F in ("%FILELIST%") do (
  set "REL=%%F"
  set "SRC=%PROJECT_DIR%%%F"

  if exist "!SRC!" (
    echo  [+] !REL!
    md "%STAGING%\%%~dpF" >nul 2>&1
    copy /y "!SRC!" "%STAGING%\!REL!" >nul
    set /a FOUND+=1
  ) else (
    REM Plano B: procurar pelo nome do arquivo dentro do projeto
    set "FN=%%~nxF"
    set "HIT="
    for /f "delims=" %%S in ('dir /b /s "%PROJECT_DIR%!FN!" 2^>nul') do (
      if not defined HIT set "HIT=%%S"
    )
    if defined HIT (
      set "REL2=!HIT:%PROJECT_DIR%=!"
      echo  [≈] Encontrado por busca: !REL!  -->  !REL2!
      md "%STAGING%\!REL2!\.." >nul 2>&1
      md "%STAGING%\!REL2:\%FN%=!" >nul 2>&1
      md "%STAGING%\!REL2!\.." >nul 2>&1
      md "%STAGING%\!REL2!" >nul 2>&1
      copy /y "!HIT!" "%STAGING%\!REL2!" >nul
      set /a FOUND+=1
    ) else (
      echo  [!] NAO ENCONTRADO: %%F
      set /a MISS+=1
    )
  )
)

echo.
echo Total copiados: %FOUND%  |  Faltando: %MISS%

echo.
echo Compactando para ZIP (PowerShell)...
powershell -NoProfile -Command ^
  "Try { Compress-Archive -Path '%STAGING%\*' -DestinationPath '%OUTPUT_ZIP%' -Force -CompressionLevel Optimal; exit 0 } Catch { Write-Error $_; exit 1 }"
if errorlevel 1 (
  echo PowerShell falhou; tentando tar.exe...
  if exist "%SystemRoot%\System32\tar.exe" (
    pushd "%STAGING%"
    "%SystemRoot%\System32\tar.exe" -a -c -f "%OUTPUT_ZIP%" * 2>nul
    popd
  ) else (
    echo ERRO: Nem Compress-Archive nem tar.exe funcionaram.
    exit /b 1
  )
)

echo.
if exist "%OUTPUT_ZIP%" (
  echo OK! ZIP criado:
  echo %OUTPUT_ZIP%
) else (
  echo ERRO: ZIP nao foi gerado.
  exit /b 1
)

endlocal
