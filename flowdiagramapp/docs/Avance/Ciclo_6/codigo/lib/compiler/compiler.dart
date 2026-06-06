/// FlowCode Diagram Compiler
/// Main barrel file exporting all compiler components
///
/// This is the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.
///
/// Usage:
/// ```dart
/// import 'package:flowdiagramapp/compiler/compiler.dart';
///
/// final compiler = DiagramCompilerPipeline();
/// final result = compiler.compile(nodes, connections);
///
/// // Access the AST
/// if (result.ast != null) {
///   print(result.ast!.toTreeString());
/// }
///
/// // Access semantic analysis results
/// if (result.semanticResult != null) {
///   print(result.semanticResult!.symbolTable.allSymbols);
/// }
/// ```

// Phase 1: Lexical Analysis
export 'token.dart';
export 'symbol_table.dart';
export 'lexical_analyzer.dart';

// Phase 2: Syntactic Analysis
export 'ast_nodes.dart';
export 'syntax_analyzer.dart';

// Phase 3: Semantic Analysis
export 'semantic_analyzer.dart';

// Phase 4: Optimization
export 'code_optimizer.dart';

// Phase 5: Code Generation
export 'code_generator_advanced.dart';

// Error handling
export 'compiler_errors.dart';

// Main pipeline
export 'compiler_pipeline.dart';
