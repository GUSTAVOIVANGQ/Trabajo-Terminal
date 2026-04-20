import 'package:flutter/material.dart';

/// ISO 5807 Node Types for Flowchart Symbols
/// Organized by categories according to ISO 5807 standard
enum NodeType {
  // ============================================
  // BASIC SYMBOLS (Original - with C code generation)
  // ============================================
  terminal, // Terminal (Oval) - Start/End
  process, // Process (Rectangle) - General processing
  decision, // Decision (Diamond/Rhombus) - Conditional branching
  preparation, // Preparation (Hexagon) - Loop initialization (formerly 'loop')
  data, // Data (Parallelogram) - Input/Output
  predefinedProcess, // Predefined Process (Rectangle with double vertical lines) - Subroutine (formerly 'subprocess')

  // ============================================
  // DATA SYMBOLS (ISO 5807) - No C code generation
  // ============================================
  storedData, // Stored Data - Rectangle with curved base
  internalStorage, // Internal Storage - Rectangle with internal grid lines
  sequentialStorage, // Sequential Access Storage - Magnetic tape (circle with tail)
  directStorage, // Direct Access Storage - Cylinder (Database)
  document, // Document - Rectangle with wavy bottom
  manualInput, // Manual Input - Parallelogram with sloped top
  card, // Card - Rectangle with cut corner
  punchedTape, // Punched Tape - Wavy rectangle
  display, // Display - Bullet shape (screen)

  // ============================================
  // PROCESS SYMBOLS (ISO 5807) - No C code generation
  // ============================================
  manualOperation, // Manual Operation - Trapezoid
  parallelMode, // Parallel Mode - Double horizontal bars
  loopLimit, // Loop Limit - Chamfered rectangle (start/end of loop)
  collate, // Collate - Circle with diagonal cross (X)
  summingJunction, // Summing Junction - Circle with vertical/horizontal cross (+)

  // ============================================
  // SPECIAL SYMBOLS (ISO 5807) - No C code generation
  // ============================================
  connector, // On-page Connector - Circle
  offPageConnector, // Off-page Connector - Pentagon (pointing down)
  annotation, // Annotation - Open bracket
  comment, // Comment/Annotation area - Dashed rectangle
}

/// Extension to provide metadata about each NodeType
extension NodeTypeExtension on NodeType {
  /// Returns true if this node type supports C code generation
  bool get hasCodeGeneration {
    switch (this) {
      case NodeType.terminal:
      case NodeType.process:
      case NodeType.decision:
      case NodeType.preparation:
      case NodeType.data:
      case NodeType.predefinedProcess:
        return true;
      default:
        return false;
    }
  }

  /// Returns the ISO 5807 category for this node type
  String get isoCategory {
    switch (this) {
      case NodeType.terminal:
        return 'Basic';
      case NodeType.process:
      case NodeType.predefinedProcess:
      case NodeType.manualOperation:
      case NodeType.preparation:
      case NodeType.decision:
      case NodeType.parallelMode:
      case NodeType.loopLimit:
      case NodeType.collate:
      case NodeType.summingJunction:
        return 'Process';
      case NodeType.data:
      case NodeType.storedData:
      case NodeType.internalStorage:
      case NodeType.sequentialStorage:
      case NodeType.directStorage:
      case NodeType.document:
      case NodeType.manualInput:
      case NodeType.card:
      case NodeType.punchedTape:
      case NodeType.display:
        return 'Data';
      case NodeType.connector:
      case NodeType.offPageConnector:
      case NodeType.annotation:
      case NodeType.comment:
        return 'Special';
    }
  }

