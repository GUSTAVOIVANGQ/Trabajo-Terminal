/// Compiler Errors for FlowCode Diagram Compiler
/// Defines error types and error handling for all compilation phases
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

/// Severity level of a compiler message
enum CompilerSeverity {
  info, // Informational message
  warning, // Warning (compilation continues)
  error, // Error (compilation may fail)
  fatal, // Fatal error (compilation stops)
}

/// Extension for CompilerSeverity
extension CompilerSeverityExtension on CompilerSeverity {
  String get prefix {
    switch (this) {
      case CompilerSeverity.info:
        return 'INFO';
      case CompilerSeverity.warning:
        return 'WARNING';
      case CompilerSeverity.error:
        return 'ERROR';
      case CompilerSeverity.fatal:
        return 'FATAL';
    }
  }

  String get emoji {
    switch (this) {
      case CompilerSeverity.info:
        return 'ℹ️';
      case CompilerSeverity.warning:
        return '⚠️';
      case CompilerSeverity.error:
        return '❌';
      case CompilerSeverity.fatal:
        return '🛑';
    }
  }
}

/// The phase where an error occurred
enum CompilerPhase {
  structural, // Structural validation (graph topology)
  lexical, // Lexical analysis (tokenization)
  syntactic, // Syntactic analysis (parsing)
  semantic, // Semantic analysis (type checking)
  optimization, // Optimization phase
  codeGen, // Code generation
}

/// Extension for CompilerPhase
extension CompilerPhaseExtension on CompilerPhase {
  String get displayName {
    switch (this) {
      case CompilerPhase.structural:
        return 'Validación Estructural';
      case CompilerPhase.lexical:
        return 'Análisis Léxico';
      case CompilerPhase.syntactic:
        return 'Análisis Sintáctico';
      case CompilerPhase.semantic:
        return 'Análisis Semántico';
      case CompilerPhase.optimization:
        return 'Optimización';
      case CompilerPhase.codeGen:
        return 'Generación de Código';
    }
  }

  String get englishName {
    switch (this) {
      case CompilerPhase.structural:
        return 'Structural Validation';
      case CompilerPhase.lexical:
        return 'Lexical Analysis';
      case CompilerPhase.syntactic:
        return 'Syntactic Analysis';
      case CompilerPhase.semantic:
        return 'Semantic Analysis';
      case CompilerPhase.optimization:
        return 'Optimization';
      case CompilerPhase.codeGen:
        return 'Code Generation';
    }
  }
}

/// Error codes for specific error types
enum CompilerErrorCode {
  // Lexical errors (1xxx)
  unexpectedCharacter, // 1001
  unterminatedString, // 1002
  unterminatedComment, // 1003
  invalidNumber, // 1004
  invalidIdentifier, // 1005
  invalidEscapeSequence, // 1006
  numberOverflow, // 1007
  emptyCharLiteral, // 1008
  multiCharacterLiteral, // 1009
  invalidFormatSpecifier, // 1010

  // Syntactic errors (2xxx)
  unexpectedToken, // 2001
  missingToken, // 2002
  unbalancedParentheses, // 2003
  unbalancedBraces, // 2004
  unbalancedBrackets, // 2005
  invalidExpression, // 2006
  missingSemicolon, // 2007
  invalidAssignment, // 2008
  invalidDeclaration, // 2009
  invalidStatement, // 2010

  // Semantic errors (3xxx)
  undeclaredVariable, // 3001
  duplicateDeclaration, // 3002
  typeMismatch, // 3003
  invalidOperation, // 3004
  uninitializedVariable, // 3005
  unusedVariable, // 3006
  invalidTypeConversion, // 3007
  divisionByZero, // 3008
  invalidArrayIndex, // 3009
  outOfScope, // 3010
  unknownFunction, // 3011

  // Structural errors (4xxx)
  missingStartNode, // 4001
  missingEndNode, // 4002
  multipleStartNodes, // 4003
  disconnectedNode, // 4004
  invalidConnection, // 4005
  infiniteLoop, // 4006
  unreachableNode, // 4007
  invalidDecisionBranch, // 4008
  missingReturnPath, // 4009
  cyclicDependency, // 4010

