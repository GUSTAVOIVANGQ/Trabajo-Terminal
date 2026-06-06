/// Token System for FlowCode Diagram Compiler
/// Defines token types and token structure for lexical analysis
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

/// Enumeration of all token types recognized by the lexical analyzer
enum TokenType {
  // ============================================
  // IDENTIFIERS AND LITERALS
  // ============================================
  identifier, // Variable names: x, contador, suma
  integerLiteral, // Integer numbers: 0, 42, -17
  floatLiteral, // Floating point: 3.14, -0.5, 1.0
  stringLiteral, // String literals: "hello", 'world'
  charLiteral, // Character literals: 'a', 'X'
  booleanLiteral, // true, false

  // ============================================
  // KEYWORDS (C Language)
  // ============================================
  kwInt, // int
  kwFloat, // float
  kwDouble, // double
  kwChar, // char
  kwBool, // bool
  kwVoid, // void
  kwConst, // const
  kwIf, // if
  kwElse, // else
  kwWhile, // while
  kwFor, // for
  kwDo, // do
  kwSwitch, // switch
  kwCase, // case
  kwDefault, // default
  kwBreak, // break
  kwContinue, // continue
  kwReturn, // return
  kwPrintf, // printf (standard library)
  kwScanf, // scanf (standard library)

  // ============================================
  // SPANISH KEYWORDS (Flowchart specific)
  // ============================================
  kwLeer, // Leer (Read/Input)
  kwMostrar, // Mostrar (Show/Print)
  kwEscribir, // Escribir (Write)
  kwImprimir, // Imprimir (Print)
  kwIngresar, // Ingresar (Enter/Input)
  kwEntero, // Entero (Integer)
  kwReal, // Real (Float)
  kwCaracter, // Caracter (Char)
  kwCadena, // Cadena (String)
  kwBooleano, // Booleano (Boolean)
  kwVerdadero, // Verdadero (True)
  kwFalso, // Falso (False)
  kwSi, // Si (If)
  kwSino, // Sino (Else)
  kwMientras, // Mientras (While)
  kwPara, // Para (For)
  kwHacer, // Hacer (Do)
  kwHasta, // Hasta (Until)
  kwRetornar, // Retornar (Return)

  // ============================================
  // ARITHMETIC OPERATORS
  // ============================================
  opPlus, // +
  opMinus, // -
  opMultiply, // *
  opDivide, // /
  opModulo, // %
  opIncrement, // ++
  opDecrement, // --
  opPlusAssign, // +=
  opMinusAssign, // -=
  opMultiplyAssign, // *=
  opDivideAssign, // /=
  opModuloAssign, // %=

  // ============================================
  // COMPARISON OPERATORS
  // ============================================
  opEqual, // ==
  opNotEqual, // !=
  opLess, // <
  opLessEqual, // <=
  opGreater, // >
  opGreaterEqual, // >=

  // ============================================
  // LOGICAL OPERATORS
  // ============================================
  opAnd, // && or AND
  opOr, // || or OR
  opNot, // ! or NOT

  // ============================================
  // BITWISE OPERATORS
  // ============================================
  opBitAnd, // &
  opBitOr, // |
  opBitXor, // ^
  opBitNot, // ~
  opShiftLeft, // <<
  opShiftRight, // >>

  // ============================================
  // ASSIGNMENT
  // ============================================
  opAssign, // =

  // ============================================
  // DELIMITERS
  // ============================================
  leftParen, // (
  rightParen, // )
  leftBrace, // {
  rightBrace, // }
  leftBracket, // [
  rightBracket, // ]
  semicolon, // ;
  comma, // ,
  colon, // :
  dot, // .
  arrow, // ->
  questionMark, // ?

  // ============================================
  // SPECIAL TOKENS
  // ============================================
  newline, // Line break
  whitespace, // Spaces/tabs
  comment, // // or /* */
  formatSpecifier, // %d, %f, %s, %c, etc.

  // ============================================
  // ERROR AND EOF
  // ============================================
  unknown, // Unrecognized token
  endOfInput, // End of input
}

