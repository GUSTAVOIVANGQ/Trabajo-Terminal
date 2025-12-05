import 'diagram_node.dart';

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    this.isValid = true,
    List<String>? errors,
    List<String>? warnings,
  })  : errors = errors ?? [],
        warnings = warnings ?? [];

  ValidationResult.withError(String error)
      : isValid = false,
        errors = [error],
        warnings = [];

  ValidationResult.withWarning(String warning)
      : isValid = true,
        errors = [],
        warnings = [warning];

  ValidationResult merge(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
    );
  }
}

class DiagramValidator {
  /// Validación principal del diagrama
  static ValidationResult validateDiagram(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    // Resultado inicial válido
    ValidationResult result = ValidationResult();

    // Validar que exista al menos un nodo
    if (nodes.isEmpty) {
      return ValidationResult.withError(
        "El diagrama está vacío. Agrega al menos un nodo de inicio.",
      );
    }

    // Validar presencia de nodo de inicio y fin
    final startNodeValidation = _validateStartNode(nodes);
    final endNodeValidation = _validateEndNode(nodes);

    // Combinar resultados
    result = result.merge(startNodeValidation);
    result = result.merge(endNodeValidation);

    // Validar conexiones
    final connectionValidation = _validateConnections(nodes, connections);
    result = result.merge(connectionValidation);

    // Validar conectores fuera de página
    final connectorValidation = _validateConnectors(nodes);
    result = result.merge(connectorValidation);

    // Validar que no haya nodos sueltos (excepto el nodo final)
    final disconnectedValidation = _validateNoDisconnectedNodes(
      nodes,
      connections,
    );
    result = result.merge(disconnectedValidation);

    return result;
  }

  /// Validar que exista un único nodo de inicio
  static ValidationResult _validateStartNode(List<DiagramNode> nodes) {
    final startNodes =
        nodes.where((node) => node.type == NodeType.start).toList();

    if (startNodes.isEmpty) {
      return ValidationResult.withError(
        "El diagrama debe tener un nodo de inicio.",
      );
    }

    if (startNodes.length > 1) {
      return ValidationResult.withError(
        "El diagrama solo puede tener un nodo de inicio.",
      );
    }

    return ValidationResult();
  }

  /// Validar que exista al menos un nodo de fin
  static ValidationResult _validateEndNode(List<DiagramNode> nodes) {
    final endNodes = nodes.where((node) => node.type == NodeType.end).toList();

    if (endNodes.isEmpty) {
      return ValidationResult.withError(
        "El diagrama debe tener al menos un nodo de fin.",
      );
    }

    return ValidationResult();
  }