  // Code generation errors (5xxx)
  unsupportedConstruct, // 5001
  codeGenerationFailed, // 5002
  templateError, // 5003

  // Generic
  unknown, // 9999
}

/// Extension for CompilerErrorCode
extension CompilerErrorCodeExtension on CompilerErrorCode {
  int get numericCode {
    switch (this) {
      // Lexical errors
      case CompilerErrorCode.unexpectedCharacter:
        return 1001;
      case CompilerErrorCode.unterminatedString:
        return 1002;
      case CompilerErrorCode.unterminatedComment:
        return 1003;
      case CompilerErrorCode.invalidNumber:
        return 1004;
      case CompilerErrorCode.invalidIdentifier:
        return 1005;
      case CompilerErrorCode.invalidEscapeSequence:
        return 1006;
      case CompilerErrorCode.numberOverflow:
        return 1007;
      case CompilerErrorCode.emptyCharLiteral:
        return 1008;
      case CompilerErrorCode.multiCharacterLiteral:
        return 1009;
      case CompilerErrorCode.invalidFormatSpecifier:
        return 1010;

      // Syntactic errors
      case CompilerErrorCode.unexpectedToken:
        return 2001;
      case CompilerErrorCode.missingToken:
        return 2002;
      case CompilerErrorCode.unbalancedParentheses:
        return 2003;
      case CompilerErrorCode.unbalancedBraces:
        return 2004;
      case CompilerErrorCode.unbalancedBrackets:
        return 2005;
      case CompilerErrorCode.invalidExpression:
        return 2006;
      case CompilerErrorCode.missingSemicolon:
        return 2007;
      case CompilerErrorCode.invalidAssignment:
        return 2008;
      case CompilerErrorCode.invalidDeclaration:
        return 2009;
      case CompilerErrorCode.invalidStatement:
        return 2010;

      // Semantic errors
      case CompilerErrorCode.undeclaredVariable:
        return 3001;
      case CompilerErrorCode.duplicateDeclaration:
        return 3002;
      case CompilerErrorCode.typeMismatch:
        return 3003;
      case CompilerErrorCode.invalidOperation:
        return 3004;
      case CompilerErrorCode.uninitializedVariable:
        return 3005;
      case CompilerErrorCode.unusedVariable:
        return 3006;
      case CompilerErrorCode.invalidTypeConversion:
        return 3007;
      case CompilerErrorCode.divisionByZero:
        return 3008;
      case CompilerErrorCode.invalidArrayIndex:
        return 3009;
      case CompilerErrorCode.outOfScope:
        return 3010;
      case CompilerErrorCode.unknownFunction:
        return 3011;

      // Structural errors
      case CompilerErrorCode.missingStartNode:
        return 4001;
      case CompilerErrorCode.missingEndNode:
        return 4002;
      case CompilerErrorCode.multipleStartNodes:
        return 4003;
      case CompilerErrorCode.disconnectedNode:
        return 4004;
      case CompilerErrorCode.invalidConnection:
        return 4005;
      case CompilerErrorCode.infiniteLoop:
        return 4006;
      case CompilerErrorCode.unreachableNode:
        return 4007;
      case CompilerErrorCode.invalidDecisionBranch:
        return 4008;
      case CompilerErrorCode.missingReturnPath:
        return 4009;
      case CompilerErrorCode.cyclicDependency:
        return 4010;

      // Code generation errors
      case CompilerErrorCode.unsupportedConstruct:
        return 5001;
      case CompilerErrorCode.codeGenerationFailed:
        return 5002;
      case CompilerErrorCode.templateError:
        return 5003;

      case CompilerErrorCode.unknown:
        return 9999;
    }
  }

