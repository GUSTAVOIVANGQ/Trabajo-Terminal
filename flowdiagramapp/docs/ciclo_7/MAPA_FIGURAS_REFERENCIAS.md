# Mapa de Referencias: Dónde Va Cada Figura

## Estructura del Documento ciclo7_resultados_pruebas.md

Este documento muestra exactamente **dónde insertar cada figura** en el documento de resultados del Ciclo 7.

---

## **FIGURA 1 ⭐ OBLIGATORIA**

### Ubicación en el documento
**Sección 22.2** - Evidencia de Ejecución de Pruebas  
**Después de la tabla:** "Cobertura de Pruebas del Ciclo 6"  
**Línea exacta:** Después de "**Evidencia:** [Figura 1] - Captura de terminal..."

### Qué insertar
**Captura de terminal mostrando:**
```
+84: All tests passed!
```

### Comando que genera esta evidencia
```bash
flutter test test/compiler/ -v
# O usar el script: .\run_ciclo7_tests.bat
```

### Archivo de referencia
`logs/ciclo7_TODOS_84_TESTS.txt`

### Cómo capturar
1. Abre PowerShell en la raíz del proyecto
2. Ejecuta: `flutter test test/compiler/ -v`
3. Espera ~60 segundos hasta ver `+84: All tests passed!`
4. Press Print Screen para capturar
5. Guarda como PNG/JPG

---

## **FIGURAS 2-7 (Opcionales)**

### Ubicación en el documento
**Sección 22.2** - Evidencia de Ejecución de Pruebas  
**Subsección:** "Distribución de los 57 casos selectivos" → "Evidencia: [Figuras 2-7]"

### Tabla de referencia rápida

| Figura | Componente | Comando | Ubicación | Casos |
|--------|-----------|---------|-----------|-------|
| **2** | Análisis Léxico | `flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v` | Después de distribución 57 casos | 8 |
| **3** | Análisis Sintáctico | `flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart -v` | Sección de desglose opcional | 8 |
| **4** | Análisis Semántico | `flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart -v` | Sección de desglose opcional | 7 |
| **5** | Generación de Código | `flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v` | Sección de desglose opcional | 10 |
| **6** | Robustez | `flutter test test/ciclo7_reports/robustness_ciclo7_test.dart -v` | Sección de desglose opcional | 10 |
| **7** | Integración E2E | `flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart -v` | Sección de desglose opcional | 12 |

---

## **Figuras de Código Generado: C, D, E, etc.**

### Ubicación en el documento
**Sección 22.4** - Casos de Uso Reales  
**Para cada algoritmo:** Antes del código C generado

### Estructura de figuras

| Figura | Algoritmo | Ubicación | Qué mostrar |
|--------|-----------|-----------|------------|
| **B** | Factorial (Algoritmo 1) | Antes de "Código C generado" | Captura del diagrama en FlowCode |
| **C** | Factorial (Algoritmo 1) | Después del código C | Captura del código en dialog CompilerResults (pestaña "Código") |
| **D** | Búsqueda Lineal (Algoritmo 2) | Antes de "Código C generado" | Captura del diagrama |
| **E** | Búsqueda Lineal (Algoritmo 2) | Después del código C | Captura del código en dialog |
| **F** | [Algoritmo 3] | Antes de "Código C generado" | Captura del diagrama |
| **G** | [Algoritmo 3] | Después del código C | Captura del código |
| **H** | [Algoritmo 4] | Antes de "Código C generado" | Captura del diagrama |
| **J** | [Algoritmo 4] | Después del código C | Captura del código |

---

## **Resumen Visual: Flujo de Figuras**

```
Sección 22.1 (Criterios)
├── Tabla CF-01 a CF-07 (Corrección Funcional)
│   └─ Evidencia: [Figuras 3-6] ← Pruebas por componente
│
├── Tabla CG-01 a CG-05 (Calidad de Código)
│   └─ Evidencia: [Figuras 5-6] + [Figuras C-J] ← Código generado
│
├── Tabla CR-01 a CR-04 (Rendimiento)
│   └─ Evidencia: [Figuras 7-8] ← Pruebas E2E con timestamps
│
└── Tabla RB-01 a RB-07 (Robustez)
    └─ Evidencia: [Figura 6] ← Pruebas de robustez

Sección 22.2 (Ejecución)
├── Tabla: Cobertura de Pruebas (84 casos)
│   └─ Evidencia: [Figura 1] ← +84: All tests passed!
│
├── Tabla: 57 casos selectivos distribuidos
│   └─ Evidencia: [Figuras 2-7] ← Desglose por componente
│
└── Tabla: Calidad de Código Generado
    └─ Evidencia: [Figura 5] + [Figuras C-J] ← Estructura y formato

Sección 22.3 (Resultados)
├── Tabla: Corrección Funcional (84 casos)
│   └─ Evidencia: [Figura 1] ← +84: All tests passed!
│
└── Tabla: Calidad de Código Generado
    └─ Evidencia: [Figura 5] ← Validación estructura/indentación

Sección 22.4 (Casos de Uso)
├── Algoritmo 1: Factorial
│   ├─ Evidencia: [Figura B] ← Diagrama en FlowCode
│   └─ Evidencia: [Figura C] ← Código C en CompilerResults dialog
│
├── Algoritmo 2: Búsqueda Lineal
│   ├─ Evidencia: [Figura D] ← Diagrama en FlowCode
│   └─ Evidencia: [Figura E] ← Código C en CompilerResults dialog
│
├── Algoritmo 3: [TBD]
│   ├─ Evidencia: [Figura F] ← Diagrama
│   └─ Evidencia: [Figura G] ← Código C
│
└── Algoritmo 4: [TBD]
    ├─ Evidencia: [Figura H] ← Diagrama
    └─ Evidencia: [Figura J] ← Código C
```

