import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../models/node_dialog_result.dart';

class DataNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const DataNodeDialog({super.key, required this.node});

  @override
  State<DataNodeDialog> createState() => _DataNodeDialogState();
}

class _DataNodeDialogState extends State<DataNodeDialog> {
  // Solo dos modos: entrada o salida
  bool _isInput = true;
  late TextEditingController _inputController;
  late TextEditingController _messageController;
  late TextEditingController _variablesController;

  @override
  void initState() {
    super.initState();
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    _inputController = TextEditingController();
    _messageController = TextEditingController();
    _variablesController = TextEditingController();

    // Detectar si era salida por palabras clave comunes
    final outputKeywords = [
      'mostrar',
      'imprimir',
      'escribir',
      'print',
      'mostrar'
    ];
    final lowerText = text.toLowerCase();
    if (outputKeywords.any((kw) => lowerText.startsWith(kw))) {
      _isInput = false;
      // Extraer el contenido quitando la palabra clave
      final cleaned = text
          .replaceFirst(
              RegExp(r'^(mostrar|imprimir|escribir|print)\s*',
                  caseSensitive: false),
              '')
          .trim();
      
      final stringMatch = RegExp(r'^"([^"]*)"(?:,\s*(.*))?$').firstMatch(cleaned);
      if (stringMatch != null) {
        _messageController.text = stringMatch.group(1) ?? '';
        _variablesController.text = stringMatch.group(2) ?? '';
      } else if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
        _messageController.text = cleaned.replaceAll('"', '');
      } else {
        _variablesController.text = cleaned;
      }
    } else {
      _isInput = true;
      final cleaned = text
          .replaceFirst(
              RegExp(r'^(leer|ingresar|input|read)\s*', caseSensitive: false),
              '')
          .trim();
      _inputController.text = cleaned;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _messageController.dispose();
    _variablesController.dispose();
    super.dispose();
  }

  String _generateText() {
    if (_isInput) {
      final content = _inputController.text.trim();
      if (content.isEmpty) return '';
      return 'Leer $content';
    } else {
      final msg = _messageController.text.trim();
      final vars = _variablesController.text.trim();
      
      if (msg.isEmpty && vars.isEmpty) return '';
      
      if (msg.isNotEmpty && vars.isNotEmpty) {
        return 'Mostrar "$msg", $vars';
      } else if (msg.isNotEmpty) {
        return 'Mostrar "$msg"';
      } else {
        return 'Mostrar $vars';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _generateText();

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isInput ? Icons.input : Icons.output,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Entrada / Salida'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector Entrada / Salida
            const Text('Tipo de operación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _OptionCard(
                    label: 'Entrada',
                    description: 'El usuario ingresa un dato',
                    icon: Icons.input,
                    selected: _isInput,
                    onTap: () => setState(() => _isInput = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OptionCard(
                    label: 'Salida',
                    description: 'El programa muestra un dato',
                    icon: Icons.output,
                    selected: !_isInput,
                    onTap: () => setState(() => _isInput = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo de dato/variable
            if (_isInput) ...[
              const Text(
                'Variable donde se guarda',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: 'Ej: edad, nombre, numero',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ] else ...[
              const Text(
                'Mensaje a mostrar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ej: El resultado es',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              const Text(
                'Variables (Opcional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _variablesController,
                decoration: const InputDecoration(
                  hintText: 'Ej: resultado, suma',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 20),

            // Vista previa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text('Vista previa',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preview.isEmpty ? '(completa el campo)' : preview,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: preview.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: preview.isEmpty
              ? null
              : () {
                  Navigator.of(context).pop(NodeDialogResult.simple(preview));
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Tarjeta de opción para seleccionar Entrada o Salida
class _OptionCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
        
    final contentColor = selected
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: contentColor, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: contentColor, fontSize: 14)),
            const SizedBox(height: 4),
            Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: contentColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