  String get description {
    switch (this) {
      case CompilerErrorCode.unexpectedCharacter:
        return 'Carácter inesperado encontrado';
      case CompilerErrorCode.unterminatedString:
        return 'Cadena de texto no terminada';
      case CompilerErrorCode.unterminatedComment:
        return 'Comentario no terminado';
      case CompilerErrorCode.invalidNumber:
        return 'Número inválido';
      case CompilerErrorCode.invalidIdentifier:
        return 'Identificador inválido';
      case CompilerErrorCode.invalidEscapeSequence:
        return 'Secuencia de escape inválida';
      case CompilerErrorCode.numberOverflow:
        return 'Número demasiado grande';
      case CompilerErrorCode.emptyCharLiteral:
        return 'Literal de carácter vacío';
      case CompilerErrorCode.multiCharacterLiteral:
        return 'Literal de carácter con múltiples caracteres';
      case CompilerErrorCode.invalidFormatSpecifier:
        return 'Especificador de formato inválido';
      case CompilerErrorCode.unexpectedToken:
        return 'Token inesperado';
      case CompilerErrorCode.missingToken:
        return 'Token faltante';
      case CompilerErrorCode.unbalancedParentheses:
        return 'Paréntesis desbalanceados';
      case CompilerErrorCode.unbalancedBraces:
        return 'Llaves desbalanceadas';
      case CompilerErrorCode.unbalancedBrackets:
        return 'Corchetes desbalanceados';
      case CompilerErrorCode.invalidExpression:
        return 'Expresión inválida';
      case CompilerErrorCode.missingSemicolon:
        return 'Punto y coma faltante';
      case CompilerErrorCode.invalidAssignment:
        return 'Asignación inválida';
      case CompilerErrorCode.invalidDeclaration:
        return 'Declaración inválida';
      case CompilerErrorCode.invalidStatement:
        return 'Sentencia inválida';
      case CompilerErrorCode.undeclaredVariable:
        return 'Variable no declarada';
      case CompilerErrorCode.duplicateDeclaration:
        return 'Declaración duplicada';
      case CompilerErrorCode.typeMismatch:
        return 'Tipos incompatibles';
      case CompilerErrorCode.invalidOperation:
        return 'Operación inválida';
      case CompilerErrorCode.uninitializedVariable:
        return 'Variable no inicializada';
      case CompilerErrorCode.unusedVariable:
        return 'Variable no utilizada';
      case CompilerErrorCode.invalidTypeConversion:
        return 'Conversión de tipo inválida';
      case CompilerErrorCode.divisionByZero:
        return 'División por cero';
      case CompilerErrorCode.invalidArrayIndex:
        return 'Índice de arreglo inválido';
      case CompilerErrorCode.outOfScope:
        return 'Variable fuera de alcance';
      case CompilerErrorCode.unknownFunction:
        return 'Función no reconocida';
      case CompilerErrorCode.missingStartNode:
        return 'Falta nodo de inicio';
      case CompilerErrorCode.missingEndNode:
        return 'Falta nodo de fin';
      case CompilerErrorCode.multipleStartNodes:
        return 'Múltiples nodos de inicio';
      case CompilerErrorCode.disconnectedNode:
        return 'Nodo desconectado';
      case CompilerErrorCode.invalidConnection:
        return 'Conexión inválida';
      case CompilerErrorCode.infiniteLoop:
        return 'Posible bucle infinito';
      case CompilerErrorCode.unreachableNode:
        return 'Nodo inalcanzable';
      case CompilerErrorCode.invalidDecisionBranch:
        return 'Rama de decisión inválida';
      case CompilerErrorCode.missingReturnPath:
        return 'Falta ruta de retorno';
      case CompilerErrorCode.cyclicDependency:
        return 'Dependencia cíclica';
      case CompilerErrorCode.unsupportedConstruct:
        return 'Construcción no soportada';
      case CompilerErrorCode.codeGenerationFailed:
        return 'Generación de código fallida';
      case CompilerErrorCode.templateError:
        return 'Error en plantilla';
      case CompilerErrorCode.unknown:
        return 'Error desconocido';
    }
  }
}

/// Represents a location in the source (node text)
class SourceLocation {
  final int line;
  final int column;
  final int offset;
  final String? nodeId;
  final String? nodeName;

  const SourceLocation({
    this.line = 1,
    this.column = 1,
    this.offset = 0,
    this.nodeId,
    this.nodeName,
  });

  @override
  String toString() {
    if (nodeId != null) {
      return 'nodo "${nodeName ?? nodeId}", línea $line, columna $column';
    }
    return 'línea $line, columna $column';
  }

