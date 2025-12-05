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
  String selectedCommentType =
      'single_line'; // Por defecto comentario de una línea

  // Tipos de comentarios disponibles
  final Map<String, String> commentTypes = {
    'single_line': 'Comentario Simple (//)',
    'multi_line': 'Comentario de Bloque (/* */)',
    'section': 'Comentario de Sección',
    'note': 'Nota Explicativa',
  };

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();

    // Intentar interpretar el texto existente
    _parseExistingText();
  }

  void _parseExistingText() {
    String text = widget.node.text.trim();
    if (text.isEmpty) {
      return;
    }

    // Detectar el tipo de comentario por el formato
    if (text.startsWith('//')) {
      selectedCommentType = 'single_line';
      _commentController.text = text.substring(2).trim();
    } else if (text.startsWith('/*') && text.endsWith('*/')) {
      selectedCommentType = 'multi_line';
      _commentController.text = text.substring(2, text.length - 2).trim();
    } else if (text.startsWith('=====') || text.contains('-----')) {
      selectedCommentType = 'section';
      // Extraer el texto entre los separadores
      final lines = text.split('\n');
      if (lines.length >= 3) {
        _commentController.text = lines[1].trim();
      } else {
        _commentController.text = text;
      }
    } else if (text.toUpperCase().startsWith('NOTA:') ||
        text.toUpperCase().startsWith('NOTE:')) {
      selectedCommentType = 'note';
      final colonIndex = text.indexOf(':');
      if (colonIndex >= 0 && colonIndex < text.length - 1) {
        _commentController.text = text.substring(colonIndex + 1).trim();
      } else {
        _commentController.text = text;
      }
    } else {
      // Por defecto, asumir comentario simple
      _commentController.text = text;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _generateCommentText() {
    String comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return 'Comentario vacío';
    }

    switch (selectedCommentType) {
      case 'single_line':
        return '// $comment';
      case 'multi_line':
        return '/* $comment */';
      case 'section':
        return '=====\n$comment\n=====';
      case 'note':
        return 'NOTA: $comment';
      default:
        return '// $comment';
    }
  }

  Widget _buildCommentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Comentario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...commentTypes.entries.map((entry) {
          return RadioListTile<String>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: selectedCommentType,
            onChanged: (value) {
              setState(() {
                selectedCommentType = value!;
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Texto del Comentario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          maxLines: selectedCommentType == 'multi_line' ? 5 : 3,
          decoration: InputDecoration(
            hintText: _getCommentHint(),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  String _getCommentHint() {
    switch (selectedCommentType) {
      case 'single_line':
        return 'Ingresa un comentario breve...';
      case 'multi_line':
        return 'Ingresa un comentario de múltiples líneas...';
      case 'section':
        return 'Título de la sección...';
      case 'note':
        return 'Nota importante...';
      default:
        return 'Escribe tu comentario...';
    }
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Vista Previa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
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
              _generateCommentText(),
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
    switch (selectedCommentType) {
      case 'single_line':
        helpText = 'Comentario de una línea. Se mostrará como: // tu texto';
        break;
      case 'multi_line':
        helpText =
            'Comentario de múltiples líneas. Se mostrará como: /* tu texto */';
        break;
      case 'section':
        helpText =
            'Comentario de sección para dividir el código. Se mostrará con separadores.';
        break;
      case 'note':
        helpText =
            'Nota explicativa importante. Se mostrará como: NOTA: tu texto';
        break;
      default:
        helpText = 'Selecciona un tipo de comentario.';
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
          Icon(Icons.comment, color: Colors.amber[700]),
          const SizedBox(width: 8),
          const Text('Editar Comentario'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCommentTypeSelector(),
              const SizedBox(height: 20),
              _buildCommentField(),
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
            widget.node.text = _generateCommentText();
            Navigator.of(context).pop(widget.node);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
