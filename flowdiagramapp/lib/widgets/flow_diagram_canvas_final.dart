import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../themes/app_themes.dart';
import '../services/theme_service.dart';
import 'dart:math' as math;

extension OffsetExtensions on Offset {
  Offset normalize() {
    final length = math.sqrt(dx * dx + dy * dy);
    return length == 0 ? Offset.zero : Offset(dx / length, dy / length);
  }
}

class FlowDiagramCanvas extends StatefulWidget {
  final List<DiagramNode> nodes;
  final List<Connection> connections;
  final DiagramNode? selectedNode;
  final Offset panOffset;
  final double scale;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(ScaleUpdateDetails) onScaleUpdate;
  final Function(DiagramNode?) onNodeTap;
  final Function(DiagramNode) onNodeLongPress;
  final Function(DiagramNode, Offset) onNodeDragUpdate;
  final Function(Connection)? onConnectionTap;
  final GlobalKey? canvasKey; // Nuevo parámetro para exportación

  const FlowDiagramCanvas({
    super.key,
    required this.nodes,
    required this.connections,
    this.selectedNode,
    required this.panOffset,
    required this.scale,
    required this.onPanUpdate,
    required this.onScaleUpdate,
    required this.onNodeTap,
    required this.onNodeLongPress,
    required this.onNodeDragUpdate,
    this.onConnectionTap,
    this.canvasKey, // Agregar el parámetro
  });

  @override
  State<FlowDiagramCanvas> createState() => _FlowDiagramCanvasState();
}

