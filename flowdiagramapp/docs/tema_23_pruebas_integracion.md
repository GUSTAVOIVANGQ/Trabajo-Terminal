# Tema 23: Pruebas de Integración

## Trabajo Terminal 2026-A038 - FlowCode
### Ciclo 6: Integración

---

## 23.1 Casos de Prueba del Compilador

FlowCode implementa una suite de pruebas exhaustiva para validar cada fase del compilador. Las pruebas están organizadas por componente y utilizan el framework `flutter_test`.

### Resumen de la Suite de Pruebas

| Archivo | Componente | Líneas | Tests |
|---------|------------|--------|-------|
| `lexical_analyzer_test.dart` | Análisis Léxico | 515 | 40+ |
| `syntax_analyzer_test.dart` | Análisis Sintáctico | 1,055 | 50+ |
| `semantic_analyzer_test.dart` | Análisis Semántico | 1,348 | 60+ |
| `code_optimizer_test.dart` | Optimización | 950 | 35+ |
| `code_generator_advanced_test.dart` | Generación de Código | 381 | 25+ |
| `compiler_integration_test.dart` | Integración E2E | 983 | 33 |
| **Total** | **6 archivos** | **5,232** | **240+** |

---

### 23.1.1 Pruebas del Analizador Léxico

**Archivo:** `test/compiler/lexical_analyzer_test.dart` (515 líneas)

#### Grupos de Pruebas

```
lexical_analyzer_test.dart
├── Token Tests
│   ├── Token creation
│   ├── TokenType precedence
│   └── TokenType properties
├── Basic Tokenization
│   ├── Integer literals
│   ├── Float literals
│   ├── String literals
│   ├── Char literals
│   └── Identifiers
├── Operator Tokenization
│   ├── Arithmetic operators (+, -, *, /, %)
│   ├── Comparison operators (==, !=, <, >, <=, >=)
│   ├── Logical operators (&&, ||, !)
│   └── Assignment operators (=, +=, -=, *=, /=)
├── Keyword Recognition
│   ├── Data types (int, float, char, double)
│   ├── Control flow (if, else, while, for)
│   └── Spanish keywords (Escribir, Leer)
├── Complex Expressions
│   ├── Arithmetic expressions
│   ├── Declarations with initialization
│   └── Nested expressions
└── Error Handling
    ├── Invalid characters
    ├── Unterminated strings
    └── Invalid number formats
```

#### Ejemplo de Test

```dart
test('Tokenize integer literal', () {
  final analyzer = DiagramLexicalAnalyzer();
  final tokens = analyzer.tokenize('42');

  expect(tokens.length, 2); // Number + EOF
  expect(tokens[0].type, TokenType.integerLiteral);
  expect(tokens[0].lexeme, '42');
  expect(tokens[0].value, 42);
});

test('TokenType precedence', () {
  // Multiplicación tiene mayor precedencia que suma
  expect(TokenType.opMultiply.precedence > TokenType.opPlus.precedence, true);
  expect(TokenType.opAssign.precedence, 1);
  expect(TokenType.opAnd.precedence > TokenType.opOr.precedence, true);
});
```

#### Casos de Prueba Cubiertos

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Literales | 8 | Enteros, flotantes, strings, chars |
| Operadores | 12 | Aritméticos, comparación, lógicos |
| Keywords | 15 | Tipos de datos, control de flujo |
| Errores | 5 | Caracteres inválidos, strings sin cerrar |

---

### 23.1.2 Pruebas del Analizador Sintáctico

**Archivo:** `test/compiler/syntax_analyzer_test.dart` (1,055 líneas)

#### Grupos de Pruebas

```
syntax_analyzer_test.dart
├── AST Node Tests
│   ├── IntegerLiteralNode creation
│   ├── FloatLiteralNode creation
│   ├── StringLiteralNode creation
│   ├── IdentifierNode creation
│   ├── BinaryExpressionNode creation
│   └── AssignmentExpressionNode creation
├── BinaryOperator Tests
│   ├── Operator symbols
│   ├── Operator precedence
│   └── C representation
├── Expression Parsing
│   ├── Primary expressions
│   ├── Unary expressions
│   ├── Binary expressions
│   └── Complex nested expressions
├── Statement Parsing
│   ├── Variable declarations
│   ├── Assignment statements
│   ├── If statements
│   └── Loop statements
├── Pointer Operators Tests
│   ├── Address-of operator (&)
│   └── Dereference operator (*)
├── Return Statement Tests
│   └── Return with expression
└── Compiler Pipeline Integration
    ├── Full pipeline execution
    └── AST generation validation
```

