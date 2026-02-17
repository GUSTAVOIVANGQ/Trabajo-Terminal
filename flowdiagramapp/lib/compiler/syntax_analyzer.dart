/// Syntax Analyzer for FlowCode Diagram Compiler
/// Implements Recursive Descent Parser for expression and statement parsing
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

import '../models/diagram_node.dart';
import 'token.dart';
import 'symbol_table.dart';
import 'ast_nodes.dart';
import 'compiler_errors.dart';
import 'lexical_analyzer.dart';

/// Result of syntactic analysis for a single node
class NodeSyntaxResult {
  final String nodeId;
  final String nodeType;
  final List<StatementNode> statements;
  final List<CompilerError> errors;
  final bool isValid;

  const NodeSyntaxResult({
    required this.nodeId,
    required this.nodeType,
    required this.statements,
    required this.errors,
    required this.isValid,
  });
}

/// Result of syntactic analysis for the entire diagram
class SyntaxAnalysisResult {
  final ProgramNode? ast;
  final List<NodeSyntaxResult> nodeResults;
  final List<CompilerError> errors;
  final bool isValid;
  final Duration analysisTime;

  const SyntaxAnalysisResult({
    this.ast,
    required this.nodeResults,
    required this.errors,
    required this.isValid,
    required this.analysisTime,
  });

  /// Get total statement count
  int get totalStatements =>
      nodeResults.fold(0, (sum, r) => sum + r.statements.length);

  /// Get error count by severity
  int getErrorCount(CompilerSeverity severity) =>
      errors.where((e) => e.severity == severity).length;
}

/// Syntactic Analyzer using Recursive Descent Parsing
class DiagramSyntaxAnalyzer {
  late List<Token> _tokens;
  int _current = 0;
  final List<CompilerError> _errors = [];
  String? _currentNodeId;
  final DiagramLexicalAnalyzer _lexicalAnalyzer;

  DiagramSyntaxAnalyzer() : _lexicalAnalyzer = DiagramLexicalAnalyzer();

  /// Analyze a complete diagram
  SyntaxAnalysisResult analyzeDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    final stopwatch = Stopwatch()..start();
    _errors.clear();

    final nodeResults = <NodeSyntaxResult>[];
    final diagramASTNodes = <DiagramASTNode>[];
    final globalDeclarations = <DeclarationStatementNode>[];

    for (final node in nodes) {
      final result = analyzeNode(node);
      nodeResults.add(result);

      if (result.isValid) {
        diagramASTNodes.add(DiagramASTNode(
          diagramNodeId: node.id,
          nodeType: node.type.name,
          statements: result.statements,
          label: node.text,
          position: const SourcePosition(line: 1, column: 1),
        ));

        // Collect global declarations from process nodes
        for (final stmt in result.statements) {
          if (stmt is DeclarationStatementNode) {
            globalDeclarations.add(stmt);
          }
        }
      }
    }

    stopwatch.stop();

    final allErrors = [
      ..._errors,
      ...nodeResults.expand((r) => r.errors),
    ];

    final hasErrors = allErrors.any((e) =>
        e.severity == CompilerSeverity.error ||
        e.severity == CompilerSeverity.fatal);

    ProgramNode? ast;
    if (!hasErrors) {
      ast = ProgramNode(
        diagramNodes: diagramASTNodes,
        globalDeclarations: globalDeclarations,
        position: const SourcePosition(line: 1, column: 1),
      );
    }

