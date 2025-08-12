import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class PreparationNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const PreparationNodeDialog({super.key, required this.node});

  @override
  State<PreparationNodeDialog> createState() => _PreparationNodeDialogState();
}

class _PreparationNodeDialogState extends State<PreparationNodeDialog> {
  String selectedPreparationType =
      'counter_init'; // Por defecto inicialización de contador
  late TextEditingController _variableController;
  late TextEditingController _startValueController;
  late TextEditingController _endValueController;
  late TextEditingController _stepController;
  late TextEditingController _customTextController;
  String selectedLoopType = 'for';
  bool useCustomText = false;

  // Tipos de preparación disponibles
  final Map<String, String> preparationTypes = {
    'counter_init': 'Inicializar Contador',
    'for_loop': 'Bucle FOR (número conocido)',
    'while_setup': 'Configurar WHILE',
    'variable_init': 'Inicializar Variable',
    'array_setup': 'Configurar Arreglo',
    'accumulator': 'Inicializar Acumulador',
    'custom': 'Escribir Manualmente',
  };

  // Tipos de bucles predefinidos
  final Map<String, String> loopTypes = {
    'for': 'FOR (para)',
    'while': 'WHILE (mientras)',
    'do_while': 'DO-WHILE (hacer-mientras)',
  };

  @override
  void initState() {
    super.initState();
    _variableController = TextEditingController();
    _startValueController = TextEditingController(text: '0');
    _endValueController = TextEditingController(text: '10');
    _stepController = TextEditingController(text: '1');
    _customTextController = TextEditingController(text: widget.node.text);

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar bucle FOR
    RegExp forPattern = RegExp(
        r'for\s*\(\s*(\w+)\s*=\s*(\d+)\s*;\s*\w+\s*<\s*(\d+)\s*;\s*\w+\+\+\s*\)');
    Match? match = forPattern.firstMatch(text.toLowerCase());

    if (match != null) {
      selectedPreparationType = 'for_loop';
      selectedLoopType = 'for';
      _variableController.text = match.group(1) ?? 'i';
      _startValueController.text = match.group(2) ?? '0';
      _endValueController.text = match.group(3) ?? '10';
      return;
    }

    // Detectar inicialización de contador simple
    RegExp counterPattern = RegExp(r'^(\w+)\s*=\s*(\d+)$');
    match = counterPattern.firstMatch(text);

    if (match != null) {
      selectedPreparationType = 'counter_init';
      _variableController.text = match.group(1) ?? 'contador';
      _startValueController.text = match.group(2) ?? '0';
      return;
    }

    // Detectar palabras clave de bucles
    if (text.toLowerCase().contains('while') ||
        text.toLowerCase().contains('mientras')) {
      selectedPreparationType = 'while_setup';
      selectedLoopType = 'while';
      return;
    }

    if (text.toLowerCase().contains('for') ||
        text.toLowerCase().contains('para')) {
      selectedPreparationType = 'for_loop';
      selectedLoopType = 'for';
      return;
    }

    // Si no coincide con ningún patrón, usar texto personalizado
    selectedPreparationType = 'custom';
    useCustomText = true;
  }

