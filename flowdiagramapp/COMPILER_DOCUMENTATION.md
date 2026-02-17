# FlowCode Compiler - Documentación Técnica

## Arquitectura del Compilador

FlowCode implementa un **compilador fuente a fuente** (source-to-source compiler) que transforma diagramas de flujo en código C funcional. El compilador está estructurado en **5 fases** siguiendo la arquitectura clásica de compiladores.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PIPELINE DE COMPILACIÓN                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   FASE 1    │───▶│   FASE 2    │───▶│   FASE 3    │───▶│   FASE 4    │  │
│  │   Léxico    │    │  Sintáctico │    │  Semántico  │    │ Optimización│  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│        │                  │                  │                  │          │
│        ▼                  ▼                  ▼                  ▼          │
│    [Tokens]            [AST]          [Symbol Table]      [Optimized AST] │
│                                                                             │
│                              ┌─────────────┐                                │
│                              │   FASE 5    │                                │
│                              │ Generación  │                                │
│                              │  de Código  │                                │
│                              └─────────────┘                                │
│                                    │                                        │
│                                    ▼                                        │
│                              [Código C]                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Estructura de Archivos

```
lib/compiler/
├── compiler.dart              # Barrel export para toda la API pública
├── compiler_pipeline.dart     # Orquestador principal del compilador
├── compiler_errors.dart       # Sistema de errores y severidades
├── token.dart                 # Definición de tokens
├── lexical_analyzer.dart      # Fase 1: Análisis Léxico
├── syntax_analyzer.dart       # Fase 2: Análisis Sintáctico
├── ast_nodes.dart             # Nodos del AST
├── semantic_analyzer.dart     # Fase 3: Análisis Semántico
├── symbol_table.dart          # Tabla de símbolos
├── code_optimizer.dart        # Fase 4: Optimización
└── code_generator_advanced.dart # Fase 5: Generación de Código Avanzada
```

---

## Fase 1: Análisis Léxico

### Descripción
El analizador léxico convierte el texto de cada nodo del diagrama en una secuencia de **tokens**. 

### Archivo Principal
`lib/compiler/lexical_analyzer.dart`

### Clase Principal
```dart
class DiagramLexicalAnalyzer {
  List<Token> tokenize(String text);
  DiagramLexicalResult analyzeDiagram(List<DiagramNode> nodes, List<Connection> connections);
}
```

### Tipos de Tokens Soportados
- **Identificadores**: `x`, `contador`, `suma`
- **Literales**: `42`, `3.14`, `"hello"`, `'a'`, `true`
- **Keywords C**: `int`, `float`, `char`, `if`, `else`, `while`, `for`, etc.
- **Keywords Español**: `Leer`, `Mostrar`, `Entero`, `Si`, `Mientras`, etc.
- **Operadores**: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `>`, `&&`, `||`, etc.
- **Puntuación**: `(`, `)`, `[`, `]`, `{`, `}`, `;`, `,`, `.`

### Resultado
```dart
class DiagramLexicalResult {
  List<NodeLexicalResult> nodeResults;  // Resultado por cada nodo
  SymbolTable symbolTable;               // Tabla de símbolos inicial
  List<LexicalError> errors;             // Errores encontrados
  List<Token> get allTokens;             // Todos los tokens
}
```

---

## Fase 2: Análisis Sintáctico

### Descripción
Construye un **Árbol de Sintaxis Abstracta (AST)** a partir de los tokens utilizando **Recursive Descent Parsing**.

### Archivo Principal
`lib/compiler/syntax_analyzer.dart`

### Clase Principal
```dart
class DiagramSyntaxAnalyzer {
  SyntaxAnalysisResult analyzeDiagram(List<DiagramNode> nodes, List<Connection> connections);
  ASTNode? parseExpression(String expression);
  bool validateExpression(String expression);
}
```

### Gramática Soportada

#### Expresiones
```
expression     → assignment | ternary
assignment     → IDENTIFIER '=' expression
ternary        → logicalOr ('?' expression ':' expression)?
logicalOr      → logicalAnd ('||' logicalAnd)*
logicalAnd     → equality ('&&' equality)*
equality       → comparison (('==' | '!=') comparison)*
comparison     → term (('<' | '>' | '<=' | '>=') term)*
term           → factor (('+' | '-') factor)*
factor         → unary (('*' | '/' | '%') unary)*
unary          → ('!' | '-' | '++' | '--')? primary
primary        → LITERAL | IDENTIFIER | '(' expression ')' | functionCall
```

