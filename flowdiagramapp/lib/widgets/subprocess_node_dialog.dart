import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class SubprocessNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const SubprocessNodeDialog({super.key, required this.node});

  @override
  State<SubprocessNodeDialog> createState() => _SubprocessNodeDialogState();
}

class _SubprocessNodeDialogState extends State<SubprocessNodeDialog> {
  late TextEditingController _functionNameController;
  late TextEditingController _parametersController;
  late TextEditingController _customTextController;
  String selectedSubprocessType =
      'function_call'; // Por defecto llamada a función
  bool useCustomText = false;

  // Tipos de subprocesos disponibles
  final Map<String, String> subprocessTypes = {
    'function_call': 'Llamada a Función',
    'function_with_params': 'Función con Parámetros',
    'function_with_return': 'Función con Retorno',
    'predefined': 'Función Predefinida',
    'custom': 'Escribir Manualmente',
  };

  // Funciones predefinidas comunes
  final Map<String, String> predefinedFunctions = {
    'calcularPromedio': 'calcularPromedio(datos, n)',
    'ordenarArreglo': 'ordenarArreglo(arr, tam)',
    'buscarElemento': 'buscarElemento(arr, tam, valor)',
    'factorial': 'factorial(n)',
    'fibonacci': 'fibonacci(n)',
    'esPrimo': 'esPrimo(numero)',
    'potencia': 'potencia(base, exponente)',
    'maximoComunDivisor': 'maximoComunDivisor(a, b)',
  };

  String selectedPredefinedFunction = 'calcularPromedio';

  @override
  void initState() {
    super.initState();
    _functionNameController = TextEditingController();
    _parametersController = TextEditingController();
    _customTextController = TextEditingController();

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) {
      return;
    }

    // Detectar el tipo de subproceso por el formato
    if (text.contains('(') && text.contains(')')) {
      final openParen = text.indexOf('(');
      final closeParen = text.lastIndexOf(')');

      _functionNameController.text = text.substring(0, openParen).trim();

      if (openParen < closeParen - 1) {
        // Tiene parámetros
        String params = text.substring(openParen + 1, closeParen).trim();
        _parametersController.text = params;

        if (params.isNotEmpty) {
          if (text.contains('=') || text.contains('return')) {
            selectedSubprocessType = 'function_with_return';
          } else {
            selectedSubprocessType = 'function_with_params';
          }
        } else {
          selectedSubprocessType = 'function_call';
        }
      } else {
        selectedSubprocessType = 'function_call';
      }

      // Verificar si es una función predefinida
      if (predefinedFunctions.containsValue(text)) {
        selectedSubprocessType = 'predefined';
        selectedPredefinedFunction = predefinedFunctions.entries
            .firstWhere((entry) => entry.value == text)
            .key;
      }
    } else {
      // No tiene formato de función, usar como texto personalizado
      _customTextController.text = text;
      selectedSubprocessType = 'custom';
    }
  }

  @override
  void dispose() {
    _functionNameController.dispose();
    _parametersController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  String _generateSubprocessText() {
    switch (selectedSubprocessType) {
      case 'function_call':
        String name = _functionNameController.text.trim();
        return name.isEmpty ? 'nombreFuncion()' : '$name()';

      case 'function_with_params':
        String name = _functionNameController.text.trim();
        String params = _parametersController.text.trim();
        if (name.isEmpty) name = 'nombreFuncion';
        if (params.isEmpty) params = 'parametros';
        return '$name($params)';

      case 'function_with_return':
        String name = _functionNameController.text.trim();
        String params = _parametersController.text.trim();
        if (name.isEmpty) name = 'nombreFuncion';
        if (params.isEmpty) params = 'parametros';
        return 'resultado = $name($params)';

      case 'predefined':
        return predefinedFunctions[selectedPredefinedFunction]!;

      case 'custom':
        String custom = _customTextController.text.trim();
        return custom.isEmpty ? 'nombreFuncion()' : custom;

      default:
        return 'nombreFuncion()';
    }
  }

  Widget _buildSubprocessTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Subproceso',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...subprocessTypes.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: selectedSubprocessType,
            onChanged: (value) {
              setState(() {
                selectedSubprocessType = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildInputFields() {
    switch (selectedSubprocessType) {
      case 'function_call':
        return _buildFunctionCallFields();
      case 'function_with_params':
        return _buildFunctionWithParamsFields();
      case 'function_with_return':
        return _buildFunctionWithReturnFields();
      case 'predefined':
        return _buildPredefinedFunctionSelector();
      case 'custom':
        return _buildCustomFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFunctionCallFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Función',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _functionNameController,
          decoration: const InputDecoration(
            hintText: 'Ej: calcularTotal',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildFunctionWithParamsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Función',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _functionNameController,
          decoration: const InputDecoration(
            hintText: 'Ej: calcularPromedio',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text(
          'Parámetros',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _parametersController,
          decoration: const InputDecoration(
            hintText: 'Ej: numeros, cantidad',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildFunctionWithReturnFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Función',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _functionNameController,
          decoration: const InputDecoration(
            hintText: 'Ej: calcularArea',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        const Text(
          'Parámetros',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _parametersController,
          decoration: const InputDecoration(
            hintText: 'Ej: base, altura',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPredefinedFunctionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Función Predefinida',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedPredefinedFunction,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
          ),
          items: predefinedFunctions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPredefinedFunction = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Texto Personalizado',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customTextController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Ej: procesarDatos(array, n)',
            border: OutlineInputBorder(),
            filled: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Vista Previa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _generateSubprocessText(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpText() {
    String helpText;
    switch (selectedSubprocessType) {
      case 'function_call':
        helpText = 'Llamada simple a una función sin parámetros.';
        break;
      case 'function_with_params':
        helpText = 'Función que recibe parámetros. Separar con comas.';
        break;
      case 'function_with_return':
        helpText = 'Función que retorna un valor. Se asignará a "resultado".';
        break;
      case 'predefined':
        helpText = 'Funciones matemáticas y de utilidad predefinidas.';
        break;
      case 'custom':
        helpText = 'Escribe la llamada a función manualmente.';
        break;
      default:
        helpText = 'Selecciona un tipo de subproceso.';
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
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
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
          Icon(Icons.account_tree, color: Colors.purple[700]),
          const SizedBox(width: 8),
          const Text('Editar Subproceso/Función'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubprocessTypeSelector(),
              const SizedBox(height: 20),
              _buildInputFields(),
              const SizedBox(height: 20),
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
        ElevatedButton(
          onPressed: () {
            widget.node.text = _generateSubprocessText();
            Navigator.of(context).pop(widget.node);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