/// Extension to provide metadata about each TokenType
extension TokenTypeExtension on TokenType {
  /// Returns true if this token is an operator
  bool get isOperator {
    return index >= TokenType.opPlus.index && index <= TokenType.opAssign.index;
  }

  /// Returns true if this token is a keyword
  bool get isKeyword {
    return (index >= TokenType.kwInt.index &&
            index <= TokenType.kwScanf.index) ||
        (index >= TokenType.kwLeer.index &&
            index <= TokenType.kwRetornar.index);
  }

  /// Returns true if this token is a literal
  bool get isLiteral {
    return index >= TokenType.integerLiteral.index &&
        index <= TokenType.booleanLiteral.index;
  }

  /// Returns true if this token is a delimiter
  bool get isDelimiter {
    return index >= TokenType.leftParen.index &&
        index <= TokenType.questionMark.index;
  }

  /// Returns true if this token is a comparison operator
  bool get isComparisonOperator {
    return index >= TokenType.opEqual.index &&
        index <= TokenType.opGreaterEqual.index;
  }

  /// Returns true if this token is a logical operator
  bool get isLogicalOperator {
    return index >= TokenType.opAnd.index && index <= TokenType.opNot.index;
  }

  /// Returns true if this token is an arithmetic operator
  bool get isArithmeticOperator {
    return index >= TokenType.opPlus.index &&
        index <= TokenType.opModuloAssign.index;
  }

  /// Returns the precedence level for operators (higher = higher precedence)
  int get precedence {
    switch (this) {
      // Lowest precedence: assignment
      case TokenType.opAssign:
      case TokenType.opPlusAssign:
      case TokenType.opMinusAssign:
      case TokenType.opMultiplyAssign:
      case TokenType.opDivideAssign:
      case TokenType.opModuloAssign:
        return 1;

      // Logical OR
      case TokenType.opOr:
        return 2;

      // Logical AND
      case TokenType.opAnd:
        return 3;

      // Bitwise OR
      case TokenType.opBitOr:
        return 4;

      // Bitwise XOR
      case TokenType.opBitXor:
        return 5;

      // Bitwise AND
      case TokenType.opBitAnd:
        return 6;

      // Equality operators
      case TokenType.opEqual:
      case TokenType.opNotEqual:
        return 7;

      // Relational operators
      case TokenType.opLess:
      case TokenType.opLessEqual:
      case TokenType.opGreater:
      case TokenType.opGreaterEqual:
        return 8;

      // Shift operators
      case TokenType.opShiftLeft:
      case TokenType.opShiftRight:
        return 9;

      // Additive operators
      case TokenType.opPlus:
      case TokenType.opMinus:
        return 10;

      // Multiplicative operators
      case TokenType.opMultiply:
      case TokenType.opDivide:
      case TokenType.opModulo:
        return 11;

      // Unary operators (highest precedence)
      case TokenType.opNot:
      case TokenType.opBitNot:
      case TokenType.opIncrement:
      case TokenType.opDecrement:
        return 12;

      default:
        return 0;
    }
  }

  /// Returns true if the operator is right-associative
  bool get isRightAssociative {
    switch (this) {
      case TokenType.opAssign:
      case TokenType.opPlusAssign:
      case TokenType.opMinusAssign:
      case TokenType.opMultiplyAssign:
      case TokenType.opDivideAssign:
      case TokenType.opModuloAssign:
      case TokenType.opNot:
      case TokenType.opBitNot:
        return true;
      default:
        return false;
    }
  }

