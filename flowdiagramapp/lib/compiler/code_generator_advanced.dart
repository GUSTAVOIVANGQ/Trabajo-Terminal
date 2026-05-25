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
  final Set<String> _emittedNodeIds = <String>{};
  // IDs de nodos que forman parte del cuerpo de un ciclo while/do-while
  // y que NO deben emitirse como nodos independientes en el flujo principal.
  final Set<String> _loopOwnedNodeIds = <String>{};
  // IDs de nodos detectados automáticamente como body de do-while por estructura del grafo
  final Set<String> _autoDetectedDoWhileBodyIds = <String>{};
  // Mapa de body-node-id → condition-node-id para do-while detectados por grafo
  final Map<String, String> _autoDetectedDoWhileConditionMap = <String, String>{};
  // Variable names that have array initializers (e.g., int arr[5] = {1,2,3})
  // and should NOT be declared in the symbol table header.
  final Set<String> _arrayInitVarNames = <String>{};

  AdvancedCodeGenerator({this.options = CodeGenOptions.defaults});

  /// Normalizes node text by collapsing visual newlines (from text wrapping
  /// in diagram nodes) into single spaces. This prevents broken C code when
  /// node text like "int a,\nb, c" is used directly in code generation.
  String _normalizeNodeText(String text) {
    return text
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Generate C code from diagram nodes using semantic information
  CodeGenerationResult generate({
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required SymbolTable symbolTable,
    ProgramNode? ast,
  }) {
    final stopwatch = Stopwatch()..start();
    _errors.clear();
    _emittedNodeIds.clear();
    _loopOwnedNodeIds.clear();
    _autoDetectedDoWhileBodyIds.clear();
    _autoDetectedDoWhileConditionMap.clear();
    _arrayInitVarNames.clear();

    // Pre-scan process nodes for array initializations (e.g., int arr[5] = {1,2,3}).
    // These must be declared inline with their initializer in C, so we exclude
    // them from the symbol table header declarations.
    _preCollectArrayInitVars(nodes);

    final buffer = StringBuffer();

    // Generate header
    _generateHeader(buffer);

    // Generate includes
    _generateIncludes(buffer);

    // Generate main function
    buffer.writeln('int main() {');

    // Generate variable declarations from symbol table
    // (excluding arrays that have brace-initializers — those are emitted inline)
    final declarations = symbolTable.generateCDeclarations(
        excludeVars: _arrayInitVarNames.isNotEmpty ? _arrayInitVarNames : null);
    if (declarations.isNotEmpty) {
      final indentedDecls = declarations
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => '${options.indentation}$line')
          .join('\n');
      buffer.writeln(indentedDecls);
      buffer.writeln('');
    }

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

    // Pre-calcular qué nodos son parte del cuerpo de un do-while
    // para no visitarlos como nodos independientes
    _precomputeLoopOwnedNodes(nodes, connections);

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
        // Decision node: check if it's a while-loop header
        final isWhile = _isWhileLoopDecision(node, connections);
        if (isWhile) {
          // For while-loop decision nodes, only follow the exit branch
          // in the ordering; the body will be generated inside the while
          final exitBranch = outgoing.where((c) {
            final label = c.label.toLowerCase();
            return label == 'no' || label == 'false' || label == 'falso';
          });
          // Still visit body nodes to ensure proper ordering
          final bodyBranch = outgoing.where((c) {
            final label = c.label.toLowerCase();
            return label == 'sí' || label == 'si' ||
                label == 'yes' || label == 'true' || label == 'verdadero';
          });
          for (final conn in bodyBranch) {
            visit(conn.target);
          }
          for (final conn in exitBranch) {
            visit(conn.target);
          }
        } else {
          // For regular decision nodes, first process the 'yes' branch, then 'no'
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
    }

    visit(startNode);
    return ordered;
  }

  /// Pre-computa qué nodos pertenecen al cuerpo de ciclos do-while
  /// para evitar emitirlos como nodos independientes.
  void _precomputeLoopOwnedNodes(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    _loopOwnedNodeIds.clear();
    _autoDetectedDoWhileBodyIds.clear();
    _autoDetectedDoWhileConditionMap.clear();

    // 1. Detectar do-while por metadata
    for (final node in nodes) {
      if (_isDoWhileBodyNodeByMetadata(node)) {
        _collectDoWhileBodyNodes(node, connections);
      }
    }

    // 2. Detectar do-while automáticamente por estructura del grafo
    //    Buscar conexiones con isLoopBack=true que apuntan a un nodo
    //    que NO es un decision node (eso sería while, no do-while)
    for (final conn in connections) {
      if (!conn.isLoopBack) continue;
      final loopbackTarget = conn.target;
      // Si el loopback va a un decision node → es while (ya manejado)
      if (loopbackTarget.type == NodeType.decision) continue;
      // Si ya fue detectado por metadata, skip
      if (_isDoWhileBodyNodeByMetadata(loopbackTarget)) continue;

      // Buscar el decision node al que se llega desde loopbackTarget
      final conditionNode = _findDecisionNodeInPath(
          loopbackTarget, connections, conn.source.id);
      if (conditionNode != null) {
        // Es un do-while: loopbackTarget es el body, conditionNode es la condición
        _autoDetectedDoWhileBodyIds.add(loopbackTarget.id);
        _autoDetectedDoWhileConditionMap[loopbackTarget.id] = conditionNode.id;
        // Marcar los nodos intermedios y el condition como owned
        _collectDoWhileBodyNodesAutoDetected(
            loopbackTarget, conditionNode, connections);
      }
    }
  }

  /// Busca el primer decision node alcanzable desde startNode, siguiendo
  /// conexiones no-loopback. sourceOfLoopback es el nodo desde donde
  /// sale la conexión loopback (para validar que es downstream del decision).
  DiagramNode? _findDecisionNodeInPath(
    DiagramNode startNode,
    List<Connection> connections,
    String sourceOfLoopbackId,
  ) {
    final queue = <DiagramNode>[startNode];
    final seen = <String>{};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (seen.contains(current.id)) continue;
      seen.add(current.id);

      final outgoing = connections
          .where((c) => c.source.id == current.id && !c.isLoopBack);
      for (final conn in outgoing) {
        if (conn.target.type == NodeType.decision) {
          // Verificar que el sourceOfLoopback es alcanzable desde alguna
          // rama de este decision (confirma que el loopback cierra el ciclo)
          if (_isReachableFrom(conn.target, sourceOfLoopbackId, connections)) {
            return conn.target;
          }
        }
        queue.add(conn.target);
      }
    }
    return null;
  }

  /// Verifica si targetId es alcanzable desde fromNode siguiendo
  /// conexiones no-loopback.
  bool _isReachableFrom(
    DiagramNode fromNode,
    String targetId,
    List<Connection> connections,
  ) {
    final queue = <String>[fromNode.id];
    final seen = <String>{};
    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      if (currentId == targetId) return true;
      if (seen.contains(currentId)) continue;
      seen.add(currentId);
      final outgoing = connections
          .where((c) => c.source.id == currentId && !c.isLoopBack);
      for (final conn in outgoing) {
        queue.add(conn.target.id);
      }
    }
    return false;
  }

  /// Recolecta los IDs de nodos que forman el cuerpo de un do-while (detectado por metadata)
  void _collectDoWhileBodyNodes(
    DiagramNode bodyStart,
    List<Connection> connections,
  ) {
    final visited = <String>{};
    void collect(DiagramNode node) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      if (_isDoWhileConditionNodeByMetadata(node)) {
        _loopOwnedNodeIds.add(node.id);
        return;
      }
      final outgoing = connections
          .where((c) => c.source.id == node.id && !c.isLoopBack);
      for (final conn in outgoing) {
        collect(conn.target);
      }
    }
    final outgoing = connections
        .where((c) => c.source.id == bodyStart.id && !c.isLoopBack);
    for (final conn in outgoing) {
      collect(conn.target);
    }
  }

  /// Recolecta los IDs de nodos entre bodyStart y conditionNode
  /// para do-while detectado automáticamente por grafo
  void _collectDoWhileBodyNodesAutoDetected(
    DiagramNode bodyStart,
    DiagramNode conditionNode,
    List<Connection> connections,
  ) {
    final visited = <String>{};
    void collect(DiagramNode node) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      if (node.id == conditionNode.id) {
        _loopOwnedNodeIds.add(node.id);
        return;
      }
      _loopOwnedNodeIds.add(node.id);
      final outgoing = connections
          .where((c) => c.source.id == node.id && !c.isLoopBack);
      for (final conn in outgoing) {
        collect(conn.target);
      }
    }
    // No marcar el bodyStart como owned (él dispara la generación)
    final outgoing = connections
        .where((c) => c.source.id == bodyStart.id && !c.isLoopBack);
    for (final conn in outgoing) {
      collect(conn.target);
    }
  }

  /// Pre-scan process nodes for array initializations.
  /// Detects patterns like `int arr[5] = {1, 2, 3}` and records the variable
  /// name so it can be excluded from the symbol table header.
  void _preCollectArrayInitVars(List<DiagramNode> nodes) {
    final arrayInitRegex = RegExp(
      r'^(int|float|double|char|bool)\s+([a-zA-Z_]\w*)\s*\[\s*\d+\s*\]\s*=\s*\{',
    );
    for (final node in nodes) {
      if (node.type == NodeType.process) {
        final text = _normalizeNodeText(node.text);
        final match = arrayInitRegex.firstMatch(text);
        if (match != null) {
          _arrayInitVarNames.add(match.group(2)!);
        }
      }
    }
  }

  /// Generate C code for a single node
  void _generateNodeCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer, {
    String? overrideIndent,
  }) {
    if (_emittedNodeIds.contains(node.id)) {
      return;
    }
    _emittedNodeIds.add(node.id);

    final indent = overrideIndent ?? options.indentation;

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
        // Detectar si es el inicio de un do-while (nodos data también pueden ser body)
        if (_isDoWhileBodyNode(node)) {
          _generateDoWhileFromBody(
              node, allNodes, connections, symbolTable, buffer, indent);
        } else {
          _generateDataCode(node, symbolTable, buffer, indent);
        }
        break;
      case NodeType.decision:
        // Detectar si es la condición de un do-while (ya procesada)
        if (_isDoWhileConditionNode(node)) {
          // La condición ya fue procesada desde el nodo body, omitir
          // Pero debemos seguir las conexiones de salida (rama "No"/exit)
          _skipToDoWhileExit(node, allNodes, connections, symbolTable, buffer);
          break;
        }
        // Detectar si es un ciclo while (decision con back-edge)
        if (_isWhileLoopDecision(node, connections)) {
          _generateWhileFromDecision(
              node, allNodes, connections, symbolTable, buffer, indent);
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
  /// AND MULTIPLE ASSIGNMENTS ON SEPARATE LINES
  void _generateProcessCode(
    DiagramNode node,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final text = _normalizeNodeText(node.text);
    if (text.isEmpty) return;

    // ── Multi-line assignment detection ──
    // When a process node contains multiple newline-separated assignments
    // (e.g. "temp = arr[j]\narr[j] = arr[j+1]\narr[j+1] = temp"),
    // _normalizeNodeText collapses them into one line, breaking the code.
    // Detect this pattern using the ORIGINAL text and emit each assignment
    // as a separate C statement.
    final rawLines = node.text
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (rawLines.length > 1) {
      // Check that the text is NOT a single type-declaration with commas
      // (e.g. "int a,\nb, c" should still be handled by the declaration path).
      final firstLineIsDecl = RegExp(
        r'^(int|float|double|char|bool)\s+',
      ).hasMatch(rawLines.first);

      if (!firstLineIsDecl) {
        // Verify each line looks like an assignment or an increment/decrement.
        final assignOrIncRegex = RegExp(
          r'^[a-zA-Z_][a-zA-Z0-9_]*(\[[^\]]*\])?\s*'  // lhs (var or arr[expr])
          r'(=|\+=|-=|\*=|/=|%=)\s*'                    // assignment operator
          r'.+$',                                        // rhs
        );
        final incDecRegex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*(\+\+|--)$');

        final allAreAssignments = rawLines.every(
          (line) => assignOrIncRegex.hasMatch(line) || incDecRegex.hasMatch(line),
        );

        if (allAreAssignments) {
          if (options.includeComments) {
            buffer.writeln('$indent// Proceso: $text');
          }
          for (final line in rawLines) {
            final normalized = line.trim();
            if (normalized.endsWith(';')) {
              buffer.writeln('$indent$normalized');
            } else {
              buffer.writeln('$indent$normalized;');
            }
          }
          return;
        }
      }
    }

    // Check if it's a variable declaration (e.g., "int a, b" or "float x = 0.0").
    // NOTE: comment emission is deferred to after this block so we can suppress
    // it when all variables are already declared in the symbol table.
    final multiDeclMatch =
        RegExp(r'^(int|float|double|char|bool)\s+(.+)$').firstMatch(text);
    if (multiDeclMatch != null) {
      final type = multiDeclMatch.group(1)!;
      var varsSection = multiDeclMatch.group(2)!.trim();
      if (varsSection.endsWith(';')) {
        varsSection = varsSection.substring(0, varsSection.length - 1).trim();
      }

      // Detect array initialization: type name[size] = {values}
      // In C, brace-initialization can ONLY happen at declaration time,
      // so we emit the full declaration here (the symbol table header skips it).
      final arrayInitMatch = RegExp(
        r'^([a-zA-Z_]\w*)\s*\[\s*(\d+)\s*\]\s*=\s*(\{.+\})$',
      ).firstMatch(varsSection);
      if (arrayInitMatch != null) {
        if (options.includeComments) {
          buffer.writeln('$indent// Proceso: $text');
        }
        buffer.writeln('$indent$text;');
        return;
      }

      final declarationParts = <String>[];
      final assignmentParts = <String>[];

      for (final rawPart in varsSection.split(',')) {
        final part = rawPart.trim();
        if (part.isEmpty) continue;

        // Detect array declaration: name[size]  →  already emitted by generateCDeclarations
        final arrayDeclMatch =
            RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*\[\s*(\d+)\s*\]$')
                .firstMatch(part);
        if (arrayDeclMatch != null) {
          // Already declared as array in symbol table → skip re-declaration
          continue;
        }

        final assignMatch =
            RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(.+)$').firstMatch(part);
        if (assignMatch != null) {
          final varName = assignMatch.group(1)!;
          final value = assignMatch.group(2)!.trim();
          final hasSymbol = symbolTable.lookup(varName) != null;
          if (hasSymbol) {
            assignmentParts.add('$varName = $value;');
          } else {
            declarationParts.add('$varName = $value');
          }
          continue;
        }

        if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(part)) {
          final hasSymbol = symbolTable.lookup(part) != null;
          if (!hasSymbol) {
            declarationParts.add(part);
          }
        } else {
          // Fallback: emit the original statement if parsing fails.
          if (options.includeComments) {
            buffer.writeln('$indent// Proceso: $text');
          }
          if (!text.endsWith(';')) {
            buffer.writeln('$indent$text;');
          } else {
            buffer.writeln('$indent$text');
          }
          return;
        }
      }

      // Only emit comment and code when there is something to output.
      if (declarationParts.isNotEmpty || assignmentParts.isNotEmpty) {
        if (options.includeComments) {
          buffer.writeln('$indent// Proceso: $text');
        }
        if (declarationParts.isNotEmpty) {
          buffer.writeln('$indent$type ${declarationParts.join(', ')};');
        }
        for (final assignment in assignmentParts) {
          buffer.writeln('$indent$assignment');
        }
      }
      // Always return after handling a type-declaration node to prevent
      // fallthrough to the generic emitter below.
      return;
    }

    if (options.includeComments) {
      buffer.writeln('$indent// Proceso: $text');
    }

    // Check for assignment
    final assignmentMatch = RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*(\[[^\]]*\])?)\s*=\s*(.+)$').firstMatch(text);
    if (assignmentMatch != null) {
      final varName = assignmentMatch.group(1)!;
      final expression = assignmentMatch.group(3)!;
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
    final text = _normalizeNodeText(node.text);
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
              '${indent}printf("$stringContent ${formatParts.join(' ')}\\n", ${varList.join(', ')});');
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

    // Array element access: name[expr] (e.g. arr[i], arr[j+1], matrix[i*n+j])
    final arrayAccessMatch =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*\[(.+)\]$').firstMatch(content);
    if (arrayAccessMatch != null) {
      final arrName = arrayAccessMatch.group(1)!;
      final indexExpr = arrayAccessMatch.group(2)!.trim();
      final formatSpec = _getFormatSpecifierForVariable(arrName, symbolTable);
      buffer.writeln(
          '${indent}printf("$formatSpec\\n", $arrName[$indexExpr]);');
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
      final parts = content.split(',');
      for (final rawPart in parts) {
        final varExpr = rawPart.trim();
        _emitScanfForExpression(varExpr, symbolTable, buffer, indent);
      }
      return;
    }

    // Single variable or array element access
    _emitScanfForExpression(content.trim(), symbolTable, buffer, indent);
  }

  /// Emit a single scanf call for a variable expression (plain var or arr[i])
  void _emitScanfForExpression(
    String expr,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // Detect array element access: name[index_expr]
    final arrayAccessMatch =
        RegExp(r'^([a-zA-Z_][a-zA-Z0-9_]*)\s*\[(.+)\]$').firstMatch(expr);
    if (arrayAccessMatch != null) {
      final arrName = arrayAccessMatch.group(1)!;
      final indexExpr = arrayAccessMatch.group(2)!.trim();
      // Determine format specifier from the array's element type
      final formatSpec = _getFormatSpecifierForVariable(arrName, symbolTable);
      buffer.writeln('${indent}scanf("$formatSpec", &$arrName[$indexExpr]);');
      return;
    }

    // Plain identifier
    if (_isValidIdentifier(expr)) {
      final formatSpec = _getFormatSpecifierForVariable(expr, symbolTable);
      final needsAmpersand = formatSpec != '%s';
      final ampersand = needsAmpersand ? '&' : '';
      buffer.writeln('${indent}scanf("$formatSpec", $ampersand$expr);');
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
    final condition = _formatCondition(_normalizeNodeText(node.text));

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
            c.label.toLowerCase() == 'true' ||
            c.label.toLowerCase() == 'verdadero'));

    for (final conn in yesBranch) {
      _generateBranchCode(conn.target, allNodes, connections, symbolTable,
          buffer, indent + options.indentation);
    }

    buffer.writeln('$indent}');

    // Find and generate 'no' branch
    final noBranch = connections.where((c) =>
        c.source.id == node.id &&
        (c.label.toLowerCase() == 'no' ||
            c.label.toLowerCase() == 'false' ||
            c.label.toLowerCase() == 'falso'));

    if (noBranch.isNotEmpty) {
      // Use a temporary buffer to avoid emitting empty else blocks
      final elseBuffer = StringBuffer();
      for (final conn in noBranch) {
        _generateBranchCode(conn.target, allNodes, connections, symbolTable,
            elseBuffer, indent + options.indentation);
      }
      if (elseBuffer.isNotEmpty) {
        buffer.writeln('${indent}else {');
        buffer.write(elseBuffer);
        buffer.writeln('$indent}');
      }
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

    // Generate code for this node, passing the branch indent so nested
    // nodes are indented correctly inside if/else blocks.
    _generateNodeCode(node, allNodes, connections, symbolTable, buffer,
        overrideIndent: indent);
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
    final loopText = _normalizeNodeText(node.text);

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

    final outgoing =
        connections.where((c) => c.source.id == node.id && !c.isLoopBack);

    final hasExplicitLoopLabels = outgoing.any((c) {
      final label = c.label.toLowerCase();
      return label == 'verdadero' ||
          label == 'true' ||
          label == 'sí' ||
          label == 'si' ||
          label == 'falso' ||
          label == 'false' ||
          label == 'no';
    });

    final bodyConnections = hasExplicitLoopLabels
        ? outgoing.where((c) {
            final label = c.label.toLowerCase();
            return label == 'verdadero' ||
                label == 'true' ||
                label == 'sí' ||
                label == 'si';
          })
        : outgoing.take(1);

    final followNextConnectionsInBody = hasExplicitLoopLabels;

    // Track visited nodes within the loop body to prevent cycles
    final visitedInBody = <String>{};

    for (final conn in bodyConnections) {
      _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
          buffer, indent + options.indentation, visitedInBody, node.id,
          followNextConnections: followNextConnectionsInBody);
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
    String loopNodeId, {
    bool followNextConnections = true,
  }) {
    // Skip if already visited in this loop body
    if (visitedInBody.contains(node.id)) return;
    visitedInBody.add(node.id);

    // Avoid emitting the same node many times across nested traversals.
    if (_emittedNodeIds.contains(node.id)) return;
    _emittedNodeIds.add(node.id);

    // Skip terminal end nodes
    if (node.type == NodeType.terminal &&
        (node.text.toLowerCase().contains('fin') ||
            node.text.toLowerCase().contains('end'))) {
      return;
    }

    // Skip if this is the loop node itself (loopback)
    if (node.id == loopNodeId) return;

    var handledBranchTraversal = false;

    // Generate code for this node based on its type
    switch (node.type) {
      case NodeType.process:
        _generateProcessCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.data:
        _generateDataCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.decision:
        handledBranchTraversal = true;
        _generateDecisionCodeInLoop(node, allNodes, connections, symbolTable,
            buffer, indent, visitedInBody, loopNodeId,
            followNextConnections: followNextConnections);
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

    if (followNextConnections && !handledBranchTraversal) {
      // Follow non-loopback connections within the body
      final nextConnections =
          connections.where((c) => c.source.id == node.id && !c.isLoopBack);

      for (final conn in nextConnections) {
        // Don't follow back to the original loop node
        if (conn.target.id != loopNodeId) {
          _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
              buffer, indent, visitedInBody, loopNodeId,
              followNextConnections: followNextConnections);
        }
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
    String loopNodeId, {
    bool followNextConnections = true,
  }) {
    // Normalizar la condición (quitar signos de interrogación y formatear)
    final condition = _formatCondition(_normalizeNodeText(node.text));

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
            c.label.toLowerCase() == 'true' ||
            c.label.toLowerCase() == 'verdadero'));

    for (final conn in yesBranch) {
      if (conn.target.id != loopNodeId) {
        _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
            buffer, indent + options.indentation, visitedInBody, loopNodeId,
            followNextConnections: followNextConnections);
      }
    }

    buffer.writeln('$indent}');

    // Find and generate 'no' branch (if not a loopback)
    final noBranch = connections.where((c) =>
        c.source.id == node.id &&
        !c.isLoopBack &&
        (c.label.toLowerCase() == 'no' ||
            c.label.toLowerCase() == 'false' ||
            c.label.toLowerCase() == 'falso'));

    if (noBranch.isNotEmpty) {
      // Use a temporary buffer to avoid emitting empty else blocks
      final elseBuffer = StringBuffer();
      for (final conn in noBranch) {
        if (conn.target.id != loopNodeId) {
          _generateLoopBodyCode(conn.target, allNodes, connections, symbolTable,
              elseBuffer, indent + options.indentation, visitedInBody, loopNodeId,
              followNextConnections: followNextConnections);
        }
      }
      if (elseBuffer.isNotEmpty) {
        buffer.writeln('${indent}else {');
        buffer.write(elseBuffer);
        buffer.writeln('$indent}');
      }
    }
  }

  /// Generate code for subprocess nodes
  void _generateSubprocessCode(
      DiagramNode node, StringBuffer buffer, String indent) {
    final funcName = _normalizeNodeText(node.text);

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
    final text = _normalizeNodeText(node.text);

    if (options.includeComments) {
      buffer.writeln('$indent// Preparación: $text');
    }

    // Preparation nodes typically contain variable declarations
    buffer.writeln('$indent$text;');
  }

  /// Verifica si un nodo es el inicio de un bucle do-while por metadata
  bool _isDoWhileBodyNodeByMetadata(DiagramNode node) {
    return node.metadata['structureType'] == 'loop' &&
        node.metadata['loopType'] == 'do-while' &&
        node.metadata['role'] == 'loop-body';
  }

  /// Verifica si un nodo es la condición de un do-while por metadata
  bool _isDoWhileConditionNodeByMetadata(DiagramNode node) {
    return node.metadata['structureType'] == 'loop' &&
        node.metadata['loopType'] == 'do-while' &&
        node.metadata['role'] == 'loop-condition';
  }

  /// Verifica si un nodo es el inicio de un bucle do-while
  /// Detecta por metadata O por estructura del grafo (auto-detected)
  bool _isDoWhileBodyNode(DiagramNode node) {
    // Por metadata explícita
    if (_isDoWhileBodyNodeByMetadata(node)) return true;
    // Por detección automática del grafo
    if (_autoDetectedDoWhileBodyIds.contains(node.id)) return true;
    return false;
  }

  /// Verifica si un nodo decisión es la condición de un bucle do-while
  /// Detecta tanto por metadata como por estructura del grafo
  bool _isDoWhileConditionNode(DiagramNode node) {
    // Detección por metadata explícita
    if (_isDoWhileConditionNodeByMetadata(node)) return true;
    // Detección automática: si este node es el condition de algún do-while auto-detectado
    if (_autoDetectedDoWhileConditionMap.values.contains(node.id)) return true;
    return false;
  }

  /// Verifica si un nodo decisión es la cabecera de un ciclo while
  /// Detecta por metadata O por presencia de back-edge en conexiones
  bool _isWhileLoopDecision(DiagramNode node, List<Connection> connections) {
    if (node.type != NodeType.decision) return false;
    // Si es una condición de do-while, NO es un while normal
    if (_isDoWhileConditionNode(node)) return false;

    // Detección por metadata explícita
    if (node.metadata['structureType'] == 'loop' &&
        (node.metadata['loopType'] == 'while' ||
         node.metadata['role'] == 'loop-condition')) {
      return true;
    }

    // Detección automática por grafo: si alguna conexión incoming
    // hacia este decision node tiene isLoopBack = true,
    // entonces es un while loop
    final hasIncomingLoopBack = connections.any(
        (c) => c.target.id == node.id && c.isLoopBack);
    if (hasIncomingLoopBack) return true;

    return false;
  }

  /// Genera código while desde un nodo de decisión (rombo)
  void _generateWhileFromDecision(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    final condition = _formatCondition(_normalizeNodeText(node.text));

    if (options.includeComments) {
      buffer.writeln('$indent// Bucle while');
    }

    buffer.writeln('${indent}while ($condition) {');

    // Encontrar la rama del cuerpo del while (Sí/Yes/True/Verdadero)
    final outgoing = connections
        .where((c) => c.source.id == node.id && !c.isLoopBack)
        .toList();

    final bodyBranch = outgoing.where((c) {
      final label = c.label.toLowerCase();
      return label == 'sí' || label == 'si' ||
          label == 'yes' || label == 'true' || label == 'verdadero';
    });

    final exitBranch = outgoing.where((c) {
      final label = c.label.toLowerCase();
      return label == 'no' || label == 'false' || label == 'falso';
    });

    // Track visited nodes within the loop body to prevent cycles
    final visitedInBody = <String>{};

    for (final conn in bodyBranch) {
      _generateLoopBodyCode(
          conn.target, allNodes, connections, symbolTable,
          buffer, indent + options.indentation, visitedInBody, node.id,
          followNextConnections: true);
    }

    buffer.writeln('$indent}');

    // Generar código de la rama de salida del while (lo que viene después)
    for (final conn in exitBranch) {
      // No marcar como emitted para que el flujo principal pueda recogerlos
      // pero solo si no fueron emitidos ya
      if (!_emittedNodeIds.contains(conn.target.id)) {
        _generateNodeCode(
            conn.target, allNodes, connections, symbolTable, buffer);
      }
    }
  }

  /// Genera código do-while desde el nodo body
  /// Soporta nodos de cualquier tipo (process, data, etc.) y múltiples nodos en el body
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

    final bodyIndent = indent + options.indentation;

    // Generar código del cuerpo: recorrer toda la cadena de nodos
    // entre el body-start y la condición
    final visitedInDoWhile = <String>{};
    _generateDoWhileBodyChain(
        bodyNode, allNodes, connections, symbolTable,
        buffer, bodyIndent, visitedInDoWhile);

    // Encontrar el nodo de condición del do-while
    DiagramNode? conditionNode = _findDoWhileCondition(
        bodyNode, connections, visitedInDoWhile);

    if (conditionNode != null) {
      _emittedNodeIds.add(conditionNode.id);

      // Determinar cuál rama hace loopback y cuál sale
      // Para generar nodos intermedios en la rama de repetición y
      // determinar la condición correcta del while()
      final allOutgoing = connections
          .where((c) => c.source.id == conditionNode.id)
          .toList();

      // Encontrar la rama que eventualmente hace loopback al bodyNode
      Connection? loopbackBranchConn;
      Connection? exitBranchConn;
      // También considerar conexiones directas de loopback
      final directLoopback = allOutgoing.where((c) => c.isLoopBack).toList();

      if (directLoopback.isNotEmpty) {
        // El loopback sale directamente del condition node
        loopbackBranchConn = directLoopback.first;
        // La rama de salida es la otra
        exitBranchConn = allOutgoing
            .where((c) => !c.isLoopBack)
            .isEmpty ? null : allOutgoing.firstWhere((c) => !c.isLoopBack);
      } else {
        // El loopback es indirecto (pasa por nodos intermedios)
        // Determinar cuál rama lleva eventualmente al loopback
        for (final conn in allOutgoing) {
          if (_pathLeadsToLoopback(conn.target, bodyNode.id, connections)) {
            loopbackBranchConn = conn;
          } else {
            exitBranchConn = conn;
          }
        }
      }

      // Generar nodos intermedios en la rama de repetición
      // (nodos entre el decision y el loopback, ej: "Mostrar menor")
      if (loopbackBranchConn != null && !loopbackBranchConn.isLoopBack) {
        // Hay nodos intermedios antes del loopback
        _generateDoWhileRepeatBranchNodes(
            loopbackBranchConn.target, bodyNode.id, allNodes,
            connections, symbolTable, buffer, bodyIndent);
      }

      // Determinar la condición del while()
      String condition;
      if (conditionNode.metadata['condition'] != null) {
        condition = conditionNode.metadata['condition'].toString();
      } else {
        String rawCondition = _formatCondition(_normalizeNodeText(conditionNode.text));
        // Determinar si necesitamos negar la condición
        // Si la rama de SALIDA es la "Verdadero", la condición de repetición
        // es la negación: !(condición)
        if (exitBranchConn != null) {
          final exitLabel = exitBranchConn.label.toLowerCase();
          final isExitOnTrue = exitLabel == 'verdadero' || exitLabel == 'sí' ||
              exitLabel == 'si' || exitLabel == 'yes' || exitLabel == 'true';
          if (isExitOnTrue) {
            // La rama true sale del ciclo, así que repetimos cuando es false
            condition = '!($rawCondition)';
          } else {
            // La rama false sale del ciclo (o sin etiqueta), repetimos cuando es true
            condition = rawCondition;
          }
        } else {
          condition = rawCondition;
        }
      }

      buffer.writeln('$indent} while ($condition);');

      // Generar lo que viene después del do-while (la rama de salida)
      if (exitBranchConn != null && !_emittedNodeIds.contains(exitBranchConn.target.id)) {
        _generateNodeCode(
            exitBranchConn.target, allNodes, connections, symbolTable, buffer);
      }
    } else {
      buffer.writeln('$indent} while (1); // TODO: Agregar condición');
    }
  }

  /// Genera código para la cadena de nodos en el cuerpo del do-while
  void _generateDoWhileBodyChain(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
    Set<String> visited,
  ) {
    if (visited.contains(node.id)) return;
    visited.add(node.id);
    _emittedNodeIds.add(node.id);

    // Si llegamos a la condición del do-while, detenernos
    if (_isDoWhileConditionNode(node) ||
        (node.type == NodeType.decision &&
         connections.any((c) => c.source.id == node.id && c.isLoopBack))) {
      return;
    }

    // Generar código según el tipo del nodo
    switch (node.type) {
      case NodeType.data:
        _generateDataCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.process:
        _generateProcessCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.decision:
        _generateDecisionCode(
            node, allNodes, connections, symbolTable, buffer, indent);
        break;
      case NodeType.comment:
        _generateCommentCode(node, buffer, indent);
        break;
      default:
        break;
    }

    // Seguir la cadena de nodos (no loopback)
    final nextConns = connections
        .where((c) => c.source.id == node.id && !c.isLoopBack)
        .toList();
    for (final conn in nextConns) {
      _generateDoWhileBodyChain(
          conn.target, allNodes, connections, symbolTable,
          buffer, indent, visited);
    }
  }

  /// Encuentra el nodo de condición del do-while buscando desde el body
  DiagramNode? _findDoWhileCondition(
    DiagramNode bodyStart,
    List<Connection> connections,
    Set<String> visited,
  ) {
    // Buscar el decision node al que se llega desde el body
    final toVisit = <DiagramNode>[bodyStart];
    final seen = <String>{};

    while (toVisit.isNotEmpty) {
      final current = toVisit.removeAt(0);
      if (seen.contains(current.id)) continue;
      seen.add(current.id);

      final outgoing = connections
          .where((c) => c.source.id == current.id && !c.isLoopBack);
      for (final conn in outgoing) {
        if (_isDoWhileConditionNode(conn.target)) {
          return conn.target;
        }
        if (conn.target.type == NodeType.decision &&
            connections.any((c) =>
                c.source.id == conn.target.id && c.isLoopBack)) {
          return conn.target;
        }
        toVisit.add(conn.target);
      }
    }
    return null;
  }


  /// Verifica si un camino desde un nodo eventualmente llega a un loopback
  /// que apunta al bodyStartId
  bool _pathLeadsToLoopback(
    DiagramNode fromNode,
    String bodyStartId,
    List<Connection> connections,
  ) {
    final queue = <String>[fromNode.id];
    final seen = <String>{};
    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      if (seen.contains(currentId)) continue;
      seen.add(currentId);
      for (final conn in connections.where((c) => c.source.id == currentId)) {
        if (conn.isLoopBack && conn.target.id == bodyStartId) return true;
        if (!conn.isLoopBack) queue.add(conn.target.id);
      }
    }
    return false;
  }

  /// Genera código para nodos intermedios en la rama de repetición del do-while
  /// (nodos entre el decision y el loopback, ej: "Mostrar Eres menor")
  void _generateDoWhileRepeatBranchNodes(
    DiagramNode node,
    String bodyStartId,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
    String indent,
  ) {
    // No generar si ya fue emitido o si es el bodyStart (loopback target)
    if (_emittedNodeIds.contains(node.id)) return;
    if (node.id == bodyStartId) return;
    _emittedNodeIds.add(node.id);

    // Generar código según el tipo del nodo
    switch (node.type) {
      case NodeType.data:
        _generateDataCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.process:
        _generateProcessCode(node, symbolTable, buffer, indent);
        break;
      case NodeType.comment:
        _generateCommentCode(node, buffer, indent);
        break;
      default:
        break;
    }

    // Seguir la cadena (no loopback)
    final nextConns = connections
        .where((c) => c.source.id == node.id && !c.isLoopBack)
        .toList();
    for (final conn in nextConns) {
      _generateDoWhileRepeatBranchNodes(
          conn.target, bodyStartId, allNodes, connections,
          symbolTable, buffer, indent);
    }
  }

  /// Sigue las conexiones de salida de un nodo do-while condition
  /// que fue omitido porque ya fue procesado
  void _skipToDoWhileExit(
    DiagramNode conditionNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    SymbolTable symbolTable,
    StringBuffer buffer,
  ) {
    // La rama de salida del do-while ya fue generada por
    // _generateDoWhileExitBranch, así que no necesitamos hacer nada aquí.
    // Los nodos de salida ya están marcados como emitidos.
  }

  /// Formatea una condición para código C
  String _formatCondition(String text) {
    // Normalize newlines first (in case caller didn't pre-normalize)
    String condition = text
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

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
