/// Compiler Pipeline for FlowCode Diagram Compiler
/// Orchestrates all compilation phases
///
/// This is the main entry point for the source-to-source compiler
/// that transforms flowchart diagrams into C code.
///
/// Implemented phases:
/// - Phase 1: Lexical Analysis
/// - Phase 2: Syntactic Analysis
/// - Phase 3: Semantic Analysis
/// - Phase 4: Optimization
/// - Phase 5: Code Generation

import '../models/diagram_node.dart';
import 'token.dart';
import 'symbol_table.dart';
import 'lexical_analyzer.dart';
import 'syntax_analyzer.dart';
import 'semantic_analyzer.dart';
import 'code_optimizer.dart';
import 'code_generator_advanced.dart';
import 'ast_nodes.dart';
import 'compiler_errors.dart';

/// Options for the compiler pipeline
class CompilerOptions {
  /// Optimization level (0 = none, 1 = basic, 2 = standard, 3 = aggressive)
  final int optimizationLevel;

  /// Whether to generate comments in the output code
  final bool generateComments;

  /// Whether to enable strict type checking
  final bool strictTypeChecking;

  /// Whether to show warnings
  final bool showWarnings;

  /// Target C standard (c99, c11, c17)
  final String targetCStandard;

  /// Whether to include debug information
  final bool includeDebugInfo;

  /// Language for error messages (es, en)
  final String language;

  const CompilerOptions({
    this.optimizationLevel = 1,
    this.generateComments = true,
    this.strictTypeChecking = false,
    this.showWarnings = true,
    this.targetCStandard = 'c99',
    this.includeDebugInfo = false,
    this.language = 'es',
  });

  /// Default options
  static const CompilerOptions defaults = CompilerOptions();

  /// Debug options (more verbose, all checks enabled)
  static const CompilerOptions debug = CompilerOptions(
    optimizationLevel: 0,
    generateComments: true,
    strictTypeChecking: true,
    showWarnings: true,
    includeDebugInfo: true,
  );

  /// Release options (optimized, minimal output)
  static const CompilerOptions release = CompilerOptions(
    optimizationLevel: 2,
    generateComments: false,
    strictTypeChecking: true,
    showWarnings: false,
    includeDebugInfo: false,
  );
}

/// Result of the complete compilation pipeline
class CompilationResult {
  /// Whether compilation was successful
  final bool success;

  /// The generated C code (if successful)
  final String? generatedCode;

  /// All errors encountered
  final CompilerErrorCollection errors;

  /// The symbol table
  final SymbolTable? symbolTable;

  /// Lexical analysis result
  final DiagramLexicalResult? lexicalResult;

  /// Syntactic analysis result
  final SyntaxAnalysisResult? syntaxResult;

  /// Semantic analysis result
  final SemanticAnalysisResult? semanticResult;

  /// Optimization result
  final OptimizationResult? optimizationResult;

  /// The generated AST (may be optimized)
  final ProgramNode? ast;

  /// Compilation metrics
  final CompilationMetrics metrics;

  /// Messages and logs
  final List<String> messages;

  const CompilationResult({
    required this.success,
    this.generatedCode,
    required this.errors,
    this.symbolTable,
    this.lexicalResult,
    this.syntaxResult,
    this.semanticResult,
    this.optimizationResult,
    this.ast,
    required this.metrics,
    this.messages = const [],
  });

