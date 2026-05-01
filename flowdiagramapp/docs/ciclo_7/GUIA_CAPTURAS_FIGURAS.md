# Guía de Capturas para Ciclo 7 — Figuras Requeridas

Este documento proporciona instrucciones paso a paso para capturar cada figura necesaria en el documento `ciclo7_resultados_pruebas.md`.

---

## 📋 Resumen de Figuras Requeridas

| Figura | Contenido | Estado |
|--------|-----------|--------|
| **A** | Terminal con `+82: All tests passed!` (compiler) | 📋 Pendiente |
| **1** | Terminal con `+84: All tests passed!` (ciclo7_reports) | ✅ Logs listos |
| **2** | Terminal con desglose de 84 tests por componente | ✅ Logs listos |
| **B** | Editor FlowCode con diagrama Factorial | 📋 Requiere app |
| **C** | CompilerResultsDialog — pestaña Código (Factorial) | 📋 Requiere app |
| **D** | Editor FlowCode con diagrama Búsqueda Lineal | 📋 Requiere app |
| **E** | CompilerResultsDialog — pestaña Semántico (Primo) | 📋 Requiere app |
| **F** | Terminal con compilación GCC sin errores | 📋 Pendiente |
| **G** | Terminal ejecutando binario de Burbuja | 📋 Pendiente |

---

## 🖼️ FIGURA A: Tests del Compilador

### Pasos:

1. Abre VS Code en el proyecto
2. En la terminal, ejecuta:
   ```bash
   flutter test test/compiler/ -v
   ```
3. Espera a que terminen (≈1 minuto)
4. Verás en la salida final:
   ```
   +282: All tests passed!
   ```
5. **Captura:** 
   - Selecciona los últimos 15 líneas que muestren el resumen
   - Usa `Win + Shift + S` para capturar
   - O haz click derecho en la terminal → "Select All" → copiar a archivo

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraA_compiler_tests.png`

---

## 🖼️ FIGURA 1: Tests Ciclo 7 — Resumen Final

### Pasos:

1. Los logs ya están listos en: `logs/ciclo7_TODOS_84_TESTS.txt`
2. Abre la terminal y corre:
   ```bash
   flutter test test/ciclo7_reports/ 2>&1 | tail -20
   ```
3. Deberías ver:
   ```
   +84: All tests passed!
   ```
4. **Captura:**
   - Incluye las líneas que muestren la secuencia de tests finales
   - Debe verse claro el `+84: All tests passed!`

**Ubicación esperada:** `docs/ciclo_7/figuras/Figura1_ciclo7_resumen.png`

---

## 🖼️ FIGURA 2: Tests Ciclo 7 — Desglose por Componente

### Pasos:

1. Corre nuevamente:
   ```bash
   flutter test test/ciclo7_reports/ -v
   ```
2. Mientras se ejecuta, verás líneas como:
   ```
   +01: ...lexical_analyzer_ciclo7_test.dart: LE-01...
   +02: ...lexical_analyzer_ciclo7_test.dart: LE-02...
   ...
   +84: All tests passed!
   ```
3. **Captura:**
   - Toma captura en el medio de la ejecución mostrando varios tests en progreso
   - O captura el final mostrando el resumen de componentes

**Ubicación esperada:** `docs/ciclo_7/figuras/Figura2_ciclo7_desglose.png`

---

## 🖼️ FIGURA B: Diagrama Factorial en Editor

### Pasos:

1. Abre la aplicación FlowCode en el Android Emulator o dispositivo
2. Crea o importa el diagrama del Factorial:
   - Nodo Terminal: "Inicio"
   - Nodo Proceso: "int n, resultado=1, i=1"
   - Nodo Data (entrada): "scanf n"
   - Nodo Preparación: "i=1; i <= n"
   - Nodo Proceso: "resultado = resultado * i"
   - Nodo Proceso: "i = i + 1"
   - Nodo Data (salida): "printf resultado"
   - Nodo Terminal: "Fin"

3. **Captura:**
   - Foto del editor visual mostrando el diagrama completo
   - Debe verse clara la estructura y las conexiones

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraB_editor_factorial.png`

---

## 🖼️ FIGURA C: Código Generado (Factorial)

### Pasos:

