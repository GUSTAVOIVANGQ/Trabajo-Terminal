import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../models/node_dialog_result.dart';

class ProcessNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const ProcessNodeDialog({super.key, required this.node});

  @override
  State<ProcessNodeDialog> createState() => _ProcessNodeDialogState();
}

class _ProcessNodeDialogState extends State<ProcessNodeDialog> {
  String selectedOperationType = 'assignment'; // Por defecto asignación
  late TextEditingController _variable1Controller;
  late TextEditingController _variable2Controller;
  late TextEditingController _resultController;
  late TextEditingController _valueController;
  late TextEditingController _customTextController;
  late TextEditingController _variableNameController;
  String selectedOperator = '+';
  String selectedDataType = 'int';
  bool useCustomText = false;

  // Tipos de operaciones disponibles (proceso + variable)
  final Map<String, String> operationTypes = {
    // Operaciones de PROCESO
    'assignment': '📝 Asignación Simple',
    'arithmetic': '🔢 Operación Matemática',
    'increment': '➕ Incrementar Variable',
    'decrement': '➖ Decrementar Variable',

    // Operaciones de VARIABLE (declaración)
    'declaration': '🏷️ Declarar Variable',
    'initialization': '🎯 Declarar e Inicializar',
    'constant': '🔒 Declarar Constante',
    'array': '📊 Declarar Arreglo',

    'custom': '✏️ Escribir Manualmente',
  };

