import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/diagram_node.dart';

/// Mejoras adicionales de rendimiento para el canvas de diagramas de flujo
///
/// Este archivo contiene optimizaciones opcionales que pueden implementarse
/// para mejorar aún más el rendimiento del canvas en dispositivos de baja gama
/// o cuando se manejan diagramas muy complejos.

class CanvasPerformanceOptimizations {
  /// Configuración de rendimiento para diferentes tipos de dispositivos
  static const Map<String, Map<String, dynamic>> performanceProfiles = {
    'high_performance': {
      'repaint_frequency': 60, // FPS
      'use_shadows': true,
      'use_animations': true,
      'grid_opacity': 0.3,
      'max_nodes_for_optimization': 100,
    },
    'medium_performance': {
      'repaint_frequency': 30, // FPS
      'use_shadows': false,
      'use_animations': true,
      'grid_opacity': 0.2,
      'max_nodes_for_optimization': 50,
    },
    'low_performance': {
      'repaint_frequency': 15, // FPS
      'use_shadows': false,
      'use_animations': false,
      'grid_opacity': 0.1,
      'max_nodes_for_optimization': 25,
    },
  };

  /// Detecta automáticamente el perfil de rendimiento basado en las características del dispositivo
  static String detectPerformanceProfile() {
    // En una implementación real, esto podría basarse en:
    // - Información del dispositivo (RAM, CPU)
    // - Resolución de pantalla
    // - Versión del SO

    // Por ahora, devolvemos un perfil por defecto
    return 'high_performance';
  }

  /// Optimiza la lista de nodos para renderizado eficiente
  static List<DiagramNode> optimizeNodesForRendering(
    List<DiagramNode> nodes,
    Rect visibleArea,
    double scale,
  ) {
    // Filtrar nodos que están fuera del área visible (viewport culling)
    return nodes.where((node) {
      final nodeRect = Rect.fromLTWH(
        node.position.dx,
        node.position.dy,
        node.size.width * scale,
        node.size.height * scale,
      );

      return visibleArea.overlaps(nodeRect);
    }).toList();
  }

  /// Calcula el área visible del canvas
  static Rect calculateVisibleArea(
      Size canvasSize, Offset panOffset, double scale) {
    return Rect.fromLTWH(
      -panOffset.dx / scale,
      -panOffset.dy / scale,
      canvasSize.width / scale,
      canvasSize.height / scale,
    );
  }

  /// Optimiza las conexiones para renderizado eficiente
  static List<Connection> optimizeConnectionsForRendering(
    List<Connection> connections,
    List<DiagramNode> visibleNodes,
  ) {
    // Solo renderizar conexiones que conectan nodos visibles
    return connections.where((connection) {
      return visibleNodes.contains(connection.source) ||
          visibleNodes.contains(connection.target);
    }).toList();
  }
}

/// Widget optimizado para el renderizado de nodos individuales
class OptimizedNodeWidget extends StatelessWidget {
  final DiagramNode node;
  final bool isSelected;
  final bool isDragging;
  final Offset? currentDragPosition;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const OptimizedNodeWidget({
    super.key,
    required this.node,
    this.isSelected = false,
    this.isDragging = false,
    this.currentDragPosition,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: isDragging && currentDragPosition != null
          ? currentDragPosition!.dx
          : node.position.dx,
      top: isDragging && currentDragPosition != null
          ? currentDragPosition!.dy
          : node.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: node.size.width,
          height: node.size.height,
          decoration: _buildNodeDecoration(),
          child: Center(
            child: Text(
              node.text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildNodeDecoration() {
    return BoxDecoration(
      color: _getNodeColor().withOpacity(0.1),
      border: Border.all(
        color: _getNodeColor(),
        width: isSelected ? 2.5 : (isDragging ? 3.0 : 2.0),
      ),
      borderRadius: _getBorderRadius(),
      boxShadow: isDragging
          ? [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 4.0,
                offset: Offset(2, 2),
              ),
            ]
          : null,
    );
  }

  Color _getNodeColor() {
    switch (node.type) {
      case NodeType.start:
        return Colors.green;
      case NodeType.end:
        return Colors.red;
      case NodeType.process:
        return Colors.blue;
      case NodeType.decision:
        return Colors.orange;
      case NodeType.input:
        return Colors.purple;
      case NodeType.output:
        return Colors.teal;
      case NodeType.variable:
        return Colors.cyan;
    }
  }

  BorderRadius? _getBorderRadius() {
    switch (node.type) {
      case NodeType.start:
      case NodeType.end:
        return BorderRadius.circular(node.size.width / 2);
      case NodeType.decision:
        return null; // Los rombos no necesitan border radius
      default:
        return BorderRadius.circular(8.0);
    }
  }
}

/// Mixin para optimizaciones de pintado
mixin CanvasPaintOptimizations {
  /// Cache para reducir recalculaciones
  static final Map<String, Path> _pathCache = {};
  static final Map<String, Paint> _paintCache = {};

  /// Obtiene un path del cache o lo crea si no existe
  Path getCachedPath(String key, Path Function() pathBuilder) {
    if (_pathCache.containsKey(key)) {
      return _pathCache[key]!;
    }

    final path = pathBuilder();
    _pathCache[key] = path;
    return path;
  }

  /// Obtiene un Paint del cache o lo crea si no existe
  Paint getCachedPaint(String key, Paint Function() paintBuilder) {
    if (_paintCache.containsKey(key)) {
      return _paintCache[key]!;
    }

    final paint = paintBuilder();
    _paintCache[key] = paint;
    return paint;
  }

  /// Limpia el cache cuando sea necesario
  void clearCache() {
    _pathCache.clear();
    _paintCache.clear();
  }
}

/// Configuración para throttling de eventos de arrastre
class DragThrottler {
  static const int _throttleMs = 16; // ~60 FPS

  DateTime? _lastUpdate;

  bool shouldUpdate() {
    final now = DateTime.now();
    if (_lastUpdate == null ||
        now.difference(_lastUpdate!).inMilliseconds >= _throttleMs) {
      _lastUpdate = now;
      return true;
    }
    return false;
  }
}

/// Indicador de rendimiento para debugging
class PerformanceMonitor {
  static int _frameCount = 0;
  static DateTime? _lastSecond;
  static double _currentFPS = 0.0;

  static void recordFrame() {
    _frameCount++;
    final now = DateTime.now();

    if (_lastSecond == null) {
      _lastSecond = now;
      return;
    }

    if (now.difference(_lastSecond!).inMilliseconds >= 1000) {
      _currentFPS = _frameCount.toDouble();
      _frameCount = 0;
      _lastSecond = now;
    }
  }

  static double get currentFPS => _currentFPS;

  static Widget buildFPSDisplay() {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'FPS: ${_currentFPS.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
