import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../models/node_dialog_result.dart';

class DecisionNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const DecisionNodeDialog({super.key, required this.node});

  @override
  State<DecisionNodeDialog> createState() => _DecisionNodeDialogState();
}

class _DecisionNodeDialogState extends State<DecisionNodeDialog> {
  final _formKey = GlobalKey<FormState>();

  String selectedConditionType = 'comparison';
  late TextEditingController _variable1Controller;
  late TextEditingController _variable2Controller;
  late TextEditingController _variableController;
  late TextEditingController _valueController;
  late TextEditingController _customTextController;
  String selectedOperator = '>';
  String selectedLogicalOperator = '&&';
  bool useCustomText = false;

  final Map<String, String> conditionTypes = {
    'comparison': '⚖️ Comparación Simple (ej. x > 10, a == b)',
    'logical': '🧠 Condición Múltiple (&&, ||)',
    'loop_condition': '🔄 Bucle Automático (Generar estructura)',
    'custom': '✏️ Escribir Manualmente',
  };

  final Map<String, String> comparisonOperators = {
    '>': 'Mayor que (>)',
    '<': 'Menor que (<)',
    '>=': 'Mayor o igual (>=)',
    '<=': 'Menor o igual (<=)',
    '==': 'Igual a (==)',
    '!=': 'Diferente (!=)',
  };

  final Map<String, String> logicalOperators = {
    '&&': 'Y (&&)',
    '||': 'O (||)',
    '!': 'NO (!)',
  };

  @override
  void initState() {
    super.initState();
    _variable1Controller = TextEditingController();
    _variable2Controller = TextEditingController();
    _variableController = TextEditingController();
    _valueController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    text = text.replaceAll('¿', '').replaceAll('?', '').trim();

    if (text.contains('&&') || text.contains('||')) {
      selectedConditionType = 'logical';
      if (text.contains('&&')) {
        selectedLogicalOperator = '&&';
      } else {
        selectedLogicalOperator = '||';
      }
      return;
    }

    RegExp comparisonPattern = RegExp(r'^(\w+)\s*(>=|<=|>|<|==|!=)\s*(.+)$');
    Match? match = comparisonPattern.firstMatch(text);

    if (match != null) {
      selectedConditionType = 'comparison';
      _variable1Controller.text = match.group(1) ?? '';
      selectedOperator = match.group(2) ?? '>';
      _variable2Controller.text = match.group(3) ?? '';
      return;
    }

    selectedConditionType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variable1Controller.dispose();
    _variable2Controller.dispose();
    _variableController.dispose();
    _valueController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generateConditionText() {
    if (useCustomText || selectedConditionType == 'custom') {
      return _customTextController.text;
    }

    switch (selectedConditionType) {
      case 'comparison':
        if (_variable1Controller.text.isNotEmpty && _variable2Controller.text.isNotEmpty) {
          return '¿${_variable1Controller.text} $selectedOperator ${_variable2Controller.text}?';
        }
        break;
      case 'logical':
        if (_variable1Controller.text.isNotEmpty && _variable2Controller.text.isNotEmpty) {
          return '¿${_variable1Controller.text} $selectedLogicalOperator ${_variable2Controller.text}?';
        }
        break;
      case 'loop_condition':
        if (_variableController.text.isNotEmpty && _valueController.text.isNotEmpty) {
          return '¿${_variableController.text} $selectedOperator ${_valueController.text}?';
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

  Widget _buildConditionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué tipo de decisión quieres evaluar?',
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
              value: selectedConditionType,
              isExpanded: true,
              items: conditionTypes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedConditionType = newValue!;
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
    if (useCustomText || selectedConditionType == 'custom') {
      return _buildCustomFields();
    }

    switch (selectedConditionType) {
      case 'comparison':
        return _buildComparisonFields();
      case 'logical':
        return _buildLogicalFields();
      case 'loop_condition':
        return _buildLoopConditionFields();
      default:
        return _buildCustomFields();
    }
  }

  Widget _buildComparisonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Configurar comparación:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _variable1Controller,
                decoration: const InputDecoration(
                  labelText: 'Valor 1',
                  hintText: 'ej: edad',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
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
                    items: comparisonOperators.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOperator = value!;
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
                  hintText: 'ej: 18',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogicalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Unir dos condiciones lógicas:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextFormField(
          controller: _variable1Controller,
          decoration: const InputDecoration(
            labelText: 'Primera Condición',
            hintText: 'ej: edad > 18',
            border: OutlineInputBorder(),
          ),
          validator: _validateRequired,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLogicalOperator,
              isExpanded: true,
              items: logicalOperators.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLogicalOperator = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _variable2Controller,
          decoration: const InputDecoration(
            labelText: 'Segunda Condición',
            hintText: 'ej: tiene_licencia == true',
            border: OutlineInputBorder(),
          ),
          validator: _validateRequired,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildLoopConditionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '🔄 Condición de Bucle',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        const Text(
          'Esta condición se evaluará en cada iteración del bucle.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable de Control',
            hintText: 'ej: contador, i',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.loop),
          ),
          validator: _validateIdentifier,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    items: const [
                      DropdownMenuItem(value: '<', child: Text('Menor que (<)')),
                      DropdownMenuItem(value: '<=', child: Text('Menor igual (<=)')),
                      DropdownMenuItem(value: '>', child: Text('Mayor que (>)?')),
                      DropdownMenuItem(value: '>=', child: Text('Mayor igual (>=)')),
                      DropdownMenuItem(value: '!=', child: Text('Diferente (!=)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedOperator = value!;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor Límite',
                  hintText: 'ej: 10, maximo',
                  border: OutlineInputBorder(),
                ),
                validator: _validateRequired,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Escribir condición manualmente:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _customTextController,
          decoration: const InputDecoration(
            labelText: 'Condición',
            hintText: 'ej: x == 5 && y > 10',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.code),
          ),
          maxLines: 2,
          validator: _validateRequired,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final generatedText = _generateConditionText();
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
            'Vista Previa:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(
            generatedText.isEmpty ? 'Completa los campos' : generatedText,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: generatedText.isEmpty ? Colors.grey : Colors.black87,
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
          Icon(Icons.call_split, color: Colors.orange),
          SizedBox(width: 8),
          Text('Editar Nodo de Decisión'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Nodo de Decisión',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Uso: Preguntas, condiciones, comparaciones\n'
                        'Salidas: Dos o más ramas (Sí/No, Verdadero/Falso)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildConditionTypeSelector(),
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
              final generatedText = _generateConditionText();

              if (selectedConditionType == 'loop_condition' &&
                  _variableController.text.isNotEmpty &&
                  _valueController.text.isNotEmpty) {
                final result = NodeDialogResult(
                  text: generatedText,
                  generateLoopStructure: true,
                  loopVariable: _variableController.text,
                  loopLimit: _valueController.text,
                  loopCondition: selectedOperator,
                );
                Navigator.of(context).pop(result);
              } else {
                Navigator.of(context).pop(generatedText);
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