  /// Returns the C representation of this token type
  String get cRepresentation {
    switch (this) {
      case TokenType.opPlus:
        return '+';
      case TokenType.opMinus:
        return '-';
      case TokenType.opMultiply:
        return '*';
      case TokenType.opDivide:
        return '/';
      case TokenType.opModulo:
        return '%';
      case TokenType.opIncrement:
        return '++';
      case TokenType.opDecrement:
        return '--';
      case TokenType.opPlusAssign:
        return '+=';
      case TokenType.opMinusAssign:
        return '-=';
      case TokenType.opMultiplyAssign:
        return '*=';
      case TokenType.opDivideAssign:
        return '/=';
      case TokenType.opModuloAssign:
        return '%=';
      case TokenType.opEqual:
        return '==';
      case TokenType.opNotEqual:
        return '!=';
      case TokenType.opLess:
        return '<';
      case TokenType.opLessEqual:
        return '<=';
      case TokenType.opGreater:
        return '>';
      case TokenType.opGreaterEqual:
        return '>=';
      case TokenType.opAnd:
        return '&&';
      case TokenType.opOr:
        return '||';
      case TokenType.opNot:
        return '!';
      case TokenType.opBitAnd:
        return '&';
      case TokenType.opBitOr:
        return '|';
      case TokenType.opBitXor:
        return '^';
      case TokenType.opBitNot:
        return '~';
      case TokenType.opShiftLeft:
        return '<<';
      case TokenType.opShiftRight:
        return '>>';
      case TokenType.opAssign:
        return '=';
      case TokenType.leftParen:
        return '(';
      case TokenType.rightParen:
        return ')';
      case TokenType.leftBrace:
        return '{';
      case TokenType.rightBrace:
        return '}';
      case TokenType.leftBracket:
        return '[';
      case TokenType.rightBracket:
        return ']';
      case TokenType.semicolon:
        return ';';
      case TokenType.comma:
        return ',';
      case TokenType.colon:
        return ':';
      case TokenType.dot:
        return '.';
      case TokenType.arrow:
        return '->';
      case TokenType.questionMark:
        return '?';
      default:
        return '';
    }
  }
}

/// Represents a single token produced by the lexical analyzer
class Token {
  /// The type of this token
  final TokenType type;

  /// The actual text/lexeme that was matched
  final String lexeme;

  /// The line number where this token was found (1-based)
  final int line;

  /// The column number where this token starts (1-based)
  final int column;

  /// The ID of the node this token belongs to (for diagram context)
  final String? nodeId;

  /// Optional semantic value (e.g., parsed integer value for int literals)
  final dynamic value;

  const Token({
    required this.type,
    required this.lexeme,
    this.line = 1,
    this.column = 1,
    this.nodeId,
    this.value,
  });

  /// Creates a copy of this token with some fields changed
  Token copyWith({
    TokenType? type,
    String? lexeme,
    int? line,
    int? column,
    String? nodeId,
    dynamic value,
  }) {
    return Token(
      type: type ?? this.type,
      lexeme: lexeme ?? this.lexeme,
      line: line ?? this.line,
      column: column ?? this.column,
      nodeId: nodeId ?? this.nodeId,
      value: value ?? this.value,
    );
  }

  /// Returns a human-readable description of this token
  @override
  String toString() {
    final valueStr = value != null ? ', value: $value' : '';
    final nodeStr = nodeId != null ? ', node: $nodeId' : '';
    return 'Token($type, "$lexeme", line: $line, col: $column$valueStr$nodeStr)';
  }

  /// Returns a compact representation for debugging
  String toShortString() {
    return '[$type: "$lexeme"]';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token &&
        other.type == type &&
        other.lexeme == lexeme &&
        other.line == line &&
        other.column == column;
  }

  @override
  int get hashCode {
    return type.hashCode ^ lexeme.hashCode ^ line.hashCode ^ column.hashCode;
  }

  /// Returns true if this token represents an error
  bool get isError => type == TokenType.unknown;

  /// Returns true if this token is the end of input
  bool get isEOF => type == TokenType.endOfInput;

  /// Returns true if this is a significant token (not whitespace/comment/EOF)
  bool get isSignificant =>
      type != TokenType.whitespace &&
      type != TokenType.comment &&
      type != TokenType.newline &&
      type != TokenType.endOfInput;
}

/// Represents the position of a token in source text
class TokenPosition {
  final int line;
  final int column;
  final int offset; // Character offset from start of text

  const TokenPosition({
    required this.line,
    required this.column,
    required this.offset,
  });

  @override
  String toString() => 'Position(line: $line, col: $column, offset: $offset)';
}

/// Represents a span of tokens (useful for error reporting)
class TokenSpan {
  final Token start;
  final Token end;

  const TokenSpan({required this.start, required this.end});

  @override
  String toString() =>
      'Span(${start.toShortString()} to ${end.toShortString()})';
}
