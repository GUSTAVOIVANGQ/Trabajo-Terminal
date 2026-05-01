# CHECKLIST: Ciclo 7 - Pruebas y Figuras

## ✅ Verificación Previa

- [ ] Flutter está instalado y funciona (`flutter --version`)
- [ ] VS Code está abierto en la carpeta del proyecto
- [ ] El emulador o dispositivo físico está disponible (opcional para figuras de app)
- [ ] Tienes acceso a herramienta de captura de pantallas (Win+Shift+S en Windows)

## 📁 Verificar Estructura de Archivos Creados

### Archivos de Test (Ciclo 7)
- [ ] `test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart` (8 casos)
- [ ] `test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart` (8 casos)
- [ ] `test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart` (7 casos)
- [ ] `test/ciclo7_reports/code_generation_ciclo7_test.dart` (10 casos)
- [ ] `test/ciclo7_reports/robustness_ciclo7_test.dart` (10 casos)
- [ ] `test/ciclo7_reports/integration_e2e_ciclo7_test.dart` (12 casos)

### Documentación de Apoyo
- [ ] `docs/ciclo_7/GUIA_FIGURAS_CICLO7.md` (creada)
- [ ] `docs/ciclo_7/RESUMEN_CAMBIOS_PLAN_ACCION.md` (creada)
- [ ] `docs/ciclo_7/ciclo7_resultados_pruebas.md` (actualizada - sección 22.2)
- [ ] `run_ciclo7_tests.bat` (script ejecutable en raíz)

## 🧪 Paso 1: Ejecutar Pruebas

### Opción A: Usando el script (Recomendado)
- [ ] Abre PowerShell o CMD en la carpeta del proyecto
- [ ] Ejecuta: `.\run_ciclo7_tests.bat`
- [ ] Espera a que todas las pruebas completen (~2-3 minutos)
- [ ] Verifica que apareció la carpeta `logs/` con 7 archivos `.txt`

