@echo off
echo 🚀 Limpeza completa de caches corrompidos do Kotlin...
echo ============================================================

echo.
echo 1. Parando daemons...
gradle --stop
taskkill /f /im gradle.exe 2>nul
taskkill /f /im kotlin-daemon.exe 2>nul

echo.
echo 2. Limpando caches do projeto...
cd /d "D:\AndroidStudioProjects\vello_motorista"
if exist "build" rmdir /s /q "build"
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"
if exist "android\build" rmdir /s /q "android\build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo 3. Limpando caches globais...
if exist "%USERPROFILE%\.gradle\caches" rmdir /s /q "%USERPROFILE%\.gradle\caches"
if exist "%USERPROFILE%\.gradle\daemon" rmdir /s /q "%USERPROFILE%\.gradle\daemon"
if exist "%USERPROFILE%\.kotlin" rmdir /s /q "%USERPROFILE%\.kotlin"
if exist "%LOCALAPPDATA%\Pub\Cache" rmdir /s /q "%LOCALAPPDATA%\Pub\Cache"

echo.
echo 4. Executando comandos de limpeza...
flutter clean
flutter pub cache repair

echo.
echo ✅ Limpeza concluída!
echo.
echo 📋 PRÓXIMOS PASSOS:
echo 1. Substitua android\gradle.properties pelo arquivo sem compilação incremental
echo 2. Execute: flutter pub get
echo 3. Execute: flutter build apk --debug
echo.
pause