  /// Generate a human-readable report
  String generateReport() {
    final buffer = StringBuffer();

    buffer.writeln(
        '╔════════════════════════════════════════════════════════════╗');
    buffer.writeln(
        '║           REPORTE DE COMPILACIÓN - FLOWCODE                ║');
    buffer.writeln(
        '╚════════════════════════════════════════════════════════════╝');
    buffer.writeln('');

    // Status
    if (success) {
      buffer.writeln('✅ COMPILACIÓN EXITOSA');
    } else {
      buffer.writeln('❌ COMPILACIÓN FALLIDA');
    }
    buffer.writeln('');

    // Metrics
    buffer.writeln('📊 MÉTRICAS:');
    buffer
        .writeln('   • Tiempo de compilación: ${metrics.compilationTimeMs} ms');
    buffer.writeln('   • Nodos procesados: ${metrics.nodesProcessed}');
    buffer.writeln('   • Tokens generados: ${metrics.tokensGenerated}');
    buffer.writeln('   • Símbolos en tabla: ${metrics.symbolsInTable}');
    buffer.writeln('   • Errores: ${metrics.errorCount}');
    buffer.writeln('   • Advertencias: ${metrics.warningCount}');
    buffer.writeln('');

    // Errors
    if (errors.isNotEmpty) {
      buffer.writeln('📋 ERRORES Y ADVERTENCIAS:');
      for (final error in errors.all) {
        buffer.writeln('   ${error.severity.emoji} ${error.toString()}');
      }
      buffer.writeln('');
    }

    // Symbol table summary
    if (symbolTable != null) {
      buffer.writeln('📝 TABLA DE SÍMBOLOS:');
      for (final symbol in symbolTable!.allSymbols.take(10)) {
        buffer
            .writeln('   • ${symbol.name}: ${symbol.dataType.cRepresentation}');
      }
      if (symbolTable!.symbolCount > 10) {
        buffer.writeln('   ... y ${symbolTable!.symbolCount - 10} más');
      }
      buffer.writeln('');
    }

    // AST summary
    if (ast != null) {
      buffer.writeln('🌳 ÁRBOL DE SINTAXIS ABSTRACTA:');
      buffer.writeln('   • Nodos del diagrama: ${ast!.diagramNodes.length}');
      buffer.writeln(
          '   • Declaraciones globales: ${ast!.globalDeclarations.length}');
      final lines = ast!.toTreeString().split('\n').take(15).toList();
      for (final line in lines) {
        buffer.writeln('   $line');
      }
      if (ast!.toTreeString().split('\n').length > 15) {
        buffer.writeln('   ... (AST truncado)');
      }
      buffer.writeln('');
    }

    // Generated code preview
    if (generatedCode != null && generatedCode!.isNotEmpty) {
      buffer.writeln('💻 CÓDIGO GENERADO (vista previa):');
      final lines = generatedCode!.split('\n').take(20).toList();
      for (final line in lines) {
        buffer.writeln('   $line');
      }
      if (generatedCode!.split('\n').length > 20) {
        buffer.writeln('   ... (código truncado)');
      }
    }

    buffer.writeln('');
    buffer.writeln(
        '════════════════════════════════════════════════════════════');

    return buffer.toString();
  }
}

/// Metrics collected during compilation
class CompilationMetrics {
  /// Total compilation time in milliseconds
  final int compilationTimeMs;

  /// Number of nodes processed
  final int nodesProcessed;

  /// Number of tokens generated
  final int tokensGenerated;

  /// Number of symbols in the table
  final int symbolsInTable;

  /// Number of errors
  final int errorCount;

  /// Number of warnings
  final int warningCount;

  /// Lexical analysis time
  final int lexicalTimeMs;

  /// Syntactic analysis time
  final int syntacticTimeMs;

  /// Semantic analysis time
  final int semanticTimeMs;

  /// Optimization time
  final int optimizationTimeMs;

  /// Code generation time
  final int codeGenTimeMs;

  const CompilationMetrics({
    this.compilationTimeMs = 0,
    this.nodesProcessed = 0,
    this.tokensGenerated = 0,
    this.symbolsInTable = 0,
    this.errorCount = 0,
    this.warningCount = 0,
    this.lexicalTimeMs = 0,
    this.syntacticTimeMs = 0,
    this.semanticTimeMs = 0,
    this.optimizationTimeMs = 0,
    this.codeGenTimeMs = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'compilationTimeMs': compilationTimeMs,
      'nodesProcessed': nodesProcessed,
      'tokensGenerated': tokensGenerated,
      'symbolsInTable': symbolsInTable,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'phases': {
        'lexical': lexicalTimeMs,
        'syntactic': syntacticTimeMs,
        'semantic': semanticTimeMs,
        'optimization': optimizationTimeMs,
        'codeGen': codeGenTimeMs,
      },
    };
  }
}

/// Main compiler pipeline that orchestrates all compilation phases
class DiagramCompilerPipeline {
  /// Compiler options
  final CompilerOptions options;

