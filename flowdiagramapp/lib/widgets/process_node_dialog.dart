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
  final _formKey = GlobalKey<FormState>();

  String selectedOperationType = 'assignment';
  late TextEditingController _variable1Controller;
  late TextEditingController _variable2Controller;
  late TextEditingController _resultController;
  late TextEditingController _valueController;
  late TextEditingController _customTextController;
  String selectedOperator = '+';
  bool useCustomText = false;

  final Map<String, String> operationTypes = {
    'assignment': '📝 Asignación Simple (x = 10)',
    'arithmetic': '🔢 Operación Matemática (a = b + c)',
    'increment': '➕ Incrementar en 1 (x++)',
    'decrement': '➖ Decrementar en 1 (x--)',
    'custom': '✏️ Escribir Manualmente',
  };

  final Map<String, String> operators = {
    '+': 'Sumar (+)',
    '-': 'Restar (-)',
    '*': 'Multiplicar (×)',
    '/': 'Dividir (÷)',
    '%': 'Módulo (%)',
  };

  @override
  void initState() {
    super.initState();
    _variable1Controller = TextEditingController();
    _variable2Controller = TextEditingController();
    _resultController = TextEditingController();
    _valueController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar operación aritmética
    RegExp arithmeticPattern = RegExp(r'^(\w+)\s*=\s*(\w+)\s*([+\-*/%])\s*(\w+)$');
    Match? match = arithmeticPattern.firstMatch(text);

    if (match != null) {
      selectedOperationType = 'arithmetic';
      _resultController.text = match.group(1) ?? '';
      _variable1Controller.text = match.group(2) ?? '';
      selectedOperator = match.group(3) ?? '+';
      _variable2Controller.text = match.group(4) ?? '';
      return;
    }

    // Detectar asignación simple (ignorar declaraciones de variables manejadas en VariableNodeDialog)
    if (!text.startsWith('int ') && !text.startsWith('float ') && !text.startsWith('char ') && !text.startsWith('bool ') && !text.startsWith('const ') && !text.startsWith('double ')) {
      RegExp assignmentPattern = RegExp(r'^(\w+)\s*=\s*(.+)$');
      match = assignmentPattern.firstMatch(text);

      if (match != null) {
        selectedOperationType = 'assignment';
        _resultController.text = match.group(1) ?? '';
        _valueController.text = match.group(2) ?? '';
        return;
      }

      // Detectar incremento/decremento
      if (text.endsWith('++') || text.contains('=') && text.contains('+ 1') && text.contains(text.split('=')[0].trim())) {
        selectedOperationType = 'increment';
        _resultController.text = text.replaceAll(RegExp(r'[+=\s1]'), '');
        return;
      }

      if (text.endsWith('--') || text.contains('=') && text.contains('- 1') && text.contains(text.split('=')[0].trim())) {
        selectedOperationType = 'decrement';
        _resultController.text = text.replaceAll(RegExp(r'[-=\s1]'), '');
        return;
      }
    }

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
    super.dispose();
  }

  String _generateProcessText() {
    if (useCustomText || selectedOperationType == 'custom') {
      return _customTextController.text;
    }

    switch (selectedOperationType) {
      case 'assignment':
        if (_resultController.text.isNotEmpty && _valueController.text.isNotEmpty) {
          return '${_resultController.text} = ${_valueController.text}';
        }
        break;
      case 'arithmetic':
        if (_resultController.text.isNotEmpty && _variable1Controller.text.isNotEmpty && _variable2Controller.text.isNotEmpty) {
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
    }
    return '';
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value)) {
      return 'Inválido';
    }
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requerido';
    return null;
  }

  Widget _buildOperationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué acción realizará este proceso?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
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
    if (useCustomText || selectedOperationType == 'custom') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proceso Personalizado:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _customTextController,
            decoration: const InputDecoration(
              labelText: 'Código del proceso',
              hintText: 'Ej: x = a + b * c',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.code),
            ),
            maxLines: 2,
            onChanged: (v) => setState(() {}),
            validator: _validateRequired,
          ),
        ],
      );
    }

    switch (selectedOperationType) {
      case 'assignment':
        return _buildAssignmentFields();
      case 'arithmetic':
        return _buildArithmeticFields();
      case 'increment':
      case 'decrement':
        return _buildIncrementDecrementFields();
      default:
        return Container();
    }
  }

  Widget _buildAssignmentFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configurar asignación:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _resultController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  hintText: 'Ej: x',
                  border: OutlineInputBorder(),
                ),
                validator: _validateIdentifier,
                onChanged: (v) => setState(() {}),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 15, left: 12, right: 12),
              child: Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor o Expresión',
                  hintText: 'Ej: 10, y, "Hola"',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (v) => setState(() {}),
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
        const Text('Configurar operación matemática:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _resultController,
          decoration: const InputDecoration(
            labelText: 'Variable que guardará el resultado',
            hintText: 'Ej: suma, total',
            border: OutlineInputBorder(),
          ),
          validator: _validateIdentifier,
          onChanged: (v) => setState(() {}),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: Text('=', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _variable1Controller,
                decoration: const InputDecoration(
                  labelText: 'Valor 1',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (v) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
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
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _variable2Controller,
                decoration: const InputDecoration(
                  labelText: 'Valor 2',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (v) => setState(() {}),
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
          isIncrement ? 'Variable a incrementar:' : 'Variable a decrementar:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _resultController,
          decoration: InputDecoration(
            labelText: 'Variable',
            hintText: 'Ej: contador, i',
            border: const OutlineInputBorder(),
            suffixText: isIncrement ? '++' : '--',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          validator: _validateIdentifier,
          onChanged: (v) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    String previewText = _generateProcessText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista Previa del Código:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(
            previewText.isEmpty ? 'Completa los campos' : '$previewText;',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: previewText.isEmpty ? Colors.grey : Colors.black87,
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
          Icon(Icons.settings_applications, color: Colors.deepOrange),
          SizedBox(width: 8),
          Text('Configurar Proceso'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'El proceso modifica el valor de variables ya existentes.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String result = _generateProcessText();
              Navigator.of(context).pop(NodeDialogResult.simple(result));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
