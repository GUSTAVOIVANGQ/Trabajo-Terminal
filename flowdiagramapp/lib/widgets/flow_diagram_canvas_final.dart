import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../themes/app_themes.dart';
import '../services/theme_service.dart';
import 'dart:math' as math;

enum _ConnectionDirection { top, bottom, left, right }

_ConnectionDirection _getFaceDirection(Offset point, DiagramNode node) {
  const double epsilon = 5.0; // Increased tolerance
  if ((point.dy - node.position.dy).abs() < epsilon)
    return _ConnectionDirection.top;
  if ((point.dy - (node.position.dy + node.size.height)).abs() < epsilon)
    return _ConnectionDirection.bottom;
  if ((point.dx - node.position.dx).abs() < epsilon)
    return _ConnectionDirection.left;
  if ((point.dx - (node.position.dx + node.size.width)).abs() < epsilon)
    return _ConnectionDirection.right;
  return _ConnectionDirection.bottom;
}

List<Offset> _getOrthogonalRoute(
    Offset start, Offset end, DiagramNode source, DiagramNode target,
    {int seed = 0}) {
  final startDir = _getFaceDirection(start, source);
  final endDir = _getFaceDirection(end, target);

  final points = <Offset>[];

  // Aplicar un pequeño desplazamiento determinista basado en la semilla
  // para evitar que líneas superpuestas se dibujen exactamente una sobre otra
  // Se usa un rango aproximado de -10 a +10
  final double offset = ((seed * 13) % 41 - 20) * 0.5;

  final midX = (start.dx + end.dx) / 2 + offset;
  final midY = (start.dy + end.dy) / 2 + offset;

  // Case 1: Vertical -> Vertical
  if ((startDir == _ConnectionDirection.top ||
          startDir == _ConnectionDirection.bottom) &&
      (endDir == _ConnectionDirection.top ||
          endDir == _ConnectionDirection.bottom)) {
    points.add(Offset(start.dx, midY));
    points.add(Offset(end.dx, midY));
  }
  // Case 2: Horizontal -> Horizontal
  else if ((startDir == _ConnectionDirection.left ||
          startDir == _ConnectionDirection.right) &&
      (endDir == _ConnectionDirection.left ||
          endDir == _ConnectionDirection.right)) {
    points.add(Offset(midX, start.dy));
    points.add(Offset(midX, end.dy));
  }
  // Case 3: Vertical -> Horizontal
  else if (startDir == _ConnectionDirection.top ||
      startDir == _ConnectionDirection.bottom) {
    points.add(Offset(start.dx, end.dy));
  }
  // Case 4: Horizontal -> Vertical
  else {
    points.add(Offset(end.dx, start.dy));
  }

  points.add(end);
  return points;
}

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
  final Function(ScaleStartDetails)? onScaleStart;
  final Function(ScaleUpdateDetails) onScaleUpdate;
  final Function(DiagramNode?) onNodeTap;
  final Function(DiagramNode) onNodeLongPress;
  final Function(DiagramNode, Offset) onNodeDragUpdate;
  final ValueChanged<bool>? onNodeDragEnd;
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
    this.onScaleStart,
    required this.onScaleUpdate,
    required this.onNodeTap,
    required this.onNodeLongPress,
    required this.onNodeDragUpdate,
    this.onNodeDragEnd,
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

      // Si es una flecha cuadrada (loop-back), verificar todos los segmentos
      if (connection.isLoopBack) {
        final offset = 40.0;
        final midY = (start.dy + end.dy) / 2;

        // Crear los puntos del camino cuadrado
        final point1 = Offset(start.dx - offset, start.dy);
        final point2 = Offset(start.dx - offset, midY);
        final point3 = Offset(end.dx - offset, midY);
        final point4 = Offset(end.dx - offset, end.dy);

        // Verificar cada segmento del camino cuadrado
        final segments = [
          [start, point1],
          [point1, point2],
          [point2, point3],
          [point3, point4],
          [point4, end],
        ];

        for (final segment in segments) {
          final distance =
              _distanceToLine(scaledPosition, segment[0], segment[1]);
          if (distance < hitDistance) {
            return connection;
          }
        }
      } else {
        // Usar la ruta ortogonal para verificar la colisión en cada segmento
        // Usamos una combinación de los IDs de los nodos para la semilla
        final seed =
            connection.source.id.hashCode ^ connection.target.id.hashCode;
        final route = _getOrthogonalRoute(
            start, end, connection.source, connection.target,
            seed: seed);

        Offset currentStart = start;
        bool hit = false;

        for (final nextPoint in route) {
          final distance =
              _distanceToLine(scaledPosition, currentStart, nextPoint);
          if (distance < hitDistance) {
            hit = true;
            break;
          }
          currentStart = nextPoint;
        }

        if (hit) return connection;
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
          // Notificar al padre que inicia un gesto de escala/pan (no sobre un nodo)
          widget.onScaleStart?.call(details);
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
          final bool didMove = currentDragPosition != null &&
              nodeDragStart != null &&
              (currentDragPosition! - nodeDragStart!).distance > 0.5;

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

          // Notificar al padre para registrar historial al terminar el arrastre
          widget.onNodeDragEnd?.call(didMove);
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
  final BuildContext? context;
  final ThemeData? themeOverride;
  final bool? isDarkModeOverride;

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
    this.context,
    this.themeOverride,
    this.isDarkModeOverride,
  }) {
    // Inicializar colores y paints basados en el tema
    final theme = themeOverride ??
        (context != null ? Theme.of(context!) : ThemeData.light());

    if (isDarkModeOverride != null) {
      isDarkMode = isDarkModeOverride!;
    } else if (context != null) {
      final themeService = ThemeService();
      isDarkMode = themeService.isDarkMode(context!);
    } else {
      isDarkMode = theme.brightness == Brightness.dark;
    }

    nodeColors = AppThemes.getNodeColors(isDarkMode);

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

  /// Draws a dashed path for annotation/comment symbols per ISO 5807
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      const dashLength = 5.0;
      const gapLength = 5.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
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

    // Check if this node uses dashed stroke (annotation/comment symbols)
    final usesDashed = node.usesDashedStroke;

    // Dibujar el borde con estilo adecuado según el estado del nodo
    if (node == selectedNode) {
      if (usesDashed) {
        _drawDashedPath(canvas, path, selectedNodePaint);
      } else {
        canvas.drawPath(path, selectedNodePaint);
      }
    } else if (node == draggingNode) {
      // Estilo especial para nodo que se está arrastrando
      final draggingPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      if (usesDashed) {
        _drawDashedPath(canvas, path, draggingPaint);
      } else {
        canvas.drawPath(path, draggingPaint);
      }

      // Agregar sombra durante el arrastre
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.save();
      canvas.translate(2, 2);
      if (usesDashed) {
        _drawDashedPath(canvas, path, shadowPaint);
      } else {
        canvas.drawPath(path, shadowPaint);
      }
      canvas.restore();
    } else {
      if (usesDashed) {
        _drawDashedPath(canvas, path, nodeStrokeCustom);
      } else {
        canvas.drawPath(path, nodeStrokeCustom);
      }
    }

    // Dibujar texto del nodo
    _drawNodeText(canvas, node);

    canvas.restore();
  }

  Color _getNodeColorByType(NodeType type) {
    switch (type) {
      case NodeType.terminal:
        return nodeColors['terminal']!;
      case NodeType.process:
        return nodeColors['process']!;
      case NodeType.decision:
        return nodeColors['decision']!;
      case NodeType.data:
        return nodeColors['data']!;
      case NodeType.preparation:
        return nodeColors['preparation'] ?? nodeColors['loop'] ?? Colors.orange;
      case NodeType.predefinedProcess:
        return nodeColors['predefinedProcess'] ??
            nodeColors['subprocess'] ??
            Colors.purple;
      default:
        // ISO 5807 symbols - return a color based on category
        return _getISOSymbolColor(type);
    }
  }

  Color _getISOSymbolColor(NodeType type) {
    switch (type.isoCategory) {
      case 'Data':
        return Colors.blue.shade400;
      case 'Process':
        return Colors.green.shade400;
      case 'Special':
        return Colors.amber.shade400;
      default:
        return Colors.grey;
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

    // Variable para almacenar el penúltimo punto (para calcular la dirección de la flecha)
    Offset penultimatePoint = start;

    // Si es una conexión de retorno de bucle, dibujar en forma cuadrada
    if (connection.isLoopBack) {
      // Calcular puntos intermedios para forma cuadrada
      final offset = 40.0; // Desplazamiento hacia la izquierda
      final midY = (start.dy + end.dy) / 2;

      // Punto 1: desplazarse hacia la izquierda desde el inicio
      final point1 = Offset(start.dx - offset, start.dy);
      // Punto 2: bajar hasta la mitad
      final point2 = Offset(start.dx - offset, midY);
      // Punto 3: subir hasta la mitad
      final point3 = Offset(end.dx - offset, midY);
      // Punto 4: ir hacia el final
      final point4 = Offset(end.dx - offset, end.dy);

      path.lineTo(point1.dx, point1.dy);
      path.lineTo(point2.dx, point2.dy);
      path.lineTo(point3.dx, point3.dy);
      path.lineTo(point4.dx, point4.dy);
      path.lineTo(end.dx, end.dy);

      // El penúltimo punto es point4 (antes de llegar a end)
      penultimatePoint = point4;
    } else {
      // Usar ruta ortogonal para conexiones normales
      final seed =
          connection.source.id.hashCode ^ connection.target.id.hashCode;
      final route = _getOrthogonalRoute(
          start, end, connection.source, connection.target,
          seed: seed);

      for (final p in route) {
        path.lineTo(p.dx, p.dy);
      }

      if (route.isNotEmpty) {
        if (route.length > 1) {
          penultimatePoint = route[route.length - 2];
        } else {
          penultimatePoint = start;
        }
      } else {
        path.lineTo(end.dx, end.dy);
      }
    }

    canvas.drawPath(path, connectionPaint);

    // Dibujar la flecha con la dirección correcta
    _drawArrow(canvas, penultimatePoint, end);

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
    // Calcular el punto medio según el tipo de conexión
    Offset midpoint;

    if (connection.isLoopBack) {
      // Para flechas cuadradas, colocar la etiqueta en el lado izquierdo (parte vertical)
      final offset = 40.0;
      final midY = (start.dy + end.dy) / 2;
      midpoint = Offset(start.dx - offset, midY);
    } else {
      // Para flechas rectas, usar el punto medio normal
      midpoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
    }

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
    // Para flechas cuadradas, colocar a la izquierda de la línea vertical
    final offset = connection.isLoopBack
        ? Offset(
            midpoint.dx -
                textPainter.width -
                8, // A la izquierda de la línea vertical
            midpoint.dy - textPainter.height / 2,
          )
        : Offset(
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