  /// The lexical analyzer
  late final DiagramLexicalAnalyzer _lexicalAnalyzer;

  /// The syntax analyzer
  late final DiagramSyntaxAnalyzer _syntaxAnalyzer;

  /// The semantic analyzer
  late final DiagramSemanticAnalyzer _semanticAnalyzer;

  /// The code optimizer
  late final DiagramCodeOptimizer _codeOptimizer;

  /// Error collection
  final CompilerErrorCollection _errors = CompilerErrorCollection();

  /// Compilation messages
  final List<String> _messages = [];

  DiagramCompilerPipeline({this.options = CompilerOptions.defaults}) {
    _lexicalAnalyzer = DiagramLexicalAnalyzer();
    _syntaxAnalyzer = DiagramSyntaxAnalyzer();
    _semanticAnalyzer = DiagramSemanticAnalyzer();
    _codeOptimizer = DiagramCodeOptimizer(
      config: OptimizerConfig.fromLevel(
        _optimizationLevelFromInt(options.optimizationLevel),
      ),
    );
  }

  /// Convert integer optimization level to OptimizationLevel enum
  static OptimizationLevel _optimizationLevelFromInt(int level) {
    switch (level) {
      case 0:
        return OptimizationLevel.none;
      case 1:
        return OptimizationLevel.basic;
      case 2:
        return OptimizationLevel.standard;
      case 3:
        return OptimizationLevel.aggressive;
      default:
        return OptimizationLevel.standard;
    }
  }

