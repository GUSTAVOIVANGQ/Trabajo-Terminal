/// Lexical Analyzer for FlowCode Diagram Compiler
/// Tokenizes text content from diagram nodes
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

import '../models/diagram_node.dart';
import 'token.dart';
import 'symbol_table.dart';
import 'compiler_errors.dart';

/// Result of lexical analysis for a single node
class NodeLexicalResult {
  /// The ID of the analyzed node
  final String nodeId;

  /// The type of the analyzed node
  final NodeType nodeType;

  /// The original text content
  final String originalText;

  /// The tokens extracted from the node
  final List<Token> tokens;

  /// Errors encountered during tokenization
  final List<LexicalError> errors;

  /// Whether the tokenization was successful
  bool get isSuccess => errors.isEmpty;

  /// The significant tokens (excluding whitespace and comments)
  List<Token> get significantTokens =>
      tokens.where((t) => t.isSignificant).toList();

  const NodeLexicalResult({
    required this.nodeId,
    required this.nodeType,
    required this.originalText,
    required this.tokens,
    required this.errors,
  });

  @override
  String toString() {
    return 'NodeLexicalResult(nodeId: $nodeId, tokens: ${tokens.length}, errors: ${errors.length})';
  }
}

/// Result of lexical analysis for the entire diagram
class DiagramLexicalResult {
  /// Results for each node
  final List<NodeLexicalResult> nodeResults;

  /// The symbol table built during analysis
  final SymbolTable symbolTable;

  /// All errors from all nodes
  final List<LexicalError> errors;

  /// All tokens from all nodes
  List<Token> get allTokens => nodeResults.expand((r) => r.tokens).toList();

  /// Whether the entire analysis was successful
  bool get isSuccess => errors.isEmpty;

  /// Number of tokens extracted
  int get tokenCount => allTokens.length;

  const DiagramLexicalResult({
    required this.nodeResults,
    required this.symbolTable,
    required this.errors,
  });

  @override
  String toString() {
    return 'DiagramLexicalResult(nodes: ${nodeResults.length}, tokens: $tokenCount, errors: ${errors.length})';
  }

  /// Generate a detailed report
  String generateReport() {
    final buffer = StringBuffer();

    buffer
        .writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('        REPORTE DE ANÁLISIS LÉXICO');
    buffer
        .writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('📊 Resumen:');
    buffer.writeln('   • Nodos analizados: ${nodeResults.length}');
    buffer.writeln('   • Tokens extraídos: $tokenCount');
    buffer.writeln('   • Errores encontrados: ${errors.length}');
    buffer.writeln('   • Símbolos en tabla: ${symbolTable.symbolCount}');
    buffer.writeln('');

    if (errors.isNotEmpty) {
      buffer.writeln('❌ Errores:');
      for (final error in errors) {
        buffer.writeln('   ${error.toString()}');
      }
      buffer.writeln('');
    }

    buffer.writeln('📝 Tokens por nodo:');
    for (final result in nodeResults) {
      buffer.writeln('');
      buffer.writeln('   Nodo: ${result.nodeId} (${result.nodeType.name})');
      buffer.writeln('   Texto: "${result.originalText}"');
      buffer.writeln('   Tokens:');
      for (final token in result.significantTokens) {
        buffer.writeln('      ${token.toShortString()}');
      }
    }

    buffer.writeln('');
    buffer.writeln('📋 Tabla de Símbolos:');
    buffer.writeln(symbolTable.toString());

    buffer
        .writeln('═══════════════════════════════════════════════════════════');

    return buffer.toString();
  }
}

/// Main Lexical Analyzer for Flowchart Diagrams
class DiagramLexicalAnalyzer {
  /// Keywords in C
  static const Map<String, TokenType> _cKeywords = {
    'int': TokenType.kwInt,
    'float': TokenType.kwFloat,
    'double': TokenType.kwDouble,
    'char': TokenType.kwChar,
    'bool': TokenType.kwBool,
    'void': TokenType.kwVoid,
    'const': TokenType.kwConst,
    'if': TokenType.kwIf,
    'else': TokenType.kwElse,
    'while': TokenType.kwWhile,
    'for': TokenType.kwFor,
    'do': TokenType.kwDo,
    'switch': TokenType.kwSwitch,
    'case': TokenType.kwCase,
    'default': TokenType.kwDefault,
    'break': TokenType.kwBreak,
    'continue': TokenType.kwContinue,
    'return': TokenType.kwReturn,
    'printf': TokenType.kwPrintf,
    'scanf': TokenType.kwScanf,
    'true': TokenType.booleanLiteral,
    'false': TokenType.booleanLiteral,
  };