class _FlowDiagramCanvasState extends State<FlowDiagramCanvas>
    with TickerProviderStateMixin {
  DiagramNode? draggingNode;
  Offset? dragStart;
  Offset? nodeDragStart;
  Offset? currentDragPosition;
  bool isLongPressing = false;
  bool isSnappingEnabled = false;
  bool isDragging = false;

  // Para optimizar el rendimiento del canvas
  late AnimationController _dragController;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  Offset _applySnapping(Offset position) {
    final snappedX = (position.dx / FlowDiagramPainter.gridSize).round() *
        FlowDiagramPainter.gridSize;
    final snappedY = (position.dy / FlowDiagramPainter.gridSize).round() *
        FlowDiagramPainter.gridSize;
    return Offset(snappedX, snappedY);
  }

  DiagramNode? _findNodeAtPosition(Offset position) {
    // Convertimos la posición del tap a coordenadas del canvas teniendo en cuenta el desplazamiento y la escala
    final localPosition = position - widget.panOffset;
    final scaledPosition = Offset(
      localPosition.dx / widget.scale,
      localPosition.dy / widget.scale,
    );

    print('Buscando nodo en posición original: $position');
    print(
        'Posición ajustada para buscar: $scaledPosition (con panOffset: ${widget.panOffset}, scale: ${widget.scale})');

    // Revisamos los nodos en orden inverso para que los que están encima (dibujados último) tengan prioridad
    for (int i = widget.nodes.length - 1; i >= 0; i--) {
      final node = widget.nodes[i];

      // Verificar si el punto está dentro del nodo
      if (node.containsPoint(scaledPosition)) {
        print('Nodo encontrado: ${node.type} en posición ${node.position}');
        print(
            'Tamaño del nodo: ${node.size}, Distancia al centro: ${(scaledPosition - (node.position + Offset(node.size.width / 2, node.size.height / 2))).distance}');
        return node;
      }
    }
    print('Ningún nodo encontrado en posición $scaledPosition');
    return null;
  }

  Connection? _findConnectionAtPosition(Offset position) {
    final localPosition = position - widget.panOffset;
    final scaledPosition = Offset(
      localPosition.dx / widget.scale,
      localPosition.dy / widget.scale,
    );

    const double hitDistance = 10.0;

    for (final connection in widget.connections) {
      final points = connection.getConnectionPoints();
      if (points.length < 2) continue;

      final start = points[0];
      final end = points[1];

      final distance = _distanceToLine(scaledPosition, start, end);

      if (distance < hitDistance) {
        return connection;
      }
    }

    return null;
  }

  double _distanceToLine(Offset point, Offset lineStart, Offset lineEnd) {
    final double lineLength = (lineEnd - lineStart).distance;
    if (lineLength == 0) return double.infinity;

    final double t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
            (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) /
        (lineLength * lineLength);

    if (t < 0) return (point - lineStart).distance;
    if (t > 1) return (point - lineEnd).distance;

    final projection = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy),
    );

    return (point - projection).distance;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Detectar toques simples (tap down) para almacenar el punto de inicio
      onTapDown: (details) {
        // Almacenar el punto donde se tocó
        setState(() {
          dragStart = details.localPosition;
          isDragging = false; // Resetear la bandera de arrastre
        });

        // Verificamos inmediatamente si hay un nodo en esta posición
        // para proporcionar retroalimentación instantánea
        final node = _findNodeAtPosition(details.localPosition);
        if (node != null) {
          print('TapDown en nodo: ${node.type}');
        }
      },

      onScaleStart: (details) {
        print('onScaleStart en ${details.localFocalPoint}');
        final node = _findNodeAtPosition(details.localFocalPoint);

        if (node != null) {
          print('Iniciando arrastre del nodo: ${node.type}');
          setState(() {
            draggingNode = node;
            dragStart = details.localFocalPoint;
            nodeDragStart = node.position;
            currentDragPosition = node.position; // Inicializar posición actual
          });
          // Notificar al padre para seleccionar este nodo inmediatamente
          widget.onNodeTap(node);

          // Iniciar animación para feedback visual
          _dragController.repeat();
        } else {
          setState(() {
            dragStart = details.localFocalPoint;
          });
        }
      },

      onScaleUpdate: (details) {
        // Si el gesto ha movido lo suficiente, considerarlo como un arrastre
        if (dragStart != null &&
            (details.localFocalPoint - dragStart!).distance > 3.0) {
          isDragging = true;
        }

        if (draggingNode != null &&
            dragStart != null &&
            nodeDragStart != null &&
            !isLongPressing) {
          // Si estamos arrastrando un nodo
          final rawDelta = details.localFocalPoint - dragStart!;
          final adjustedDelta = rawDelta / widget.scale;

          // Calcular nueva posición
          final newPosition = nodeDragStart! + adjustedDelta;

          // Actualizar la posición de arrastre temporal para feedback visual
          setState(() {
            currentDragPosition = newPosition;
          });

          // Actualizar posición del nodo de forma más eficiente
          if (mounted) {
            // Usar el AnimationController para suavizar el movimiento
            _dragController.reset();
            _dragController.forward();
          }

          // Notificar al padre del cambio menos frecuentemente para mejor rendimiento
          widget.onNodeDragUpdate(draggingNode!, newPosition);
        } else if (details.scale != 1.0 && !isLongPressing) {
          // Si estamos haciendo zoom
          widget.onScaleUpdate(details);
        } else if (!isLongPressing && details.scale == 1.0) {
          // Si estamos moviendo el canvas (pan)
          widget.onPanUpdate(
            DragUpdateDetails(
              globalPosition: details.localFocalPoint,
              delta: details.focalPointDelta,
            ),
          );
        }
      },

      onScaleEnd: (details) {
        if (draggingNode != null) {
          // Detener la animación
          _dragController.stop();

          // Aplicar la posición final al nodo
          if (currentDragPosition != null) {
            draggingNode!.position = currentDragPosition!;
          }

          // Aplicar ajuste a cuadrícula si está habilitado
          if (isSnappingEnabled && currentDragPosition != null) {
            final snappedPosition = _applySnapping(currentDragPosition!);
            draggingNode!.position = snappedPosition;
            widget.onNodeDragUpdate(draggingNode!, snappedPosition);
          }

          // Guardar referencia al nodo arrastrado
          final dragged = draggingNode;

          setState(() {
            draggingNode = null;
            nodeDragStart = null;
            currentDragPosition = null;
          });

          // Mantener el nodo seleccionado después del arrastre
          widget.onNodeTap(dragged);
        }
      },

      onLongPress: () {
        // Para iniciar conexión entre nodos
        if (dragStart != null) {
          final node = _findNodeAtPosition(dragStart!);
          if (node != null) {
            setState(() {
              isLongPressing = true;
            });
            widget.onNodeLongPress(node);
          }
        }
      },

      onLongPressEnd: (details) {
        setState(() {
          isLongPressing = false;
        });
      },

      onTap: () {
        // Para seleccionar un nodo o conexión, o deseleccionar si se toca en un espacio vacío
        if (!isLongPressing && dragStart != null && !isDragging) {
          // Solo procesamos el tap si no estamos arrastrando
          final node = _findNodeAtPosition(dragStart!);
          print('Tap detectado. Nodo encontrado: ${node?.type}');

          if (node != null) {
            // Si se encontró un nodo, notificar para seleccionar
            widget.onNodeTap(node);
          } else {
            final connection = _findConnectionAtPosition(dragStart!);
            if (connection != null && widget.onConnectionTap != null) {
              widget.onConnectionTap!(connection);
            } else {
              // Si no se tocó un nodo ni una conexión, notificar al padre para deseleccionar
              widget.onNodeTap(null);
              print('Enviando null para deseleccionar');
            }
          }
        }

        // Resetear el estado de arrastre
        setState(() {
          isDragging = false;
        });
      },

      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ClipRect(
          child: RepaintBoundary(
            key: widget.canvasKey,
            child: AnimatedBuilder(
              animation: _dragController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FlowDiagramPainter(
                    nodes: widget.nodes,
                    connections: widget.connections,
                    selectedNode: widget.selectedNode,
                    draggingNode: draggingNode,
                    currentDragPosition: currentDragPosition,
                    panOffset: widget.panOffset,
                    scale: widget.scale,
                    context: context,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class FlowDiagramPainter extends CustomPainter {
  final List<DiagramNode> nodes;
  final List<Connection> connections;
  final DiagramNode? selectedNode;
  final DiagramNode? draggingNode;
  final Offset? currentDragPosition;
  final Offset panOffset;
  final double scale;
  final BuildContext context;

  static const gridSize = 20.0;
  static const arrowSize = 10.0;

  late final Paint gridPaint;
  late final Paint nodeFillPaint;
  late final Paint nodeStrokePaint;
  late final Paint selectedNodePaint;
  late final Paint draggingNodePaint;
  late final Paint connectionPaint;
  late final TextStyle nodeTextStyle;
  late final Map<String, Color> nodeColors;
  late final bool isDarkMode;

  FlowDiagramPainter({
    required this.nodes,
    required this.connections,
    this.selectedNode,
    this.draggingNode,
    this.currentDragPosition,
    required this.panOffset,
    required this.scale,
    required this.context,
  }) {
    // Inicializar colores y paints basados en el tema
    final themeService = ThemeService();
    isDarkMode = themeService.isDarkMode(context);
    nodeColors = AppThemes.getNodeColors(isDarkMode);

    final theme = Theme.of(context);

    gridPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    nodeFillPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;

    nodeStrokePaint = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    selectedNodePaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    draggingNodePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    connectionPaint = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    nodeTextStyle = TextStyle(
      fontSize: 14,
      color: theme.colorScheme.onSurface,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Aplicar transformación para pan y zoom
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(scale);

    // Dibujar cuadrícula
    _drawGrid(canvas, size);

    // Dibujar conexiones
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }

    // Dibujar nodos
    for (final node in nodes) {
      _drawNode(canvas, node);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final width = size.width / scale;
    final height = size.height / scale;

    final startX = (-panOffset.dx / scale / gridSize).floor() * gridSize;
    final startY = (-panOffset.dy / scale / gridSize).floor() * gridSize;

    // Líneas verticales
    for (double x = startX; x <= startX + width; x += gridSize) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + height),
        gridPaint,
      );
    }

    // Líneas horizontales
    for (double y = startY; y <= startY + height; y += gridSize) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + width, y),
        gridPaint,
      );
    }
  }

  void _drawNode(Canvas canvas, DiagramNode node) {
    canvas.save();

    // Si este nodo se está arrastrando, usar la posición temporal
    Offset nodePosition = node.position;
    if (node == draggingNode && currentDragPosition != null) {
      nodePosition = currentDragPosition!;
    }

    canvas.translate(nodePosition.dx, nodePosition.dy);

    // Obtener la forma del nodo según su tipo
    final path = node.getPath();

    // Obtener el color específico del tipo de nodo
    final nodeColor = _getNodeColorByType(node.type);

    // Crear paint personalizado para este nodo
    final nodeFillPaintCustom = Paint()
      ..color = nodeColor.withOpacity(node == draggingNode ? 0.3 : 0.1)
      ..style = PaintingStyle.fill;

    final nodeStrokeCustom = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Dibujar el fondo del nodo con color específico
    canvas.drawPath(path, nodeFillPaintCustom);

    // Dibujar el borde con estilo adecuado según el estado del nodo
    if (node == selectedNode) {
      canvas.drawPath(path, selectedNodePaint);
    } else if (node == draggingNode) {
      // Estilo especial para nodo que se está arrastrando
      final draggingPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawPath(path, draggingPaint);

      // Agregar sombra durante el arrastre
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.save();
      canvas.translate(2, 2);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    } else {
      canvas.drawPath(path, nodeStrokeCustom);
    }

    // Dibujar texto del nodo
    _drawNodeText(canvas, node);

    canvas.restore();
  }

  Color _getNodeColorByType(NodeType type) {
    switch (type) {
      case NodeType.start:
        return nodeColors['start']!;
      case NodeType.end:
        return nodeColors['end']!;
      case NodeType.process:
        return nodeColors['process']!;
      case NodeType.decision:
        return nodeColors['decision']!;
      case NodeType.input:
        return nodeColors['input']!;
      case NodeType.output:
        return nodeColors['output']!;
      case NodeType.variable:
        return nodeColors['variable']!;
    }
  }

  void _drawNodeText(Canvas canvas, DiagramNode node) {
    final textSpan = TextSpan(
      text: node.text,
      style: nodeTextStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: node.size.width - 10);

    final xCenter = (node.size.width - textPainter.width) / 2;
    final yCenter = (node.size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  void _drawConnection(Canvas canvas, Connection connection) {
    final points = connection.getConnectionPoints();
    if (points.length < 2) return;

    final start = points[0];
    final end = points[1];

    // Dibujar la línea
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);
    canvas.drawPath(path, connectionPaint);

    // Dibujar la flecha
    _drawArrow(canvas, start, end);

    // Dibujar la etiqueta si existe
    if (connection.label.isNotEmpty) {
      _drawConnectionLabel(canvas, connection, start, end);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end) {
    final direction = (end - start).normalize();
    final perpendicular = Offset(-direction.dy, direction.dx);

    final arrowBase = end - direction * arrowSize;
    final arrowLeft = arrowBase - perpendicular * arrowSize / 2;
    final arrowRight = arrowBase + perpendicular * arrowSize / 2;

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowLeft.dx, arrowLeft.dy)
      ..lineTo(arrowRight.dx, arrowRight.dy)
      ..close();

    canvas.drawPath(arrowPath, Paint()..color = Colors.black);
  }

  void _drawConnectionLabel(
      Canvas canvas, Connection connection, Offset start, Offset end) {
    final midpoint = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );

    final textSpan = TextSpan(
      text: connection.label,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
        backgroundColor: Color(0xBBFFFFFF),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Desplazamiento pequeño para que no esté directamente sobre la línea
    final offset = Offset(
      midpoint.dx - textPainter.width / 2,
      midpoint.dy - textPainter.height - 5,
    );

    // Dibujar un rectángulo de fondo
    final rect = Rect.fromLTWH(
      offset.dx - 2,
      offset.dy - 2,
      textPainter.width + 4,
      textPainter.height + 4,
    );
    canvas.drawRect(
      rect,
      Paint()..color = Colors.white.withOpacity(0.8),
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(FlowDiagramPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.connections != connections ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.draggingNode != draggingNode ||
        oldDelegate.currentDragPosition != currentDragPosition ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.scale != scale;
  }
}