1. Convierte el diagrama del Factorial haciendo click en "Compilar"
2. Se abrirá el diálogo `CompilerResultsDialog`
3. Selecciona la pestaña "Código"
4. **Captura:**
   - Foto mostrando el código C generado completo
   - Debe verse todo desde `#include <stdio.h>` hasta `return 0;`

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraC_codigo_factorial.png`

---

## 🖼️ FIGURA D: Diagrama Búsqueda Lineal

### Pasos:

1. En FlowCode, crea el diagrama de búsqueda lineal:
   - Nodo Terminal: "Inicio"
   - Nodo Proceso: "int arr[5], objetivo, encontrado=0"
   - Nodo Data (entrada): "scanf objetivo"
   - Nodo Preparación: "i=0"
   - Nodo Decisión: "i < 5"
   - Nodo Decisión (dentro): "arr[i] == objetivo"
   - Nodo Proceso: "encontrado = 1"
   - Nodo Proceso: "i = i + 1"
   - Nodo Decisión (final): "encontrado == 1"
   - Nodo Data (salida): "printf encontrado"
   - Nodo Terminal: "Fin"

2. **Captura:**
   - Foto del editor visual con todo el diagrama visible

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraD_editor_busqueda.png`

---

## 🖼️ FIGURA E: Tabla de Símbolos (Primo)

### Pasos:

1. Crea o carga el diagrama del verificador de primos en FlowCode
2. Convierte haciendo click en "Compilar"
3. En el diálogo `CompilerResultsDialog`, selecciona la pestaña "Semántico"
4. **Captura:**
   - Foto mostrando la tabla de símbolos con variables `n`, `i`, `esPrimo` y sus tipos

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraE_tabla_simbolos_primo.png`

---

## 🖼️ FIGURA F: Compilación con GCC

### Pasos:

1. Copia el código C generado del Factorial (desde Figura C)
2. En VS Code, crea un archivo `factorial.c` con ese código
3. En la terminal PowerShell, ejecuta:
   ```bash
   gcc factorial.c -o factorial
   ```
4. **Captura:**
   - Foto de la terminal mostrando el comando sin errores
   - Debe verse que se creó el ejecutable sin mensajes de error

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraF_gcc_compilacion.png`

---

## 🖼️ FIGURA G: Ejecución del Binario

### Pasos:

1. En la terminal PowerShell, ejecuta:
   ```bash
   .\factorial
   ```
2. Ingresa un número cuando pida (ej: 5)
3. **Captura:**
   - Foto mostrando la ejecución completa con entrada y salida

**Ubicación esperada:** `docs/ciclo_7/figuras/FiguraG_ejecucion_binario.png`

---

## 📁 Crear Carpeta de Figuras

Antes de empezar, crea la carpeta donde guardarás las imágenes:

```bash
mkdir docs/ciclo_7/figuras
```

---

## 📝 Nomenclatura de Archivos

```
docs/ciclo_7/figuras/
├── FiguraA_compiler_tests.png
├── Figura1_ciclo7_resumen.png
├── Figura2_ciclo7_desglose.png
├── FiguraB_editor_factorial.png
├── FiguraC_codigo_factorial.png
├── FiguraD_editor_busqueda.png
├── FiguraE_tabla_simbolos_primo.png
├── FiguraF_gcc_compilacion.png
└── FiguraG_ejecucion_binario.png
```

---

## ✅ Checklist

- [ ] Figura A: Tests compilador (282)
- [ ] Figura 1: Resumen ciclo 7 (84)
- [ ] Figura 2: Desglose por componente
- [ ] Figura B: Editor factorial
- [ ] Figura C: Código factorial
- [ ] Figura D: Editor búsqueda
- [ ] Figura E: Tabla símbolos primo
- [ ] Figura F: Compilación GCC
- [ ] Figura G: Ejecución binario

---

## 💡 Consejos

1. **Para capturas de VS Code:** Usa `Win + Shift + S` y recorta el área deseada
2. **Para capturas del Android Emulator:** Usa el botón de captura del emulador o `Ctrl + PrintScreen`
3. **Formato:** Guarda todas las imágenes en PNG (mejor compresión)
4. **Resolución:** Asegúrate de que el texto sea legible (mínimo 1280×720)
5. **Nombres descriptivos:** Facilita encontrar y referenciar luego en el documento

---

## 📌 Notas

- Los logs de ejecución ya están guardados en `logs/ciclo7_TODOS_84_TESTS.txt`
- Para las figuras de la aplicación (B, C, D, E) necesitarás tener FlowCode compilada y corriendo
- Las figuras F y G requieren archivos `.c` en la carpeta del proyecto

¡Éxito capturando las figuras! 📸
