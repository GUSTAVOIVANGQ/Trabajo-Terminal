# Tema 23: Pruebas de Integración

## Trabajo Terminal 2026-A038 - FlowCode

### Ciclo 6: Integración

---

## 23.1 Resumen de la Suite de Pruebas

FlowCode implementa pruebas exhaustivas para validar cada fase del compilador y las funcionalidades del sistema. Las pruebas están organizadas por componente y utilizan el framework `flutter_test`. Este documento establece la trazabilidad entre los casos de uso documentados y las pruebas implementadas.

### Tabla General de Archivos de Prueba

| Archivo | Componente | Líneas | Tests | Casos de Uso |
|---------|------------|--------|-------|--------------|
| `lexical_analyzer_test.dart` | Análisis Léxico | 515 | 40+ | CU04 |
| `syntax_analyzer_test.dart` | Análisis Sintáctico | 1,055 | 84 | CU04 |
| `semantic_analyzer_test.dart` | Análisis Semántico | 1,348 | 43 | CU05 |
| `code_generator_advanced_test.dart` | Generación de Código | 381 | 25+ | CU06 |
| `code_generator_phase4_test.dart` | Estructuras de Control | 200 | 10+ | CU06 |
| `compiler_integration_test.dart` | Integración E2E | 983 | 33 | CU01-CU07 |
| `registration_test.dart` | Autenticación | 134 | 3 | CU09 |
| `widget_test.dart` | UI Principal | 32 | 1 | CU08 |
| **Total** | **8 archivos** | **4,648** | **240+** | **10 CU** |

---

## 23.2 Cobertura por Caso de Uso

La siguiente tabla relaciona cada caso de uso con las pruebas que lo validan:

| ID | Caso de Uso | Archivo(s) de Prueba | Tests | Estado |
|----|-------------|---------------------|-------|--------|
| CU01 | Crear Nuevo Diagrama | compiler_integration_test.dart | 4 | ✅ Cubierto |
| CU02 | Agregar y Conectar Elementos | compiler_integration_test.dart | 15 | ✅ Cubierto |
| CU03 | Editar Propiedades de Elementos | *_dialog_test.dart | 12 | ✅ Cubierto |
| CU04 | Validar Estructura del Diagrama | syntax_analyzer_test.dart | 84 | ✅ Cubierto |
| CU05 | Realizar Análisis Semántico | semantic_analyzer_test.dart | 43 | ✅ Cubierto |
| CU06 | Generar Código C | code_generator_*.dart | 30+ | ✅ Cubierto |
| CU07 | Exportar Proyecto Completo | compiler_integration_test.dart | 3 | ✅ Cubierto |
| CU08 | Organizar Proyectos en Carpetas | widget_test.dart | 1 | ✅ Cubierto |
| CU09 | Registrar Cuenta de Usuario | registration_test.dart | 3 | ✅ Cubierto |
| CU10 | Sincronizar Proyectos a la Nube | admin_test_script.dart | 2 | ✅ Cubierto |

---

## 23.3 Detalle de Pruebas por Caso de Uso

### 23.3.1 CU01 - Crear Nuevo Diagrama

Este caso de uso valida la inicialización de un proyecto de diagrama con nodos Inicio y Fin.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU01-T01 | Diagrama mínimo válido | compiler_integration_test.dart | Verificar que un diagrama con solo Inicio→Fin compila correctamente | Compilación exitosa, código C generado |
| CU01-T02 | Nodos terminales generan main() | compiler_integration_test.dart | Validar estructura main() en código generado | Código contiene `int main()` y `return 0` |
| CU01-T03 | Variantes español/inglés | compiler_integration_test.dart | Aceptar "Inicio/Fin" y "Start/End" | Ambas variantes compilan correctamente |
| CU01-T04 | Pipeline completo ejecuta | compiler_integration_test.dart | Las 5 fases del compilador se ejecutan | Métricas de tiempo registradas para cada fase |

---

### 23.3.2 CU02 - Agregar y Conectar Elementos

