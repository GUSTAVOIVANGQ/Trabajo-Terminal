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
│   ├── lexical_analyzer.dart         # Fase 2: Análisis Léxico
│   ├── syntax_analyzer.dart          # Fase 3: Análisis Sintáctico
│   ├── semantic_analyzer.dart        # Fase 4: Análisis Semántico
│   ├── code_optimizer.dart           # Fase 5: Optimización
│   ├── intermediate_representation.dart # Representación intermedia
│   ├── symbol_table.dart             # Tabla de símbolos
│   ├── ast_nodes.dart                # Nodos del AST
│   ├── compiler_metrics.dart         # Métricas del compilador
│   └── compiler_pipeline.dart        # Orquestador principal
├── models/
│   ├── code_generator.dart           # Fase 6: Generación (MEJORADO)
│   ├── diagram_validator.dart        # Fase 1: Validación (EXISTENTE)
│   └── ... (archivos existentes)
└── ... (estructura existente)
```

---

## 🔍 Especificación Detallada de Componentes

### 1. Validador Estructural (Existente - Mejorar)
```dart
class EnhancedDiagramValidator {
  // Algoritmos de grafos
  bool validateGraphTopology(List<DiagramNode> nodes, List<Connection> connections)
  List<List<DiagramNode>> detectStronglyConnectedComponents() // Tarjan
  bool detectInfiniteLoops() // Cycle detection
  List<DiagramNode> findUnreachableNodes() // DFS/BFS
}
```

### 2. Analizador Léxico (Nuevo)
```dart
class DiagramLexicalAnalyzer {
  List<Token> tokenizeNode(DiagramNode node) // FSM + Regex
  SymbolTable buildSymbolTable(List<DiagramNode> nodes)
  bool validateIdentifier(String identifier) // Pattern matching
  TokenType classifyToken(String text) // Hash table lookup
}
```

### 3. Analizador Sintáctico (Nuevo)
```dart
class DiagramSyntaxAnalyzer {
  AST parseExpression(List<Token> tokens) // Recursive descent
  bool validateAssignment(DiagramNode node) // Grammar checking
  ExpressionTree buildExpressionTree(String expression) // Shunting yard
  bool checkSyntaxValidity(AST tree) // Tree traversal
}
```

### 4. Analizador Semántico (Nuevo)
```dart
class DiagramSemanticAnalyzer {
  bool performTypeChecking(AST ast) // Type inference
  DataFlowGraph analyzeDataFlow(List<DiagramNode> nodes) // DFA
  bool validateVariableScope(SymbolTable symbolTable) // Scope analysis
  List<SemanticError> findSemanticErrors() // Error collection
}
```

### 5. Optimizador de Código (Nuevo)
```dart
class DiagramCodeOptimizer {
  AST foldConstants(AST ast) // Constant folding
  List<DiagramNode> eliminateDeadCode(List<DiagramNode> nodes) // DCE
  ControlFlowGraph optimizeControlFlow(ControlFlowGraph cfg) // CFG optimization
  String optimizeGeneratedCode(String code) // Peephole optimization
}
```

### 6. Generador de Código Mejorado (creado nuevo archivo)
```dart
class EnhancedCodeGenerator {
  String generateOptimizedCode(
    List<DiagramNode> nodes,
    List<Connection> connections,
    CompilerOptions options
  )
  
  // Nuevos métodos
  String generateFromIR(IntermediateRepresentation ir)
  String applyCodeTemplates(Map<String, dynamic> context)
  String injectOptimizations(String baseCode)
}
```

---

## 📊 Métricas y Validación

### Métricas de Calidad del Compilador
```dart
class CompilerQualityMetrics {
  // Métricas por fase
  double lexicalAccuracy;      // % tokens correctamente identificados
  double syntaxValidation;     // % expresiones sintácticamente válidas  
  double semanticPrecision;    // % errores semánticos detectados
  double optimizationGain;     // % mejora en líneas/performance código
  
