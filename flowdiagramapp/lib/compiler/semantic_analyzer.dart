/// Semantic Analyzer for FlowCode Diagram Compiler
/// Performs semantic analysis: type checking, scope analysis, and validation
///
/// This is part of Phase 3 of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

import '../models/diagram_node.dart';
import 'token.dart';
import 'symbol_table.dart';
import 'ast_nodes.dart';
import 'compiler_errors.dart';
import 'lexical_analyzer.dart';

// ============================================
// SEMANTIC ANALYSIS RESULTS
// ============================================

/// Result of semantic analysis for a single node
class NodeSemanticResult {
  /// The node ID
  final String nodeId;

  /// Whether the node passed semantic analysis
  final bool isValid;

  /// List of semantic errors
  final List<CompilerError> errors;

  /// List of semantic warnings
  final List<CompilerError> warnings;

  /// Type information for expressions in this node
  final Map<String, DataType> expressionTypes;

  /// Variables used in this node
  final Set<String> variablesUsed;

  /// Variables declared in this node
  final Set<String> variablesDeclared;

  /// Variables modified in this node
  final Set<String> variablesModified;

  const NodeSemanticResult({
    required this.nodeId,
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.expressionTypes = const {},
    this.variablesUsed = const {},
    this.variablesDeclared = const {},
    this.variablesModified = const {},
  });
}

/// Result of semantic analysis for the entire diagram
class SemanticAnalysisResult {
  /// Whether the semantic analysis passed
  final bool isValid;

  /// List of all semantic errors
  final List<CompilerError> errors;

  /// List of all semantic warnings
  final List<CompilerError> warnings;

  /// Results for each node
  final Map<String, NodeSemanticResult> nodeResults;

  /// The enhanced symbol table after semantic analysis
  final SymbolTable symbolTable;

  /// Type information collected during analysis
  final TypeEnvironment typeEnvironment;

  /// Scope analysis results
  final ScopeAnalysisResult scopeAnalysis;

  const SemanticAnalysisResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.nodeResults,
    required this.symbolTable,
    required this.typeEnvironment,
    required this.scopeAnalysis,
  });

  /// Get total error count
  int get errorCount => errors.length;

  /// Get total warning count
  int get warningCount => warnings.length;

  /// Check if there are any undeclared variables
  bool get hasUndeclaredVariables =>
      errors.any((e) => e.code == CompilerErrorCode.undeclaredVariable);

  /// Check if there are type mismatches
  bool get hasTypeMismatches =>
      errors.any((e) => e.code == CompilerErrorCode.typeMismatch);
}

/// Scope analysis results
class ScopeAnalysisResult {
  /// Mapping of node ID to scope level
  final Map<String, int> nodeScopeLevels;

  /// Variables accessible at each node
  final Map<String, Set<String>> accessibleVariables;

  /// Scope hierarchy information
  final Map<String, String?> scopeParents;

  const ScopeAnalysisResult({
    this.nodeScopeLevels = const {},
    this.accessibleVariables = const {},
    this.scopeParents = const {},
  });
}

/// Type environment for tracking expression types
class TypeEnvironment {
  /// Variable types
  final Map<String, DataType> variableTypes;

  /// Expression types (for each expression string)
  final Map<String, DataType> expressionTypes;

  /// Function return types
  final Map<String, DataType> functionReturnTypes;

  /// Array element types
  final Map<String, DataType> arrayElementTypes;

  const TypeEnvironment({
    this.variableTypes = const {},
    this.expressionTypes = const {},
    this.functionReturnTypes = const {},
    this.arrayElementTypes = const {},
  });

  /// Create a mutable copy
  TypeEnvironment copyWith({
    Map<String, DataType>? variableTypes,
    Map<String, DataType>? expressionTypes,
    Map<String, DataType>? functionReturnTypes,
    Map<String, DataType>? arrayElementTypes,
  }) {
    return TypeEnvironment(
      variableTypes: variableTypes ?? Map.from(this.variableTypes),
      expressionTypes: expressionTypes ?? Map.from(this.expressionTypes),
      functionReturnTypes:
          functionReturnTypes ?? Map.from(this.functionReturnTypes),
      arrayElementTypes: arrayElementTypes ?? Map.from(this.arrayElementTypes),
    );
  }
}

// ============================================
// MAIN SEMANTIC ANALYZER
// ============================================

/// Semantic analyzer for flowchart diagrams
///
/// Performs:
/// - Type checking
/// - Scope analysis
/// - Undeclared variable detection
/// - Operation compatibility verification
/// - Initialization checking
/// - Usage analysis
class DiagramSemanticAnalyzer {
  /// The symbol table
  late SymbolTable _symbolTable;

  /// The lexer for tokenizing node text
  late DiagramLexicalAnalyzer _lexer;

  /// The type environment (mutable maps)
  late Map<String, DataType> _variableTypes;
  late Map<String, DataType> _expressionTypes;
  late Map<String, DataType> _functionReturnTypes;
  late Map<String, DataType> _arrayElementTypes;

  /// Errors collected during analysis
  final List<CompilerError> _errors = [];

  /// Warnings collected during analysis
  final List<CompilerError> _warnings = [];

  /// Node results
  final Map<String, NodeSemanticResult> _nodeResults = {};

  /// Scope tracking
  final Map<String, int> _nodeScopeLevels = {};
  final Map<String, Set<String>> _accessibleVariables = {};
  final Map<String, String?> _scopeParents = {};

