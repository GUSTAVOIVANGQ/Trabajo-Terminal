@echo off
REM Script para ejecutar TODAS las pruebas del Ciclo 7 de FlowCode
REM Trabajo Terminal 2026-A038
REM
REM Este script ejecuta los 84 casos de prueba documentados en el Ciclo 6:
REM   - 8 casos: Análisis léxico
REM   - 8 casos: Análisis sintáctico
REM   - 7 casos: Análisis semántico
REM   - 10 casos: Optimización y generación de código
REM   - 33 casos: Integración extremo a extremo
REM   - 6 casos: Verificación de estructura del código generado
REM   - 12 casos: Almacenamiento local y nube (manuales/Firebase)
REM   TOTAL: 84 casos
REM
REM NOTA: Los 57 casos selectivos se encuentran en test/ciclo7_reports/

echo.
echo ============================================================
echo   CICLO 7: SUITE COMPLETA DE 84 PRUEBAS - FlowCode
echo   Trabajo Terminal 2026-A038
echo ============================================================
echo.

cd /d "%~dp0"

echo Creando directorio de logs si no existe...
if not exist "logs" mkdir logs

echo.
echo ============================================================
echo   [PRINCIPAL] Ejecutando TODOS los 84 casos de prueba...
echo   Ubicación: test/compiler/
echo ============================================================
flutter test test/compiler/ -v > logs\ciclo7_TODOS_84_TESTS.txt 2>&1
echo ✓ Completado. Salida guardada en: logs\ciclo7_TODOS_84_TESTS.txt
echo   (Abre este archivo para capturar Figura 1)
timeout /t 3 /nobreak

echo.
echo ============================================================
echo   [OPCIONAL] Ejecutando pruebas selectivas por componente...
echo ============================================================
echo.
echo [2/6] Análisis Léxico (8 casos)...
flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v > logs\ciclo7_LEXICAL_ANALYZER.txt 2>&1
echo ✓ Completado. logs\ciclo7_LEXICAL_ANALYZER.txt
timeout /t 1 /nobreak

echo.
echo [3/6] Análisis Sintáctico (8 casos)...
flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v > logs\ciclo7_SYNTAX_ANALYZER.txt 2>&1
echo ✓ Completado. logs\ciclo7_SYNTAX_ANALYZER.txt
timeout /t 1 /nobreak

echo.
echo [4/6] Análisis Semántico (7 casos)...
flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v > logs\ciclo7_SEMANTIC_ANALYZER.txt 2>&1
echo ✓ Completado. logs\ciclo7_SEMANTIC_ANALYZER.txt
timeout /t 1 /nobreak

echo.
echo [5/6] Generación de Código (10 casos)...
flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v > logs\ciclo7_CODE_GENERATION.txt 2>&1
echo ✓ Completado. logs\ciclo7_CODE_GENERATION.txt
timeout /t 1 /nobreak

echo.
echo [6/6] Integración E2E + Robustez (22 casos)...
flutter test test/ciclo7_reports/robustness_ciclo7_test.dart test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v > logs\ciclo7_INTEGRATION_ROBUSTNESS.txt 2>&1
echo ✓ Completado. logs\ciclo7_INTEGRATION_ROBUSTNESS.txt
timeout /t 1 /nobreak

echo.
echo ============================================================
echo   EJECUCIÓN COMPLETADA ✓
echo ============================================================
echo.
echo RESUMEN DE ARCHIVOS GENERADOS:
echo.
echo PRINCIPAL (para Figura 1 - OBLIGATORIO):
echo   ✓ ciclo7_TODOS_84_TESTS.txt
echo     → Muestra TODOS los 84 casos documentados en Ciclo 6
echo     → Sección: test/compiler/ (pruebas originales completas)
echo.
echo COMPLEMENTARIOS (opcionales - para detalle):
echo   ✓ ciclo7_LEXICAL_ANALYZER.txt (8 casos selectivos)
echo   ✓ ciclo7_SYNTAX_ANALYZER.txt (8 casos selectivos)
echo   ✓ ciclo7_SEMANTIC_ANALYZER.txt (7 casos selectivos)
echo   ✓ ciclo7_CODE_GENERATION.txt (10 casos selectivos)
echo   ✓ ciclo7_INTEGRATION_ROBUSTNESS.txt (22 casos selectivos)
echo.
echo PRÓXIMOS PASOS:
echo   1. [OBLIGATORIO] Abre: ciclo7_TODOS_84_TESTS.txt
echo   2. Captura pantalla mostrando "+84: All tests passed!"
echo   3. Guarda en: docs\ciclo_7\figuras\figura_1_todos_84_tests.png
echo   4. Inserta en ciclo7_resultados_pruebas.md (sección 22.2)
echo.
pause