#### Ejemplo de Test

```dart
test('Parse binary expression: 5 + 3', () {
  final pipeline = DiagramCompilerPipeline();
  final ast = pipeline.parseExpression('5 + 3');
  
  expect(ast, isNotNull);
  expect(ast, isA<BinaryExpressionNode>());
  
  final binary = ast as BinaryExpressionNode;
  expect(binary.operator, BinaryOperator.add);
  expect((binary.left as IntegerLiteralNode).value, 5);
  expect((binary.right as IntegerLiteralNode).value, 3);
});

test('Parse declaration with initialization', () {
  final nodes = [
    DiagramNode(id: 'start', type: NodeType.terminal, text: 'Inicio', ...),
    DiagramNode(id: 'decl', type: NodeType.process, text: 'int x = 10', ...),
    DiagramNode(id: 'end', type: NodeType.terminal, text: 'Fin', ...),
  ];
  
  final result = pipeline.compile(nodes, connections);
  
  expect(result.success, isTrue);
  expect(result.ast, isNotNull);
});
```

#### Casos de Prueba Cubiertos

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Nodos AST | 10 | Creación y propiedades de nodos |
| Expresiones | 20 | Parsing de expresiones aritméticas |
| Sentencias | 15 | Declaraciones, asignaciones, control |
| Integración | 5 | Pipeline completo |

---

### 23.1.3 Pruebas del Analizador Semántico

**Archivo:** `test/compiler/semantic_analyzer_test.dart` (1,348 líneas)

#### Grupos de Pruebas

```
semantic_analyzer_test.dart
├── Basic Tests
│   └── Analyzer instance creation
├── Undeclared Variables
│   ├── Detect undeclared in process node
│   ├── No error for declared variable
│   └── Multiple undeclared variables
├── Type Checking
│   ├── Integer operations
│   ├── Float operations
│   ├── Type mismatch detection
│   └── Implicit conversion warnings
├── Variable Declaration
│   ├── Simple declaration
│   ├── Declaration with initialization
│   └── Multiple declarations
├── Scope Analysis
│   ├── Global scope
│   ├── Local scope (if blocks)
│   ├── Loop scope
│   └── Shadowing detection
├── Symbol Table Integration
│   ├── Symbol registration
│   ├── Symbol lookup
│   └── Symbol type retrieval
├── Format Specifier Inference
│   ├── %d for int
│   ├── %f for float
│   ├── %c for char
│   └── %s for string
└── Error Recovery
    ├── Continue after errors
    └── Collect all errors
```

#### Ejemplo de Test

```dart
test('Detect undeclared variable in process node', () {
  final analyzer = DiagramSemanticAnalyzer();
  final nodes = [
    DiagramNode(id: 'start', type: NodeType.terminal, text: 'Inicio', ...),
    DiagramNode(id: 'proc', type: NodeType.process, text: 'x = y + 5', ...),
    DiagramNode(id: 'end', type: NodeType.terminal, text: 'Fin', ...),
  ];

  final result = analyzer.analyzeDiagram(nodes, []);

  // Should have error for undeclared 'y'
  expect(
    result.errors.any((e) =>
      e.code == CompilerErrorCode.undeclaredVariable &&
      e.message.contains('y')),
    true
  );
});

test('No error for declared variable', () {
  final nodes = [
    DiagramNode(id: 'decl', type: NodeType.preparation, text: 'int x = 0', ...),
    DiagramNode(id: 'proc', type: NodeType.process, text: 'x = x + 5', ...),
  ];

  final result = analyzer.analyzeDiagram(nodes, []);

  expect(
    result.errors.where((e) => e.message.contains('x')).length,
    0
  );
});
```