  // Métricas generales
  double compilationSuccess;   // % diagramas que compilan exitosamente
  double codeQuality;         // % código generado que compila en GCC
  double performanceGain;     // Mejora vs generación directa actual
}
```

---

## 🚀 Casos de Uso del Compilador

### Caso de Uso 1: Diagrama Simple
```
Input:  [Inicio] → [x = 5] → [y = x + 2] → [Mostrar y] → [Fin]

Fase 1: ✅ Estructura válida
Fase 2: x, =, 5, y, =, x, +, 2, Mostrar, y
Fase 3: AST { Assignment(x, 5), Assignment(y, BinaryOp(x, +, 2)), Print(y) }
Fase 4: ✅ Tipos consistentes, variables definidas antes de uso
Fase 5: Optimización: y = x + 2 → y = 7 (si x es constante)
Fase 6: Código C optimizado
```

### Caso de Uso 2: Diagrama con Decisión
```
Input:  [Inicio] → [n = 10] → [¿n > 0?] → [Sí: n--] → [No: Fin]

Fase 1: ✅ Flujo de control válido
Fase 2: n, =, 10, n, >, 0, n, --, ...
Fase 3: AST { Assignment(n, 10), IfStatement(BinaryOp(n, >, 0), Decrement(n)) }
Fase 4: ✅ Operadores compatibles con tipos
Fase 5: Optimización de bucle
Fase 6: Código C con while/for optimizado
```

---

## ⚙️ Configuración y Opciones del Compilador

### Opciones de Compilación
```dart
class CompilerOptions {
  OptimizationLevel optimizationLevel; // -O0, -O1, -O2, -O3
  bool enableWarnings;
  bool strictTypeChecking;
  bool generateComments;
  TargetVersion targetCStandard; // C99, C11, C17
  bool enableDebugInfo;
}

enum OptimizationLevel { none, basic, standard, aggressive }
enum TargetVersion { c99, c11, c17 }
```

---

## 🔧 Integración con la Aplicación Existente

### Modificaciones Necesarias

#### 1. Editor Screen (Modificar)
```dart
// Agregar nuevas opciones de compilación
void _generateOptimizedCode() {
  final options = CompilerOptions(
    optimizationLevel: OptimizationLevel.standard,
    enableWarnings: true,
    strictTypeChecking: true,
  );
  
  final compiler = DiagramCompilerPipeline();
  final result = compiler.compile(nodes, connections, options);
  
  _showCompilerResults(result);
}
```

#### 2. Validación Mejorada (Modificar)
```dart
// Usar el nuevo sistema de validación multinivel
ValidationResult _validateDiagramEnhanced() {
  final pipeline = DiagramCompilerPipeline();
  return pipeline.validateOnly(nodes, connections);
}
```

---

## 🎯 Plan de Implementación

### Cronograma Detallado (14 semanas)

**Semanas 1-2: Análisis Léxico**
- Implementar `DiagramLexicalAnalyzer`
- Crear sistema de tokens
- Desarrollar tabla de símbolos

**Semanas 3-5: Análisis Sintáctico**
- Implementar `DiagramSyntaxAnalyzer`
- Crear parser de expresiones
- Construir sistema AST

**Semanas 6-9: Análisis Semántico**
- Implementar `DiagramSemanticAnalyzer`
- Desarrollar verificación de tipos
- Crear análisis de flujo de datos

**Semanas 10-12: Optimización**
- Implementar `DiagramCodeOptimizer`
- Desarrollar algoritmos de optimización
- Integrar con generador existente

**Semanas 13-14: Integración**
- Integrar todas las fases
- Pruebas completas del sistema
- Documentación final y métricas

---

## 📈 Validación y Pruebas

### Casos de Prueba por Fase
```dart
class CompilerTestSuite {
  // Pruebas de análisis léxico
  void testTokenization();
  void testSymbolTableConstruction();
  
  // Pruebas de análisis sintáctico
  void testExpressionParsing();
  void testASTConstruction();
  
  // Pruebas de análisis semántico
  void testTypeChecking();
  void testDataFlowAnalysis();
  
  // Pruebas de optimización
  void testConstantFolding();
  void testDeadCodeElimination();
  
  // Pruebas de integración
  void testEndToEndCompilation();
  void testPerformanceMetrics();
}
```

---

*Documentación generada para FlowCode v1.0 - Compilador Visual*