  /// Validar conexiones lógicas entre nodos
  static ValidationResult _validateConnections(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    // Validar que el nodo de inicio tenga al menos una salida
    final startNodes =
        nodes.where((node) => node.type == NodeType.start).toList();
    if (startNodes.isNotEmpty) {
      final startNode = startNodes.first;
      final startNodeOutputs =
          connections.where((conn) => conn.source == startNode).toList();

      if (startNodeOutputs.isEmpty) {
        result = result.merge(
          ValidationResult.withError(
            "El nodo de inicio debe tener al menos una conexión de salida.",
          ),
        );
      }
    }

    // Validar que el nodo de fin no tenga salidas
    final endNodes = nodes.where((node) => node.type == NodeType.end).toList();
    for (final endNode in endNodes) {
      final endNodeOutputs =
          connections.where((conn) => conn.source == endNode).toList();

      if (endNodeOutputs.isNotEmpty) {
        result = result.merge(
          ValidationResult.withError(
            "Un nodo de fin no puede tener conexiones de salida.",
          ),
        );
        break;
      }
    }

    // Validar que los nodos de decisión tengan al menos dos salidas
    final decisionNodes =
        nodes.where((node) => node.type == NodeType.decision).toList();
    for (final decisionNode in decisionNodes) {
      final outputs =
          connections.where((conn) => conn.source == decisionNode).toList();

      if (outputs.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo de decisión '${decisionNode.text}' no tiene conexiones de salida.",
          ),
        );
      } else if (outputs.length < 2) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo de decisión '${decisionNode.text}' debe tener al menos dos salidas (verdadero/falso).",
          ),
        );
      }
    }

    // Validar que los nodos de bucle tengan estructura correcta
    final loopNodes =
        nodes.where((node) => node.type == NodeType.loop).toList();
    for (final loopNode in loopNodes) {
      final inputs =
          connections.where((conn) => conn.target == loopNode).toList();
      final outputs =
          connections.where((conn) => conn.source == loopNode).toList();

      if (inputs.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo de bucle '${loopNode.text}' debe tener al menos una conexión de entrada.",
          ),
        );
      }

      if (outputs.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo de bucle '${loopNode.text}' debe tener al menos una conexión de salida.",
          ),
        );
      }

      // Validar que haya una conexión de retorno (bucle)
      bool hasLoopback = false;
      for (final output in outputs) {
        // Buscar si hay un camino de retorno al bucle
        if (_hasPathBack(output.target, loopNode, connections, Set<String>())) {
          hasLoopback = true;
          break;
        }
      }

      if (!hasLoopback && outputs.isNotEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo de bucle '${loopNode.text}' debería tener una conexión de retorno para formar un ciclo.",
          ),
        );
      }
    }

    return result;
  }

  /// Validar conectores fuera de página
  static ValidationResult _validateConnectors(List<DiagramNode> nodes) {
    ValidationResult result = ValidationResult();

    // Obtener todos los nodos de tipo conector
    final connectorNodes =
        nodes.where((node) => node.type == NodeType.connector).toList();

    if (connectorNodes.isEmpty) {
      return result; // No hay conectores, no hay nada que validar
    }

    // Crear un mapa de etiquetas de conectores
    Map<String, List<DiagramNode>> connectorsByLabel = {};

    for (final connector in connectorNodes) {
      String label = _extractConnectorLabel(connector.text);

      if (label.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector en la posición (${connector.position.dx.toInt()}, ${connector.position.dy.toInt()}) no tiene etiqueta.",
          ),
        );
        continue;
      }

      if (!connectorsByLabel.containsKey(label)) {
        connectorsByLabel[label] = [];
      }
      connectorsByLabel[label]!.add(connector);
    }

    // Validar que cada etiqueta tenga al menos dos conectores (entrada y salida)
    for (final entry in connectorsByLabel.entries) {
      final label = entry.key;
      final connectorsWithLabel = entry.value;

      if (connectorsWithLabel.length == 1) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector '$label' solo aparece una vez. Debería tener al menos un conector de entrada y uno de salida.",
          ),
        );
      } else if (connectorsWithLabel.length > 2) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector '$label' aparece ${connectorsWithLabel.length} veces. Se recomienda tener solo 2 (entrada y salida).",
          ),
        );
      }

      // Verificar que haya al menos un conector de entrada y uno de salida
      bool hasEntry = connectorsWithLabel
          .any((c) => c.text.contains('←') || c.text.contains('DESDE'));
      bool hasExit = connectorsWithLabel
          .any((c) => c.text.contains('→') || c.text.contains('HACIA'));

      if (!hasEntry && !hasExit && connectorsWithLabel.length == 2) {
        // Si no tienen marcadores específicos pero son dos, es aceptable
        continue;
      }

      if (connectorsWithLabel.length >= 2 && !hasEntry) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector '$label' no tiene un punto de entrada (←) definido.",
          ),
        );
      }

      if (connectorsWithLabel.length >= 2 && !hasExit) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector '$label' no tiene un punto de salida (→) definido.",
          ),
        );
      }
    }

    return result;
  }

  /// Extraer la etiqueta de un conector (sin los símbolos de dirección)
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

  /// Validar que no haya nodos desconectados (excepto posiblemente el de inicio)
  static ValidationResult _validateNoDisconnectedNodes(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    for (final node in nodes) {
      // Ignorar el nodo de inicio y los comentarios en esta validación
      if (node.type == NodeType.start || node.type == NodeType.comment) {
        continue;
      }

      // Verificar si el nodo tiene conexiones entrantes
      final incomingConnections =
          connections.where((conn) => conn.target == node).toList();

      // Verificar si el nodo tiene conexiones salientes (excepto para los nodos de fin)
      final outgoingConnections =
          connections.where((conn) => conn.source == node).toList();

      if (incomingConnections.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo '${node.text.isEmpty ? _getNodeTypeName(node.type) : node.text}' no tiene conexiones entrantes.",
          ),
        );
      }

      if (outgoingConnections.isEmpty && node.type != NodeType.end) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo '${node.text.isEmpty ? _getNodeTypeName(node.type) : node.text}' no tiene conexiones salientes.",
          ),
        );
      }
    }

    return result;
  }

  static String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.start:
        return 'Inicio';
      case NodeType.end:
        return 'Fin';
      case NodeType.process:
        return 'Proceso';
      case NodeType.decision:
        return 'Decisión';
      case NodeType.input:
        return 'Entrada';
      case NodeType.output:
        return 'Salida';
      case NodeType.variable:
        return 'Variable';
      case NodeType.loop:
        return 'Preparación/Inicialización';
      case NodeType.connector:
        return 'Conector';
      case NodeType.comment:
        return 'Comentario';
      case NodeType.subprocess:
        return 'Subproceso/Función';
    }
  }

  /// Método auxiliar para verificar si hay un camino de retorno al nodo de bucle
  static bool _hasPathBack(
    DiagramNode currentNode,
    DiagramNode targetLoopNode,
    List<Connection> connections,
    Set<String> visited,
  ) {
    // Evitar ciclos infinitos en la búsqueda
    if (visited.contains(currentNode.id)) {
      return false;
    }
    visited.add(currentNode.id);

    // Si llegamos de vuelta al nodo de bucle, hemos encontrado un camino de retorno
    if (currentNode.id == targetLoopNode.id) {
      return true;
    }

    // Buscar en los nodos conectados
    final outConnections =
        connections.where((conn) => conn.source == currentNode).toList();

    for (final connection in outConnections) {
      if (_hasPathBack(
          connection.target, targetLoopNode, connections, Set.from(visited))) {
        return true;
      }
    }

    return false;
  }
}