  String toShortString() => '($line:$column)';
}

/// Base class for all compiler errors
class CompilerError {
  /// The error code
  final CompilerErrorCode code;

  /// The severity of the error
  final CompilerSeverity severity;

  /// The phase where the error occurred
  final CompilerPhase phase;

  /// Human-readable error message
  final String message;

  /// The location where the error occurred
  final SourceLocation? location;

  /// The problematic text/token
  final String? problematicText;

  /// Suggestion for how to fix the error
  final String? suggestion;

  /// Additional context information
  final Map<String, dynamic>? context;

  const CompilerError({
    required this.code,
    required this.severity,
    required this.phase,
    required this.message,
    this.location,
    this.problematicText,
    this.suggestion,
    this.context,
  });

  /// Creates a lexical error
  factory CompilerError.lexical({
    required CompilerErrorCode code,
    required String message,
    SourceLocation? location,
    String? problematicText,
    String? suggestion,
    CompilerSeverity severity = CompilerSeverity.error,
  }) {
    return CompilerError(
      code: code,
      severity: severity,
      phase: CompilerPhase.lexical,
      message: message,
      location: location,
      problematicText: problematicText,
      suggestion: suggestion,
    );
  }

  /// Creates a syntactic error
  factory CompilerError.syntactic({
    required CompilerErrorCode code,
    required String message,
    SourceLocation? location,
    String? problematicText,
    String? suggestion,
    CompilerSeverity severity = CompilerSeverity.error,
  }) {
    return CompilerError(
      code: code,
      severity: severity,
      phase: CompilerPhase.syntactic,
      message: message,
      location: location,
      problematicText: problematicText,
      suggestion: suggestion,
    );
  }

  /// Creates a semantic error
  factory CompilerError.semantic({
    required CompilerErrorCode code,
    required String message,
    SourceLocation? location,
    String? problematicText,
    String? suggestion,
    CompilerSeverity severity = CompilerSeverity.error,
  }) {
    return CompilerError(
      code: code,
      severity: severity,
      phase: CompilerPhase.semantic,
      message: message,
      location: location,
      problematicText: problematicText,
      suggestion: suggestion,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('[${severity.prefix}] ');
    buffer.write('[${code.numericCode}] ');
    buffer.write('${phase.displayName}: ');
    buffer.write(message);

    if (location != null) {
      buffer.write(' en $location');
    }

    if (problematicText != null) {
      buffer.write(' (texto: "$problematicText")');
    }

    return buffer.toString();
  }

  /// Returns a detailed multi-line representation
  String toDetailedString() {
    final buffer = StringBuffer();

    buffer
        .writeln('${severity.emoji} ${severity.prefix} [${code.numericCode}]');
    buffer.writeln('Fase: ${phase.displayName}');
    buffer.writeln('Mensaje: $message');

    if (location != null) {
      buffer.writeln('Ubicación: $location');
    }

    if (problematicText != null) {
      buffer.writeln('Texto problemático: "$problematicText"');
    }

    if (suggestion != null) {
      buffer.writeln('Sugerencia: $suggestion');
    }

    return buffer.toString();
  }

  /// Convert to JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'code': code.numericCode,
      'codeName': code.name,
      'severity': severity.name,
      'phase': phase.name,
      'message': message,
      'location': location != null
          ? {
              'line': location!.line,
              'column': location!.column,
              'nodeId': location!.nodeId,
            }
          : null,
      'problematicText': problematicText,
      'suggestion': suggestion,
    };
  }
}

/// Lexical-specific error
class LexicalError extends CompilerError {
  LexicalError({
    required CompilerErrorCode code,
    required String message,
    SourceLocation? location,
    String? problematicText,
    String? suggestion,
    CompilerSeverity severity = CompilerSeverity.error,
  }) : super(
          code: code,
          severity: severity,
          phase: CompilerPhase.lexical,
          message: message,
          location: location,
          problematicText: problematicText,
          suggestion: suggestion,
        );

