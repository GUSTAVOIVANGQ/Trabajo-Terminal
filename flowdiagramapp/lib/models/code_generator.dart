import 'diagram_node.dart';

enum ProgrammingLanguage { c, python, javascript, java, pseudocode }

class CodeGenerator {
  // Convierte el diagrama en código fuente del lenguaje especificado
  static String generateCode(
    List<DiagramNode> nodes,
    List<Connection> connections,
    ProgrammingLanguage language,
  ) {
    // Verificar que exista un nodo terminal de inicio
    final startNodes = nodes
        .where((node) =>
            node.type == NodeType.terminal &&
            (node.text.toLowerCase().contains('inicio') ||
                node.text.toLowerCase().contains('start') ||
                node.text.isEmpty))
        .toList();
    if (startNodes.isEmpty) {
      return "// Error: El diagrama debe tener un nodo terminal de inicio";
    }
    final DiagramNode startNode = startNodes.first;

    // Por ahora, solo generamos código C
    if (language == ProgrammingLanguage.c) {
      return _generateCCode(startNode, nodes, connections);
    } else {
      return "// La generación de código para este lenguaje estará disponible próximamente";
    }
  }

  // ============================================================
  // MÉTODOS DE DETECCIÓN INTELIGENTE (FASE 3)
  // ============================================================

  /// Detecta si un nodo es parte de una estructura switch
  /// Prioridad 1: Metadata explícito
  /// Prioridad 2: Patrón de texto
  static bool _isSwitchStatement(DiagramNode node) {
    // Prioridad 1: Metadata explícito
    if (node.metadata['structureType'] == 'switch' &&
        node.metadata['role'] == 'switch-header') {
      return true;
    }

    // Prioridad 2: Patrón de texto
    final text = node.text.trim().toLowerCase();
    return text.startsWith('switch(') || text.startsWith('switch (');
  }

  /// Detecta el tipo de bucle (for, while, do-while)
  /// Prioridad 1: Metadata explícito
  /// Prioridad 2: Patrón de texto
  static String _detectLoopType(DiagramNode node) {
    // Prioridad 1: Metadata explícito
    if (node.metadata['loopType'] != null) {
      return node.metadata['loopType'];
    }

    // Prioridad 2: Palabra clave explícita en el texto
    final text = node.text.trim().toLowerCase();
    if (text.startsWith('for(') || text.startsWith('for (')) {
      return 'for';
    }
    if (text.startsWith('while(') || text.startsWith('while (')) {
      return 'while';
    }
    if (text.startsWith('do ') || text.contains('do {')) {
      return 'do-while';
    }

    // Prioridad 3: Análisis de patrón
    // For típicamente tiene 3 partes: init; condition; increment
    if (text.split(';').length >= 3) {
      return 'for';
    }

    // Por defecto: while
    return 'while';
  }

  /// Detecta si un nodo de decisión es un case de switch
  static bool _isSwitchCase(DiagramNode node) {
    return node.metadata['structureType'] == 'switch' &&
        node.metadata['role'] == 'switch-case';
  }

  /// Verifica si un nodo forma parte de una estructura de bucle basado en metadata
  static bool _isLoopNode(DiagramNode node) {
    return node.metadata['structureType'] == 'loop';
  }

  /// Genera código switch completo basado en metadata
  static void _generateSwitchCode(
    DiagramNode switchNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Extraer variable del switch (desde metadata o texto)
    String switchVar = switchNode.metadata['variable'] ??
        _extractSwitchVariable(switchNode.text);

    code.writeln("${indent}switch ($switchVar) {");

    // Buscar todos los nodos case conectados
    final outConnections =
        connections.where((conn) => conn.source == switchNode).toList();

    for (final connection in outConnections) {
      final targetNode = connection.target;

      // Verificar si es un case
      if (_isSwitchCase(targetNode)) {
        String caseValue = targetNode.metadata['caseValue'] ??
            _extractCaseValue(targetNode.text);
        code.writeln("${indent}    case $caseValue:");

        // Generar código del cuerpo del case
        _generateSwitchCaseBody(targetNode, allNodes, connections, code,
            indent + "        ", processedNodes);

        code.writeln("${indent}        break;");
      }
    }

    // Agregar default si existe
    final defaultCase = outConnections.firstWhere(
      (conn) => conn.target.metadata['role'] == 'switch-default',
      orElse: () =>
          Connection(source: switchNode, target: switchNode, label: ''),
    );

    if (defaultCase.target.id != switchNode.id) {
      code.writeln("${indent}    default:");
      _generateSwitchCaseBody(defaultCase.target, allNodes, connections, code,
          indent + "        ", processedNodes);
      code.writeln("${indent}        break;");
    }

    code.writeln("${indent}}");

    // Marcar switch como procesado
    processedNodes[switchNode.id] = true;

    // Procesar nodos después del switch
    _processNextNodes(
        switchNode, allNodes, connections, code, indent, processedNodes);
  }

  /// Genera el cuerpo de un case en un switch
  static void _generateSwitchCaseBody(
    DiagramNode caseNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    processedNodes[caseNode.id] = true;

    // Buscar nodos conectados al case (cuerpo del case)
    final caseConnections =
        connections.where((conn) => conn.source == caseNode).toList();

    for (final connection in caseConnections) {
      final targetNode = connection.target;

      // No procesar otros cases ni el nodo switch
      if (!_isSwitchCase(targetNode) && !_isSwitchStatement(targetNode)) {
        _generateCNodeCode(
            targetNode, allNodes, connections, code, indent, processedNodes);
      }
    }
  }

