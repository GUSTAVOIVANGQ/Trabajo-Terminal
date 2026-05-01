# Guía de Captura de Figuras - Ciclo 7

## Visión General

El Ciclo 7 documenta la evidencia de ejecución de **84 casos de prueba** del Ciclo 6, distribuidos en:
- **Figura 1 (OBLIGATORIA):** TODOS los 84 casos ejecutados desde `test/compiler/`
- **Figuras 2-8 (OPCIONALES):** 57 casos selectivos desglosados por componente

---

## Figura 1: EVIDENCIA PRINCIPAL - Todos los 84 Casos ⭐ **OBLIGATORIA**

### Propósito
Demostrar la ejecución exitosa de la TOTALIDAD de casos de prueba documentados en el Ciclo 6.

### Qué Capturar
Ejecución completa de `flutter test test/compiler/ -v` mostrando el resultado final: `+84: All tests passed!`

### Comando a Ejecutar
```bash
# Opción A: Usar el script (más cómodo)
.\run_ciclo7_tests.bat

# Opción B: Ejecución manual
flutter test test/compiler/ -v
```

### Dónde Aparece la Evidencia
- **Consola/Terminal:** Muestra `+84: All tests passed!` al final
- **Archivo de log:** `logs/ciclo7_TODOS_84_TESTS.txt` (generado automáticamente)

### Qué Mostrar en la Captura
1. Línea de comando ejecutada
2. Progreso de ejecución (pueden verse el `+` de tests aprobados)
3. **Línea final: `+84: All tests passed!`** (esto es lo más importante)
4. Timestamp y duración total (p.ej., "00:45 +84...")

### Pie de Figura Recomendado
```
Figura 1. Ejecución completa de la suite de pruebas del Ciclo 6: 84 casos totales
ejecutados mediante 'flutter test test/compiler/ -v'. La salida muestra "+84: All tests 
passed!" confirmando que el 100% de casos pasan satisfactoriamente, validando las cinco 
fases del conversor fuente a fuente (análisis léxico, sintáctico, semántico, 
optimización y generación de código C99).

(Insertar captura de: logs/ciclo7_TODOS_84_TESTS.txt o terminal mostrando "+84: All tests passed!")
```

### Pasos Detallados
1. Abre PowerShell / CMD en la raíz del proyecto
2. Ejecuta: `.\run_ciclo7_tests.bat` (o manualmente `flutter test test/compiler/ -v`)
3. Espera a que termine (normalmente 45-60 segundos)
4. Cuando veas `+84: All tests passed!`, captura la pantalla (Print Screen)
5. Abre Paint, GIMP o Snagit y pega la captura
6. Guarda como: `docs/ciclo_7/figuras/Figura_01_TODOS_84_TESTS.png`
7. Inserta en ciclo7_resultados_pruebas.md sección 22.2

---

## Figuras 2-8: Desglose Selectivo por Componente (Opcional)

Estas figuras son **complementarias** y utilizan los 57 casos selectivos de `test/ciclo7_reports/`. Úsalas si deseas mostrar resultados por fase individual.

### Figura 2: Análisis Léxico (8 casos)

**Propósito:** Validar tokenización y reconocimiento de elementos sintácticos básicos.

**Comando:**
```bash
flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v
```

**Resultado esperado:** `+8: All tests passed!`

**Pie de Figura:**
```
Figura 2. Ejecución de pruebas de análisis léxico: 8 casos selectivos validando 
tokenización de identificadores, literales, palabras clave, operadores y delimitadores.
(Insertar captura de terminal mostrando "+8: All tests passed!")
```

---

### Figura 3: Análisis Sintáctico (8 casos)

**Propósito:** Validar construcción del árbol de sintaxis abstracta (AST).

**Comando:**
```bash
flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v
```

**Resultado esperado:** `+8: All tests passed!`

**Pie de Figura:**
```
Figura 3. Ejecución de pruebas de análisis sintáctico: 8 casos selectivos validando 
construcción del AST, precedencia de operadores, declaraciones de variables y 
sentencias asignación.
(Insertar captura de terminal mostrando "+8: All tests passed!")
```

---

### Figura 4: Análisis Semántico (7 casos)

**Propósito:** Validar tabla de símbolos, compatibilidad de tipos y errores semánticos.

**Comando:**
```bash
flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v
```

**Resultado esperado:** `+7: All tests passed!`

**Pie de Figura:**
```
Figura 4. Ejecución de pruebas de análisis semántico: 7 casos selectivos validando 
tabla de símbolos, inferencia de tipos, detección de variables no declaradas y 
compatibilidad de tipos entre asignaciones.
(Insertar captura de terminal mostrando "+7: All tests passed!")
```