#### Casos de Prueba Cubiertos

| Categoría | Tests | Descripción |
|-----------|-------|-------------|
| Variables no declaradas | 10 | Detección en diferentes contextos |
| Verificación de tipos | 15 | Operaciones y conversiones |
| Análisis de alcance | 12 | Ámbitos global/local |
| Tabla de símbolos | 8 | Registro y búsqueda |
| Especificadores formato | 5 | Inferencia automática |

---

### 23.1.4 Pruebas del Generador de Código

**Archivo:** `test/compiler/code_generator_advanced_test.dart` (381 líneas)

#### Grupos de Pruebas

```
code_generator_advanced_test.dart
├── Basic Code Generation
│   ├── Empty diagram (Inicio -> Fin)
│   ├── Simple variable declaration
│   └── Multiple declarations
├── I/O Code Generation
│   ├── printf for output
│   ├── scanf for input
│   └── Format specifiers
├── Control Structure Generation
│   ├── If statement
│   ├── If-else statement
│   └── Nested conditions
├── Loop Generation
│   ├── While loop
│   ├── For loop
│   └── Do-while loop
├── Expression Generation
│   ├── Arithmetic expressions
│   ├── Comparison expressions
│   └── Logical expressions
├── Code Style Options
│   ├── With comments
│   ├── Without comments
│   └── Indentation levels
└── Symbol Table in Code
    ├── Variable tracking
    └── Type information preservation
```

#### Ejemplo de Test

```dart
test('Generate printf for output node', () {
  final nodes = [
    DiagramNode(id: 'start', type: NodeType.terminal, text: 'Inicio', ...),
    DiagramNode(id: 'decl', type: NodeType.process, text: 'int valor = 100', ...),
    DiagramNode(id: 'out', type: NodeType.data, text: 'Escribir valor',
      metadata: {'isOutput': true}
    ),
    DiagramNode(id: 'end', type: NodeType.terminal, text: 'Fin', ...),
  ];

  final result = compiler.compile(nodes, connections);

  expect(result.success, isTrue);
  expect(result.generatedCode!.contains('printf('), isTrue);
  expect(result.generatedCode!.contains('%d'), isTrue); // int format
});

test('Generate if-else structure', () {
  final nodes = [
    DiagramNode(id: 'dec', type: NodeType.decision, text: 'x > 0', ...),
    // ... then and else branches
  ];

  final result = compiler.compile(nodes, connections);

  expect(result.generatedCode!.contains('if (x > 0)'), isTrue);
  expect(result.generatedCode!.contains('else'), isTrue);
});
```

---

## 23.2 Validación de Código Generado

### 23.2.1 Compilabilidad con GCC

Las pruebas de integración verifican que el código generado cumple con la sintaxis de C ANSI:

#### Pruebas de Estructura C

```dart
group('GEN-01: Generated Code Structure', () {
  test('GEN-01.1: Code has proper C structure', () {
    final result = nodes.compile(connections);

    expect(result.success, isTrue);
    final code = result.generatedCode!;

    // Required C structure elements
    expect(code.contains('#include'), isTrue,
        reason: 'Must have include directives');
    expect(code.contains('int main('), isTrue,
        reason: 'Must have main function');
    expect(code.contains('return 0;'), isTrue,
        reason: 'Must have return statement');
    expect(code.contains('{'), isTrue);
    expect(code.contains('}'), isTrue);
  });

  test('GEN-01.2: Code has balanced braces', () {
    final code = result.generatedCode!;

    final openBraces = '{'.allMatches(code).length;
    final closeBraces = '}'.allMatches(code).length;

    expect(openBraces, equals(closeBraces),
        reason: 'Braces must be balanced');
  });
});
```

#### Validación de Sintaxis

| Verificación | Descripción | Test |
|--------------|-------------|------|
| Includes | Directivas `#include` presentes | ✅ |
| Main | Función `int main(void)` | ✅ |
| Return | Sentencia `return 0;` | ✅ |
| Braces | Llaves balanceadas | ✅ |
| Semicolons | Sentencias terminan con `;` | ✅ |

### 23.2.2 Correctitud Funcional