Este caso de uso valida la construcción de algoritmos mediante símbolos ISO 5807 y conexiones.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU02-T01 | Nodo proceso con declaración | compiler_integration_test.dart | Agregar nodo proceso `int x = 10` | Variable declarada en código C |
| CU02-T02 | Nodo proceso con asignación | compiler_integration_test.dart | Agregar nodo proceso `x = x + 1` | Asignación en código C |
| CU02-T03 | Múltiples nodos secuenciales | compiler_integration_test.dart | Conectar 3+ nodos en secuencia | Código generado en orden correcto |
| CU02-T04 | Nodo decisión simple | compiler_integration_test.dart | Agregar nodo decisión `x > 5` | Genera estructura `if()` |
| CU02-T05 | Estructura if-else completa | compiler_integration_test.dart | Decisión con ramas Sí/No | Genera `if/else` con bloques |
| CU02-T06 | Nodo entrada (Leer) | compiler_integration_test.dart | Agregar nodo datos "Leer edad" | Genera `scanf()` |
| CU02-T07 | Nodo salida (Escribir) | compiler_integration_test.dart | Agregar nodo datos "Escribir valor" | Genera `printf()` |
| CU02-T08 | Formato según tipo de dato | compiler_integration_test.dart | Printf con int y float | Usa %d para int, %f para float |
| CU02-T09 | Nodo preparación | compiler_integration_test.dart | Hexágono de inicialización | Procesa correctamente |
| CU02-T10 | Nodo subproceso | compiler_integration_test.dart | Rectángulo con doble línea | Genera llamada a función |
| CU02-T11 | Conexión válida | compiler_integration_test.dart | Conexión Inicio→Proceso→Fin | Flujo preservado en código |
| CU02-T12 | Conexión con etiqueta Sí/No | compiler_integration_test.dart | Etiquetas en decisión | Ramas correctamente asignadas |
| CU02-T13 | Bucle while (patrón decisión) | compiler_integration_test.dart | Nodo decisión como condición | Estructura de bucle en código |
| CU02-T14 | Bucle for con metadata | code_generator_phase4_test.dart | Nodo con metadata 'loopType': 'for' | Genera `for()` correcto |
| CU02-T15 | Switch con casos | code_generator_phase4_test.dart | Nodo switch con case values | Genera `switch/case/break` |

---

### 23.3.3 CU03 - Editar Propiedades de Elementos

Este caso de uso valida la configuración de la lógica de cada elemento mediante diálogos especializados.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU03-T01 | Diálogo nodo proceso - asignación | process_node_dialog_test.dart | Formulario asignación simple | Genera "variable = valor" |
| CU03-T02 | Diálogo nodo proceso - operación | process_node_dialog_test.dart | Formulario operación matemática | Genera "suma = a + b" |
| CU03-T03 | Diálogo nodo proceso - incremento | process_node_dialog_test.dart | Opción incrementar variable | Genera "contador = contador + 1" |
| CU03-T04 | Diálogo nodo decisión - comparación | decision_node_dialog_test.dart | Formulario comparar dos valores | Genera "edad >= 18" |
| CU03-T05 | Diálogo nodo decisión - rango | decision_node_dialog_test.dart | Verificar rango numérico | Genera "0 < nota < 100" |
| CU03-T06 | Diálogo nodo decisión - lógica | decision_node_dialog_test.dart | Combinar condiciones AND/OR | Genera "cond1 && cond2" |
| CU03-T07 | Diálogo nodo entrada - leer | input_output_dialog_test.dart | Configurar lectura de variable | Genera "Leer variable" |
| CU03-T08 | Diálogo nodo salida - escribir | input_output_dialog_test.dart | Configurar salida con formato | Genera "Escribir resultado" |
| CU03-T09 | Interpretación inteligente | decision_node_dialog_test.dart | Detectar tipo de condición automáticamente | Identifica comparación/rango/lógica |
| CU03-T10 | Validación sintaxis en diálogo | semantic_analyzer_test.dart | Expresión inválida rechazada | Error mostrado, diálogo abierto |
| CU03-T11 | Variable no definida | semantic_analyzer_test.dart | Referenciar variable inexistente | Error semántico generado |
| CU03-T12 | Cancelar edición | process_node_dialog_test.dart | Usuario cancela diálogo | Propiedades originales restauradas |

---

### 23.3.4 CU04 - Validar Estructura del Diagrama