#### Sentencias
```
statement      → declaration | assignment | ifStmt | whileStmt | forStmt | 
                 ioStmt | returnStmt | expression
declaration    → type IDENTIFIER ('=' expression)? ';'
ifStmt         → 'if' '(' expression ')' statement ('else' statement)?
whileStmt      → 'while' '(' expression ')' statement
forStmt        → 'for' '(' forInit? ';' expression? ';' expression? ')' statement
```

### Nodos del AST
```dart
// Programa completo
class ProgramNode {
  List<DiagramASTNode> diagramNodes;
  List<DeclarationStatementNode> globalDeclarations;
}

// Expresiones
abstract class ExpressionNode extends ASTNode {}
class BinaryExpressionNode extends ExpressionNode {}
class UnaryExpressionNode extends ExpressionNode {}
class LiteralNode extends ExpressionNode {}
class IdentifierNode extends ExpressionNode {}
class FunctionCallNode extends ExpressionNode {}

// Sentencias
abstract class StatementNode extends ASTNode {}
class DeclarationStatementNode extends StatementNode {}
class AssignmentStatementNode extends StatementNode {}
class IfStatementNode extends StatementNode {}
class WhileStatementNode extends StatementNode {}
class ForStatementNode extends StatementNode {}
```

### Resultado
```dart
class SyntaxAnalysisResult {
  ProgramNode? ast;
  List<NodeSyntaxResult> nodeResults;
  List<CompilerError> errors;
  bool isValid;
}
```

---

## Fase 3: Análisis Semántico

### Descripción
Verifica la **coherencia lógica** del programa: verificación de tipos, variables no declaradas, alcance de variables, etc.

### Archivo Principal
`lib/compiler/semantic_analyzer.dart`

### Clase Principal
```dart
class DiagramSemanticAnalyzer {
  SemanticAnalysisResult analyzeDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections, {
    SymbolTable? existingSymbolTable,
    ProgramNode? ast,
  });
}
```

### Verificaciones Realizadas

1. **Verificación de Tipos**
   - Compatibilidad en asignaciones
   - Operaciones válidas entre tipos
   - Conversiones implícitas permitidas

2. **Análisis de Alcance (Scope)**
   - Variables declaradas antes de uso
   - Reasignación de constantes
   - Shadowing de variables

3. **Detección de Errores**
   - Variables no declaradas
   - Variables no inicializadas
   - Variables no usadas (warning)
   - División por cero (warning)

### Tabla de Símbolos
```dart
class SymbolTable {
  void declare(String name, SymbolInfo info);
  SymbolInfo? lookup(String name);
  void enterScope();
  void exitScope();
  List<SymbolInfo> get allSymbols;
}

class SymbolInfo {
  String name;
  DataType dataType;
  SymbolCategory category;
  int scopeLevel;
  bool isInitialized;
  bool isUsed;
}
```

### Tipos de Datos Soportados
```dart
enum DataType {
  integer,   // int
  float,     // float
  double_,   // double
  char,      // char
  string,    // char*
  boolean,   // bool
  void_,     // void
  array,     // []
  unknown,   // tipo no determinado
}
```

### Resultado
```dart
class SemanticAnalysisResult {
  SymbolTable symbolTable;
  List<NodeSemanticResult> nodeResults;
  List<CompilerError> errors;
  List<CompilerError> warnings;
  bool isValid;
}
```

---

## Fase 4: Optimización

### Descripción
Mejora el AST aplicando **optimizaciones** que reducen el tamaño y mejoran la eficiencia del código generado.

### Archivo Principal
`lib/compiler/code_optimizer.dart`

### Clase Principal
```dart
class DiagramCodeOptimizer {
  OptimizationResult optimize(ProgramNode ast, {SymbolTable? symbolTable});
}
```

### Niveles de Optimización
```dart
enum OptimizationLevel {
  none,       // Nivel 0: Sin optimización
  basic,      // Nivel 1: Solo constant folding
  standard,   // Nivel 2: Todas excepto agresivas (default)
  aggressive, // Nivel 3: Todas las optimizaciones
}
```

