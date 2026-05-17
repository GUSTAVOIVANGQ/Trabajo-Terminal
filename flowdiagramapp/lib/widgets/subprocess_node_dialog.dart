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
  late TextEditingController _returnVarController;
  bool _hasParameters = false;
  bool _hasReturn = false;

  @override
  void initState() {
    super.initState();
    _functionNameController = TextEditingController();
    _parametersController = TextEditingController();
    _returnVarController = TextEditingController();
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar patrón: resultado = funcion(params)
    final withReturn = RegExp(r'^(\w+)\s*=\s*(\w+)\s*\(([^)]*)\)$');
    final m1 = withReturn.firstMatch(text);
    if (m1 != null) {
      _returnVarController.text = m1.group(1)!.trim();
      _functionNameController.text = m1.group(2)!.trim();
      final params = m1.group(3)!.trim();
      if (params.isNotEmpty) {
        _parametersController.text = params;
        _hasParameters = true;
      }
      _hasReturn = true;
      return;
    }

    // Detectar patrón: funcion(params)
    final withParams = RegExp(r'^(\w+)\s*\(([^)]*)\)$');
    final m2 = withParams.firstMatch(text);
    if (m2 != null) {
      _functionNameController.text = m2.group(1)!.trim();
      final params = m2.group(2)!.trim();
      if (params.isNotEmpty) {
        _parametersController.text = params;
        _hasParameters = true;
      }
      return;
    }

    // Texto simple sin paréntesis
    _functionNameController.text = text;
  }

  @override
  void dispose() {
    _functionNameController.dispose();
    _parametersController.dispose();
    _returnVarController.dispose();
    super.dispose();
  }

  String _generateText() {
    final name = _functionNameController.text.trim();
    if (name.isEmpty) return '';

    final params = _hasParameters ? _parametersController.text.trim() : '';
    final call = '$name($params)';

    if (_hasReturn) {
      final ret = _returnVarController.text.trim();
      if (ret.isNotEmpty) return '$ret = $call';
    }
    return call;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _generateText();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_tree, color: Colors.purple[700]),
          const SizedBox(width: 8),
          const Text('Proceso Predefinido'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Explicación
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Representa una función o subrutina definida en otra parte del programa.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nombre de la función
              const Text('Nombre de la función',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              TextField(
                controller: _functionNameController,
                decoration: const InputDecoration(
                  hintText: 'Ej: calcularPromedio, ordenar, buscar',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Toggle: ¿Tiene parámetros?
              SwitchListTile(
                title: const Text('Recibe parámetros'),
                subtitle: const Text('La función necesita datos de entrada',
                    style: TextStyle(fontSize: 12)),
                value: _hasParameters,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _hasParameters = val),
              ),

              if (_hasParameters) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _parametersController,
                  decoration: const InputDecoration(
                    labelText: 'Parámetros',
                    hintText: 'Ej: datos, n  ó  arreglo, tamaño, valor',
                    border: OutlineInputBorder(),
                    helperText: 'Separa los parámetros con comas',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
              ],

              // Toggle: ¿Retorna un valor?
              SwitchListTile(
                title: const Text('Retorna un valor'),
                subtitle: const Text('El resultado se guarda en una variable',
                    style: TextStyle(fontSize: 12)),
                value: _hasReturn,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _hasReturn = val),
              ),

              if (_hasReturn) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _returnVarController,
                  decoration: const InputDecoration(
                    labelText: 'Variable donde guardar el resultado',
                    hintText: 'Ej: resultado, promedio, encontrado',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 16),

              // Vista previa
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                        Icon(Icons.visibility,
                            size: 16, color: Colors.purple[700]),
                        const SizedBox(width: 6),
                        Text('Vista previa',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[900],
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preview.isEmpty
                          ? '(completa el nombre de la función)'
                          : preview,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: preview.isEmpty ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
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
          onPressed: preview.isEmpty
              ? null
              : () {
                  widget.node.text = preview;
                  Navigator.of(context).pop(widget.node);
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