  /// Extrae la variable del switch desde el texto
  static String _extractSwitchVariable(String text) {
    // Buscar patrón switch(variable)
    final match =
        RegExp(r'switch\s*\(\s*(\w+)\s*\)').firstMatch(text.toLowerCase());
    if (match != null) {
      return match.group(1) ?? 'x';
    }
    return 'x';
  }

  /// Extrae el valor del case desde el texto
  static String _extractCaseValue(String text) {
    // Buscar patrón case valor:
    final match = RegExp(r'case\s+(.+?)\s*:').firstMatch(text.toLowerCase());
    if (match != null) {
      return match.group(1)?.trim() ?? '0';
    }
    return '0';
  }

  /// Genera código for loop basado en metadata
  static void _generateForLoopCode(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Extraer parámetros del for desde metadata o texto
    String initialization = loopNode.metadata['initialization'] ??
        _extractForInitialization(loopNode.text);
    String condition =
        loopNode.metadata['condition'] ?? _extractForCondition(loopNode.text);
    String increment =
        loopNode.metadata['increment'] ?? _extractForIncrement(loopNode.text);

    code.writeln("${indent}for ($initialization; $condition; $increment) {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}}");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  /// Extrae la inicialización del for desde el texto
  static String _extractForInitialization(String text) {
    // Buscar patrón for(init; condition; increment)
    final match = RegExp(r'for\s*\(\s*([^;]+);').firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? 'int i = 0';
    }
    return 'int i = 0';
  }

