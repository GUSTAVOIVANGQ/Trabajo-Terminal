import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class OutputNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const OutputNodeDialog({super.key, required this.node});

  @override
  State<OutputNodeDialog> createState() => _OutputNodeDialogState();
}

class _OutputNodeDialogState extends State<OutputNodeDialog> {
  String selectedOutputType = 'simple_output'; // Por defecto salida simple
  late TextEditingController _variableController;
  late TextEditingController _messageController;
  late TextEditingController _formatController;
  late TextEditingController _customTextController;
  String selectedOutputFormat = 'text';
  bool useCustomText = false;

  // Tipos de salida disponibles
  final Map<String, String> outputTypes = {
    'simple_output': 'Mostrar Variable',
    'message_output': 'Mostrar Mensaje',
    'formatted_output': 'Mostrar con Formato',
    'multiple_output': 'Mostrar Múltiples Variables',
    'file_output': 'Guardar en Archivo',
    'custom': 'Escribir Manualmente',
  };

  // Formatos de salida disponibles
  final Map<String, String> outputFormats = {
    'text': 'Texto Simple',
    'number': 'Número',
    'formatted': 'Con Formato Específico',
    'table': 'En Tabla',
  };

  @override
  void initState() {
    super.initState();
    _variableController = TextEditingController();
    _messageController = TextEditingController();
    _formatController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar salida con formato
    RegExp formattedPattern = RegExp(
        r'(?:mostrar|imprimir|print)\s+(.+?)\s+(?:formato|con formato)\s+(.+)',
        caseSensitive: false);
    Match? match = formattedPattern.firstMatch(text);

    if (match != null) {
      selectedOutputType = 'formatted_output';
      _variableController.text = match.group(1) ?? '';
      _formatController.text = match.group(2) ?? '';
      return;
    }

    // Detectar salida de mensaje
    RegExp messagePattern = RegExp(
        r'(?:mostrar|imprimir|print)\s+["' + "'" + r'](.+?)["' + "'" + r']',
        caseSensitive: false);
    match = messagePattern.firstMatch(text);

    if (match != null) {
      selectedOutputType = 'message_output';
      _messageController.text = match.group(1) ?? '';
      return;
    }

    // Detectar salida simple de variable
    RegExp simplePattern =
        RegExp(r'(?:mostrar|imprimir|print)\s+(\w+)', caseSensitive: false);
    match = simplePattern.firstMatch(text);

    if (match != null) {
      selectedOutputType = 'simple_output';
      _variableController.text = match.group(1) ?? '';
      return;
    }

    // Detectar múltiples variables
    if (text.toLowerCase().contains('mostrar') && text.contains(',')) {
      selectedOutputType = 'multiple_output';
      // Extraer variables separadas por comas
      String variables = text
          .replaceAll(
              RegExp(r'(?:mostrar|imprimir|print)', caseSensitive: false), '')
          .trim();
      _variableController.text = variables;
      return;
    }

    // Detectar salida a archivo
    if (text.toLowerCase().contains('archivo') ||
        text.toLowerCase().contains('guardar')) {
      selectedOutputType = 'file_output';
      RegExp filePattern = RegExp(
          r'(?:guardar|escribir)\s+(\w+)\s+(?:en|a)\s+archivo',
          caseSensitive: false);
      match = filePattern.firstMatch(text);
      if (match != null) {
        _variableController.text = match.group(1) ?? '';
      }
      return;
    }

    // Si no coincide con ningún patrón, usar texto personalizado
    selectedOutputType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variableController.dispose();
    _messageController.dispose();
    _formatController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generateOutputText() {
    if (selectedOutputType == 'custom') {
      return _customTextController.text;
    }

    switch (selectedOutputType) {
      case 'simple_output':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Mostrar variable';
        return 'Mostrar $variable';

      case 'message_output':
        String message = _messageController.text.trim();
        if (message.isEmpty) return 'Mostrar mensaje';
        return 'Mostrar "$message"';

      case 'formatted_output':
        String variable = _variableController.text.trim();
        String format = _formatController.text.trim();
        if (variable.isEmpty && format.isEmpty) return 'Mostrar con formato';
        if (variable.isEmpty) return 'Mostrar con formato: $format';
        if (format.isEmpty) return 'Mostrar $variable con formato';
        return 'Mostrar $variable con formato: $format';

      case 'multiple_output':
        String variables = _variableController.text.trim();
        if (variables.isEmpty) return 'Mostrar variables';
        return 'Mostrar $variables';

      case 'file_output':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Guardar en archivo';
        return 'Guardar $variable en archivo';

      default:
        return 'Salida';
    }
  }

  Widget _buildOutputTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Salida',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          ...outputTypes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: selectedOutputType,
              onChanged: (value) {
                setState(() {
                  selectedOutputType = value!;
                  useCustomText = value == 'custom';
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOutputFields() {
    if (selectedOutputType == 'custom') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Texto Personalizado',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customTextController,
            decoration: const InputDecoration(
              labelText: 'Texto del nodo',
              hintText: 'Escribe el texto personalizado...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => setState(() {}),
          ),
        ],
      );
    }

    switch (selectedOutputType) {
      case 'simple_output':
        return _buildSimpleOutputFields();
      case 'message_output':
        return _buildMessageOutputFields();
      case 'formatted_output':
        return _buildFormattedOutputFields();
      case 'multiple_output':
        return _buildMultipleOutputFields();
      case 'file_output':
        return _buildFileOutputFields();
      default:
        return Container();
    }
  }

  Widget _buildSimpleOutputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mostrar Variable',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a mostrar',
            hintText: 'Ej: resultado, nombre, suma',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.output),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _buildOutputFormatSelector(),
      ],
    );
  }

  Widget _buildMessageOutputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mostrar Mensaje',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: 'Mensaje a mostrar',
            hintText: 'Ej: El resultado es, Bienvenido',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
          ),
          maxLines: 2,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildFormattedOutputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Salida con Formato',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a mostrar',
            hintText: 'Ej: precio, temperatura',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.output),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _formatController,
          decoration: const InputDecoration(
            labelText: 'Formato de salida',
            hintText: 'Ej: %.2f, %d, "El valor es: %d"',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_shapes),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          'Usa %d para enteros, %.2f para decimales con 2 cifras',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildMultipleOutputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Múltiples Variables',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variables (separadas por comas)',
            hintText: 'Ej: nombre, edad, promedio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.view_list),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          'Separa las variables con comas para mostrar múltiples valores',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFileOutputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guardar en Archivo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a guardar',
            hintText: 'Ej: resultados, datos',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.save),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildOutputFormatSelector() {
    return DropdownButtonFormField<String>(
      value: selectedOutputFormat,
      decoration: const InputDecoration(
        labelText: 'Formato de salida',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.format_paint),
      ),
      items: outputFormats.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedOutputFormat = value!;
        });
      },
    );
  }

  Widget _buildPreview() {
    final previewText = _generateOutputText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Vista Previa',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              previewText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurface,
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
      title: Row(
        children: [
          Icon(
            Icons.output,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Editar Nodo de Salida'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configura cómo el programa mostrará información al usuario',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              _buildOutputTypeSelector(),
              const SizedBox(height: 16),
              _buildOutputFields(),
              const SizedBox(height: 16),
              _buildPreview(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_generateOutputText());
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