Las pruebas de integración end-to-end verifican la correctitud del flujo completo:

#### Archivo: `compiler_integration_test.dart` (983 líneas)

```
compiler_integration_test.dart
├── E2E-01: Pipeline End-to-End Flow
│   ├── E2E-01.1: Minimal valid diagram compiles successfully
│   ├── E2E-01.2: Complete pipeline phases execute in order
│   ├── E2E-01.3: Symbol table propagates through all phases
│   └── E2E-01.4: Optimization affects generated code
├── ISO-01: Terminal Nodes
│   ├── ISO-01.1: Terminal nodes generate valid main()
│   └── ISO-01.2: Spanish and English variants work
├── ISO-02: Process Nodes
│   ├── ISO-02.1: Variable declaration
│   ├── ISO-02.2: Assignment expression
│   ├── ISO-02.3: Multiple variable declaration
│   └── ISO-02.4: Two sequential process nodes
├── ISO-03: Data Nodes (I/O)
│   ├── ISO-03.1: Output with printf
│   ├── ISO-03.2: Input with scanf
│   └── ISO-03.3: Format specifiers match data types
├── ISO-04: Decision Nodes
│   ├── ISO-04.1: Simple if condition
│   ├── ISO-04.2: If-else structure
│   └── ISO-04.3: Standard logical operators
├── ISO-05: Preparation Nodes
│   ├── ISO-05.1: Variable initialization
│   └── ISO-05.2: Loop representation with decision
├── ISO-06: Predefined Process Nodes
│   └── ISO-06.1: Predefined process handled
├── ISO-07: Comment Nodes
│   └── ISO-07.1: Comments don't break compilation
├── ISO-08: Connector Nodes
│   └── ISO-08.1: Basic flow compiles
├── GEN-01: Generated Code Structure
│   ├── GEN-01.1: Proper C structure
│   ├── GEN-01.2: Balanced braces
│   └── GEN-01.3: Statement semicolons
├── GEN-02: Code Compilability
│   ├── GEN-02.1: Syntactically valid C
│   └── GEN-02.2: I/O diagram generates valid code
├── ERR-01: Error Detection
│   ├── ERR-01.1: Lexical errors detected
│   ├── ERR-01.2: Syntax errors detected
│   └── ERR-01.3: Semantic warnings for unused
├── ERR-02: Error Recovery
│   └── ERR-02.1: Pipeline continues after non-fatal
└── MET-01: Compilation Metrics
    ├── MET-01.1: Metrics collected correctly
    └── MET-01.2: Report generation works
```

#### Métricas de Pruebas de Integración

| Métrica | Valor |
|---------|-------|
| Total de tests | 33 |
| Tests pasados | 33 (100%) |
| Cobertura de nodos | 8 tipos ISO 5807 |
| Cobertura de fases | 5 fases del pipeline |

---

## Ejecución de Pruebas

### Comandos de Ejecución

```bash
# Ejecutar todas las pruebas del compilador
flutter test test/compiler/

# Ejecutar pruebas específicas
flutter test test/compiler/lexical_analyzer_test.dart
flutter test test/compiler/syntax_analyzer_test.dart
flutter test test/compiler/semantic_analyzer_test.dart
flutter test test/compiler/code_optimizer_test.dart
flutter test test/compiler/code_generator_advanced_test.dart
flutter test test/compiler/compiler_integration_test.dart

# Ejecutar con cobertura
flutter test --coverage test/compiler/
```

### Resultado Esperado

```
✓ All tests passed!

Test Suites: 6 passed, 6 total
Tests:       240+ passed, 240+ total
Time:        ~15s
```

---

## Matriz de Cobertura de Pruebas

### Por Fase del Compilador

| Fase | Archivo de Test | Cobertura |
|------|-----------------|-----------|
| Léxico | `lexical_analyzer_test.dart` | ✅ Alta |
| Sintáctico | `syntax_analyzer_test.dart` | ✅ Alta |
| Semántico | `semantic_analyzer_test.dart` | ✅ Alta |
| Optimización | `code_optimizer_test.dart` | ✅ Alta |
| Generación | `code_generator_advanced_test.dart` | ✅ Alta |
| Integración | `compiler_integration_test.dart` | ✅ Alta |

