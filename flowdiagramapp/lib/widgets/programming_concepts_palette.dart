import 'package:flutter/material.dart';

enum ProgrammingConceptType {
  scanf,
  printf,
  declareInt,
  assignment,
  loopFor,
  loopWhile,
  loopDoWhile,
  ifElse,
  switchStructure,
  function,
  struct,
  pointer,
}

class ProgrammingConceptsPalette extends StatelessWidget {
  final Function(ProgrammingConceptType) onConceptSelected;

  const ProgrammingConceptsPalette({
    super.key,
    required this.onConceptSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'C Concepts',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          _buildConceptItem(context, ProgrammingConceptType.scanf, 'scanf()',
              Icons.input, Colors.cyan),
          _buildConceptItem(context, ProgrammingConceptType.printf, 'printf()',
              Icons.output, Colors.teal),
          _buildConceptItem(
              context,
              ProgrammingConceptType.declareInt,
              'int var',
              Colors.blue,
              Colors.orange), // Custom icon handled below if needed
          _buildConceptItem(context, ProgrammingConceptType.assignment,
              'Assign', Icons.calculate, Colors.blueGrey),
          _buildConceptItem(context, ProgrammingConceptType.loopFor, 'For Loop',
              Icons.refresh, Colors.green),
          _buildConceptItem(context, ProgrammingConceptType.loopWhile, 'While',
              Icons.repeat, Colors.lightGreen),
          _buildConceptItem(context, ProgrammingConceptType.loopDoWhile,
              'Do-While', Icons.replay, Colors.lime),
          _buildConceptItem(context, ProgrammingConceptType.ifElse, 'If-Else',
              Icons.call_split, Colors.purple),
          _buildConceptItem(context, ProgrammingConceptType.switchStructure,
              'Switch', Icons.list_alt, Colors.deepPurple),
          _buildConceptItem(context, ProgrammingConceptType.function,
              'Function', Icons.functions, Colors.pink),
          _buildConceptItem(context, ProgrammingConceptType.struct, 'Struct',
              Icons.view_module, Colors.brown),
          _buildConceptItem(context, ProgrammingConceptType.pointer, 'Pointer',
              Icons.arrow_right_alt, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildConceptItem(BuildContext context, ProgrammingConceptType type,
      String label, dynamic iconOrColor, Color color) {
    return Tooltip(
      message: 'Add $label structure',
      child: InkWell(
        onTap: () => onConceptSelected(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 2),
                ),
                child: iconOrColor is IconData
                    ? Icon(iconOrColor, color: color, size: 24)
                    : Icon(Icons.code, color: color, size: 24),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
