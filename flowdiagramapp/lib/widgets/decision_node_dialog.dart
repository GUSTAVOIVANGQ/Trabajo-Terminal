import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class DecisionNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const DecisionNodeDialog({super.key, required this.node});

  @override
  State<DecisionNodeDialog> createState() => _DecisionNodeDialogState();
}

class _DecisionNodeDialogState extends State<DecisionNodeDialog> {
  String selectedConditionType = 'comparison'; // Por defecto comparación
  late TextEditingController _variable1Controller;
  late TextEditingController _variable2Controller;
  late TextEditingController _variableController;
  late TextEditingController _valueController;
  late TextEditingController _customTextController;
  String selectedOperator = '>';
  String selectedLogicalOperator = '&&';
  bool useCustomText = false;

  // Tipos de condiciones disponibles
  final Map<String, String> conditionTypes = {
    'comparison': 'Comparar Dos Valores',
    'range': 'Verificar Rango',
    'equality': 'Verificar Igualdad',
    'existence': 'Verificar Existencia',
    'logical': 'Condición Lógica',
    'loop_condition': 'Condición de Bucle',
    'even_odd': 'Par o Impar',
    'positive_negative': 'Positivo o Negativo',
    'custom': 'Escribir Manualmente',
  };

  // Operadores de comparación disponibles
  final Map<String, String> comparisonOperators = {
    '>': 'Mayor que (>)',
    '<': 'Menor que (<)',
    '>=': 'Mayor o igual que (>=)',
    '<=': 'Menor o igual que (<=)',
    '==': 'Igual a (==)',
    '!=': 'Diferente de (!=)',
  };

  // Operadores lógicos disponibles
  final Map<String, String> logicalOperators = {
    '&&': 'Y (&&)',
    '||': 'O (||)',
    '!': 'NO (!)',
  };

  // Rangos predefinidos
  final Map<String, String> rangeTypes = {
    'between': 'Entre dos valores',
    'outside': 'Fuera del rango',
    'positive': 'Es positivo',
    'negative': 'Es negativo',
    'zero': 'Es igual a cero',
  };

  @override
  void initState() {
    super.initState();
    _variable1Controller = TextEditingController();
    _variable2Controller = TextEditingController();
    _variableController = TextEditingController();
    _valueController = TextEditingController();
    _customTextController = TextEditingController(text: widget.node.text);

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Remover signos de interrogación del texto original
    text = text.replaceAll('¿', '').replaceAll('?', '').trim();

    // Detectar comparaciones simples (variable operador valor)
    RegExp comparisonPattern = RegExp(r'^(\w+)\s*(>=|<=|>|<|==|!=)\s*(.+)$');
    Match? match = comparisonPattern.firstMatch(text);

    if (match != null) {
      selectedConditionType = 'comparison';
      _variable1Controller.text = match.group(1) ?? '';
      selectedOperator = match.group(2) ?? '>';
      _variable2Controller.text = match.group(3) ?? '';
      return;
    }

    // Detectar igualdad simple
    RegExp equalityPattern = RegExp(r'^(\w+)\s*==\s*(.+)$');
    match = equalityPattern.firstMatch(text);

    if (match != null) {
      selectedConditionType = 'equality';
      _variableController.text = match.group(1) ?? '';
      _valueController.text = match.group(2) ?? '';
      return;
    }

    // Detectar condiciones de rango
    if (text.contains('>') && text.contains('<')) {
      selectedConditionType = 'range';
      // Intentar extraer la variable del medio
      RegExp rangePattern = RegExp(r'(\d+)\s*<\s*(\w+)\s*<\s*(\d+)');
      match = rangePattern.firstMatch(text);
      if (match != null) {
        _variableController.text = match.group(2) ?? '';
        _variable1Controller.text = match.group(1) ?? '';
        _variable2Controller.text = match.group(3) ?? '';
        return;
      }
    }

    // Detectar condiciones lógicas (con && o ||)
    if (text.contains('&&') || text.contains('||')) {
      selectedConditionType = 'logical';
      if (text.contains('&&')) {
        selectedLogicalOperator = '&&';
      } else {
        selectedLogicalOperator = '||';
      }
      return;
    }

    // Si no coincide con ningún patrón, usar texto personalizado
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
    switch (selectedConditionType) {
      case 'comparison':
        if (_variable1Controller.text.isNotEmpty &&
            _variable2Controller.text.isNotEmpty) {
          return '¿${_variable1Controller.text} $selectedOperator ${_variable2Controller.text}?';
        }
        break;
      case 'equality':
        if (_variableController.text.isNotEmpty &&
            _valueController.text.isNotEmpty) {
          return '¿${_variableController.text} == ${_valueController.text}?';
        }
        break;
      case 'range':
        if (_variableController.text.isNotEmpty &&
            _variable1Controller.text.isNotEmpty &&
            _variable2Controller.text.isNotEmpty) {
          return '¿${_variable1Controller.text} < ${_variableController.text} < ${_variable2Controller.text}?';
        }
        break;
      case 'existence':
        if (_variableController.text.isNotEmpty) {
          return '¿${_variableController.text} existe?';
        }
        break;
      case 'logical':
        if (_variable1Controller.text.isNotEmpty &&
            _variable2Controller.text.isNotEmpty) {
          return '¿${_variable1Controller.text} $selectedLogicalOperator ${_variable2Controller.text}?';
        }
        break;
      case 'loop_condition':
        if (_variableController.text.isNotEmpty &&
            _valueController.text.isNotEmpty) {
          return '¿${_variableController.text} $selectedOperator ${_valueController.text}?';
        }
        break;
      case 'even_odd':
        if (_variableController.text.isNotEmpty) {
          return '¿${_variableController.text} % 2 == 0?';
        }
        break;
      case 'positive_negative':
        if (_variableController.text.isNotEmpty) {
          return '¿${_variableController.text} > 0?';
        }
        break;
      case 'custom':
        return _customTextController.text;
    }
    return '';
  }

