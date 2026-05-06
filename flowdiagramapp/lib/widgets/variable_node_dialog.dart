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
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _arraySizeController;

  String _selectedDataType = 'int';
  bool _isConstant = false;
  bool _isArray = false;

  final Map<String, String> _dataTypes = {
    'int': 'Número entero (Ej. 5)',
    'float': 'Número decimal (Ej. 3.14)',
    'char': 'Un solo carácter (Ej. a)',
    'string': 'Texto o palabra (Ej. Hola)',
    'bool': 'Verdadero o Falso (true/false)',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _valueController = TextEditingController();
    _arraySizeController = TextEditingController(text: '10');

    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar si es constante
    if (text.startsWith('const ')) {
      _isConstant = true;
      text = text.substring(6).trim();
    }

    // Buscar tipo de dato
    String foundType = 'int';
    for (String type in ['int', 'float', 'double', 'char', 'bool']) {
      if (text.startsWith('$type ')) {
        foundType = type;
        text = text.substring(type.length).trim();
        break;
      }
    }

    // Detectar si es un arreglo de char (string)
    if (foundType == 'char' && (text.contains('[') || text.contains('*'))) {
      _selectedDataType = 'string';
      _isArray = false; // Manejado internamente como string
    } else {
      if (foundType == 'double') foundType = 'float'; // Simplificar a float para UI
      _selectedDataType = foundType;
    }

    // Detectar arreglo genérico
    if (text.contains('[') && text.contains(']')) {
      if (_selectedDataType != 'string') {
        _isArray = true;
      }
      
      RegExp arrayPattern = RegExp(r'^(\w+)\[(\d+)\]');
      Match? match = arrayPattern.firstMatch(text);
      if (match != null) {
        _nameController.text = match.group(1) ?? '';
        _arraySizeController.text = match.group(2) ?? '10';
        text = text.substring(match.end).trim();
        if (text.startsWith('=')) {
          _valueController.text = text.substring(1).trim();
        }
        return;
      }
    }

    // Variable normal con o sin inicialización
    RegExp varPattern = RegExp(r'^(\w+)\s*(?:=\s*(.+))?$');
    Match? match = varPattern.firstMatch(text);
    if (match != null) {
      _nameController.text = match.group(1) ?? '';
      _valueController.text = match.group(2) ?? '';
    } else {
      // Fallback
      _nameController.text = text.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _arraySizeController.dispose();
    super.dispose();
  }

  String _generateVariableText() {
    if (_nameController.text.trim().isEmpty) return '';

    String prefix = _isConstant ? 'const ' : '';
    String type = _selectedDataType == 'string' ? 'char' : _selectedDataType;
    String name = _nameController.text.trim();
    
    String declaration;
    if (_selectedDataType == 'string') {
      String size = _arraySizeController.text.trim().isEmpty ? '100' : _arraySizeController.text.trim();
      declaration = '$prefix$type $name[$size]';
    } else if (_isArray) {
      String size = _arraySizeController.text.trim().isEmpty ? '10' : _arraySizeController.text.trim();
      declaration = '$prefix$type $name[$size]';
    } else {
      declaration = '$prefix$type $name';
    }

    String value = _valueController.text.trim();
    if (value.isNotEmpty) {
      // Basic formatting for strings/chars if user forgot quotes
      if (_selectedDataType == 'string' && !value.startsWith('"') && !value.startsWith('{')) {
        value = '"$value"';
      } else if (_selectedDataType == 'char' && !value.startsWith("'") && value.length == 1) {
        value = "'$value'";
      }
      return '$declaration = $value';
    }

    return declaration;
  }

  String? _validateVariableName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value)) {
      return 'Solo letras, números y guiones bajos. No debe empezar con número.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.data_object, color: Colors.blue),
          SizedBox(width: 8),
          Text('Crear Variable'),
        ],
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de dato que almacenará:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                      value: _selectedDataType,
                      isExpanded: true,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDataType = value!;
                          if (value == 'string') {
                            _isArray = false; // String ya es un arreglo de chars
                          }
                        });
                      },
                      items: _dataTypes.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la variable',
                    hintText: 'Ej: edad, nombre, contador',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                  validator: _validateVariableName,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: 'Valor inicial (Opcional)',
                    hintText: _selectedDataType == 'int' ? 'Ej: 0' : 
                              _selectedDataType == 'string' ? 'Ej: "Hola"' : 'Dejar en blanco si no tiene valor aún',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                
                // Opciones avanzadas
                ExpansionTile(
                  title: const Text('Opciones Adicionales', style: TextStyle(fontSize: 14)),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    CheckboxListTile(
                      title: const Text('Es un valor constante (No cambiará)'),
                      value: _isConstant,
                      onChanged: (val) => setState(() => _isConstant = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_selectedDataType != 'string')
                      CheckboxListTile(
                        title: const Text('Es una lista/arreglo (Múltiples valores)'),
                        value: _isArray,
                        onChanged: (val) => setState(() => _isArray = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    if (_isArray || _selectedDataType == 'string')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: TextFormField(
                          controller: _arraySizeController,
                          decoration: InputDecoration(
                            labelText: _selectedDataType == 'string' ? 'Longitud máxima del texto' : 'Cantidad de elementos en la lista',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                  ],
                ),
                
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
              String result = _generateVariableText();
              Navigator.of(context).pop(NodeDialogResult.simple(result));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    String generatedText = _generateVariableText();

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
            'Vista Previa del Código en C:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(
            generatedText.isEmpty ? 'Escribe un nombre para ver el código' : '$generatedText;',
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
}

