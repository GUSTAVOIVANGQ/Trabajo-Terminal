import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../themes/app_themes.dart';
import '../services/theme_service.dart';

class NodePalette extends StatelessWidget {
  final Function(NodeType) onNodeSelected;

  const NodePalette({super.key, required this.onNodeSelected});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isDarkMode = themeService.isDarkMode(context);
    final nodeColors = AppThemes.getNodeColors(isDarkMode);

    return Container(
      width: 80,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildPaletteItem(
            context,
            NodeType.start,
            'Inicio',
            Icons.play_circle_outline,
            nodeColors['start']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.end,
            'Fin',
            Icons.stop_circle_outlined,
            nodeColors['end']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.process,
            'Proceso',
            Icons.square_outlined,
            nodeColors['process']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.decision,
            'Decisión',
            Icons.change_history_outlined,
            nodeColors['decision']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.input,
            'Entrada',
            Icons.arrow_circle_down_outlined,
            nodeColors['input']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.output,
            'Salida',
            Icons.arrow_circle_up_outlined,
            nodeColors['output']!,
          ),
          _buildPaletteItem(
            context,
            NodeType.variable,
            'Variable',
            Icons.data_array_outlined,
            nodeColors['variable']!,
          ),
        ],
      ),
    );
  }

  Widget _buildPaletteItem(
    BuildContext context,
    NodeType type,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Tooltip(
            message: label,
            child: InkWell(
              onTap: () => onNodeSelected(type),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const Divider(height: 24),
      ],
    );
  }
}