  Widget _buildConditionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Condición:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedConditionType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: conditionTypes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedConditionType = value!;
              useCustomText = value == 'custom';
            });
          },
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    if (useCustomText) {
      return _buildCustomFields();
    }

    switch (selectedConditionType) {
      case 'comparison':
        return _buildComparisonFields();
      case 'equality':
        return _buildEqualityFields();
      case 'range':
        return _buildRangeFields();
      case 'existence':
        return _buildExistenceFields();
      case 'logical':
        return _buildLogicalFields();
      case 'loop_condition':
        return _buildLoopConditionFields();
      case 'even_odd':
        return _buildEvenOddFields();
      case 'positive_negative':
        return _buildPositiveNegativeFields();
      default:
        return _buildCustomFields();
    }
  }

  Widget _buildComparisonFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _variable1Controller,
                decoration: const InputDecoration(
                  labelText: 'Primera Variable',
                  hintText: 'ej: edad',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                value: selectedOperator,
                decoration: const InputDecoration(
                  labelText: 'Operador',
                  border: OutlineInputBorder(),
                ),
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
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _variable2Controller,
                decoration: const InputDecoration(
                  labelText: 'Segunda Variable',
                  hintText: 'ej: 18',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEqualityFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a Verificar',
            hintText: 'ej: nombre',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Valor a Comparar',
            hintText: 'ej: "admin"',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildRangeFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a Verificar',
            hintText: 'ej: nota',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _variable1Controller,
                decoration: const InputDecoration(
                  labelText: 'Valor Mínimo',
                  hintText: 'ej: 0',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _variable2Controller,
                decoration: const InputDecoration(
                  labelText: 'Valor Máximo',
                  hintText: 'ej: 100',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExistenceFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a Verificar',
            hintText: 'ej: archivo',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildLogicalFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _variable1Controller,
          decoration: const InputDecoration(
            labelText: 'Primera Condición',
            hintText: 'ej: edad > 18',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedLogicalOperator,
          decoration: const InputDecoration(
            labelText: 'Operador Lógico',
            border: OutlineInputBorder(),
          ),
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
        const SizedBox(height: 12),
        TextField(
          controller: _variable2Controller,
          decoration: const InputDecoration(
            labelText: 'Segunda Condición',
            hintText: 'ej: tiene_licencia == true',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCustomFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextField(
          controller: _customTextController,
          decoration: const InputDecoration(
            labelText: 'Condición Personalizada',
            hintText: '¿Escriba su condición aquí?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vista Previa:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            generatedText.isEmpty
                ? 'Complete los campos para ver la vista previa'
                : generatedText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.black87,
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
          Icon(Icons.help_outline, color: Colors.orange),
          SizedBox(width: 8),
          Text('Editar Nodo de Decisión'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
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
                      'Forma: Rombo/Diamante\n'
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final generatedText = _generateConditionText();
            Navigator.of(context).pop(generatedText);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildLoopConditionFields() {
    return Column(
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
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable de Control',
            hintText: 'ej: contador, i, indice',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.loop),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<String>(
                value: selectedOperator,
                decoration: const InputDecoration(
                  labelText: 'Condición',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '<', child: Text('Menor que (<)')),
                  DropdownMenuItem(
                      value: '<=', child: Text('Menor igual (<=)')),
                  DropdownMenuItem(value: '>', child: Text('Mayor que (>)')),
                  DropdownMenuItem(
                      value: '>=', child: Text('Mayor igual (>=)')),
                  DropdownMenuItem(value: '!=', child: Text('Diferente (!=)')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedOperator = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Valor Límite',
                  hintText: 'ej: 10, limite, maximo',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEvenOddFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '🔢 Verificar Par o Impar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifica si un número es par (divisible por 2) o impar.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a Verificar',
            hintText: 'ej: numero, edad, cantidad',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calculate),
            helperText: 'La condición será: variable % 2 == 0 (es par)',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPositiveNegativeFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '➕➖ Verificar Positivo o Negativo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        const Text(
          'Verifica si un número es positivo (mayor que 0) o negativo.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable a Verificar',
            hintText: 'ej: numero, saldo, diferencia',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.trending_up),
            helperText: 'La condición será: variable > 0 (es positivo)',
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}