---

## **Orden de Captura Recomendado**

### Paso 1: Figuras de Terminal (5-10 min)
- [ ] Ejecuta: `.\run_ciclo7_tests.bat`
- [ ] Captura Figura 1 (cuando aparezca `+84: All tests passed!`)
- [ ] El script automáticamente genera logs para Figuras 2-7

### Paso 2: Figuras de Diagrama y Código (15-20 min)
- [ ] Abre FlowCode (app móvil)
- [ ] Crea/carga cada algoritmo
- [ ] Captura Figuras B, D, F, H (diagramas)
- [ ] Genera código y captura el dialog CompilerResults
- [ ] Captura Figuras C, E, G, J (código generado)

### Paso 3: Inserta en Documento (5-10 min)
- [ ] Copia imágenes a: `docs/ciclo_7/figuras/`
- [ ] Inserta en ciclo7_resultados_pruebas.md en las ubicaciones indicadas
- [ ] Verifica que pies de figura sean claros

**Tiempo total: 25-40 minutos**

---

## **Checklist de Inserción**

### Sección 22.2 (Ejecución)
- [ ] Figura 1: Después de "Cobertura de Pruebas del Ciclo 6" (OBLIGATORIA)
- [ ] Figuras 2-7: En "Desglose de Figuras Disponibles" (opcionales)

### Sección 22.3 (Resultados)
- [ ] Tabla de Corrección Funcional: Evidencia Figura 1
- [ ] Tabla de Calidad de Código: Evidencia Figuras 5, C-J

### Sección 22.4 (Casos de Uso)
- [ ] Algoritmo 1: Figuras B (diagrama) y C (código)
- [ ] Algoritmo 2: Figuras D (diagrama) y E (código)
- [ ] Algoritmo 3: Figuras F (diagrama) y G (código)
- [ ] Algoritmo 4: Figuras H (diagrama) y J (código)

---

## **Pies de Figura - Plantillas**

### Figura 1
```
Figura 1. Ejecución completa de la suite de pruebas del Ciclo 6: 84 casos totales 
ejecutados mediante `flutter test test/compiler/ -v`. La salida muestra "+84: All 
tests passed!" confirmando validación de las cinco fases del conversor (análisis 
léxico, sintáctico, semántico, optimización y generación de código C99). Captura 
de: logs/ciclo7_TODOS_84_TESTS.txt o terminal PowerShell con timestamp y duración 
total de ejecución.
```

### Figuras 2-7
```
Figura X. Ejecución de pruebas de [COMPONENTE]: Y casos validando 
[DESCRIPCIÓN ESPECÍFICA DEL COMPONENTE]. Captura de terminal mostrando 
"+Y: All tests passed!" Comando: flutter test test/ciclo7_reports/[archivo] -v
```

**Ejemplos completados:**

**Figura 2:**
```
Figura 2. Ejecución de pruebas de análisis léxico: 8 casos validando tokenización 
de identificadores, literales, palabras clave, operadores y delimitadores. Captura 
de terminal mostrando "+8: All tests passed!" Comando: flutter test 
test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart -v
```

**Figura 5:**
```
Figura 5. Ejecución de pruebas de generación de código: 10 casos validando 
estructura main() válida, inclusión de headers, declaración de variables, 
especificadores de formato y indentación consistente. Captura de terminal mostrando 
"+10: All tests passed!" Comando: flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart -v
```

---

## **Ubicación de Archivos de Soporte**

```
docs/ciclo_7/
├── ciclo7_resultados_pruebas.md ← DOCUMENTO PRINCIPAL (aquí van las figuras)
├── GUIA_FIGURAS_CICLO7_ACTUALIZADA.md ← Instrucciones de captura
├── RESOLUCION_84_CASOS_CICLO6.md ← Justificación de estrategia
├── MAPA_FIGURAS_REFERENCIAS.md ← Este documento
└── figuras/ ← CARPETA PARA GUARDAR IMÁGENES
    ├── Figura_01_TODOS_84_TESTS.png
    ├── Figura_02_LEXICAL.png
    ├── Figura_03_SYNTAX.png
    ├── ... etc
    └── [imagenes de código generado]

logs/ ← Archivos de log generados automáticamente
├── ciclo7_TODOS_84_TESTS.txt
├── ciclo7_LEXICAL_ANALYZER.txt
├── ciclo7_SYNTAX_ANALYZER.txt
├── ciclo7_SEMANTIC_ANALYZER.txt
├── ciclo7_CODE_GENERATION.txt
├── ciclo7_ROBUSTNESS.txt
└── ciclo7_INTEGRATION_E2E.txt
```

---

## **Validación Final**

Antes de entregar el documento:

- [ ] **Figura 1:** Visible y clara, muestra `+84: All tests passed!`
- [ ] **Figuras 2-7:** Presentes (si vas por la opción completa)
- [ ] **Figuras B-J:** Diagramas y código generado de cada algoritmo
- [ ] **Pies de figura:** Descriptivos y con referencias a comandos/archivos
- [ ] **Tablas:** Cada tabla con su evidencia correspondiente citada debajo
- [ ] **Resolución:** Todas las imágenes legibles (fuente clara, no pixeladas)
- [ ] **Trazabilidad:** Cada tabla apunta a la(s) figura(s) que la sustenta

✅ **Cuando todo esto esté listo, el documento estará completo para entrega.**