  /// Extrae la condición del for desde el texto
  static String _extractForCondition(String text) {
    // Buscar patrón for(init; condition; increment)
    final match = RegExp(r'for\s*\([^;]+;\s*([^;]+);').firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? 'i < 10';
    }
    return 'i < 10';
  }

  /// Extrae el incremento del for desde el texto
  static String _extractForIncrement(String text) {
    // Buscar patrón for(init; condition; increment)
    final match = RegExp(r'for\s*\([^;]+;[^;]+;\s*([^)]+)\)').firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? 'i++';
    }
    return 'i++';
  }

  /// Genera código while loop basado en metadata
  static void _generateWhileLoopCode(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Extraer condición desde metadata o texto
    String condition =
        loopNode.metadata['condition'] ?? _extractLoopCondition(loopNode.text);

    code.writeln("${indent}while ($condition) {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}}");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  /// Genera código do-while loop
  static void _generateDoWhileLoopCode(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    code.writeln("${indent}do {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    // Extraer condición
    String condition =
        loopNode.metadata['condition'] ?? _extractLoopCondition(loopNode.text);

    code.writeln("${indent}} while ($condition);");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  // Genera código C
  static String _generateCCode(
    DiagramNode startNode,
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    StringBuffer code = StringBuffer();

    code.writeln(
      "// Código C generado automáticamente a partir del diagrama de flujo",
    );
    code.writeln("// Generado el ${DateTime.now().toString()}");
    code.writeln("");
    code.writeln("#include <stdio.h>");
    code.writeln("#include <stdlib.h>");
    code.writeln("#include <stdbool.h>");
    code.writeln("");

    // Detectar y generar subprocesos/funciones definidos en el diagrama
    _generateSubprocessFunctions(nodes, connections, code);

    // Función principal
    code.writeln("int main() {");

    // Variables para seguimiento
    Map<String, bool> processedNodes = {};

    // Marcar los nodos de subprocesos como procesados para no procesarlos en main
    _markSubprocessNodesAsProcessed(nodes, processedNodes);

    // Comenzar la generación recursiva desde el nodo de inicio
    _generateCNodeCode(
      startNode,
      nodes,
      connections,
      code,
      "    ",
      processedNodes,
    );

    // Terminar la función principal
    code.writeln("");
    code.writeln("    return 0;");
    code.writeln("}");

    return code.toString();
  }

  /// Detecta subprocesos definidos en el diagrama y genera funciones C para ellos
  static void _generateSubprocessFunctions(
    List<DiagramNode> nodes,
    List<Connection> connections,
    StringBuffer code,
  ) {
    // Buscar nodos terminales que sean inicio de subprocesos
    // (tienen formato "Inicio NombreFuncion" o "Inicio NombreFuncion(params)")
    final subprocessStartNodes = nodes.where((node) {
      if (node.type != NodeType.terminal) return false;
      final text = node.text.trim();
      final lowerText = text.toLowerCase();

      // Debe contener "inicio" o "start"
      if (!lowerText.startsWith('inicio ') && !lowerText.startsWith('start '))
        return false;

      // El nombre después de "inicio" debe ser un identificador (nombre de función)
      final words = text.split(RegExp(r'\s+'));
      if (words.length < 2) return false;

      // Verificar que no sea el inicio del programa principal
      final secondWord = words[1];
      if (['de', 'del', 'programa', 'principal', 'main']
          .contains(secondWord.toLowerCase())) return false;

      return true;
    }).toList();

    // Generar cada subproceso como función
    for (final subStartNode in subprocessStartNodes) {
      _generateSingleSubprocessFunction(subStartNode, nodes, connections, code);
    }
  }

  /// Genera una función C para un subproceso específico
  static void _generateSingleSubprocessFunction(
    DiagramNode subStartNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
  ) {
    // Extraer nombre de función y parámetros del texto
    final functionInfo = _extractFunctionInfo(subStartNode.text);
    final functionName = functionInfo['name'] ?? 'funcion';
    final parameters = functionInfo['params'] ?? '';

    // Determinar tipo de retorno (por defecto int)
    String returnType = 'int';

    // Buscar si hay un nodo con "return" para determinar el tipo
    final subprocessNodes = _getSubprocessNodes(subStartNode, connections);
    for (final node in subprocessNodes) {
      if (node.text.toLowerCase().contains('return')) {
        // Si retorna algo con punto decimal, usar float
        if (node.text.contains('.')) {
          returnType = 'float';
        }
        break;
      }
    }

    // Escribir firma de función
    code.writeln("// Subproceso: $functionName");
    code.writeln("$returnType $functionName($parameters) {");

    // Generar código del cuerpo del subproceso
    Map<String, bool> processedNodes = {};
    processedNodes[subStartNode.id] = true;

    // Procesar nodos del subproceso
    final outConnections =
        connections.where((conn) => conn.source == subStartNode).toList();
    for (final conn in outConnections) {
      _generateSubprocessNodeCode(
        conn.target,
        allNodes,
        connections,
        code,
        "    ",
        processedNodes,
      );
    }

    code.writeln("}");
    code.writeln("");
  }

  /// Extrae el nombre de la función y parámetros del texto del nodo
  static Map<String, String> _extractFunctionInfo(String text) {
    // Patrones: "Inicio Suma(x, y)" o "Inicio Suma" o "Start Sum(a, b)"
    final result = <String, String>{};

    // Remover "Inicio " o "Start "
    String cleaned = text.trim();
    if (cleaned.toLowerCase().startsWith('inicio ')) {
      cleaned = cleaned.substring(7).trim();
    } else if (cleaned.toLowerCase().startsWith('start ')) {
      cleaned = cleaned.substring(6).trim();
    }

    // Verificar si tiene parámetros entre paréntesis
    if (cleaned.contains('(') && cleaned.contains(')')) {
      final parenStart = cleaned.indexOf('(');
      final parenEnd = cleaned.lastIndexOf(')');
      result['name'] = cleaned.substring(0, parenStart).trim();
      result['params'] = cleaned.substring(parenStart + 1, parenEnd).trim();

      // Agregar tipos a los parámetros si no los tienen
      if (result['params']!.isNotEmpty &&
          !result['params']!.contains('int') &&
          !result['params']!.contains('float')) {
        final params = result['params']!
            .split(',')
            .map((p) => 'int ${p.trim()}')
            .join(', ');
        result['params'] = params;
      }
    } else {
      result['name'] = cleaned;
      result['params'] = '';
    }

    return result;
  }

  /// Obtiene todos los nodos que pertenecen a un subproceso
  static List<DiagramNode> _getSubprocessNodes(
    DiagramNode subStartNode,
    List<Connection> connections,
  ) {
    final result = <DiagramNode>[];
    final visited = <String>{};

    void traverse(DiagramNode node) {
      if (visited.contains(node.id)) return;
      visited.add(node.id);
      result.add(node);

      final outConnections =
          connections.where((conn) => conn.source == node).toList();
      for (final conn in outConnections) {
        traverse(conn.target);
      }
    }

    traverse(subStartNode);
    return result;
  }

  /// Marca todos los nodos de subprocesos como procesados
  static void _markSubprocessNodesAsProcessed(
    List<DiagramNode> nodes,
    Map<String, bool> processedNodes,
  ) {
    // Encontrar nodos de inicio de subprocesos
    for (final node in nodes) {
      if (node.type == NodeType.terminal) {
        final text = node.text.trim().toLowerCase();
        if ((text.startsWith('inicio ') || text.startsWith('start ')) &&
            !text.contains('programa') &&
            !text.contains('principal') &&
            !text.contains('main')) {
          // Verificar que tiene un nombre de función después
          final words = node.text.split(RegExp(r'\s+'));
          if (words.length >= 2) {
            processedNodes[node.id] = true;
          }
        }
      }
    }
  }

  /// Genera código para nodos dentro de un subproceso
  static void _generateSubprocessNodeCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    if (processedNodes[node.id] == true) return;
    processedNodes[node.id] = true;

    switch (node.type) {
      case NodeType.terminal:
        // Si es fin del subproceso, no generar código especial
        final lowerText = node.text.toLowerCase();
        if (lowerText.contains('fin') || lowerText.contains('end')) {
          // No generar nada, el return ya se manejó
        }
        break;

      case NodeType.process:
        code.writeln("${indent}${_formatCProcessStatement(node.text)};");
        _processSubprocessNextNodes(
            node, allNodes, connections, code, indent, processedNodes);
        break;

      case NodeType.data:
        final dataText = node.text.toLowerCase();
        // Verificar si es un return
        if (dataText.contains('return')) {
          final returnValue = _extractReturnValue(node.text);
          code.writeln("${indent}return $returnValue;");
        } else if (dataText.contains('leer') || dataText.contains('input')) {
          code.writeln("${indent}${_formatCInputStatement(node.text)};");
          _processSubprocessNextNodes(
              node, allNodes, connections, code, indent, processedNodes);
        } else {
          code.writeln("${indent}${_formatCOutputStatement(node.text)};");
          _processSubprocessNextNodes(
              node, allNodes, connections, code, indent, processedNodes);
        }
        break;

      default:
        _processSubprocessNextNodes(
            node, allNodes, connections, code, indent, processedNodes);
        break;
    }
  }

  /// Procesa los siguientes nodos en un subproceso
  static void _processSubprocessNextNodes(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    final outConnections =
        connections.where((conn) => conn.source == node).toList();
    for (final conn in outConnections) {
      _generateSubprocessNodeCode(
          conn.target, allNodes, connections, code, indent, processedNodes);
    }
  }

  /// Extrae el valor de retorno de un texto como "return retorno"
  static String _extractReturnValue(String text) {
    final lowerText = text.toLowerCase().trim();
    if (lowerText.startsWith('return ')) {
      return text.substring(7).trim();
    }
    // Buscar patrón "return X"
    final match =
        RegExp(r'return\s+(\S+)', caseSensitive: false).firstMatch(text);
    if (match != null) {
      return match.group(1) ?? '0';
    }
    return '0';
  }

  // Genera código recursivamente para un nodo en C
  static void _generateCNodeCode(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Evitar ciclos infinitos
    if (processedNodes[node.id] == true) {
      return;
    }
    processedNodes[node.id] = true;

    // ============ DETECCIÓN DE ESTRUCTURAS SWITCH ============
    if (node.type == NodeType.process && _isSwitchStatement(node)) {
      _generateSwitchCode(
          node, allNodes, connections, code, indent, processedNodes);
      return;
    }

    // ============ DETECCIÓN DE BUCLES CON METADATA ============
    if (node.type == NodeType.decision && _isLoopNode(node)) {
      final loopType = _detectLoopType(node);

      if (loopType == 'for') {
        _generateForLoopCode(
            node, allNodes, connections, code, indent, processedNodes);
      } else if (loopType == 'while') {
        _generateWhileLoopCode(
            node, allNodes, connections, code, indent, processedNodes);
      } else if (loopType == 'do-while') {
        _generateDoWhileLoopCode(
            node, allNodes, connections, code, indent, processedNodes);
      }
      return;
    }

    switch (node.type) {
      case NodeType.terminal:
        // Determinar si es inicio o fin según el texto
        final isStart = node.text.toLowerCase().contains('inicio') ||
            node.text.toLowerCase().contains('start') ||
            node.text.isEmpty;
        final isEnd = node.text.toLowerCase().contains('fin') ||
            node.text.toLowerCase().contains('end') ||
            node.text.toLowerCase().contains('terminar');

        if (isStart) {
          // El nodo terminal de inicio no genera código específico
          _processNextNodes(
            node,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
        } else if (isEnd) {
          code.writeln("${indent}// Fin del programa");
        }
        break;

      case NodeType.predefinedProcess:
        // Los subprocesos se traducen en llamadas a función
        code.writeln("${indent}// Llamada a subproceso/función");
        code.writeln("${indent}${_formatSubprocessCall(node.text)};");
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.process:
        code.writeln("${indent}// Proceso: ${node.text}");
        code.writeln("${indent}${_formatCProcessStatement(node.text)};");
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.decision:
        code.writeln("${indent}// Decisión: ${node.text}");

        // FASE 3: Detectar si es un switch statement
        if (_isSwitchStatement(node)) {
          _generateSwitchCode(
            node,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
          break; // Salir del switch, ya procesamos el nodo
        }

        // Verificar si este nodo de decisión es parte de un bucle while
        // (tiene una conexión de retorno desde uno de sus descendientes)
        final outConnections =
            connections.where((conn) => conn.source == node).toList();

        bool isWhileLoop = false;
        Connection? trueConn;
        Connection? falseConn;

        // Identificar las conexiones verdadera y falsa
        for (var conn in outConnections) {
          final label = conn.label.toLowerCase();
          if (label.contains('true') ||
              label.contains('verdadero') ||
              label.contains('sí') ||
              label.contains('yes')) {
            trueConn = conn;
          } else if (label.contains('false') ||
              label.contains('falso') ||
              label.contains('no')) {
            falseConn = conn;
          }
        }

        // Si no se identificaron por etiqueta, usar orden
        trueConn ??= outConnections.isNotEmpty ? outConnections.first : null;
        falseConn ??= outConnections.length > 1 ? outConnections[1] : null;

        // Verificar si la rama verdadera tiene un camino de retorno (es un while)
        if (trueConn != null) {
          isWhileLoop = _hasReturnPath(trueConn.target, node, connections, {});
        }

        if (isWhileLoop && trueConn != null) {
          // Generar un bucle while
          code.writeln("${indent}while (${_formatCCondition(node.text)}) {");

          // Marcar el nodo de decisión como procesado para evitar que se procese
          // de nuevo cuando el cuerpo del bucle llegue al loop back
          processedNodes[node.id] = true;

          // Procesar el cuerpo del bucle (rama verdadera) con detección de loop back
          _generateWhileLoopBody(
            trueConn.target,
            node, // El nodo de decisión del while (para detectar loop back)
            allNodes,
            connections,
            code,
            indent + "    ",
            Map<String, bool>.from(processedNodes),
          );

          code.writeln("${indent}}");

          // Procesar lo que viene después del bucle (rama falsa)
          if (falseConn != null) {
            _generateCNodeCode(
              falseConn.target,
              allNodes,
              connections,
              code,
              indent,
              processedNodes,
            );
          }
        } else {
          // Generar un if-else normal
          code.writeln("${indent}if (${_formatCCondition(node.text)}) {");

          // Procesar rama 'true' con indentación adicional
          if (outConnections.isNotEmpty) {
            final trueConnection = outConnections.firstWhere(
              (conn) =>
                  conn.label.toLowerCase().contains('true') ||
                  conn.label.toLowerCase().contains('sí') ||
                  conn.label.toLowerCase().contains('yes'),
              orElse: () => outConnections.first,
            );
            _generateCNodeCode(
              trueConnection.target,
              allNodes,
              connections,
              code,
              indent + "    ",
              Map.from(processedNodes),
            );
          }

          // Procesar rama 'false'
          if (outConnections.length > 1) {
            final falseConnection = outConnections.firstWhere(
              (conn) =>
                  conn.label.toLowerCase().contains('false') ||
                  conn.label.toLowerCase().contains('no'),
              orElse: () => outConnections[1],
            );
            code.writeln("${indent}} else {");
            _generateCNodeCode(
              falseConnection.target,
              allNodes,
              connections,
              code,
              indent + "    ",
              Map.from(processedNodes),
            );
          }

          code.writeln("${indent}}");
        }
        break;

      case NodeType.data:
        // Detectar si es entrada o salida basándose en el texto
        final dataText = node.text.toLowerCase();
        final isInput = dataText.contains('leer') ||
            dataText.contains('input') ||
            dataText.contains('ingresar') ||
            dataText.contains('scanf');
        final isOutput = dataText.contains('mostrar') ||
            dataText.contains('imprimir') ||
            dataText.contains('print') ||
            dataText.contains('escribir') ||
            dataText.contains('printf');

        if (isInput) {
          code.writeln("${indent}// Entrada: ${node.text}");
          code.writeln("${indent}${_formatCInputStatement(node.text)};");
        } else if (isOutput) {
          code.writeln("${indent}// Salida: ${node.text}");
          code.writeln("${indent}${_formatCOutputStatement(node.text)};");
        } else {
          // Por defecto, considerar como salida
          code.writeln("${indent}// Dato: ${node.text}");
          code.writeln("${indent}${_formatCOutputStatement(node.text)};");
        }

        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.preparation:
        // Analizar si es una inicialización simple o una estructura de bucle completa
        final loopText = node.text.toLowerCase();

        // Si el texto parece una inicialización simple (variable = valor)
        if (!loopText.contains('while') &&
            !loopText.contains('for') &&
            !loopText.contains('do') &&
            !loopText.contains('mientras') &&
            !loopText.contains('para') &&
            !loopText.contains('hacer') &&
            loopText.contains('=')) {
          // Es una inicialización, generar el código y continuar
          code.writeln("${indent}// Inicialización");
          code.writeln("${indent}${_formatCProcessStatement(node.text)};");

          // Buscar el siguiente nodo (debería ser la decisión del bucle)
          _processNextNodes(
            node,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
        } else {
          // Es una estructura de bucle completa (legado)
          code.writeln("${indent}// Bucle: ${node.text}");
          _generateCLoopCode(
            node,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
        }
        break;

      // ISO 5807 symbols without code generation
      // These symbols are for documentation and structural purposes only
      default:
        // Comment the symbol in generated code for documentation
        if (node.type.hasCodeGeneration == false) {
          code.writeln(
              "${indent}// [ISO 5807] ${node.type.isoName}: ${node.text}");
        }
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;
    }
  }

  // Procesa los nodos siguientes conectados al nodo actual
  static void _processNextNodes(
    DiagramNode node,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Encuentra el siguiente nodo para procesos lineales (no decisiones ni bucles)
    if (node.type != NodeType.decision && node.type != NodeType.preparation) {
      final outConnections =
          connections.where((conn) => conn.source == node).toList();
      for (final connection in outConnections) {
        _generateCNodeCode(
          connection.target,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
      }
    }
  }

  // Genera código para bucles en C
  static void _generateCLoopCode(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Analizar el texto del bucle para determinar el tipo
    final loopText = loopNode.text.toLowerCase();

    if (loopText.contains('while') || loopText.contains('mientras')) {
      _generateWhileLoop(
          loopNode, allNodes, connections, code, indent, processedNodes);
    } else if (loopText.contains('for') || loopText.contains('para')) {
      _generateForLoop(
          loopNode, allNodes, connections, code, indent, processedNodes);
    } else if (loopText.contains('do') || loopText.contains('hacer')) {
      _generateDoWhileLoop(
          loopNode, allNodes, connections, code, indent, processedNodes);
    } else {
      // Bucle genérico - usar while por defecto
      _generateGenericLoop(
          loopNode, allNodes, connections, code, indent, processedNodes);
    }
  }

  // Genera un bucle while
  static void _generateWhileLoop(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    String condition = _extractLoopCondition(loopNode.text);
    code.writeln("${indent}while ($condition) {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}}");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  // Genera un bucle for
  static void _generateForLoop(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    String forStatement = _extractForStatement(loopNode.text);
    code.writeln("${indent}for ($forStatement) {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}}");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  // Genera un bucle do-while
  static void _generateDoWhileLoop(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    String condition = _extractLoopCondition(loopNode.text);
    code.writeln("${indent}do {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}} while ($condition);");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  // Genera un bucle genérico (while)
  static void _generateGenericLoop(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Si no hay condición específica, usar una condición básica
    String condition = loopNode.text.isEmpty
        ? "/* condición */"
        : _formatCCondition(loopNode.text);
    code.writeln("${indent}while ($condition) {");

    _generateLoopBody(
        loopNode, allNodes, connections, code, indent + "    ", processedNodes);

    code.writeln("${indent}}");

    // Procesar nodos después del bucle
    _processLoopExit(
        loopNode, allNodes, connections, code, indent, processedNodes);
  }

  // Genera el cuerpo del bucle
  static void _generateLoopBody(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Encontrar nodos dentro del bucle (conectados desde el nodo de bucle)
    final loopConnections =
        connections.where((conn) => conn.source == loopNode).toList();

    for (final connection in loopConnections) {
      // Solo procesar nodos que forman parte del cuerpo del bucle
      // (no la salida del bucle)
      if (!_isLoopExitConnection(connection, loopNode, connections)) {
        _generateCNodeCode(
          connection.target,
          allNodes,
          connections,
          code,
          indent,
          Map.from(processedNodes), // Copia para evitar marcar como procesados
        );
      }
    }
  }

  // Procesa la salida del bucle
  static void _processLoopExit(
    DiagramNode loopNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    final exitConnections = connections
        .where((conn) =>
            conn.source == loopNode &&
            _isLoopExitConnection(conn, loopNode, connections))
        .toList();

    for (final connection in exitConnections) {
      _generateCNodeCode(
        connection.target,
        allNodes,
        connections,
        code,
        indent,
        processedNodes,
      );
    }
  }

  // Determina si una conexión es una salida del bucle
  static bool _isLoopExitConnection(
    Connection connection,
    DiagramNode loopNode,
    List<Connection> allConnections,
  ) {
    // Una conexión es de salida si no tiene camino de retorno al bucle
    return !_hasReturnPath(
        connection.target, loopNode, allConnections, Set<String>());
  }

  // Genera el cuerpo de un while, deteniéndose antes del loop back
  static void _generateWhileLoopBody(
    DiagramNode currentNode,
    DiagramNode whileDecisionNode,
    List<DiagramNode> allNodes,
    List<Connection> connections,
    StringBuffer code,
    String indent,
    Map<String, bool> processedNodes,
  ) {
    // Si ya procesamos este nodo o es el nodo de decisión del while, detenernos
    if (processedNodes[currentNode.id] == true) {
      return;
    }
    if (currentNode.id == whileDecisionNode.id) {
      return; // Llegamos al loop back, no generar más código
    }

    processedNodes[currentNode.id] = true;

    // Verificar si este nodo conecta de vuelta al while (es el último del cuerpo)
    final outConnections =
        connections.where((conn) => conn.source == currentNode).toList();

    bool connectsBackToWhile =
        outConnections.any((conn) => conn.target.id == whileDecisionNode.id);

    // Generar código según el tipo de nodo
    switch (currentNode.type) {
      case NodeType.process:
        code.writeln("${indent}// Proceso: ${currentNode.text}");
        code.writeln("${indent}${_formatCProcessStatement(currentNode.text)};");
        break;

      case NodeType.data:
        final dataText = currentNode.text.toLowerCase();
        final isInput = dataText.contains('leer') ||
            dataText.contains('input') ||
            dataText.contains('ingresar') ||
            dataText.contains('scanf');
        final isOutput = dataText.contains('mostrar') ||
            dataText.contains('imprimir') ||
            dataText.contains('print') ||
            dataText.contains('escribir') ||
            dataText.contains('printf');

        if (isInput) {
          code.writeln("${indent}// Entrada: ${currentNode.text}");
          code.writeln("${indent}${_formatCInputStatement(currentNode.text)};");
        } else if (isOutput) {
          code.writeln("${indent}// Salida: ${currentNode.text}");
          code.writeln(
              "${indent}${_formatCOutputStatement(currentNode.text)};");
        } else {
          code.writeln("${indent}// Dato: ${currentNode.text}");
          code.writeln(
              "${indent}${_formatCOutputStatement(currentNode.text)};");
        }
        break;

      case NodeType.decision:
        // Decisión dentro del while (if-else anidado)
        code.writeln("${indent}// Decisión: ${currentNode.text}");
        code.writeln("${indent}if (${_formatCCondition(currentNode.text)}) {");

        final decisionConnections =
            connections.where((conn) => conn.source == currentNode).toList();

        Connection? trueConn;
        Connection? falseConn;

        for (var conn in decisionConnections) {
          final label = conn.label.toLowerCase();
          if (label.contains('true') ||
              label.contains('sí') ||
              label.contains('yes')) {
            trueConn = conn;
          } else if (label.contains('false') || label.contains('no')) {
            falseConn = conn;
          }
        }

        trueConn ??=
            decisionConnections.isNotEmpty ? decisionConnections.first : null;
        falseConn ??=
            decisionConnections.length > 1 ? decisionConnections[1] : null;

        if (trueConn != null && trueConn.target.id != whileDecisionNode.id) {
          _generateWhileLoopBody(
            trueConn.target,
            whileDecisionNode,
            allNodes,
            connections,
            code,
            indent + "    ",
            Map<String, bool>.from(processedNodes),
          );
        }

        if (falseConn != null && falseConn.target.id != whileDecisionNode.id) {
          code.writeln("${indent}} else {");
          _generateWhileLoopBody(
            falseConn.target,
            whileDecisionNode,
            allNodes,
            connections,
            code,
            indent + "    ",
            Map<String, bool>.from(processedNodes),
          );
        }

        code.writeln("${indent}}");
        return; // Las decisiones manejan sus propias conexiones

      default:
        // Otros tipos de nodos
        if (currentNode.type != NodeType.terminal) {
          code.writeln(
              "${indent}// ${currentNode.type.name}: ${currentNode.text}");
        }
        break;
    }

    // Si no conecta de vuelta al while, procesar los siguientes nodos
    if (!connectsBackToWhile) {
      for (final conn in outConnections) {
        if (conn.target.id != whileDecisionNode.id) {
          _generateWhileLoopBody(
            conn.target,
            whileDecisionNode,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
        }
      }
    }
  }

  // Verifica si hay un camino de retorno al bucle
  static bool _hasReturnPath(
    DiagramNode currentNode,
    DiagramNode loopNode,
    List<Connection> connections,
    Set<String> visited,
  ) {
    if (visited.contains(currentNode.id)) {
      return false;
    }
    visited.add(currentNode.id);

    if (currentNode.id == loopNode.id) {
      return true;
    }

    final outConnections =
        connections.where((conn) => conn.source == currentNode).toList();
    for (final connection in outConnections) {
      if (_hasReturnPath(
          connection.target, loopNode, connections, Set.from(visited))) {
        return true;
      }
    }

    return false;
  }

  // Extrae la condición del bucle desde el texto
  static String _extractLoopCondition(String text) {
    // Buscar patrones comunes de condiciones
    if (text.contains('(') && text.contains(')')) {
      final start = text.indexOf('(');
      final end = text.lastIndexOf(')');
      if (start != -1 && end != -1 && end > start) {
        return text.substring(start + 1, end);
      }
    }

    // Si contiene operadores de comparación, usar como condición
    if (text.contains('==') ||
        text.contains('>') ||
        text.contains('<') ||
        text.contains('>=') ||
        text.contains('<=') ||
        text.contains('!=')) {
      return text;
    }

    // Condición por defecto
    return "/* $text */";
  }

  // Extrae la declaración for desde el texto
  static String _extractForStatement(String text) {
    // Buscar patrón for(init; condition; increment)
    if (text.contains('(') && text.contains(')')) {
      final start = text.indexOf('(');
      final end = text.lastIndexOf(')');
      if (start != -1 && end != -1 && end > start) {
        return text.substring(start + 1, end);
      }
    }

    // Patrón básico por defecto
    return "int i = 0; i < 10; i++";
  }

  // Formatea una declaración de proceso para C
  static String _formatCProcessStatement(String text) {
    String trimmedText = text.trim();

    // Si el texto termina con punto y coma, removerlo para evitar duplicación
    if (trimmedText.endsWith(';')) {
      trimmedText = trimmedText.substring(0, trimmedText.length - 1);
    }

    // Si es una declaración struct, formatearla correctamente
    if (trimmedText.startsWith('struct ')) {
      // Si contiene llaves, es una definición completa de struct
      if (trimmedText.contains('{') && trimmedText.contains('}')) {
        return trimmedText;
      }
      // Si no tiene llaves, puede ser una declaración de variable tipo struct
      return trimmedText;
    }

    // Si es una declaración de puntero (contiene * después de un tipo)
    if (_isPointerDeclaration(trimmedText)) {
      return trimmedText;
    }

    // Si es una declaración de tipo (int, float, char, double, bool)
    if (_isTypeDeclaration(trimmedText)) {
      return trimmedText;
    }

    // Si ya contiene una asignación, usarla directamente
    if (trimmedText.contains('=') && !trimmedText.contains('==')) {
      return trimmedText;
    }

    // Intentar convertir la descripción del proceso a código C
    return trimmedText;
  }

  // Verifica si el texto es una declaración de tipo de dato
  static bool _isTypeDeclaration(String text) {
    final types = [
      'int',
      'float',
      'double',
      'char',
      'bool',
      'void',
      'long',
      'short',
      'unsigned',
      'signed',
      'const'
    ];
    final lowerText = text.toLowerCase().trim();
    for (var type in types) {
      if (lowerText.startsWith('$type ') ||
          lowerText.startsWith('const $type ')) {
        return true;
      }
    }
    return false;
  }

  // Verifica si el texto es una declaración de puntero
  static bool _isPointerDeclaration(String text) {
    // Patrón: tipo *nombre o tipo* nombre
    final pointerPattern = RegExp(
        r'^(const\s+)?(int|float|double|char|void|long|short|unsigned|signed)\s*\*');
    return pointerPattern.hasMatch(text.toLowerCase().trim());
  }

  // Formatea una condición para C
  static String _formatCCondition(String text) {
    // Remover símbolos de interrogación y espacios extra
    String cleanText = text.replaceAll('¿', '').replaceAll('?', '').trim();

    // Si ya contiene operadores de comparación, usarla directamente
    if (cleanText.contains('==') ||
        cleanText.contains('>') ||
        cleanText.contains('<') ||
        cleanText.contains('>=') ||
        cleanText.contains('<=') ||
        cleanText.contains('!=')) {
      return cleanText;
    }

    // Intentar inferir la condición
    if (cleanText.contains(' mayor que ')) {
      return cleanText.replaceAll(' mayor que ', ' > ');
    } else if (cleanText.contains(' menor que ')) {
      return cleanText.replaceAll(' menor que ', ' < ');
    } else if (cleanText.contains(' igual a ')) {
      return cleanText.replaceAll(' igual a ', ' == ');
    }

    // Si no se puede inferir, usar el texto como está
    return cleanText;
  }

  // Formatea una declaración de entrada para C
  static String _formatCInputStatement(String text) {
    String trimmedText = text.trim();

    // Si ya es una sentencia scanf completa, devolverla tal cual
    if (trimmedText.startsWith('scanf(') && trimmedText.contains(')')) {
      // Remover el punto y coma final si existe para evitar duplicación
      if (trimmedText.endsWith(';')) {
        return trimmedText.substring(0, trimmedText.length - 1);
      }
      return trimmedText;
    }

    // Extraer el nombre de la variable del texto
    String varName = _extractVariableNameFromInput(trimmedText);
    String dataType = _detectDataType(trimmedText);

    // Si el texto contiene una asignación o especificación de variable
    if (text.contains('=')) {
      varName = text.split('=')[0].trim();
      // Limpiar el nombre de la variable de palabras clave
      varName = _cleanVariableName(varName);
    }

    // Generar código según el tipo de dato
    switch (dataType) {
      case 'float':
        return "printf(\"Ingrese $varName: \"); scanf(\"%f\", &$varName)";
      case 'char':
        return "printf(\"Ingrese $varName: \"); scanf(\" %c\", &$varName)";
      case 'string':
        return "printf(\"Ingrese $varName: \"); scanf(\"%s\", $varName)";
      case 'int':
      default:
        return "printf(\"Ingrese $varName: \"); scanf(\"%d\", &$varName)";
    }
  }

  // Extrae el nombre de la variable de un texto de entrada
  static String _extractVariableNameFromInput(String text) {
    String lowerText = text.toLowerCase();

    // Patrones comunes: "Leer variable", "Ingresar variable", "Input variable"
    final patterns = [
      RegExp(r'leer\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'ingresar\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'input\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'scanf.*&([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    // Si no se encuentra patrón, intentar extraer la última palabra que parezca variable
    final words = text.split(RegExp(r'[\s,]+'));
    for (int i = words.length - 1; i >= 0; i--) {
      final word = words[i].trim();
      if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(word) &&
          !_isKeyword(word.toLowerCase())) {
        return word;
      }
    }

    return 'var';
  }

  // Detecta el tipo de dato del texto de entrada
  static String _detectDataType(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains('flotante') ||
        lowerText.contains('float') ||
        lowerText.contains('decimal') ||
        lowerText.contains('real')) {
      return 'float';
    } else if (lowerText.contains('caracter') ||
        lowerText.contains('char') ||
        lowerText.contains('carácter')) {
      return 'char';
    } else if (lowerText.contains('cadena') ||
        lowerText.contains('string') ||
        lowerText.contains('texto')) {
      return 'string';
    }
    return 'int';
  }

  // Verifica si una palabra es una palabra clave a ignorar
  static bool _isKeyword(String word) {
    const keywords = [
      'leer',
      'ingresar',
      'input',
      'entrada',
      'escribir',
      'mostrar',
      'imprimir',
      'print',
      'output',
      'salida',
      'el',
      'la',
      'los',
      'las',
      'un',
      'una',
      'de',
      'del',
      'al',
      'y',
      'o',
      'a'
    ];
    return keywords.contains(word);
  }

  // Limpia el nombre de una variable de palabras clave
  static String _cleanVariableName(String name) {
    final words = name.split(RegExp(r'\s+'));
    for (int i = words.length - 1; i >= 0; i--) {
      final word = words[i].trim();
      if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(word) &&
          !_isKeyword(word.toLowerCase())) {
        return word;
      }
    }
    return name.replaceAll(' ', '_');
  }

  // Formatea una declaración de salida para C
  static String _formatCOutputStatement(String text) {
    String trimmedText = text.trim();

    // Si ya es una sentencia printf completa, devolverla tal cual
    if (trimmedText.startsWith('printf(') && trimmedText.contains(')')) {
      // Remover el punto y coma final si existe para evitar duplicación
      if (trimmedText.endsWith(';')) {
        return trimmedText.substring(0, trimmedText.length - 1);
      }
      return trimmedText;
    }

    // Detectar si el texto contiene una cadena literal entre comillas
    final stringMatch = RegExp(r'"([^"]*)"').firstMatch(trimmedText);
    if (stringMatch != null) {
      final stringContent = stringMatch.group(1)!;
      // Verificar si hay variables adicionales después de la cadena
      final afterString = trimmedText.substring(stringMatch.end).trim();
      if (afterString.isNotEmpty) {
        // Hay variables para mostrar junto con el texto
        final vars = afterString
            .split(RegExp(r'[,\s]+'))
            .where((v) => v.isNotEmpty && !_isKeyword(v.toLowerCase()))
            .toList();
        if (vars.isNotEmpty) {
          final formatSpecifiers = vars.map((v) => '%d').join(' ');
          return "printf(\"$stringContent $formatSpecifiers\\n\", ${vars.join(', ')})";
        }
      }
      return "printf(\"$stringContent\\n\")";
    }

    // Extraer variables del texto de salida
    String varName = _extractVariableNameFromOutput(trimmedText);

    // Si parece una variable sola, la mostramos
    if (_isSimpleVariableName(varName)) {
      return "printf(\"%d\\n\", $varName)";
    }

    // Si no tiene formato especial, lo tratamos como texto a mostrar
    // Pero primero verificamos si no es un comando como "Escribir algo"
    final lowerText = trimmedText.toLowerCase();
    if (lowerText.startsWith('escribir ') ||
        lowerText.startsWith('mostrar ') ||
        lowerText.startsWith('imprimir ') ||
        lowerText.startsWith('print ')) {
      // Extraer lo que se debe mostrar
      final content =
          trimmedText.substring(trimmedText.indexOf(' ') + 1).trim();
      if (_isSimpleVariableName(content)) {
        return "printf(\"%d\\n\", $content)";
      } else if (content.startsWith('"') && content.endsWith('"')) {
        return "printf(${content.substring(0, content.length)}\\n\")";
      } else {
        // Es un texto literal
        return "printf(\"$content\\n\")";
      }
    }

    return "printf(\"$trimmedText\\n\")";
  }

  // Extrae el nombre de la variable de un texto de salida
  static String _extractVariableNameFromOutput(String text) {
    String lowerText = text.toLowerCase();

    // Patrones comunes: "Escribir variable", "Mostrar variable", "Print variable"
    final patterns = [
      RegExp(r'escribir\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'mostrar\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'imprimir\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
      RegExp(r'print\s+([a-zA-Z_][a-zA-Z0-9_]*)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    // Si no se encuentra patrón, devolver el texto limpio
    return text;
  }

  // Verifica si el texto parece un nombre de variable simple
  static bool _isSimpleVariableName(String text) {
    final simpleName = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    return simpleName.hasMatch(text.trim());
  }

  // Formatea una llamada a subproceso/función
  static String _formatSubprocessCall(String text) {
    // Si ya tiene el formato correcto de llamada a función, devolverlo tal cual
    if (text.contains('(') && text.contains(')')) {
      // Remover "resultado = " si existe para evitar duplicación
      if (text.startsWith('resultado = ')) {
        return text;
      }
      return text;
    }

    // Si no tiene formato de función, agregarlo
    return "$text()";
  }
}
