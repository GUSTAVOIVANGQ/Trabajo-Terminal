/// Advanced Code Generator for FlowCode Diagram Compiler
/// Phase 5: Generates optimized C code from the AST and Symbol Table
///
/// This generator uses the full compilation pipeline's semantic information
/// to produce type-correct and optimized C code.

import '../models/diagram_node.dart';
import 'symbol_table.dart';
import 'ast_nodes.dart';
import 'compiler_errors.dart';

/// Options for code generation
class CodeGenOptions {
  /// Whether to include comments in the generated code
  final bool includeComments;

  /// Whether to include header timestamp
  final bool includeTimestamp;

  /// Indentation string (default: 4 spaces)
  final String indentation;

  /// Target C standard (c99, c11, c17)
  final String targetCStandard;

  /// Whether to generate debug printf statements
  final bool debugMode;

  const CodeGenOptions({
    this.includeComments = true,
    this.includeTimestamp = true,
    this.indentation = '    ',
    this.targetCStandard = 'c99',
    this.debugMode = false,
  });

  static const CodeGenOptions defaults = CodeGenOptions();
}

/// Result of code generation
class CodeGenerationResult {
  /// Whether code generation was successful
  final bool success;

  /// The generated C code
  final String code;

  /// Any errors during generation
  final List<CompilerError> errors;

  /// Code generation metrics
  final CodeGenMetrics metrics;

  const CodeGenerationResult({
    required this.success,
    required this.code,
    this.errors = const [],
    required this.metrics,
  });
}

/// Metrics for code generation
class CodeGenMetrics {
  final int linesOfCode;
  final int functionsGenerated;
  final int variablesUsed;
  final int generationTimeMs;

  const CodeGenMetrics({
    this.linesOfCode = 0,
    this.functionsGenerated = 0,
    this.variablesUsed = 0,
    this.generationTimeMs = 0,
  });
}

/// Advanced code generator that uses the symbol table for type information
class AdvancedCodeGenerator {
  final CodeGenOptions options;
  final List<CompilerError> _errors = [];

  AdvancedCodeGenerator({this.options = CodeGenOptions.defaults});

  /// Generate C code from diagram nodes using semantic information
  CodeGenerationResult generate({
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required SymbolTable symbolTable,
    ProgramNode? ast,
  }) {
    final stopwatch = Stopwatch()..start();
    _errors.clear();

    final buffer = StringBuffer();

    // Generate header
    _generateHeader(buffer);

    // Generate includes
    _generateIncludes(buffer);

    // Generate main function
    buffer.writeln('int main() {');

    // Sort nodes by execution order (start from terminal start)
    final orderedNodes = _getNodesInExecutionOrder(nodes, connections);

    // Generate code for each node
    for (final node in orderedNodes) {
      _generateNodeCode(node, nodes, connections, symbolTable, buffer);
    }

    // Generate return statement
    buffer.writeln('');
    buffer.writeln('${options.indentation}return 0;');
    buffer.writeln('}');

    stopwatch.stop();

    final code = buffer.toString();

    return CodeGenerationResult(
      success: _errors.isEmpty,
      code: code,
      errors: List.from(_errors),
      metrics: CodeGenMetrics(
        linesOfCode: code.split('\n').length,
        functionsGenerated: 1,
        variablesUsed: symbolTable.symbolCount,
        generationTimeMs: stopwatch.elapsedMilliseconds,
      ),
    );
  }

  /// Generate the header comment
  void _generateHeader(StringBuffer buffer) {
    buffer.writeln(
        '// Código C generado automáticamente a partir del diagrama de flujo');
    if (options.includeTimestamp) {
      buffer.writeln('// Generado el ${DateTime.now()}');
    }
    buffer.writeln(
        '// Compilador FlowCode - Generador Avanzado (FASE 5: Integración)');
    buffer.writeln('');
  }

  /// Generate #include statements
  void _generateIncludes(StringBuffer buffer) {
    buffer.writeln('#include <stdio.h>');
    buffer.writeln('#include <stdlib.h>');
    buffer.writeln('#include <stdbool.h>');
    buffer.writeln('');
  }

