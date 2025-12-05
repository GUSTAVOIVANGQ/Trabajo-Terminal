import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../models/node_dialog_result.dart';

class VariableNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const VariableNodeDialog({super.key, required this.node});

  @override
  State<VariableNodeDialog> createState() => _VariableNodeDialogState();
}

class _VariableNodeDialogState extends State<VariableNodeDialog> {
  String selectedDeclarationType = 'declaration'; // Por defecto declaración
  late TextEditingController _variableNameController;
  late TextEditingController _valueController;
  late TextEditingController _customTextController;
  String selectedDataType = 'int';
  bool initializeWithValue = false;
  bool useCustomText = false;

  // Tipos de declaraciones disponibles
  final Map<String, String> declarationTypes = {
    'declaration': 'Declarar Variable',
    'initialization': 'Declarar e Inicializar',
    'constant': 'Declarar Constante',
    'array': 'Declarar Arreglo',
    'custom': 'Escribir Manualmente',
  };

  // Tipos de datos disponibles en C
  final Map<String, String> dataTypes = {
    'int': 'Entero (int)',
    'float': 'Decimal (float)',
    'double': 'Decimal doble (double)',
    'char': 'Carácter (char)',
    'bool': 'Booleano (bool)',
    'string': 'Cadena de texto (char[])',
  };