  /// Returns the English name according to ISO 5807
  String get isoName {
    switch (this) {
      case NodeType.terminal:
        return 'Terminal';
      case NodeType.process:
        return 'Process';
      case NodeType.decision:
        return 'Decision';
      case NodeType.preparation:
        return 'Preparation';
      case NodeType.data:
        return 'Data';
      case NodeType.predefinedProcess:
        return 'Predefined Process';
      case NodeType.storedData:
        return 'Stored Data';
      case NodeType.internalStorage:
        return 'Internal Storage';
      case NodeType.sequentialStorage:
        return 'Sequential Access Storage';
      case NodeType.directStorage:
        return 'Direct Access Storage';
      case NodeType.document:
        return 'Document';
      case NodeType.manualInput:
        return 'Manual Input';
      case NodeType.card:
        return 'Card';
      case NodeType.punchedTape:
        return 'Punched Tape';
      case NodeType.display:
        return 'Display';
      case NodeType.manualOperation:
        return 'Manual Operation';
      case NodeType.parallelMode:
        return 'Parallel Mode';
      case NodeType.loopLimit:
        return 'Loop Limit';
      case NodeType.collate:
        return 'Collate';
      case NodeType.summingJunction:
        return 'Summing Junction';
      case NodeType.connector:
        return 'Connector';
      case NodeType.offPageConnector:
        return 'Off-page Connector';
      case NodeType.annotation:
        return 'Annotation';
      case NodeType.comment:
        return 'Comment';
    }
  }

  /// Returns the Spanish description of the symbol shape
  String get shapeDescription {
    switch (this) {
      case NodeType.terminal:
        return 'Óvalo';
      case NodeType.process:
        return 'Rectángulo';
      case NodeType.decision:
        return 'Rombo';
      case NodeType.preparation:
        return 'Hexágono';
      case NodeType.data:
        return 'Paralelogramo';
      case NodeType.predefinedProcess:
        return 'Rectángulo con doble borde';
      case NodeType.storedData:
        return 'Rectángulo con base curva';
      case NodeType.internalStorage:
        return 'Rectángulo con líneas internas';
      case NodeType.sequentialStorage:
        return 'Cinta magnética';
      case NodeType.directStorage:
        return 'Cilindro';
      case NodeType.document:
        return 'Rectángulo con borde ondulado';
      case NodeType.manualInput:
        return 'Paralelogramo inclinado';
      case NodeType.card:
        return 'Rectángulo con esquina cortada';
      case NodeType.punchedTape:
        return 'Rectángulo ondulado';
      case NodeType.display:
        return 'Forma de pantalla';
      case NodeType.manualOperation:
        return 'Trapecio';
      case NodeType.parallelMode:
        return 'Barras horizontales';
      case NodeType.loopLimit:
        return 'Rectángulo con esquinas recortadas';
      case NodeType.collate:
        return 'Círculo con cruz diagonal (X)';
      case NodeType.summingJunction:
        return 'Círculo con cruz (+)';
      case NodeType.connector:
        return 'Círculo';
      case NodeType.offPageConnector:
        return 'Pentágono';
      case NodeType.annotation:
        return 'Llave / corchete';
      case NodeType.comment:
        return 'Rectángulo discontinuo';
    }
  }
}

class DiagramNode {
  final String id;
  final NodeType type;
  Offset position;
  String text;
  final Map<String, dynamic>
      metadata; // Metadata para estructuras de control y transpilador

  // Dimensiones del nodo (varían según el tipo)
  Size get size {
    switch (type) {
      // Basic symbols
      case NodeType.terminal:
        return const Size(120, 60);
      case NodeType.decision:
        return const Size(140, 100);
      case NodeType.preparation:
        return const Size(160, 90);
      case NodeType.predefinedProcess:
        return const Size(160, 80);
      case NodeType.process:
      case NodeType.data:
        return const Size(160, 80);

      // Data symbols
      case NodeType.storedData:
        return const Size(140, 70);
      case NodeType.internalStorage:
        return const Size(120, 80);
      case NodeType.sequentialStorage:
        return const Size(100, 80);
      case NodeType.directStorage:
        return const Size(120, 80);
      case NodeType.document:
        return const Size(140, 80);
      case NodeType.manualInput:
        return const Size(140, 70);
      case NodeType.card:
        return const Size(140, 80);
      case NodeType.punchedTape:
        return const Size(140, 80);
      case NodeType.display:
        return const Size(140, 70);

      // Process symbols
      case NodeType.manualOperation:
        return const Size(140, 70);
      case NodeType.parallelMode:
        return const Size(160, 40);
      case NodeType.loopLimit:
        return const Size(140, 70);
      case NodeType.collate:
        return const Size(70, 70);
      case NodeType.summingJunction:
        return const Size(70, 70);

      // Special symbols
      case NodeType.connector:
        return const Size(60, 60);
      case NodeType.offPageConnector:
        return const Size(80, 80);
      case NodeType.annotation:
        return const Size(120, 80);
      case NodeType.comment:
        return const Size(160, 80);
    }
  }