  /// Get nodes in execution order starting from the start terminal
  List<DiagramNode> _getNodesInExecutionOrder(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    // Find start node
    final startNode = nodes.firstWhere(
      (n) =>
          n.type == NodeType.terminal &&
          (n.text.toLowerCase().contains('inicio') ||
              n.text.toLowerCase().contains('start')),
      orElse: () => nodes.first,
    );

    final ordered = <DiagramNode>[];
    final visited = <String>{};

    void visit(DiagramNode node) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);

      // Skip terminal end nodes for now, we'll add them at the end
      if (node.type == NodeType.terminal &&
          (node.text.toLowerCase().contains('fin') ||
              node.text.toLowerCase().contains('end'))) {
        return;
      }

      ordered.add(node);

      // Find next nodes - IGNORE loop back connections to prevent infinite recursion
      final outgoing = connections
          .where((c) => c.source.id == node.id && !c.isLoopBack)
          .toList();

      // For non-decision nodes, follow the single path
      if (node.type != NodeType.decision && node.type != NodeType.preparation) {
        for (final conn in outgoing) {
          visit(conn.target);
        }
      } else if (node.type == NodeType.preparation) {
        // For loop nodes (preparation), process body first then exit
        final bodyBranch = outgoing.where((c) =>
            c.label.toLowerCase() == 'verdadero' ||
            c.label.toLowerCase() == 'true' ||
            c.label.isEmpty);
        final exitBranch = outgoing.where((c) =>
            c.label.toLowerCase() == 'falso' ||
            c.label.toLowerCase() == 'false');

        for (final conn in bodyBranch) {
          visit(conn.target);
        }
        for (final conn in exitBranch) {
          visit(conn.target);
        }
      } else {
        // For decision nodes, first process the 'yes' branch, then 'no'
        final yesBranch = outgoing.where((c) =>
            c.label.toLowerCase() == 'sí' ||
            c.label.toLowerCase() == 'si' ||
            c.label.toLowerCase() == 'yes' ||
            c.label.toLowerCase() == 'true');
        final noBranch = outgoing.where((c) =>
            c.label.toLowerCase() == 'no' || c.label.toLowerCase() == 'false');

        for (final conn in yesBranch) {
          visit(conn.target);
        }
        for (final conn in noBranch) {
          visit(conn.target);
        }
      }
    }

    visit(startNode);
    return ordered;
  }

  /// Generate C code for a single node
  void _generateNodeCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
  ) {
    final indent = options.indentation;

    switch (node.type) {
      case NodeType.terminal:
        _generateTerminalCode(node, buffer, indent);
        break;
      case NodeType.process:
        // Detectar si es el inicio de un do-while
        if (_isDoWhileBodyNode(node)) {
          _generateDoWhileFromBody(
              node, allNodes, connections, symbolTable, buffer, indent);
        } else {
          _generateProcessCode(node, symbolTable, buffer, indent);
        }
        break;
      case NodeType.data:
        _generateDataCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.decision:
        // Detectar si es la condición de un do-while (ya procesada)
        if (_isDoWhileConditionNode(node)) {
          // La condición ya fue procesada desde el nodo body, omitir
          break;
        }
        _generateDecisionCode(
            node, allNodes, connections, symbolTable, buffer, indent);
        break;
      case NodeType.preparation:
        _generateLoopCode(
            node, allNodes, connections, symbolTable, buffer, indent);
        break;
      case NodeType.predefinedProcess:
        _generateSubprocessCode(node, buffer, indent);
        break;
      case NodeType.comment:
        _generateCommentCode(node, buffer, indent);
        break;
      case NodeType.connector:
      case NodeType.offPageConnector:
        // Connectors don't generate code
        break;
      // ISO 5807 Data Symbols - not used for basic code generation
      case NodeType.storedData:
      case NodeType.internalStorage:
      case NodeType.sequentialStorage:
      case NodeType.directStorage:
      case NodeType.document:
      case NodeType.manualInput:
      case NodeType.card:
      case NodeType.punchedTape:
      case NodeType.display:
      // ISO 5807 Process Symbols - not used for basic code generation
      case NodeType.manualOperation:
      case NodeType.parallelMode:
      case NodeType.loopLimit:
      case NodeType.collate:
      case NodeType.summingJunction:
      // ISO 5807 Special Symbols
      case NodeType.annotation:
        // These node types are not supported for code generation yet
        if (options.includeComments) {
          buffer.writeln('$indent// [Nodo no soportado: ${node.type.name}]');
        }
        break;
    }
  }

  /// Generate code for terminal nodes (start/end)
  void _generateTerminalCode(
      DiagramNode node, StringBuffer buffer, String indent) {
    if (options.includeComments) {
      final isStart = node.text.toLowerCase().contains('inicio') ||
          node.text.toLowerCase().contains('start');
      if (isStart) {
        buffer.writeln('$indent// Inicio del programa');
      } else {
        buffer.writeln('$indent// Fin del programa');
      }
    }
  }

  /// Generate code for process nodes - SUPPORTS MULTIPLE VARIABLE DECLARATIONS
  void _generateProcessCode(
    DiagramNode node,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final text = node.text.trim();
    if (text.isEmpty) return;

    if (options.includeComments) {
      buffer.writeln('$indent// Proceso: $text');
    }

    // Check if it's a multiple variable declaration (e.g., "int a, b, c" or "float x = 0.0, y = 1.5, z")
    final multiDeclMatch =
        RegExp(r'^(int|float|double|char|bool)\s+(.+)$').firstMatch(text);
    if (multiDeclMatch != null) {
      final type = multiDeclMatch.group(1)!;
      final varsSection = multiDeclMatch.group(2)!.trim();

      // Check if it contains a comma (multiple variables)
      if (varsSection.contains(',')) {
        // It's a multiple declaration - output as-is with proper formatting
        final cleanVars = varsSection.endsWith(';')
            ? varsSection.substring(0, varsSection.length - 1)
            : varsSection;
        buffer.writeln('$indent$type $cleanVars;');
        return;
      }

      // Single variable with possible initialization
      final singleWithInit =
          RegExp(r'^(\w+)\s*=\s*(.+)$').firstMatch(varsSection);
      if (singleWithInit != null) {
        final varName = singleWithInit.group(1)!;
        final value = singleWithInit.group(2)!.replaceAll(';', '').trim();
        buffer.writeln('$indent$type $varName = $value;');
        return;
      }

      // Simple single variable declaration
      final cleanVar = varsSection.replaceAll(';', '').trim();
      if (RegExp(r'^\w+$').hasMatch(cleanVar)) {
        buffer.writeln('$indent$type $cleanVar;');
        return;
      }
    }

    // Check for assignment
    final assignmentMatch = RegExp(r'^(\w+)\s*=\s*(.+)$').firstMatch(text);
    if (assignmentMatch != null) {
      final varName = assignmentMatch.group(1)!;
      final expression = assignmentMatch.group(2)!;
      buffer.writeln('$indent$varName = $expression;');
      return;
    }

    // Check for increment/decrement
    if (text.endsWith('++') || text.endsWith('--')) {
      buffer.writeln('$indent$text;');
      return;
    }

    // Default: treat as expression statement
    if (!text.endsWith(';')) {
      buffer.writeln('$indent$text;');
    } else {
      buffer.writeln('$indent$text');
    }
  }

  /// Generate code for data (I/O) nodes - IMPROVED for multiple variables
  void _generateDataCode(
    DiagramNode node,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final text = node.text.trim();
    final lowerText = text.toLowerCase();

    if (options.includeComments) {
      buffer.writeln('$indent// Dato: $text');
    }

    // Determine if it's input or output
    final isOutput = lowerText.startsWith('escribir') ||
        lowerText.startsWith('mostrar') ||
        lowerText.startsWith('imprimir') ||
        lowerText.startsWith('print') ||
        lowerText.contains('salida') ||
        (node.metadata['isOutput'] == true);

    if (isOutput) {
      _generateOutputCode(node, text, symbolTable, buffer, indent);
    } else {
      _generateInputCode(node, text, symbolTable, buffer, indent);
    }
  }

  /// Generate printf statement for output - HANDLES MULTIPLE VARIABLES
  void _generateOutputCode(
    DiagramNode node,
    String text,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Extract content to output (remove keywords)
    String content = text;
    for (final keyword in [
      'escribir',
      'mostrar',
      'imprimir',
      'print',
      'salida'
    ]) {
      if (content.toLowerCase().startsWith(keyword)) {
        content = content.substring(keyword.length).trim();
        break;
      }
    }

    // Check for string literal
    final stringMatch = RegExp(r'^"([^"]*)"(.*)$').firstMatch(content);
    if (stringMatch != null) {
      final stringContent = stringMatch.group(1)!;
      final afterString = stringMatch.group(2)!.trim();

      if (afterString.isNotEmpty) {
        // There are variables after the string
        final vars = _extractVariables(afterString);
        if (vars.isNotEmpty) {
          final formatParts = <String>[];
          final varList = <String>[];

          for (final varName in vars) {
            final formatSpec =
                _getFormatSpecifierForVariable(varName, symbolTable);
            formatParts.add(formatSpec);
            varList.add(varName);
          }

          buffer.writeln(
              '$indent printf("$stringContent ${formatParts.join(' ')}\\n", ${varList.join(', ')});');
          return;
        }
      }

      // Just a string literal
      buffer.writeln('${indent}printf("$stringContent\\n");');
      return;
    }

    // Check for multiple variables separated by comma
    if (content.contains(',')) {
      final vars = _extractVariables(content);
      if (vars.isNotEmpty) {
        final formatParts = <String>[];
        final varList = <String>[];

        for (final varName in vars) {
          final formatSpec =
              _getFormatSpecifierForVariable(varName, symbolTable);
          formatParts.add(formatSpec);
          varList.add(varName);
        }

        buffer.writeln(
            '${indent}printf("${formatParts.join(' ')}\\n", ${varList.join(', ')});');
        return;
      }
    }

    // Single variable
    if (_isValidIdentifier(content)) {
      final formatSpec = _getFormatSpecifierForVariable(content, symbolTable);
      buffer.writeln('${indent}printf("$formatSpec\\n", $content);');
      return;
    }

    // Default: treat as literal text
    buffer.writeln('${indent}printf("$content\\n");');
  }

  /// Generate scanf statement for input
  void _generateInputCode(
    DiagramNode node,
    String text,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Extract variable name
    String content = text;
    for (final keyword in ['leer', 'entrada', 'input', 'read', 'scanf']) {
      if (content.toLowerCase().startsWith(keyword)) {
        content = content.substring(keyword.length).trim();
        break;
      }
    }

    // Handle multiple variables
    if (content.contains(',')) {
      final vars = _extractVariables(content);
      for (final varName in vars) {
        final formatSpec = _getFormatSpecifierForVariable(varName, symbolTable);
        final needsAmpersand = formatSpec != '%s'; // Strings don't need &
        final ampersand = needsAmpersand ? '&' : '';
        buffer.writeln('${indent}printf("Ingrese $varName: ");');
        buffer.writeln('${indent}scanf("$formatSpec", $ampersand$varName);');
      }
      return;
    }

    // Single variable
    final varName = content.trim();
    if (_isValidIdentifier(varName)) {
      final formatSpec = _getFormatSpecifierForVariable(varName, symbolTable);
      final needsAmpersand = formatSpec != '%s';
      final ampersand = needsAmpersand ? '&' : '';
      buffer.writeln('${indent}printf("Ingrese $varName: ");');
      buffer.writeln('${indent}scanf("$formatSpec", $ampersand$varName);');
    }
  }

  /// Get the format specifier for a variable using the symbol table
  String _getFormatSpecifierForVariable(
      String varName, SymbolTable symbolTable) {
    // First, try to look up in symbol table
    final symbol = symbolTable.lookup(varName);
    if (symbol != null) {
      return symbol.dataType.formatSpecifier;
    }

    // Fallback: infer from variable name conventions
    final lowerName = varName.toLowerCase();

    // Char detection
    if (lowerName == 'c' ||
        lowerName == 'z' ||
        lowerName.startsWith('ch') ||
        lowerName.contains('char') ||
        lowerName == 'letra' ||
        lowerName == 'caracter') {
      return '%c';
    }

    // Float detection
    if (lowerName == 'y' ||
        lowerName == 'f' ||
        lowerName.contains('float') ||
        lowerName.contains('decimal') ||
        lowerName.contains('real') ||
        lowerName == 'pi' ||
        lowerName.contains('promedio') ||
        lowerName.contains('average') ||
        lowerName.contains('celsius') ||
        lowerName.contains('fahrenheit') ||
        lowerName.contains('temp')) {
      return '%f';
    }

    // Double detection
    if (lowerName == 'd' || lowerName.contains('double')) {
      return '%lf';
    }

    // String detection
    if (lowerName.contains('str') ||
        lowerName.contains('nombre') ||
        lowerName.contains('texto') ||
        lowerName.contains('cadena') ||
        lowerName.contains('name')) {
      return '%s';
    }

    // Default: int
    return '%d';
  }

  /// Extract variable names from text
  List<String> _extractVariables(String text) {
    return text
        .split(RegExp(r'[,\s]+'))
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty && _isValidIdentifier(v))
        .toList();
  }

  /// Check if text is a valid C identifier
  bool _isValidIdentifier(String text) {
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(text.trim());
  }

  /// Generate code for decision nodes
  void _generateDecisionCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Normalizar la condición (quitar signos de interrogación y formatear)
    final condition = _formatCondition(node.text);

    if (options.includeComments) {
      buffer.writeln('$indent// Decisión: $condition');
    }

    // Check for switch statement
    if (node.metadata['structureType'] == 'switch' ||
        condition.toLowerCase().startsWith('switch')) {
      _generateSwitchCode(
          node, allNodes, connections, symbolTable, buffer, indent);
      return;
    }

    // Generate if statement
    buffer.writeln('${indent}if ($condition) {');

    // Find and generate 'yes' branch
    final yesBranch = connections.where((c) =>
        c.source.id == node.id &&
        (c.label.toLowerCase() == 'sí' ||
            c.label.toLowerCase() == 'si' ||
            c.label.toLowerCase() == 'yes' ||
            c.label.toLowerCase() == 'true'));

    for (final conn in yesBranch) {
      _generateBranchCode(conn.target, allNodes, connections, symbolTable,
          buffer, indent + options.indentation);
    }

    buffer.writeln('$indent}');

    // Find and generate 'no' branch
    final noBranch = connections.where((c) =>
        c.source.id == node.id &&
        (c.label.toLowerCase() == 'no' || c.label.toLowerCase() == 'false'));

    if (noBranch.isNotEmpty) {
      buffer.writeln('${indent}else {');
      for (final conn in noBranch) {
        _generateBranchCode(conn.target, allNodes, connections, symbolTable,
            buffer, indent + options.indentation);
      }
      buffer.writeln('$indent}');
    }
  }

  /// Generate code for a branch (helper for decision nodes)
  void _generateBranchCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Skip if it's a terminal end node
    if (node.type == NodeType.terminal &&
        (node.text.toLowerCase().contains('fin') ||
            node.text.toLowerCase().contains('end'))) {
      return;
    }

    // Generate code for this node
    _generateNodeCode(node, allNodes, connections, symbolTable, buffer);
  }

  /// Generate code for switch statements
  void _generateSwitchCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Extract switch variable
    final switchMatch =
        RegExp(r'switch\s*\(\s*(\w+)\s*\)').firstMatch(node.text);
    final switchVar = switchMatch?.group(1) ?? node.text;

    buffer.writeln('${indent}switch ($switchVar) {');

    // Find case nodes
    final caseConnections = connections.where((c) => c.source.id == node.id);

    for (final conn in caseConnections) {
      final caseNode = conn.target;
      final caseValue = conn.label.isNotEmpty
          ? conn.label
          : (caseNode.metadata['caseValue']?.toString() ?? 'default');

      if (caseValue.toLowerCase() == 'default') {
        buffer.writeln('$indent${options.indentation}default:');
      } else {
        buffer.writeln('$indent${options.indentation}case $caseValue:');
      }

      // Generate case body
      _generateBranchCode(caseNode, allNodes, connections, symbolTable, buffer,
          indent + options.indentation + options.indentation);

      buffer
          .writeln('$indent${options.indentation}${options.indentation}break;');
    }

    buffer.writeln('$indent}');
  }

  /// Generate code for loop nodes - HANDLES isLoopBack to prevent infinite recursion
  void _generateLoopCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final loopText = node.text.trim();

    if (options.includeComments) {
      buffer.writeln('$indent// Bucle: $loopText');
    }

    // Detect loop type from metadata or text
    final loopType = node.metadata['loopType']?.toString() ?? 'while';

    if (loopType == 'for' || loopText.toLowerCase().startsWith('for')) {
      // For loop
      if (loopText.toLowerCase().startsWith('for')) {
        buffer.writeln('$indent$loopText {');
      } else {
        buffer.writeln('${indent}for ($loopText) {');
      }
    } else if (loopType == 'do-while') {
      buffer.writeln('${indent}do {');
    } else {
      // While loop (default)
      if (loopText.toLowerCase().startsWith('while')) {
        buffer.writeln('$indent$loopText {');
      } else {
        buffer.writeln('${indent}while ($loopText) {');
      }
    }

    // Generate loop body - ONLY follow body connections, NOT isLoopBack
    // Body connections are typically labeled "Verdadero" or "true" or empty (first connection)
    final bodyConnections = connections.where((c) =>
        c.source.id == node.id &&
        !c.isLoopBack &&
        (c.label.isEmpty ||
            c.label.toLowerCase() == 'verdadero' ||
            c.label.toLowerCase() == 'true'));

    // Track visited nodes within the loop body to prevent cycles
    final visitedInBody = <String>{};

    for (final conn in bodyConnections) {
      _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
          buffer, indent + options.indentation, visitedInBody, node.id);
    }

    if (loopType == 'do-while') {
      buffer.writeln('$indent} while ($loopText);');
    } else {
      buffer.writeln('$indent}');
    }
  }

  /// Generate code for loop body - tracks visited nodes to prevent infinite recursion
  void _generateLoopBodyCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
    Set<String> visitedInBody,
    String loopNodeId,
  ) {
    // Skip if already visited in this loop body
    if (visitedInBody.contains(node.id)) return;
    visitedInBody.add(node.id);

    // Skip terminal end nodes
    if (node.type == NodeType.terminal &&
        (node.text.toLowerCase().contains('fin') ||
            node.text.toLowerCase().contains('end'))) {
      return;
    }

    // Skip if this is the loop node itself (loopback)
    if (node.id == loopNodeId) return;

    // Generate code for this node based on its type
    switch (node.type) {
      case NodeType.process:
        _generateProcessCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.data:
        _generateDataCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.decision:
        _generateDecisionCodeInLoop(node, allNodes, connections, symbolTable,
            buffer, indent, visitedInBody, loopNodeId);
        break;
      case NodeType.preparation:
        // Nested loop
        _generateLoopCode(
            node, allNodes, connections, symbolTable, buffer, indent);
        break;
      case NodeType.comment:
        _generateCommentCode(node, buffer, indent);
        break;
      default:
        break;
    }

    // Follow non-loopback connections within the body
    final nextConnections =
        connections.where((c) => c.source.id == node.id && !c.isLoopBack);

    for (final conn in nextConnections) {
      // Don't follow back to the original loop node
      if (conn.target.id != loopNodeId) {
        _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
            buffer, indent, visitedInBody, loopNodeId);
      }
    }
  }

  /// Generate decision code within a loop body context
  void _generateDecisionCodeInLoop(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
    Set<String> visitedInBody,
    String loopNodeId,
  ) {
    // Normalizar la condición (quitar signos de interrogación y formatear)
    final condition = _formatCondition(node.text);

    if (options.includeComments) {
      buffer.writeln('$indent// Decisión: $condition');
    }

    buffer.writeln('${indent}if ($condition) {');

    // Find and generate 'yes' branch
    final yesBranch = connections.where((c) =>
        c.source.id == node.id &&
        !c.isLoopBack &&
        (c.label.toLowerCase() == 'sí' ||
            c.label.toLowerCase() == 'si' ||
            c.label.toLowerCase() == 'yes' ||
            c.label.toLowerCase() == 'true'));

    for (final conn in yesBranch) {
      if (conn.target.id != loopNodeId) {
        _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
            buffer, indent + options.indentation, visitedInBody, loopNodeId);
      }
    }

    buffer.writeln('$indent}');

    // Find and generate 'no' branch (if not a loopback)
    final noBranch = connections.where((c) =>
        c.source.id == node.id &&
        !c.isLoopBack &&
        (c.label.toLowerCase() == 'no' || c.label.toLowerCase() == 'false'));

    if (noBranch.isNotEmpty) {
      buffer.writeln('${indent}else {');
      for (final conn in noBranch) {
        if (conn.target.id != loopNodeId) {
          _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
              buffer, indent + options.indentation, visitedInBody, loopNodeId);
        }
      }
      buffer.writeln('$indent}');
    }
  }

  /// Generate code for subprocess nodes
  void _generateSubprocessCode(
      DiagramNode node, StringBuffer buffer, String indent) {
    final funcName = node.text.trim();

    if (options.includeComments) {
      buffer.writeln('$indent// Subproceso: $funcName');
    }

    if (funcName.contains('(')) {
      buffer.writeln('$indent$funcName;');
    } else {
      buffer.writeln('$indent$funcName();');
    }
  }

  /// Generate code for comment nodes
  void _generateCommentCode(
      DiagramNode node, StringBuffer buffer, String indent) {
    if (options.includeComments) {
      final comment = node.text.trim();
      if (comment.startsWith('/*') && comment.endsWith('*/')) {
        buffer.writeln('$indent$comment');
      } else if (comment.startsWith('//')) {
        buffer.writeln('$indent$comment');
      } else {
        // Multi-line comment
        final lines = comment.split('\n');
        if (lines.length > 1) {
          buffer.writeln('$indent/*');
          for (final line in lines) {
            buffer.writeln('$indent * ${line.trim()}');
          }
          buffer.writeln('$indent */');
        } else {
          buffer.writeln('$indent// $comment');
        }
      }
    }
  }

  /// Generate code for preparation nodes (variable declarations)
  void _generatePreparationCode(
    DiagramNode node,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final text = node.text.trim();

    if (options.includeComments) {
      buffer.writeln('$indent// Preparación: $text');
    }

    // Preparation nodes typically contain variable declarations
    buffer.writeln('$indent$text;');
  }

  /// Verifica si un nodo proceso es el inicio de un bucle do-while
  bool _isDoWhileBodyNode(DiagramNode node) {
    return node.metadata['structureType'] == 'loop' &&
        node.metadata['loopType'] == 'do-while' &&
        node.metadata['role'] == 'loop-body';
  }

  /// Verifica si un nodo decisión es la condición de un bucle do-while
  bool _isDoWhileConditionNode(DiagramNode node) {
    return node.metadata['structureType'] == 'loop' &&
        node.metadata['loopType'] == 'do-while' &&
        node.metadata['role'] == 'loop-condition';
  }

  /// Genera código do-while desde el nodo body
  void _generateDoWhileFromBody(
    DiagramNode bodyNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    if (options.includeComments) {
      buffer.writeln('$indent// Bucle do-while');
    }

    buffer.writeln('${indent}do {');

    // Generar código del cuerpo
    final bodyText = bodyNode.text.trim();
    if (bodyText.isNotEmpty && !bodyText.startsWith('//')) {
      _generateProcessCode(
          bodyNode, symbolTable, buffer, indent + options.indentation);
    } else {
      buffer.writeln('$indent${options.indentation}// Cuerpo del do-while');
    }

    // Encontrar el nodo de condición
    final bodyConnections = connections
        .where((c) => c.source.id == bodyNode.id && !c.isLoopBack)
        .toList();

    DiagramNode? conditionNode;
    for (final conn in bodyConnections) {
      if (_isDoWhileConditionNode(conn.target) ||
          conn.target.type == NodeType.decision) {
        conditionNode = conn.target;
        break;
      }
    }

    if (conditionNode != null) {
      // Extraer la condición
      String condition = conditionNode.metadata['condition']?.toString() ??
          _formatCondition(conditionNode.text);
      buffer.writeln('$indent} while ($condition);');
    } else {
      buffer.writeln('$indent} while (1); // TODO: Agregar condición');
    }
  }

  /// Formatea una condición para código C
  String _formatCondition(String text) {
    String condition = text.trim();

    // Remover signos de interrogación
    condition = condition.replaceAll('¿', '').replaceAll('?', '');

    // Formatear operadores
    condition = condition
        .replaceAll(' Y ', ' && ')
        .replaceAll(' y ', ' && ')
        .replaceAll(' AND ', ' && ')
        .replaceAll(' O ', ' || ')
        .replaceAll(' o ', ' || ')
        .replaceAll(' OR ', ' || ')
        .replaceAll(' = ', ' == ')
        .replaceAll('<>', '!=')
        .replaceAll('≤', '<=')
        .replaceAll('≥', '>=')
        .replaceAll('≠', '!=');

    return condition;
  }
}