  @override
  void initState() {
    super.initState();
    _variableNameController = TextEditingController();
    _valueController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar declaración con inicialización
    RegExp initPattern =
        RegExp(r'^(int|float|double|char|bool)\s+(\w+)\s*=\s*(.+)$');
    Match? match = initPattern.firstMatch(text);

    if (match != null) {
      selectedDeclarationType = 'initialization';
      selectedDataType = match.group(1) ?? 'int';
      _variableNameController.text = match.group(2) ?? '';
      _valueController.text = match.group(3) ?? '';
      initializeWithValue = true;
      return;
    }

    // Detectar declaración simple
    RegExp declPattern = RegExp(r'^(int|float|double|char|bool)\s+(\w+)$');
    match = declPattern.firstMatch(text);

    if (match != null) {
      selectedDeclarationType = 'declaration';
      selectedDataType = match.group(1) ?? 'int';
      _variableNameController.text = match.group(2) ?? '';
      initializeWithValue = false;
      return;
    }

    // Detectar constante
    if (text.contains('const')) {
      RegExp constPattern =
          RegExp(r'^const\s+(int|float|double|char|bool)\s+(\w+)\s*=\s*(.+)$');
      match = constPattern.firstMatch(text);

      if (match != null) {
        selectedDeclarationType = 'constant';
        selectedDataType = match.group(1) ?? 'int';
        _variableNameController.text = match.group(2) ?? '';
        _valueController.text = match.group(3) ?? '';
        return;
      }
    }

    // Detectar arreglo
    if (text.contains('[') && text.contains(']')) {
      RegExp arrayPattern =
          RegExp(r'^(int|float|double|char|bool)\s+(\w+)\[(\d+)\]$');
      match = arrayPattern.firstMatch(text);

      if (match != null) {
        selectedDeclarationType = 'array';
        selectedDataType = match.group(1) ?? 'int';
        _variableNameController.text = match.group(2) ?? '';
        _valueController.text = match.group(3) ?? '';
        return;
      }
    }

    // Detectar cadena de texto (char[])
    if (text.contains('char') && (text.contains('[') || text.contains('*'))) {
      selectedDataType = 'string';
      selectedDeclarationType = 'array';

      RegExp stringPattern = RegExp(r'^char\s+(\w+)\[(\d*)\]$');
      match = stringPattern.firstMatch(text);

      if (match != null) {
        _variableNameController.text = match.group(1) ?? '';
        _valueController.text = match.group(2) ?? '100';
        return;
      }
    }

    // Si no coincide con ningún patrón, usar texto personalizado
    selectedDeclarationType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variableNameController.dispose();
    _valueController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generateVariableText() {
    if (useCustomText || selectedDeclarationType == 'custom') {
      return _customTextController.text;
    }

    switch (selectedDeclarationType) {
      case 'declaration':
        return '$selectedDataType ${_variableNameController.text}';

      case 'initialization':
        return '$selectedDataType ${_variableNameController.text} = ${_valueController.text}';

      case 'constant':
        return 'const $selectedDataType ${_variableNameController.text} = ${_valueController.text}';

      case 'array':
        if (selectedDataType == 'string') {
          String size =
              _valueController.text.isEmpty ? '100' : _valueController.text;
          return 'char ${_variableNameController.text}[$size]';
        } else {
          String size =
              _valueController.text.isEmpty ? '10' : _valueController.text;
          return '$selectedDataType ${_variableNameController.text}[$size]';
        }

      default:
        return '';
    }
  }

  Widget _buildDeclarationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Declaración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDeclarationType,
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  selectedDeclarationType = value!;
                  useCustomText = value == 'custom';
                });
              },
              items: declarationTypes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    if (useCustomText || selectedDeclarationType == 'custom') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Declaración Personalizada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customTextController,
            decoration: const InputDecoration(
              labelText: 'Código de declaración',
              hintText: 'Ej: int matriz[10][10]',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) => setState(() {}),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildVariableNameField(),
        if (selectedDeclarationType == 'initialization' ||
            selectedDeclarationType == 'constant' ||
            selectedDeclarationType == 'array') ...[
          const SizedBox(height: 16),
          _buildValueField(),
        ],
      ],
    );
  }

  Widget _buildDataTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Dato',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDataType,
              isExpanded: true,
              onChanged: (String? value) {
                setState(() {
                  selectedDataType = value!;
                });
              },
              items: dataTypes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariableNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Variable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _variableNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: contador, suma, edad',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildValueField() {
    String label;
    String hint;

    switch (selectedDeclarationType) {
      case 'initialization':
        label = 'Valor Inicial';
        hint = _getValueHint();
        break;
      case 'constant':
        label = 'Valor de la Constante';
        hint = _getValueHint();
        break;
      case 'array':
        label = selectedDataType == 'string'
            ? 'Tamaño del arreglo'
            : 'Tamaño del arreglo';
        hint = selectedDataType == 'string' ? 'Ej: 100' : 'Ej: 10, 50';
        break;
      default:
        label = 'Valor';
        hint = 'Ingrese el valor';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _valueController,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  String _getValueHint() {
    switch (selectedDataType) {
      case 'int':
        return 'Ej: 0, 5, -10';
      case 'float':
      case 'double':
        return 'Ej: 0.0, 3.14, -2.5';
      case 'char':
        return "Ej: 'a', 'X', '1'";
      case 'bool':
        return 'Ej: true, false';
      case 'string':
        return 'Ej: 100 (tamaño)';
      default:
        return 'Ingrese el valor';
    }
  }

  Widget _buildPreview() {
    String generatedText = _generateVariableText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista Previa del Código:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            generatedText.isEmpty
                ? 'Complete los campos para ver la vista previa'
                : generatedText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    String helpText;

    switch (selectedDeclarationType) {
      case 'declaration':
        helpText = 'Declara una variable sin asignarle un valor inicial. '
            'La variable se puede usar después para almacenar datos.';
        break;
      case 'initialization':
        helpText = 'Declara una variable y le asigna un valor inicial. '
            'Es recomendable inicializar las variables para evitar valores basura.';
        break;
      case 'constant':
        helpText =
            'Declara una constante que no puede cambiar su valor durante la ejecución. '
            'Útil para valores fijos como PI o tamaños máximos.';
        break;
      case 'array':
        helpText =
            'Declara un arreglo que puede almacenar múltiples valores del mismo tipo. '
            'Especifica el tamaño entre corchetes.';
        break;
      default:
        helpText =
            'Escriba manualmente la declaración de variable en sintaxis de C.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              helpText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
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
          Icon(Icons.settings, color: Colors.teal),
          SizedBox(width: 8),
          Text('Configurar Variable'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeclarationTypeSelector(),
              const SizedBox(height: 16),
              _buildInputFields(),
              const SizedBox(height: 16),
              _buildPreview(),
              const SizedBox(height: 16),
              _buildHelpText(),
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
            String result = _generateVariableText();
            if (result.isNotEmpty) {
              Navigator.of(context).pop(NodeDialogResult.simple(result));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
