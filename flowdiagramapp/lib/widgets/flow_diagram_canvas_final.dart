import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Ruta ortogonal. Si [midOffset] no es null, se usa como posición absoluta
/// del segmento del medio (reemplazando el cálculo automático).
List<Offset> _getOrthogonalRoute(
    Offset start, Offset end, DiagramNode source, DiagramNode target,
    {int seed = 0, double? midOffset}) {
  final startDir = _getFaceDirection(start, source);
  final endDir = _getFaceDirection(end, target);

  final points = <Offset>[];

  // Desplazamiento determinista anti-solapamiento (solo si no hay midOffset manual)
  final double autoShift = ((seed * 13) % 41 - 20) * 0.5;

  // Case 1: Vertical -> Vertical  →  segmento horizontal en midY
  if ((startDir == _ConnectionDirection.top ||
          startDir == _ConnectionDirection.bottom) &&
      (endDir == _ConnectionDirection.top ||
          endDir == _ConnectionDirection.bottom)) {
    final midY = midOffset ?? ((start.dy + end.dy) / 2 + autoShift);
    points.add(Offset(start.dx, midY));
    points.add(Offset(end.dx, midY));
  }
  // Case 2: Horizontal -> Horizontal  →  segmento vertical en midX
  else if ((startDir == _ConnectionDirection.left ||
          startDir == _ConnectionDirection.right) &&
      (endDir == _ConnectionDirection.left ||
          endDir == _ConnectionDirection.right)) {
    final midX = midOffset ?? ((start.dx + end.dx) / 2 + autoShift);
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

/// Devuelve qué tipo de segmento medio tiene la ruta (vertical/horizontal/ninguno).
_MidSegmentKind _getMidSegmentKind(
    Offset start, Offset end, DiagramNode source, DiagramNode target) {
  final startDir = _getFaceDirection(start, source);
  final endDir = _getFaceDirection(end, target);
  if ((startDir == _ConnectionDirection.top ||
          startDir == _ConnectionDirection.bottom) &&
      (endDir == _ConnectionDirection.top ||
          endDir == _ConnectionDirection.bottom)) {
    return _MidSegmentKind.horizontal; // se mueve en Y
  }
  if ((startDir == _ConnectionDirection.left ||
          startDir == _ConnectionDirection.right) &&
      (endDir == _ConnectionDirection.left ||
          endDir == _ConnectionDirection.right)) {
    return _MidSegmentKind.vertical; // se mueve en X
  }
  return _MidSegmentKind.none;
}

enum _MidSegmentKind { horizontal, vertical, none }
enum _HandleType { source, mid, target }

class _HandleHit {
  final Connection connection;
  final _HandleType type;
  _HandleHit(this.connection, this.type);
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
  final Connection? selectedConnection;
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
  final Function(Connection)? onConnectionLongPress;
  final Function(DiagramNode, String)? onConnectionPointTap;
  // Called when the user drags a connection endpoint to a new node.
  // Parameters: connection, newNode, isSource (true = source endpoint moved)
  final Function(Connection, DiagramNode, bool)? onEndpointReconnect;
  final GlobalKey? canvasKey;

  const FlowDiagramCanvas({
    super.key,
    required this.nodes,
    required this.connections,
    this.selectedNode,
    this.selectedConnection,
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
    this.onConnectionLongPress,
    this.onConnectionPointTap,
    this.onEndpointReconnect,
    this.canvasKey,
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

  // ── Handle drag de segmento medio de flecha ──
  Connection? _draggingHandleConnection;
  _HandleType? _draggingHandleType;
  bool _isDraggingHandle = false;
  double _handleDragStartValue = 0.0; // valor al inicio del drag

  // ── Endpoint handle drag (reconexión de extremos de flecha) ──
  Connection? _draggingEndpointConnection;
  bool _isDraggingSourceEndpoint = false; // true = source, false = target
  bool _isDraggingEndpoint = false;
  Offset? _endpointDragCurrentPos; // posición actual del extremo mientras se arrastra
  DiagramNode? _endpointHoveredNode; // nodo iluminado bajo el cursor
  String? _endpointHoveredAnchor; // punto de anclaje más cercano en el nodo iluminado
  Offset? _endpointLongPressStart; // posición de inicio del long press sobre el endpoint

  // ── Resize handle drag (redimensionar nodo) ──
  DiagramNode? _resizingNode;
  String? _resizeCorner; // 'topLeft','topRight','bottomLeft','bottomRight'
  bool _isDraggingResize = false;
  Offset? _resizeDragStart;
  Offset? _resizeNodeStartPos;
  Size? _resizeNodeStartSize;
  static const double _minNodeWidth  = 50.0;
  static const double _minNodeHeight = 30.0;
  static const double _resizeHandleRadius = 8.0;
  static const double _resizeHandleHitRadius = 18.0;

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

  // Radio visual de los puntos de conexión
  static const double _connectionPointRadius = 7.0;
  // Radio de hit-test ampliado para facilitar el toque en móvil
  static const double _connectionPointHitRadius = 18.0;

  Offset _applySnapping(Offset position) {
    final snappedX = (position.dx / FlowDiagramPainter.gridSize).round() *
        FlowDiagramPainter.gridSize;
    final snappedY = (position.dy / FlowDiagramPainter.gridSize).round() *
        FlowDiagramPainter.gridSize;
    return Offset(snappedX, snappedY);
  }

  /// Detecta si [position] (pantalla) toca uno de los 4 handles de esquina del nodo seleccionado.
  /// Devuelve la esquina: 'topLeft','topRight','bottomLeft','bottomRight' o null.
  String? _findResizeHandleAtPosition(Offset position) {
    final sel = widget.selectedNode;
    if (sel == null) return null;

    final localPos  = position - widget.panOffset;
    final scaledPos = Offset(localPos.dx / widget.scale, localPos.dy / widget.scale);
    final hitR = _resizeHandleHitRadius / widget.scale;

    final corners = <String, Offset>{
      'topLeft'     : sel.position,
      'topRight'    : sel.position + Offset(sel.size.width, 0),
      'bottomLeft'  : sel.position + Offset(0, sel.size.height),
      'bottomRight' : sel.position + Offset(sel.size.width, sel.size.height),
    };

    for (final entry in corners.entries) {
      if ((scaledPos - entry.value).distance <= hitR) return entry.key;
    }
    return null;
  }

  /// Detecta si el toque fue sobre uno de los 4 puntos de conexión del nodo seleccionado.
  /// Retorna la dirección ('top', 'bottom', 'left', 'right') o null si no fue en un punto.
  String? _findConnectionPointAtPosition(Offset position) {
    final selectedNode = widget.selectedNode;
    if (selectedNode == null) return null;

    final localPosition = position - widget.panOffset;
    final scaledPosition = Offset(
      localPosition.dx / widget.scale,
      localPosition.dy / widget.scale,
    );

    // Los 4 puntos de conexión con su dirección
    final Map<String, Offset> connectionPoints = {
      'top': selectedNode.getInputPoint(),
      'bottom': selectedNode.getOutputPoint(),
      'left': selectedNode.getLeftPoint(),
      'right': selectedNode.getRightPoint(),
    };

    // Ajustar el radio de hit-test según la escala actual
    final adjustedHitRadius = _connectionPointHitRadius / widget.scale;

    for (final entry in connectionPoints.entries) {
      final distance = (scaledPosition - entry.value).distance;
      if (distance <= adjustedHitRadius) {
        return entry.key;
      }
    }

    return null;
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
        // Usar la ruta ortogonal con midPointOffset si existe
        final seed =
            connection.source.id.hashCode ^ connection.target.id.hashCode;
        final route = _getOrthogonalRoute(
            start, end, connection.source, connection.target,
            seed: seed, midOffset: connection.midPointOffset);

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

  /// Detecta si [position] (pantalla) está sobre el handle de la conexión seleccionada.
  /// Devuelve la conexión si hay hit, o null.
  _HandleHit? _findHandleAtPosition(Offset position) {
    final sel = widget.selectedConnection;
    if (sel == null || sel.isLoopBack) return null;

    final localPos = position - widget.panOffset;
    final scaledPos =
        Offset(localPos.dx / widget.scale, localPos.dy / widget.scale);

    final pts = sel.getConnectionPoints();
    if (pts.length < 2) return null;
    final start = pts[0];
    final end = pts[1];

    final seed = sel.source.id.hashCode ^ sel.target.id.hashCode;
    final route = _getOrthogonalRoute(start, end, sel.source, sel.target,
        seed: seed, midOffset: sel.midPointOffset);

    if (route.isEmpty) return null;

    final hitRadius = 28.0 / widget.scale;
    Offset prev = start;

    for (int i = 0; i < route.length; i++) {
      final wp = route[i];
      final len = (wp - prev).distance;
      if (len > 10) {
        final center = (prev + wp) / 2;
        if ((scaledPos - center).distance <= hitRadius) {
          _HandleType type = _HandleType.mid;
          if (i == 0) type = _HandleType.source;
          else if (i == route.length - 1) type = _HandleType.target;
          return _HandleHit(sel, type);
        }
      }
      prev = wp;
    }
    return null;
  }

  // ── Detecta si la posición está sobre el endpoint handle (source o target) ──
  // Devuelve 'source', 'target', o null
  String? _findEndpointHandleAtPosition(Offset position) {
    final sel = widget.selectedConnection;
    if (sel == null) return null;

    final localPos = position - widget.panOffset;
    final scaledPos = Offset(localPos.dx / widget.scale, localPos.dy / widget.scale);

    final pts = sel.getConnectionPoints();
    if (pts.length < 2) return null;

    final hitRadius = 30.0 / widget.scale;

    if ((scaledPos - pts[0]).distance <= hitRadius) return 'source';
    if ((scaledPos - pts[1]).distance <= hitRadius) return 'target';
    return null;
  }

  // ── Encuentra el nodo más cercano a la posición (en coordenadas canvas) ──
  // Excluye los nodos source/target de la conexión que se arrastra
  DiagramNode? _findNearestNodeForEndpoint(Offset canvasPos) {
    final conn = _draggingEndpointConnection;
    DiagramNode? nearest;
    double minDist = 80.0; // umbral máximo en px de canvas

    for (final node in widget.nodes) {
      // Excluir el nodo opuesto para evitar self-loops accidentales
      if (conn != null) {
        if (_isDraggingSourceEndpoint && node == conn.target) continue;
        if (!_isDraggingSourceEndpoint && node == conn.source) continue;
      }
      final center = node.position + Offset(node.size.width / 2, node.size.height / 2);
      final dist = (canvasPos - center).distance;
      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }
    }
    return nearest;
  }

  // ── Convierte posición de pantalla a coordenadas canvas ──
  Offset _screenToCanvas(Offset screenPos) {
    final local = screenPos - widget.panOffset;
    return Offset(local.dx / widget.scale, local.dy / widget.scale);
  }

  // ── Calcula el anchor más cercano al punto en el nodo iluminado ──
  String _nearestAnchorForPoint(DiagramNode node, Offset canvasPos) {
    final points = {
      'top': node.getInputPoint(),
      'bottom': node.getOutputPoint(),
      'left': node.getLeftPoint(),
      'right': node.getRightPoint(),
    };
    String best = 'bottom';
    double minDist = double.infinity;
    for (final e in points.entries) {
      final d = (canvasPos - e.value).distance;
      if (d < minDist) {
        minDist = d;
        best = e.key;
      }
    }
    return best;
  }

  // ── Aplica la reconexión del endpoint al nodo/anchor detectado ──
  void _applyEndpointReconnect() {
    final conn = _draggingEndpointConnection;
    final hovNode = _endpointHoveredNode;
    if (conn == null) return;

    if (hovNode != null && _endpointHoveredAnchor != null) {
      final anchor = _anchorFromString(_endpointHoveredAnchor!);
      setState(() {
        if (_isDraggingSourceEndpoint) {
          // Reconectar source: creamos una nueva conexión con source cambiado
          // No podemos cambiar source (final), así que notificamos al padre
          // Aquí marcamos los campos que sí podemos cambiar
          conn.sourceAnchor = anchor;
          conn.midPointOffset = null;
          conn.sourceOffset = 0.0;
        } else {
          conn.targetAnchor = anchor;
          conn.midPointOffset = null;
          conn.targetOffset = 0.0;
        }
      });
      // Notificar al padre para reconexión completa (cambio de nodo)
      if (_isDraggingSourceEndpoint && hovNode != conn.source) {
        widget.onEndpointReconnect?.call(conn, hovNode, true);
      } else if (!_isDraggingSourceEndpoint && hovNode != conn.target) {
        widget.onEndpointReconnect?.call(conn, hovNode, false);
      }
    }
    // Si no hay nodo, la flecha vuelve al estado original (no cambia nada)

    setState(() {
      _isDraggingEndpoint = false;
      _draggingEndpointConnection = null;
      _endpointDragCurrentPos = null;
      _endpointHoveredNode = null;
      _endpointHoveredAnchor = null;
      _endpointLongPressStart = null;
    });
  }

  ConnectionAnchor _anchorFromString(String s) {
    switch (s) {
      case 'top': return ConnectionAnchor.top;
      case 'bottom': return ConnectionAnchor.bottom;
      case 'left': return ConnectionAnchor.left;
      case 'right': return ConnectionAnchor.right;
      default: return ConnectionAnchor.auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        setState(() {
          dragStart = details.localPosition;
          isDragging = false;
        });

        final node = _findNodeAtPosition(details.localPosition);
        if (node != null) {
          print('TapDown en nodo: ${node.type}');
        }
      },

      onScaleStart: (details) {
        print('onScaleStart en ${details.localFocalPoint}');

        // ── Detectar inicio de drag sobre resize handle de esquina ──
        final resizeCorner = _findResizeHandleAtPosition(details.localFocalPoint);
        if (resizeCorner != null && widget.selectedNode != null) {
          setState(() {
            _resizingNode         = widget.selectedNode;
            _resizeCorner         = resizeCorner;
            _isDraggingResize     = true;
            _resizeDragStart      = details.localFocalPoint;
            _resizeNodeStartPos   = widget.selectedNode!.position;
            _resizeNodeStartSize  = widget.selectedNode!.size;
            dragStart = details.localFocalPoint;
            isDragging = false;
          });
          return;
        }

        // ── Detectar inicio de drag sobre endpoint handle (reconexión) ──
        if (widget.selectedConnection != null) {
          final endpointSide = _findEndpointHandleAtPosition(details.localFocalPoint);
          if (endpointSide != null) {
            HapticFeedback.lightImpact(); // Agregar vibración aquí
            final conn = widget.selectedConnection!;
            final pts = conn.getConnectionPoints();
            setState(() {
              _isDraggingEndpoint = true;
              _draggingEndpointConnection = conn;
              _isDraggingSourceEndpoint = endpointSide == 'source';
              _endpointDragCurrentPos = _isDraggingSourceEndpoint ? pts[0] : pts[1];
              _endpointLongPressStart = details.localFocalPoint;
              dragStart = details.localFocalPoint;
              isDragging = false;
            });
            return;
          }
        }

        // ── Detectar inicio de drag sobre handle de flecha ──
        final hit = _findHandleAtPosition(details.localFocalPoint);
        if (hit != null) {
          final handleConn = hit.connection;
          final pts = handleConn.getConnectionPoints();

          setState(() {
            _draggingHandleConnection = handleConn;
            _draggingHandleType = hit.type;
            _isDraggingHandle = true;
            dragStart = details.localFocalPoint;
            isDragging = false;
            
            if (hit.type == _HandleType.source) {
               _handleDragStartValue = handleConn.sourceOffset;
            } else if (hit.type == _HandleType.target) {
               _handleDragStartValue = handleConn.targetOffset;
            } else {
               final kind = _getMidSegmentKind(pts[0], pts[1], handleConn.source, handleConn.target);
               if (kind == _MidSegmentKind.horizontal) {
                 _handleDragStartValue = handleConn.midPointOffset ?? ((pts[0].dy + pts[1].dy) / 2);
               } else {
                 _handleDragStartValue = handleConn.midPointOffset ?? ((pts[0].dx + pts[1].dx) / 2);
               }
            }
          });
          return; // No procesar como nodo drag ni pan
        }
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

        // ── Drag de resize de nodo ──
        if (_isDraggingResize && _resizingNode != null && _resizeDragStart != null) {
          final rawDelta    = details.localFocalPoint - _resizeDragStart!;
          final delta       = rawDelta / widget.scale;
          final startPos    = _resizeNodeStartPos!;
          final startSize   = _resizeNodeStartSize!;

          double newX = startPos.dx;
          double newY = startPos.dy;
          double newW = startSize.width;
          double newH = startSize.height;

          switch (_resizeCorner!) {
            case 'topLeft':
              newX = startPos.dx + delta.dx;
              newY = startPos.dy + delta.dy;
              newW = startSize.width  - delta.dx;
              newH = startSize.height - delta.dy;
              break;
            case 'topRight':
              newY = startPos.dy + delta.dy;
              newW = startSize.width  + delta.dx;
              newH = startSize.height - delta.dy;
              break;
            case 'bottomLeft':
              newX = startPos.dx + delta.dx;
              newW = startSize.width  - delta.dx;
              newH = startSize.height + delta.dy;
              break;
            case 'bottomRight':
              newW = startSize.width  + delta.dx;
              newH = startSize.height + delta.dy;
              break;
          }

          // Aplicar mínimos
          if (newW < _minNodeWidth) {
            if (_resizeCorner == 'topLeft' || _resizeCorner == 'bottomLeft') {
              newX = startPos.dx + startSize.width - _minNodeWidth;
            }
            newW = _minNodeWidth;
          }
          if (newH < _minNodeHeight) {
            if (_resizeCorner == 'topLeft' || _resizeCorner == 'topRight') {
              newY = startPos.dy + startSize.height - _minNodeHeight;
            }
            newH = _minNodeHeight;
          }

          setState(() {
            _resizingNode!.position = Offset(newX, newY);
            _resizingNode!.metadata['customWidth']  = newW;
            _resizingNode!.metadata['customHeight'] = newH;
          });
          return;
        }

        // ── Drag de endpoint de flecha (reconexión) ──
        if (_isDraggingEndpoint && _draggingEndpointConnection != null) {
          final canvasPos = _screenToCanvas(details.localFocalPoint);
          final hovNode = _findNearestNodeForEndpoint(canvasPos);
          setState(() {
            _endpointDragCurrentPos = canvasPos;
            _endpointHoveredNode = hovNode;
            _endpointHoveredAnchor = hovNode != null
                ? _nearestAnchorForPoint(hovNode, canvasPos)
                : null;
          });
          return;
        }

        // ── Drag de handle de segmento medio ──
        if (_isDraggingHandle &&
            _draggingHandleConnection != null &&
            _draggingHandleType != null &&
            dragStart != null) {
          final conn = _draggingHandleConnection!;
          final pts = conn.getConnectionPoints();
          final start = pts[0];
          final end = pts[1];
          final startDir = _getFaceDirection(start, conn.source);
          final endDir = _getFaceDirection(end, conn.target);

          final rawDelta = details.localFocalPoint - dragStart!;
          final adjustedDelta = rawDelta / widget.scale;

          setState(() {
            if (_draggingHandleType == _HandleType.source) {
              if (startDir == _ConnectionDirection.top || startDir == _ConnectionDirection.bottom) {
                 conn.sourceOffset = _handleDragStartValue + adjustedDelta.dx;
              } else {
                 conn.sourceOffset = _handleDragStartValue + adjustedDelta.dy;
              }
            } else if (_draggingHandleType == _HandleType.target) {
              if (endDir == _ConnectionDirection.top || endDir == _ConnectionDirection.bottom) {
                 conn.targetOffset = _handleDragStartValue + adjustedDelta.dx;
              } else {
                 conn.targetOffset = _handleDragStartValue + adjustedDelta.dy;
              }
            } else {
              final kind = _getMidSegmentKind(start, end, conn.source, conn.target);
              if (kind == _MidSegmentKind.horizontal) {
                conn.midPointOffset = _handleDragStartValue + adjustedDelta.dy;
              } else if (kind == _MidSegmentKind.vertical) {
                conn.midPointOffset = _handleDragStartValue + adjustedDelta.dx;
              }
            }
          });
          return;
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
        // ── Fin drag de resize ──
        if (_isDraggingResize) {
          setState(() {
            _isDraggingResize    = false;
            _resizingNode        = null;
            _resizeCorner        = null;
            _resizeDragStart     = null;
            _resizeNodeStartPos  = null;
            _resizeNodeStartSize = null;
          });
          widget.onNodeDragEnd?.call(true); // registrar en historial
          return;
        }

        // ── Fin drag de endpoint ──
        if (_isDraggingEndpoint) {
          _applyEndpointReconnect();
          return;
        }

        // ── Fin drag de handle ──
        if (_isDraggingHandle) {
          setState(() {
            _isDraggingHandle = false;
            _draggingHandleConnection = null;
            _draggingHandleType = null;
          });
          return;
        }

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
          } else {
            // Long-press sobre conexión → abrir opciones avanzadas
            final conn = _findConnectionAtPosition(dragStart!);
            if (conn != null) {
              widget.onConnectionLongPress?.call(conn);
            }
          }
        }
      },

      onLongPressEnd: (details) {
        setState(() {
          isLongPressing = false;
        });
      },

      onTap: () {
        // Seleccionar nodo / conexión sin abrir diálogo
        if (!isLongPressing && dragStart != null && !isDragging) {
          // 1. Punto de conexión del nodo seleccionado
          final connectionPointDir = _findConnectionPointAtPosition(dragStart!);
          if (connectionPointDir != null && widget.selectedNode != null) {
            print('Punto de conexión tocado: $connectionPointDir');
            widget.onConnectionPointTap
                ?.call(widget.selectedNode!, connectionPointDir);
            setState(() {
              isDragging = false;
            });
            return;
          }

          // 2. Nodo
          final node = _findNodeAtPosition(dragStart!);
          print('Tap detectado. Nodo encontrado: ${node?.type}');

          if (node != null) {
            widget.onNodeTap(node);
          } else {
            // 3. Conexión: solo seleccionar, sin diálogo
            final connection = _findConnectionAtPosition(dragStart!);
            if (connection != null && widget.onConnectionTap != null) {
              widget.onConnectionTap!(connection);
            } else {
              // 4. Área vacía: deseleccionar todo
              widget.onNodeTap(null);
              print('Enviando null para deseleccionar');
            }
          }
        }

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
                    selectedConnection: widget.selectedConnection,
                    draggingHandleConnection:
                        _isDraggingHandle ? _draggingHandleConnection : null,
                    draggingHandleType:
                        _isDraggingHandle ? _draggingHandleType : null,
                    draggingNode: draggingNode,
                    currentDragPosition: currentDragPosition,
                    panOffset: widget.panOffset,
                    scale: widget.scale,
                    context: context,
                    // Endpoint drag state
                    isDraggingEndpoint: _isDraggingEndpoint,
                    draggingEndpointConnection: _isDraggingEndpoint ? _draggingEndpointConnection : null,
                    isDraggingSourceEndpoint: _isDraggingSourceEndpoint,
                    endpointDragCurrentPos: _endpointDragCurrentPos,
                    endpointHoveredNode: _endpointHoveredNode,
                    endpointHoveredAnchor: _endpointHoveredAnchor,
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
  final Connection? selectedConnection;
  final Connection? draggingHandleConnection;
  final _HandleType? draggingHandleType;
  final DiagramNode? draggingNode;
  final Offset? currentDragPosition;
  final Offset panOffset;
  final double scale;
  final BuildContext? context;
  final ThemeData? themeOverride;
  final bool? isDarkModeOverride;

  // Endpoint drag state
  final bool isDraggingEndpoint;
  final Connection? draggingEndpointConnection;
  final bool isDraggingSourceEndpoint;
  final Offset? endpointDragCurrentPos;
  final DiagramNode? endpointHoveredNode;
  final String? endpointHoveredAnchor;

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
    this.selectedConnection,
    this.draggingHandleConnection,
    this.draggingHandleType,
    this.draggingNode,
    this.currentDragPosition,
    required this.panOffset,
    required this.scale,
    this.context,
    this.themeOverride,
    this.isDarkModeOverride,
    // Endpoint drag
    this.isDraggingEndpoint = false,
    this.draggingEndpointConnection,
    this.isDraggingSourceEndpoint = false,
    this.endpointDragCurrentPos,
    this.endpointHoveredNode,
    this.endpointHoveredAnchor,
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

    // ── Overlay de endpoint drag ──
    if (isDraggingEndpoint && draggingEndpointConnection != null && endpointDragCurrentPos != null) {
      _drawEndpointDragOverlay(canvas);
    }

    canvas.restore();
  }

  // ── Dibuja el overlay completo durante el drag de un endpoint ──
  void _drawEndpointDragOverlay(Canvas canvas) {
    final conn = draggingEndpointConnection!;
    final dragPos = endpointDragCurrentPos!;
    final pts = conn.getConnectionPoints();

    final Color blue = isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    final fixedPoint = isDraggingSourceEndpoint ? pts[1] : pts[0];

    // Línea fantasma desde el punto fijo al punto de drag
    final ghostPaint = Paint()
      ..color = blue.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final ghostPath = Path();
    ghostPath.moveTo(fixedPoint.dx, fixedPoint.dy);
    ghostPath.lineTo(dragPos.dx, dragPos.dy);
    canvas.drawPath(ghostPath, ghostPaint);

    // Nodo iluminado con sus puntos de anclaje
    if (endpointHoveredNode != null) {
      _drawHoveredNodeOverlay(canvas, endpointHoveredNode!, blue);
    }

    // Handle animado en la posición de drag
    _drawDraggingEndpointHandle(canvas, dragPos, blue);
  }

  // ── Dibuja el nodo iluminado con sus 4 puntos, el más cercano resaltado ──
  void _drawHoveredNodeOverlay(Canvas canvas, DiagramNode node, Color blue) {
    const double margin = 8.0;

    final overlayPaint = Paint()
      ..color = blue.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = blue.withOpacity(0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        node.position.dx - margin,
        node.position.dy - margin,
        node.size.width + margin * 2,
        node.size.height + margin * 2,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, overlayPaint);
    canvas.drawRRect(rect, borderPaint);

    final points = {
      'top': node.getInputPoint(),
      'bottom': node.getOutputPoint(),
      'left': node.getLeftPoint(),
      'right': node.getRightPoint(),
    };

    for (final e in points.entries) {
      final isActive = e.key == endpointHoveredAnchor;
      _drawAnchorPoint(canvas, e.value, blue, isActive);
    }
  }

  // ── Dibuja un punto de anclaje (normal o activo) ──
  void _drawAnchorPoint(Canvas canvas, Offset center, Color blue, bool isActive) {
    const double r = 7.0;
    const double outerR = 12.0;

    if (isActive) {
      canvas.drawCircle(center, outerR,
          Paint()..color = blue.withOpacity(0.30)..style = PaintingStyle.fill);
      canvas.drawCircle(center, r,
          Paint()..color = blue..style = PaintingStyle.fill);
      canvas.drawCircle(center, r,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0);
    } else {
      canvas.drawCircle(center, outerR * 0.7,
          Paint()..color = blue.withOpacity(0.12)..style = PaintingStyle.fill);
      canvas.drawCircle(center, r,
          Paint()
            ..color = (isDarkMode ? const Color(0xFF1E293B) : Colors.white)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(center, r,
          Paint()..color = blue..style = PaintingStyle.stroke..strokeWidth = 2.0);
      canvas.drawCircle(center, 3.0,
          Paint()..color = blue.withOpacity(0.5)..style = PaintingStyle.fill);
    }
  }

  // ── Dibuja el handle del extremo siendo arrastrado ──
  void _drawDraggingEndpointHandle(Canvas canvas, Offset pos, Color blue) {
    canvas.drawCircle(
      pos + const Offset(1, 1), 10.0,
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(pos, 9.0,
        Paint()..color = blue..style = PaintingStyle.fill);
    canvas.drawCircle(pos, 9.0,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0);
    // Cruz interior
    final lp = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(pos + const Offset(-4, 0), pos + const Offset(4, 0), lp);
    canvas.drawLine(pos + const Offset(0, -4), pos + const Offset(0, 4), lp);
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
    Color nodeColor = _getNodeColorByType(node.type);
    if (node.metadata['customColor'] != null) {
      nodeColor = Color(node.metadata['customColor'] as int);
    }

    // Crear paint personalizado para este nodo
    final nodeFillPaintCustom = Paint()
      ..color = nodeColor.withOpacity(node == draggingNode ? 0.3 : 0.1)
      ..style = PaintingStyle.fill;

    final nodeStrokeCustom = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // ─── Rectángulo azul de selección (overlay) ───
    if (node == selectedNode) {
      _drawSelectionOverlay(canvas, node);
    }

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

    // ─── Puntos de conexión del nodo seleccionado ───
    if (node == selectedNode) {
      _drawConnectionPoints(canvas, node);
      _drawResizeHandles(canvas, node);
    }

    canvas.restore();
  }

  /// Dibuja un rectángulo redondeado azul semi-transparente alrededor del nodo seleccionado
  void _drawSelectionOverlay(Canvas canvas, DiagramNode node) {
    const double margin = 8.0;
    const double borderRadius = 6.0;

    // Color azul de selección basado en el tema
    final Color selectionColor = isDarkMode
        ? const Color(0xFF3B82F6) // Azul para modo oscuro
        : const Color(0xFF2563EB); // Azul para modo claro

    final selectionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        -margin,
        -margin,
        node.size.width + margin * 2,
        node.size.height + margin * 2,
      ),
      const Radius.circular(borderRadius),
    );

    // Relleno semi-transparente azul
    final fillPaint = Paint()
      ..color = selectionColor.withOpacity(0.10)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(selectionRect, fillPaint);

    // Borde azul semi-transparente con patrón de línea discontinua sutil
    final borderPaint = Paint()
      ..color = selectionColor.withOpacity(0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(selectionRect, borderPaint);
  }

  /// Dibuja los 4 puntos de conexión interactivos (top, bottom, left, right)
  void _drawConnectionPoints(Canvas canvas, DiagramNode node) {
    const double pointRadius = 7.0;
    const double outerRingRadius = 10.0;

    // Color azul del tema
    final Color pointColor = isDarkMode
        ? const Color(0xFF3B82F6)
        : const Color(0xFF2563EB);

    // Los 4 puntos de conexión en coordenadas locales del nodo
    final List<Offset> points = [
      Offset(node.size.width / 2, 0),           // Top
      Offset(node.size.width / 2, node.size.height), // Bottom
      Offset(0, node.size.height / 2),           // Left
      Offset(node.size.width, node.size.height / 2), // Right
    ];

    for (final point in points) {
      // Anillo exterior tenue (amplía área visual de toque)
      final outerRingPaint = Paint()
        ..color = pointColor.withOpacity(0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, outerRingRadius, outerRingPaint);

      // Sombra sutil detrás del punto
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(point + const Offset(0.5, 0.5), pointRadius, shadowPaint);

      // Relleno blanco del punto
      final fillPaint = Paint()
        ..color = isDarkMode ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, pointRadius, fillPaint);

      // Borde azul del punto
      final borderPaint = Paint()
        ..color = pointColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(point, pointRadius, borderPaint);

      // Indicador interno (pequeño círculo azul sólido al centro)
      final innerDotPaint = Paint()
        ..color = pointColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 3.0, innerDotPaint);
    }
  }

  /// Dibuja los 4 handles cuadrados de esquina para redimensionar el nodo seleccionado.
  void _drawResizeHandles(Canvas canvas, DiagramNode node) {
    const double r = 7.0;
    final Color accent = isDarkMode
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);

    // Esquinas en coordenadas locales del nodo (el canvas ya está trasladado)
    final List<Offset> corners = [
      const Offset(0, 0),                                   // topLeft
      Offset(node.size.width, 0),                          // topRight
      Offset(0, node.size.height),                         // bottomLeft
      Offset(node.size.width, node.size.height),           // bottomRight
    ];

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    final fillPaint = Paint()
      ..color = isDarkMode ? const Color(0xFF1E293B) : Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final c in corners) {
      final rect = Rect.fromCenter(center: c, width: r * 2, height: r * 2);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      final shadowRect = RRect.fromRectAndRadius(
        rect.translate(1, 1), const Radius.circular(2));
      canvas.drawRRect(shadowRect, shadowPaint);
      canvas.drawRRect(rRect, fillPaint);
      canvas.drawRRect(rRect, borderPaint);
    }
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

    final isSelected = connection == selectedConnection ||
        connection == draggingHandleConnection;

    // ── Paint de la línea (resaltado azul si seleccionada) ──
    final Color connColor = isSelected
        ? (isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
        : (isDarkMode
            ? Colors.white.withOpacity(0.85)
            : Colors.black.withOpacity(0.85));

    final linePaint = Paint()
      ..color = connColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;

    // Construir la ruta con midPointOffset
    final path = Path();
    path.moveTo(start.dx, start.dy);

    Offset penultimatePoint = start;

    if (connection.isLoopBack) {
      final offset = 40.0;
      final midY = (start.dy + end.dy) / 2;

      final point1 = Offset(start.dx - offset, start.dy);
      final point2 = Offset(start.dx - offset, midY);
      final point3 = Offset(end.dx - offset, midY);
      final point4 = Offset(end.dx - offset, end.dy);

      path.lineTo(point1.dx, point1.dy);
      path.lineTo(point2.dx, point2.dy);
      path.lineTo(point3.dx, point3.dy);
      path.lineTo(point4.dx, point4.dy);
      path.lineTo(end.dx, end.dy);

      penultimatePoint = point4;
    } else {
      final seed =
          connection.source.id.hashCode ^ connection.target.id.hashCode;
      final route = _getOrthogonalRoute(start, end, connection.source,
          connection.target,
          seed: seed, midOffset: connection.midPointOffset);

      for (final p in route) {
        path.lineTo(p.dx, p.dy);
      }

      if (route.isNotEmpty) {
        penultimatePoint =
            route.length > 1 ? route[route.length - 2] : start;
      } else {
        path.lineTo(end.dx, end.dy);
      }
    }

    // ── Sombreado de selección (halo azul semitransparente) ──
    if (isSelected) {
      final haloPaint = Paint()
        ..color = connColor.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, haloPaint);
    }

    canvas.drawPath(path, linePaint);

    // Flecha
    _drawArrow(canvas, penultimatePoint, end, color: connColor);

    // Etiqueta
    if (connection.label.isNotEmpty) {
      _drawConnectionLabel(canvas, connection, start, end);
    }

    // ── Handles rectangulares del segmento medio (solo si seleccionada) ──
    if (isSelected && !connection.isLoopBack) {
      _drawSegmentHandles(canvas, connection, start, end, connColor);
    }

    // ── Cuadraditos de endpoint (source & target) si seleccionada ──
    if (isSelected && !isDraggingEndpoint) {
      _drawEndpointHandles(canvas, start, end, connColor);
    }
  }

  /// Dibuja los cuadraditos de reconexión en los extremos source y target de la flecha.
  void _drawEndpointHandles(Canvas canvas, Offset start, Offset end, Color color) {
    const double size = 10.0;

    void drawSquare(Offset center) {
      final rect = Rect.fromCenter(center: center, width: size, height: size);
      // Sombra
      canvas.drawRect(
        rect.translate(1, 1),
        Paint()..color = Colors.black.withOpacity(0.15)..style = PaintingStyle.fill,
      );
      // Relleno blanco / oscuro
      canvas.drawRect(
        rect,
        Paint()
          ..color = isDarkMode ? const Color(0xFF1E293B) : Colors.white
          ..style = PaintingStyle.fill,
      );
      // Borde con color de selección
      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    drawSquare(start);
    drawSquare(end);
  }

  /// Dibuja handles rectangulares sobre los segmentos ajustables de la flecha.
  void _drawSegmentHandles(Canvas canvas, Connection connection, Offset start,
      Offset end, Color color) {
    final seed =
        connection.source.id.hashCode ^ connection.target.id.hashCode;
    final route = _getOrthogonalRoute(start, end, connection.source,
        connection.target,
        seed: seed, midOffset: connection.midPointOffset);

    if (route.isEmpty) return;

    Offset prev = start;
    for (int i = 0; i < route.length; i++) {
      final wp = route[i];
      final len = (wp - prev).distance;
      if (len > 10) {
        final center = (prev + wp) / 2;
        final isHorizontal = (prev.dy - wp.dy).abs() < 2.0;
        
        _HandleType type = _HandleType.mid;
        if (i == 0) type = _HandleType.source;
        else if (i == route.length - 1) type = _HandleType.target;
        
        final bool isDragged = connection == draggingHandleConnection && type == draggingHandleType;
        
        _drawSingleHandle(canvas, center, isHorizontal, color, isDragged);
      }
      prev = wp;
    }
  }

  void _drawSingleHandle(Canvas canvas, Offset center, bool isHorizontal, Color color, bool isDragged) {
    // Dimensiones del handle (como en Lucidchart)
    const double handleLong = 24.0;
    const double handleShort = 10.0;
    final double hw = isHorizontal ? handleShort : handleLong;
    final double hh = isHorizontal ? handleLong : handleShort;

    final handleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: hw, height: hh),
      const Radius.circular(5), // Forma de cápsula
    );

    // Fondo blanco / oscuro o relleno azul si está siendo arrastrado
    final fillPaint = Paint()
      ..color = isDragged ? color : (isDarkMode ? const Color(0xFF1E293B) : Colors.white)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(handleRect, fillPaint);

    // Borde con el color de selección
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(handleRect, borderPaint);

    // Líneas interiores que indican la dirección de arrastre
    final linePaint = Paint()
      ..color = isDragged ? Colors.white : color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (isHorizontal) {
      // Flechas verticales ↕
      canvas.drawLine(Offset(center.dx, center.dy - 4),
          Offset(center.dx, center.dy + 4), linePaint);
      canvas.drawLine(Offset(center.dx - 2, center.dy - 3),
          Offset(center.dx, center.dy - 5), linePaint);
      canvas.drawLine(Offset(center.dx + 2, center.dy - 3),
          Offset(center.dx, center.dy - 5), linePaint);
      canvas.drawLine(Offset(center.dx - 2, center.dy + 3),
          Offset(center.dx, center.dy + 5), linePaint);
      canvas.drawLine(Offset(center.dx + 2, center.dy + 3),
          Offset(center.dx, center.dy + 5), linePaint);
    } else {
      // Flechas horizontales ↔
      canvas.drawLine(Offset(center.dx - 4, center.dy),
          Offset(center.dx + 4, center.dy), linePaint);
      canvas.drawLine(Offset(center.dx - 5, center.dy - 2),
          Offset(center.dx - 3, center.dy), linePaint);
      canvas.drawLine(Offset(center.dx - 5, center.dy + 2),
          Offset(center.dx - 3, center.dy), linePaint);
      canvas.drawLine(Offset(center.dx + 5, center.dy - 2),
          Offset(center.dx + 3, center.dy), linePaint);
      canvas.drawLine(Offset(center.dx + 5, center.dy + 2),
          Offset(center.dx + 3, center.dy), linePaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end,
      {Color? color}) {
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

    canvas.drawPath(
      arrowPath,
      Paint()..color = color ?? (isDarkMode ? Colors.white : Colors.black),
    );
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
    // Al manejar listas mutables, el repintado incondicional evita bugs
    // de visualización que ocurren al agregar/borrar elementos o arrastrar handles.
    return true;
  }
}