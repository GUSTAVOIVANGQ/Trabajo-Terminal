# Documentación de Arquitectura: FlowCode Compiler

## 📋 Resumen Ejecutivo

**FlowCode** es un compilador fuente-a-fuente que traduce diagramas de flujo visuales a código C estructurado mediante un pipeline de análisis multinivel. La aplicación implementa un compilador completo adaptado para procesamiento de grafos visuales, incluyendo análisis léxico, sintáctico, semántico y optimización.

---

## 🏗️ Arquitectura General del Sistema

### Arquitectura en Capas (3-Tier Architecture)

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐│
│  │ Interfaz UI │ │Editor Visual│ │Visualizador │ │ Gestor   ││
│  │   Flutter   │ │ Diagramas   │ │   Código    │ │Proyectos ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘│
└─────────────────────────────────────────────────────────────┘
                            ↕️
┌─────────────────────────────────────────────────────────────┐
│                 CAPA DE LÓGICA DE NEGOCIO                     │
│                    (COMPILADOR PIPELINE)                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐│
│  │  Análisis   │ │  Análisis   │ │  Análisis   │ │Generador ││
│  │   Léxico    │ │ Sintáctico  │ │ Semántico   │ │ Código C ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘│
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │ Validador   │ │Representación│ │Optimizador  │              │
│  │Estructural  │ │  Intermedia  │ │   Código    │              │
│  └─────────────┘ └─────────────┘ └─────────────┘              │
└─────────────────────────────────────────────────────────────┘
                            ↕️
┌─────────────────────────────────────────────────────────────┐
│                   CAPA DE PERSISTENCIA                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐│
│  │Almacenamiento│ │Almacenamiento│ │Almacenamiento│ │ Métricas ││
│  │  Proyectos  │ │  Diagramas  │ │   Código     │ │Compilador││
│  │   SQLite    │ │   SQLite    │ │   Local      │ │ SQLite   ││
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Pipeline de Compilación Multinivel (CORREGIDO)

### Diagrama de Flujo de Compilación Refinado

```
📊 ENTRADA: Diagrama de Flujo (Grafo Visual)
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 1: VALIDACIÓN ESTRUCTURAL DEL GRAFO                    │
│ • Análisis de topología del grafo (DFS/BFS)                  │
│ • Verificación de símbolos obligatorios                      │
│ • Validación de conexiones y cardinalidad                    │
│ • Detección de ciclos infinitos (Algoritmo de Tarjan)        │
│ └→ Algoritmos: DFS, BFS, Tarjan Cycle Detection             │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 2: ANÁLISIS LÉXICO DE CONTENIDO DE NODOS               │
│ • Tokenización del texto en cada nodo                        │
│ • Reconocimiento de identificadores, operadores, literales   │
│ • Construcción de tabla de símbolos preliminar               │
│ • Validación de nombres de variables                         │
│ └→ Algoritmos: Pattern Matching, Regular Expressions        │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 3: ANÁLISIS SINTÁCTICO DE EXPRESIONES                  │
│ • Parser de expresiones aritméticas/lógicas                  │
│ • Construcción de AST por nodo                               │
│ • Verificación de sintaxis de asignaciones                   │
│ • Balanceo de operadores y paréntesis                        │
│ └→ Algoritmos: Recursive Descent Parser, Shunting Yard      │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 4: ANÁLISIS SEMÁNTICO Y VALIDACIÓN                     │
│ • Verificación de tipos de datos                             │
│ • Análisis de alcanzabilidad de variables                    │
│ • Data Flow Analysis (variables definidas/usadas)            │
│ • Análisis de scope y visibilidad                            │
│ • Validación de compatibilidad de operaciones                │
│ └→ Algoritmos: Type Checking, Data Flow Analysis, DFS       │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 5: OPTIMIZACIÓN INTERMEDIA                             │
│ • Eliminación de código muerto                               │
│ • Simplificación de expresiones constantes                   │
│ • Optimización de estructuras de control                     │
│ • Reducción de redundancias                                  │
│ └→ Algoritmos: Constant Folding, Dead Code Elimination      │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ NIVEL 6: GENERACIÓN DE CÓDIGO C (BACKEND)                    │
│ • Traducción de representación intermedia a C                │
│ • Optimización de código generado                            │
│ • Formateo y documentación automática                        │
│ • Inyección de headers y librerías                           │
│ └→ Algoritmos: Code Generation, Template Engine             │
└─────────────────────────────────────────────────────────────┘
                        ↓
💻 SALIDA: Código C Estándar (Compilable en GCC/Clang)
```

---

## 🧮 Algoritmos Específicos por Fase

### Fase 1: Validación Estructural
```dart
Algoritmos principales:
1. **Depth-First Search (DFS)**: Recorrido del grafo para validar conectividad
2. **Breadth-First Search (BFS)**: Análisis de niveles y alcanzabilidad
3. **Tarjan's Algorithm**: Detección de componentes fuertemente conectados
4. **Cycle Detection**: Detección de bucles infinitos potenciales
```

