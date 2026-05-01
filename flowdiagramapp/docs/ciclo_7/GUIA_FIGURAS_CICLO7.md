## Anexo: Guía de Figuras para el Ciclo 7

Este documento enumera todas las figuras sugeridas para evidenciar los resultados de las pruebas del Ciclo 7. Para cada figura se proporciona:
1. ID de la figura
2. Descripción de qué capturar
3. Instrucción para ejecutar las pruebas
4. Pie de figura sugerido

---

## GRUPO 1: Análisis Léxico

### Figura 1: Ejecución de Pruebas del Análisis Léxico

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 8 casos de prueba del análisis léxico.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos LE-01 a LE-08 con ✓ (checkmark) indicando aprobación
- Tiempo total de ejecución
- Mensaje final: "X tests passed"

**Pie de figura sugerido:**
> Figura X. Ejecución de los 8 casos de prueba del análisis léxico. Se valida la tokenización correcta de identificadores, literales (enteros y flotantes), palabras clave, operadores aritméticos/relacionales, delimitadores y expresiones complejas. (Captura de terminal con salida de `flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v`)

---

## GRUPO 2: Análisis Sintáctico

### Figura 2: Ejecución de Pruebas del Análisis Sintáctico

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 8 casos de prueba del análisis sintáctico y construcción del AST.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos SN-01 a SN-08 con ✓ indicando aprobación
- Validación de nodos del AST (IntegerLiteral, FloatLiteral, Identifier, BinaryExpression, etc.)
- Validación de jerarquía del árbol sintáctico
- Tiempo total de ejecución

**Pie de figura sugerido:**
> Figura X. Ejecución de los 8 casos de prueba del análisis sintáctico. Se valida la creación correcta de nodos del árbol sintáctico abstracto (AST), incluyendo literales, identificadores, expresiones binarias, asignaciones y declaraciones de variables. (Captura de terminal con salida de `flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v`)

---

## GRUPO 3: Análisis Semántico

### Figura 3: Ejecución de Pruebas del Análisis Semántico

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 7 casos de prueba del análisis semántico.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos SE-01 a SE-07 con ✓ indicando aprobación
- Detección de variables no declaradas (SE-01)
- Detección de declaraciones duplicadas (SE-02)
- Validación de compatibilidad de tipos (SE-03)
- Detección de variables no utilizadas (SE-04)
- Advertencias de división por cero (SE-05)
- Validación de tabla de símbolos (SE-06)
- Análisis de múltiples tipos (SE-07)
- Tiempo total de ejecución

**Pie de figura sugerido:**
> Figura X. Ejecución de los 7 casos de prueba del análisis semántico. Se valida la correcta detección de variables no declaradas, declaraciones duplicadas, compatibilidad de tipos, variables no utilizadas, advertencias de operaciones peligrosas (división por cero) y la propagación de información a través de la tabla de símbolos. (Captura de terminal con salida de `flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v`)

---

## GRUPO 4: Generación de Código

### Figura 4: Ejecución de Pruebas de Generación de Código

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 10 casos de prueba de generación de código en C.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos GC-01 a GC-10 con ✓ indicando aprobación
- Validación de estructura `int main()`
- Inclusión de `#include <stdio.h>`
- Generación de declaraciones (GC-03)
- Generación de `scanf` (GC-04)
- Generación de `printf` (GC-05)
- Generación de estructuras `if` (GC-06)
- Generación de bucles `while`/`for` (GC-07)
- Validación de indentación (GC-08)
- Validación de operadores aritméticos (GC-09)
- Validación de sintaxis C (GC-10)
- Tiempo total de ejecución

**Pie de figura sugerido:**
> Figura X. Ejecución de los 10 casos de prueba de generación de código C. Se valida la traducción correcta de estructuras del diagrama de flujo a código C válido: función main(), inclusión de headers, declaraciones de variables, operaciones de entrada/salida (scanf/printf), estructuras de control (if/else, while/for), operadores aritméticos y validación de sintaxis C correcta según el estándar C99. (Captura de terminal con salida de `flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v`)

