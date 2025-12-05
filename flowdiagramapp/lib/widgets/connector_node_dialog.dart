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
  String selectedConnectorType = 'entry'; // Por defecto entrada

  // Tipos de conectores disponibles
  final Map<String, String> connectorTypes = {
    'entry': 'Entrada (Origen)',
    'exit': 'Salida (Destino)',
    'both': 'Bidireccional',
  };

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) {
      return;
    }

    // Intentar detectar el tipo de conector por el formato
    if (text.startsWith('→') ||
        text.startsWith('HACIA:') ||
        text.startsWith('TO:')) {
      selectedConnectorType = 'exit';
      // Extraer la etiqueta removiendo el prefijo
      text = text
          .replaceAll('→', '')
          .replaceAll('HACIA:', '')
          .replaceAll('TO:', '')
          .trim();
    } else if (text.startsWith('←') ||
        text.startsWith('DESDE:') ||
        text.startsWith('FROM:')) {
      selectedConnectorType = 'entry';
      text = text
          .replaceAll('←', '')
          .replaceAll('DESDE:', '')
          .replaceAll('FROM:', '')
          .trim();
    } else if (text.startsWith('⇄') || text.startsWith('CONECTOR:')) {
      selectedConnectorType = 'both';
      text = text.replaceAll('⇄', '').replaceAll('CONECTOR:', '').trim();
    }

    _labelController.text = text;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _generateConnectorText() {
    String label = _labelController.text.trim();
    if (label.isEmpty) {
      label = 'A';
    }

    switch (selectedConnectorType) {
      case 'entry':
        return '← $label'; // Entrada desde otra página
      case 'exit':
        return '→ $label'; // Salida hacia otra página
      case 'both':
        return '⇄ $label'; // Bidireccional
      default:
        return label;
    }
  }

  Widget _buildConnectorTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Conector:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...connectorTypes.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: selectedConnectorType,
            onChanged: (value) {
              setState(() {
                selectedConnectorType = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLabelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiqueta del Conector:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelController,
          decoration: InputDecoration(
            hintText: 'Ej: A, B, C, 1, 2...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.label_outline),
            helperText: 'Identificador único para este conector',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 3,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Vista Previa:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _generateConnectorText(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    String helpText;
    switch (selectedConnectorType) {
      case 'entry':
        helpText =
            'Este conector recibe el flujo desde otra página del diagrama.';
        break;
      case 'exit':
        helpText =
            'Este conector envía el flujo hacia otra página del diagrama.';
        break;
      case 'both':
        helpText =
            'Este conector puede recibir y enviar flujo hacia/desde otras páginas.';
        break;
      default:
        helpText = '';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              helpText,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.radio_button_unchecked, size: 28),
          SizedBox(width: 12),
          Text('Conector Fuera de Página'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectorTypeSelector(),
              const SizedBox(height: 20),
              _buildLabelField(),
              const SizedBox(height: 20),
              _buildHelpText(),
              const SizedBox(height: 20),
              _buildPreview(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('DELETE');
          },
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
        FilledButton(
          onPressed: () {
            final text = _generateConnectorText();
            Navigator.of(context).pop(text);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