  // Operadores matemáticos disponibles
  final Map<String, String> operators = {
    '+': 'Sumar (+)',
    '-': 'Restar (-)',
    '*': 'Multiplicar (×)',
    '/': 'Dividir (÷)',
    '%': 'Módulo (%)',
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
    _variable1Controller = TextEditingController();
    _variable2Controller = TextEditingController();
    _resultController = TextEditingController();
    _valueController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);
    _variableNameController = TextEditingController();

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
      selectedOperationType = 'initialization';
      selectedDataType = match.group(1) ?? 'int';
      _variableNameController.text = match.group(2) ?? '';
      _valueController.text = match.group(3) ?? '';
      return;
    }

    // Detectar declaración simple
    RegExp declPattern = RegExp(r'^(int|float|double|char|bool)\s+(\w+)$');
    match = declPattern.firstMatch(text);

    if (match != null) {
      selectedOperationType = 'declaration';
      selectedDataType = match.group(1) ?? 'int';
      _variableNameController.text = match.group(2) ?? '';
      return;
    }

    // Detectar constante
    if (text.contains('const')) {
      RegExp constPattern =
          RegExp(r'^const\s+(int|float|double|char|bool)\s+(\w+)\s*=\s*(.+)$');
      match = constPattern.firstMatch(text);

      if (match != null) {
        selectedOperationType = 'constant';
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
        selectedOperationType = 'array';
        selectedDataType = match.group(1) ?? 'int';
        _variableNameController.text = match.group(2) ?? '';
        _valueController.text = match.group(3) ?? '';
        return;
      }
    }

    // Detectar si es una operación aritmética simple
    RegExp arithmeticPattern =
        RegExp(r'^(\w+)\s*=\s*(\w+)\s*([+\-*/])\s*(\w+)$');
    match = arithmeticPattern.firstMatch(text);

    if (match != null) {
      selectedOperationType = 'arithmetic';
      _resultController.text = match.group(1) ?? '';
      _variable1Controller.text = match.group(2) ?? '';
      selectedOperator = match.group(3) ?? '+';
      _variable2Controller.text = match.group(4) ?? '';
      return;
    }

    // Detectar asignación simple
    RegExp assignmentPattern = RegExp(r'^(\w+)\s*=\s*(.+)$');
    match = assignmentPattern.firstMatch(text);

    if (match != null) {
      selectedOperationType = 'assignment';
      _resultController.text = match.group(1) ?? '';
      _valueController.text = match.group(2) ?? '';
      return;
    }

    // Detectar incremento/decremento
    if (text.contains('++') || text.contains('+ 1')) {
      selectedOperationType = 'increment';
      String varName = text.replaceAll(RegExp(r'[+=\s1]'), '');
      _resultController.text = varName;
      return;
    }

    if (text.contains('--') || text.contains('- 1')) {
      selectedOperationType = 'decrement';
      String varName = text.replaceAll(RegExp(r'[-=\s1]'), '');
      _resultController.text = varName;
      return;
    }

    // Si no coincide con ningún patrón, usar texto personalizado
    selectedOperationType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variable1Controller.dispose();
    _variable2Controller.dispose();
    _resultController.dispose();
    _valueController.dispose();
    _customTextController.dispose();
    _variableNameController.dispose();
    super.dispose();
  }

  String _generateProcessText() {
    switch (selectedOperationType) {
      // PROCESO
      case 'assignment':
        if (_resultController.text.isNotEmpty &&
            _valueController.text.isNotEmpty) {
          return '${_resultController.text} = ${_valueController.text}';
        }
        break;
      case 'arithmetic':
        if (_resultController.text.isNotEmpty &&
            _variable1Controller.text.isNotEmpty &&
            _variable2Controller.text.isNotEmpty) {
          return '${_resultController.text} = ${_variable1Controller.text} $selectedOperator ${_variable2Controller.text}';
        }
        break;
      case 'increment':
        if (_resultController.text.isNotEmpty) {
          return '${_resultController.text} = ${_resultController.text} + 1';
        }
        break;
      case 'decrement':
        if (_resultController.text.isNotEmpty) {
          return '${_resultController.text} = ${_resultController.text} - 1';
        }
        break;

      // VARIABLE (declaración)
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

      case 'custom':
        return _customTextController.text;
    }
    return '';
  }

  Widget _buildOperationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de operación:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
              value: selectedOperationType,
              isExpanded: true,
              items: operationTypes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOperationType = newValue!;
                  useCustomText = newValue == 'custom';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    if (useCustomText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escribir proceso personalizado:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customTextController,
            decoration: const InputDecoration(
              labelText: 'Proceso',
              hintText: 'Ej: suma = a + b o int contador = 0',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      );
    }

    switch (selectedOperationType) {
      // PROCESO
      case 'assignment':
        return _buildAssignmentFields();
      case 'arithmetic':
        return _buildArithmeticFields();
      case 'increment':
      case 'decrement':
        return _buildIncrementDecrementFields();

      // VARIABLE
      case 'declaration':
        return _buildDeclarationFields();
      case 'initialization':
        return _buildInitializationFields();
      case 'constant':
        return _buildConstantFields();
      case 'array':
        return _buildArrayFields();

      default:
        return Container();
    }
  }

  Widget _buildAssignmentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asignar valor a variable:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _resultController,
                decoration: const InputDecoration(
                  labelText: 'Variable',
                  hintText: 'nombre',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('=', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  hintText: '10 o edad',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArithmeticFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operación matemática:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _resultController,
                decoration: const InputDecoration(
                  labelText: 'Resultado',
                  hintText: 'suma',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('=', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _variable1Controller,
                decoration: const InputDecoration(
                  labelText: 'Variable 1',
                  hintText: 'a',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedOperator,
                    isExpanded: true,
                    items: operators.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOperator = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _variable2Controller,
                decoration: const InputDecoration(
                  labelText: 'Variable 2',
                  hintText: 'b',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncrementDecrementFields() {
    bool isIncrement = selectedOperationType == 'increment';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isIncrement
              ? 'Incrementar variable en 1:'
              : 'Decrementar variable en 1:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _resultController,
          decoration: InputDecoration(
            labelText: 'Variable',
            hintText: 'contador',
            border: const OutlineInputBorder(),
            suffixText: isIncrement ? '+ 1' : '- 1',
          ),
        ),
      ],
    );
  }

  // ===== NUEVOS BUILDERS PARA VARIABLE =====

  Widget _buildDeclarationFields() {
    return Column(
      children: [
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildVariableNameField(),
      ],
    );
  }

  Widget _buildInitializationFields() {
    return Column(
      children: [
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildVariableNameField(),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Valor Inicial',
            hintText: 'Ej: 0, 3.14, true',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildConstantFields() {
    return Column(
      children: [
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildVariableNameField(),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Valor de la Constante',
            hintText: 'Ej: 10, 3.1416',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildArrayFields() {
    return Column(
      children: [
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildVariableNameField(),
        const SizedBox(height: 16),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Tamaño del arreglo',
            hintText: 'Ej: 10, 50, 100',
            border: OutlineInputBorder(),
          ),
        ),
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
        ),
      ],
    );
  }

  Widget _buildPreview() {
    String previewText = _generateProcessText();
    if (previewText.isEmpty) return Container();

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
            'Vista previa:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            previewText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              color: Colors.blue,
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
          Icon(Icons.settings, color: Colors.blue),
          SizedBox(width: 8),
          Text('Configurar Proceso'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Un proceso realiza operaciones, cálculos, asignaciones o declaraciones de variables.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildOperationTypeSelector(),
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
            String result = _generateProcessText();
            Navigator.of(context).pop(NodeDialogResult.simple(result));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