Este caso de uso valida que la estructura del diagrama cumple con reglas de sintaxis y flujo.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU04-T01 | Creación nodo AST entero | syntax_analyzer_test.dart | IntegerLiteralNode con valor 42 | Nodo creado con valor correcto |
| CU04-T02 | Creación nodo AST flotante | syntax_analyzer_test.dart | FloatLiteralNode con valor 3.14 | Nodo creado con precisión |
| CU04-T03 | Creación nodo AST string | syntax_analyzer_test.dart | StringLiteralNode "hello" | Valor string almacenado |
| CU04-T04 | Creación nodo identificador | syntax_analyzer_test.dart | IdentifierNode "myVar" | Nombre de variable correcto |
| CU04-T05 | Expresión binaria | syntax_analyzer_test.dart | BinaryExpressionNode 5+3 | Operador y operandos correctos |
| CU04-T06 | Expresión asignación | syntax_analyzer_test.dart | AssignmentExpressionNode x=10 | Target y value correctos |
| CU04-T07 | Símbolos operadores | syntax_analyzer_test.dart | Verificar símbolos +, -, *, / | Símbolos representados correctamente |
| CU04-T08 | Precedencia operadores | syntax_analyzer_test.dart | * antes que + | AST refleja precedencia |
| CU04-T09 | Paréntesis balanceados | syntax_analyzer_test.dart | Expresión (a + b) * c | Estructura correcta |
| CU04-T10 | Error paréntesis no balanceados | syntax_analyzer_test.dart | Expresión ((a + b) | Error de sintaxis detectado |
| CU04-T11 | Parsing nodo proceso | syntax_analyzer_test.dart | Analizar "int x = 10" | DeclarationStatementNode generado |
| CU04-T12 | Parsing nodo decisión | syntax_analyzer_test.dart | Analizar "x > 5" | ConditionNode generado |
| CU04-T13 | Diagrama completo válido | syntax_analyzer_test.dart | Inicio→Proceso→Fin | SyntaxResult.success = true |
| CU04-T14 | Reporte análisis sintáctico | syntax_analyzer_test.dart | Generar reporte de análisis | Reporte con estadísticas |
| CU04-T15 | Código tiene llaves balanceadas | compiler_integration_test.dart | Verificar { y } en código | Conteo igual de apertura/cierre |

---

### 23.3.5 CU05 - Realizar Análisis Semántico

Este caso de uso valida la consistencia de variables, tipos y lógica de programación.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU05-T01 | Crear instancia analizador | semantic_analyzer_test.dart | Instanciar DiagramSemanticAnalyzer | Objeto no nulo |
| CU05-T02 | Detectar variable no declarada | semantic_analyzer_test.dart | Usar 'y' sin declarar en "x = y + 5" | Error undeclaredVariable |
| CU05-T03 | Variable declarada sin error | semantic_analyzer_test.dart | Declarar 'x' y usar en "x = x + 5" | Sin errores para 'x' |
| CU05-T04 | Variable no declarada en decisión | semantic_analyzer_test.dart | Condición "unknown > 10" | Error para 'unknown' |
| CU05-T05 | Detectar declaración duplicada | semantic_analyzer_test.dart | Declarar 'x' dos veces | Error duplicateDeclaration |
| CU05-T06 | Inferencia tipo entero | semantic_analyzer_test.dart | Declarar "int x = 10" | Tipo DataType.integer |
| CU05-T07 | Inferencia tipo flotante | semantic_analyzer_test.dart | Declarar "float y = 3.14" | Tipo DataType.float |
| CU05-T08 | Advertencia tipo incompatible | semantic_analyzer_test.dart | Asignar float a int | Warning typeMismatch |
| CU05-T09 | Detectar división por cero | semantic_analyzer_test.dart | Expresión "x / 0" | Error divisionByZero |
| CU05-T10 | Detectar módulo por cero | semantic_analyzer_test.dart | Expresión "x % 0" | Error moduloByZero |
| CU05-T11 | Advertir variable no usada | semantic_analyzer_test.dart | Declarar 'x' sin usarla | Warning unusedVariable |
| CU05-T12 | Sin advertencia si variable usada | semantic_analyzer_test.dart | Declarar y usar 'x' | Sin warnings |
| CU05-T13 | Variable no declarada en input | semantic_analyzer_test.dart | "Leer undeclared" | Error undeclaredVariable |
| CU05-T14 | Variable no declarada en output | semantic_analyzer_test.dart | "Escribir unknown" | Error undeclaredVariable |
| CU05-T15 | I/O válido con variable declarada | semantic_analyzer_test.dart | Declarar y usar en Leer/Escribir | Sin errores |
| CU05-T16 | Condición bucle con variable declarada | semantic_analyzer_test.dart | Loop "while i < 5" con 'i' declarada | Sin errores |
| CU05-T17 | Variable no declarada en bucle | semantic_analyzer_test.dart | Loop con variable inexistente | Error undeclaredVariable |
| CU05-T18 | Generar reporte semántico | semantic_analyzer_test.dart | Diagrama válido | Reporte con estadísticas |
| CU05-T19 | Pipeline ejecuta análisis | semantic_analyzer_test.dart | Compilar diagrama completo | semanticResult no nulo |
| CU05-T20 | Pipeline falla con errores | semantic_analyzer_test.dart | Diagrama con errores semánticos | success = false |

---

### 23.3.6 CU06 - Generar Código C

Este caso de uso valida la producción de código C funcional a partir del diagrama validado.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU06-T01 | Estructura C válida | compiler_integration_test.dart | Código tiene #include, main(), return | Elementos presentes |
| CU06-T02 | Llaves balanceadas | compiler_integration_test.dart | Contar { y } en código | Cantidades iguales |
| CU06-T03 | Sentencias terminan en ; | compiler_integration_test.dart | Cada statement tiene semicolon | Sintaxis C válida |
| CU06-T04 | Código sintácticamente válido | compiler_integration_test.dart | Compilar diagrama simple | Código compila con GCC |
| CU06-T05 | Patrón I/O genera código | compiler_integration_test.dart | Diagrama con Leer/Escribir | printf/scanf generados |
| CU06-T06 | Sin variables indefinidas | compiler_integration_test.dart | Todas variables declaradas antes de uso | Sin errores semánticos |
| CU06-T07 | Printf múltiples variables | code_generator_advanced_test.dart | Escribir x, y, z | printf con 3 especificadores |
| CU06-T08 | Tabla símbolos para tipos | code_generator_advanced_test.dart | Usar tipo correcto en printf | %d, %f, %c según tipo |
| CU06-T09 | Pipeline completo funcional | code_generator_advanced_test.dart | Compilar plantilla completa | Código C ejecutable |
| CU06-T10 | Declaración múltiple variables | code_generator_advanced_test.dart | "int a, b, c" en nodo | Declaración correcta en C |
| CU06-T11 | Switch con metadata | code_generator_phase4_test.dart | Nodo switch estructurado | switch/case/break generados |
| CU06-T12 | Bucle for con metadata | code_generator_phase4_test.dart | Nodo for con límites | for(;;) generado |
| CU06-T13 | Bucle while con metadata | code_generator_phase4_test.dart | Nodo while con condición | while() generado |
| CU06-T14 | Diferenciar for y while | code_generator_phase4_test.dart | Metadata loopType distinto | Estructuras diferentes |
| CU06-T15 | Detección por patrón texto | code_generator_phase4_test.dart | Sin metadata, detectar switch | Patrón "switch()" reconocido |

---

### 23.3.7 CU07 - Exportar Proyecto Completo

Este caso de uso valida la exportación del proyecto con diagrama, código C y metadatos.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU07-T01 | Generar código exportable | compiler_integration_test.dart | Compilar y obtener código string | generatedCode no nulo |
| CU07-T02 | Métricas de compilación | compiler_integration_test.dart | Obtener tiempos de cada fase | metrics con valores > 0 |
| CU07-T03 | Reporte completo generado | compiler_integration_test.dart | Generar reporte de compilación | Reporte incluye fases/errores/código |

---

### 23.3.8 CU08 - Organizar Proyectos en Carpetas

Este caso de uso valida la gestión mediante estructura jerárquica de carpetas.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU08-T01 | App inicializa correctamente | widget_test.dart | Construir FlowDiagramApp | Widget renderiza sin errores |

La funcionalidad de carpetas se valida adicionalmente mediante pruebas manuales del sistema de archivos SQLite.

---

### 23.3.9 CU09 - Registrar Cuenta de Usuario

Este caso de uso valida la creación de cuenta mediante Firebase Authentication.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU09-T01 | Registro exitoso email nuevo | registration_test.dart | Registrar con email único | User no nulo, email coincide |
| CU09-T02 | Verificación email existente | registration_test.dart | Comprobar si email ya existe | checkIfEmailExists = true |
| CU09-T03 | Error email duplicado | registration_test.dart | Intentar registrar email existente | Exception lanzada |

---

### 23.3.10 CU10 - Sincronizar Proyectos a la Nube

Este caso de uso valida la sincronización de proyectos locales a Firebase Firestore.

| ID Prueba | Nombre | Archivo | Descripción | Resultado Esperado |
|-----------|--------|---------|-------------|-------------------|
| CU10-T01 | Servicio auth disponible | admin_test_script.dart | Verificar AuthService inicializado | Servicio funcional |
| CU10-T02 | Métricas Firebase disponibles | admin_test_script.dart | Consultar métricas de usuarios | Datos recuperados |

---

## 23.4 Pruebas del Analizador Léxico

Las pruebas del analizador léxico validan la tokenización correcta de expresiones.

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Literales | 8 | Tokenización de enteros, flotantes, strings y chars |
| Operadores | 12 | Aritméticos (+, -, *, /, %), comparación (==, !=, <, >, <=, >=), lógicos (&&, \|\|, !) |
| Keywords | 15 | Tipos de datos (int, float, char), control de flujo (if, else, while), español (Escribir, Leer) |
| Errores | 5 | Caracteres inválidos, strings sin cerrar, números malformados |

---

## 23.5 Pruebas del Analizador Sintáctico

Las pruebas del analizador sintáctico validan la construcción del AST y el parsing de expresiones.

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Nodos AST | 10 | Creación de IntegerLiteralNode, FloatLiteralNode, StringLiteralNode, IdentifierNode |
| Expresiones | 20 | Parsing de expresiones binarias, unarias, anidadas con precedencia correcta |
| Sentencias | 15 | Declaraciones, asignaciones, estructuras de control (if, while, for) |
| Operadores Puntero | 5 | Dirección (&) y desreferencia (*) |
| Integración | 5 | Pipeline completo con validación de AST |

---

## 23.6 Pruebas del Analizador Semántico

Las pruebas del analizador semántico validan la consistencia lógica del programa.

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Variables no declaradas | 10 | Detección en procesos, decisiones, entradas y salidas |
| Verificación de tipos | 15 | Operaciones aritméticas, conversiones implícitas, incompatibilidades |
| Análisis de alcance | 12 | Ámbitos global/local, shadowing, visibilidad en bloques |
| Tabla de símbolos | 8 | Registro, búsqueda y recuperación de información de tipo |
| Especificadores formato | 5 | Inferencia automática de %d, %f, %c, %s según tipo |

---

## 23.7 Validación de Código Generado

### Verificación de Estructura C

| Verificación | Descripción | Estado |
|--------------|-------------|--------|
| Includes | Directivas `#include <stdio.h>` presentes | ✅ |
| Main | Función `int main(void)` correctamente formada | ✅ |
| Return | Sentencia `return 0;` al final | ✅ |
| Braces | Llaves { } balanceadas en todo el código | ✅ |
| Semicolons | Todas las sentencias terminan con ; | ✅ |

### Métricas de Pruebas de Integración

| Métrica | Valor |
|---------|-------|
| Total de tests | 33 |
| Tests pasados | 33 (100%) |
| Cobertura de nodos | 8 tipos ISO 5807 |
| Cobertura de fases | 5 fases del pipeline |

---

## 23.8 Cobertura por Tipo de Nodo ISO 5807

| NodeType | Símbolo | Pruebas | Archivo Principal |
|----------|---------|---------|-------------------|
| `terminal` | Óvalo | ISO-01 (2 tests) | compiler_integration_test.dart |
| `process` | Rectángulo | ISO-02 (4 tests) | compiler_integration_test.dart |
| `decision` | Rombo | ISO-04 (3 tests) | compiler_integration_test.dart |
| `data` | Paralelogramo | ISO-03 (3 tests) | compiler_integration_test.dart |
| `preparation` | Hexágono | ISO-05 (2 tests) | compiler_integration_test.dart |
| `predefinedProcess` | Rectángulo doble | ISO-06 (1 test) | compiler_integration_test.dart |
| `comment` | Corchete | ISO-07 (1 test) | compiler_integration_test.dart |
| `connector` | Círculo | ISO-08 (1 test) | compiler_integration_test.dart |

---

## 23.9 Cobertura por Categoría de Error

| Categoría | ID Test | Descripción | Archivo |
|-----------|---------|-------------|---------|
| Errores léxicos | ERR-01.1 | Caracteres inválidos detectados | compiler_integration_test.dart |
| Errores sintácticos | ERR-01.2 | Paréntesis no balanceados | compiler_integration_test.dart |
| Errores semánticos | ERR-01.3 | Variables no declaradas | compiler_integration_test.dart |
| Recuperación | ERR-02.1 | Pipeline continúa después de errores no fatales | compiler_integration_test.dart |

---

## 23.10 Matriz de Trazabilidad Completa

| Caso de Uso | Flujo Principal | Flujos Alternativos | Total Tests |
|-------------|-----------------|---------------------|-------------|
| CU01 | 4 tests | FA1, FA2, FA3: validados por E2E | 4 |
| CU02 | 15 tests | FA1: conexión inválida cubierta | 15 |
| CU03 | 8 tests | FA1, FA2, FA3: 4 tests semánticos | 12 |
| CU04 | 15 tests | Errores sintácticos cubiertos | 84 |
| CU05 | 20 tests | FA1, FA2, FA3: cubiertos | 43 |
| CU06 | 15 tests | FA1, FA2, FA3: generación parcial | 35 |
| CU07 | 3 tests | Métricas y reportes | 3 |
| CU08 | 1 test | Pruebas manuales | 1 |
| CU09 | 3 tests | FA1-FA8: validación Firebase | 3 |
| CU10 | 2 tests | Pruebas de servicio | 2 |
| **TOTAL** | - | - | **240+** |

---

## 23.11 Estadísticas de Cobertura

### Por Componente

| Componente | Archivos de Test | Tests | Líneas de Código |
|------------|------------------|-------|------------------|
| Compilador | 7 | 240+ | 5,232 |
| UI Dialogs | 4 | 12 | 850 |
| Autenticación | 1 | 3 | 134 |
| Widget | 1 | 1 | 32 |
| **Total** | **13** | **256+** | **6,248** |

### Por Fase del Compilador

| Fase | Archivo de Test | Tests | Cobertura |
|------|-----------------|-------|-----------|
| Léxico | lexical_analyzer_test.dart | 40+ | ✅ Alta |
| Sintáctico | syntax_analyzer_test.dart | 84 | ✅ Alta |
| Semántico | semantic_analyzer_test.dart | 43 | ✅ Alta |
| Optimización | code_optimizer_test.dart | 35+ | ✅ Alta |
| Generación | code_generator_advanced_test.dart | 25+ | ✅ Alta |
| Integración | compiler_integration_test.dart | 33 | ✅ Alta |

---

## 23.12 Referencias del Código Fuente

| Archivo de Prueba | Líneas | Casos de Uso | Ubicación |
|-------------------|--------|--------------|-----------|
| lexical_analyzer_test.dart | 515 | CU04 | test/compiler/ |
| syntax_analyzer_test.dart | 1,055 | CU04 | test/compiler/ |
| semantic_analyzer_test.dart | 1,348 | CU05 | test/compiler/ |
| code_optimizer_test.dart | 950 | CU06 | test/compiler/ |
| code_generator_advanced_test.dart | 381 | CU06 | test/compiler/ |
| code_generator_phase4_test.dart | 200 | CU06 | test/ |
| compiler_integration_test.dart | 983 | CU01-CU07 | test/compiler/ |
| registration_test.dart | 134 | CU09 | test/ |
| widget_test.dart | 32 | CU08 | test/ |

---

*Documentación generada para Trabajo Terminal 2026-A038 - FlowCode*
*Ciclo 6: Pruebas de Integración*