  /// Run the complete compilation pipeline
  /// Implements all 5 phases: Lexical, Syntactic, Semantic, Optimization, Code Generation
  CompilationResult compile(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    _errors.clear();
    _messages.clear();

    final stopwatch = Stopwatch()..start();
    int lexicalTime = 0;
    int syntacticTime = 0;

    _messages.add('Iniciando compilación...');
    _messages.add(
        'Opciones: optimización=${options.optimizationLevel}, estricto=${options.strictTypeChecking}');

    // ═══════════════════════════════════════════════════════════
    // PHASE 1: LEXICAL ANALYSIS
    // ═══════════════════════════════════════════════════════════
    _messages.add('Fase 1: Análisis Léxico...');
    final lexicalStopwatch = Stopwatch()..start();

    final lexicalResult = _lexicalAnalyzer.analyzeDiagram(nodes, connections);

    lexicalStopwatch.stop();
    lexicalTime = lexicalStopwatch.elapsedMilliseconds;

    // Collect lexical errors
    for (final error in lexicalResult.errors) {
      _errors.add(error);
    }

    _messages.add('  - Nodos analizados: ${lexicalResult.nodeResults.length}');
    _messages.add('  - Tokens extraídos: ${lexicalResult.tokenCount}');
    _messages.add(
        '  - Símbolos encontrados: ${lexicalResult.symbolTable.symbolCount}');
    _messages.add('  - Errores léxicos: ${lexicalResult.errors.length}');
    _messages.add('  - Tiempo: ${lexicalTime}ms');

    // Check for fatal errors
    if (_errors.hasFatalErrors) {
      stopwatch.stop();
      return CompilationResult(
        success: false,
        errors: _errors,
        symbolTable: lexicalResult.symbolTable,
        lexicalResult: lexicalResult,
        metrics: CompilationMetrics(
          compilationTimeMs: stopwatch.elapsedMilliseconds,
          nodesProcessed: nodes.length,
          tokensGenerated: lexicalResult.tokenCount,
          symbolsInTable: lexicalResult.symbolTable.symbolCount,
          errorCount: _errors.errorCount,
          warningCount: _errors.warningCount,
          lexicalTimeMs: lexicalTime,
        ),
        messages: List.from(_messages),
      );
    }

    // ═══════════════════════════════════════════════════════════
    // PHASE 2: SYNTACTIC ANALYSIS
    // ═══════════════════════════════════════════════════════════
    _messages.add('Fase 2: Análisis Sintáctico...');
    final syntacticStopwatch = Stopwatch()..start();

    final syntaxResult = _syntaxAnalyzer.analyzeDiagram(nodes, connections);

    syntacticStopwatch.stop();
    syntacticTime = syntacticStopwatch.elapsedMilliseconds;

    // Collect syntax errors
    for (final error in syntaxResult.errors) {
      _errors.add(error);
    }

    _messages.add('  - Nodos parseados: ${syntaxResult.nodeResults.length}');
    _messages.add('  - Statements generados: ${syntaxResult.totalStatements}');
    _messages.add('  - AST generado: ${syntaxResult.ast != null ? "✓" : "✗"}');
    _messages.add('  - Errores sintácticos: ${syntaxResult.errors.length}');
    _messages.add('  - Tiempo: ${syntacticTime}ms');

    // Check for fatal errors after syntax analysis
    if (_errors.hasFatalErrors || !syntaxResult.isValid) {
      stopwatch.stop();
      return CompilationResult(
        success: false,
        errors: _errors,
        symbolTable: lexicalResult.symbolTable,
        lexicalResult: lexicalResult,
        syntaxResult: syntaxResult,
        ast: syntaxResult.ast,
        metrics: CompilationMetrics(
          compilationTimeMs: stopwatch.elapsedMilliseconds,
          nodesProcessed: nodes.length,
          tokensGenerated: lexicalResult.tokenCount,
          symbolsInTable: lexicalResult.symbolTable.symbolCount,
          errorCount: _errors.errorCount,
          warningCount: _errors.warningCount,
          lexicalTimeMs: lexicalTime,
          syntacticTimeMs: syntacticTime,
        ),
        messages: List.from(_messages),
      );
    }

    // ═══════════════════════════════════════════════════════════
    // PHASE 3: SEMANTIC ANALYSIS
    // ═══════════════════════════════════════════════════════════
    _messages.add('Fase 3: Análisis Semántico...');
    final semanticStopwatch = Stopwatch()..start();

    final semanticResult = _semanticAnalyzer.analyzeDiagram(
      nodes,
      connections,
      existingSymbolTable: lexicalResult.symbolTable,
      ast: syntaxResult.ast,
    );

    semanticStopwatch.stop();
    final semanticTime = semanticStopwatch.elapsedMilliseconds;

    // Collect semantic errors and warnings
    for (final error in semanticResult.errors) {
      _errors.add(error);
    }
    for (final warning in semanticResult.warnings) {
      _errors.add(warning);
    }

    _messages.add('  - Nodos analizados: ${semanticResult.nodeResults.length}');
    _messages.add(
        '  - Variables en tabla: ${semanticResult.symbolTable.symbolCount}');
    _messages.add('  - Errores semánticos: ${semanticResult.errorCount}');
    _messages.add('  - Advertencias: ${semanticResult.warningCount}');
    _messages.add('  - Tiempo: ${semanticTime}ms');

    // Check for errors after semantic analysis
    if (semanticResult.errors.isNotEmpty) {
      stopwatch.stop();
      return CompilationResult(
        success: false,
        errors: _errors,
        symbolTable: semanticResult.symbolTable,
        lexicalResult: lexicalResult,
        syntaxResult: syntaxResult,
        semanticResult: semanticResult,
        ast: syntaxResult.ast,
        metrics: CompilationMetrics(
          compilationTimeMs: stopwatch.elapsedMilliseconds,
          nodesProcessed: nodes.length,
          tokensGenerated: lexicalResult.tokenCount,
          symbolsInTable: semanticResult.symbolTable.symbolCount,
          errorCount: _errors.errorCount,
          warningCount: _errors.warningCount,
          lexicalTimeMs: lexicalTime,
          syntacticTimeMs: syntacticTime,
          semanticTimeMs: semanticTime,
        ),
        messages: List.from(_messages),
      );
    }

    // ═══════════════════════════════════════════════════════════
    // PHASE 4: OPTIMIZATION
    // ═══════════════════════════════════════════════════════════
    _messages.add('Fase 4: Optimización...');
    final optimizationStopwatch = Stopwatch()..start();

    OptimizationResult? optimizationResult;
    ProgramNode? optimizedAST = syntaxResult.ast;

    if (options.optimizationLevel > 0 && syntaxResult.ast != null) {
      optimizationResult = _codeOptimizer.optimize(
        syntaxResult.ast!,
        symbolTable: semanticResult.symbolTable,
      );

      if (optimizationResult.success &&
          optimizationResult.optimizedAST != null) {
        optimizedAST = optimizationResult.optimizedAST;
      }

      // Collect optimization errors (if any)
      for (final error in optimizationResult.errors) {
        _errors.add(error);
      }

      _messages.add(
          '  - Optimizaciones aplicadas: ${optimizationResult.totalOptimizations}');
      _messages.add(
          '  - Constantes plegadas: ${optimizationResult.metrics.constantsFolded}');
      _messages.add(
          '  - Código muerto eliminado: ${optimizationResult.metrics.deadCodeRemoved}');
      _messages.add(
          '  - Expresiones simplificadas: ${optimizationResult.metrics.expressionsSimplified}');
      _messages.add(
          '  - Reducción de tamaño: ${optimizationResult.metrics.sizeReductionPercent.toStringAsFixed(1)}%');
    } else {
      _messages.add('  - Optimización deshabilitada (nivel 0)');
    }

    optimizationStopwatch.stop();
    final optimizationTime = optimizationStopwatch.elapsedMilliseconds;
    _messages.add('  - Tiempo: ${optimizationTime}ms');

    // ═══════════════════════════════════════════════════════════
    // PHASE 5: CODE GENERATION
    // ═══════════════════════════════════════════════════════════
    _messages.add('Fase 5: Generación de Código...');
    final codeGenStopwatch = Stopwatch()..start();

    String? generatedCode;
    CodeGenerationResult? codeGenResult;

    try {
      final codeGenerator = AdvancedCodeGenerator(
        options: CodeGenOptions(
          includeComments: options.generateComments,
          includeTimestamp: true,
          debugMode: options.includeDebugInfo,
        ),
      );

      codeGenResult = codeGenerator.generate(
        nodes: nodes,
        connections: connections,
        symbolTable: semanticResult.symbolTable,
        ast: optimizedAST,
      );

      generatedCode = codeGenResult.code;

      // Collect any code generation errors
      for (final error in codeGenResult.errors) {
        _errors.add(error);
      }

      _messages
          .add('  - Líneas de código: ${codeGenResult.metrics.linesOfCode}');
      _messages.add(
          '  - Variables utilizadas: ${codeGenResult.metrics.variablesUsed}');
    } catch (e) {
      _messages.add('  - Error en generación: $e');
      _errors.add(CompilerError(
        code: CompilerErrorCode.codeGenerationFailed,
        message: 'Error durante la generación de código: $e',
        phase: CompilerPhase.codeGen,
        severity: CompilerSeverity.error,
      ));
    }

    codeGenStopwatch.stop();
    final codeGenTime = codeGenStopwatch.elapsedMilliseconds;
    _messages.add('  - Tiempo: ${codeGenTime}ms');

    // Return success after code generation
    stopwatch.stop();

    _messages
        .add('Compilación completada en ${stopwatch.elapsedMilliseconds}ms');

    return CompilationResult(
      success: !_errors.hasErrors && generatedCode != null,
      generatedCode: generatedCode,
      errors: _errors,
      symbolTable: semanticResult.symbolTable,
      lexicalResult: lexicalResult,
      syntaxResult: syntaxResult,
      semanticResult: semanticResult,
      optimizationResult: optimizationResult,
      ast: optimizedAST,
      metrics: CompilationMetrics(
        compilationTimeMs: stopwatch.elapsedMilliseconds,
        nodesProcessed: nodes.length,
        tokensGenerated: lexicalResult.tokenCount,
        symbolsInTable: semanticResult.symbolTable.symbolCount,
        errorCount: _errors.errorCount,
        warningCount: _errors.warningCount,
        lexicalTimeMs: lexicalTime,
        syntacticTimeMs: syntacticTime,
        semanticTimeMs: semanticTime,
        optimizationTimeMs: optimizationTime,
        codeGenTimeMs: codeGenTime,
      ),
      messages: List.from(_messages),
    );
  }

