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
  // Tres modos: asignación guiada, operación matemática, texto libre
  String _mode = 'assignment'; // 'assignment' | 'arithmetic' | 'free'

  // Modo asignación
  late TextEditingController _assignVarController;
  late TextEditingController _assignValueController;

  // Modo aritmético
  late TextEditingController _arithResultController;
  late TextEditingController _arithOp1Controller;
  late TextEditingController _arithOp2Controller;
  String _operator = '+';

  // Modo texto libre
  late TextEditingController _freeController;

  static const _operators = ['+', '-', '*', '/', '%'];

  @override
  void initState() {
    super.initState();
    _assignVarController = TextEditingController();
    _assignValueController = TextEditingController();
    _arithResultController = TextEditingController();
    _arithOp1Controller = TextEditingController();
    _arithOp2Controller = TextEditingController();
    _freeController = TextEditingController();
    _parseExistingText();
  }

  void _parseExistingText() {
    final text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar operación aritmética: resultado = a OP b
    final arithPattern = RegExp(r'^(\w+)\s*=\s*(\w+)\s*([+\-*/%])\s*(\w+)$');
    final m1 = arithPattern.firstMatch(text);
    if (m1 != null) {
      _mode = 'arithmetic';
      _arithResultController.text = m1.group(1)!;
      _arithOp1Controller.text = m1.group(2)!;
      _operator = m1.group(3)!;
      _arithOp2Controller.text = m1.group(4)!;
      return;
    }

    // Detectar asignación simple: variable = valor
    final assignPattern = RegExp(r'^(\w+)\s*=\s*(.+)$');
    final m2 = assignPattern.firstMatch(text);
    if (m2 != null) {
      _mode = 'assignment';
      _assignVarController.text = m2.group(1)!;
      _assignValueController.text = m2.group(2)!;
      return;
    }

    // Cualquier otra cosa → texto libre
    _mode = 'free';
    _freeController.text = text;
  }

  @override
  void dispose() {
    _assignVarController.dispose();
    _assignValueController.dispose();
    _arithResultController.dispose();
    _arithOp1Controller.dispose();
    _arithOp2Controller.dispose();
    _freeController.dispose();
    super.dispose();
  }

  String _generateText() {
    switch (_mode) {
      case 'assignment':
        final v = _assignVarController.text.trim();
        final val = _assignValueController.text.trim();
        if (v.isEmpty) return '';
        return val.isEmpty ? v : '$v = $val';

      case 'arithmetic':
        final res = _arithResultController.text.trim();
        final op1 = _arithOp1Controller.text.trim();
        final op2 = _arithOp2Controller.text.trim();
        if (res.isEmpty || op1.isEmpty || op2.isEmpty) return '';
        return '$res = $op1 $_operator $op2';

      case 'free':
        return _freeController.text.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final preview = _generateText();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.crop_square_rounded,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Proceso'),
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
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Un proceso realiza una operación que cambia el valor '
                        'o el estado de los datos: cálculos, asignaciones, '
                        'incrementos, etc.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selector de modo
              const Text('Tipo de operación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      label: 'Asignación',
                      icon: Icons.drive_file_rename_outline,
                      example: 'x = 5',
                      selected: _mode == 'assignment',
                      onTap: () => setState(() => _mode = 'assignment'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeCard(
                      label: 'Operación',
                      icon: Icons.calculate_outlined,
                      example: 'suma = a + b',
                      selected: _mode == 'arithmetic',
                      onTap: () => setState(() => _mode = 'arithmetic'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeCard(
                      label: 'Libre',
                      icon: Icons.edit_outlined,
                      example: 'cualquier texto',
                      selected: _mode == 'free',
                      onTap: () => setState(() => _mode = 'free'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campos según el modo
              if (_mode == 'assignment') ..._buildAssignmentFields(),
              if (_mode == 'arithmetic') ..._buildArithmeticFields(),
              if (_mode == 'free') ..._buildFreeFields(),

              const SizedBox(height: 20),

              // Vista previa
              _buildPreview(context, preview),
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
              : () =>
                  Navigator.of(context).pop(NodeDialogResult.simple(preview)),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  List<Widget> _buildAssignmentFields() {
    return [
      const Text('Asignación',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              controller: _assignVarController,
              decoration: const InputDecoration(
                labelText: 'Variable',
                hintText: 'contador',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('=',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 6,
            child: TextField(
              controller: _assignValueController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                hintText: '0  ó  edad',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        'El valor puede ser un número, otra variable o una expresión.',
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ];
  }

  List<Widget> _buildArithmeticFields() {
    return [
      const Text('Operación matemática',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      // Fila 1: resultado =
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _arithResultController,
              decoration: const InputDecoration(
                labelText: 'Resultado',
                hintText: 'suma',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text('=',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextField(
              controller: _arithOp1Controller,
              decoration: const InputDecoration(
                labelText: 'Operando 1',
                hintText: 'a',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // Fila 2: operador y operando 2
      Row(
        children: [
          // Selector de operador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _operator,
                items: _operators
                    .map((op) => DropdownMenuItem(
                        value: op,
                        child: Text(op, style: const TextStyle(fontSize: 18))))
                    .toList(),
                onChanged: (v) => setState(() => _operator = v!),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _arithOp2Controller,
              decoration: const InputDecoration(
                labelText: 'Operando 2',
                hintText: 'b',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildFreeFields() {
    return [
      const Text('Descripción del proceso',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      TextField(
        controller: _freeController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Ej: intercambiar A y B\n    contador = contador + 1',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  Widget _buildPreview(BuildContext context, String preview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility,
                  size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Text('Vista previa',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            preview.isEmpty ? '(completa los campos)' : preview,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: preview.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String example;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.icon,
    required this.example,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
        
    final contentColor = selected
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: contentColor, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: contentColor, fontSize: 12)),
            const SizedBox(height: 2),
            Text(example,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: contentColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}
