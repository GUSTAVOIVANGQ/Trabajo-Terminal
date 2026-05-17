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
  String _mode = 'simple'; // 'simple' | 'compound' | 'check' | 'free'

  // Modo: comparación simple
  late TextEditingController _simpleLeftCtrl;
  late TextEditingController _simpleRightCtrl;
  String _simpleOp = '>';

  // Modo: condición compuesta
  late TextEditingController _compLeft1Ctrl;
  late TextEditingController _compRight1Ctrl;
  String _compOp1 = '>';
  String _logicOp = '&&';
  late TextEditingController _compLeft2Ctrl;
  late TextEditingController _compRight2Ctrl;
  String _compOp2 = '>';

  // Modo: verificar estado
  late TextEditingController _checkVarCtrl;
  bool _checkNegated = false;

  // Modo: texto libre
  late TextEditingController _freeCtrl;

  static const _compOps = ['>', '<', '>=', '<=', '==', '!='];
  static const _compOpLabels = {
    '>':  'mayor que  ( > )',
    '<':  'menor que  ( < )',
    '>=': 'mayor o igual  ( >= )',
    '<=': 'menor o igual  ( <= )',
    '==': 'igual a  ( == )',
    '!=': 'diferente de  ( != )',
  };

  @override
  void initState() {
    super.initState();
    _simpleLeftCtrl  = TextEditingController();
    _simpleRightCtrl = TextEditingController();
    _compLeft1Ctrl   = TextEditingController();
    _compRight1Ctrl  = TextEditingController();
    _compLeft2Ctrl   = TextEditingController();
    _compRight2Ctrl  = TextEditingController();
    _checkVarCtrl    = TextEditingController();
    _freeCtrl        = TextEditingController();
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text
        .replaceAll('¿', '')
        .replaceAll('?', '')
        .trim();
    if (text.isEmpty) return;

    // Detectar condición compuesta: expr1 && expr2  ó  expr1 || expr2
    final compoundPattern = RegExp(r'^(.+?)\s*(&&|\|\|)\s*(.+)$');
    final mc = compoundPattern.firstMatch(text);
    if (mc != null) {
      _mode    = 'compound';
      _logicOp = mc.group(2)!;
      _parseSimplePart(mc.group(1)!.trim(), _compLeft1Ctrl, _compRight1Ctrl,
              (op) => _compOp1 = op);
      _parseSimplePart(mc.group(3)!.trim(), _compLeft2Ctrl, _compRight2Ctrl,
              (op) => _compOp2 = op);
      return;
    }

    // Detectar comparación simple
    final simplePattern = RegExp(r'^(.+?)\s*(>=|<=|!=|>|<|==)\s*(.+)$');
    final ms = simplePattern.firstMatch(text);
    if (ms != null) {
      _mode                = 'simple';
      _simpleLeftCtrl.text  = ms.group(1)!.trim();
      _simpleOp             = ms.group(2)!;
      _simpleRightCtrl.text = ms.group(3)!.trim();
      return;
    }

    // Detectar negación
    if (text.startsWith('!') || text.toLowerCase().startsWith('no ')) {
      _mode             = 'check';
      _checkNegated     = true;
      _checkVarCtrl.text = text
          .replaceFirst(RegExp(r'^(!|no\s+)', caseSensitive: false), '')
          .trim();
      return;
    }

    // Verificación simple (pocas palabras, sin operador)
    if (text.split(' ').length <= 3) {
      _mode              = 'check';
      _checkVarCtrl.text = text;
      return;
    }

    // Resto → libre
    _mode         = 'free';
    _freeCtrl.text = text;
  }

  void _parseSimplePart(
      String part,
      TextEditingController leftCtrl,
      TextEditingController rightCtrl,
      void Function(String) setOp,
      ) {
    final p =
    RegExp(r'^(.+?)\s*(>=|<=|!=|>|<|==)\s*(.+)$').firstMatch(part);
    if (p != null) {
      leftCtrl.text  = p.group(1)!.trim();
      setOp(p.group(2)!);
      rightCtrl.text = p.group(3)!.trim();
    } else {
      leftCtrl.text = part;
    }
  }

  @override
  void dispose() {
    _simpleLeftCtrl.dispose();
    _simpleRightCtrl.dispose();
    _compLeft1Ctrl.dispose();
    _compRight1Ctrl.dispose();
    _compLeft2Ctrl.dispose();
    _compRight2Ctrl.dispose();
    _checkVarCtrl.dispose();
    _freeCtrl.dispose();
    super.dispose();
  }

  String _generateText() {
    switch (_mode) {
      case 'simple':
        final l = _simpleLeftCtrl.text.trim();
        final r = _simpleRightCtrl.text.trim();
        if (l.isEmpty) return '';
        if (r.isEmpty) return '¿$l?';
        return '¿$l $_simpleOp $r?';

      case 'compound':
        final l1 = _compLeft1Ctrl.text.trim();
        final r1 = _compRight1Ctrl.text.trim();
        final l2 = _compLeft2Ctrl.text.trim();
        final r2 = _compRight2Ctrl.text.trim();
        if (l1.isEmpty || l2.isEmpty) return '';
        final part1 = r1.isEmpty ? l1 : '$l1 $_compOp1 $r1';
        final part2 = r2.isEmpty ? l2 : '$l2 $_compOp2 $r2';
        return '¿$part1 $_logicOp $part2?';

      case 'check':
        final v = _checkVarCtrl.text.trim();
        if (v.isEmpty) return '';
        return _checkNegated ? '¿!$v?' : '¿$v?';

      case 'free':
        final t = _freeCtrl.text.trim();
        if (t.isEmpty) return '';
        if (!t.startsWith('¿') && !t.endsWith('?')) return '¿$t?';
        return t;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final preview = _generateText();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.diamond_outlined, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Decisión'),
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
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Evalúa una condición y dirige el flujo por una de '
                            'sus salidas. Las salidas se etiquetan con '
                            'Sí / No o Verdadero / Falso.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selector de modo — cuadrícula 2×2
              const Text('Tipo de condición',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      label: 'Comparación',
                      icon: Icons.compare_arrows,
                      example: 'edad > 18',
                      selected: _mode == 'simple',
                      onTap: () => setState(() => _mode = 'simple'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeCard(
                      label: 'Compuesta',
                      icon: Icons.account_tree_outlined,
                      example: 'a>0 && a<100',
                      selected: _mode == 'compound',
                      onTap: () => setState(() => _mode = 'compound'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      label: 'Verificar estado',
                      icon: Icons.check_circle_outline,
                      example: '¿encontrado?',
                      selected: _mode == 'check',
                      onTap: () => setState(() => _mode = 'check'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeCard(
                      label: 'Texto libre',
                      icon: Icons.edit_outlined,
                      example: '¿cualquier\ncondición?',
                      selected: _mode == 'free',
                      onTap: () => setState(() => _mode = 'free'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campos según el modo
              if (_mode == 'simple')   ..._buildSimpleFields(),
              if (_mode == 'compound') ..._buildCompoundFields(),
              if (_mode == 'check')    ..._buildCheckFields(),
              if (_mode == 'free')     ..._buildFreeFields(),

              const SizedBox(height: 20),

              // Vista previa
              _buildPreview(context, preview),

              const SizedBox(height: 12),

              // Recordatorio de etiquetas en flechas
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.call_split,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuerda etiquetar las salidas (Sí / No) '
                            'en las flechas que salen del rombo.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
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
              : () => Navigator.of(context)
              .pop(NodeDialogResult.simple(preview)),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // ── Comparación simple ─────────────────────────────────────────────────────
  List<Widget> _buildSimpleFields() {
    return [
      const Text('Comparación',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      TextField(
        controller: _simpleLeftCtrl,
        decoration: const InputDecoration(
          labelText: 'Variable o valor',
          hintText: 'Ej: edad, nota, contador',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        value: _simpleOp,
        decoration: const InputDecoration(
          labelText: 'Condición',
          border: OutlineInputBorder(),
        ),
        items: _compOps
            .map((op) => DropdownMenuItem(
          value: op,
          child: Text(_compOpLabels[op] ?? op),
        ))
            .toList(),
        onChanged: (v) => setState(() => _simpleOp = v!),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _simpleRightCtrl,
        decoration: const InputDecoration(
          labelText: 'Comparar con',
          hintText: 'Ej: 18, 0, limite',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  // ── Condición compuesta ────────────────────────────────────────────────────
  List<Widget> _buildCompoundFields() {
    return [
      const Text('Condición compuesta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      Text(
        'Combina dos comparaciones con Y (&&) u O (||)',
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      _buildInlineComparison(
        leftCtrl:   _compLeft1Ctrl,
        rightCtrl:  _compRight1Ctrl,
        currentOp:  _compOp1,
        onOpChanged: (v) => setState(() => _compOp1 = v),
        label: 'Primera condición',
      ),
      const SizedBox(height: 10),
      // Selector Y / O
      Row(
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '&&', label: Text('Y  (&&)')),
              ButtonSegment(value: '||', label: Text('O  (||)')),
            ],
            selected: {_logicOp},
            onSelectionChanged: (s) => setState(() => _logicOp = s.first),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 10),
      _buildInlineComparison(
        leftCtrl:   _compLeft2Ctrl,
        rightCtrl:  _compRight2Ctrl,
        currentOp:  _compOp2,
        onOpChanged: (v) => setState(() => _compOp2 = v),
        label: 'Segunda condición',
      ),
    ];
  }

  Widget _buildInlineComparison({
    required TextEditingController leftCtrl,
    required TextEditingController rightCtrl,
    required String currentOp,
    required void Function(String) onOpChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: leftCtrl,
                decoration: const InputDecoration(
                  hintText: 'variable',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentOp,
                  isDense: true,
                  items: _compOps
                      .map((op) => DropdownMenuItem(
                    value: op,
                    child: Text(op,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 14)),
                  ))
                      .toList(),
                  onChanged: (v) => onOpChanged(v!),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: TextField(
                controller: rightCtrl,
                decoration: const InputDecoration(
                  hintText: 'valor',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Verificar estado ───────────────────────────────────────────────────────
  List<Widget> _buildCheckFields() {
    return [
      const Text('Verificar estado',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      Text(
        'Para condiciones que son verdaderas o falsas por sí solas.',
        style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _checkVarCtrl,
        decoration: const InputDecoration(
          labelText: 'Variable o condición',
          hintText: 'Ej: encontrado, esPar, lista vacía',
          border: OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        title: const Text('Negar la condición'),
        subtitle: Text(
          _checkNegated
              ? 'Se evalúa: ¿NO ${_checkVarCtrl.text.trim()}?'
              : 'Se evalúa: ¿${_checkVarCtrl.text.trim()}?',
          style: const TextStyle(fontSize: 12),
        ),
        value: _checkNegated,
        contentPadding: EdgeInsets.zero,
        onChanged: (v) => setState(() => _checkNegated = v),
      ),
    ];
  }

  // ── Texto libre ────────────────────────────────────────────────────────────
  List<Widget> _buildFreeFields() {
    return [
      const Text('Condición',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 8),
      TextField(
        controller: _freeCtrl,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Ej: numero % 2 == 0\n    saldo > deuda',
          border: OutlineInputBorder(),
          helperText: 'Se agregarán ¿? automáticamente si no los escribes.',
        ),
        onChanged: (_) => setState(() {}),
      ),
    ];
  }

  // ── Vista previa ───────────────────────────────────────────────────────────
  Widget _buildPreview(BuildContext context, String preview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 6),
              Text('Vista previa',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
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

// ── Tarjeta de modo ────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: contentColor, fontSize: 12)),
            const SizedBox(height: 2),
            Text(example,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: contentColor.withOpacity(0.75))),
          ],
        ),
      ),
    );
  }
}