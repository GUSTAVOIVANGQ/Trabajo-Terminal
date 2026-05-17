import 'package:flutter/material.dart';
import '../models/diagram_node.dart';

class CommentNodeDialog extends StatefulWidget {
  final DiagramNode node;

  const CommentNodeDialog({super.key, required this.node});

  @override
  State<CommentNodeDialog> createState() => _CommentNodeDialogState();
}

class _CommentNodeDialogState extends State<CommentNodeDialog> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    // Limpiar prefijos de versiones anteriores si existen
    String text = widget.node.text
        .replaceAll(RegExp(r'^//\s*'), '')
        .replaceAll(RegExp(r'^/\*\s*|\s*\*/$'), '')
        .replaceAll(RegExp(r'^=====\n|\n=====$'), '')
        .replaceAll(RegExp(r'^NOTA:\s*', caseSensitive: false), '')
        .trim();
    _commentController = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.comment_outlined, color: Colors.amber[700]),
          const SizedBox(width: 12),
          const Text('Anotación'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'La anotación agrega notas o aclaraciones al diagrama. '
                      'Se conecta mediante una línea punteada al símbolo que explica.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Campo de texto
            const Text(
              'Texto de la anotación',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe la nota o aclaración...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            widget.node.text = _commentController.text.trim();
            Navigator.of(context).pop(widget.node);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}