  /// Standard library function return types
  static const Map<String, DataType> _standardFunctions = {
    // C Standard Library
    'printf': DataType.integer,
    'scanf': DataType.integer,
    'sqrt': DataType.double_,
    'pow': DataType.double_,
    'abs': DataType.integer,
    'fabs': DataType.double_,
    'sin': DataType.double_,
    'cos': DataType.double_,
    'tan': DataType.double_,
    'log': DataType.double_,
    'log10': DataType.double_,
    'exp': DataType.double_,
    'floor': DataType.double_,
    'ceil': DataType.double_,
    'round': DataType.double_,
    'strlen': DataType.integer,
    'strcmp': DataType.integer,
    'strcpy': DataType.string,
    'strcat': DataType.string,
    'atoi': DataType.integer,
    'atof': DataType.double_,
    'rand': DataType.integer,
    'srand': DataType.void_,
    // Spanish aliases
    'Leer': DataType.void_,
    'Mostrar': DataType.void_,
    'Escribir': DataType.void_,
    'Imprimir': DataType.void_,
    'Ingresar': DataType.void_,
  };

  /// Initialize the analyzer
  DiagramSemanticAnalyzer() {
    _reset();
  }

  /// Reset the analyzer state
  void _reset() {
    _symbolTable = SymbolTable();
    _lexer = DiagramLexicalAnalyzer();
    _variableTypes = {};
    _expressionTypes = {};
    _functionReturnTypes = Map.from(_standardFunctions);
    _arrayElementTypes = {};
    _errors.clear();
    _warnings.clear();
    _nodeResults.clear();
    _nodeScopeLevels.clear();
    _accessibleVariables.clear();
    _scopeParents.clear();
  }

