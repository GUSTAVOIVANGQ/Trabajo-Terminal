# 📌 CÓMO INSERTAR LAS FIGURAS EN MARKDOWN

Una vez que hayas capturado todas las imágenes PNG, insértalas en `ciclo7_resultados_pruebas.md` usando esta sintaxis.

---

## Sintaxis Markdown para Figuras

```markdown
![Descripción de la figura](ruta/a/imagen.png)

> **[Figura N]** *Descripción de lo que muestra la captura*
```

---

## Ejemplo Completo

Para insertar la Figura A en el documento, busca este comentario:

```markdown
### Ejecución de la Suite de Pruebas del Ciclo 7
```

Y después de la sección "Nivel 1: Ejecución Completa", añade:

```markdown
**Resultado esperado:**
```
+282: All tests passed!
```

![Captura de terminal mostrando 282 tests aprobados](../figuras/FiguraA_compiler_tests.png)

> **[Figura A]** *Captura de pantalla de la terminal mostrando la ejecución completa de los 282 casos de prueba originales con resultado `+282: All tests passed!`. Incluye timestamp de ejecución y tiempo total.*
```

---

## Plantilla para Cada Figura

### Figura A - Tests Compilador
```markdown
![Tests compilador](../figuras/FiguraA_compiler_tests.png)

> **[Figura A]** *Captura de pantalla de la terminal de VS Code mostrando `flutter test test/compiler/` con resultado final `+282: All tests passed!`*
```

### Figura 1 - Ciclo 7 Resumen
```markdown
![Ciclo 7 resumen](../figuras/Figura1_ciclo7_resumen.png)

> **[Figura 1]** *Captura de pantalla de la terminal mostrando la ejecución de los 84 casos de prueba del Ciclo 7 con resultado `+84: All tests passed!` y timestamp de ejecución y tiempo total.*
```

### Figura 2 - Ciclo 7 Desglose
```markdown
![Ciclo 7 desglose](../figuras/Figura2_ciclo7_desglose.png)

> **[Figura 2]** *Captura de pantalla de la terminal mostrando los últimos tests ejecutándose en `test/ciclo7_reports/` con identificadores de test (LE-01 a LE-08, SN-01 a SN-08, etc.)*
```

### Figura B - Editor Factorial
```markdown
![Editor con diagrama factorial](../figuras/FiguraB_editor_factorial.png)

> **[Figura B]** *Captura del editor de FlowCode en el emulador Android mostrando el diagrama completo del Algoritmo 1 (Factorial) con sus nodos y conexiones.*
```

### Figura C - Código Factorial
```markdown
![Código C generado](../figuras/FiguraC_codigo_factorial.png)

> **[Figura C]** *Captura del diálogo CompilerResultsDialog — pestaña "Código" — mostrando el código C del factorial con resaltado de sintaxis.*
```

### Figura D - Editor Búsqueda
```markdown
![Editor con diagrama búsqueda](../figuras/FiguraD_editor_busqueda.png)

> **[Figura D]** *Captura del editor de FlowCode mostrando el diagrama del Algoritmo 2 (Búsqueda lineal) con el nodo de decisión y las ramas condicionales.*
```

### Figura E - Tabla de Símbolos
```markdown
![Tabla de símbolos primo](../figuras/FiguraE_tabla_simbolos_primo.png)

> **[Figura E]** *Captura del diálogo CompilerResultsDialog — pestaña "Semántico" — mostrando la tabla de símbolos con las variables del Algoritmo 3 (Primo) y sus tipos inferidos.*
```

### Figura F - Compilación GCC
```markdown
![Compilación con GCC](../figuras/FiguraF_gcc_compilacion.png)

> **[Figura F]** *Captura de pantalla de la terminal de VS Code mostrando la conversión del código C con GCC (`gcc factorial.c -o factorial`) sin errores ni advertencias.*
```