---

## GRUPO 5: Pruebas de Robustez

### Figura 5: Ejecución de Pruebas de Robustez

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 10 casos de prueba de robustez y manejo de errores.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/robustness_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos RB-01 a RB-10 con ✓ indicando aprobación
- Manejo de errores léxicos sin fallo (RB-01)
- Detección de errores sintácticos (RB-02)
- Detección de variables no declaradas (RB-03)
- Detección de declaraciones duplicadas (RB-04)
- Advertencias de división por cero (RB-05)
- Advertencias de tipos incompatibles (RB-06)
- Advertencias de variables no utilizadas (RB-07)
- Validación de diagrama sin nodo Inicio (RB-08)
- Validación de diagrama sin nodo Fin (RB-09)
- Validación de nodos desconectados (RB-10)
- Tiempo total de ejecución

**Pie de figura sugerido:**
> Figura X. Ejecución de los 10 casos de prueba de robustez del conversor. Se valida que el sistema maneja correctamente entradas inválidas (léxicas, sintácticas y semánticas) sin fallos de la aplicación, genera errores y advertencias descriptivos, y valida la estructura del diagrama (presencia de nodos terminales, conectividad). (Captura de terminal con salida de `flutter test test/ciclo7_reports/robustness_ciclo7_test.dart -v`)

---

## GRUPO 6: Integración Extremo a Extremo

### Figura 6: Ejecución de Pruebas de Integración E2E

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución exitosa de los 12 casos de prueba de integración extremo a extremo.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v
```

**Observar en la terminal:**
- Casos E2E-01 a E2E-12 con ✓ indicando aprobación
- Compilación de diagrama mínimo (E2E-01)
- Compilación con variables (E2E-02)
- Compilación con procesos (E2E-03)
- Compilación con entrada (E2E-04)
- Compilación con salida (E2E-05)
- Compilación con decisiones (E2E-06)
- Compilación con iteraciones (E2E-07)
- Compilación con múltiples variables (E2E-08)
- Compilación con expresiones aritméticas (E2E-09)
- Compilación con estructuras de control (E2E-10)
- Ejecución de las 5 fases (E2E-11)
- Validación de sintaxis C (E2E-12)
- Tiempo total de ejecución

**Pie de figura sugerido:**
> Figura X. Ejecución de los 12 casos de prueba de integración extremo a extremo. Se valida el flujo completo del conversor desde la entrada de diagrama de flujo hasta la producción de código C compilable, incluyendo los seis tipos de nodos ISO 5807 (terminal, variable, proceso, entrada/salida, decisión, iteración), múltiples variables, expresiones aritméticas y estructuras de control complejas. (Captura de terminal con salida de `flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v`)

---

## GRUPO 7: Ejecución Completa de la Suite de Pruebas

### Figura 7: Ejecución de Todas las Pruebas del Ciclo 7

**Qué capturar:** Captura de pantalla de la terminal mostrando la ejecución de TODOS los archivos de prueba en una sola ejecución.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/ -v
```

**Observar en la terminal:**
- Resumen total de pruebas ejecutadas (suma de todas las pruebas)
- Todos los casos con ✓ indicando aprobación
- Tiempo total de ejecución (debería estar dentro de RNF03: < 10 000 ms para diagramas complejos)
- Mensaje final: "X tests passed" donde X es aproximadamente 47-57 (todos los casos)

**Pie de figura sugerido:**
> Figura X. Ejecución completa de la suite de pruebas del Ciclo 7 (57 casos en total). Se valida el conversor fuente a fuente en sus cinco fases (análisis léxico, sintáctico, semántico, optimización y generación de código), con pruebas de integración extremo a extremo y validación de robustez. Los tiempos de ejecución demuestran cumplimiento con los criterios de rendimiento establecidos. (Captura de terminal con salida de `flutter test test/ciclo7_reports/ -v`)