  /// Main entry point: Analyze a diagram
  SemanticAnalysisResult analyzeDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections, {
    SymbolTable? existingSymbolTable,
    ProgramNode? ast,
  }) {
    _reset();

    // Use existing symbol table if provided
    if (existingSymbolTable != null) {
      _symbolTable = existingSymbolTable;
      // Copy variable types from existing symbol table
      for (final symbol in _symbolTable.allSymbols) {
        _variableTypes[symbol.name] = symbol.dataType;
      }
    }

    // If AST is provided, use it instead of raw nodes
    if (ast != null) {
      return analyzeAST(ast);
    }

    // Phase 1: Gather all declarations (first pass)
    _gatherDeclarationsFromNodes(nodes);

    // Phase 2: Analyze each node semantically
    for (final node in nodes) {
      _analyzeNode(node);
    }

    // Phase 3: Post-analysis checks
    _checkUnusedVariables();

    // Build result
    final typeEnv = TypeEnvironment(
      variableTypes: Map.from(_variableTypes),
      expressionTypes: Map.from(_expressionTypes),
      functionReturnTypes: Map.from(_functionReturnTypes),
      arrayElementTypes: Map.from(_arrayElementTypes),
    );

    final scopeResult = ScopeAnalysisResult(
      nodeScopeLevels: Map.from(_nodeScopeLevels),
      accessibleVariables: Map.from(_accessibleVariables),
      scopeParents: Map.from(_scopeParents),
    );

    return SemanticAnalysisResult(
      isValid: _errors.isEmpty,
      errors: List.from(_errors),
      warnings: List.from(_warnings),
      nodeResults: Map.from(_nodeResults),
      symbolTable: _symbolTable,
      typeEnvironment: typeEnv,
      scopeAnalysis: scopeResult,
    );
  }

  /// Analyze from an AST (alternative entry point)
  SemanticAnalysisResult analyzeAST(ProgramNode ast) {
    _reset();

    // Gather declarations from AST
    _gatherDeclarationsFromAST(ast);

    // Analyze each diagram node in AST
    for (final node in ast.diagramNodes) {
      _analyzeASTNode(node);
    }

    // Post-analysis checks
    _checkUnusedVariables();

    final typeEnv = TypeEnvironment(
      variableTypes: Map.from(_variableTypes),
      expressionTypes: Map.from(_expressionTypes),
      functionReturnTypes: Map.from(_functionReturnTypes),
      arrayElementTypes: Map.from(_arrayElementTypes),
    );

    final scopeResult = ScopeAnalysisResult(
      nodeScopeLevels: Map.from(_nodeScopeLevels),
      accessibleVariables: Map.from(_accessibleVariables),
      scopeParents: Map.from(_scopeParents),
    );

    return SemanticAnalysisResult(
      isValid: _errors.isEmpty,
      errors: List.from(_errors),
      warnings: List.from(_warnings),
      nodeResults: Map.from(_nodeResults),
      symbolTable: _symbolTable,
      typeEnvironment: typeEnv,
      scopeAnalysis: scopeResult,
    );
  }

  // ============================================
  // DECLARATION GATHERING (FIRST PASS)
  // ============================================

  /// Gather all variable declarations from nodes
  void _gatherDeclarationsFromNodes(List<DiagramNode> nodes) {
    for (final node in nodes) {
      // Check for function definitions in terminal nodes (e.g., "Inicio Suma(x, y)")
      if (node.type == NodeType.terminal) {
        _extractFunctionParameters(node.text, node.id);
      }
      // Check for declarations in preparation nodes
      else if (node.type == NodeType.preparation) {
        _extractDeclaration(node.text, node.id);
      }
      // Check for declarations in process nodes (e.g., "int retorno")
      else if (node.type == NodeType.process) {
        _extractDeclarationFromProcess(node.text, node.id);
      }
    }
  }

  /// Extract function parameters from terminal node text
  /// Handles patterns like "Inicio Suma(x, y)" or "Inicio Factorial(n)"
  void _extractFunctionParameters(String text, String nodeId) {
    // Look for function definition pattern: "Inicio FuncName(param1, param2, ...)"
    final funcMatch =
        RegExp(r'Inicio\s+(\w+)\s*\(([^)]*)\)', caseSensitive: false)
            .firstMatch(text);
    if (funcMatch != null) {
      final funcName = funcMatch.group(1)!;
      final paramsStr = funcMatch.group(2)!;

      // Register the function in the function return types (default to int)
      _functionReturnTypes[funcName] = DataType.integer;

      // Parse parameters
      if (paramsStr.trim().isNotEmpty) {
        final params = paramsStr
            .split(',')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty);
        for (final param in params) {
          // Handle pointer parameters like "int *x", "int* x", "int * x"
          // First, normalize: remove asterisks from type and name separately
          String normalizedParam = param;

          // Check if it's a pointer parameter
          bool isPointer = param.contains('*');

          // Remove asterisks for parsing, but remember it's a pointer
          normalizedParam = param.replaceAll('*', ' ').trim();
          normalizedParam = normalizedParam.replaceAll(
              RegExp(r'\s+'), ' '); // Normalize spaces

          // Parameters can be "type name" or just "name"
          final parts = normalizedParam
              .split(RegExp(r'\s+'))
              .where((p) => p.isNotEmpty)
              .toList();

          String paramName;
          DataType paramType = DataType.integer; // Default type

          if (parts.length >= 2) {
            // Has type: "int x" (after removing asterisks)
            paramType = _stringToDataType(parts[0]) ?? DataType.integer;
            paramName = parts.last;
          } else if (parts.length == 1) {
            // Just name: "x"
            paramName = parts[0];
          } else {
            continue;
          }

          // Clean any remaining asterisks from parameter name (shouldn't happen after normalization)
          paramName = paramName.replaceAll('*', '').trim();

          // Skip empty names
          if (paramName.isEmpty) continue;

          // Register parameter as a variable (for pointers, register the dereferenced name)
          if (!_symbolTable.symbolExists(paramName)) {
            _registerDeclaration(paramName, paramType, true, nodeId);
          }

          // If it's a pointer, also note this for type checking purposes
          if (isPointer) {
            // Store pointer type information
            _variableTypes[paramName] = paramType;
          }
        }
      }
    }
  }

  /// Extract declarations from process nodes
  /// Handles patterns like "int x", "int retorno", "float resultado"
  void _extractDeclarationFromProcess(String text, String nodeId) {
    final tokens = _lexer.tokenize(text, nodeId: nodeId);

    if (tokens.isEmpty) return;

    // Check if starts with a type keyword
    final firstToken = tokens.first;
    final dataType = _tokenToDataType(firstToken.type);

    if (dataType == null) return;

    // It's a declaration, extract variable names
    for (int i = 1; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.type == TokenType.identifier) {
        final varName = token.lexeme;

        // Skip array size specifiers
        if (i > 1 && tokens[i - 1].type == TokenType.leftBracket) {
          continue;
        }

        // Check if it's not already declared
        if (!_symbolTable.symbolExists(varName)) {
          // Check if initialized
          bool isInitialized = false;
          for (int j = i + 1; j < tokens.length; j++) {
            if (tokens[j].type == TokenType.opAssign) {
              isInitialized = true;
              break;
            }
            if (tokens[j].type == TokenType.comma ||
                tokens[j].type == TokenType.semicolon) {
              break;
            }
          }

          _registerDeclaration(varName, dataType, isInitialized, nodeId);
        }

        // Move to next variable (after comma)
        while (i < tokens.length && tokens[i].type != TokenType.comma) {
          i++;
        }
      }
    }
  }

  /// Convert string type name to DataType
  DataType? _stringToDataType(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'int':
      case 'entero':
        return DataType.integer;
      case 'float':
      case 'real':
        return DataType.float;
      case 'double':
        return DataType.double_;
      case 'char':
      case 'caracter':
        return DataType.char;
      case 'bool':
      case 'booleano':
        return DataType.boolean;
      case 'string':
      case 'cadena':
        return DataType.string;
      case 'void':
        return DataType.void_;
      default:
        return null;
    }
  }

  /// Gather declarations from AST
  void _gatherDeclarationsFromAST(ProgramNode ast) {
    // Process global declarations
    for (final decl in ast.globalDeclarations) {
      _registerDeclaration(
        decl.variableName,
        decl.dataType,
        decl.initializer != null,
        null,
      );
    }

    // Process node-level declarations and function parameters
    for (final diagNode in ast.diagramNodes) {
      // Check for function parameters in terminal nodes
      // e.g., "Inicio Suma(x, y)" or "Inicio Factorial(n)"
      if (diagNode.nodeType == 'terminal' && diagNode.label != null) {
        _extractFunctionParameters(diagNode.label!, diagNode.diagramNodeId);
      }

      // Check for declarations in process nodes
      // e.g., "int retorno" or "int a, b, c"
      if (diagNode.nodeType == 'process' && diagNode.label != null) {
        _extractDeclarationFromProcess(diagNode.label!, diagNode.diagramNodeId);
      }

      // Process statement-level declarations
      for (final stmt in diagNode.statements) {
        if (stmt is DeclarationStatementNode) {
          _registerDeclaration(
            stmt.variableName,
            stmt.dataType,
            stmt.initializer != null,
            diagNode.diagramNodeId,
          );
        }
      }
    }
  }

  /// Extract declaration from node text
  void _extractDeclaration(String text, String nodeId) {
    final tokens = _lexer.tokenize(text, nodeId: nodeId);

    if (tokens.isEmpty) return;

    // Check for type keyword
    final firstToken = tokens.first;
    final dataType = _tokenToDataType(firstToken.type);

    if (dataType == null) return;

    // Look for variable name
    for (int i = 1; i < tokens.length; i++) {
      final token = tokens[i];
      if (token.type == TokenType.identifier) {
        final varName = token.lexeme;

        // Check for duplicate
        if (_symbolTable.symbolExists(varName)) {
          _errors
              .add(SemanticError.duplicateDeclaration(varName, nodeId: nodeId));
        } else {
          // Check if initialized (has '=')
          bool isInitialized = false;
          for (int j = i + 1; j < tokens.length; j++) {
            if (tokens[j].type == TokenType.opAssign) {
              isInitialized = true;
              break;
            }
            if (tokens[j].type == TokenType.comma ||
                tokens[j].type == TokenType.semicolon) {
              break;
            }
          }

          _registerDeclaration(varName, dataType, isInitialized, nodeId);
        }

        // Move to next variable (after comma)
        while (i < tokens.length && tokens[i].type != TokenType.comma) {
          i++;
        }
      }
    }
  }

  /// Register a declaration in the symbol table
  void _registerDeclaration(
    String name,
    DataType type,
    bool isInitialized,
    String? nodeId,
  ) {
    _symbolTable.declareSymbol(
      name: name,
      dataType: type,
      nodeId: nodeId,
      isInitialized: isInitialized,
    );
    _variableTypes[name] = type;
  }

  /// Convert token type to data type
  DataType? _tokenToDataType(TokenType tokenType) {
    switch (tokenType) {
      case TokenType.kwInt:
      case TokenType.kwEntero:
        return DataType.integer;
      case TokenType.kwFloat:
      case TokenType.kwReal:
        return DataType.float;
      case TokenType.kwDouble:
        return DataType.double_;
      case TokenType.kwChar:
      case TokenType.kwCaracter:
        return DataType.char;
      case TokenType.kwBool:
      case TokenType.kwBooleano:
        return DataType.boolean;
      case TokenType.kwCadena:
        return DataType.string;
      case TokenType.kwVoid:
        return DataType.void_;
      default:
        return null;
    }
  }

  // ============================================
  // NODE ANALYSIS
  // ============================================

  /// Analyze a single diagram node
  void _analyzeNode(DiagramNode node) {
    final nodeErrors = <CompilerError>[];
    final nodeWarnings = <CompilerError>[];
    final usedVars = <String>{};
    final declaredVars = <String>{};
    final modifiedVars = <String>{};

    switch (node.type) {
      case NodeType.terminal:
        // Start/End nodes - no semantic analysis needed
        break;

      case NodeType.process:
        _analyzeProcessNode(
            node, nodeErrors, nodeWarnings, usedVars, modifiedVars);
        break;

      case NodeType.decision:
        _analyzeDecisionNode(node, nodeErrors, nodeWarnings, usedVars);
        break;

      case NodeType.preparation:
        _analyzePreparationNode(
            node, nodeErrors, nodeWarnings, declaredVars, usedVars);
        break;

      case NodeType.data:
        _analyzeDataNode(
            node, nodeErrors, nodeWarnings, usedVars, modifiedVars);
        break;

      case NodeType.predefinedProcess:
        _analyzeSubprocessNode(node, nodeErrors, nodeWarnings, usedVars);
        break;

      case NodeType.loopLimit:
        _analyzeLoopNode(
            node, nodeErrors, nodeWarnings, usedVars, modifiedVars);
        break;

      default:
        // Other node types - no semantic analysis
        break;
    }

    _errors.addAll(nodeErrors);
    _warnings.addAll(nodeWarnings);

    _nodeResults[node.id] = NodeSemanticResult(
      nodeId: node.id,
      isValid: nodeErrors.isEmpty,
      errors: nodeErrors,
      warnings: nodeWarnings,
      variablesUsed: usedVars,
      variablesDeclared: declaredVars,
      variablesModified: modifiedVars,
    );
  }

  /// Analyze an AST node
  void _analyzeASTNode(DiagramASTNode node) {
    for (final stmt in node.statements) {
      _analyzeStatement(stmt, node.diagramNodeId);
    }
  }

  /// Analyze a statement
  void _analyzeStatement(StatementNode stmt, String nodeId) {
    if (stmt is DeclarationStatementNode) {
      // Already handled in first pass
      if (stmt.initializer != null) {
        _analyzeExpression(stmt.initializer!, nodeId);
      }
    } else if (stmt is ExpressionStatementNode) {
      _analyzeExpression(stmt.expression, nodeId);
    } else if (stmt is InputStatementNode) {
      for (final varNode in stmt.variables) {
        _checkVariableDeclared(varNode.name, nodeId);
        _symbolTable.markAsInitialized(varNode.name);
      }
    } else if (stmt is OutputStatementNode) {
      for (final expr in stmt.expressions) {
        _analyzeExpression(expr, nodeId);
      }
    } else if (stmt is ReturnStatementNode) {
      // Analyze return statement - check the return value
      if (stmt.value != null) {
        _analyzeExpression(stmt.value!, nodeId);
      }
    } else if (stmt is IfStatementNode) {
      _analyzeExpression(stmt.condition, nodeId);
      _analyzeStatement(stmt.thenBranch, nodeId);
      if (stmt.elseBranch != null) {
        _analyzeStatement(stmt.elseBranch!, nodeId);
      }
    } else if (stmt is WhileStatementNode) {
      _analyzeExpression(stmt.condition, nodeId);
      _analyzeStatement(stmt.body, nodeId);
    } else if (stmt is ForStatementNode) {
      if (stmt.initializer != null) {
        _analyzeExpression(stmt.initializer!, nodeId);
      }
      if (stmt.condition != null) {
        _analyzeExpression(stmt.condition!, nodeId);
      }
      if (stmt.update != null) {
        _analyzeExpression(stmt.update!, nodeId);
      }
      _analyzeStatement(stmt.body, nodeId);
    } else if (stmt is BlockStatementNode) {
      for (final s in stmt.statements) {
        _analyzeStatement(s, nodeId);
      }
    }
  }

  /// Analyze an expression
  void _analyzeExpression(ASTNode expr, String nodeId) {
    if (expr is IdentifierNode) {
      _checkVariableDeclared(expr.name, nodeId);
      _symbolTable.markAsUsed(expr.name);
    } else if (expr is BinaryExpressionNode) {
      _analyzeExpression(expr.left, nodeId);
      _analyzeExpression(expr.right, nodeId);
      _checkBinaryOperation(expr, nodeId);
    } else if (expr is UnaryExpressionNode) {
      _analyzeExpression(expr.operand, nodeId);
    } else if (expr is AssignmentExpressionNode) {
      _analyzeExpression(expr.value, nodeId);
      if (expr.target is IdentifierNode) {
        final name = (expr.target as IdentifierNode).name;
        _checkVariableDeclared(name, nodeId);
        _symbolTable.markAsInitialized(name);
        _checkAssignmentTypes(expr, nodeId);
      }
    } else if (expr is FunctionCallNode) {
      for (final arg in expr.arguments) {
        _analyzeExpression(arg, nodeId);
      }
    } else if (expr is ArrayAccessNode) {
      _analyzeExpression(expr.array, nodeId);
      _analyzeExpression(expr.index, nodeId);
      _checkArrayIndex(expr.index, nodeId);
    } else if (expr is ConditionalExpressionNode) {
      _analyzeExpression(expr.condition, nodeId);
      _analyzeExpression(expr.trueExpression, nodeId);
      _analyzeExpression(expr.falseExpression, nodeId);
    }
  }

  // ============================================
  // NODE-SPECIFIC ANALYSIS
  // ============================================

  /// Analyze process node (assignments, operations)
  void _analyzeProcessNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> usedVars,
    Set<String> modifiedVars,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    // Extract variables used and modified
    final identifiers = _extractIdentifiers(tokens);

    for (final ident in identifiers) {
      // Check if declared
      if (!_symbolTable.symbolExists(ident)) {
        errors.add(SemanticError.undeclaredVariable(ident, nodeId: node.id));
      } else {
        usedVars.add(ident);
        _symbolTable.markAsUsed(ident);
      }
    }

    // Check for assignments
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].type == TokenType.opAssign && i > 0) {
        final targetToken = tokens[i - 1];
        if (targetToken.type == TokenType.identifier) {
          modifiedVars.add(targetToken.lexeme);
          _symbolTable.markAsInitialized(targetToken.lexeme);
        }
      }
    }

    // Check for division by zero
    _checkDivisionByZero(tokens, node.id, errors);

    // Type checking for operations
    _checkOperationTypes(tokens, node.id, warnings);
  }

  /// Analyze decision node (conditions)
  void _analyzeDecisionNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> usedVars,
  ) {
    // Normalizar el texto del nodo de decisión (quitar signos de interrogación)
    String text = node.text.trim();
    text = text.replaceAll('¿', '').replaceAll('?', '').trim();

    if (text.isEmpty) return;

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    // Extract and check variables
    final identifiers = _extractIdentifiers(tokens);

    for (final ident in identifiers) {
      if (!_symbolTable.symbolExists(ident)) {
        errors.add(SemanticError.undeclaredVariable(ident, nodeId: node.id));
      } else {
        usedVars.add(ident);
        _symbolTable.markAsUsed(ident);

        // Check if initialized
        final symbol = _symbolTable.lookup(ident);
        if (symbol != null && !symbol.isInitialized) {
          warnings
              .add(SemanticError.uninitializedVariable(ident, nodeId: node.id));
        }
      }
    }
  }

  /// Analyze preparation node (declarations)
  void _analyzePreparationNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> declaredVars,
    Set<String> usedVars,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    // Find declared variables
    DataType? currentType;
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      // Check for type keyword
      final dataType = _tokenToDataType(token.type);
      if (dataType != null) {
        currentType = dataType;
        continue;
      }

      // Check for variable name after type
      if (token.type == TokenType.identifier && currentType != null) {
        declaredVars.add(token.lexeme);

        // Check for initialization expression
        if (i + 2 < tokens.length && tokens[i + 1].type == TokenType.opAssign) {
          // Analyze initialization expression for used variables
          for (int j = i + 2; j < tokens.length; j++) {
            if (tokens[j].type == TokenType.comma ||
                tokens[j].type == TokenType.semicolon) {
              break;
            }
            if (tokens[j].type == TokenType.identifier) {
              final initVar = tokens[j].lexeme;
              if (!_symbolTable.symbolExists(initVar) &&
                  initVar != token.lexeme) {
                errors.add(
                    SemanticError.undeclaredVariable(initVar, nodeId: node.id));
              } else if (initVar != token.lexeme) {
                usedVars.add(initVar);
                _symbolTable.markAsUsed(initVar);
              }
            }
          }
        }
      }
    }
  }

  /// Analyze data node (input/output/return)
  void _analyzeDataNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> usedVars,
    Set<String> modifiedVars,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    final lowerText = text.toLowerCase();

    // Check if it's a return statement
    final isReturn = lowerText.startsWith('return') ||
        lowerText.startsWith('retornar') ||
        node.metadata['isReturn'] == true;

    final isInput = lowerText.startsWith('leer') ||
        lowerText.startsWith('ingresar') ||
        lowerText.startsWith('scanf');

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    if (isReturn) {
      // For return statements, analyze all identifiers after 'return' keyword
      bool afterReturn = false;
      for (final token in tokens) {
        if (token.type == TokenType.kwReturn ||
            token.type == TokenType.kwRetornar) {
          afterReturn = true;
          continue;
        }

        if (afterReturn && token.type == TokenType.identifier) {
          final varName = token.lexeme;
          if (!_symbolTable.symbolExists(varName)) {
            errors.add(
                SemanticError.undeclaredVariable(varName, nodeId: node.id));
          } else {
            usedVars.add(varName);
            _symbolTable.markAsUsed(varName);

            // Check if variable is initialized for return
            final symbol = _symbolTable.lookup(varName);
            if (symbol != null && !symbol.isInitialized) {
              warnings.add(SemanticError.uninitializedVariable(varName,
                  nodeId: node.id));
            }
          }
        }
      }
      return;
    }

    // Extract variables from function arguments
    bool inParens = false;
    for (final token in tokens) {
      if (token.type == TokenType.leftParen) {
        inParens = true;
        continue;
      }
      if (token.type == TokenType.rightParen) {
        inParens = false;
        continue;
      }

      if (inParens && token.type == TokenType.identifier) {
        final varName = token.lexeme;

        if (!_symbolTable.symbolExists(varName)) {
          errors
              .add(SemanticError.undeclaredVariable(varName, nodeId: node.id));
        } else {
          if (isInput) {
            modifiedVars.add(varName);
            _symbolTable.markAsInitialized(varName);
          } else {
            usedVars.add(varName);
            _symbolTable.markAsUsed(varName);

            // Check if variable is initialized for output
            final symbol = _symbolTable.lookup(varName);
            if (symbol != null && !symbol.isInitialized) {
              warnings.add(SemanticError.uninitializedVariable(varName,
                  nodeId: node.id));
            }
          }
        }
      }
    }
  }

  /// Analyze loop node (condition checking)
  void _analyzeLoopNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> usedVars,
    Set<String> modifiedVars,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    final identifiers = _extractIdentifiers(tokens);

    for (final ident in identifiers) {
      if (!_symbolTable.symbolExists(ident)) {
        errors.add(SemanticError.undeclaredVariable(ident, nodeId: node.id));
      } else {
        usedVars.add(ident);
        _symbolTable.markAsUsed(ident);
      }
    }
  }

  /// Analyze subprocess node (function calls)
  void _analyzeSubprocessNode(
    DiagramNode node,
    List<CompilerError> errors,
    List<CompilerError> warnings,
    Set<String> usedVars,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    final tokens = _lexer.tokenize(text, nodeId: node.id);

    // Check for function call pattern
    if (tokens.isNotEmpty && tokens.first.type == TokenType.identifier) {
      final funcName = tokens.first.lexeme;

      // Check if it's a known function
      if (!_functionReturnTypes.containsKey(funcName) &&
          !_symbolTable.symbolExists(funcName)) {
        warnings.add(CompilerError.semantic(
          code: CompilerErrorCode.unknownFunction,
          message: 'Función no reconocida: $funcName',
          location: SourceLocation(nodeId: node.id),
        ));
      }
    }

    // Check arguments
    bool inParens = false;
    for (final token in tokens) {
      if (token.type == TokenType.leftParen) {
        inParens = true;
        continue;
      }
      if (token.type == TokenType.rightParen) {
        inParens = false;
        continue;
      }

      if (inParens && token.type == TokenType.identifier) {
        final varName = token.lexeme;
        if (!_symbolTable.symbolExists(varName)) {
          errors
              .add(SemanticError.undeclaredVariable(varName, nodeId: node.id));
        } else {
          usedVars.add(varName);
          _symbolTable.markAsUsed(varName);
        }
      }
    }
  }

  // ============================================
  // VALIDATION HELPERS
  // ============================================

  /// Extract identifier names from tokens
  List<String> _extractIdentifiers(List<Token> tokens) {
    return tokens
        .where((t) => t.type == TokenType.identifier)
        .map((t) => t.lexeme)
        .toList();
  }

  /// Check if variable is declared
  void _checkVariableDeclared(String name, String nodeId) {
    if (!_symbolTable.symbolExists(name)) {
      _errors.add(SemanticError.undeclaredVariable(name, nodeId: nodeId));
    }
  }

  /// Check for division by zero
  void _checkDivisionByZero(
    List<Token> tokens,
    String nodeId,
    List<CompilerError> errors,
  ) {
    for (int i = 0; i < tokens.length - 1; i++) {
      if (tokens[i].type == TokenType.opDivide ||
          tokens[i].type == TokenType.opModulo) {
        // Look for the operand, skipping over parentheses
        int j = i + 1;
        while (j < tokens.length && tokens[j].type == TokenType.leftParen) {
          j++;
        }
        if (j < tokens.length) {
          final nextToken = tokens[j];
          if (nextToken.type == TokenType.integerLiteral ||
              nextToken.type == TokenType.floatLiteral) {
            final value = num.tryParse(nextToken.lexeme);
            if (value != null && value == 0) {
              errors.add(SemanticError.divisionByZero(nodeId: nodeId));
            }
          }
        }
      }
    }
  }

  /// Check operation types
  void _checkOperationTypes(
    List<Token> tokens,
    String nodeId,
    List<CompilerError> warnings,
  ) {
    // Find assignment
    int assignIdx = -1;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].type == TokenType.opAssign) {
        assignIdx = i;
        break;
      }
    }

    if (assignIdx > 0 && assignIdx < tokens.length - 1) {
      final targetToken = tokens[assignIdx - 1];
      if (targetToken.type == TokenType.identifier) {
        final targetType = _variableTypes[targetToken.lexeme];
        if (targetType != null) {
          // Infer expression type
          final exprType = _inferExpressionType(tokens.sublist(assignIdx + 1));

          if (exprType != null && !_areTypesCompatible(targetType, exprType)) {
            warnings.add(SemanticError.typeMismatch(
              expected: targetType,
              actual: exprType,
              nodeId: nodeId,
            ));
          }
        }
      }
    }
  }

  /// Check binary operation types
  void _checkBinaryOperation(BinaryExpressionNode expr, String nodeId) {
    final leftType = _getExpressionType(expr.left);
    final rightType = _getExpressionType(expr.right);

    if (leftType == null || rightType == null) return;

    // Check operator compatibility
    final op = expr.operator;

    // Arithmetic operators need numeric types
    if (_isArithmeticOperator(op)) {
      if (!leftType.isArithmetic || !rightType.isArithmetic) {
        _warnings.add(SemanticError.invalidOperation(
          op.symbol,
          leftType,
          rightType,
          nodeId: nodeId,
        ));
      }
    }

    // Logical operators need boolean types
    if (_isLogicalOperator(op)) {
      if (leftType != DataType.boolean || rightType != DataType.boolean) {
        _warnings.add(SemanticError.invalidOperation(
          op.symbol,
          leftType,
          rightType,
          nodeId: nodeId,
        ));
      }
    }
  }

  /// Check assignment types
  void _checkAssignmentTypes(AssignmentExpressionNode expr, String nodeId) {
    if (expr.target is! IdentifierNode) return;

    final targetName = (expr.target as IdentifierNode).name;
    final targetType = _variableTypes[targetName];
    final valueType = _getExpressionType(expr.value);

    if (targetType != null && valueType != null) {
      if (!_areTypesCompatible(targetType, valueType)) {
        _warnings.add(SemanticError.typeMismatch(
          expected: targetType,
          actual: valueType,
          nodeId: nodeId,
        ));
      }
    }
  }

  /// Check array index
  void _checkArrayIndex(ASTNode indexExpr, String nodeId) {
    final indexType = _getExpressionType(indexExpr);
    if (indexType != null && indexType != DataType.integer) {
      _warnings.add(CompilerError.semantic(
        code: CompilerErrorCode.invalidArrayIndex,
        message:
            'El índice del arreglo debe ser de tipo entero, pero es ${indexType.cRepresentation}',
        location: SourceLocation(nodeId: nodeId),
      ));
    }
  }

  /// Check unused variables
  void _checkUnusedVariables() {
    for (final symbol in _symbolTable.allSymbols) {
      if (!symbol.isUsed && symbol.category == SymbolCategory.variable) {
        _warnings.add(SemanticError.unusedVariable(
          symbol.name,
          nodeId: symbol.declaringNodeId,
        ));
      }
    }
  }

  // ============================================
  // TYPE INFERENCE
  // ============================================

  /// Get the type of an expression
  DataType? _getExpressionType(ASTNode expr) {
    if (expr is IntegerLiteralNode) {
      return DataType.integer;
    } else if (expr is FloatLiteralNode) {
      return DataType.float;
    } else if (expr is StringLiteralNode) {
      return DataType.string;
    } else if (expr is CharLiteralNode) {
      return DataType.char;
    } else if (expr is BooleanLiteralNode) {
      return DataType.boolean;
    } else if (expr is IdentifierNode) {
      return _variableTypes[expr.name];
    } else if (expr is BinaryExpressionNode) {
      return _getBinaryExpressionType(expr);
    } else if (expr is UnaryExpressionNode) {
      return _getExpressionType(expr.operand);
    } else if (expr is FunctionCallNode) {
      return _functionReturnTypes[expr.functionName];
    } else if (expr is ArrayAccessNode) {
      if (expr.array is IdentifierNode) {
        final arrayName = (expr.array as IdentifierNode).name;
        return _arrayElementTypes[arrayName] ?? _variableTypes[arrayName];
      }
    }
    return null;
  }

  /// Get type of binary expression
  DataType? _getBinaryExpressionType(BinaryExpressionNode expr) {
    final leftType = _getExpressionType(expr.left);
    final rightType = _getExpressionType(expr.right);

    if (leftType == null || rightType == null) return null;

    // Comparison operators return boolean
    if (_isComparisonOperator(expr.operator)) {
      return DataType.boolean;
    }

    // Logical operators return boolean
    if (_isLogicalOperator(expr.operator)) {
      return DataType.boolean;
    }

    // Arithmetic operators - type promotion
    if (_isArithmeticOperator(expr.operator)) {
      return _promoteTypes(leftType, rightType);
    }

    return leftType;
  }

  /// Infer expression type from tokens
  DataType? _inferExpressionType(List<Token> tokens) {
    if (tokens.isEmpty) return null;

    // Look for the dominant type
    bool hasFloat = false;
    bool hasString = false;
    DataType? identifierType;

    for (final token in tokens) {
      switch (token.type) {
        case TokenType.floatLiteral:
          hasFloat = true;
          break;
        case TokenType.stringLiteral:
          hasString = true;
          break;
        case TokenType.identifier:
          identifierType = _variableTypes[token.lexeme];
          if (identifierType == DataType.float ||
              identifierType == DataType.double_) {
            hasFloat = true;
          }
          break;
        default:
          break;
      }
    }

    if (hasString) return DataType.string;
    if (hasFloat) return DataType.float;
    if (identifierType != null) return identifierType;
    return DataType.integer;
  }

  /// Check if types are compatible
  bool _areTypesCompatible(DataType target, DataType source) {
    if (target == source) return true;

    // Numeric promotions
    if (target.isNumeric && source.isNumeric) {
      return true;
    }

    // Char can be assigned to int
    if (target == DataType.integer && source == DataType.char) {
      return true;
    }

    return false;
  }

  /// Promote types for arithmetic operations
  DataType _promoteTypes(DataType left, DataType right) {
    if (left == DataType.double_ || right == DataType.double_) {
      return DataType.double_;
    }
    if (left == DataType.float || right == DataType.float) {
      return DataType.float;
    }
    return DataType.integer;
  }

  /// Check if operator is arithmetic
  bool _isArithmeticOperator(BinaryOperator op) {
    return op == BinaryOperator.add ||
        op == BinaryOperator.subtract ||
        op == BinaryOperator.multiply ||
        op == BinaryOperator.divide ||
        op == BinaryOperator.modulo;
  }

  /// Check if operator is comparison
  bool _isComparisonOperator(BinaryOperator op) {
    return op == BinaryOperator.equal ||
        op == BinaryOperator.notEqual ||
        op == BinaryOperator.less ||
        op == BinaryOperator.lessEqual ||
        op == BinaryOperator.greater ||
        op == BinaryOperator.greaterEqual;
  }

  /// Check if operator is logical
  bool _isLogicalOperator(BinaryOperator op) {
    return op == BinaryOperator.and || op == BinaryOperator.or;
  }

  // ============================================
  // REPORT GENERATION
  // ============================================

  /// Generate a human-readable report
  String generateReport(SemanticAnalysisResult result) {
    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('           REPORTE DE ANÁLISIS SEMÁNTICO');
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln();

    // Summary
    buffer.writeln('📊 RESUMEN:');
    buffer
        .writeln('   Estado: ${result.isValid ? "✅ VÁLIDO" : "❌ CON ERRORES"}');
    buffer.writeln('   Errores: ${result.errorCount}');
    buffer.writeln('   Advertencias: ${result.warningCount}');
    buffer
        .writeln('   Variables declaradas: ${result.symbolTable.symbolCount}');
    buffer.writeln();

    // Errors
    if (result.errors.isNotEmpty) {
      buffer.writeln('❌ ERRORES:');
      for (final error in result.errors) {
        buffer.writeln('   • [${error.code.name}] ${error.message}');
        if (error.location?.nodeId != null) {
          buffer.writeln('     En nodo: ${error.location!.nodeId}');
        }
      }
      buffer.writeln();
    }

    // Warnings
    if (result.warnings.isNotEmpty) {
      buffer.writeln('⚠️ ADVERTENCIAS:');
      for (final warning in result.warnings) {
        buffer.writeln('   • [${warning.code.name}] ${warning.message}');
        if (warning.location?.nodeId != null) {
          buffer.writeln('     En nodo: ${warning.location!.nodeId}');
        }
      }
      buffer.writeln();
    }

    // Symbol table
    buffer.writeln('📋 TABLA DE SÍMBOLOS:');
    for (final symbol in result.symbolTable.allSymbols) {
      buffer.writeln('   • ${symbol.name}: ${symbol.dataType.cRepresentation}');
      buffer
          .writeln('     Inicializado: ${symbol.isInitialized ? "Sí" : "No"}');
      buffer.writeln('     Usado: ${symbol.isUsed ? "Sí" : "No"}');
    }
    buffer.writeln();

    // Type environment
    if (result.typeEnvironment.variableTypes.isNotEmpty) {
      buffer.writeln('🔤 TIPOS DE VARIABLES:');
      for (final entry in result.typeEnvironment.variableTypes.entries) {
        buffer.writeln('   ${entry.key}: ${entry.value.cRepresentation}');
      }
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════════════════════');

    return buffer.toString();
  }
}