### Optimizaciones Implementadas

#### 1. Constant Folding (Plegado de Constantes)
Evalúa expresiones constantes en tiempo de compilación.
```c
// Antes:
int x = 2 + 3 * 4;
// Después:
int x = 14;
```

#### 2. Dead Code Elimination (Eliminación de Código Muerto)
Elimina código inalcanzable o ramas con condiciones constantes.
```c
// Antes:
if (1 == 1) { doSomething(); }
else { neverReached(); }
// Después:
doSomething();
```

#### 3. Expression Simplification (Simplificación de Expresiones)
Aplica identidades algebraicas.
```c
// Antes:           // Después:
x + 0       →       x
x * 1       →       x
x * 0       →       0
x - x       →       0
x / 1       →       x
x || true   →       true
x && false  →       false
```

#### 4. Control Flow Optimization (Optimización de Flujo de Control)
Elimina estructuras de control vacías o redundantes.
```c
// Antes:
if (condition) {}
// Después: (eliminado)
```

### Métricas de Optimización
```dart
class OptimizationMetrics {
  int originalNodeCount;
  int optimizedNodeCount;
  int constantsFolded;
  int deadCodeRemoved;
  int expressionsSimplified;
  int controlFlowOptimized;
  double sizeReductionPercent;
}
```

### Resultado
```dart
class OptimizationResult {
  bool success;
  ProgramNode? optimizedAST;
  List<OptimizationPassResult> passResults;
  int totalOptimizations;
  OptimizationMetrics metrics;
}
```

---

## Fase 5: Generación de Código

### Descripción
Genera código C funcional a partir del AST optimizado utilizando la **tabla de símbolos** para determinar tipos de datos correctos.

### Archivo Principal
`lib/compiler/code_generator_advanced.dart`

### Clase Principal
```dart
class AdvancedCodeGenerator {
  CodeGenerationResult generate({
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required SymbolTable symbolTable,
    ProgramNode? ast,
  });
}
```

### Características
- **Tipos correctos**: Usa la tabla de símbolos para determinar `%d`, `%f`, `%c`, `%s`
- **Múltiples variables**: Soporta `printf("%d %f %c\n", x, y, z);`
- **Fallback inteligente**: Infiere tipos por convención de nombres si no está en tabla
- **Comentarios**: Genera comentarios descriptivos del diagrama

### Opciones de Generación
```dart
class CodeGenOptions {
  bool includeComments;     // Incluir comentarios
  bool includeTimestamp;    // Incluir fecha de generación
  String indentation;       // Indentación (default: 4 espacios)
  String targetCStandard;   // c99, c11, c17
  bool debugMode;           // Modo debug
}
```

### Resultado
```dart
class CodeGenerationResult {
  bool success;
  String code;
  List<CompilerError> errors;
  CodeGenMetrics metrics;
}
```

### Integración con UI

#### PopupMenuButton en el Editor
```dart
// En editor_screen.dart
PopupMenuButton<String>(
  icon: const Icon(Icons.code),
  tooltip: 'Generar código',
  itemBuilder: (context) => [
    PopupMenuItem(value: 'simple', child: Text('Generador Simple')),
    PopupMenuItem(value: 'compiler', child: Text('Compilador Avanzado')),
  ],
)
```

#### 2. CompilerResultsDialog
Un diálogo con pestañas que muestra:
- **General**: Métricas, tiempos, log de compilación
- **Léxico**: Tokens generados por nodo
- **Sintáctico**: AST visualizado en árbol
- **Semántico**: Tabla de símbolos
- **Optimización**: Métricas y cambios aplicados
- **Código**: Código C generado

### Uso del Compilador

```dart
// Compilación básica
final compiler = DiagramCompilerPipeline();
final result = compiler.compile(nodes, connections);

// Con opciones personalizadas
final compiler = DiagramCompilerPipeline(
  options: CompilerOptions(
    optimizationLevel: 2,
    generateComments: true,
    strictTypeChecking: false,
  ),
);
final result = compiler.compile(nodes, connections);

// Usar extensión en lista de nodos
final result = nodes.compile(connections);
```

