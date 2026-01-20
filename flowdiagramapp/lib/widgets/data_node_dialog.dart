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
  String selectedDataOperation = 'input_simple'; // Por defecto entrada simple
  late TextEditingController _variableController;
  late TextEditingController _messageController;
  late TextEditingController _formatController;
  late TextEditingController _customTextController;
  String selectedDataType = 'int';
  String selectedOutputFormat = 'text';
  bool useCustomText = false;

  // Operaciones de datos disponibles (entrada y salida combinadas)
  final Map<String, String> dataOperations = {
    // Operaciones de ENTRADA
    'input_simple': '📥 Leer Variable Simple',
    'input_with_prompt': '📥 Leer con Mensaje',
    'input_multiple': '📥 Leer Múltiples Variables',
    'input_file': '📥 Leer desde Archivo',

    // Operaciones de SALIDA
    'output_simple': '📤 Mostrar Variable',
    'output_message': '📤 Mostrar Mensaje',
    'output_formatted': '📤 Mostrar con Formato',
    'output_multiple': '📤 Mostrar Múltiples Variables',
    'output_file': '📤 Guardar en Archivo',

    'custom': '✏️ Escribir Manualmente',
  };

  // Tipos de datos disponibles
  final Map<String, String> dataTypes = {
    'int': 'Número Entero (int)',
    'float': 'Número Decimal (float)',
    'char': 'Carácter (char)',
    'string': 'Texto (string)',
  };

  // Formatos de salida disponibles
  final Map<String, String> outputFormats = {
    'text': 'Texto Simple',
    'number': 'Número',
    'formatted': 'Con Formato Específico',
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

    // DETECCIÓN DE ENTRADA
    // Detectar entrada con mensaje
    RegExp inputPromptPattern = RegExp(
        r'(?:leer|input|ingresar?)\s+(.+?)(?:\s+en\s+(\w+))?',
        caseSensitive: false);
    Match? match = inputPromptPattern.firstMatch(text);

    if (match != null && !text.toLowerCase().contains('mostrar')) {
      selectedDataOperation = 'input_with_prompt';
      String prompt = match.group(1) ?? '';
      String? variable = match.group(2);

      _messageController.text = prompt.replaceAll('"', '').replaceAll("'", '');
      if (variable != null) {
        _variableController.text = variable;
      }
      return;
    }

    // Detectar entrada simple de variable
    RegExp inputSimplePattern =
        RegExp(r'(?:leer|input)\s+(\w+)', caseSensitive: false);
    match = inputSimplePattern.firstMatch(text);

    if (match != null && !text.toLowerCase().contains('mostrar')) {
      selectedDataOperation = 'input_simple';
      _variableController.text = match.group(1) ?? '';
      return;
    }

    // Detectar entrada múltiple
    if ((text.toLowerCase().contains('leer') ||
            text.toLowerCase().contains('input')) &&
        text.contains(',') &&
        !text.toLowerCase().contains('mostrar')) {
      selectedDataOperation = 'input_multiple';
      String variables = text
          .replaceAll(RegExp(r'(?:leer|input)', caseSensitive: false), '')
          .trim();
      _variableController.text = variables;
      return;
    }

    // Detectar entrada desde archivo
    if (text.toLowerCase().contains('archivo') &&
        (text.toLowerCase().contains('leer') ||
            text.toLowerCase().contains('input'))) {
      selectedDataOperation = 'input_file';
      RegExp filePattern = RegExp(
          r'(?:leer|input)\s+(\w+)\s+(?:desde|from)\s+archivo',
          caseSensitive: false);
      match = filePattern.firstMatch(text);
      if (match != null) {
        _variableController.text = match.group(1) ?? '';
      }
      return;
    }

    // DETECCIÓN DE SALIDA
    // Detectar salida con formato
    RegExp outputFormattedPattern = RegExp(
        r'(?:mostrar|imprimir|print)\s+(.+?)\s+(?:formato|con formato)\s+(.+)',
        caseSensitive: false);
    match = outputFormattedPattern.firstMatch(text);

    if (match != null) {
      selectedDataOperation = 'output_formatted';
      _variableController.text = match.group(1) ?? '';
      _formatController.text = match.group(2) ?? '';
      return;
    }

    // Detectar salida de mensaje
    RegExp outputMessagePattern = RegExp(
        r'(?:mostrar|imprimir|print)\s+["' + "'" + r'](.+?)["' + "'" + r']',
        caseSensitive: false);
    match = outputMessagePattern.firstMatch(text);

    if (match != null) {
      selectedDataOperation = 'output_message';
      _messageController.text = match.group(1) ?? '';
      return;
    }

    // Detectar salida simple de variable
    RegExp outputSimplePattern = RegExp(
        r'(?:mostrar|imprimir|print|escribir)\s+(\w+)',
        caseSensitive: false);
    match = outputSimplePattern.firstMatch(text);

    if (match != null) {
      selectedDataOperation = 'output_simple';
      _variableController.text = match.group(1) ?? '';
      return;
    }

    // Detectar salida múltiple
    if ((text.toLowerCase().contains('mostrar') ||
            text.toLowerCase().contains('imprimir') ||
            text.toLowerCase().contains('print')) &&
        text.contains(',')) {
      selectedDataOperation = 'output_multiple';
      String variables = text
          .replaceAll(
              RegExp(r'(?:mostrar|imprimir|print)', caseSensitive: false), '')
          .trim();
      _variableController.text = variables;
      return;
    }

    // Detectar salida a archivo
    if (text.toLowerCase().contains('archivo') &&
        (text.toLowerCase().contains('guardar') ||
            text.toLowerCase().contains('escribir'))) {
      selectedDataOperation = 'output_file';
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
    selectedDataOperation = 'custom';
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

  String _generateDataText() {
    if (selectedDataOperation == 'custom') {
      return _customTextController.text;
    }

    switch (selectedDataOperation) {
      // ENTRADA
      case 'input_simple':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Leer variable';
        return 'Leer $variable';

      case 'input_with_prompt':
        String message = _messageController.text.trim();
        String variable = _variableController.text.trim();
        if (message.isEmpty && variable.isEmpty) return 'Leer con mensaje';
        if (message.isEmpty) return 'Leer $variable';
        if (variable.isEmpty) return 'Mostrar "$message" y leer';
        return 'Mostrar "$message" y leer $variable';

      case 'input_multiple':
        String variables = _variableController.text.trim();
        if (variables.isEmpty) return 'Leer variables';
        return 'Leer $variables';

      case 'input_file':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Leer desde archivo';
        return 'Leer $variable desde archivo';

      // SALIDA
      case 'output_simple':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Mostrar variable';
        return 'Mostrar $variable';

      case 'output_message':
        String message = _messageController.text.trim();
        if (message.isEmpty) return 'Mostrar mensaje';
        return 'Mostrar "$message"';

      case 'output_formatted':
        String variable = _variableController.text.trim();
        String format = _formatController.text.trim();
        if (variable.isEmpty && format.isEmpty) return 'Mostrar con formato';
        if (variable.isEmpty) return 'Mostrar con formato: $format';
        if (format.isEmpty) return 'Mostrar $variable con formato';
        return 'Mostrar $variable con formato: $format';

      case 'output_multiple':
        String variables = _variableController.text.trim();
        if (variables.isEmpty) return 'Mostrar variables';
        return 'Mostrar $variables';

      case 'output_file':
        String variable = _variableController.text.trim();
        if (variable.isEmpty) return 'Guardar en archivo';
        return 'Guardar $variable en archivo';

      default:
        return 'Dato';
    }
  }

  bool get _isInputOperation => selectedDataOperation.startsWith('input_');
  bool get _isOutputOperation => selectedDataOperation.startsWith('output_');

  Widget _buildOperationSelector() {
    return DropdownButtonFormField<String>(
      value: selectedDataOperation,
      decoration: InputDecoration(
        labelText: 'Tipo de Operación',
        hintText: 'Selecciona una operación de datos',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          _isInputOperation
              ? Icons.input
              : _isOutputOperation
                  ? Icons.output
                  : Icons.edit,
          color: Theme.of(context).colorScheme.primary,
        ),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      items: dataOperations.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(
            entry.value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedDataOperation = value!;
          useCustomText = value == 'custom';
        });
      },
      isExpanded: true,
    );
  }

  Widget _buildDataFields() {
    if (selectedDataOperation == 'custom') {
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

    // ENTRADA
    if (selectedDataOperation == 'input_simple') {
      return _buildInputSimpleFields();
    } else if (selectedDataOperation == 'input_with_prompt') {
      return _buildInputWithPromptFields();
    } else if (selectedDataOperation == 'input_multiple') {
      return _buildInputMultipleFields();
    } else if (selectedDataOperation == 'input_file') {
      return _buildInputFileFields();
    }

    // SALIDA
    else if (selectedDataOperation == 'output_simple') {
      return _buildOutputSimpleFields();
    } else if (selectedDataOperation == 'output_message') {
      return _buildOutputMessageFields();
    } else if (selectedDataOperation == 'output_formatted') {
      return _buildOutputFormattedFields();
    } else if (selectedDataOperation == 'output_multiple') {
      return _buildOutputMultipleFields();
    } else if (selectedDataOperation == 'output_file') {
      return _buildOutputFileFields();
    }

    return Container();
  }

  // ======= CAMPOS DE ENTRADA =======

  Widget _buildInputSimpleFields() {
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

  Widget _buildInputWithPromptFields() {
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
          controller: _messageController,
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

  Widget _buildInputMultipleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Múltiples Variables de Entrada',
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

  Widget _buildInputFileFields() {
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

  // ======= CAMPOS DE SALIDA =======

  Widget _buildOutputSimpleFields() {
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

  Widget _buildOutputMessageFields() {
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

  Widget _buildOutputFormattedFields() {
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

  Widget _buildOutputMultipleFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Múltiples Variables de Salida',
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

  Widget _buildOutputFileFields() {
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

  // ======= SELECTORES =======

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
    final previewText = _generateDataText();
    final operationType = _isInputOperation
        ? 'Entrada'
        : _isOutputOperation
            ? 'Salida'
            : 'Personalizado';
    final iconData = _isInputOperation
        ? Icons.input
        : _isOutputOperation
            ? Icons.output
            : Icons.edit;

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
                'Vista Previa - $operationType',
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
            child: Row(
              children: [
                Icon(
                  iconData,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
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
            Icons.swap_horiz,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Editar Nodo de Dato'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configura cómo el programa recibe o muestra datos (Entrada/Salida)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              _buildOperationSelector(),
              const SizedBox(height: 16),
              _buildDataFields(),
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
            Navigator.of(context)
                .pop(NodeDialogResult.simple(_generateDataText()));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