// ============================================
// SEMANTIC ERROR FACTORY
// ============================================

/// Factory class for creating semantic errors
class SemanticError {
  /// Create an undeclared variable error
  static CompilerError undeclaredVariable(String variableName,
      {String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.undeclaredVariable,
      message: 'Variable no declarada: $variableName',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create a duplicate declaration error
  static CompilerError duplicateDeclaration(String variableName,
      {String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.duplicateDeclaration,
      message: 'Variable ya declarada: $variableName',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create a type mismatch error
  static CompilerError typeMismatch({
    required DataType expected,
    required DataType actual,
    String? nodeId,
  }) {
    return CompilerError.semantic(
      code: CompilerErrorCode.typeMismatch,
      message:
          'Incompatibilidad de tipos: se esperaba ${expected.cRepresentation}, '
          'pero se encontró ${actual.cRepresentation}',
      severity: CompilerSeverity.warning,
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an invalid operation error
  static CompilerError invalidOperation(
    String operator,
    DataType leftType,
    DataType rightType, {
    String? nodeId,
  }) {
    return CompilerError.semantic(
      code: CompilerErrorCode.invalidOperation,
      message: 'Operación inválida: $operator no puede aplicarse a '
          '${leftType.cRepresentation} y ${rightType.cRepresentation}',
      severity: CompilerSeverity.warning,
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an uninitialized variable warning
  static CompilerError uninitializedVariable(String variableName,
      {String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.uninitializedVariable,
      message: 'Variable posiblemente no inicializada: $variableName',
      severity: CompilerSeverity.warning,
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an unused variable warning
  static CompilerError unusedVariable(String variableName, {String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.unusedVariable,
      message: 'Variable declarada pero no usada: $variableName',
      severity: CompilerSeverity.warning,
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create a division by zero error
  static CompilerError divisionByZero({String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.divisionByZero,
      message: 'División por cero detectada',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an invalid array index error
  static CompilerError invalidArrayIndex({
    required DataType indexType,
    String? nodeId,
  }) {
    return CompilerError.semantic(
      code: CompilerErrorCode.invalidArrayIndex,
      message:
          'El índice del arreglo debe ser entero, pero es ${indexType.cRepresentation}',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an out of scope error
  static CompilerError outOfScope(String variableName, {String? nodeId}) {
    return CompilerError.semantic(
      code: CompilerErrorCode.outOfScope,
      message: 'Variable fuera de alcance: $variableName',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }

  /// Create an invalid type conversion error
  static CompilerError invalidTypeConversion({
    required DataType from,
    required DataType to,
    String? nodeId,
  }) {
    return CompilerError.semantic(
      code: CompilerErrorCode.invalidTypeConversion,
      message:
          'No se puede convertir de ${from.cRepresentation} a ${to.cRepresentation}',
      location: nodeId != null ? SourceLocation(nodeId: nodeId) : null,
    );
  }
}