### Opciones del Compilador
```dart
class CompilerOptions {
  int optimizationLevel;      // 0-3
  bool generateComments;       // Comentarios en código generado
  bool strictTypeChecking;     // Verificación estricta de tipos
  bool showWarnings;           // Mostrar advertencias
  String targetCStandard;      // c99, c11, c17
  bool includeDebugInfo;       // Información de debug
  String language;             // es, en (para mensajes)
}
```

---

## Sistema de Errores

### Severidades
```dart
enum CompilerSeverity {
  info,     // Información
  warning,  // Advertencia (compilación continúa)
  error,    // Error (puede fallar)
  fatal,    // Error fatal (detiene compilación)
}
```

### Fases de Error
```dart
enum CompilerPhase {
  structural,   // Validación estructural
  lexical,      // Análisis léxico
  syntactic,    // Análisis sintáctico
  semantic,     // Análisis semántico
  optimization, // Optimización
  codeGen,      // Generación de código
}
```

### Códigos de Error
Más de 70 códigos de error definidos en `CompilerErrorCode`, incluyendo:
- Errores léxicos: `invalidCharacter`, `unterminatedString`, etc.
- Errores sintácticos: `unexpectedToken`, `expectedExpression`, etc.
- Errores semánticos: `undeclaredVariable`, `typeMismatch`, etc.

---

## Métricas de Compilación

```dart
class CompilationMetrics {
  int compilationTimeMs;     // Tiempo total
  int nodesProcessed;        // Nodos del diagrama
  int tokensGenerated;       // Tokens extraídos
  int symbolsInTable;        // Símbolos en tabla
  int errorCount;            // Errores
  int warningCount;          // Advertencias
  
  // Tiempos por fase
  int lexicalTimeMs;
  int syntacticTimeMs;
  int semanticTimeMs;
  int optimizationTimeMs;
  int codeGenTimeMs;
}
```

---

## Tests

### Ubicación
```
test/compiler/
├── lexical_analyzer_test.dart        # Tests del analizador léxico
├── syntax_analyzer_test.dart         # Tests del parser
├── semantic_analyzer_test.dart       # Tests del analizador semántico
├── code_optimizer_test.dart          # Tests del optimizador
└── code_generator_advanced_test.dart # Tests del generador de código
```

### Ejecutar Tests
```bash
flutter test test/compiler/
```

---

## Ejemplo de Uso Completo

```dart
import 'package:flowdiagramapp/compiler/compiler.dart';

void compileMyDiagram(List<DiagramNode> nodes, List<Connection> connections) {
  // Crear compilador
  final compiler = DiagramCompilerPipeline(
    options: const CompilerOptions(
      optimizationLevel: 2,
      generateComments: true,
    ),
  );
  
  // Compilar
  final result = compiler.compile(nodes, connections);
  
  // Verificar resultado
  if (result.success) {
    print('✅ Compilación exitosa en ${result.metrics.compilationTimeMs}ms');
    print('Tokens: ${result.metrics.tokensGenerated}');
    print('Símbolos: ${result.metrics.symbolsInTable}');
    
    // Mostrar AST
    if (result.ast != null) {
      print(result.ast!.toTreeString());
    }
    
    // Mostrar tabla de símbolos
    if (result.symbolTable != null) {
      for (final symbol in result.symbolTable!.allSymbols) {
        print('${symbol.name}: ${symbol.dataType.cRepresentation}');
      }
    }
    
    // Mostrar optimizaciones
    if (result.optimizationResult != null) {
      print('Optimizaciones: ${result.optimizationResult!.totalOptimizations}');
    }
  } else {
    print('❌ Errores de compilación:');
    for (final error in result.errors.all) {
      print('  ${error.severity.emoji} ${error.message}');
    }
  }
}
```

---

## Contribuir

Para agregar nuevas optimizaciones o mejoras al compilador:

1. **Fase 1 (Léxico)**: Modificar `lexical_analyzer.dart`
2. **Fase 2 (Sintáctico)**: Modificar `syntax_analyzer.dart` y `ast_nodes.dart`
3. **Fase 3 (Semántico)**: Modificar `semantic_analyzer.dart`
4. **Fase 4 (Optimización)**: Modificar `code_optimizer.dart`
5. **Agregar tests**: En `test/compiler/`

---

*Documentación generada para FlowCode Compiler v1.0*