  DiagramNode({
    required this.id,
    required this.type,
    required this.position,
    this.text = '',
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  /// Crea una copia del nodo con los campos especificados modificados
  DiagramNode copyWith({
    String? id,
    NodeType? type,
    Offset? position,
    String? text,
    Map<String, dynamic>? metadata,
  }) {
    return DiagramNode(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      text: text ?? this.text,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  /// Actualiza metadata sin crear una copia completa del nodo
  void updateMetadata(String key, dynamic value) {
    metadata[key] = value;
  }

  /// Obtiene un valor de metadata con valor por defecto
  T getMetadata<T>(String key, T defaultValue) {
    return (metadata[key] as T?) ?? defaultValue;
  }

  /// Verifica si el nodo tiene un metadata específico
  bool hasMetadata(String key) {
    return metadata.containsKey(key);
  }

  /// Obtener la forma del nodo según su tipo (ISO 5807)
  Path getPath() {
    final Path path = Path();

    switch (type) {
      // ============================================
      // BASIC SYMBOLS
      // ============================================
      case NodeType.terminal:
        // Óvalo para terminal (inicio/fin)
        path.addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height,
          ),
        );
        break;

      case NodeType.process:
        // Rectángulo para proceso
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;

      case NodeType.decision:
        // Rombo para decisión
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;

      case NodeType.preparation:
        // Hexágono para preparación/inicialización de bucle
        final double offset = size.width * 0.15;
        path.moveTo(offset, 0);
        path.lineTo(size.width - offset, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - offset, size.height);
        path.lineTo(offset, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;

      case NodeType.data:
        // Paralelogramo para datos (entrada/salida)
        final double offset = size.width * 0.15;
        path.moveTo(offset, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width - offset, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;

      case NodeType.predefinedProcess:
        // Rectángulo con dos líneas verticales en los laterales
        final double lineOffset = 12.0;
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        path.moveTo(lineOffset, 0);
        path.lineTo(lineOffset, size.height);
        path.moveTo(size.width - lineOffset, 0);
        path.lineTo(size.width - lineOffset, size.height);
        break;

      // ============================================
      // DATA SYMBOLS (ISO 5807)
      // ============================================
      case NodeType.storedData:
        // Rectángulo con lados curvos (stored data)
        final curveDepth = size.width * 0.15;
        path.moveTo(curveDepth, 0);
        path.lineTo(size.width, 0);
        path.quadraticBezierTo(
          size.width - curveDepth,
          size.height / 2,
          size.width,
          size.height,
        );
        path.lineTo(curveDepth, size.height);
        path.quadraticBezierTo(0, size.height / 2, curveDepth, 0);
        break;

      case NodeType.internalStorage:
        // Rectángulo con líneas internas (grid)
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        final double topMargin = size.height * 0.2;
        final double leftMargin = size.width * 0.2;
        path.moveTo(0, topMargin);
        path.lineTo(size.width, topMargin);
        path.moveTo(leftMargin, 0);
        path.lineTo(leftMargin, size.height);
        break;

      case NodeType.sequentialStorage:
        // Cinta magnética (círculo con cola) - Sequential Access Storage
        final radius = size.height * 0.35;
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        path.addOval(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
        // Cola de la cinta
        path.moveTo(centerX, centerY + radius);
        path.lineTo(size.width * 0.85, centerY + radius);
        break;

      case NodeType.directStorage:
        // Cilindro (Base de datos) - Direct Access Storage
        final curveHeight = size.height * 0.15;
        // Tapa superior (elipse completa)
        path.addOval(Rect.fromLTWH(0, 0, size.width, curveHeight * 2));
        // Cuerpo del cilindro
        path.moveTo(0, curveHeight);
        path.lineTo(0, size.height - curveHeight);
        // Base inferior (media elipse)
        path.arcToPoint(
          Offset(size.width, size.height - curveHeight),
          radius: Radius.elliptical(size.width / 2, curveHeight),
          clockwise: false,
        );
        path.lineTo(size.width, curveHeight);
        break;

      case NodeType.document:
        // Rectángulo con borde inferior ondulado
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height * 0.85);
        path.quadraticBezierTo(
          size.width * 0.75,
          size.height,
          size.width * 0.5,
          size.height * 0.9,
        );
        path.quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.8,
          0,
          size.height * 0.95,
        );
        path.close();
        break;

      case NodeType.manualInput:
        // Paralelogramo con parte superior inclinada
        path.moveTo(0, size.height * 0.3);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;

      case NodeType.card:
        // Rectángulo con esquina cortada (tarjeta perforada)
        final cut = size.width * 0.15;
        path.moveTo(cut, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.lineTo(0, cut);
        path.close();
        break;

      case NodeType.punchedTape:
        // Rectángulo con bordes ondulados (cinta perforada)
        // Borde superior ondulado
        path.moveTo(0, size.height * 0.1);
        path.quadraticBezierTo(
          size.width * 0.25,
          -size.height * 0.05,
          size.width * 0.5,
          size.height * 0.1,
        );
        path.quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.25,
          size.width,
          size.height * 0.1,
        );
        path.lineTo(size.width, size.height * 0.9);
        // Borde inferior ondulado
        path.quadraticBezierTo(
          size.width * 0.75,
          size.height * 1.05,
          size.width * 0.5,
          size.height * 0.9,
        );
        path.quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.75,
          0,
          size.height * 0.9,
        );
        path.close();
        break;

      case NodeType.display:
        // Forma de pantalla (bullet shape)
        final arrowWidth = size.width * 0.2;
        path.moveTo(arrowWidth, 0);
        path.lineTo(size.width - arrowWidth, 0);
        path.arcToPoint(
          Offset(size.width - arrowWidth, size.height),
          radius: Radius.circular(size.height),
          clockwise: true,
        );
        path.lineTo(arrowWidth, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;

      // ============================================
      // PROCESS SYMBOLS (ISO 5807)
      // ============================================
      case NodeType.manualOperation:
        // Trapecio (operación manual)
        final slope = size.width * 0.15;
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width - slope, size.height);
        path.lineTo(slope, size.height);
        path.close();
        break;

      case NodeType.parallelMode:
        // Barras horizontales paralelas
        final barHeight = size.height * 0.25;
        path.addRect(Rect.fromLTWH(0, 0, size.width, barHeight));
        path.addRect(
            Rect.fromLTWH(0, size.height - barHeight, size.width, barHeight));
        break;

      case NodeType.loopLimit:
        // Rectángulo con esquinas superiores recortadas (inicio/fin de bucle)
        final cut = size.width * 0.12;
        path.moveTo(cut, 0);
        path.lineTo(size.width - cut, 0);
        path.lineTo(size.width, cut);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.lineTo(0, cut);
        path.close();
        break;

      case NodeType.collate:
        // Círculo con cruz diagonal (X) - Collate symbol
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final radius = size.width / 2;
        // Dibujar el círculo
        path.addOval(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        );
        // Dibujar la X diagonal
        final offset = radius * 0.707; // cos(45°) = sin(45°) ≈ 0.707
        path.moveTo(centerX - offset, centerY - offset);
        path.lineTo(centerX + offset, centerY + offset);
        path.moveTo(centerX + offset, centerY - offset);
        path.lineTo(centerX - offset, centerY + offset);
        break;

      case NodeType.summingJunction:
        // Círculo con cruz vertical/horizontal (+) - Summing Junction symbol
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final radius = size.width / 2;
        // Dibujar el círculo
        path.addOval(
          Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        );
        // Dibujar la cruz +
        path.moveTo(centerX, centerY - radius);
        path.lineTo(centerX, centerY + radius);
        path.moveTo(centerX - radius, centerY);
        path.lineTo(centerX + radius, centerY);
        break;

      // ============================================
      // SPECIAL SYMBOLS (ISO 5807)
      // ============================================
      case NodeType.connector:
        // Círculo (conector en la misma página)
        path.addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height,
          ),
        );
        break;

      case NodeType.offPageConnector:
        // Pentágono apuntando hacia abajo (conector fuera de página)
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height * 0.5);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height * 0.5);
        path.close();
        break;