---

## GRUPO 8: Métricas de Rendimiento (Opcional)

### Figura 8: Métricas de Rendimiento del Conversor

**Qué capturar (OPCIONAL):** Si deseas medir rendimiento, ejecuta una conversión simple y captura el tiempo.

**Cómo ejecutar:**
```bash
flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart --tags="E2E-01" -v
```

O desde la aplicación móvil: captura de pantalla mostrando el tiempo de conversión en el diálogo de resultados.

**Pie de figura sugerido:**
> Figura X. Métricas de rendimiento del conversor para diagrama mínimo. El tiempo de conversión se encuentra dentro del umbral establecido en RNF03 (< 1 000 ms para diagramas simples). (Captura de terminal u aplicación móvil mostrando tiempo de ejecución)

---

## GRUPO 9: Código C Generado (Evidencia Cualitativa)

### Figura 9: Ejemplo de Código C Generado

**Qué capturar:** Una captura que muestre el código C generado por el conversor (desde la aplicación móvil en el diálogo de resultados).

**Observar:**
- Presencia de `#include <stdio.h>`
- Función `int main()`
- Declaraciones de variables
- Operaciones de entrada/salida
- Estructuras de control (if/while)
- `return 0;` al final
- Indentación consistente con 2 espacios

**Cómo capturar:**
1. Abre la aplicación en Android
2. Crea un diagrama simple (Inicio -> Variable -> Proceso -> Fin)
3. Haz clic en "Convertir"
4. En el diálogo de resultados, ve a la pestaña "Código C"
5. Captura la pantalla mostrando el código completo

**Pie de figura sugerido:**
> Figura X. Ejemplo de código C generado por el conversor para un diagrama de flujo simple. El código incluye todos los elementos requeridos: header de entrada/salida, función main, declaraciones de variables, y estructura de control válida según el estándar C99. (Captura de la aplicación móvil mostrando el diálogo de resultados en la pestaña "Código C")

---

## GRUPO 10: Validación de Errores (Evidencia Cualitativa)

### Figura 10: Detección de Error en Variable No Declarada

**Qué capturar:** Captura mostrando el sistema detectando y reportando un error semántico.

**Cómo capturar:**
1. Abre la aplicación
2. Crea un diagrama: Inicio -> Proceso (con "x = y + 5" donde 'y' no está declarada) -> Fin
3. Haz clic en "Convertir"
4. Captura el diálogo de resultados mostrando el error rojo en la pestaña "Análisis Semántico"

**Pie de figura sugerido:**
> Figura X. Detección de variable no declarada por el análisis semántico. El sistema reporta error fatal (en rojo) indicando que la variable 'y' no fue declarada antes de ser utilizada en la expresión. (Captura de la aplicación móvil mostrando el diálogo de error)

---

## Resumen: Orden de Captura Recomendado

Para completar el reporte de forma eficiente:

1. **Primero:** Ejecuta todas las pruebas en paralelo (Figura 7)
   ```bash
   flutter test test/ciclo7_reports/ -v > ciclo7_tests_output.txt
   ```

2. **Luego:** Captura las figuras individuales por grupo (Figuras 1-6) si necesitas detalles específicos

3. **Finalmente:** Captura evidencia de la aplicación móvil (Figuras 9-10)

4. **Tiempo total esperado:** 
   - Pruebas automatizadas: 30-60 segundos
   - Capturas de aplicación: 5-10 minutos
   - **Total: ~15-20 minutos**

---

## Notas Importantes

- **Resolución mínima para capturas:** 1920x1080 para texto legible
- **Formato:** PNG o JPEG a máxima calidad
- **Nombres de archivo:** `figura_X_descripcion.png`
- **Ubicación:** Guardar en `docs/ciclo_7/figuras/`
- **Insertar en documento:** Usar sintaxis Markdown:
  ```markdown
  ![Figura X: Descripción](figuras/figura_X_descripcion.png)
  ```

