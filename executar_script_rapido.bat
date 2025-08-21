@echo off
echo ========================================
echo  CORRETOR DE ERRO BOM - GRADLE
echo ========================================
echo.
echo Este script vai corrigir o erro de BOM nos arquivos Gradle
echo do seu projeto vello_motorista.
echo.
pause

echo Executando correção...
python remove_bom.py "D:\AndroidStudioProjects\vello_motorista"

echo.
echo ========================================
echo  CORREÇÃO CONCLUÍDA!
echo ========================================
echo.
echo Próximos passos:
echo 1. Abra o Android Studio
echo 2. Build ^> Clean Project
echo 3. Build ^> Rebuild Project
echo.
pause