  /// Keywords in Spanish (flowchart specific)
  static const Map<String, TokenType> _spanishKeywords = {
    'leer': TokenType.kwLeer,
    'mostrar': TokenType.kwMostrar,
    'escribir': TokenType.kwEscribir,
    'imprimir': TokenType.kwImprimir,
    'ingresar': TokenType.kwIngresar,
    'entero': TokenType.kwEntero,
    'real': TokenType.kwReal,
    'caracter': TokenType.kwCaracter,
    'cadena': TokenType.kwCadena,
    'booleano': TokenType.kwBooleano,
    'verdadero': TokenType.booleanLiteral,
    'falso': TokenType.booleanLiteral,
    'si': TokenType.kwSi,
    'sino': TokenType.kwSino,
    'mientras': TokenType.kwMientras,
    'para': TokenType.kwPara,
    'hacer': TokenType.kwHacer,
    'hasta': TokenType.kwHasta,
    'retornar': TokenType.kwRetornar,
  };

  /// Two-character operators
  static const Map<String, TokenType> _twoCharOperators = {
    '++': TokenType.opIncrement,
    '--': TokenType.opDecrement,
    '+=': TokenType.opPlusAssign,
    '-=': TokenType.opMinusAssign,
    '*=': TokenType.opMultiplyAssign,
    '/=': TokenType.opDivideAssign,
    '%=': TokenType.opModuloAssign,
    '==': TokenType.opEqual,
    '!=': TokenType.opNotEqual,
    '<=': TokenType.opLessEqual,
    '>=': TokenType.opGreaterEqual,
    '&&': TokenType.opAnd,
    '||': TokenType.opOr,
    '<<': TokenType.opShiftLeft,
    '>>': TokenType.opShiftRight,
    '->': TokenType.arrow,
  };

  /// Single-character operators and delimiters
  /// Note: '%' is handled separately to distinguish modulo from format specifiers
  static const Map<String, TokenType> _singleCharTokens = {
    '+': TokenType.opPlus,
    '-': TokenType.opMinus,
    '*': TokenType.opMultiply,
    '/': TokenType.opDivide,
    // '%' handled separately - can be modulo or format specifier
    '=': TokenType.opAssign,
    '<': TokenType.opLess,
    '>': TokenType.opGreater,
    '!': TokenType.opNot,
    '&': TokenType.opBitAnd,
    '|': TokenType.opBitOr,
    '^': TokenType.opBitXor,
    '~': TokenType.opBitNot,
    '(': TokenType.leftParen,
    ')': TokenType.rightParen,
    '{': TokenType.leftBrace,
    '}': TokenType.rightBrace,
    '[': TokenType.leftBracket,
    ']': TokenType.rightBracket,
    ';': TokenType.semicolon,
    ',': TokenType.comma,
    ':': TokenType.colon,
    '.': TokenType.dot,
    '?': TokenType.questionMark,
  };

  /// The symbol table being built
  late SymbolTable _symbolTable;

  /// Current position in the text
  int _position = 0;

  /// Current line number
  int _line = 1;

  /// Current column number
  int _column = 1;

  /// The text being tokenized
  String _text = '';

  /// Current node ID
  String? _currentNodeId;

  /// Errors collected during analysis
  final List<LexicalError> _errors = [];

  DiagramLexicalAnalyzer();

  /// Analyze an entire diagram
  DiagramLexicalResult analyzeDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    _symbolTable = SymbolTable();
    final nodeResults = <NodeLexicalResult>[];
    final allErrors = <LexicalError>[];

    // Analyze each node
    for (final node in nodes) {
      if (node.text.trim().isNotEmpty) {
        final result = analyzeNode(node);
        nodeResults.add(result);
        allErrors.addAll(result.errors);

        // Extract variable declarations and add to symbol table
        _extractSymbols(result, node);
      }
    }