### Opción B: Ejecutar manualmente
- [ ] Abre terminal en VS Code (Ctrl+`)
- [ ] Ejecuta: `flutter test test/ciclo7_reports/ -v`
- [ ] Verifica que aparece: `+57: All tests passed!`

## 📸 Paso 2: Capturar Figuras de Terminal

### Figura 1: Todas las Pruebas (PRINCIPAL)
- [ ] Abre el archivo `logs/ciclo7_ALL_TESTS.txt` en VS Code
- [ ] Selecciona y captura la pantalla (Win+Shift+S)
- [ ] O ejecuta nuevamente: `flutter test test/ciclo7_reports/ -v` y captura
- [ ] Incluye: línea de comando + checkmarks + resumen final
- [ ] Guarda como: `docs/ciclo_7/figuras/figura_1_all_tests.png`

### Figuras 2-7: Por Componente (OPCIONAL)
- [ ] Abre el archivo `logs/ciclo7_LEXICAL_ANALYZER.txt` → captura → `figura_2_lexical.png`
- [ ] Abre el archivo `logs/ciclo7_SYNTAX_ANALYZER.txt` → captura → `figura_3_syntax.png`
- [ ] Abre el archivo `logs/ciclo7_SEMANTIC_ANALYZER.txt` → captura → `figura_4_semantic.png`
- [ ] Abre el archivo `logs/ciclo7_CODE_GENERATION.txt` → captura → `figura_5_codegen.png`
- [ ] Abre el archivo `logs/ciclo7_ROBUSTNESS.txt` → captura → `figura_6_robustness.png`
- [ ] Abre el archivo `logs/ciclo7_INTEGRATION_E2E.txt` → captura → `figura_7_e2e.png`

**Criterios de captura válida:**
- ✅ Texto legible (resolución ≥ 1920x1080 recomendada)
- ✅ Muestra el comando ejecutado
- ✅ Muestra los checkmarks (✓) de tests aprobados
- ✅ Muestra el resumen final (ej: "+57: All tests passed!")
- ✅ Incluye timestamp (hora de ejecución)

## 📱 Paso 3: Capturar Figuras de Aplicación (Opcional pero Recomendado)

### Figura 8: Código C Generado
- [ ] Abre la app en emulador/dispositivo
- [ ] Crea un diagrama simple: Inicio → Variable(int x) → Proceso(x=42) → Fin
- [ ] Haz clic en botón "Convertir"
- [ ] Ve a pestaña "Código C"
- [ ] Captura mostrando código con resaltado de sintaxis
- [ ] Guarda como: `docs/ciclo_7/figuras/figura_8_codigo_generado.png`

### Figura 9: Error Semántico (variable no declarada)
- [ ] Crea diagrama: Inicio → Proceso(resultado = x + y) → Fin
- [ ] Haz clic en "Convertir"
- [ ] Ve a pestaña "Análisis Semántico"
- [ ] Captura mostrando error en rojo indicando variables no declaradas
- [ ] Guarda como: `docs/ciclo_7/figuras/figura_9_error_nodeclarada.png`

### Figura 10: Estructura de Control (opcional)
- [ ] Crea diagrama: Inicio → Variable(int x) → Entrada(Leer x) → Decisión(x>0) → Fin
- [ ] Haz clic en "Convertir"
- [ ] Captura el diagrama y código juntos
- [ ] Guarda como: `docs/ciclo_7/figuras/figura_10_control.png`

## 📝 Paso 4: Insertar Figuras en Documento

- [ ] Crea la carpeta `docs/ciclo_7/figuras/` si no existe
- [ ] Coloca todas las imágenes PNG ahí
- [ ] Abre `docs/ciclo_7/ciclo7_resultados_pruebas.md`
- [ ] Reemplaza los placeholders `(Insertar captura de...)` con:
  ```markdown
  ![Figura 1: Descripción](figuras/figura_1_all_tests.png)
  ```
- [ ] Reemplaza los pies con texto de `GUIA_FIGURAS_CICLO7.md`

## 🔍 Paso 5: Verificar Calidad de Contenido

### Verificar pies de figura
- [ ] NO usan palabras: "aprendizaje", "comprensión", "aprender", "comprender"
- [ ] Usan "conversor" o "conversor fuente a fuente" (NO "compilador")
- [ ] Cada pie describe QUÉ se valida y POR QUÉ importa
- [ ] Los pies tienen entre 2-4 líneas (concisos pero descriptivos)

### Verificar explicaciones en 22.2
- [ ] Menciona los 57 casos (8+8+7+10+10+12)
- [ ] Explica que es un subconjunto de los 82 casos del Ciclo 6
- [ ] Proporciona comandos listos para copiar/pegar
- [ ] Todas las figuras referenciadas están insertadas

## 📊 Paso 6: Validación Final

- [ ] El documento compila sin errores Markdown
- [ ] Todas las imágenes se cargan correctamente (sin errores de ruta)
- [ ] Los pies de figura tienen numeración consistente (Figura X)
- [ ] Las referencias cruzadas funcionan (ej: "ver Figura 3")
- [ ] El documento sigue el mismo formato que el Ciclo 6

## 🎯 Resumen de Entregables

| Componente | Estado | Archivo/Ubicación |
|-----------|--------|-------------------|
| Test Análisis Léxico | ✅ Creado | `test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart` |
| Test Análisis Sintáctico | ✅ Creado | `test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart` |
| Test Análisis Semántico | ✅ Creado | `test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart` |
| Test Generación de Código | ✅ Creado | `test/ciclo7_reports/code_generation_ciclo7_test.dart` |
| Test Robustez | ✅ Creado | `test/ciclo7_reports/robustness_ciclo7_test.dart` |
| Test Integración E2E | ✅ Creado | `test/ciclo7_reports/integration_e2e_ciclo7_test.dart` |
| Guía de Figuras | ✅ Creada | `docs/ciclo_7/GUIA_FIGURAS_CICLO7.md` |
| Plan de Acción | ✅ Creado | `docs/ciclo_7/RESUMEN_CAMBIOS_PLAN_ACCION.md` |
| Script ejecutable | ✅ Creado | `run_ciclo7_tests.bat` |
| Documento actualizado | ✅ Actualizado | `docs/ciclo_7/ciclo7_resultados_pruebas.md` (sec 22.2) |

## ⏱️ Tiempo Estimado

| Tarea | Tiempo |
|-------|--------|
| Ejecutar pruebas | 1-2 min |
| Capturar figura 1 (terminal) | 2 min |
| Capturar figuras 2-7 (opcional) | 10 min |
| Capturar figuras 8-10 (app) | 5 min |
| Insertar figuras en documento | 10 min |
| Revisión final | 5 min |
| **TOTAL** | **~30-40 min** |

## 🚀 Lista de Verificación Final

- [ ] Todos los tests ejecutados exitosamente (57/57 aprobados)
- [ ] Todas las figuras capturadas (mínimo: Figura 1)
- [ ] Todas las figuras insertadas en el documento
- [ ] Todos los pies de figura redactados correctamente
- [ ] Documento sin errores Markdown
- [ ] Carpeta `docs/ciclo_7/figuras/` creada y poblada
- [ ] Carpeta `test/ciclo7_reports/` con 6 archivos de test
- [ ] No hay referencias pendientes (placeholders reemplazados)
- [ ] Lenguaje consistente (conversor, NO compilador)
- [ ] Documento listo para presentación

## 💡 Notas Adicionales

- Los tests son independientes y pueden ejecutarse en cualquier orden
- Si un test falla, revisa el archivo de log correspondiente para detalles
- Las capturas pueden ser redimensionadas después, pero mejor a máxima resolución
- Puedes usar herramientas como Snagit, ShareX o el capturador nativo de Windows
- Si necesitas re-ejecutar, solo necesita volver a capturar las figuras (tests tardan <1 min)

---

**¿LISTO?** Comienza por el Paso 1 con el script `run_ciclo7_tests.bat`. 
Aproximadamente en 30 minutos tendrás tu reporte completamente documentado.