  /// Run only the lexical analysis phase
  DiagramLexicalResult runLexicalAnalysis(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    return _lexicalAnalyzer.analyzeDiagram(nodes, connections);
  }

  /// Run only the syntactic analysis phase
  SyntaxAnalysisResult runSyntacticAnalysis(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    return _syntaxAnalyzer.analyzeDiagram(nodes, connections);
  }

  /// Run only the semantic analysis phase
  SemanticAnalysisResult runSemanticAnalysis(
    List<DiagramNode> nodes,
    List<Connection> connections, {
    SymbolTable? existingSymbolTable,
    ProgramNode? ast,
  }) {
    return _semanticAnalyzer.analyzeDiagram(
      nodes,
      connections,
      existingSymbolTable: existingSymbolTable,
      ast: ast,
    );
  }

  /// Parse a single expression
  ASTNode? parseExpression(String expression, {String? nodeId}) {
    return _syntaxAnalyzer.parseExpression(expression, nodeId: nodeId);
  }

  /// Validate an expression syntactically
  bool validateExpression(String expression) {
    return _syntaxAnalyzer.validateExpression(expression);
  }

  /// Check balanced parentheses
  bool checkBalancedParentheses(String expression) {
    return _syntaxAnalyzer.checkBalancedParentheses(expression);
  }