      case NodeType.annotation:
        // Corchete abierto (anotación)
        path.moveTo(size.width * 0.7, 0);
        path.lineTo(size.width * 0.3, 0);
        path.lineTo(size.width * 0.3, size.height);
        path.lineTo(size.width * 0.7, size.height);
        break;

      case NodeType.comment:
        // Rectángulo (el estilo discontinuo se aplica al pintar)
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
    }

    return path;
  }

  /// Returns true if this node uses dashed stroke (for comment/annotation symbols)
  bool get usesDashedStroke {
    return type == NodeType.comment;
  }

  // Verificar si un punto está dentro del nodo
  bool containsPoint(Offset point) {
    // Asegurarse de que el punto está en coordenadas locales al nodo
    final localPoint = point - position;

    // Para detección más precisa, añadimos una verificación simplificada usando un rectángulo
    if (localPoint.dx >= 0 &&
        localPoint.dx <= size.width &&
        localPoint.dy >= 0 &&
        localPoint.dy <= size.height) {
      // Si estamos dentro del rectángulo delimitador, verificamos la forma exacta
      return getPath().contains(localPoint);
    }

    return false;
  }

  // Puntos de conexión para las líneas
  Offset getInputPoint() {
    return Offset(position.dx + size.width / 2, position.dy);
  }

  Offset getOutputPoint() {
    return Offset(position.dx + size.width / 2, position.dy + size.height);
  }

  Offset getLeftPoint() {
    return Offset(position.dx, position.dy + size.height / 2);
  }

  Offset getRightPoint() {
    return Offset(position.dx + size.width, position.dy + size.height / 2);
  }

  // Encontrar el punto más cercano para una conexión
  Offset getNearestConnectionPoint(Offset target) {
    final List<Offset> points = [
      getInputPoint(),
      getOutputPoint(),
      getLeftPoint(),
      getRightPoint(),
    ];

    Offset nearest = points.first;
    double minDistance = (target - nearest).distance;

    for (Offset point in points) {
      final distance = (target - point).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = point;
      }
    }

    return nearest;
  }
}