### Figura G - Ejecución Binario
```markdown
![Ejecución del ejecutable](../figuras/FiguraG_ejecucion_binario.png)

> **[Figura G]** *Captura de pantalla mostrando la compilación con GCC y la ejecución del ejecutable de burbuja (`burbuja.exe`) en la terminal de Windows 11.*
```

---

## Ubicaciones Exactas en el Documento

Busca estos textos en `ciclo7_resultados_pruebas.md` y añade las imágenes después:

| Figura | Buscar este texto | Acción |
|--------|------------------|--------|
| A | `Nivel 1: Ejecución Completa` | Añade después de `+282: All tests passed!` |
| 1 | `Nivel 2: Ejecución Selectiva` | Añade después de `+84: All tests passed!` |
| 2 | `Instrucciones de Ejecución` | Añade antes de `TODOS los 84 casos` |
| B | `Código C generado por FlowCode:` (primer algoritmo) | Añade antes del bloque de código |
| C | Después del código del Factorial | Añade en la sección de "Corrida del ejecutable" |
| D | `Código C generado por FlowCode:` (segundo algoritmo) | Añade antes del bloque de código |
| E | Después del código de Búsqueda | Añade en la sección de "Corrida del ejecutable" |
| F | `Corrida del ejecutable:` (Burbuja) | Añade antes del bloque de salida |
| G | Después de la salida de Burbuja | Última figura al final |

---

## ⚠️ Notas Importantes

1. **Rutas relativas:** Usa `../figuras/nombredelarchivo.png` desde `ciclo_7/` 
2. **Nombres de archivos:** Deben ser exactos, sensibles a mayúsculas
3. **Formato PNG:** Asegúrate de que todas sean PNG, no JPG
4. **Descripción alt:** El texto entre `![]()` es el texto alternativo (importante para accesibilidad)

---

## Ejemplo Completo de Inserción

Para insertar Figura A en la sección correcta:

```markdown
## 22.2 Evidencia de Ejecución de Pruebas

### Cobertura de Pruebas del Ciclo 6

De acuerdo con el Ciclo 6, la suite de validación del conversor está compuesta por un total de **84 casos de prueba** documentados exhaustivamente. Estos casos se distribuyen de la siguiente manera:

| Componente | Tipo | Casos | Estado |
|-----------|------|-------|--------|
| Análisis léxico | Unitaria | 8 | ✅ |
...

### Ejecución de la Suite de Pruebas del Ciclo 7

Para demostrar la validación completa del conversor fuente a fuente, este ciclo ejecuta nuevamente la suite de **84 pruebas** en dos niveles:

#### **Nivel 1: Ejecución Completa (84 casos)**

Se ejecutan todas las pruebas originales del Ciclo 6 ubicadas en `test/compiler/`:

```bash
flutter test test/compiler/ -v
```

**Resultado esperado:**
```
+282: All tests passed!
```

![Captura de terminal con 282 tests aprobados](../figuras/FiguraA_compiler_tests.png)

> **[Figura A]** *Captura de pantalla de la terminal de VS Code mostrando `flutter test test/compiler/` con resultado final `+282: All tests passed!`*
```

---

## ✅ Checklist de Inserción

- [ ] Figura A insertada en "Nivel 1: Ejecución Completa"
- [ ] Figura 1 insertada en "Nivel 2: Ejecución Selectiva"
- [ ] Figura 2 insertada después del desglose por componente
- [ ] Figura B insertada antes del código Factorial
- [ ] Figura C insertada en Corrida del ejecutable Factorial
- [ ] Figura D insertada antes del código Búsqueda
- [ ] Figura E insertada en Corrida del ejecutable Búsqueda
- [ ] Figura F insertada antes de salida Burbuja
- [ ] Figura G insertada después de salida Burbuja

¡Listo! Una vez completes todas las capturas, solo tienes que copiar-pegar estos snippets en los lugares correctos.