  /// Unexpected character error
  factory LexicalError.unexpectedCharacter(
      String char, SourceLocation location) {
    return LexicalError(
      code: CompilerErrorCode.unexpectedCharacter,
      message: 'Carácter inesperado: "$char"',
      location: location,
      problematicText: char,
      suggestion: 'Verifica que el carácter sea válido en este contexto',
    );
  }

  /// Unterminated string error
  factory LexicalError.unterminatedString(SourceLocation location) {
    return LexicalError(
      code: CompilerErrorCode.unterminatedString,
      message: 'Cadena de texto no terminada',
      location: location,
      suggestion: 'Añade las comillas de cierre al final de la cadena',
    );
  }

  /// Invalid number error
  factory LexicalError.invalidNumber(String text, SourceLocation location) {
    return LexicalError(
      code: CompilerErrorCode.invalidNumber,
      message: 'Número inválido: "$text"',
      location: location,
      problematicText: text,
      suggestion: 'Verifica el formato del número',
    );
  }

  /// Invalid identifier error
  factory LexicalError.invalidIdentifier(String text, SourceLocation location) {
    return LexicalError(
      code: CompilerErrorCode.invalidIdentifier,
      message: 'Identificador inválido: "$text"',
      location: location,
      problematicText: text,
      suggestion:
          'Los identificadores deben comenzar con una letra o guión bajo',
    );
  }
}

/// Syntax-specific error for Phase 2
class SyntaxError extends CompilerError {
  SyntaxError({
    required CompilerErrorCode code,
    required String message,
    SourceLocation? location,
    String? problematicText,
    String? suggestion,
    CompilerSeverity severity = CompilerSeverity.error,
  }) : super(
          code: code,
          severity: severity,
          phase: CompilerPhase.syntactic,
          message: message,
          location: location,
          problematicText: problematicText,
          suggestion: suggestion,
        );

  /// Unexpected token error
  factory SyntaxError.unexpectedToken(String token, SourceLocation location,
      {String? expected}) {
    return SyntaxError(
      code: CompilerErrorCode.unexpectedToken,
      message:
          'Token inesperado: "$token"${expected != null ? ", se esperaba $expected" : ""}',
      location: location,
      problematicText: token,
      suggestion: expected != null
          ? 'Reemplaza "$token" con $expected'
          : 'Verifica la sintaxis en esta posición',
    );
  }

  /// Missing token error
  factory SyntaxError.missingToken(String expected, SourceLocation location) {
    return SyntaxError(
      code: CompilerErrorCode.missingToken,
      message: 'Se esperaba: $expected',
      location: location,
      suggestion: 'Añade $expected en esta posición',
    );
  }

  /// Unbalanced parentheses error
  factory SyntaxError.unbalancedParentheses(SourceLocation location,
      {bool missing = true}) {
    return SyntaxError(
      code: CompilerErrorCode.unbalancedParentheses,
      message: missing
          ? 'Falta paréntesis de cierre ")"'
          : 'Paréntesis de cierre ")" sin paréntesis de apertura',
      location: location,
      suggestion: missing
          ? 'Añade ")" para cerrar el paréntesis'
          : 'Elimina ")" o añade "(" correspondiente',
    );
  }

  /// Unbalanced brackets error
  factory SyntaxError.unbalancedBrackets(SourceLocation location,
      {bool missing = true}) {
    return SyntaxError(
      code: CompilerErrorCode.unbalancedBrackets,
      message: missing
          ? 'Falta corchete de cierre "]"'
          : 'Corchete de cierre "]" sin corchete de apertura',
      location: location,
      suggestion: missing
          ? 'Añade "]" para cerrar el corchete'
          : 'Elimina "]" o añade "[" correspondiente',
    );
  }

  /// Unbalanced braces error
  factory SyntaxError.unbalancedBraces(SourceLocation location,
      {bool missing = true}) {
    return SyntaxError(
      code: CompilerErrorCode.unbalancedBraces,
      message: missing
          ? 'Falta llave de cierre "}"'
          : 'Llave de cierre "}" sin llave de apertura',
      location: location,
      suggestion: missing
          ? 'Añade "}" para cerrar la llave'
          : 'Elimina "}" o añade "{" correspondiente',
    );
  }

