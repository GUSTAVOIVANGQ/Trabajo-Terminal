import 'diagram_node.dart';

/// ISO 5807 Symbol Connection Rules
/// Defines the structural validation rules for each symbol type
class ISO5807ConnectionRules {
  /// Returns the minimum number of input connections required for a node type
  static int minInputs(NodeType type) {
    switch (type) {
      // Terminal start: no inputs needed
      case NodeType.terminal:
        return 0; // Handled specially - start has 0, end has 1+
      // Connectors: inputs depend on usage
      case NodeType.connector:
      case NodeType.offPageConnector:
        return 0; // Can be entry or exit point
      // Annotations don't participate in flow
      case NodeType.annotation:
      case NodeType.comment:
        return 0;
      // Collate and Summing Junction: need at least 1 input OR output
      case NodeType.collate:
      case NodeType.summingJunction:
        return 0; // Validated separately - needs 1 connection (in or out)
      // All other symbols need at least one input
      default:
        return 1;
    }
  }

  /// Returns the minimum number of output connections required for a node type
  static int minOutputs(NodeType type) {
    switch (type) {
      // Decision needs at least 2 outputs (true/false)
      case NodeType.decision:
        return 2;
      // Parallel mode needs at least 2 outputs
      case NodeType.parallelMode:
        return 2;
      // Loop limit has 2 paths: continue loop or exit
      case NodeType.loopLimit:
        return 2;
      // Terminal end: no outputs
      case NodeType.terminal:
        return 0; // Handled specially - start has 1+, end has 0
      // Connectors: outputs depend on usage
      case NodeType.connector:
      case NodeType.offPageConnector:
        return 0; // Can be entry or exit point
      // Annotations don't participate in flow
      case NodeType.annotation:
      case NodeType.comment:
        return 0;
      // Collate and Summing Junction: need at least 1 input OR output
      case NodeType.collate:
      case NodeType.summingJunction:
        return 0; // Validated separately - needs 1 connection (in or out)
      // All other symbols need at least one output
      default:
        return 1;
    }
  }

  /// Returns true if the node type participates in the main program flow
  static bool participatesInFlow(NodeType type) {
    switch (type) {
      case NodeType.annotation:
      case NodeType.comment:
        return false;
      default:
        return true;
    }
  }

  /// Returns true if the node type can be a standalone element
  static bool canBeStandalone(NodeType type) {
    switch (type) {
      case NodeType.annotation:
      case NodeType.comment:
        return true;
      default:
        return false;
    }
  }

  /// Returns true if the node type is a data storage symbol
  static bool isDataStorageSymbol(NodeType type) {
    switch (type) {
      case NodeType.data:
      case NodeType.storedData:
      case NodeType.internalStorage:
      case NodeType.sequentialStorage:
      case NodeType.directStorage:
      case NodeType.document:
      case NodeType.card:
      case NodeType.punchedTape:
        return true;
      default:
        return false;
    }
  }

  /// Returns true if the node type is an I/O symbol
  static bool isIOSymbol(NodeType type) {
    switch (type) {
      case NodeType.data:
      case NodeType.manualInput:
      case NodeType.display:
        return true;
      default:
        return false;
    }
  }