### Fase 2: Análisis Léxico
```dart
Algoritmos principales:
1. **Finite State Automaton**: Reconocimiento de tokens
2. **Regular Expression Matching**: Identificación de patrones
3. **Hash Table**: Manejo eficiente de tabla de símbolos
4. **String Pattern Matching**: Reconocimiento de identificadores
```

### Fase 3: Análisis Sintáctico
```dart
Algoritmos principales:
1. **Recursive Descent Parser**: Parsing de expresiones
2. **Shunting Yard Algorithm**: Conversión infix a postfix
3. **AST Construction**: Construcción de árbol sintáctico abstracto
4. **Precedence Climbing**: Manejo de precedencia de operadores
```

### Fase 4: Análisis Semántico
```dart
Algoritmos principales:
1. **Data Flow Analysis**: Análisis de definiciones y usos
2. **Type Checking Algorithm**: Verificación de tipos
3. **Symbol Table Management**: Manejo de scope y visibilidad
4. **Reachability Analysis**: Análisis de código alcanzable
```

### Fase 5: Optimización
```dart
Algoritmos principales:
1. **Constant Folding**: Evaluación de expresiones constantes
2. **Dead Code Elimination**: Eliminación de código no usado
3. **Control Flow Optimization**: Optimización de saltos
4. **Common Subexpression Elimination**: Eliminación de redundancias
```

---

## 📁 Estructura de Archivos del Compilador

```
lib/
├── compiler/
│   ├── compiler.dart                   # Barrel export para API pública
│   ├── compiler_pipeline.dart          # Orquestador principal del pipeline
│   ├── compiler_errors.dart            # Sistema de errores y severidades
│   ├── token.dart                       # Definición de tokens
│   ├── lexical_analyzer.dart           # Fase 1: Análisis Léxico
│   ├── syntax_analyzer.dart            # Fase 2: Análisis Sintáctico
│   ├── ast_nodes.dart                   # Nodos del AST
│   ├── semantic_analyzer.dart          # Fase 3: Análisis Semántico
│   ├── symbol_table.dart               # Tabla de símbolos
│   ├── code_optimizer.dart             # Fase 4: Optimización
│   └── code_generator_advanced.dart    # Fase 5: Generación de Código
├── models/
│   ├── code_generator.dart             # Generador de código simple (legacy)
│   ├── diagram_validator.dart          # Validación estructural del diagrama
│   └── ... (archivos existentes)
└── ... (estructura existente)
```

---

## 🔍 Especificación Detallada de Componentes

### 1. Validador Estructural (lib/models/diagram_validator.dart)
```dart
class DiagramValidator {
  static ValidationResult validateDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections,
  )
  static ValidationResult _validateStartNode(List<DiagramNode> nodes)
  static ValidationResult _validateEndNode(List<DiagramNode> nodes)
  static ValidationResult _validateConnections(nodes, connections)
  static ValidationResult _validateNoDisconnectedNodes(nodes, connections)
  static ValidationResult _validateISO5807Symbols(nodes, connections)
}
```

### 2. Analizador Léxico (lib/compiler/lexical_analyzer.dart)
```dart
class DiagramLexicalAnalyzer {
  List<Token> tokenize(String text)              // Tokenización de texto
  List<Token> tokenizeNode(DiagramNode node)     // Tokenización por nodo
  DiagramLexicalResult analyzeDiagram(           // Análisis completo
    List<DiagramNode> nodes,
    List<Connection> connections,
  )
}
```

### 3. Analizador Sintáctico (lib/compiler/syntax_analyzer.dart)
```dart
class DiagramSyntaxAnalyzer {
  SyntaxAnalysisResult analyzeDiagram(           // Análisis sintáctico completo
    List<DiagramNode> nodes,
    List<Connection> connections,
  )
  NodeSyntaxResult analyzeNode(DiagramNode node) // Análisis por nodo
  ASTNode? parseExpression(String expression)    // Parser de expresiones
  bool validateExpression(String expression)     // Validación de expresión
}
```

### 4. Analizador Semántico (lib/compiler/semantic_analyzer.dart)
```dart
class DiagramSemanticAnalyzer {
  SemanticAnalysisResult analyzeDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections, {
    SymbolTable? existingSymbolTable,
    ProgramNode? ast,
  })
  // Incluye verificación de tipos, análisis de scope, detección de errores
}
```

### 5. Optimizador de Código (lib/compiler/code_optimizer.dart)
```dart
class DiagramCodeOptimizer {
  OptimizationResult optimize(
    ProgramNode ast, {
    SymbolTable? symbolTable,
  })
  // Implementa: Constant Folding, Dead Code Elimination,
  // Expression Simplification, Control Flow Optimization
}
```

### 6. Generador de Código Avanzado (lib/compiler/code_generator_advanced.dart)
```dart
class AdvancedCodeGenerator {
  CodeGenerationResult generate({
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required SymbolTable symbolTable,
    ProgramNode? ast,
  })
  // Genera código C usando información semántica de la tabla de símbolos
}
```

