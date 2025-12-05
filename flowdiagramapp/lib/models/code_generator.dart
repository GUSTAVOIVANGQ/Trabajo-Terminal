import 'diagram_node.dart';

enum ProgrammingLanguage { c, python, javascript, java, pseudocode }

class CodeGenerator {
  // Convierte el diagrama en código fuente del lenguaje especificado
  static String generateCode(
    List<DiagramNode> nodes,
    List<Connection> connections,
    ProgrammingLanguage language,
  ) {
    // Verificar que exista un nodo de inicio
    final startNodes =
        nodes.where((node) => node.type == NodeType.start).toList();
    if (startNodes.isEmpty) {
      return "// Error: El diagrama debe tener un nodo de inicio";
    }
    final DiagramNode startNode = startNodes.first;

    // Por ahora, solo generamos código C
    if (language == ProgrammingLanguage.c) {
      return _generateCCode(startNode, nodes, connections);
    } else {
      return "// La generación de código para este lenguaje estará disponible próximamente";
    }
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

    // Declarar variables utilizadas en el diagrama
    List<DiagramNode> variableNodes =
        nodes.where((node) => node.type == NodeType.variable).toList();
    if (variableNodes.isNotEmpty) {
      code.writeln("// Declaración de variables");
      for (var node in variableNodes) {
        code.writeln(_formatCVariableDeclaration(node.text));
      }
      code.writeln("");
    }

    // Función principal
    code.writeln("int main() {");

    // Variables para seguimiento
    Map<String, bool> processedNodes = {};

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

    switch (node.type) {
      case NodeType.start:
        // El nodo de inicio no genera código específico
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.end:
        code.writeln("${indent}// Fin del programa");
        break;

      case NodeType.comment:
        // Los comentarios se agregan tal cual al código
        code.writeln("${indent}${node.text}");
        // Los comentarios no generan flujo de control adicional
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.subprocess:
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
        
        // Verificar si este nodo de decisión es parte de un bucle while
        // (tiene una conexión de retorno desde uno de sus descendientes)
        final outConnections =
            connections.where((conn) => conn.source == node).toList();
        
        bool isWhileLoop = false;
        if (outConnections.isNotEmpty) {
          // Verificar si hay un camino que regresa a este nodo
          for (var conn in outConnections) {
            if (_hasReturnPath(conn.target, node, connections, {})) {
              isWhileLoop = true;
              break;
            }
          }
        }
        
        if (isWhileLoop) {
          // Generar un bucle while
          code.writeln("${indent}while (${_formatCCondition(node.text)}) {");
          
          // Procesar el cuerpo del bucle (rama verdadera)
          if (outConnections.isNotEmpty) {
            final trueConnection = outConnections.firstWhere(
              (conn) =>
                  conn.label.toLowerCase().contains('true') ||
                  conn.label.toLowerCase().contains('verdadero') ||
                  conn.label.toLowerCase().contains('sí') ||
                  conn.label.toLowerCase().contains('yes'),
              orElse: () => outConnections.first,
            );
            
            // Procesar el cuerpo del bucle con una copia del estado de procesamiento
            // para permitir la repetición
            final loopProcessedNodes = Map<String, bool>.from(processedNodes);
            loopProcessedNodes[node.id] = false; // Permitir volver a este nodo
            
            _generateCNodeCode(
              trueConnection.target,
              allNodes,
              connections,
              code,
              indent + "    ",
              loopProcessedNodes,
            );
          }
          
          code.writeln("${indent}}");
          
          // Procesar lo que viene después del bucle (rama falsa)
          if (outConnections.length > 1) {
            final falseConnection = outConnections.firstWhere(
              (conn) =>
                  conn.label.toLowerCase().contains('false') ||
                  conn.label.toLowerCase().contains('falso') ||
                  conn.label.toLowerCase().contains('no'),
              orElse: () => outConnections[1],
            );
            
            _generateCNodeCode(
              falseConnection.target,
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

      case NodeType.input:
        code.writeln("${indent}// Entrada: ${node.text}");
        code.writeln("${indent}${_formatCInputStatement(node.text)};");
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.output:
        code.writeln("${indent}// Salida: ${node.text}");
        code.writeln("${indent}${_formatCOutputStatement(node.text)};");
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.variable:
        code.writeln("${indent}// Inicialización de variable: ${node.text}");
        code.writeln("${indent}${_formatCVariableInitialization(node.text)};");
        _processNextNodes(
          node,
          allNodes,
          connections,
          code,
          indent,
          processedNodes,
        );
        break;

      case NodeType.loop:
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

      case NodeType.connector:
        // Los conectores son puntos de referencia para dividir diagramas grandes
        final label = _extractConnectorLabel(node.text);
        
        // Generar una etiqueta goto en C
        if (node.text.contains('←') || node.text.contains('DESDE')) {
          // Conector de entrada - generar una etiqueta
          code.writeln("${indent}// Conector de entrada: $label");
          code.writeln("${indent}connector_$label:");
        } else if (node.text.contains('→') || node.text.contains('HACIA')) {
          // Conector de salida - generar un goto
          code.writeln("${indent}// Conector de salida: $label");
          code.writeln("${indent}goto connector_$label;");
        } else {
          // Conector bidireccional o sin tipo específico
          code.writeln("${indent}// Conector: $label");
          code.writeln("${indent}connector_$label:");
        }
        
        // Procesar nodos siguientes solo si es entrada o bidireccional
        if (node.text.contains('←') || node.text.contains('⇄') || 
            node.text.contains('DESDE') || !node.text.contains('→')) {
          _processNextNodes(
            node,
            allNodes,
            connections,
            code,
            indent,
            processedNodes,
          );
        }
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
    if (node.type != NodeType.decision && node.type != NodeType.loop) {
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
    // Si ya contiene una asignación, usarla directamente
    if (text.contains('=') && !text.contains('==')) {
      return text;
    }

    // Intentar convertir la descripción del proceso a código C
    return text;
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
    String varName = text.trim();

    // Si el texto contiene una asignación o especificación de variable
    if (text.contains('=')) {
      varName = text.split('=')[0].trim();
      return "scanf(\"%d\", &$varName)";
    }

    // Si el texto contiene instrucciones sobre el tipo de variable
    if (text.toLowerCase().contains('entero') ||
        text.toLowerCase().contains('int')) {
      return "printf(\"Ingrese $varName: \"); scanf(\"%d\", &$varName)";
    } else if (text.toLowerCase().contains('flotante') ||
        text.toLowerCase().contains('float') ||
        text.toLowerCase().contains('decimal')) {
      return "printf(\"Ingrese $varName: \"); scanf(\"%f\", &$varName)";
    } else if (text.toLowerCase().contains('caracter') ||
        text.toLowerCase().contains('char')) {
      return "printf(\"Ingrese $varName: \"); scanf(\" %c\", &$varName)";
    } else {
      // Por defecto, asumir entero
      return "printf(\"Ingrese $varName: \"); scanf(\"%d\", &$varName)";
    }
  }

  // Formatea una declaración de salida para C
  static String _formatCOutputStatement(String text) {
    // Si parece una variable sola, la mostramos
    if (_isSimpleVariableName(text)) {
      return "printf(\"%d\\n\", $text)";
    }

    // Si contiene comillas, probablemente sea un mensaje formateado
    if (text.contains('"')) {
      return "printf($text)";
    }

    // Si no tiene formato especial, lo tratamos como texto a mostrar
    return "printf(\"$text\\n\")";
  }

  // Formatea una declaración de variable para C
  static String _formatCVariableDeclaration(String text) {
    if (text.contains('=')) {
      // Ya tiene inicialización, determinar tipo de variable
      String varName = text.split('=')[0].trim();
      String varValue = text.split('=')[1].trim();

      if (varValue.contains('.')) {
        return "float $text";
      } else if (varValue.contains('"') || varValue.contains("'")) {
        if (varValue.length == 3) {
          // 'a' (char con comillas simples)
          return "char $text";
        } else {
          return "char $varName[100] = $varValue";
        }
      } else {
        return "int $text";
      }
    } else if (text.toLowerCase().contains('entero') ||
        text.toLowerCase().contains('int')) {
      String varName =
          text.replaceAll('entero', '').replaceAll('int', '').trim();
      return "int $varName";
    } else if (text.toLowerCase().contains('flotante') ||
        text.toLowerCase().contains('float') ||
        text.toLowerCase().contains('decimal')) {
      String varName = text
          .replaceAll('flotante', '')
          .replaceAll('float', '')
          .replaceAll('decimal', '')
          .trim();
      return "float $varName";
    } else if (text.toLowerCase().contains('caracter') ||
        text.toLowerCase().contains('char')) {
      String varName =
          text.replaceAll('caracter', '').replaceAll('char', '').trim();
      return "char $varName";
    } else {
      // Por defecto, int
      return "int $text";
    }
  }

  // Formatea una inicialización de variable para C
  static String _formatCVariableInitialization(String text) {
    // Si ya contiene una asignación, usarla directamente
    if (text.contains('=')) {
      // Verificar si ya está correctamente declarada con tipo
      if (text.contains('int') ||
          text.contains('float') ||
          text.contains('double') ||
          text.contains('char')) {
        return text;
      }

      return text;
    }

    // Si no tiene asignación, asignar un valor predeterminado según contexto
    return "$text = 0";
  }

  // Verifica si el texto parece un nombre de variable simple
  static bool _isSimpleVariableName(String text) {
    final simpleName = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
    return simpleName.hasMatch(text.trim());
  }

  // Extrae la etiqueta de un conector (sin símbolos de dirección)
  static String _extractConnectorLabel(String text) {
    return text
        .replaceAll('←', '')
        .replaceAll('→', '')
        .replaceAll('⇄', '')
        .replaceAll('DESDE:', '')
        .replaceAll('HACIA:', '')
        .replaceAll('TO:', '')
        .replaceAll('FROM:', '')
        .replaceAll('CONECTOR:', '')
        .trim();
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