    return SyntaxAnalysisResult(
      ast: ast,
      nodeResults: nodeResults,
      errors: allErrors,
      isValid: !hasErrors,
      analysisTime: stopwatch.elapsed,
    );
  }

  /// Analyze a single diagram node
  NodeSyntaxResult analyzeNode(DiagramNode node) {
    _currentNodeId = node.id;
    _errors.clear();

    // Skip empty nodes or terminal nodes
    if (node.text.trim().isEmpty || node.type == NodeType.terminal) {
      return NodeSyntaxResult(
        nodeId: node.id,
        nodeType: node.type.name,
        statements: [],
        errors: [],
        isValid: true,
      );
    }

    // Tokenize the node content (with automatic normalization for decision nodes)
    final tokens = _lexicalAnalyzer.tokenizeNode(node);
    final significantTokens = tokens.where((t) => t.isSignificant).toList();

    if (significantTokens.isEmpty) {
      return NodeSyntaxResult(
        nodeId: node.id,
        nodeType: node.type.name,
        statements: [],
        errors: [],
        isValid: true,
      );
    }

    // Parse based on node type
    final statements = _parseNodeContent(node, significantTokens);

    return NodeSyntaxResult(
      nodeId: node.id,
      nodeType: node.type.name,
      statements: statements,
      errors: List.from(_errors),
      isValid: _errors.every((e) =>
          e.severity != CompilerSeverity.error &&
          e.severity != CompilerSeverity.fatal),
    );
  }

  /// Parse node content based on node type
  List<StatementNode> _parseNodeContent(
    DiagramNode node,
    List<Token> tokens,
  ) {
    _tokens = tokens;
    _current = 0;

    switch (node.type) {
      case NodeType.process:
        return _parseProcessNode();
      case NodeType.data:
        return _parseDataNode(node);
      case NodeType.decision:
        return _parseDecisionNode();
      case NodeType.preparation:
        return _parsePreparationNode();
      case NodeType.predefinedProcess:
        return _parsePredefinedProcessNode();
      case NodeType.terminal:
        return [];
      default:
        return _parseGenericStatements();
    }
  }

  /// Parse a process node (assignments, expressions, declarations)
  /// Supports multiple variable declarations: int a, b, c
  List<StatementNode> _parseProcessNode() {
    final statements = <StatementNode>[];

    while (!_isAtEnd()) {
      try {
        // Check if it's a declaration (may contain multiple variables)
        if (_isDeclaration()) {
          final declarations = _parseDeclarations();
          statements.addAll(declarations);
        } else {
          final stmt = _parseStatement();
          if (stmt != null) {
            statements.add(stmt);
          }
        }
      } catch (e) {
        // Synchronize on error
        _synchronize();
      }
    }

    return statements;
  }

  /// Parse a data node (input/output operations or return statements)
  List<StatementNode> _parseDataNode(DiagramNode node) {
    // Check for return statement first (metadata or keyword)
    if (node.metadata['isReturn'] == true || _hasReturnKeyword()) {
      final stmt = _parseReturnStatement();
      return stmt != null ? [stmt] : [];
    }

    // Check metadata for input/output direction
    final isInput =
        node.metadata['dataDirection'] == 'input' || _hasInputKeyword();

    if (isInput) {
      return _parseInputStatement();
    } else {
      return _parseOutputStatement();
    }
  }

  /// Check if current tokens contain a return keyword
  bool _hasReturnKeyword() {
    final savedPosition = _current;
    while (!_isAtEnd()) {
      if (_check(TokenType.kwReturn) || _check(TokenType.kwRetornar)) {
        _current = savedPosition;
        return true;
      }
      _advance();
    }
    _current = savedPosition;
    return false;
  }

  /// Parse a decision node (condition)
  List<StatementNode> _parseDecisionNode() {
    // Decision nodes contain just a condition expression
    try {
      final expr = _parseExpression();
      if (expr != null) {
        return [
          ExpressionStatementNode(
            expression: expr,
            position: _getPosition(),
            nodeId: _currentNodeId,
          )
        ];
      }
    } catch (e) {
      _addError(
        CompilerErrorCode.invalidExpression,
        'Expresión de condición inválida',
        _getPosition(),
      );
    }
    return [];
  }

  /// Parse a preparation node (declarations, initializations)
  List<StatementNode> _parsePreparationNode() {
    final statements = <StatementNode>[];

    while (!_isAtEnd()) {
      try {
        // Try to parse as declaration first (supports multiple vars: int a, b, c)
        if (_isDeclaration()) {
          final declarations = _parseDeclarations();
          statements.addAll(declarations);
        } else {
          // Otherwise parse as regular statement
          final stmt = _parseStatement();
          if (stmt != null) {
            statements.add(stmt);
          }
        }
      } catch (e) {
        _synchronize();
      }
    }

    return statements;
  }

  /// Parse a predefined process node (function calls, including with pointer operators)
  List<StatementNode> _parsePredefinedProcessNode() {
    final statements = <StatementNode>[];

    while (!_isAtEnd()) {
      try {
        // Check for assignment: result = FunctionCall(...)
        if (_check(TokenType.identifier) && _checkNext(TokenType.opAssign)) {
          final stmt = _parseStatement();
          if (stmt != null) {
            statements.add(stmt);
          }
        } else if (_check(TokenType.identifier) &&
            _checkNext(TokenType.leftParen)) {
          final call = _parseFunctionCall();
          if (call != null) {
            statements.add(ExpressionStatementNode(
              expression: call,
              position: _getPosition(),
              nodeId: _currentNodeId,
            ));
          }
        } else {
          final stmt = _parseStatement();
          if (stmt != null) {
            statements.add(stmt);
          }
        }
      } catch (e) {
        _synchronize();
      }
    }

    return statements;
  }

  /// Parse generic statements
  List<StatementNode> _parseGenericStatements() {
    final statements = <StatementNode>[];

    while (!_isAtEnd()) {
      try {
        final stmt = _parseStatement();
        if (stmt != null) {
          statements.add(stmt);
        }
      } catch (e) {
        _synchronize();
      }
    }

    return statements;
  }

  // ============================================
  // STATEMENT PARSING
  // ============================================

  /// Parse a statement
  StatementNode? _parseStatement() {
    // Skip semicolons
    while (_match([TokenType.semicolon])) {}

    if (_isAtEnd()) return null;

    // Check for declaration
    if (_isDeclaration()) {
      return _parseDeclaration();
    }

    // Check for control flow keywords
    if (_match([TokenType.kwIf, TokenType.kwSi])) {
      return _parseIfStatement();
    }

    if (_match([TokenType.kwWhile, TokenType.kwMientras])) {
      return _parseWhileStatement();
    }

    if (_match([TokenType.kwFor, TokenType.kwPara])) {
      return _parseForStatement();
    }

    if (_match([TokenType.kwDo, TokenType.kwHacer])) {
      return _parseDoWhileStatement();
    }

    if (_match([TokenType.kwReturn, TokenType.kwRetornar])) {
      return _parseReturnStatement();
    }

    if (_match([TokenType.kwBreak])) {
      return BreakStatementNode(
        position: _getPosition(),
        nodeId: _currentNodeId,
      );
    }

    if (_match([TokenType.kwContinue])) {
      return ContinueStatementNode(
        position: _getPosition(),
        nodeId: _currentNodeId,
      );
    }

    // Check for input/output keywords
    if (_isInputKeyword()) {
      final stmts = _parseInputStatement();
      return stmts.isNotEmpty ? stmts.first : null;
    }

    if (_isOutputKeyword()) {
      final stmts = _parseOutputStatement();
      return stmts.isNotEmpty ? stmts.first : null;
    }

    // Parse as expression statement
    return _parseExpressionStatement();
  }

  /// Check if current position starts a declaration
  bool _isDeclaration() {
    return _check(TokenType.kwInt) ||
        _check(TokenType.kwFloat) ||
        _check(TokenType.kwDouble) ||
        _check(TokenType.kwChar) ||
        _check(TokenType.kwBool) ||
        _check(TokenType.kwVoid) ||
        _check(TokenType.kwConst) ||
        _check(TokenType.kwEntero) ||
        _check(TokenType.kwReal) ||
        _check(TokenType.kwCaracter) ||
        _check(TokenType.kwCadena) ||
        _check(TokenType.kwBooleano);
  }

  /// Parse a declaration statement (supports multiple variables: int a, b, c)
  /// Returns a single DeclarationStatementNode for single variable
  /// or wraps multiple declarations - caller should use _parseDeclarations() for multi-var support
  DeclarationStatementNode? _parseDeclaration() {
    final declarations = _parseDeclarations();
    return declarations.isNotEmpty ? declarations.first : null;
  }

  /// Parse declarations that may contain multiple variables of the same type
  /// Example: "int a, b, c" returns [DeclarationStatementNode(a), DeclarationStatementNode(b), DeclarationStatementNode(c)]
  /// Example: "int x = 5" returns [DeclarationStatementNode(x, initializer: 5)]
  /// Example: "int *ptr = arr" returns [DeclarationStatementNode(ptr, isPointer: true)]
  List<DeclarationStatementNode> _parseDeclarations() {
    final position = _getPosition();
    final declarations = <DeclarationStatementNode>[];

    // Parse type
    final dataType = _parseDataType();
    if (dataType == null) {
      _addError(
        CompilerErrorCode.invalidDeclaration,
        'Se esperaba un tipo de dato',
        position,
      );
      return declarations;
    }

    // Check for pointer declaration immediately after type (asterisk after type)
    // Handles: "int *ptr", "int* ptr", "int * ptr"
    bool isPointerType = _match([TokenType.opMultiply]);

    // Parse first variable (required) - check after possibly consuming pointer asterisk
    if (!_check(TokenType.identifier)) {
      _addError(
        CompilerErrorCode.invalidDeclaration,
        'Se esperaba un identificador',
        _getPosition(),
      );
      return declarations;
    }

    // Track if we're in the first iteration (where isPointerType applies)
    bool firstVariable = true;

    // Parse all variable names (comma-separated)
    do {
      final varPosition = _getPosition();

      // For first variable, use isPointerType. For subsequent variables, check for individual asterisk.
      bool isPointer;
      if (firstVariable) {
        isPointer = isPointerType;
        firstVariable = false;
      } else {
        // Check for pointer on this specific variable (e.g., "int a, *b, c")
        isPointer = _match([TokenType.opMultiply]);
      }

      if (!_check(TokenType.identifier)) {
        _addError(
          CompilerErrorCode.invalidDeclaration,
          'Se esperaba un identificador después de la coma',
          _getPosition(),
        );
        break;
      }

      final nameToken = _advance();
      final variableName = nameToken.lexeme;

      // Check for array declaration
      bool isArray = false;
      int? arraySize;

      if (_match([TokenType.leftBracket])) {
        isArray = true;
        if (_check(TokenType.integerLiteral)) {
          arraySize = int.parse(_advance().lexeme);
        }
        if (!_match([TokenType.rightBracket])) {
          _addError(
            CompilerErrorCode.unbalancedBrackets,
            'Se esperaba \']\'',
            _getPosition(),
          );
        }
      }

      // Check for initializer (only for last variable or single variable)
      ASTNode? initializer;
      if (_match([TokenType.opAssign])) {
        initializer = _parseExpression();
      }

      declarations.add(DeclarationStatementNode(
        dataType: dataType,
        variableName: variableName,
        initializer: initializer,
        isArray: isArray,
        arraySize: arraySize,
        isPointer: isPointer,
        position: varPosition,
        nodeId: _currentNodeId,
      ));
    } while (_match([TokenType.comma]));

    // Consume optional semicolon
    _match([TokenType.semicolon]);

    return declarations;
  }

  /// Parse a data type keyword
  DataType? _parseDataType() {
    if (_match([TokenType.kwInt, TokenType.kwEntero])) {
      return DataType.integer;
    }
    if (_match([TokenType.kwFloat, TokenType.kwReal])) {
      return DataType.float;
    }
    if (_match([TokenType.kwDouble])) {
      return DataType.double_;
    }
    if (_match([TokenType.kwChar, TokenType.kwCaracter])) {
      return DataType.char;
    }
    if (_match([TokenType.kwBool, TokenType.kwBooleano])) {
      return DataType.boolean;
    }
    if (_match([TokenType.kwCadena])) {
      return DataType.string;
    }
    if (_match([TokenType.kwVoid])) {
      return DataType.void_;
    }
    if (_match([TokenType.kwConst])) {
      // const followed by another type
      return _parseDataType();
    }
    return null;
  }

  /// Parse if statement
  IfStatementNode _parseIfStatement() {
    final position = _getPosition();

    // Parse condition
    _match([TokenType.leftParen]);
    final condition = _parseExpression();
    _match([TokenType.rightParen]);

    if (condition == null) {
      _addError(
        CompilerErrorCode.invalidExpression,
        'Se esperaba una condición',
        position,
      );
      return IfStatementNode(
        condition: BooleanLiteralNode(
          value: true,
          position: position,
        ),
        thenBranch: BlockStatementNode(
          statements: [],
          position: position,
        ),
        position: position,
        nodeId: _currentNodeId,
      );
    }

    // Parse then branch
    final thenBranch = _parseBlock();

    // Check for else branch
    StatementNode? elseBranch;
    if (_match([TokenType.kwElse, TokenType.kwSino])) {
      if (_check(TokenType.kwIf) || _check(TokenType.kwSi)) {
        _advance();
        elseBranch = _parseIfStatement();
      } else {
        elseBranch = _parseBlock();
      }
    }

    return IfStatementNode(
      condition: condition,
      thenBranch: thenBranch,
      elseBranch: elseBranch,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse while statement
  WhileStatementNode _parseWhileStatement() {
    final position = _getPosition();

    _match([TokenType.leftParen]);
    final condition = _parseExpression();
    _match([TokenType.rightParen]);

    if (condition == null) {
      _addError(
        CompilerErrorCode.invalidExpression,
        'Se esperaba una condición',
        position,
      );
      return WhileStatementNode(
        condition: BooleanLiteralNode(value: true, position: position),
        body: BlockStatementNode(statements: [], position: position),
        position: position,
        nodeId: _currentNodeId,
      );
    }

    final body = _parseBlock();

    return WhileStatementNode(
      condition: condition,
      body: body,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse for statement
  ForStatementNode _parseForStatement() {
    final position = _getPosition();

    _match([TokenType.leftParen]);

    // Parse initializer
    ASTNode? initializer;
    if (!_check(TokenType.semicolon)) {
      if (_isDeclaration()) {
        initializer = _parseDeclaration();
      } else {
        initializer = _parseExpression();
      }
    }
    _match([TokenType.semicolon]);

    // Parse condition
    ASTNode? condition;
    if (!_check(TokenType.semicolon)) {
      condition = _parseExpression();
    }
    _match([TokenType.semicolon]);

    // Parse update
    ASTNode? update;
    if (!_check(TokenType.rightParen)) {
      update = _parseExpression();
    }
    _match([TokenType.rightParen]);

    final body = _parseBlock();

    return ForStatementNode(
      initializer: initializer,
      condition: condition,
      update: update,
      body: body,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse do-while statement
  DoWhileStatementNode _parseDoWhileStatement() {
    final position = _getPosition();

    final body = _parseBlock();

    if (!_match([TokenType.kwWhile, TokenType.kwMientras])) {
      _addError(
        CompilerErrorCode.missingToken,
        'Se esperaba "while" o "mientras"',
        _getPosition(),
      );
    }

    _match([TokenType.leftParen]);
    final condition = _parseExpression();
    _match([TokenType.rightParen]);
    _match([TokenType.semicolon]);

    if (condition == null) {
      return DoWhileStatementNode(
        body: body,
        condition: BooleanLiteralNode(value: true, position: position),
        position: position,
        nodeId: _currentNodeId,
      );
    }

    return DoWhileStatementNode(
      body: body,
      condition: condition,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse return statement
  ReturnStatementNode _parseReturnStatement() {
    final position = _getPosition();

    // Consume return keyword if present
    _match([TokenType.kwReturn, TokenType.kwRetornar]);

    ASTNode? value;
    if (!_check(TokenType.semicolon) && !_isAtEnd()) {
      value = _parseExpression();
    }
    _match([TokenType.semicolon]);

    return ReturnStatementNode(
      value: value,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse a block of statements
  BlockStatementNode _parseBlock() {
    final position = _getPosition();
    final statements = <StatementNode>[];

    if (_match([TokenType.leftBrace])) {
      while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
        final stmt = _parseStatement();
        if (stmt != null) {
          statements.add(stmt);
        }
      }
      _match([TokenType.rightBrace]);
    } else {
      // Single statement
      final stmt = _parseStatement();
      if (stmt != null) {
        statements.add(stmt);
      }
    }

    return BlockStatementNode(
      statements: statements,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse expression statement
  ExpressionStatementNode? _parseExpressionStatement() {
    final position = _getPosition();
    final expr = _parseExpression();

    if (expr == null) {
      // Skip unknown token
      if (!_isAtEnd()) {
        _advance();
      }
      return null;
    }

    _match([TokenType.semicolon]);

    return ExpressionStatementNode(
      expression: expr,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  // ============================================
  // INPUT/OUTPUT PARSING
  // ============================================

  bool _hasInputKeyword() {
    for (int i = 0; i < _tokens.length; i++) {
      if (_isInputTokenType(_tokens[i].type)) {
        return true;
      }
    }
    return false;
  }

  bool _isInputKeyword() {
    return _isInputTokenType(_peek().type);
  }

  bool _isInputTokenType(TokenType type) {
    return type == TokenType.kwLeer ||
        type == TokenType.kwIngresar ||
        type == TokenType.kwScanf;
  }

  bool _isOutputKeyword() {
    return _isOutputTokenType(_peek().type);
  }

  bool _isOutputTokenType(TokenType type) {
    return type == TokenType.kwMostrar ||
        type == TokenType.kwEscribir ||
        type == TokenType.kwImprimir ||
        type == TokenType.kwPrintf;
  }

  /// Parse input statement: Leer(x), scanf("%d", &x)
  List<StatementNode> _parseInputStatement() {
    final position = _getPosition();
    final variables = <IdentifierNode>[];
    String? formatString;

    // Consume input keyword
    if (_isInputKeyword()) {
      _advance();
    }

    // Parse arguments
    _match([TokenType.leftParen]);

    // Check for format string first (scanf style)
    if (_check(TokenType.stringLiteral)) {
      final token = _advance();
      formatString = token.value as String?;
      _match([TokenType.comma]);
    }

    // Parse variable list
    while (!_check(TokenType.rightParen) && !_isAtEnd()) {
      // Skip & for scanf
      _match([TokenType.opBitAnd]);

      if (_check(TokenType.identifier)) {
        final token = _advance();
        variables.add(IdentifierNode(
          name: token.lexeme,
          position: SourcePosition.fromToken(token),
          nodeId: _currentNodeId,
        ));
      }

      if (!_match([TokenType.comma])) break;
    }

    _match([TokenType.rightParen]);
    _match([TokenType.semicolon]);

    return [
      InputStatementNode(
        variables: variables,
        formatString: formatString,
        position: position,
        nodeId: _currentNodeId,
      )
    ];
  }

  /// Parse output statement: Mostrar(x), printf("%d", x)
  List<StatementNode> _parseOutputStatement() {
    final position = _getPosition();
    final expressions = <ASTNode>[];
    String? formatString;

    // Consume output keyword
    if (_isOutputKeyword()) {
      _advance();
    }

    // Parse arguments
    _match([TokenType.leftParen]);

    // Check for format string first (printf style)
    if (_check(TokenType.stringLiteral)) {
      final token = _advance();
      formatString = token.value as String?;

      if (_match([TokenType.comma])) {
        // Parse remaining expressions
        while (!_check(TokenType.rightParen) && !_isAtEnd()) {
          final expr = _parseExpression();
          if (expr != null) {
            expressions.add(expr);
          }
          if (!_match([TokenType.comma])) break;
        }
      }
    } else {
      // Spanish style: Mostrar(x, y, z)
      while (!_check(TokenType.rightParen) && !_isAtEnd()) {
        final expr = _parseExpression();
        if (expr != null) {
          expressions.add(expr);
        }
        if (!_match([TokenType.comma])) break;
      }
    }

    _match([TokenType.rightParen]);
    _match([TokenType.semicolon]);

    return [
      OutputStatementNode(
        expressions: formatString != null && expressions.isEmpty
            ? [
                StringLiteralNode(
                  value: formatString,
                  position: position,
                )
              ]
            : expressions,
        formatString: formatString,
        position: position,
        nodeId: _currentNodeId,
      )
    ];
  }

  // ============================================
  // EXPRESSION PARSING (Recursive Descent)
  // ============================================

  /// Parse an expression
  ASTNode? _parseExpression() {
    return _parseAssignment();
  }

  /// Parse assignment expression
  ASTNode? _parseAssignment() {
    final expr = _parseConditional();

    if (_checkAssignment()) {
      final op = AssignmentOperatorExtension.fromTokenType(_advance().type);
      final value = _parseAssignment();

      if (op != null && value != null && expr != null) {
        return AssignmentExpressionNode(
          target: expr,
          operator: op,
          value: value,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  bool _checkAssignment() {
    return _check(TokenType.opAssign) ||
        _check(TokenType.opPlusAssign) ||
        _check(TokenType.opMinusAssign) ||
        _check(TokenType.opMultiplyAssign) ||
        _check(TokenType.opDivideAssign) ||
        _check(TokenType.opModuloAssign);
  }

  /// Parse conditional (ternary) expression
  ASTNode? _parseConditional() {
    var expr = _parseOr();

    if (_match([TokenType.questionMark])) {
      final trueExpr = _parseExpression();
      if (!_match([TokenType.colon])) {
        _addError(
          CompilerErrorCode.missingToken,
          'Se esperaba ":"',
          _getPosition(),
        );
      }
      final falseExpr = _parseConditional();

      if (expr != null && trueExpr != null && falseExpr != null) {
        expr = ConditionalExpressionNode(
          condition: expr,
          trueExpression: trueExpr,
          falseExpression: falseExpr,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse logical OR expression
  ASTNode? _parseOr() {
    var expr = _parseAnd();

    while (_match([TokenType.opOr])) {
      final right = _parseAnd();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: BinaryOperator.or,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse logical AND expression
  ASTNode? _parseAnd() {
    var expr = _parseBitOr();

    while (_match([TokenType.opAnd])) {
      final right = _parseBitOr();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: BinaryOperator.and,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse bitwise OR expression
  ASTNode? _parseBitOr() {
    var expr = _parseBitXor();

    while (_match([TokenType.opBitOr])) {
      final right = _parseBitXor();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: BinaryOperator.bitOr,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse bitwise XOR expression
  ASTNode? _parseBitXor() {
    var expr = _parseBitAnd();

    while (_match([TokenType.opBitXor])) {
      final right = _parseBitAnd();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: BinaryOperator.bitXor,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse bitwise AND expression
  ASTNode? _parseBitAnd() {
    var expr = _parseEquality();

    while (_match([TokenType.opBitAnd])) {
      final right = _parseEquality();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: BinaryOperator.bitAnd,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse equality expression
  ASTNode? _parseEquality() {
    var expr = _parseComparison();

    while (_match([TokenType.opEqual, TokenType.opNotEqual])) {
      final op = _previous().type == TokenType.opEqual
          ? BinaryOperator.equal
          : BinaryOperator.notEqual;
      final right = _parseComparison();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: op,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse comparison expression
  ASTNode? _parseComparison() {
    var expr = _parseShift();

    while (_match([
      TokenType.opLess,
      TokenType.opLessEqual,
      TokenType.opGreater,
      TokenType.opGreaterEqual,
    ])) {
      final opType = _previous().type;
      BinaryOperator op;
      switch (opType) {
        case TokenType.opLess:
          op = BinaryOperator.less;
          break;
        case TokenType.opLessEqual:
          op = BinaryOperator.lessEqual;
          break;
        case TokenType.opGreater:
          op = BinaryOperator.greater;
          break;
        case TokenType.opGreaterEqual:
          op = BinaryOperator.greaterEqual;
          break;
        default:
          op = BinaryOperator.less;
      }
      final right = _parseShift();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: op,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse shift expression
  ASTNode? _parseShift() {
    var expr = _parseAdditive();

    while (_match([TokenType.opShiftLeft, TokenType.opShiftRight])) {
      final op = _previous().type == TokenType.opShiftLeft
          ? BinaryOperator.shiftLeft
          : BinaryOperator.shiftRight;
      final right = _parseAdditive();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: op,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse additive expression
  ASTNode? _parseAdditive() {
    var expr = _parseMultiplicative();

    while (_match([TokenType.opPlus, TokenType.opMinus])) {
      final op = _previous().type == TokenType.opPlus
          ? BinaryOperator.add
          : BinaryOperator.subtract;
      final right = _parseMultiplicative();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: op,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse multiplicative expression
  ASTNode? _parseMultiplicative() {
    var expr = _parseUnary();

    while (_match([
      TokenType.opMultiply,
      TokenType.opDivide,
      TokenType.opModulo,
    ])) {
      final opType = _previous().type;
      BinaryOperator op;
      switch (opType) {
        case TokenType.opMultiply:
          op = BinaryOperator.multiply;
          break;
        case TokenType.opDivide:
          op = BinaryOperator.divide;
          break;
        case TokenType.opModulo:
          op = BinaryOperator.modulo;
          break;
        default:
          op = BinaryOperator.multiply;
      }
      final right = _parseUnary();
      if (expr != null && right != null) {
        expr = BinaryExpressionNode(
          left: expr,
          operator: op,
          right: right,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return expr;
  }

  /// Parse unary expression
  ASTNode? _parseUnary() {
    // Prefix operators (including pointer operators & and *)
    if (_match([
      TokenType.opNot,
      TokenType.opBitNot,
      TokenType.opMinus,
      TokenType.opIncrement,
      TokenType.opDecrement,
      TokenType.opBitAnd, // & (address-of operator)
      TokenType.opMultiply, // * (dereference operator)
    ])) {
      final opType = _previous().type;
      final operand = _parseUnary();

      if (operand != null) {
        UnaryOperator op;
        switch (opType) {
          case TokenType.opNot:
            op = UnaryOperator.not;
            break;
          case TokenType.opBitNot:
            op = UnaryOperator.bitNot;
            break;
          case TokenType.opMinus:
            op = UnaryOperator.negate;
            break;
          case TokenType.opIncrement:
            op = UnaryOperator.preIncrement;
            break;
          case TokenType.opDecrement:
            op = UnaryOperator.preDecrement;
            break;
          case TokenType.opBitAnd:
            op = UnaryOperator.addressOf;
            break;
          case TokenType.opMultiply:
            op = UnaryOperator.dereference;
            break;
          default:
            op = UnaryOperator.negate;
        }

        return UnaryExpressionNode(
          operator: op,
          operand: operand,
          position: _getPosition(),
          nodeId: _currentNodeId,
        );
      }
    }

    return _parsePostfix();
  }

  /// Parse postfix expression
  ASTNode? _parsePostfix() {
    var expr = _parsePrimary();

    while (true) {
      if (_match([TokenType.opIncrement])) {
        if (expr != null) {
          expr = UnaryExpressionNode(
            operator: UnaryOperator.postIncrement,
            operand: expr,
            position: _getPosition(),
            nodeId: _currentNodeId,
          );
        }
      } else if (_match([TokenType.opDecrement])) {
        if (expr != null) {
          expr = UnaryExpressionNode(
            operator: UnaryOperator.postDecrement,
            operand: expr,
            position: _getPosition(),
            nodeId: _currentNodeId,
          );
        }
      } else if (_match([TokenType.leftBracket])) {
        // Array access
        final index = _parseExpression();
        if (!_match([TokenType.rightBracket])) {
          _addError(
            CompilerErrorCode.unbalancedBrackets,
            'Se esperaba \']\'',
            _getPosition(),
          );
        }
        if (expr != null && index != null) {
          expr = ArrayAccessNode(
            array: expr,
            index: index,
            position: _getPosition(),
            nodeId: _currentNodeId,
          );
        }
      } else if (_match([TokenType.leftParen])) {
        // Function call (if expr is identifier)
        if (expr is IdentifierNode) {
          final args = _parseArgumentList();
          expr = FunctionCallNode(
            functionName: expr.name,
            arguments: args,
            position: _getPosition(),
            nodeId: _currentNodeId,
          );
        } else {
          _addError(
            CompilerErrorCode.invalidExpression,
            'Solo se pueden llamar funciones con identificadores',
            _getPosition(),
          );
        }
      } else {
        break;
      }
    }

    return expr;
  }

  /// Parse primary expression
  ASTNode? _parsePrimary() {
    final position = _getPosition();

    // Literals
    if (_match([TokenType.integerLiteral])) {
      final value = int.tryParse(_previous().lexeme) ?? 0;
      return IntegerLiteralNode(
        value: value,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    if (_match([TokenType.floatLiteral])) {
      final value = double.tryParse(_previous().lexeme) ?? 0.0;
      return FloatLiteralNode(
        value: value,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    if (_match([TokenType.stringLiteral])) {
      final value = _previous().value as String? ?? _previous().lexeme;
      return StringLiteralNode(
        value: value,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    if (_match([TokenType.charLiteral])) {
      final value = _previous().value as String? ?? _previous().lexeme;
      return CharLiteralNode(
        value: value,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    if (_match(
        [TokenType.booleanLiteral, TokenType.kwVerdadero, TokenType.kwFalso])) {
      final lexeme = _previous().lexeme.toLowerCase();
      final value = lexeme == 'true' || lexeme == 'verdadero';
      return BooleanLiteralNode(
        value: value,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    // Identifier or function call
    if (_match([TokenType.identifier])) {
      final name = _previous().lexeme;

      // Check if it's a function call
      if (_check(TokenType.leftParen)) {
        _advance(); // consume '('
        final args = _parseArgumentList();
        return FunctionCallNode(
          functionName: name,
          arguments: args,
          position: position,
          nodeId: _currentNodeId,
        );
      }

      return IdentifierNode(
        name: name,
        position: position,
        nodeId: _currentNodeId,
      );
    }

    // Parenthesized expression
    if (_match([TokenType.leftParen])) {
      final expr = _parseExpression();
      if (!_match([TokenType.rightParen])) {
        _addError(
          CompilerErrorCode.unbalancedParentheses,
          'Se esperaba \')\'',
          _getPosition(),
        );
      }
      return expr;
    }

    // Array initializer: {1, 2, 3, 4, 5}
    if (_match([TokenType.leftBrace])) {
      return _parseArrayInitializer(position);
    }

    // Unknown token
    if (!_isAtEnd()) {
      _addError(
        CompilerErrorCode.unexpectedToken,
        'Token inesperado: ${_peek().lexeme}',
        position,
      );
    }

    return null;
  }

  /// Parse array initializer: {expr, expr, ...}
  ArrayInitializerNode _parseArrayInitializer(SourcePosition position) {
    final elements = <ASTNode>[];

    // Parse elements until we hit '}'
    if (!_check(TokenType.rightBrace)) {
      do {
        final element = _parseExpression();
        if (element != null) {
          elements.add(element);
        }
      } while (_match([TokenType.comma]));
    }

    if (!_match([TokenType.rightBrace])) {
      _addError(
        CompilerErrorCode.missingToken,
        'Se esperaba \'}\'',
        _getPosition(),
      );
    }

    return ArrayInitializerNode(
      elements: elements,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse function call (when identifier is already consumed)
  FunctionCallNode? _parseFunctionCall() {
    if (!_check(TokenType.identifier)) return null;

    final nameToken = _advance();
    final position = SourcePosition.fromToken(nameToken);

    if (!_match([TokenType.leftParen])) {
      return null;
    }

    final args = _parseArgumentList();

    return FunctionCallNode(
      functionName: nameToken.lexeme,
      arguments: args,
      position: position,
      nodeId: _currentNodeId,
    );
  }

  /// Parse argument list
  List<ASTNode> _parseArgumentList() {
    final args = <ASTNode>[];

    if (!_check(TokenType.rightParen)) {
      do {
        final arg = _parseExpression();
        if (arg != null) {
          args.add(arg);
        }
      } while (_match([TokenType.comma]));
    }

    if (!_match([TokenType.rightParen])) {
      _addError(
        CompilerErrorCode.unbalancedParentheses,
        'Se esperaba \')\'',
        _getPosition(),
      );
    }

    return args;
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Check if at end of tokens
  bool _isAtEnd() => _current >= _tokens.length;

  /// Get current token
  Token _peek() => _isAtEnd()
      ? const Token(
          type: TokenType.endOfInput,
          lexeme: '',
          line: 0,
          column: 0,
        )
      : _tokens[_current];

  /// Get previous token
  Token _previous() => _tokens[_current - 1];

  /// Check if current token matches type
  bool _check(TokenType type) => !_isAtEnd() && _peek().type == type;

  /// Check if next token matches type
  bool _checkNext(TokenType type) {
    if (_current + 1 >= _tokens.length) return false;
    return _tokens[_current + 1].type == type;
  }

  /// Advance to next token
  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  /// Match and consume any of the given token types
  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  /// Get current source position
  SourcePosition _getPosition() {
    if (_isAtEnd()) {
      return _tokens.isNotEmpty
          ? SourcePosition.fromToken(_tokens.last)
          : const SourcePosition(line: 1, column: 1);
    }
    return SourcePosition.fromToken(_peek());
  }

  /// Add a syntax error
  void _addError(
      CompilerErrorCode code, String message, SourcePosition position) {
    _errors.add(SyntaxError(
      code: code,
      message: message,
      location: SourceLocation(
        line: position.line,
        column: position.column,
        nodeId: _currentNodeId,
      ),
    ));
  }

  /// Synchronize after error (skip to next statement)
  void _synchronize() {
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.semicolon) return;

      switch (_peek().type) {
        case TokenType.kwInt:
        case TokenType.kwFloat:
        case TokenType.kwDouble:
        case TokenType.kwChar:
        case TokenType.kwBool:
        case TokenType.kwIf:
        case TokenType.kwWhile:
        case TokenType.kwFor:
        case TokenType.kwReturn:
        case TokenType.kwLeer:
        case TokenType.kwMostrar:
        case TokenType.kwEntero:
        case TokenType.kwReal:
        case TokenType.kwSi:
        case TokenType.kwMientras:
        case TokenType.kwPara:
        case TokenType.kwRetornar:
          return;
        default:
          _advance();
      }
    }
  }

  // ============================================
  // PUBLIC API - EXPRESSION PARSING
  // ============================================

  /// Parse a single expression string
  ASTNode? parseExpression(String expression, {String? nodeId}) {
    _currentNodeId = nodeId;
    _errors.clear();

    final tokens = _lexicalAnalyzer.tokenize(expression, nodeId: nodeId);
    _tokens = tokens.where((t) => t.isSignificant).toList();
    _current = 0;

    if (_tokens.isEmpty) return null;

    return _parseExpression();
  }

  /// Parse a list of tokens directly
  ASTNode? parseTokens(List<Token> tokens, {String? nodeId}) {
    _currentNodeId = nodeId;
    _errors.clear();

    _tokens = tokens.where((t) => t.isSignificant).toList();
    _current = 0;

    if (_tokens.isEmpty) return null;

    return _parseExpression();
  }

  /// Get parsing errors
  List<CompilerError> get errors => List.unmodifiable(_errors);

  /// Check if expression is valid
  bool validateExpression(String expression) {
    final result = parseExpression(expression);
    return result != null && _errors.isEmpty;
  }

  /// Check if parentheses are balanced
  bool checkBalancedParentheses(String expression) {
    int count = 0;
    for (final char in expression.runes) {
      if (String.fromCharCode(char) == '(') count++;
      if (String.fromCharCode(char) == ')') count--;
      if (count < 0) return false;
    }
    return count == 0;
  }

  /// Check if brackets are balanced
  bool checkBalancedBrackets(String expression) {
    int count = 0;
    for (final char in expression.runes) {
      if (String.fromCharCode(char) == '[') count++;
      if (String.fromCharCode(char) == ']') count--;
      if (count < 0) return false;
    }
    return count == 0;
  }

  /// Check if braces are balanced
  bool checkBalancedBraces(String expression) {
    int count = 0;
    for (final char in expression.runes) {
      if (String.fromCharCode(char) == '{') count++;
      if (String.fromCharCode(char) == '}') count--;
      if (count < 0) return false;
    }
    return count == 0;
  }

  /// Generate analysis report
  String generateReport(SyntaxAnalysisResult result) {
    final buffer = StringBuffer();

    buffer.writeln(
        '╔════════════════════════════════════════════════════════════╗');
    buffer.writeln(
        '║           REPORTE DE ANÁLISIS SINTÁCTICO                    ║');
    buffer.writeln(
        '╠════════════════════════════════════════════════════════════╣');
    buffer
        .writeln('║ Estado: ${result.isValid ? "✅ VÁLIDO" : "❌ CON ERRORES"}');
    buffer.writeln('║ Tiempo: ${result.analysisTime.inMilliseconds}ms');
    buffer.writeln('║ Nodos analizados: ${result.nodeResults.length}');
    buffer.writeln('║ Statements generados: ${result.totalStatements}');
    buffer.writeln(
        '╠════════════════════════════════════════════════════════════╣');

    if (result.errors.isNotEmpty) {
      buffer.writeln('║ ERRORES:');
      for (final error in result.errors) {
        buffer.writeln('║   ${error.severity.emoji} ${error.message}');
        if (error.location != null) {
          buffer.writeln(
              '║      Línea ${error.location!.line}, Col ${error.location!.column}');
        }
      }
    }

    buffer.writeln(
        '╠════════════════════════════════════════════════════════════╣');
    buffer.writeln('║ AST GENERADO:');
    if (result.ast != null) {
      for (final line in result.ast!.toTreeString().split('\n')) {
        buffer.writeln('║   $line');
      }
    } else {
      buffer.writeln('║   No se generó AST debido a errores');
    }

    buffer.writeln(
        '╚════════════════════════════════════════════════════════════╝');

    return buffer.toString();
  }
}
