import 'package:flutter/material.dart';
import '../models/diagram_node.dart';
import 'process_node_dialog.dart';
import 'decision_node_dialog.dart';
import 'data_node_dialog.dart';
import 'preparation_node_dialog.dart';
import 'subprocess_node_dialog.dart';
import 'connector_node_dialog.dart';
import 'comment_node_dialog.dart';
import 'variable_node_dialog.dart';

class NodeEditorDialog extends StatefulWidget {
  final DiagramNode node;

  const NodeEditorDialog({super.key, required this.node});

  @override
  State<NodeEditorDialog> createState() => _NodeEditorDialogState();
}

class _NodeEditorDialogState extends State<NodeEditorDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.node.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _isVariableNode() {
    if (widget.node.metadata['concept_type'] == 'declareInt') return true;
    
    String t = widget.node.text.trim();
    return t.startsWith('int ') || 
           t.startsWith('float ') || 
           t.startsWith('double ') || 
           t.startsWith('char ') || 
           t.startsWith('bool ') || 
           t.startsWith('const ');
  }

  @override
  Widget build(BuildContext context) {
    // Si detectamos que es una declaración de variable, usamos su diálogo
    if ((widget.node.type == NodeType.process || widget.node.type == NodeType.preparation) && _isVariableNode()) {
      return VariableNodeDialog(node: widget.node);
    }

    // Para nodos de proceso, usar el diálogo especializado
    if (widget.node.type == NodeType.process) {
      return ProcessNodeDialog(node: widget.node);
    }

    // Para nodos de decisión, usar el diálogo especializado
    if (widget.node.type == NodeType.decision) {
      return DecisionNodeDialog(node: widget.node);
    }

    // Para nodos de datos (entrada/salida), usar el diálogo especializado
    if (widget.node.type == NodeType.data) {
      return DataNodeDialog(node: widget.node);
    }

    // Para nodos de preparación/inicialización, usar el diálogo especializado
    if (widget.node.type == NodeType.preparation) {
      return PreparationNodeDialog(node: widget.node);
    }

    // Para nodos de subproceso/predefined process, usar el diálogo especializado
    if (widget.node.type == NodeType.predefinedProcess) {
      return SubprocessNodeDialog(node: widget.node);
    }

    // Para nodos de conector (in-page y off-page), usar el diálogo especializado
    if (widget.node.type == NodeType.connector ||
        widget.node.type == NodeType.offPageConnector) {
      return ConnectorNodeDialog(node: widget.node);
    }

    // Para nodos de comentario/anotación, usar el diálogo especializado
    if (widget.node.type == NodeType.comment ||
        widget.node.type == NodeType.annotation) {
      return CommentNodeDialog(node: widget.node);
    }

    String dialogTitle;
    String hintText;

    switch (widget.node.type) {
      case NodeType.terminal:
        dialogTitle = 'Editar Nodo Terminal';
        hintText = 'Escribe "Inicio", "Fin" u otro texto';
        break;
      case NodeType.process:
        dialogTitle = 'Editar Proceso';
        hintText = 'Describe el proceso (ej: suma = a + b)';
        break;
      case NodeType.decision:
        dialogTitle = 'Editar Condición';
        hintText = '¿Condición? (ej: edad >= 18)';
        break;
      case NodeType.preparation:
        dialogTitle = 'Editar Preparación';
        hintText = 'Inicialización de bucle (ej: i = 0, contador = 1)';
        break;
      case NodeType.data:
        dialogTitle = 'Editar Dato';
        hintText =
            'Describe entrada o salida (ej: leer edad, mostrar resultado)';
        break;
      case NodeType.predefinedProcess:
        dialogTitle = 'Editar Subproceso/Función';
        hintText = 'Nombre de la función (ej: calcularPromedio)';
        break;
      // ISO 5807 symbols without specialized dialogs use default
      default:
        dialogTitle = 'Editar ${widget.node.type.isoName}';
        hintText = 'Ingrese el texto del nodo';
        break;
    }

    return AlertDialog(
      title: Text(dialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo: ${_getNodeTypeName(widget.node.type)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Texto',
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_textController.text);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.terminal:
        return 'Terminal (Inicio/Fin)';
      case NodeType.process:
        return 'Proceso';
      case NodeType.decision:
        return 'Decisión';
      case NodeType.preparation:
        return 'Preparación';
      case NodeType.data:
        return 'Dato (Entrada/Salida)';
      case NodeType.predefinedProcess:
        return 'Subproceso/Función';
      default:
        return type.isoName;
    }
  }
}