  /// Invalid expression error
  factory SyntaxError.invalidExpression(SourceLocation location,
      {String? details}) {
    return SyntaxError(
      code: CompilerErrorCode.invalidExpression,
      message: 'Expresión inválida${details != null ? ": $details" : ""}',
      location: location,
      suggestion: 'Verifica la sintaxis de la expresión',
    );
  }

  /// Invalid assignment error
  factory SyntaxError.invalidAssignment(SourceLocation location,
      {String? details}) {
    return SyntaxError(
      code: CompilerErrorCode.invalidAssignment,
      message: 'Asignación inválida${details != null ? ": $details" : ""}',
      location: location,
      suggestion:
          'El lado izquierdo de una asignación debe ser una variable o elemento de arreglo',
    );
  }

  /// Invalid declaration error
  factory SyntaxError.invalidDeclaration(SourceLocation location,
      {String? details}) {
    return SyntaxError(
      code: CompilerErrorCode.invalidDeclaration,
      message: 'Declaración inválida${details != null ? ": $details" : ""}',
      location: location,
      suggestion: 'Verifica el formato: tipo nombre [= valor];',
    );
  }

  /// Invalid statement error
  factory SyntaxError.invalidStatement(SourceLocation location,
      {String? details}) {
    return SyntaxError(
      code: CompilerErrorCode.invalidStatement,
      message: 'Sentencia inválida${details != null ? ": $details" : ""}',
      location: location,
      suggestion: 'Verifica la sintaxis de la sentencia',
    );
  }

  /// Missing semicolon error
  factory SyntaxError.missingSemicolon(SourceLocation location) {
    return SyntaxError(
      code: CompilerErrorCode.missingSemicolon,
      message: 'Falta punto y coma ";"',
      location: location,
      suggestion: 'Añade ";" al final de la sentencia',
    );
  }
}

/// Collection of compiler errors with utilities
class CompilerErrorCollection {
  final List<CompilerError> _errors = [];

  /// Add an error to the collection
  void add(CompilerError error) {
    _errors.add(error);
  }

  /// Add multiple errors
  void addAll(Iterable<CompilerError> errors) {
    _errors.addAll(errors);
  }

  /// Get all errors
  List<CompilerError> get all => List.unmodifiable(_errors);

  /// Get errors by severity
  List<CompilerError> getBySeverity(CompilerSeverity severity) {
    return _errors.where((e) => e.severity == severity).toList();
  }

  /// Get errors by phase
  List<CompilerError> getByPhase(CompilerPhase phase) {
    return _errors.where((e) => e.phase == phase).toList();
  }

  /// Check if there are any errors (not just warnings)
  bool get hasErrors => _errors.any((e) =>
      e.severity == CompilerSeverity.error ||
      e.severity == CompilerSeverity.fatal);

  /// Check if there are any fatal errors
  bool get hasFatalErrors =>
      _errors.any((e) => e.severity == CompilerSeverity.fatal);

  /// Get the count of errors
  int get errorCount => _errors
      .where((e) =>
          e.severity == CompilerSeverity.error ||
          e.severity == CompilerSeverity.fatal)
      .length;

  /// Get the count of warnings
  int get warningCount =>
      _errors.where((e) => e.severity == CompilerSeverity.warning).length;

  /// Check if collection is empty
  bool get isEmpty => _errors.isEmpty;

  /// Check if collection is not empty
  bool get isNotEmpty => _errors.isNotEmpty;

  /// Clear all errors
  void clear() {
    _errors.clear();
  }

  /// Get a summary string
  String get summary {
    final errors = errorCount;
    final warnings = warningCount;

    if (errors == 0 && warnings == 0) {
      return '✅ Sin errores ni advertencias';
    }

    final parts = <String>[];
    if (errors > 0) {
      parts.add('$errors error${errors > 1 ? 'es' : ''}');
    }
    if (warnings > 0) {
      parts.add('$warnings advertencia${warnings > 1 ? 's' : ''}');
    }

    return parts.join(', ');
  }

  @override
  String toString() {
    if (_errors.isEmpty) return 'No errors';
    return _errors.map((e) => e.toString()).join('\n');
  }
}
