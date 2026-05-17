import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class ConnectorNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const ConnectorNodeDialog({super.key, required this.node});

  @override
  State<ConnectorNodeDialog> createState() => _ConnectorNodeDialogState();
}

class _ConnectorNodeDialogState extends State<ConnectorNodeDialog> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    // Limpiar prefijos de versiones anteriores si existen
    String text = widget.node.text
        .replaceAll('←', '')
        .replaceAll('→', '')
        .replaceAll('⇄', '')
        .replaceAll('HACIA:', '')
        .replaceAll('DESDE:', '')
        .replaceAll('CONECTOR:', '')
        .trim();
    _labelController = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.radio_button_unchecked, size: 28),
          SizedBox(width: 12),
          Text('Conector'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación del símbolo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'El conector une partes del diagrama que están separadas. '
                      'Se identifica con una letra o número. Los dos conectores con el '
                      'mismo identificador están conectados entre sí.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de identificador
            const Text(
              'Identificador del conector',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              decoration: const InputDecoration(
                hintText: 'Ej: A, B, 1, 2...',
                border: OutlineInputBorder(),
                helperText:
                    'Usa el mismo identificador en el par de conectores',
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Vista previa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Vista previa',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Simulación visual del símbolo conector (círculo)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _labelController.text.isEmpty
                            ? '?'
                            : _labelController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop('DELETE'),
          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: _labelController.text.trim().isEmpty
              ? null
              : () {
                  widget.node.text = _labelController.text.trim().toUpperCase();
                  Navigator.of(context).pop(widget.node);
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
