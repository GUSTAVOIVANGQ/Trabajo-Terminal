import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../themes/app_themes.dart';
import '../services/theme_service.dart';
import '../interactive_tutorials/auto_tutorial_script.dart';

/// ISO 5807 compliant Node Palette with all flowchart symbols
/// organized by categories
class NodePalette extends StatefulWidget {
  final Function(NodeType) onNodeSelected;

  const NodePalette({super.key, required this.onNodeSelected});

  @override
  State<NodePalette> createState() => _NodePaletteState();
}

class _NodePaletteState extends State<NodePalette> {
  // Track which categories are expanded
  final Map<String, bool> _expandedCategories = {
    'basic': true, // Basic symbols expanded by default
    'process': false,
    'data': false,
    'special': false,
  };

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isDarkMode = themeService.isDarkMode(context);
    final nodeColors = AppThemes.getNodeColors(isDarkMode);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'ISO 5807',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),

          // === BASIC SYMBOLS (with C code generation) ===
          _buildCategoryHeader(
            context,
            'basic',
            'Basic',
            Icons.star,
            Colors.amber,
            hasCodeGen: true,
          ),
          if (_expandedCategories['basic']!) ...[
            _buildPaletteItem(context, NodeType.terminal, 'Terminal',
                _getNodeIcon(NodeType.terminal), nodeColors['terminal']!,
                hasCodeGen: true,
                itemKey: EditorTutorialKeys.terminalButton),
            _buildPaletteItem(context, NodeType.process, 'Process',
                _getNodeIcon(NodeType.process), nodeColors['process']!,
                hasCodeGen: true,
                itemKey: EditorTutorialKeys.processButton),
            _buildPaletteItem(context, NodeType.decision, 'Decision',
                _getNodeIcon(NodeType.decision), nodeColors['decision']!,
                hasCodeGen: true,
                itemKey: EditorTutorialKeys.decisionButton),
            _buildPaletteItem(
                context,
                NodeType.preparation,
                'Preparation',
                _getNodeIcon(NodeType.preparation),
                nodeColors['preparation'] ?? Colors.orange,
                hasCodeGen: true),
            _buildPaletteItem(context, NodeType.data, 'Data',
                _getNodeIcon(NodeType.data), nodeColors['data']!,
                hasCodeGen: true,
                itemKey: EditorTutorialKeys.dataButton),
            _buildPaletteItem(
                context,
                NodeType.predefinedProcess,
                'Predefined\nProcess',
                _getNodeIcon(NodeType.predefinedProcess),
                nodeColors['predefinedProcess'] ?? Colors.purple,
                hasCodeGen: true),
          ],

          // === PROCESS SYMBOLS (ISO 5807) ===
          _buildCategoryHeader(
            context,
            'process',
            'Process',
            Icons.settings,
            Colors.green,
          ),
          if (_expandedCategories['process']!) ...[
            _buildPaletteItem(
                context,
                NodeType.manualOperation,
                'Manual\nOperation',
                _getNodeIcon(NodeType.manualOperation),
                nodeColors['manualOperation'] ?? Colors.green),
            _buildPaletteItem(
                context,
                NodeType.parallelMode,
                'Parallel\nMode',
                _getNodeIcon(NodeType.parallelMode),
                nodeColors['parallelMode'] ?? Colors.lightGreen),
            _buildPaletteItem(
                context,
                NodeType.loopLimit,
                'Loop\nLimit',
                _getNodeIcon(NodeType.loopLimit),
                nodeColors['loopLimit'] ?? Colors.deepOrange),
            _buildPaletteItem(
                context,
                NodeType.collate,
                'Collate',
                _getNodeIcon(NodeType.collate),
                nodeColors['collate'] ?? Colors.teal),
            _buildPaletteItem(
                context,
                NodeType.summingJunction,
                'Summing\nJunction',
                _getNodeIcon(NodeType.summingJunction),
                nodeColors['summingJunction'] ?? Colors.teal),
          ],

          // === DATA SYMBOLS (ISO 5807) ===
          _buildCategoryHeader(
            context,
            'data',
            'Data',
            Icons.storage,
            Colors.blue,
          ),
          if (_expandedCategories['data']!) ...[
            _buildPaletteItem(
                context,
                NodeType.storedData,
                'Stored\nData',
                _getNodeIcon(NodeType.storedData),
                nodeColors['storedData'] ?? Colors.cyan),
            _buildPaletteItem(
                context,
                NodeType.internalStorage,
                'Internal\nStorage',
                _getNodeIcon(NodeType.internalStorage),
                nodeColors['internalStorage'] ?? Colors.cyan),
            _buildPaletteItem(
                context,
                NodeType.sequentialStorage,
                'Sequential\nStorage',
                _getNodeIcon(NodeType.sequentialStorage),
                nodeColors['sequentialStorage'] ?? Colors.blue),
            _buildPaletteItem(
                context,
                NodeType.directStorage,
                'Direct\nStorage',
                _getNodeIcon(NodeType.directStorage),
                nodeColors['directStorage'] ?? Colors.indigo),
            _buildPaletteItem(
                context,
                NodeType.document,
                'Document',
                _getNodeIcon(NodeType.document),
                nodeColors['document'] ?? Colors.indigo),
            _buildPaletteItem(
                context,
                NodeType.manualInput,
                'Manual\nInput',
                _getNodeIcon(NodeType.manualInput),
                nodeColors['manualInput'] ?? Colors.purple),
            _buildPaletteItem(
                context,
                NodeType.card,
                'Card',
                _getNodeIcon(NodeType.card),
                nodeColors['card'] ?? Colors.indigo),
            _buildPaletteItem(
                context,
                NodeType.punchedTape,
                'Punched\nTape',
                _getNodeIcon(NodeType.punchedTape),
                nodeColors['punchedTape'] ?? Colors.purple),
            _buildPaletteItem(
                context,
                NodeType.display,
                'Display',
                _getNodeIcon(NodeType.display),
                nodeColors['display'] ?? Colors.purple),
          ],

          // === SPECIAL SYMBOLS (ISO 5807) ===
          _buildCategoryHeader(
            context,
            'special',
            'Special',
            Icons.auto_awesome,
            Colors.amber,
          ),
          if (_expandedCategories['special']!) ...[
            _buildPaletteItem(
                context,
                NodeType.connector,
                'Connector',
                _getNodeIcon(NodeType.connector),
                nodeColors['connector'] ?? Colors.amber),
            _buildPaletteItem(
                context,
                NodeType.offPageConnector,
                'Off-page\nConnector',
                _getNodeIcon(NodeType.offPageConnector),
                nodeColors['offPageConnector'] ?? Colors.amber),
            _buildPaletteItem(
                context,
                NodeType.annotation,
                'Annotation',
                _getNodeIcon(NodeType.annotation),
                nodeColors['annotation'] ?? Colors.grey),
            _buildPaletteItem(
                context,
                NodeType.comment,
                'Comment',
                _getNodeIcon(NodeType.comment),
                nodeColors['comment'] ?? Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    String categoryKey,
    String title,
    IconData icon,
    Color color, {
    bool hasCodeGen = false,
  }) {
    final isExpanded = _expandedCategories[categoryKey] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          _expandedCategories[categoryKey] = !isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasCodeGen)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'C code',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNodeIcon(NodeType type) {
    switch (type) {
      // Basic symbols
      case NodeType.terminal:
        return Icons.trip_origin;
      case NodeType.process:
        return Icons.square_outlined;
      case NodeType.decision:
        return Icons.change_history_outlined;
      case NodeType.preparation:
        return Icons.hexagon_outlined;
      case NodeType.data:
        return Icons.swap_horiz;
      case NodeType.predefinedProcess:
        return Icons.account_tree_outlined;

      // Process symbols
      case NodeType.manualOperation:
        return Icons.back_hand_outlined;
      case NodeType.parallelMode:
        return Icons.view_stream_outlined;
      case NodeType.loopLimit:
        return Icons.repeat_outlined;
      case NodeType.collate:
        return Icons.close; // X symbol
      case NodeType.summingJunction:
        return Icons.add; // + symbol

      // Data symbols
      case NodeType.storedData:
        return Icons.save_outlined;
      case NodeType.internalStorage:
        return Icons.memory_outlined;
      case NodeType.sequentialStorage:
        return Icons.album_outlined;
      case NodeType.directStorage:
        return Icons.dns_outlined;
      case NodeType.document:
        return Icons.description_outlined;
      case NodeType.manualInput:
        return Icons.keyboard_outlined;
      case NodeType.card:
        return Icons.credit_card_outlined;
      case NodeType.punchedTape:
        return Icons.receipt_long_outlined;
      case NodeType.display:
        return Icons.monitor_outlined;

      // Special symbols
      case NodeType.connector:
        return Icons.radio_button_unchecked;
      case NodeType.offPageConnector:
        return Icons.arrow_drop_down_circle_outlined;
      case NodeType.annotation:
        return Icons.mode_comment_outlined;
      case NodeType.comment:
        return Icons.chat_bubble_outline;
    }
  }

  Widget _buildPaletteItem(
    BuildContext context,
    NodeType type,
    String label,
    IconData icon,
    Color color, {
    bool hasCodeGen = false,
    GlobalKey? itemKey,
  }) {
    return Column(
      key: itemKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Tooltip(
            message:
                '${type.isoName}\n${type.shapeDescription}${hasCodeGen ? '\n✓ Generates C code' : ''}',
            child: InkWell(
              onTap: () => widget.onNodeSelected(type),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  color: color.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    // Mini shape preview
                    SizedBox(
                      width: 36,
                      height: 24,
                      child: CustomPaint(
                        painter:
                            _MiniNodeShapePainter(type: type, color: color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 8,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw mini versions of each node shape
class _MiniNodeShapePainter extends CustomPainter {
  final NodeType type;
  final Color color;

  _MiniNodeShapePainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = _getShapePath(size);

    // Draw fill first, then stroke
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Draw additional details for certain shapes
    _drawShapeDetails(canvas, size, paint);
  }

  Path _getShapePath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (type) {
      case NodeType.terminal:
        // Oval
        path.addOval(Rect.fromLTWH(0, 0, w, h));
        break;

      case NodeType.process:
        // Rectangle
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        break;

      case NodeType.decision:
        // Diamond
        path.moveTo(w / 2, 0);
        path.lineTo(w, h / 2);
        path.lineTo(w / 2, h);
        path.lineTo(0, h / 2);
        path.close();
        break;

      case NodeType.preparation:
        // Hexagon
        final offset = w * 0.2;
        path.moveTo(offset, 0);
        path.lineTo(w - offset, 0);
        path.lineTo(w, h / 2);
        path.lineTo(w - offset, h);
        path.lineTo(offset, h);
        path.lineTo(0, h / 2);
        path.close();
        break;

      case NodeType.data:
        // Parallelogram
        final offset = w * 0.2;
        path.moveTo(offset, 0);
        path.lineTo(w, 0);
        path.lineTo(w - offset, h);
        path.lineTo(0, h);
        path.close();
        break;

      case NodeType.predefinedProcess:
        // Rectangle with vertical lines
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        break;

      case NodeType.manualOperation:
        // Trapezoid
        final slope = w * 0.15;
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w - slope, h);
        path.lineTo(slope, h);
        path.close();
        break;

      case NodeType.parallelMode:
        // Two horizontal bars
        path.addRect(Rect.fromLTWH(0, 0, w, h * 0.3));
        path.addRect(Rect.fromLTWH(0, h * 0.7, w, h * 0.3));
        break;

      case NodeType.loopLimit:
        // Rectangle with chamfered top corners
        final cut = w * 0.15;
        path.moveTo(cut, 0);
        path.lineTo(w - cut, 0);
        path.lineTo(w, cut);
        path.lineTo(w, h);
        path.lineTo(0, h);
        path.lineTo(0, cut);
        path.close();
        break;

      case NodeType.collate:
        // Circle with diagonal cross (X)
        final centerX = w / 2;
        final centerY = h / 2;
        final radius = h * 0.4;
        path.addOval(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
        // X diagonal
        final offset = radius * 0.707;
        path.moveTo(centerX - offset, centerY - offset);
        path.lineTo(centerX + offset, centerY + offset);
        path.moveTo(centerX + offset, centerY - offset);
        path.lineTo(centerX - offset, centerY + offset);
        break;

      case NodeType.summingJunction:
        // Circle with vertical/horizontal cross (+)
        final centerX = w / 2;
        final centerY = h / 2;
        final radius = h * 0.4;
        path.addOval(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
        // + cross
        path.moveTo(centerX, centerY - radius);
        path.lineTo(centerX, centerY + radius);
        path.moveTo(centerX - radius, centerY);
        path.lineTo(centerX + radius, centerY);
        break;

      case NodeType.storedData:
        // Rectangle with curved sides
        path.moveTo(w * 0.15, 0);
        path.lineTo(w, 0);
        path.quadraticBezierTo(w * 0.85, h / 2, w, h);
        path.lineTo(w * 0.15, h);
        path.quadraticBezierTo(0, h / 2, w * 0.15, 0);
        break;

      case NodeType.internalStorage:
        // Rectangle with internal grid
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        break;

      case NodeType.sequentialStorage:
        // Circle with tail (magnetic tape)
        final radius = h * 0.35;
        path.addOval(
            Rect.fromCircle(center: Offset(w / 2, h / 2), radius: radius));
        break;

      case NodeType.directStorage:
        // Cylinder shape
        path.addOval(Rect.fromLTWH(0, 0, w, h * 0.3));
        path.moveTo(0, h * 0.15);
        path.lineTo(0, h * 0.85);
        path.arcToPoint(Offset(w, h * 0.85),
            radius: Radius.elliptical(w / 2, h * 0.15), clockwise: false);
        path.lineTo(w, h * 0.15);
        break;

      case NodeType.document:
        // Rectangle with wavy bottom
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h * 0.8);
        path.quadraticBezierTo(w * 0.75, h, w * 0.5, h * 0.85);
        path.quadraticBezierTo(w * 0.25, h * 0.7, 0, h * 0.9);
        path.close();
        break;

      case NodeType.manualInput:
        // Parallelogram with sloped top
        path.moveTo(0, h * 0.3);
        path.lineTo(w, 0);
        path.lineTo(w, h);
        path.lineTo(0, h);
        path.close();
        break;

      case NodeType.card:
        // Rectangle with cut corner
        final cut = w * 0.2;
        path.moveTo(cut, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h);
        path.lineTo(0, h);
        path.lineTo(0, cut);
        path.close();
        break;

      case NodeType.punchedTape:
        // Wavy rectangle
        path.moveTo(0, h * 0.15);
        path.quadraticBezierTo(w * 0.25, 0, w * 0.5, h * 0.15);
        path.quadraticBezierTo(w * 0.75, h * 0.3, w, h * 0.15);
        path.lineTo(w, h * 0.85);
        path.quadraticBezierTo(w * 0.75, h, w * 0.5, h * 0.85);
        path.quadraticBezierTo(w * 0.25, h * 0.7, 0, h * 0.85);
        path.close();
        break;

      case NodeType.display:
        // Bullet shape
        final arrowWidth = w * 0.25;
        path.moveTo(arrowWidth, 0);
        path.lineTo(w - arrowWidth, 0);
        path.arcToPoint(Offset(w - arrowWidth, h),
            radius: Radius.circular(h), clockwise: true);
        path.lineTo(arrowWidth, h);
        path.lineTo(0, h / 2);
        path.close();
        break;

      case NodeType.connector:
        // Circle
        path.addOval(Rect.fromLTWH(w * 0.15, 0, w * 0.7, h));
        break;

      case NodeType.offPageConnector:
        // Pentagon pointing down
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h * 0.5);
        path.lineTo(w / 2, h);
        path.lineTo(0, h * 0.5);
        path.close();
        break;

      case NodeType.annotation:
        // Open bracket
        path.moveTo(w * 0.7, 0);
        path.lineTo(w * 0.3, 0);
        path.lineTo(w * 0.3, h);
        path.lineTo(w * 0.7, h);
        break;

      case NodeType.comment:
        // Dashed rectangle (shown as regular for simplicity)
        path.addRect(Rect.fromLTWH(0, 0, w, h));
        break;
    }

    return path;
  }

  void _drawShapeDetails(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case NodeType.predefinedProcess:
        // Draw vertical lines
        final lineOffset = w * 0.15;
        canvas.drawLine(Offset(lineOffset, 0), Offset(lineOffset, h), paint);
        canvas.drawLine(
            Offset(w - lineOffset, 0), Offset(w - lineOffset, h), paint);
        break;

      case NodeType.internalStorage:
        // Draw internal grid lines
        canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), paint);
        canvas.drawLine(Offset(w * 0.25, 0), Offset(w * 0.25, h), paint);
        break;

      case NodeType.sequentialStorage:
        // Draw tail
        final radius = h * 0.35;
        canvas.drawLine(
          Offset(w / 2, h / 2 + radius),
          Offset(w * 0.85, h / 2 + radius),
          paint,
        );
        break;

      default:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
