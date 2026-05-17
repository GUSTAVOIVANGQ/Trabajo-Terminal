import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import '../models/node_dialog_result.dart';

class PreparationNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const PreparationNodeDialog({super.key, required this.node});

  @override
  State<PreparationNodeDialog> createState() => _PreparationNodeDialogState();
}

class _PreparationNodeDialogState extends State<PreparationNodeDialog> {
  // Dos modos: inicializar variable o configurar bucle
  bool _isLoopMode = false;

  // Modo variable
  late TextEditingController _varNameController;
  late TextEditingController _varValueController;

  // Modo bucle
  late TextEditingController _loopVarController;
  late TextEditingController _loopStartController;
  late TextEditingController _loopEndController;
  late TextEditingController _loopStepController;

  @override
  void initState() {
    super.initState();
    _varNameController = TextEditingController();
    _varValueController = TextEditingController(text: '0');
    _loopVarController = TextEditingController(text: 'i');
    _loopStartController = TextEditingController(text: '0');
    _loopEndController = TextEditingController();
    _loopStepController = TextEditingController(text: '1');
    _parseExistingText();
  }

  void _parseExistingText() {
    final text = widget.node.text.trim();
    if (text.isEmpty) return;

    // Detectar patrón de bucle: variable = inicio; variable < fin; variable++
    final forPattern = RegExp(
        r'(\w+)\s*=\s*(\d+)\s*;\s*\w+\s*[<>]=?\s*(\d+)\s*;\s*\w+(\+\+|--|\s*[+-]=\s*\d+)');
    final m = forPattern.firstMatch(text);
    if (m != null) {
      _isLoopMode = true;
      _loopVarController.text = m.group(1) ?? 'i';
      _loopStartController.text = m.group(2) ?? '0';
      _loopEndController.text = m.group(3) ?? '';
      return;
    }

    // Detectar inicialización simple: variable = valor
    final initPattern = RegExp(r'^(\w+)\s*=\s*(.+)$');
    final m2 = initPattern.firstMatch(text);
    if (m2 != null) {
      _isLoopMode = false;
      _varNameController.text = m2.group(1) ?? '';
      _varValueController.text = m2.group(2) ?? '0';
      return;
    }
  }

  @override
  void dispose() {
    _varNameController.dispose();
    _varValueController.dispose();
    _loopVarController.dispose();
    _loopStartController.dispose();
    _loopEndController.dispose();
    _loopStepController.dispose();
    super.dispose();
  }

  String _generateText() {
    if (_isLoopMode) {
      final v = _loopVarController.text.trim();
      final start = _loopStartController.text.trim();
      final end = _loopEndController.text.trim();
      final step = _loopStepController.text.trim();
      if (v.isEmpty || end.isEmpty) return '';
      final stepPart = (step == '1' || step.isEmpty) ? '$v++' : '$v += $step';
      return '$v = $start; $v < $end; $stepPart';
    } else {
      final name = _varNameController.text.trim();
      final value = _varValueController.text.trim();
      if (name.isEmpty) return '';
      return '$name = $value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _generateText();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.hexagon_outlined,
              color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          const Text('Preparación'),
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
                      .secondaryContainer
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Sirve para inicializar variables antes de un proceso, '
                        'o para definir el control de un bucle.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selector de modo
              const Text('¿Para qué se usa?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _OptionCard(
                      label: 'Inicializar',
                      description: 'Asignar valor inicial a una variable',
                      icon: Icons.edit_note,
                      selected: !_isLoopMode,
                      onTap: () => setState(() => _isLoopMode = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OptionCard(
                      label: 'Control de bucle',
                      description: 'Definir inicio, fin y paso',
                      icon: Icons.loop,
                      selected: _isLoopMode,
                      onTap: () => setState(() => _isLoopMode = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campos según el modo
              if (!_isLoopMode) ...[
                const Text('Variable a inicializar',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: _varNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: suma, contador, i',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _varValueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor inicial',
                    hintText: 'Ej: 0, 1, -1',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ] else ...[
                const Text('Control del bucle',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TextField(
                  controller: _loopVarController,
                  decoration: const InputDecoration(
                    labelText: 'Variable de control',
                    hintText: 'Ej: i, contador, indice',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _loopStartController,
                        decoration: const InputDecoration(
                          labelText: 'Inicio',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _loopEndController,
                        decoration: const InputDecoration(
                          labelText: 'Fin (< este valor)',
                          hintText: '10',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _loopStepController,
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
              const SizedBox(height: 20),

              // Vista previa
              Container(
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
                            size: 16,
                            color: Theme.of(context).colorScheme.primary),
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
                  Navigator.of(context).pop(NodeDialogResult.simple(preview));
                },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Tarjeta de opción reutilizable
class _OptionCard extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.description,
    required this.icon,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: contentColor, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: contentColor, fontSize: 13)),
            const SizedBox(height: 4),
            Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: contentColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
