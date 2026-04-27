# 18.x Catálogo de Errores y Tablas (Resumen)

Este documento resume el **catálogo de errores** y las **tablas** usadas por el sistema de errores del conversor (FlowCode), para referencia rápida.



## Tabla 1 — Niveles de severidad (`CompilerSeverity`)

| Severidad | Prefijo | Emoji | Comportamiento esperado |
|---|---|---|---|
| `info` | `INFO` | ℹ️ | Mensaje informativo; la conversión continúa |
| `warning` | `WARNING` | ⚠️ | Advertencia; la conversión continúa, se recomienda revisar |
| `error` | `ERROR` | ❌ | Error; la conversión puede fallar o producir código incorrecto |
| `fatal` | `FATAL` | 🛑 | Error crítico; la conversión debe detenerse |


## Tabla 3 — Catálogo de errores (`CompilerErrorCode`)

### 3.1 Errores léxicos (1001–1010)

| Código | Enum | Descripción |
|---:|---|---|
| 1001 | `unexpectedCharacter` | Carácter inesperado encontrado |
| 1002 | `unterminatedString` | Cadena de texto no terminada |
| 1003 | `unterminatedComment` | Comentario no terminado |
| 1004 | `invalidNumber` | Número inválido |
| 1005 | `invalidIdentifier` | Identificador inválido |
| 1006 | `invalidEscapeSequence` | Secuencia de escape inválida |
| 1007 | `numberOverflow` | Número demasiado grande |
| 1008 | `emptyCharLiteral` | Literal de carácter vacío |
| 1009 | `multiCharacterLiteral` | Literal de carácter con múltiples caracteres |
| 1010 | `invalidFormatSpecifier` | Especificador de formato inválido |

### 3.2 Errores sintácticos (2001–2010)

| Código | Enum | Descripción |
|---:|---|---|
| 2001 | `unexpectedToken` | Token inesperado |
| 2002 | `missingToken` | Token faltante |
| 2003 | `unbalancedParentheses` | Paréntesis desbalanceados |
| 2004 | `unbalancedBraces` | Llaves desbalanceadas |
| 2005 | `unbalancedBrackets` | Corchetes desbalanceados |
| 2006 | `invalidExpression` | Expresión inválida |
| 2007 | `missingSemicolon` | Punto y coma faltante |
| 2008 | `invalidAssignment` | Asignación inválida |
| 2009 | `invalidDeclaration` | Declaración inválida |
| 2010 | `invalidStatement` | Sentencia inválida |

### 3.3 Errores semánticos (3001–3011)

| Código | Enum | Descripción |
|---:|---|---|
| 3001 | `undeclaredVariable` | Variable no declarada |
| 3002 | `duplicateDeclaration` | Declaración duplicada |
| 3003 | `typeMismatch` | Tipos incompatibles |
| 3004 | `invalidOperation` | Operación inválida |
| 3005 | `uninitializedVariable` | Variable no inicializada |
| 3006 | `unusedVariable` | Variable no utilizada |
| 3007 | `invalidTypeConversion` | Conversión de tipo inválida |
| 3008 | `divisionByZero` | División por cero |
| 3009 | `invalidArrayIndex` | Índice de arreglo inválido |
| 3010 | `outOfScope` | Variable fuera de alcance |
| 3011 | `unknownFunction` | Función no reconocida |

### 3.4 Errores estructurales (4001–4010)

| Código | Enum | Descripción |
|---:|---|---|
| 4001 | `missingStartNode` | Falta nodo de inicio |
| 4002 | `missingEndNode` | Falta nodo de fin |
| 4003 | `multipleStartNodes` | Múltiples nodos de inicio |
| 4004 | `disconnectedNode` | Nodo desconectado |
| 4005 | `invalidConnection` | Conexión inválida |
| 4006 | `infiniteLoop` | Posible bucle infinito |
| 4007 | `unreachableNode` | Nodo inalcanzable |
| 4008 | `invalidDecisionBranch` | Rama de decisión inválida |
| 4009 | `missingReturnPath` | Falta ruta de retorno |
| 4010 | `cyclicDependency` | Dependencia cíclica |

### 3.5 Errores de generación de código (5001–5003)

| Código | Enum | Descripción |
|---:|---|---|
| 5001 | `unsupportedConstruct` | Construcción no soportada |
| 5002 | `codeGenerationFailed` | Generación de código fallida |
| 5003 | `templateError` | Error en plantilla |

### 3.6 Genérico

| Código | Enum | Descripción |
|---:|---|---|
| 9999 | `unknown` | Error desconocido |
