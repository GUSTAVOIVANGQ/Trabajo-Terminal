# Casos de prueba específicos (representativos)

Este documento resume los **casos de prueba más representativos** implementados en la suite de pruebas de FlowCode. Se seleccionaron para cubrir:

- **Integración end-to-end (pipeline completo)**
- **Fases del compilador**: léxico, sintáctico, semántico, optimización y generación de código
- **Símbolos ISO 5807** (terminal, proceso, decisión, datos)
- **Funcionalidades de app**: UI base y registro

Fuentes de trazabilidad: `docs/tema_23_pruebas_integracion.md` y `docs/tema_22_integracion_pipeline.md`.

---

## Tabla de casos de prueba representativos

> Nota: En la columna **Archivo** se usa la ruta real dentro del repo (carpeta `test/`). En **Caso (nombre)** se usa el literal del `test('...')` cuando aplica.

| ID | Fase / CU | Tipo | Archivo | Caso (nombre) | ¿Qué valida? | Resultado esperado |
|---|---|---|---|---|---|---|
| CP-01 | Integración (E2E) | Integración | `test/compiler/compiler_integration_test.dart` | `E2E-01.1: Minimal valid diagram compiles successfully` | Diagrama mínimo (Inicio→Fin) compila y genera C básico | `success=true`, incluye `#include <stdio.h>`, `int main(` y `return 0;` |
| CP-02 | Integración (E2E) | Integración | `test/compiler/compiler_integration_test.dart` | `E2E-01.2: Complete pipeline phases execute in order` | Las 5 fases ejecutan y producen resultados no nulos | `lexicalResult/syntaxResult/semanticResult/ast/generatedCode` no nulos |
| CP-03 | Tabla de símbolos | Integración | `test/compiler/compiler_integration_test.dart` | `E2E-01.3: Symbol table propagates through all phases` | Propagación de tabla de símbolos y tipado C | `lookup('contador')` existe y `cRepresentation == 'int'` |
| CP-04 | Optimización (E2E) | Integración | `test/compiler/compiler_integration_test.dart` | `E2E-01.4: Optimization affects generated code` | Ejecución opcional de optimización según nivel | Compila con y sin optimización; si hay `optimizationResult`, reporta optimizaciones |
| CP-05 | CU01 / ISO 5807 Terminal | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-01.1: Terminal nodes generate valid main() structure` | Nodos terminales producen estructura `main()` | Código contiene `int main(` y `return 0;` |
| CP-06 | CU01 (ES/EN) | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-01.2: Spanish and English variants work` | Soporta variantes `Inicio/Fin` y `Start/End` | Compilación exitosa con mezcla ES/EN |
| CP-07 | CU02 Proceso (declaración) | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-02.1: Variable declaration` | Traducción de declaración desde nodo proceso | Código generado contiene `int numero = 42` |
| CP-08 | CU02 Proceso (asignación) | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-02.2: Assignment expression` | Traducción de asignación/operación en nodo proceso | Código generado contiene `x = x + 1` |
| CP-09 | CU02 Datos (salida) | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-03.1: Output with printf` | Generación de `printf()` desde nodo de salida | Código contiene `printf(` |
| CP-10 | CU02 Datos (entrada) | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-03.2: Input with scanf` | Generación de `scanf()` desde nodo de entrada | Código contiene `scanf(` |
| CP-11 | CU02 Tipos → formato | Integración | `test/compiler/compiler_integration_test.dart` | `ISO-03.3: Format specifiers match data types` | Especificadores correctos según tipo (`int`, `float`) | Código contiene `%d` y `%f` en salidas correspondientes |
| CP-12 | Fase 1 (Léxico) | Unit test | `test/compiler/lexical_analyzer_test.dart` | `Tokenize Spanish keyword` | Palabras clave en español (p.ej. `Leer`) se tokenizan correctamente | `TokenType.kwLeer` |
| CP-13 | Fase 1 (Léxico) | Unit test | `test/compiler/lexical_analyzer_test.dart` | `Tokenize modulo expression with spaces` | El operador `%` con espacios se interpreta como `opModulo` | Secuencia de tokens incluye `TokenType.opModulo` |
| CP-14 | Fase 2 (Sintáctico) | Unit test | `test/compiler/syntax_analyzer_test.dart` | `Parse complex expression` | Parsing respeta precedencia y no genera errores | AST válido y `analyzer.errors` vacío |
| CP-15 | Fase 2 (Sintáctico) | Unit test | `test/compiler/syntax_analyzer_test.dart` | `Check balanced parentheses - invalid` | Detección de paréntesis desbalanceados | Retorna `false` para expresiones inválidas |
| CP-16 | Fase 2 (Sintáctico) | Unit test | `test/compiler/syntax_analyzer_test.dart` | `Analyze process node with declaration` | Un nodo de declaración produce `DeclarationStatementNode` con `DataType` correcto | `DataType.integer` y `variableName == 'x'` |
| CP-17 | Fase 3 (Semántico) | Unit test | `test/compiler/semantic_analyzer_test.dart` | `Detect undeclared variable in process node` | Detecta variable no declarada en expresión (p.ej. `y`) | Error con `CompilerErrorCode.undeclaredVariable` |
| CP-18 | Fase 3 (Semántico) | Unit test | `test/compiler/semantic_analyzer_test.dart` | `Detect duplicate declaration` | Detecta declaración duplicada | Error `CompilerErrorCode.duplicateDeclaration` |
| CP-19 | Fase 3 (Semántico) | Unit test | `test/compiler/semantic_analyzer_test.dart` | `Type mismatch warning for incompatible assignment` | Warning por incompatibilidad de tipos | Warning `CompilerErrorCode.typeMismatch` |
| CP-20 | Fase 3 (Semántico) | Unit test | `test/compiler/semantic_analyzer_test.dart` | `Detect division by zero` | Error por división entre cero | Error `CompilerErrorCode.divisionByZero` |
| CP-21 | Fase 4 (Optimización) | Unit test | `test/compiler/code_optimizer_test.dart` | `Fold integer addition: 2 + 3 = 5` | Constant folding en AST | Expresión optimizada se vuelve `IntegerLiteralNode(5)` |
| CP-22 | Fase 4 (Optimización) | Unit test | `test/compiler/code_optimizer_test.dart` | `Optimizer with no optimizations level` | Nivel `none` no aplica optimizaciones | `totalOptimizations == 0` |
| CP-23 | Fase 4 (CodeGen con metadata) | Unit test | `test/code_generator_phase4_test.dart` | `Switch con metadata genera código switch correcto` | Metadata produce `switch/case/break` y evita `if-else` anidados | Código contiene `switch (opcion)`, `case`, `break;` y NO contiene `if (opcion == 1)` |
| CP-24 | Fase 4 (CodeGen con metadata) | Unit test | `test/code_generator_phase4_test.dart` | `Bucle for con metadata genera código for correcto` | Metadata produce `for(init;cond;inc)` y evita `while` | Contiene `for (...)` y NO contiene `while (i < 5)` |
| CP-25 | Fase 4 (CodeGen con metadata) | Unit test | `test/code_generator_phase4_test.dart` | `Bucle while con metadata genera código while correcto` | Metadata produce `while(cond)` | Contiene `while (` |
| CP-26 | Fase 5 (CodeGen avanzado) | Integración | `test/compiler/code_generator_advanced_test.dart` | `Plantilla 02 - Múltiples variables en printf` | `printf` incluye múltiples variables y respeta declaraciones | Compila; declara `x,y,z` y un `printf(...)` que incluye `x`, `y`, `z` |
| CP-27 | Fase 5 (CodeGen avanzado) | Integración | `test/compiler/code_generator_advanced_test.dart` | `Generador avanzado usa tabla de símbolos para tipos` | El formato de salida usa `%f` para `float` | Código contiene `%f` |
| CP-28 | App (UI base) | Widget test | `test/widget_test.dart` | `Counter increments smoke test` | Smoke test del árbol de widgets (app inicia y responde) | Contador pasa de `0` a `1` tras tap en `+` |
| CP-29 | App (Registro) | Integración | `test/registration_test.dart` | `Registro exitoso con email nuevo` | Registro con `AuthService` retorna usuario con rol | `user != null`, email coincide, `role == UserRole.user` |
| CP-30 | Rendimiento | Benchmark | `test/compiler/compiler_benchmark_test.dart` | `BENCH-01.10: Linear diagram with 10 nodes` (y variantes) | Mide tiempos por fase y escalabilidad | Reporta métricas y `avgTotalTime >= 0` |

---

## Notas importantes (para interpretación del reporte)

- En `test/` existen archivos tipo **demostración/manual** (por ejemplo `test/process_node_dialog_test.dart`, `test/decision_node_dialog_test.dart`, `test/programming_concepts_test.dart`) que **imprimen resultados** pero no usan `expect(...)`; por eso no se listan como “representativos automatizados” arriba.
- En `docs/tema_23_pruebas_integracion.md` se menciona `admin_test_script.dart` para CU10; **no aparece como archivo real en `test/`** en el workspace actual.