  @override
  void dispose() {
    _variableController.dispose();
    _startValueController.dispose();
    _endValueController.dispose();
    _stepController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generatePreparationText() {
    switch (selectedPreparationType) {
      case 'counter_init':
        if (_variableController.text.isNotEmpty &&
            _startValueController.text.isNotEmpty) {
          return '${_variableController.text} = ${_startValueController.text}';
        }
        break;
      case 'for_loop':
        if (_variableController.text.isNotEmpty &&
            _startValueController.text.isNotEmpty &&
            _endValueController.text.isNotEmpty) {
          return 'for (${_variableController.text} = ${_startValueController.text}; ${_variableController.text} < ${_endValueController.text}; ${_variableController.text}++)';
        }
        break;
      case 'while_setup':
        if (_variableController.text.isNotEmpty &&
            _startValueController.text.isNotEmpty) {
          return '${_variableController.text} = ${_startValueController.text}';
        }
        break;
      case 'variable_init':
        if (_variableController.text.isNotEmpty &&
            _startValueController.text.isNotEmpty) {
          return '${_variableController.text} = ${_startValueController.text}';
        }
        break;
      case 'array_setup':
        if (_variableController.text.isNotEmpty &&
            _endValueController.text.isNotEmpty) {
          return 'int ${_variableController.text}[${_endValueController.text}]';
        }
        break;
      case 'accumulator':
        if (_variableController.text.isNotEmpty) {
          return '${_variableController.text} = 0';
        }
        break;
      case 'custom':
        return _customTextController.text;
    }
    return '';
  }

  Widget _buildPreparationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Preparación:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedPreparationType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: preparationTypes.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPreparationType = value!;
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

    switch (selectedPreparationType) {
      case 'counter_init':
        return _buildCounterInitFields();
      case 'for_loop':
        return _buildForLoopFields();
      case 'while_setup':
        return _buildWhileSetupFields();
      case 'variable_init':
        return _buildVariableInitFields();
      case 'array_setup':
        return _buildArraySetupFields();
      case 'accumulator':
        return _buildAccumulatorFields();
      default:
        return _buildCustomFields();
    }
  }

  Widget _buildCounterInitFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '🔢 Inicialización de Contador',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configurar una variable que se usará para contar iteraciones.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Contador',
            hintText: 'ej: contador, i, indice',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.looks_one),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _startValueController,
          decoration: const InputDecoration(
            labelText: 'Valor Inicial',
            hintText: 'ej: 0, 1',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.start),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildForLoopFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '🔄 Bucle FOR (Número Conocido de Iteraciones)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configurar un bucle con número predeterminado de repeticiones.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable de Control',
            hintText: 'ej: i, j, contador',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.control_camera),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startValueController,
                decoration: const InputDecoration(
                  labelText: 'Inicio',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _endValueController,
                decoration: const InputDecoration(
                  labelText: 'Fin',
                  hintText: '10',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _stepController,
                decoration: const InputDecoration(
                  labelText: 'Paso',
                  hintText: '1',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWhileSetupFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '🔁 Configuración para Bucle WHILE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
        ),
        const SizedBox(height: 8),
        const Text(
          'Inicializar variables necesarias para el bucle while.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Variable de Condición',
            hintText: 'ej: contador, bandera, continuar',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _startValueController,
          decoration: const InputDecoration(
            labelText: 'Valor Inicial',
            hintText: 'ej: 0, true, 1',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.start),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildVariableInitFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '📝 Inicialización de Variable',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 8),
        const Text(
          'Asignar un valor inicial a una variable antes de usarla.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la Variable',
            hintText: 'ej: suma, resultado, total',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.assignment),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _startValueController,
          decoration: const InputDecoration(
            labelText: 'Valor Inicial',
            hintText: 'ej: 0, "", null',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildArraySetupFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '📊 Configuración de Arreglo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        const Text(
          'Declarar un arreglo con su tamaño.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Arreglo',
            hintText: 'ej: numeros, datos, valores',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.view_list),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _endValueController,
          decoration: const InputDecoration(
            labelText: 'Tamaño del Arreglo',
            hintText: 'ej: 10, 100',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAccumulatorFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          '📈 Inicializar Acumulador',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        const SizedBox(height: 8),
        const Text(
          'Variable para acumular valores (suma, producto, etc.).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variableController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Acumulador',
            hintText: 'ej: suma, total, producto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.add_box),
            helperText: 'Se inicializará en 0',
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
        const Text(
          '✏️ Texto Personalizado',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customTextController,
          decoration: const InputDecoration(
            labelText: 'Texto del Nodo',
            hintText: 'Escriba el código manualmente',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.code),
          ),
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    final generatedText = _generatePreparationText();

    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Vista Previa:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Text(
                generatedText.isEmpty ? '(Vacío)' : generatedText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nodo de Preparación/Inicialización'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔶 Nodo de Preparación/Inicialización',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Forma: Hexágono\n'
                      'Uso: Inicializar contadores, configurar bucles\n'
                      'Propósito: Preparar variables antes de procesos iterativos',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildPreparationTypeSelector(),
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
            final generatedText = _generatePreparationText();
            Navigator.of(context).pop(generatedText);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