### Por Tipo de Nodo ISO 5807

| NodeType | Pruebas | Estado |
|----------|---------|--------|
| `terminal` | E2E, ISO-01 | ✅ |
| `process` | ISO-02 (4 tests) | ✅ |
| `decision` | ISO-04 (3 tests) | ✅ |
| `data` | ISO-03 (3 tests) | ✅ |
| `preparation` | ISO-05 (2 tests) | ✅ |
| `predefinedProcess` | ISO-06 (1 test) | ✅ |
| `comment` | ISO-07 (1 test) | ✅ |
| `connector` | ISO-08 (1 test) | ✅ |

### Por Categoría de Error

| Categoría | Pruebas | Archivo |
|-----------|---------|---------|
| Errores léxicos | ERR-01.1 | `compiler_integration_test.dart` |
| Errores sintácticos | ERR-01.2 | `compiler_integration_test.dart` |
| Errores semánticos | ERR-01.3 | `compiler_integration_test.dart` |
| Recuperación | ERR-02.1 | `compiler_integration_test.dart` |

---

## Ejemplos de Código de Pruebas

### Test End-to-End Completo

```dart
test('E2E-01.1: Minimal valid diagram compiles successfully', () {
  // Arrange: Create the simplest valid diagram (Inicio -> Fin)
  final startNode = DiagramNode(
    id: 'e2e_start_1',
    type: NodeType.terminal,
    position: const Offset(200, 50),
    text: 'Inicio',
  );

  final endNode = DiagramNode(
    id: 'e2e_end_1',
    type: NodeType.terminal,
    position: const Offset(200, 150),
    text: 'Fin',
  );

  final nodes = [startNode, endNode];
  final connections = [
    Connection(source: startNode, target: endNode, label: ''),
  ];

  // Act
  final compiler = DiagramCompilerPipeline();
  final result = compiler.compile(nodes, connections);

  // Assert
  expect(result.success, isTrue,
      reason: 'Minimal diagram should compile successfully');
  expect(result.generatedCode, isNotNull);
  expect(result.generatedCode!.contains('#include <stdio.h>'), isTrue);
  expect(result.generatedCode!.contains('int main('), isTrue);
  expect(result.generatedCode!.contains('return 0;'), isTrue);

  // Verify all phases executed
  expect(result.lexicalResult, isNotNull);
  expect(result.syntaxResult, isNotNull);
  expect(result.semanticResult, isNotNull);
  expect(result.metrics.compilationTimeMs, greaterThan(0));
});
```

### Test de Detección de Errores

```dart
test('ERR-01.2: Syntax errors detected', () {
  final nodes = [
    _createTerminalNode('syn_start', 'Inicio', 50),
    DiagramNode(
      id: 'syn_invalid',
      type: NodeType.process,
      position: const Offset(200, 150),
      text: 'int x = (5 +', // Unclosed parenthesis
    ),
    _createTerminalNode('syn_end', 'Fin', 250),
  ];
  final connections = _createLinearConnections(nodes);

  final result = nodes.compile(connections);

  // Should detect the syntax error
  final hasSyntaxError = !result.success ||
      result.errors.getByPhase(CompilerPhase.syntactic).isNotEmpty;

  expect(hasSyntaxError, isTrue,
      reason: 'Should detect unbalanced parenthesis');
});
```

---

## Referencias del Código Fuente

| Archivo de Prueba | Líneas | Ubicación |
|-------------------|--------|-----------|
| `lexical_analyzer_test.dart` | 515 | `test/compiler/` |
| `syntax_analyzer_test.dart` | 1,055 | `test/compiler/` |
| `semantic_analyzer_test.dart` | 1,348 | `test/compiler/` |
| `code_optimizer_test.dart` | 950 | `test/compiler/` |
| `code_generator_advanced_test.dart` | 381 | `test/compiler/` |
| `compiler_integration_test.dart` | 983 | `test/compiler/` |

---

*Documentación generada para Trabajo Terminal 2026-A038 - FlowCode*
*Ciclo 6: Pruebas de Integración*