  /// Returns true if the node type requires at least one connection (input OR output)
  /// These symbols are junction/merge points that need at least one connection
  static bool requiresAtLeastOneConnection(NodeType type) {
    switch (type) {
      case NodeType.collate:
      case NodeType.summingJunction:
        return true;
      default:
        return false;
    }
  }
}

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

    // Validar que no haya nodos sueltos (excepto el nodo final)
    final disconnectedValidation = _validateNoDisconnectedNodes(
      nodes,
      connections,
    );
    result = result.merge(disconnectedValidation);

    // Validar símbolos ISO 5807 específicos
    final iso5807Validation = _validateISO5807Symbols(nodes, connections);
    result = result.merge(iso5807Validation);

    return result;
  }

  /// Validar símbolos ISO 5807 específicos
  static ValidationResult _validateISO5807Symbols(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    for (final node in nodes) {
      // Skip nodes that don't participate in flow (annotations/comments)
      if (!ISO5807ConnectionRules.participatesInFlow(node.type)) {
        continue;
      }

      // Validate connectors
      if (node.type == NodeType.connector ||
          node.type == NodeType.offPageConnector) {
        result = result.merge(_validateConnector(node, nodes, connections));
      }

      // Validate parallel mode
      if (node.type == NodeType.parallelMode) {
        result = result.merge(_validateParallelMode(node, connections));
      }

      // Validate loop limit
      if (node.type == NodeType.loopLimit) {
        result = result.merge(_validateLoopLimit(node, connections));
      }

      // Validate manual operation
      if (node.type == NodeType.manualOperation) {
        result = result.merge(_validateManualOperation(node, connections));
      }

      // Validate predefined process (subproceso)
      if (node.type == NodeType.predefinedProcess) {
        result = result.merge(_validatePredefinedProcess(node, connections));
      }

      // Validate data storage symbols
      if (ISO5807ConnectionRules.isDataStorageSymbol(node.type)) {
        result = result.merge(_validateDataStorage(node, connections));
      }
    }

    return result;
  }

  /// Validate connector nodes (in-page and off-page)
  static ValidationResult _validateConnector(
    DiagramNode connector,
    List<DiagramNode> allNodes,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final inputs = connections.where((c) => c.target == connector).toList();
    final outputs = connections.where((c) => c.source == connector).toList();

    // A connector should either have inputs OR outputs, but typically not both
    // (it's a jump point in the flowchart)
    if (inputs.isEmpty && outputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El conector '${connector.text.isEmpty ? connector.type.isoName : connector.text}' no tiene conexiones. Los conectores deben ser puntos de entrada o salida.",
        ),
      );
    }

    // Check if there's a matching connector with the same label
    if (connector.text.isNotEmpty) {
      final matchingConnectors = allNodes
          .where((n) =>
              (n.type == NodeType.connector ||
                  n.type == NodeType.offPageConnector) &&
              n.id != connector.id &&
              n.text == connector.text)
          .toList();

      if (matchingConnectors.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El conector '${connector.text}' no tiene un conector correspondiente con la misma etiqueta.",
          ),
        );
      }
    } else {
      result = result.merge(
        ValidationResult.withWarning(
          "Se recomienda etiquetar los conectores para identificar su destino.",
        ),
      );
    }

    return result;
  }

  /// Validate parallel mode nodes
  static ValidationResult _validateParallelMode(
    DiagramNode parallelNode,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final outputs = connections.where((c) => c.source == parallelNode).toList();
    final inputs = connections.where((c) => c.target == parallelNode).toList();

    if (outputs.length < 2) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de modo paralelo '${parallelNode.text.isEmpty ? 'Parallel Mode' : parallelNode.text}' debe tener al menos 2 salidas para representar procesos paralelos.",
        ),
      );
    }

    if (inputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de modo paralelo '${parallelNode.text.isEmpty ? 'Parallel Mode' : parallelNode.text}' debe tener al menos una entrada.",
        ),
      );
    }

    return result;
  }

  /// Validate loop limit nodes
  static ValidationResult _validateLoopLimit(
    DiagramNode loopLimitNode,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final outputs =
        connections.where((c) => c.source == loopLimitNode).toList();
    final inputs = connections.where((c) => c.target == loopLimitNode).toList();

    if (outputs.length < 2) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de límite de bucle '${loopLimitNode.text.isEmpty ? 'Loop Limit' : loopLimitNode.text}' debe tener 2 salidas: una para continuar el bucle y otra para salir.",
        ),
      );
    }

    if (inputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de límite de bucle '${loopLimitNode.text.isEmpty ? 'Loop Limit' : loopLimitNode.text}' debe tener al menos una entrada.",
        ),
      );
    }

    return result;
  }

  /// Validate manual operation nodes
  static ValidationResult _validateManualOperation(
    DiagramNode manualOpNode,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final outputs = connections.where((c) => c.source == manualOpNode).toList();
    final inputs = connections.where((c) => c.target == manualOpNode).toList();

    if (inputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de operación manual '${manualOpNode.text.isEmpty ? 'Manual Operation' : manualOpNode.text}' debe tener al menos una entrada.",
        ),
      );
    }

    if (outputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El nodo de operación manual '${manualOpNode.text.isEmpty ? 'Manual Operation' : manualOpNode.text}' debe tener al menos una salida.",
        ),
      );
    }

    return result;
  }

  /// Validate predefined process (subproceso) nodes
  static ValidationResult _validatePredefinedProcess(
    DiagramNode predefinedNode,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final outputs =
        connections.where((c) => c.source == predefinedNode).toList();
    final inputs =
        connections.where((c) => c.target == predefinedNode).toList();

    if (inputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El subproceso '${predefinedNode.text.isEmpty ? 'Predefined Process' : predefinedNode.text}' debe tener al menos una entrada.",
        ),
      );
    }

    if (outputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El subproceso '${predefinedNode.text.isEmpty ? 'Predefined Process' : predefinedNode.text}' debe tener al menos una salida.",
        ),
      );
    }

    if (predefinedNode.text.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "Se recomienda nombrar el subproceso para identificar la función que representa.",
        ),
      );
    }

    return result;
  }

  /// Validate data storage symbols
  static ValidationResult _validateDataStorage(
    DiagramNode dataNode,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    final outputs = connections.where((c) => c.source == dataNode).toList();
    final inputs = connections.where((c) => c.target == dataNode).toList();

    // Data storage can be read-only (just outputs) or write-only (just inputs)
    // but should have at least one connection
    if (inputs.isEmpty && outputs.isEmpty) {
      result = result.merge(
        ValidationResult.withWarning(
          "El símbolo de almacenamiento '${dataNode.text.isEmpty ? dataNode.type.isoName : dataNode.text}' debe tener al menos una conexión de entrada o salida.",
        ),
      );
    }

    return result;
  }

  /// Validar que exista un nodo terminal de inicio
  static ValidationResult _validateStartNode(List<DiagramNode> nodes) {
    final startNodes = nodes
        .where((node) =>
            node.type == NodeType.terminal &&
            (node.text.toLowerCase().contains('inicio') ||
                node.text.toLowerCase().contains('start') ||
                node.text.toLowerCase().contains('comenzar') ||
                node.text.isEmpty))
        .toList();

    if (startNodes.isEmpty) {
      return ValidationResult.withError(
        "El diagrama debe tener un nodo terminal de inicio (con texto 'Inicio', 'Start' o vacío).",
      );
    }

    if (startNodes.length > 1) {
      return ValidationResult.withError(
        "El diagrama solo puede tener un nodo terminal de inicio.",
      );
    }

    return ValidationResult();
  }

  /// Validar que exista al menos un nodo terminal de fin
  static ValidationResult _validateEndNode(List<DiagramNode> nodes) {
    final endNodes = nodes
        .where((node) =>
            node.type == NodeType.terminal &&
            (node.text.toLowerCase().contains('fin') ||
                node.text.toLowerCase().contains('end') ||
                node.text.toLowerCase().contains('terminar')))
        .toList();

    if (endNodes.isEmpty) {
      return ValidationResult.withError(
        "El diagrama debe tener al menos un nodo terminal de fin (con texto 'Fin', 'End' o 'Terminar').",
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

    // Validar que el nodo terminal de inicio tenga al menos una salida
    final startNodes = nodes
        .where((node) =>
            node.type == NodeType.terminal &&
            (node.text.toLowerCase().contains('inicio') ||
                node.text.toLowerCase().contains('start') ||
                node.text.isEmpty))
        .toList();
    if (startNodes.isNotEmpty) {
      final startNode = startNodes.first;
      final startNodeOutputs =
          connections.where((conn) => conn.source == startNode).toList();

      if (startNodeOutputs.isEmpty) {
        result = result.merge(
          ValidationResult.withError(
            "El nodo terminal de inicio debe tener al menos una conexión de salida.",
          ),
        );
      }
    }

    // Validar que los nodos terminales de fin no tengan salidas
    final endNodes = nodes
        .where((node) =>
            node.type == NodeType.terminal &&
            (node.text.toLowerCase().contains('fin') ||
                node.text.toLowerCase().contains('end') ||
                node.text.toLowerCase().contains('terminar')))
        .toList();
    for (final endNode in endNodes) {
      final endNodeOutputs =
          connections.where((conn) => conn.source == endNode).toList();

      if (endNodeOutputs.isNotEmpty) {
        result = result.merge(
          ValidationResult.withError(
            "Un nodo terminal de fin no puede tener conexiones de salida.",
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

    // Validar que los nodos de preparación tengan estructura correcta
    final loopNodes =
        nodes.where((node) => node.type == NodeType.preparation).toList();
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

  /// Validar que no haya nodos desconectados (excepto posiblemente el de inicio)
  static ValidationResult _validateNoDisconnectedNodes(
    List<DiagramNode> nodes,
    List<Connection> connections,
  ) {
    ValidationResult result = ValidationResult();

    for (final node in nodes) {
      // Skip nodes that don't participate in flow (annotations, comments)
      if (!ISO5807ConnectionRules.participatesInFlow(node.type)) {
        continue;
      }

      // Skip connectors as they have special validation rules
      if (node.type == NodeType.connector ||
          node.type == NodeType.offPageConnector) {
        continue;
      }

      // Verificar si el nodo tiene conexiones entrantes
      final incomingConnections =
          connections.where((conn) => conn.target == node).toList();

      // Verificar si el nodo tiene conexiones salientes (excepto para los nodos de fin)
      final outgoingConnections =
          connections.where((conn) => conn.source == node).toList();

      // Special validation for collate and summing junction: need at least 1 connection (in OR out)
      if (ISO5807ConnectionRules.requiresAtLeastOneConnection(node.type)) {
        if (incomingConnections.isEmpty && outgoingConnections.isEmpty) {
          result = result.merge(
            ValidationResult.withWarning(
              "El nodo '${node.text.isEmpty ? _getNodeTypeName(node.type) : node.text}' (${node.type.isoName}) debe tener al menos una conexión entrante o saliente.",
            ),
          );
        }
        continue; // Skip regular validation for these types
      }

      // Ignorar los nodos terminales de inicio en esta validación
      if (node.type == NodeType.terminal &&
          (node.text.toLowerCase().contains('inicio') ||
              node.text.toLowerCase().contains('start') ||
              node.text.isEmpty)) {
        continue;
      }

      if (incomingConnections.isEmpty) {
        result = result.merge(
          ValidationResult.withWarning(
            "El nodo '${node.text.isEmpty ? _getNodeTypeName(node.type) : node.text}' no tiene conexiones entrantes.",
          ),
        );
      }

      // Los nodos terminales de fin no requieren conexiones salientes
      final isEndTerminal = node.type == NodeType.terminal &&
          (node.text.toLowerCase().contains('fin') ||
              node.text.toLowerCase().contains('end') ||
              node.text.toLowerCase().contains('terminar'));

      // Data storage symbols might only have inputs (write) or outputs (read)
      final isDataStorage =
          ISO5807ConnectionRules.isDataStorageSymbol(node.type);

      if (outgoingConnections.isEmpty && !isEndTerminal && !isDataStorage) {
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
      case NodeType.terminal:
        return 'Terminal';
      case NodeType.process:
        return 'Proceso';
      case NodeType.decision:
        return 'Decisión';
      case NodeType.data:
        return 'Dato';
      case NodeType.preparation:
        return 'Preparación/Inicialización';
      case NodeType.predefinedProcess:
        return 'Subproceso/Función';
      case NodeType.collate:
        return 'Collate (Intercalar)';
      case NodeType.summingJunction:
        return 'Summing Junction (Unión)';
      default:
        return type.isoName;
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
