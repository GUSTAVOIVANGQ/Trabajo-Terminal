# Plan de Implementación — Intérprete de AST en Dart

## Contexto

Se reemplaza la implementación anterior (plan-cExecutionTerminal) que usaba PicoC + NDK/MethodChannel
por un **intérprete de AST puro en Dart** que ejecuta la lógica del diagrama directamente.

## Archivos a Modificar/Crear

### Eliminar implementación anterior
- [x] `lib/services/c_execution_service.dart` — se reescribe completamente
- [x] `lib/widgets/execution_tab.dart` — se reescribe completamente

### Pieza 1 — Intérprete de AST
- [x] `lib/compiler/ast_interpreter.dart` — **NUEVO**: Visitor que ejecuta el AST

### Pieza 2 + 3 — Servicio de ejecución con comunicación
- [x] `lib/services/c_execution_service.dart` — **REESCRIBIR**: Servicio que maneja Isolate + eventos

### Pieza 4 — Pestaña "Ejecutar"
- [x] `lib/widgets/execution_tab.dart` — **REESCRIBIR**: Terminal interactiva con estados

### Restricciones
- No usar NDK, JNI, FFI, MethodChannel
- No hacer llamadas HTTP
- No modificar archivos del compilador existente
- No agregar dependencias externas
- Dart puro