enum ConnectionAnchor { auto, top, bottom, left, right }

class Connection {
  final DiagramNode source;
  final DiagramNode target;
  String label;
  bool
      isLoopBack; // Indica si esta conexión es un retorno de bucle (puede cambiar)
  ConnectionAnchor sourceAnchor;
  ConnectionAnchor targetAnchor;

  Connection({
    required this.source,
    required this.target,
    this.label = '',
    this.isLoopBack = false,
    this.sourceAnchor = ConnectionAnchor.auto,
    this.targetAnchor = ConnectionAnchor.auto,
  });

  // Calcular los puntos de conexión entre nodos
  List<Offset> getConnectionPoints() {
    final sourceCenter =
        source.position + Offset(source.size.width / 2, source.size.height / 2);
    final targetCenter =
        target.position + Offset(target.size.width / 2, target.size.height / 2);

    final sourcePoint = _getAnchorPoint(source, sourceAnchor, targetCenter);
    final targetPoint = _getAnchorPoint(target, targetAnchor, sourceCenter);

    return [sourcePoint, targetPoint];
  }

  Offset _getAnchorPoint(
      DiagramNode node, ConnectionAnchor anchor, Offset otherCenter) {
    switch (anchor) {
      case ConnectionAnchor.top:
        return node.getInputPoint();
      case ConnectionAnchor.bottom:
        return node.getOutputPoint();
      case ConnectionAnchor.left:
        return node.getLeftPoint();
      case ConnectionAnchor.right:
        return node.getRightPoint();
      case ConnectionAnchor.auto:
        return node.getNearestConnectionPoint(otherCenter);
    }
  }
}