---

### Figura 5: Generación de Código (10 casos)

**Propósito:** Validar correctitud del código C99 generado.

**Comando:**
```bash
flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v
```

**Resultado esperado:** `+10: All tests passed!`

**Pie de Figura:**
```
Figura 5. Ejecución de pruebas de generación de código: 10 casos selectivos validando 
generación correcta de código C99, incluyendo declaración de main(), inclusión de 
headers, variables, scanf/printf, estructuras de control y formato adecuado.
(Insertar captura de terminal mostrando "+10: All tests passed!")
```

---

### Figura 6: Robustez y Manejo de Errores (10 casos)

**Propósito:** Validar manejo graceful de errores y diagrama inválido.

**Comando:**
```bash
flutter test test/ciclo7_reports/robustness_ciclo7_test.dart -v
```

**Resultado esperado:** `+10: All tests passed!`

**Pie de Figura:**
```
Figura 6. Ejecución de pruebas de robustez: 10 casos selectivos validando manejo 
correcto de errores léxicos, sintácticos, semánticos, y casos de diagrama inválido 
como nodos desconectados o falta de nodos terminales.
(Insertar captura de terminal mostrando "+10: All tests passed!")
```

---

### Figura 7: Integración Extremo a Extremo (12 casos)

**Propósito:** Validar pipeline completo desde diagrama a código C compilable.

**Comando:**
```bash
flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v
```

**Resultado esperado:** `+12: All tests passed!`

**Pie de Figura:**
```
Figura 7. Ejecución de pruebas de integración E2E: 12 casos selectivos validando 
pipeline completo del conversor: diagram → tokens → AST → tabla de símbolos → código 
generado, cubriendo diagramas mínimos, variables, procesos, entrada/salida, decisiones 
y bucles.
(Insertar captura de terminal mostrando "+12: All tests passed!")
```

---

## Tabla de Distribución de Figuras Recomendada

| Figura | Contenido | Tipo | Casos | Prioridad | Comando |
|--------|-----------|------|-------|-----------|---------|
| **1** | **TODOS los 84 casos** | Nivel principal | **84** | ⭐ **OBLIGATORIA** | `flutter test test/compiler/ -v` |
| 2 | Análisis léxico | Componente | 8 | Opcional | `flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v` |
| 3 | Análisis sintáctico | Componente | 8 | Opcional | `flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v` |
| 4 | Análisis semántico | Componente | 7 | Opcional | `flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v` |
| 5 | Generación de código | Componente | 10 | Opcional | `flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v` |
| 6 | Robustez | Componente | 10 | Opcional | `flutter test test/ciclo7_reports/robustness_ciclo7_test.dart -v` |
| 7 | Integración E2E | Componente | 12 | Opcional | `flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v` |

---

## Flujo Recomendado de Captura

### Mínimo (15 minutos)
1. ✅ Ejecuta `.\run_ciclo7_tests.bat`
2. ✅ Espera a que aparezca `+84: All tests passed!`
3. ✅ Captura Figura 1
4. ✅ Inserta en documento

### Completo (45 minutos)
1. ✅ Figuras 1-7 (ejecuta todas y captura)
2. ✅ Inserta en documento en sección 22.2
3. ✅ Revisa alineación y legibilidad

---

## Validación Final

Antes de considerar completa la evidencia, verifica:

- [ ] Figura 1 muestra `+84: All tests passed!` ← **CRÍTICO**
- [ ] Todas las figuras tienen pies descriptivos
- [ ] Los pies mencionan el número de casos y tipo de validación
- [ ] Las capturas se ven claras (fuente legible, no pixeladas)
- [ ] Las figuras están insertadas en ciclo7_resultados_pruebas.md sección 22.2

---

## Notas Importantes

1. **Figura 1 es obligatoria:** Sin ella, la evidencia está incompleta. Las figuras 2-7 son complementarias.
2. **84 vs 57:** Figura 1 muestra TODOS los 84 casos. Figuras 2-7 muestran 57 casos selectivos (desglose por componente).
3. **Tiempo de ejecución:** Figura 1 tarda ~45-60 segundos. Figuras 2-7 cada una ~10-15 segundos.
4. **Script automatizado:** `run_ciclo7_tests.bat` genera automáticamente los logs y también ejecuta las 6 pruebas selectivas. Puedes capturar desde los archivos de log en la carpeta `logs/`.
5. **Ubicación de logs:** Después de ejecutar el script, todos los archivos están en `logs/` para referencia y reutilización.