    return DiagramLexicalResult(
      nodeResults: nodeResults,
      symbolTable: _symbolTable,
      errors: allErrors,
    );
  }

  /// Analyze a single node
  NodeLexicalResult analyzeNode(DiagramNode node) {
    _currentNodeId = node.id;
    final tokens = tokenize(node.text, nodeId: node.id);

    return NodeLexicalResult(
      nodeId: node.id,
      nodeType: node.type,
      originalText: node.text,
      tokens: tokens,
      errors: List.from(_errors),
    );
  }

  /// Tokenize a string of text
  List<Token> tokenize(String text, {String? nodeId}) {
    _text = text;
    _position = 0;
    _line = 1;
    _column = 1;
    _currentNodeId = nodeId;
    _errors.clear();

    final tokens = <Token>[];

    while (!_isAtEnd()) {
      final token = _scanToken();
      if (token != null) {
        tokens.add(token);
      }
    }

    // Add end of input token
    tokens.add(Token(
      type: TokenType.endOfInput,
      lexeme: '',
      line: _line,
      column: _column,
      nodeId: nodeId,
    ));

    return tokens;
  }

  /// Extract symbols from lexical result and add to symbol table
  void _extractSymbols(NodeLexicalResult result, DiagramNode node) {
    final tokens = result.significantTokens;

    // Pattern: type identifier = value OR type identifier
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      // Check for type keywords
      if (_isTypeKeyword(token.type)) {
        final dataType = _tokenTypeToDataType(token.type);

        // Next token should be an identifier
        if (i + 1 < tokens.length &&
            tokens[i + 1].type == TokenType.identifier) {
          final nameToken = tokens[i + 1];

          // Check if it's an initialization
          bool isInitialized = false;
          dynamic initialValue;

          if (i + 2 < tokens.length &&
              tokens[i + 2].type == TokenType.opAssign) {
            isInitialized = true;
            if (i + 3 < tokens.length) {
              initialValue = tokens[i + 3].value ?? tokens[i + 3].lexeme;
            }
          }

          _symbolTable.declareSymbol(
            name: nameToken.lexeme,
            dataType: dataType,
            nodeId: node.id,
            line: nameToken.line,
            column: nameToken.column,
            isInitialized: isInitialized,
            initialValue: initialValue,
          );
        }
      }

      // Also check for assignments without explicit type (type inference)
      if (token.type == TokenType.identifier) {
        if (i + 1 < tokens.length && tokens[i + 1].type == TokenType.opAssign) {
          // If variable doesn't exist, infer type from value
          if (!_symbolTable.symbolExists(token.lexeme)) {
            DataType inferredType = DataType.integer; // Default

            if (i + 2 < tokens.length) {
              final valueToken = tokens[i + 2];
              inferredType = _inferTypeFromToken(valueToken);
            }

            _symbolTable.declareSymbol(
              name: token.lexeme,
              dataType: inferredType,
              nodeId: node.id,
              line: token.line,
              column: token.column,
              isInitialized: true,
            );
          } else {
            // Mark as initialized if already declared
            _symbolTable.markAsInitialized(token.lexeme);
          }
        } else {
          // Just using the variable, mark as used
          _symbolTable.markAsUsed(token.lexeme);
        }
      }
    }
  }

  /// Scan the next token
  Token? _scanToken() {
    _skipWhitespace();

    if (_isAtEnd()) return null;

    final startLine = _line;
    final startColumn = _column;
    final char = _advance();

    // Check for two-character operators
    if (!_isAtEnd()) {
      final twoChar = char + _peek();
      if (_twoCharOperators.containsKey(twoChar)) {
        _advance();
        return Token(
          type: _twoCharOperators[twoChar]!,
          lexeme: twoChar,
          line: startLine,
          column: startColumn,
          nodeId: _currentNodeId,
        );
      }
    }

    // Format specifier (for printf/scanf) - check BEFORE single-char tokens
    // because % could be modulo or format specifier
    if (char == '%') {
      if (!_isAtEnd()) {
        final nextChar = _peek();
        // Check if it looks like a format specifier
        if (_isAlpha(nextChar) ||
            '+-# 0'.contains(nextChar) ||
            _isDigit(nextChar)) {
          return _scanFormatSpecifier(startLine, startColumn);
        }
      }
      // Otherwise it's the modulo operator (including when % is at end of input)
      return Token(
        type: TokenType.opModulo,
        lexeme: char,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
      );
    }

    // Check for single-character tokens
    if (_singleCharTokens.containsKey(char)) {
      return Token(
        type: _singleCharTokens[char]!,
        lexeme: char,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
      );
    }

    // String literals
    if (char == '"' || char == "'") {
      return _scanString(char, startLine, startColumn);
    }

    // Numbers
    if (_isDigit(char)) {
      return _scanNumber(char, startLine, startColumn);
    }

    // Identifiers and keywords
    if (_isAlpha(char)) {
      return _scanIdentifier(char, startLine, startColumn);
    }

    // Unknown character
    _errors.add(LexicalError.unexpectedCharacter(
      char,
      SourceLocation(
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
      ),
    ));

    return Token(
      type: TokenType.unknown,
      lexeme: char,
      line: startLine,
      column: startColumn,
      nodeId: _currentNodeId,
    );
  }

  /// Skip whitespace and track line/column
  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final char = _peek();
      switch (char) {
        case ' ':
        case '\t':
        case '\r':
          _advance();
          break;
        case '\n':
          _line++;
          _column = 0;
          _advance();
          break;
        case '/':
          if (_peekNext() == '/') {
            // Single-line comment
            while (!_isAtEnd() && _peek() != '\n') {
              _advance();
            }
          } else if (_peekNext() == '*') {
            // Multi-line comment
            _advance(); // /
            _advance(); // *
            while (!_isAtEnd() && !(_peek() == '*' && _peekNext() == '/')) {
              if (_peek() == '\n') {
                _line++;
                _column = 0;
              }
              _advance();
            }
            if (!_isAtEnd()) {
              _advance(); // *
              _advance(); // /
            }
          } else {
            return;
          }
          break;
        default:
          return;
      }
    }
  }

  /// Scan a string literal
  Token _scanString(String quote, int startLine, int startColumn) {
    final buffer = StringBuffer();

    while (!_isAtEnd() && _peek() != quote) {
      if (_peek() == '\n') {
        _errors.add(LexicalError.unterminatedString(
          SourceLocation(
            line: startLine,
            column: startColumn,
            nodeId: _currentNodeId,
          ),
        ));
        break;
      }

      // Handle escape sequences
      if (_peek() == '\\' && !_isAtEnd()) {
        _advance(); // Skip backslash
        final escaped = _advance();
        switch (escaped) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          case "'":
            buffer.write("'");
            break;
          case '0':
            buffer.write('\x00');
            break;
          default:
            buffer.write(escaped);
        }
      } else {
        buffer.write(_advance());
      }
    }

    if (!_isAtEnd() && _peek() == quote) {
      _advance(); // Closing quote
    } else if (_isAtEnd()) {
      // Reached end of input without closing quote
      _errors.add(LexicalError.unterminatedString(
        SourceLocation(
          line: startLine,
          column: startColumn,
          nodeId: _currentNodeId,
        ),
      ));
    }

    final value = buffer.toString();
    final lexeme = quote + value + quote;

    // Determine if it's a char or string literal
    final type = (quote == "'" && value.length == 1)
        ? TokenType.charLiteral
        : TokenType.stringLiteral;

    return Token(
      type: type,
      lexeme: lexeme,
      line: startLine,
      column: startColumn,
      nodeId: _currentNodeId,
      value: value,
    );
  }

  /// Scan a number (integer or float)
  Token _scanNumber(String firstChar, int startLine, int startColumn) {
    final buffer = StringBuffer(firstChar);
    bool isFloat = false;

    // Consume digits
    while (!_isAtEnd() && _isDigit(_peek())) {
      buffer.write(_advance());
    }

    // Check for decimal point
    if (!_isAtEnd() && _peek() == '.' && _isDigit(_peekNext())) {
      isFloat = true;
      buffer.write(_advance()); // .

      while (!_isAtEnd() && _isDigit(_peek())) {
        buffer.write(_advance());
      }
    }

    // Check for exponent
    if (!_isAtEnd() && (_peek() == 'e' || _peek() == 'E')) {
      isFloat = true;
      buffer.write(_advance()); // e/E

      if (!_isAtEnd() && (_peek() == '+' || _peek() == '-')) {
        buffer.write(_advance());
      }

      while (!_isAtEnd() && _isDigit(_peek())) {
        buffer.write(_advance());
      }
    }

    // Check for float suffix
    if (!_isAtEnd() && (_peek() == 'f' || _peek() == 'F')) {
      isFloat = true;
      buffer.write(_advance());
    }

    final lexeme = buffer.toString();

    try {
      final value = isFloat ? double.parse(lexeme) : int.parse(lexeme);

      return Token(
        type: isFloat ? TokenType.floatLiteral : TokenType.integerLiteral,
        lexeme: lexeme,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
        value: value,
      );
    } catch (e) {
      _errors.add(LexicalError.invalidNumber(
        lexeme,
        SourceLocation(
          line: startLine,
          column: startColumn,
          nodeId: _currentNodeId,
        ),
      ));

      return Token(
        type: TokenType.unknown,
        lexeme: lexeme,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
      );
    }
  }

  /// Scan an identifier or keyword
  Token _scanIdentifier(String firstChar, int startLine, int startColumn) {
    final buffer = StringBuffer(firstChar);

    while (!_isAtEnd() && _isAlphaNumeric(_peek())) {
      buffer.write(_advance());
    }

    final lexeme = buffer.toString();
    final lowerLexeme = lexeme.toLowerCase();

    // Check if it's a C keyword
    if (_cKeywords.containsKey(lowerLexeme)) {
      return Token(
        type: _cKeywords[lowerLexeme]!,
        lexeme: lexeme,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
        value: lowerLexeme == 'true'
            ? true
            : (lowerLexeme == 'false' ? false : null),
      );
    }

    // Check if it's a Spanish keyword
    if (_spanishKeywords.containsKey(lowerLexeme)) {
      return Token(
        type: _spanishKeywords[lowerLexeme]!,
        lexeme: lexeme,
        line: startLine,
        column: startColumn,
        nodeId: _currentNodeId,
        value: lowerLexeme == 'verdadero'
            ? true
            : (lowerLexeme == 'falso' ? false : null),
      );
    }

    // It's an identifier
    return Token(
      type: TokenType.identifier,
      lexeme: lexeme,
      line: startLine,
      column: startColumn,
      nodeId: _currentNodeId,
    );
  }

  /// Scan a format specifier (%d, %f, %s, etc.)
  Token _scanFormatSpecifier(int startLine, int startColumn) {
    final buffer = StringBuffer('%');

    // Optional flags
    while (!_isAtEnd() && '+-# 0'.contains(_peek())) {
      buffer.write(_advance());
    }

    // Optional width
    while (!_isAtEnd() && _isDigit(_peek())) {
      buffer.write(_advance());
    }

    // Optional precision
    if (!_isAtEnd() && _peek() == '.') {
      buffer.write(_advance());
      while (!_isAtEnd() && _isDigit(_peek())) {
        buffer.write(_advance());
      }
    }

    // Length modifier
    while (!_isAtEnd() && 'hlL'.contains(_peek())) {
      buffer.write(_advance());
    }

    // Conversion specifier
    if (!_isAtEnd() && 'diouxXeEfFgGaAcspn%'.contains(_peek())) {
      buffer.write(_advance());
    }

    return Token(
      type: TokenType.formatSpecifier,
      lexeme: buffer.toString(),
      line: startLine,
      column: startColumn,
      nodeId: _currentNodeId,
    );
  }

  // Helper methods

  bool _isAtEnd() => _position >= _text.length;

  String _peek() => _isAtEnd() ? '\x00' : _text[_position];

  String _peekNext() =>
      _position + 1 >= _text.length ? '\x00' : _text[_position + 1];

  String _advance() {
    final char = _text[_position++];
    _column++;
    return char;
  }

  bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  bool _isAlpha(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // A-Z
        (code >= 97 && code <= 122) || // a-z
        char == '_';
  }

  bool _isAlphaNumeric(String char) => _isAlpha(char) || _isDigit(char);

  bool _isTypeKeyword(TokenType type) {
    return type == TokenType.kwInt ||
        type == TokenType.kwFloat ||
        type == TokenType.kwDouble ||
        type == TokenType.kwChar ||
        type == TokenType.kwBool ||
        type == TokenType.kwVoid ||
        type == TokenType.kwEntero ||
        type == TokenType.kwReal ||
        type == TokenType.kwCaracter ||
        type == TokenType.kwCadena ||
        type == TokenType.kwBooleano;
  }

  DataType _tokenTypeToDataType(TokenType type) {
    switch (type) {
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
        return DataType.unknown;
    }
  }

  DataType _inferTypeFromToken(Token token) {
    switch (token.type) {
      case TokenType.integerLiteral:
        return DataType.integer;
      case TokenType.floatLiteral:
        return DataType.float;
      case TokenType.stringLiteral:
        return DataType.string;
      case TokenType.charLiteral:
        return DataType.char;
      case TokenType.booleanLiteral:
        return DataType.boolean;
      default:
        return DataType.unknown;
    }
  }

  /// Validate that an identifier follows C naming conventions
  static bool isValidCIdentifier(String identifier) {
    if (identifier.isEmpty) return false;

    // Must start with letter or underscore
    if (!RegExp(r'^[a-zA-Z_]').hasMatch(identifier)) return false;

    // Rest must be alphanumeric or underscore
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(identifier)) return false;

    // Cannot be a C keyword
    if (_cKeywords.containsKey(identifier.toLowerCase())) return false;

    return true;
  }

  /// Get all C keywords
  static Set<String> get cKeywords => _cKeywords.keys.toSet();

  /// Get all Spanish keywords
  static Set<String> get spanishKeywords => _spanishKeywords.keys.toSet();
}