### 7. Pipeline Principal (lib/compiler/compiler_pipeline.dart)
```dart
class DiagramCompilerPipeline {
  CompilationResult compile(
    List<DiagramNode> nodes,
    List<Connection> connections,
  )
  // Orquesta las 5 fases: Léxico → Sintáctico → Semántico → Optimización → Generación
}
```

---

## 📊 Métricas y Validación

### Métricas de Compilación (Implementadas)
```dart
class CompilationMetrics {
  int compilationTimeMs;     // Tiempo total de compilación
  int nodesProcessed;        // Nodos del diagrama procesados
  int tokensGenerated;       // Tokens extraídos
  int symbolsInTable;        // Símbolos en tabla
  int errorCount;            // Errores encontrados
  int warningCount;          // Advertencias generadas
  
  // Tiempos por fase
  int lexicalTimeMs;         // Tiempo análisis léxico
  int syntacticTimeMs;       // Tiempo análisis sintáctico
  int semanticTimeMs;        // Tiempo análisis semántico
  int optimizationTimeMs;    // Tiempo optimización
  int codeGenTimeMs;         // Tiempo generación de código
}

class OptimizationMetrics {
  int originalNodeCount;         // Nodos AST originales
  int optimizedNodeCount;        // Nodos AST optimizados
  int constantsFolded;           // Constantes plegadas
  int deadCodeRemoved;           // Código muerto eliminado
  int expressionsSimplified;     // Expresiones simplificadas
  int controlFlowOptimized;      // Optimizaciones de flujo
  double sizeReductionPercent;   // Porcentaje de reducción
}
```

---

## 🚀 Casos de Uso del Compilador

### Caso de Uso 1: Diagrama Simple
```
Input:  [Inicio] → [x = 5] → [y = x + 2] → [Mostrar y] → [Fin]

Validación Estructural: ✅ Estructura válida (DiagramValidator)
Fase 1 (Léxico): x, =, 5, y, =, x, +, 2, Mostrar, y
Fase 2 (Sintáctico): AST { Assignment(x, 5), Assignment(y, BinaryOp(x, +, 2)), Print(y) }
Fase 3 (Semántico): ✅ Tipos consistentes, variables definidas antes de uso
Fase 4 (Optimización): y = x + 2 → y = 7 (si x es constante)
Fase 5 (Generación): Código C optimizado
```

### Caso de Uso 2: Diagrama con Decisión
```
Input:  [Inicio] → [n = 10] → [¿n > 0?] → [Sí: n--] → [No: Fin]

Validación Estructural: ✅ Flujo de control válido
Fase 1 (Léxico): n, =, 10, n, >, 0, n, --, ...
Fase 2 (Sintáctico): AST { Assignment(n, 10), IfStatement(BinaryOp(n, >, 0), Decrement(n)) }
Fase 3 (Semántico): ✅ Operadores compatibles con tipos
Fase 4 (Optimización): Optimización de bucle
Fase 5 (Generación): Código C con while/for optimizado
```

---

## ⚙️ Configuración y Opciones del Compilador

### Opciones de Compilación (Implementadas)
```dart
class CompilerOptions {
  int optimizationLevel;       // 0-3 (none, basic, standard, aggressive)
  bool generateComments;       // Comentarios en código generado
  bool strictTypeChecking;     // Verificación estricta de tipos
  bool showWarnings;           // Mostrar advertencias
  String targetCStandard;      // c99, c11, c17
  bool includeDebugInfo;       // Información de debug
  String language;             // es, en (para mensajes)
}

enum OptimizationLevel { none, basic, standard, aggressive }
```

### Opciones de Generación de Código
```dart
class CodeGenOptions {
  bool includeComments;     // Incluir comentarios descriptivos
  bool includeTimestamp;    // Incluir fecha de generación
  String indentation;       // Indentación (default: 4 espacios)
  String targetCStandard;   // c99, c11, c17
  bool debugMode;           // Modo debug con printf adicionales
}
```

---

## 🔧 Integración con la Aplicación

### Uso del Compilador desde la UI

#### 1. Compilación Básica
```dart
import 'package:flowdiagramapp/compiler/compiler.dart';

void _compileAndShowResults() {
  final compiler = DiagramCompilerPipeline(
    options: const CompilerOptions(
      optimizationLevel: 2,
      generateComments: true,
    ),
  );
  
  final result = compiler.compile(nodes, connections);
  
  if (result.success) {
    // Mostrar código generado
    _showGeneratedCode(result.generatedCode);
  } else {
    // Mostrar errores
    _showCompilerErrors(result.errors);
  }
}
```

#### 2. Diálogo de Resultados del Compilador
La aplicación incluye `CompilerResultsDialog` con pestañas para:
- **General**: Métricas y tiempos de compilación
- **Léxico**: Tokens generados por nodo
- **Sintáctico**: AST visualizado en árbol
- **Semántico**: Tabla de símbolos
- **Optimización**: Métricas y cambios aplicados
- **Código**: Código C generado con resaltado de sintaxis

---

## 📝 Tests del Compilador

### Ubicación de Tests
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

*Documentación generada para FlowCode v1.0 - Compilador Visual*