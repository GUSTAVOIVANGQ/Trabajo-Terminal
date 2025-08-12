import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class InputNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const InputNodeDialog({super.key, required this.node});

  @override
  State<InputNodeDialog> createState() => _InputNodeDialogState();
}

class _InputNodeDialogState extends State<InputNodeDialog> {
  String selectedInputType = 'simple_input'; // Por defecto entrada simple
  late TextEditingController _variableController;
  late TextEditingController _promptController;
  late TextEditingController _customTextController;
  String selectedDataType = 'int';
  bool useCustomText = false;

  // Tipos de entrada disponibles
  final Map<String, String> inputTypes = {
    'simple_input': 'Leer Variable Simple',
    'input_with_prompt': 'Leer con Mensaje',
    'multiple_input': 'Leer Múltiples Variables',
    'file_input': 'Leer desde Archivo',
    'custom': 'Escribir Manualmente',
  };

  // Tipos de datos disponibles
  final Map<String, String> dataTypes = {
    'int': 'Número Entero (int)',
    'float': 'Número Decimal (float)',
    'char': 'Carácter (char)',
    'string': 'Texto (string)',
  };

  @override
  void initState() {
    super.initState();
    _variableController = TextEditingController();
    _promptController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar entrada con mensaje
    RegExp promptPattern = RegExp(
        r'(?:leer|input|ingresar?)\s+(.+?)(?:\s+en\s+(\w+))?',
        caseSensitive: false);
    Match? match = promptPattern.firstMatch(text);

    if (match != null) {
      selectedInputType = 'input_with_prompt';
      String prompt = match.group(1) ?? '';
      String? variable = match.group(2);

      _promptController.text = prompt.replaceAll('"', '').replaceAll("'", '');
      if (variable != null) {
        _variableController.text = variable;
      }
      return;
    }

    // Detectar entrada simple de variable
    RegExp simplePattern =
        RegExp(r'(?:leer|input)\s+(\w+)', caseSensitive: false);
    match = simplePattern.firstMatch(text);

    if (match != null) {
      selectedInputType = 'simple_input';
      _variableController.text = match.group(1) ?? '';
      return;
    }

    // Detectar múltiples variables
    if (text.toLowerCase().contains('leer') && text.contains(',')) {
      selectedInputType = 'multiple_input';
      // Extraer variables separadas por comas
      String variables = text
          .replaceAll(RegExp(r'(?:leer|input)', caseSensitive: false), '')
          .trim();
      _variableController.text = variables;
      return;
    }

    // Si no coincide con ningún patrón, usar texto personalizado
    selectedInputType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variableController.dispose();
    _promptController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generateInputText() {
    if (selectedInputType == 'custom') {
      return _customTextController.text;
    }

    switch (selectedInputType) {
      case 'simple_input':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Leer variable';
        return 'Leer $variable';

      case 'input_with_prompt':
        String prompt = _promptController.text.trim();
        String variable = _variableController.text.trim();
        if (prompt.isEmpty && variable.isEmpty) return 'Leer con mensaje';
        if (prompt.isEmpty) return 'Leer $variable';
        if (variable.isEmpty) return 'Mostrar "$prompt" y leer';
        return 'Mostrar "$prompt" y leer $variable';

      case 'multiple_input':
        String variables = _variableController.text.trim();
        if (variables.isEmpty) return 'Leer variables';
        return 'Leer $variables';

      case 'file_input':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Leer desde archivo';
        return 'Leer $variable desde archivo';

      default:
        return 'Entrada';
    }
  }

  Widget _buildInputTypeSelector() {
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
            'Tipo de Entrada',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 12),
          ...inputTypes.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: selectedInputType,
              onChanged: (value) {
                setState(() {
                  selectedInputType = value!;
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

  Widget _buildInputFields() {
    if (selectedInputType == 'custom') {
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

    switch (selectedInputType) {
      case 'simple_input':
        return _buildSimpleInputFields();
      case 'input_with_prompt':
        return _buildPromptInputFields();
      case 'multiple_input':
        return _buildMultipleInputFields();
      case 'file_input':
        return _buildFileInputFields();
      default:
        return Container();
    }
  }

  Widget _buildSimpleInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrada Simple',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la variable',
            hintText: 'Ej: edad, nombre, numero',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.input),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _buildDataTypeSelector(),
      ],
    );
  }

  Widget _buildPromptInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrada con Mensaje',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _promptController,
          decoration: const InputDecoration(
            labelText: 'Mensaje para el usuario',
            hintText: 'Ej: Ingrese su edad, Escriba su nombre',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable donde guardar',
            hintText: 'Ej: edad, nombre, numero',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.input),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        _buildDataTypeSelector(),
      ],
    );
  }

  Widget _buildMultipleInputFields() {
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
            hintText: 'Ej: nombre, edad, ciudad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.view_list),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Text(
          'Separa las variables con comas para leer múltiples valores',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFileInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entrada desde Archivo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable donde guardar',
            hintText: 'Ej: datos, contenido',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.file_open),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDataTypeSelector() {
    return DropdownButtonFormField<String>(
      value: selectedDataType,
      decoration: const InputDecoration(
        labelText: 'Tipo de dato',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.data_object),
      ),
      items: dataTypes.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDataType = value!;
        });
      },
    );
  }

  Widget _buildPreview() {
    final previewText = _generateInputText();

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
            Icons.input,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Editar Nodo de Entrada'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configura cómo el programa recibirá datos del usuario',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              _buildInputTypeSelector(),
              const SizedBox(height: 16),
              _buildInputFields(),
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
            Navigator.of(context).pop(_generateInputText());
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