  /// Tokenize a single text string (utility method)
  List<Token> tokenizeText(String text) {
    return _lexicalAnalyzer.tokenize(text);
  }

  /// Analyze a single node lexically (utility method)
  NodeLexicalResult analyzeNodeLexically(DiagramNode node) {
    return _lexicalAnalyzer.analyzeNode(node);
  }

  /// Analyze a single node syntactically
  NodeSyntaxResult analyzeNodeSyntactically(DiagramNode node) {
    return _syntaxAnalyzer.analyzeNode(node);
  }

  /// Validate an identifier
  static bool isValidIdentifier(String identifier) {
    return DiagramLexicalAnalyzer.isValidCIdentifier(identifier);
  }

  /// Get all C keywords
  static Set<String> get cKeywords => DiagramLexicalAnalyzer.cKeywords;

  /// Get all Spanish keywords
  static Set<String> get spanishKeywords =>
      DiagramLexicalAnalyzer.spanishKeywords;

  /// Run only the optimization phase
  OptimizationResult runOptimization(
    ProgramNode ast, {
    SymbolTable? symbolTable,
  }) {
    return _codeOptimizer.optimize(ast, symbolTable: symbolTable);
  }

  /// Change the optimization level after construction
  void setOptimizationLevel(int level) {
    _codeOptimizer = DiagramCodeOptimizer(
      config: OptimizerConfig.fromLevel(
        _optimizationLevelFromInt(level),
      ),
    );
  }
}

/// Extension to provide easy access to compilation from diagram nodes
extension DiagramNodeListCompilation on List<DiagramNode> {
  /// Compile this list of nodes with the given connections
  CompilationResult compile(
    List<Connection> connections, {
    CompilerOptions options = CompilerOptions.defaults,
  }) {
    final pipeline = DiagramCompilerPipeline(options: options);
    return pipeline.compile(this, connections);
  }

  /// Run lexical analysis only
  DiagramLexicalResult analyzeLexically(List<Connection> connections) {
    final pipeline = DiagramCompilerPipeline();
    return pipeline.runLexicalAnalysis(this, connections);
  }

  /// Run syntactic analysis only
  SyntaxAnalysisResult analyzeSyntactically(List<Connection> connections) {
    final pipeline = DiagramCompilerPipeline();
    return pipeline.runSyntacticAnalysis(this, connections);
  }

  /// Run semantic analysis only
  SemanticAnalysisResult analyzeSemantically(
    List<Connection> connections, {
    SymbolTable? existingSymbolTable,
    ProgramNode? ast,
  }) {
    final pipeline = DiagramCompilerPipeline();
    return pipeline.runSemanticAnalysis(
      this,
      connections,
      existingSymbolTable: existingSymbolTable,
      ast: ast,
    );
  }

  /// Run optimization only on an AST
  OptimizationResult optimize(
    ProgramNode ast, {
    SymbolTable? symbolTable,
    OptimizationLevel level = OptimizationLevel.standard,
  }) {
    final pipeline = DiagramCompilerPipeline(
      options: CompilerOptions(optimizationLevel: level.index),
    );
    return pipeline.runOptimization(ast, symbolTable: symbolTable);
  }
}
