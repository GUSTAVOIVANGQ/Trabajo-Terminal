import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/flow_diagram_canvas_final.dart';
import '../widgets/node_palette.dart';
import '../widgets/programming_concepts_palette.dart';
import '../widgets/editor_side_panel.dart';
import '../widgets/node_editor_dialog.dart';
import '../widgets/validation_result_dialog.dart';
import 'load_diagram_screen.dart';
import '../widgets/save_diagram_dialog.dart';
import '../models/diagram_node.dart';
import '../models/diagram_validator.dart';
import '../models/code_generator.dart';
import '../models/saved_diagram.dart';
import '../models/node_dialog_result.dart';
import '../services/database_service.dart';
import '../services/metrics_service.dart'; // Nueva importación
import '../services/diagram_export_service.dart'; // Importación para exportación

class EditorScreen extends StatefulWidget {
  final SavedDiagram? initialDiagram;

  const EditorScreen({super.key, this.initialDiagram});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final List<DiagramNode> nodes = [];
  final List<Connection> connections = [];
  DiagramNode? selectedNode;
  Connection? selectedConnection; // Nueva propiedad para conexión seleccionada
  DiagramNode? connectionStart;
  Offset panOffset = Offset.zero;
  double currentScale = 1.0;
  bool isConnecting = false;

  // Para control de guardado
  SavedDiagram? currentDiagram;
  final DatabaseService _databaseService = DatabaseService();
  final MetricsService _metricsService = MetricsService(); // Nuevo servicio
  bool _hasUnsavedChanges = false;

  // GlobalKey para capturar el canvas y exportar
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Si se proporciona un diagrama inicial, cargarlo
    if (widget.initialDiagram != null) {
      _loadDiagram(widget.initialDiagram!);
    }
  }

  void _loadDiagram(SavedDiagram diagram) {
    setState(() {
      nodes.clear();
      connections.clear();

      // Agregar nodos y conexiones del diagrama cargado
      nodes.addAll(diagram.nodes);
      connections.addAll(diagram.connections);

      // Almacenar referencia al diagrama actual
      currentDiagram = diagram;
      _hasUnsavedChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentDiagram?.name ?? 'Diagrama de Flujo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBackNavigation(context),
        ),
        actions: [
          // Botón para validar el diagrama
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Validar diagrama',
            onPressed: _validateDiagram,
          ),
          // Botón para guardar diagrama
          IconButton(
            icon: _hasUnsavedChanges
                ? const Icon(Icons.save, color: Colors.amber)
                : const Icon(Icons.save),
            tooltip: 'Guardar diagrama',
            onPressed: _showSaveDiagramDialog,
          ),
          // Botón para cargar diagrama
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Cargar diagrama',
            onPressed: () => _navigateToLoadDiagram(context),
          ),
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Generar código',
            onPressed: _generateCode,
          ),
          // Menú de exportación
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download),
            tooltip: 'Exportar diagrama',
            onSelected: (value) {
              if (value == 'png') {
                _exportDiagramAsPNG();
              } else if (value == 'jpg') {
                _exportDiagramAsJPG();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('Exportar como PNG'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'jpg',
                child: Row(
                  children: [
                    Icon(Icons.photo),
                    SizedBox(width: 8),
                    Text('Exportar como JPG'),
                  ],
                ),
              ),
            ],
          ),
          if (selectedNode != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar nodo',
              onPressed: () => _editSelectedNode(),
            ),
          if (selectedNode != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar nodo',
              onPressed: () => _deleteSelectedNode(),
            ),
          // Nuevo botón para gestionar conexiones
          if (selectedNode != null)
            IconButton(
              icon: isConnecting
                  ? const Icon(Icons.link_off)
                  : const Icon(Icons.link),
              tooltip: isConnecting ? 'Cancelar conexión' : 'Crear conexión',
              onPressed: () {
                setState(() {
                  if (isConnecting) {
                    connectionStart = null;
                    isConnecting = false;
                    // _showSnackBar('Conexión cancelada');
                  } else {
                    connectionStart = selectedNode;
                    isConnecting = true;
                    // _showSnackBar('Selecciona otro nodo para conectarlo');
                  }
                });
              },
            ),
        ],
      ),
      body: Row(
        children: [
          // Panel lateral con pestañas para símbolos y conceptos
          EditorSidePanel(
            onNodeSelected: (nodeType) {
              // No seleccionar automáticamente el nodo si estamos en modo conexión
              _addNode(nodeType, autoSelect: !isConnecting);
            },
            onConceptSelected: (conceptType) {
              _addConcept(conceptType);
            },
          ),

          // Área principal del canvas
          Expanded(
            child: Stack(
              children: [
                FlowDiagramCanvas(
                  nodes: nodes,
                  connections: connections,
                  selectedNode: selectedNode,
                  panOffset: panOffset,
                  scale: currentScale,
                  canvasKey: _canvasKey, // Agregar el GlobalKey
                  onPanUpdate: (details) {
                    if (!isConnecting) {
                      setState(() {
                        panOffset += details.delta;
                      });
                    }
                  },
                  onScaleUpdate: (scale) {
                    if (!isConnecting) {
                      setState(() {
                        currentScale = scale.scale.clamp(0.5, 2.0);
                      });
                    }
                  },
                  onNodeTap: (node) {
                    print('Editor recibió tap en nodo: ${node?.type}');
                    setState(() {
                      if (node == null) {
                        // Si se toca un área vacía, deseleccionamos todo
                        if (!isConnecting) {
                          print('Deseleccionando nodo');
                          selectedNode = null;
                          selectedConnection = null;
                        }
                      } else if (isConnecting && connectionStart != null) {
                        // Si estamos en modo conexión y ya tenemos un nodo de origen,
                        // este tap es para seleccionar el nodo destino y crear la conexión
                        if (connectionStart != node) {
                          // Evitar conectar un nodo consigo mismo
                          _createConnection(connectionStart!, node);
                          // Después de crear la conexión, salimos del modo conexión
                          isConnecting = false;
                          connectionStart = null;
                        } else {
                          _showSnackBar(
                              'No puedes conectar un nodo consigo mismo');
                        }
                      } else {
                        // Si no estamos en modo conexión, simplemente seleccionamos el nodo
                        print('Seleccionando nodo: ${node.type}');
                        selectedNode = node;
                        selectedConnection =
                            null; // Deseleccionar cualquier conexión
                      }
                    });

                    // Mostrar indicación visual de que el nodo fue seleccionado
                    // if (node != null && !isConnecting) {
                    //   String nodeName = "";
                    //   switch (node.type) {
                    //     case NodeType.start:
                    //       nodeName = "Inicio";
                    //       break;
                    //     case NodeType.end:
                    //       nodeName = "Fin";
                    //       break;
                    //     case NodeType.process:
                    //       nodeName = "Proceso";
                    //       break;
                    //     case NodeType.decision:
                    //       nodeName = "Decisión";
                    //       break;
                    //     case NodeType.loop:
                    //       nodeName = "Bucle";
                    //       break;
                    //     case NodeType.input:
                    //       nodeName = "Entrada";
                    //       break;
                    //     case NodeType.output:
                    //       nodeName = "Salida";
                    //       break;
                    //     case NodeType.variable:
                    //       nodeName = "Variable";
                    //       break;
                    //     case NodeType.connector:
                    //       nodeName = "Conector";
                    //       break;
                    //     case NodeType.comment:
                    //       nodeName = "Comentario";
                    //       break;
                    //     case NodeType.subprocess:
                    //       nodeName = "Subproceso";
                    //       break;
                    //   }
                    //   _showSnackBar('Nodo ${nodeName} seleccionado');
                    // }
                  },
                  onNodeLongPress: (node) {
                    setState(() {
                      // Solo iniciar conexión si no estamos ya en ese modo
                      if (!isConnecting) {
                        connectionStart = node;
                        selectedNode = node;
                        isConnecting = true;
                        // _showSnackBar('Selecciona otro nodo para conectarlos');
                      }
                    });
                  },
                  onNodeDragUpdate: (node, offset) {
                    setState(() {
                      node.position = offset;
                      _hasUnsavedChanges = true;
                    });
                  },
                  onConnectionTap: (connection) {
                    setState(() {
                      selectedConnection = connection;
                      selectedNode = null; // Deseleccionar cualquier nodo
                      _showConnectionOptionsDialog(connection);
                    });
                  },
                ),

                // Indicador visual cuando estamos en modo conexión
                if (isConnecting)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Modo conexión: Toca otro nodo para conectar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isConnecting)
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  connectionStart = null;
                  isConnecting = false;
                });
                // _showSnackBar('Conexión cancelada');
              },
              heroTag: 'cancel',
              mini: true,
              tooltip: 'Cancelar conexión',
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                // Resetear el desplazamiento y la escala
                panOffset = Offset.zero;
                currentScale = 1.0;
              });
            },
            heroTag: 'center',
            tooltip: 'Centrar diagrama',
            child: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
    );
  }

  // Control de navegación hacia atrás con verificación de cambios sin guardar
  Future<void> _handleBackNavigation(BuildContext context) async {
    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    final bool shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Descartar cambios?'),
            content: const Text(
              'Hay cambios sin guardar. ¿Estás seguro de que quieres salir sin guardar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Descartar'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldDiscard && mounted) {
      Navigator.pop(context);
    }
  }

  void _addNode(NodeType nodeType, {bool autoSelect = true}) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: nodeType,
      position: Offset(
        (MediaQuery.of(context).size.width / 2 - panOffset.dx) / currentScale,
        (MediaQuery.of(context).size.height / 2 - panOffset.dy) / currentScale,
      ),
    );

    setState(() {
      nodes.add(node);
      if (autoSelect) {
        selectedNode = node;
      }
      _hasUnsavedChanges = true;
    });

    // Registrar métrica de creación de nodo
    _metricsService.trackUserAction(
      action: 'diagrama_creado',
      category: 'editor',
      metadata: {'node_type': nodeType.toString()},
    );

    // Mostrar diálogo para editar el nodo recién creado
    _editSelectedNode();
  }

  void _addConcept(ProgrammingConceptType conceptType) {
    // Calcular posición central para el nuevo nodo
    final centerPosition = Offset(
      (MediaQuery.of(context).size.width / 2 - panOffset.dx) / currentScale,
      (MediaQuery.of(context).size.height / 2 - panOffset.dy) / currentScale,
    );

    switch (conceptType) {
      // ==========================================
      // FASE 1: Nodos simples (1 símbolo)
      // ==========================================
      case ProgrammingConceptType.scanf:
        _addScanfConcept(centerPosition);
        break;
      case ProgrammingConceptType.printf:
        _addPrintfConcept(centerPosition);
        break;
      case ProgrammingConceptType.declareInt:
        _addDeclareIntConcept(centerPosition);
        break;
      case ProgrammingConceptType.assignment:
        _addAssignmentConcept(centerPosition);
        break;
      case ProgrammingConceptType.function:
        _addFunctionConcept(centerPosition);
        break;
      case ProgrammingConceptType.struct:
        _addStructConcept(centerPosition);
        break;
      case ProgrammingConceptType.pointer:
        _addPointerConcept(centerPosition);
        break;

      // ==========================================
      // FASE 2: Estructuras compuestas
      // ==========================================
      case ProgrammingConceptType.loopFor:
        _addForLoopConcept(centerPosition);
        break;
      case ProgrammingConceptType.loopWhile:
        _addWhileLoopConcept(centerPosition);
        break;
      case ProgrammingConceptType.ifElse:
        _addIfElseConcept(centerPosition);
        break;
      case ProgrammingConceptType.switchStructure:
        _addSwitchConcept(centerPosition);
        break;
    }
  }

  // ==========================================
  // FASE 1: Implementación de conceptos simples
  // ==========================================

  /// Agrega un nodo de entrada scanf() - Símbolo ISO 5807: Paralelogramo (data)
  void _addScanfConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.data,
      position: position,
      text: 'scanf("%d", &x)',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'scanf', 'node_type': 'data'},
    );

    // Mostrar diálogo para personalizar
    _editSelectedNode();
  }

  /// Agrega un nodo de salida printf() - Símbolo ISO 5807: Paralelogramo (data)
  void _addPrintfConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.data,
      position: position,
      text: 'printf("Resultado: %d\\n", x)',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'printf', 'node_type': 'data'},
    );

    _editSelectedNode();
  }

  /// Agrega un nodo de declaración de entero - Símbolo ISO 5807: Rectángulo (process)
  void _addDeclareIntConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.process,
      position: position,
      text: 'int x = 0',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'declareInt', 'node_type': 'process'},
    );

    _editSelectedNode();
  }

  /// Agrega un nodo de asignación - Símbolo ISO 5807: Rectángulo (process)
  void _addAssignmentConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.process,
      position: position,
      text: 'x = valor',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'assignment', 'node_type': 'process'},
    );

    _editSelectedNode();
  }

  /// Agrega un nodo de función/subproceso - Símbolo ISO 5807: Rectángulo con doble línea (predefinedProcess)
  void _addFunctionConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.predefinedProcess,
      position: position,
      text: 'miFuncion()',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'function', 'node_type': 'predefinedProcess'},
    );

    _editSelectedNode();
  }

  /// Agrega un nodo de estructura (struct) - Símbolo ISO 5807: Rectángulo (process)
  void _addStructConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.process,
      position: position,
      text: 'struct Punto { int x; int y; }',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'struct', 'node_type': 'process'},
    );

    _editSelectedNode();
  }

  /// Agrega un nodo de puntero - Símbolo ISO 5807: Rectángulo (process)
  void _addPointerConcept(Offset position) {
    final node = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.process,
      position: position,
      text: 'int *ptr = NULL',
    );

    setState(() {
      nodes.add(node);
      selectedNode = node;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'pointer', 'node_type': 'process'},
    );

    _editSelectedNode();
  }

  // ==========================================
  // FASE 2: Implementación de estructuras compuestas
  // ==========================================

  /// Agrega estructura For Loop (2 nodos + conexiones)
  /// Basado en diagrama ISO 5807:
  /// - 1 nodo decisión (condición del for)
  /// - 1 nodo proceso (cuerpo del for)
  /// - Conexión de retorno del proceso al nodo de decisión
  void _addForLoopConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Nodo 1: Decisión (condición del bucle)
    final decisionNode = DiagramNode(
      id: '${timestamp}_for_decision',
      type: NodeType.decision,
      position: position,
      text: 'i < 10',
      metadata: {
        'structureType': 'loop',
        'loopType': 'for',
        'role': 'loop-condition',
      },
    );

    // Nodo 2: Proceso (cuerpo del for)
    final bodyNode = DiagramNode(
      id: '${timestamp}_for_body',
      type: NodeType.process,
      position: Offset(position.dx, position.dy + 150),
      text: '// Cuerpo del for\ni++',
      metadata: {
        'structureType': 'loop',
        'loopType': 'for',
        'role': 'loop-body',
      },
    );

    // Crear conexiones
    final trueConnection = Connection(
      source: decisionNode,
      target: bodyNode,
      label: 'Sí',
    );

    // Conexión de retorno (loop back)
    final loopBackConnection = Connection(
      source: bodyNode,
      target: decisionNode,
      label: '',
      isLoopBack: true,
    );

    setState(() {
      nodes.addAll([decisionNode, bodyNode]);
      connections.addAll([trueConnection, loopBackConnection]);
      selectedNode = decisionNode;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'forLoop', 'nodes_created': 2},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura For creada. Conecta la salida "No" para continuar el flujo.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Agrega estructura While Loop (2 nodos + conexiones)
  /// Basado en diagrama ISO 5807:
  /// - 1 nodo decisión (Test Condition)
  /// - 1 nodo proceso (while loop body)
  /// - Conexión de retorno del proceso al nodo de decisión
  void _addWhileLoopConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Nodo 1: Decisión (condición del while)
    final decisionNode = DiagramNode(
      id: '${timestamp}_while_decision',
      type: NodeType.decision,
      position: position,
      text: 'condicion',
      metadata: {
        'structureType': 'loop',
        'loopType': 'while',
        'role': 'loop-condition',
      },
    );

    // Nodo 2: Proceso (cuerpo del while)
    final bodyNode = DiagramNode(
      id: '${timestamp}_while_body',
      type: NodeType.process,
      position: Offset(position.dx, position.dy + 150),
      text: '// Cuerpo del while',
      metadata: {
        'structureType': 'loop',
        'loopType': 'while',
        'role': 'loop-body',
      },
    );

    // Crear conexiones
    final trueConnection = Connection(
      source: decisionNode,
      target: bodyNode,
      label: 'Verdadero',
    );

    // Conexión de retorno (loop back)
    final loopBackConnection = Connection(
      source: bodyNode,
      target: decisionNode,
      label: '',
      isLoopBack: true,
    );

    setState(() {
      nodes.addAll([decisionNode, bodyNode]);
      connections.addAll([trueConnection, loopBackConnection]);
      selectedNode = decisionNode;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'whileLoop', 'nodes_created': 2},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura While creada. Conecta la salida "Falso" para continuar el flujo.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Agrega estructura If-Else (3 nodos + conexiones)
  /// Basado en diagrama ISO 5807:
  /// - 1 nodo decisión (condición)
  /// - 1 nodo proceso (rama if/verdadero)
  /// - 1 nodo proceso (rama else/falso)
  void _addIfElseConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Nodo 1: Decisión (condición)
    final decisionNode = DiagramNode(
      id: '${timestamp}_if_decision',
      type: NodeType.decision,
      position: position,
      text: 'x > 0',
    );

    // Nodo 2: Proceso (rama if - verdadero)
    final ifNode = DiagramNode(
      id: '${timestamp}_if_true',
      type: NodeType.process,
      position: Offset(position.dx - 120, position.dy + 150),
      text: '// Bloque if',
    );

    // Nodo 3: Proceso (rama else - falso)
    final elseNode = DiagramNode(
      id: '${timestamp}_if_false',
      type: NodeType.process,
      position: Offset(position.dx + 120, position.dy + 150),
      text: '// Bloque else',
    );

    // Crear conexiones
    final trueConnection = Connection(
      source: decisionNode,
      target: ifNode,
      label: 'Sí',
    );

    final falseConnection = Connection(
      source: decisionNode,
      target: elseNode,
      label: 'No',
    );

    setState(() {
      nodes.addAll([decisionNode, ifNode, elseNode]);
      connections.addAll([trueConnection, falseConnection]);
      selectedNode = decisionNode;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'ifElse', 'nodes_created': 3},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura If-Else creada. Puedes conectar las salidas a los siguientes nodos.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Agrega estructura Switch (8 nodos + conexiones)
  /// Basado en diagrama ISO 5807:
  /// - 1 nodo proceso (switch expression)
  /// - 3 nodos decisión (case 1, case 2, case n/default check)
  /// - 4 nodos proceso (statement blocks para cada caso + default)
  void _addSwitchConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Espaciado vertical entre niveles
    const double verticalSpacing = 120.0;
    const double horizontalOffset = 200.0;

    // Nodo 1: Proceso (expresión del switch)
    final switchExprNode = DiagramNode(
      id: '${timestamp}_switch_expr',
      type: NodeType.process,
      position: position,
      text: 'switch(opcion)',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-header',
        'variable': 'opcion',
      },
    );

    // Nodo 2: Decisión case 1
    final case1Decision = DiagramNode(
      id: '${timestamp}_case1_decision',
      type: NodeType.decision,
      position: Offset(position.dx, position.dy + verticalSpacing),
      text: 'opcion == 1',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case',
        'caseValue': '1',
        'parentSwitch': 'opcion',
      },
    );

    // Nodo 3: Proceso case 1
    final case1Process = DiagramNode(
      id: '${timestamp}_case1_process',
      type: NodeType.process,
      position:
          Offset(position.dx + horizontalOffset, position.dy + verticalSpacing),
      text: '// Caso 1',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case-body',
        'caseValue': '1',
      },
    );

    // Nodo 4: Decisión case 2
    final case2Decision = DiagramNode(
      id: '${timestamp}_case2_decision',
      type: NodeType.decision,
      position: Offset(position.dx, position.dy + verticalSpacing * 2),
      text: 'opcion == 2',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case',
        'caseValue': '2',
        'parentSwitch': 'opcion',
      },
    );

    // Nodo 5: Proceso case 2
    final case2Process = DiagramNode(
      id: '${timestamp}_case2_process',
      type: NodeType.process,
      position: Offset(
          position.dx + horizontalOffset, position.dy + verticalSpacing * 2),
      text: '// Caso 2',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case-body',
        'caseValue': '2',
      },
    );

    // Nodo 6: Decisión case n (o verificación default)
    final caseNDecision = DiagramNode(
      id: '${timestamp}_caseN_decision',
      type: NodeType.decision,
      position: Offset(position.dx, position.dy + verticalSpacing * 3),
      text: 'opcion == n',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case',
        'caseValue': 'n',
        'parentSwitch': 'opcion',
      },
    );

    // Nodo 7: Proceso case n
    final caseNProcess = DiagramNode(
      id: '${timestamp}_caseN_process',
      type: NodeType.process,
      position: Offset(
          position.dx + horizontalOffset, position.dy + verticalSpacing * 3),
      text: '// Caso n',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case-body',
        'caseValue': 'n',
      },
    );

    // Nodo 8: Proceso default
    final defaultProcess = DiagramNode(
      id: '${timestamp}_default_process',
      type: NodeType.process,
      position: Offset(position.dx, position.dy + verticalSpacing * 4),
      text: '// Default',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-default',
        'parentSwitch': 'opcion',
      },
    );

    // Crear conexiones
    final List<Connection> switchConnections = [
      // switch expr -> case 1 decision
      Connection(source: switchExprNode, target: case1Decision, label: ''),

      // case 1 decision -> case 1 process (true)
      Connection(source: case1Decision, target: case1Process, label: 'Sí'),

      // case 1 decision -> case 2 decision (false)
      Connection(source: case1Decision, target: case2Decision, label: 'No'),

      // case 2 decision -> case 2 process (true)
      Connection(source: case2Decision, target: case2Process, label: 'Sí'),

      // case 2 decision -> case n decision (false)
      Connection(source: case2Decision, target: caseNDecision, label: 'No'),

      // case n decision -> case n process (true)
      Connection(source: caseNDecision, target: caseNProcess, label: 'Sí'),

      // case n decision -> default process (false)
      Connection(source: caseNDecision, target: defaultProcess, label: 'No'),
    ];

    setState(() {
      nodes.addAll([
        switchExprNode,
        case1Decision,
        case1Process,
        case2Decision,
        case2Process,
        caseNDecision,
        caseNProcess,
        defaultProcess,
      ]);
      connections.addAll(switchConnections);
      selectedNode = switchExprNode;
      _hasUnsavedChanges = true;
    });

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'switch', 'nodes_created': 8},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura Switch creada con 8 nodos. Puedes editar cada nodo y conectar las salidas.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _createConnection(DiagramNode source, DiagramNode target) {
    // No crear conexión si es el mismo nodo
    if (source == target) {
      connectionStart = null;
      isConnecting = false;
      return;
    }

    // Verificar que la conexión sea válida según el tipo de nodo
    if (_isValidConnection(source, target)) {
      // Detectar automáticamente si esta conexión debe ser de tipo cuadrada
      // (conexión de retorno a un nodo de decisión)
      bool shouldBeLoopBack = _isReturnToDecisionNode(source, target);

      // Establecer etiqueta predeterminada según el tipo de nodo
      String defaultLabel = '';

      // Si el nodo fuente es una decisión, mostrar diálogo para elegir etiqueta
      if (source.type == NodeType.decision) {
        _showConnectionLabelDialog(source, target,
            isLoopBack: shouldBeLoopBack);
      } else {
        final connection = Connection(
          source: source,
          target: target,
          label: defaultLabel,
          isLoopBack: shouldBeLoopBack,
        );
        setState(() {
          connections.add(connection);
          _hasUnsavedChanges = true;
          connectionStart = null;
          isConnecting = false;
        });

        // if (shouldBeLoopBack) {
        //   _showSnackBar(
        //       'Conexión creada (flecha cuadrada detectada automáticamente)');
        // } else {
        //   _showSnackBar('Conexión creada');
        // }
      }
    } else {
      setState(() {
        connectionStart = null;
        isConnecting = false;
      });
    }
  }

  // Detectar si una conexión es de retorno a un nodo de decisión
  bool _isReturnToDecisionNode(DiagramNode source, DiagramNode target) {
    // Si el destino es un nodo de decisión y hay una ruta desde ese nodo
    // de decisión de vuelta al nodo fuente, es probable que sea un bucle
    if (target.type == NodeType.decision) {
      // Verificar si ya existe una ruta del nodo de decisión al nodo fuente
      return _hasPathBetweenNodes(target, source, {});
    }
    return false;
  }

  // Verificar si hay un camino entre dos nodos
  bool _hasPathBetweenNodes(
    DiagramNode from,
    DiagramNode to,
    Set<String> visited,
  ) {
    if (from.id == to.id) return true;
    if (visited.contains(from.id)) return false;

    visited.add(from.id);

    final outConnections =
        connections.where((conn) => conn.source.id == from.id).toList();

    for (final conn in outConnections) {
      if (_hasPathBetweenNodes(conn.target, to, Set.from(visited))) {
        return true;
      }
    }

    return false;
  }

  // Diálogo para editar la etiqueta de una conexión
  Future<void> _showConnectionLabelDialog(
    DiagramNode source,
    DiagramNode target, {
    bool isLoopBack = false,
  }) async {
    final TextEditingController labelController = TextEditingController();

    // Establecer etiqueta predeterminada para nodos de decisión
    if (source.type == NodeType.decision) {
      // Verificar si ya hay otras conexiones desde este nodo de decisión
      final existingConnections =
          connections.where((c) => c.source == source).toList();
      if (existingConnections.isEmpty) {
        // Primera conexión, sugerimos "Verdadero" como etiqueta
        labelController.text = "Verdadero";
      } else if (existingConnections.length == 1) {
        // Segunda conexión, sugerimos "Falso" como etiqueta
        labelController.text = "Falso";
      }
    }

    final String? label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiqueta de conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Etiqueta',
                hintText: 'ej: Verdadero, Falso, Sí, No',
              ),
              autofocus: true,
            ),
            if (isLoopBack)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta conexión se dibujará con flecha cuadrada (retorno de bucle)',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(labelController.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (label != null) {
      final connection = Connection(
        source: source,
        target: target,
        label: label,
        isLoopBack: isLoopBack,
      );
      setState(() {
        connections.add(connection);
        _hasUnsavedChanges = true;
        connectionStart = null;
        isConnecting = false;
      });

      // if (isLoopBack) {
      //   _showSnackBar(
      //       'Conexión creada con flecha cuadrada y etiqueta "$label"');
      // } else {
      //   _showSnackBar('Conexión creada con etiqueta "$label"');
      // }
    } else {
      // Si se canceló el diálogo, cancelar la creación de la conexión
      setState(() {
        connectionStart = null;
        isConnecting = false;
      });
    }
  }

  // Método para eliminar una conexión seleccionada
  void _deleteConnection(Connection connection) {
    setState(() {
      connections.remove(connection);
      _hasUnsavedChanges = true;
    });
    // _showSnackBar('Conexión eliminada');
  }

  // Mostrar menú de opciones para una conexión
  Future<void> _showConnectionOptionsDialog(Connection connection) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Origen: ${_getNodeTypeName(connection.source.type)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Destino: ${_getNodeTypeName(connection.target.type)}',
              style: const TextStyle(fontSize: 14),
            ),
            if (connection.label.isNotEmpty)
              Text(
                'Etiqueta: "${connection.label}"',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${connection.isLoopBack ? "Flecha Cuadrada" : "Flecha Recta"}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('edit_label'),
            icon: const Icon(Icons.label),
            label: const Text('Editar Etiqueta'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('toggle_type'),
            icon:
                Icon(connection.isLoopBack ? Icons.timeline : Icons.turn_left),
            label: Text(
              connection.isLoopBack ? 'Cambiar a Recta' : 'Cambiar a Cuadrada',
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('delete'),
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      switch (result) {
        case 'edit_label':
          await _editConnectionLabel(connection);
          break;
        case 'toggle_type':
          _toggleConnectionType(connection);
          break;
        case 'delete':
          _deleteConnection(connection);
          break;
        case 'cancel':
          // No hacer nada
          break;
      }
    }
  }

  // Editar etiqueta de una conexión existente
  Future<void> _editConnectionLabel(Connection connection) async {
    final TextEditingController labelController =
        TextEditingController(text: connection.label);

    final String? newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Etiqueta'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText: 'Etiqueta',
            hintText: 'ej: Sí, No, Verdadero, Falso',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(labelController.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newLabel != null) {
      setState(() {
        connection.label = newLabel;
        _hasUnsavedChanges = true;
      });
      // _showSnackBar('Etiqueta actualizada');
    }
  }

  // Cambiar tipo de conexión entre recta y cuadrada
  void _toggleConnectionType(Connection connection) {
    setState(() {
      connection.isLoopBack = !connection.isLoopBack;
      _hasUnsavedChanges = true;
    });
    // _showSnackBar(
    //   connection.isLoopBack
    //       ? 'Conexión cambiada a flecha cuadrada'
    //       : 'Conexión cambiada a flecha recta',
    // );
  }

  // Obtener nombre legible del tipo de nodo
  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.terminal:
        return 'Terminal';
      case NodeType.process:
        return 'Proceso';
      case NodeType.decision:
        return 'Decisión';
      case NodeType.preparation:
        return 'Preparación';
      case NodeType.data:
        return 'Dato';
      case NodeType.predefinedProcess:
        return 'Subproceso/Función';
      default:
        return type.isoName;
    }
  }

  bool _isValidConnection(DiagramNode source, DiagramNode target) {
    // Un nodo terminal de fin no puede tener salidas
    final sourceIsEnd = source.type == NodeType.terminal &&
        (source.text.toLowerCase().contains('fin') ||
            source.text.toLowerCase().contains('end') ||
            source.text.toLowerCase().contains('terminar'));

    if (sourceIsEnd) {
      // _showSnackBar('Un nodo terminal de fin no puede tener conexiones de salida');
      return false;
    }

    // Un nodo terminal de inicio no puede tener entradas
    final targetIsStart = target.type == NodeType.terminal &&
        (target.text.toLowerCase().contains('inicio') ||
            target.text.toLowerCase().contains('start') ||
            target.text.isEmpty);

    if (targetIsStart) {
      // _showSnackBar('Un nodo terminal de inicio no puede tener conexiones de entrada');
      return false;
    }

    // Evitar conexiones duplicadas
    bool isDuplicate = connections.any(
      (conn) => conn.source == source && conn.target == target,
    );

    if (isDuplicate) {
      // _showSnackBar('Esta conexión ya existe');
      return false;
    }

    // Si pasó todas las validaciones, la conexión es válida
    return true;
  }

  Future<void> _editSelectedNode() async {
    if (selectedNode == null) return;

    final dynamic result = await showDialog<dynamic>(
      context: context,
      builder: (context) => NodeEditorDialog(node: selectedNode!),
    );

    if (result != null) {
      setState(() {
        // Si el resultado es un NodeDialogResult (condición de bucle o switch)
        if (result is NodeDialogResult) {
          selectedNode!.text = result.text;

          // Si se debe generar la estructura de bucle
          if (result.generateLoopStructure) {
            _generateLoopStructure(
              selectedNode!,
              result.loopVariable ?? '',
              result.loopLimit ?? '',
              result.loopCondition ?? '<',
            );
          }

          // Si se debe generar la estructura de switch-case
          if (result.generateSwitchStructure) {
            _generateSwitchStructure(
              selectedNode!,
              result.switchVariable ?? '',
              result.switchCases ?? [],
              result.hasDefaultCase,
            );
          }
        } else if (result is String) {
          // Si es solo un String, actualizar el texto normalmente
          selectedNode!.text = result;
        }
        _hasUnsavedChanges = true;
      });
    }
  }

  /// Genera automáticamente la estructura básica de un bucle while
  ///
  /// Crea:
  /// 1. Nodo de decisión (rombo) - ya existe, es el selectedNode
  /// 2. Nodo de proceso (rectángulo) - cuerpo del bucle
  /// 3. Conexiones:
  ///    - Decisión -> Proceso (etiqueta "Verdadero" o "Sí")
  ///    - Proceso -> Decisión (flecha de retorno)
  void _generateLoopStructure(
    DiagramNode decisionNode,
    String loopVariable,
    String loopLimit,
    String condition,
  ) {
    // Calcular posición para el nodo de proceso (debajo del nodo de decisión)
    final processPosition = Offset(
      decisionNode.position.dx,
      decisionNode.position.dy + 150, // 150 píxeles debajo
    );

    // Crear el nodo de proceso (cuerpo del bucle)
    final processNode = DiagramNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NodeType.process,
      position: processPosition,
      text: 'Cuerpo del bucle\n// Incrementar $loopVariable',
    );

    // Agregar el nodo de proceso
    nodes.add(processNode);

    // Crear conexión: Decisión -> Proceso (cuando la condición es verdadera)
    final trueConnection = Connection(
      source: decisionNode,
      target: processNode,
      label: 'Verdadero',
    );

    // Crear conexión: Proceso -> Decisión (retorno al inicio del bucle)
    final loopBackConnection = Connection(
      source: processNode,
      target: decisionNode,
      label: '',
      isLoopBack:
          true, // Marcar como conexión de retorno para dibujar en forma cuadrada
    );

    // Agregar las conexiones
    connections.add(trueConnection);
    connections.add(loopBackConnection);

    // Mostrar mensaje informativo
    // _showSnackBar(
    //   'Estructura de bucle creada. Conecta la salida "Falso" para continuar el flujo.',
    // );
  }

  /// Genera automáticamente la estructura básica de switch-case
  ///
  /// Transforma el nodo de decisión en un nodo de proceso que representa
  /// la expresión del switch, y crea múltiples nodos de decisión (rombos)
  /// conectados para representar cada caso.
  ///
  /// Estructura generada:
  /// 1. Nodo de proceso (rectángulo) - expresión switch(variable)
  /// 2. Múltiples nodos de decisión (rombos) - uno por cada caso
  /// 3. Conexiones desde el proceso a cada rombo case
  void _generateSwitchStructure(
    DiagramNode originalNode,
    String switchVariable,
    List<SwitchCaseData> switchCases,
    bool hasDefaultCase,
  ) {
    // Guardar la posición del nodo original
    final originalPosition = originalNode.position;

    // Crear un nuevo nodo de proceso para reemplazar el nodo de decisión original
    final processNode = DiagramNode(
      id: originalNode.id, // Mantener el mismo ID
      type: NodeType.process,
      position: originalPosition,
      text: 'switch($switchVariable)',
    );

    // Remover el nodo original y agregar el nuevo nodo de proceso
    nodes.remove(originalNode);
    nodes.add(processNode);

    // También necesitamos actualizar todas las conexiones que apuntaban al nodo original
    for (final connection in connections) {
      if (connection.source == originalNode) {
        // Reemplazar la referencia en la conexión
        final newConnection = Connection(
          source: processNode,
          target: connection.target,
          label: connection.label,
          isLoopBack: connection.isLoopBack,
        );
        connections.remove(connection);
        connections.add(newConnection);
      }
      if (connection.target == originalNode) {
        final newConnection = Connection(
          source: connection.source,
          target: processNode,
          label: connection.label,
          isLoopBack: connection.isLoopBack,
        );
        connections.remove(connection);
        connections.add(newConnection);
      }
    }

    // Actualizar selectedNode para que apunte al nuevo nodo
    selectedNode = processNode;

    // Espaciado entre nodos de caso
    const double horizontalSpacing = 180.0;
    const double verticalOffset = 150.0;

    // Calcular la posición inicial para centrar los casos
    final double totalWidth = (switchCases.length - 1) * horizontalSpacing;
    final double startX = originalPosition.dx - (totalWidth / 2);

    // Crear un nodo de decisión (rombo) para cada caso
    for (int i = 0; i < switchCases.length; i++) {
      final caseData = switchCases[i];

      // Calcular posición del rombo (distribuidos horizontalmente)
      final casePosition = Offset(
        startX + (i * horizontalSpacing),
        originalPosition.dy + verticalOffset,
      );

      // Crear nodo de decisión para el caso
      final caseNode = DiagramNode(
        id: '${DateTime.now().millisecondsSinceEpoch}_case_$i',
        type: NodeType.decision,
        position: casePosition,
        text: caseData.label.isNotEmpty
            ? caseData.label
            : 'case ${caseData.value}',
      );

      // Agregar el nodo de caso
      nodes.add(caseNode);

      // Crear conexión desde el nodo switch al nodo case
      final caseConnection = Connection(
        source: processNode,
        target: caseNode,
        label: 'case ${caseData.value}',
      );

      connections.add(caseConnection);
    }

    // Si hay caso default, crear un nodo adicional
    if (hasDefaultCase) {
      final defaultPosition = Offset(
        startX + (switchCases.length * horizontalSpacing),
        originalPosition.dy + verticalOffset,
      );

      final defaultNode = DiagramNode(
        id: '${DateTime.now().millisecondsSinceEpoch}_default',
        type: NodeType.decision,
        position: defaultPosition,
        text: 'default',
      );

      nodes.add(defaultNode);

      final defaultConnection = Connection(
        source: processNode,
        target: defaultNode,
        label: 'default',
      );

      connections.add(defaultConnection);
    }
  }

  void _deleteSelectedNode() {
    if (selectedNode == null) return;

    // Eliminar también todas las conexiones relacionadas con este nodo
    setState(() {
      connections.removeWhere(
        (connection) =>
            connection.source == selectedNode ||
            connection.target == selectedNode,
      );

      nodes.remove(selectedNode);
      selectedNode = null;
      _hasUnsavedChanges = true;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // Método para validar el diagrama
  void _validateDiagram() {
    final ValidationResult result = DiagramValidator.validateDiagram(
      nodes,
      connections,
    );

    // Registrar métrica de validación
    _metricsService.trackUserAction(
      action: result.isValid ? 'validacion_exitosa' : 'validacion_fallida',
      category: 'validation',
      metadata: {
        'nodes_count': nodes.length,
        'connections_count': connections.length,
        'errors_count': result.errors.length,
        'warnings_count': result.warnings.length,
      },
    );

    _showValidationDialog(result);
  }

  // Mostrar el diálogo con los resultados de la validación
  void _showValidationDialog(ValidationResult result) {
    showDialog(
      context: context,
      builder: (context) => ValidationResultDialog(result: result),
    );
  }

  // Método para generar código
  void _generateCode() {
    // Primero validamos el diagrama
    final validationResult = DiagramValidator.validateDiagram(
      nodes,
      connections,
    );
    if (!validationResult.isValid) {
      // Si hay errores, mostramos el diálogo de validación
      _showValidationDialog(validationResult);
      return;
    }

    // Si el diagrama es válido, generamos el código en C
    final code = CodeGenerator.generateCode(
      nodes,
      connections,
      ProgrammingLanguage.c,
    );

    // Registrar métrica de generación de código
    _metricsService.trackUserAction(
      action: 'codigo_generado',
      category: 'code_generation',
      metadata: {
        'nodes_count': nodes.length,
        'connections_count': connections.length,
        'code_lines': code.split('\n').length,
        'language': 'c',
      },
    );

    _showCodeDialog(code);
  }

  // Mostrar el diálogo con el código generado
  void _showCodeDialog(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código C generado'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              // Copiar el código al portapapeles
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo para guardar el diagrama
  Future<void> _showSaveDiagramDialog() async {
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveDiagramDialog(
        initialName: currentDiagram?.name,
        initialDescription: currentDiagram?.description,
        isUpdate: currentDiagram != null,
      ),
    );

    if (result != null && mounted) {
      final now = DateTime.now();

      try {
        if (currentDiagram == null) {
          // Crear un nuevo diagrama
          final newDiagram = SavedDiagram(
            name: result['name'],
            description: result['description'],
            createdAt: now,
            updatedAt: now,
            nodes: nodes,
            connections: connections,
          );

          final id = await _databaseService.saveDiagram(newDiagram);
          setState(() {
            currentDiagram = newDiagram.copyWith(id: id);
            _hasUnsavedChanges = false;
          });
          // _showSnackBar('Diagrama guardado correctamente');
        } else {
          // Actualizar diagrama existente
          final updatedDiagram = currentDiagram!.copyWith(
            name: result['name'],
            description: result['description'],
            updatedAt: now,
            nodes: nodes,
            connections: connections,
          );

          await _databaseService.updateDiagram(updatedDiagram);
          setState(() {
            currentDiagram = updatedDiagram;
            _hasUnsavedChanges = false;
          });
          // _showSnackBar('Diagrama actualizado correctamente');
        }
      } catch (e) {
        // _showSnackBar('Error al guardar: ${e.toString()}');
      }
    }
  }

  // Navegar a la pantalla de carga de diagramas
  Future<void> _navigateToLoadDiagram(BuildContext context) async {
    // Verificar si hay cambios sin guardar
    if (_hasUnsavedChanges) {
      final bool? shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text(
            'Hay cambios sin guardar. ¿Deseas guardar antes de continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No guardar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showSaveDiagramDialog();
              },
              child: const Text('Guardar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (shouldProceed == null) {
        return; // Operación cancelada
      }

      if (shouldProceed) {
        // El usuario eligió guardar, esperamos a que termine
        await _showSaveDiagramDialog();
      }
    }

    // Ahora navegamos a la pantalla de carga
    if (!mounted) return;

    final result = await Navigator.push<SavedDiagram?>(
      context,
      MaterialPageRoute(builder: (context) => const LoadDiagramScreen()),
    );

    // Si se seleccionó un diagrama, cargarlo
    if (result != null && mounted) {
      _loadDiagram(result);
    }
  }

  // Métodos de exportación de diagramas

  /// Exporta el diagrama actual como imagen PNG
  Future<void> _exportDiagramAsPNG() async {
    try {
      if (nodes.isEmpty) {
        _showSnackBar('No hay nodos para exportar');
        return;
      }

      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exportando imagen PNG...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Generar nombre del archivo
      final String diagramName = currentDiagram?.name ?? 'diagrama';

      // Exportar usando el servicio
      final String filePath = await DiagramExportService.exportDiagramToPNG(
        canvasKey: _canvasKey,
        diagramName: diagramName,
      );

      // Cerrar el diálogo de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado exitoso
      _showSuccessDialog(
        'PNG exportado exitosamente',
        'El diagrama se guardó en:\n$filePath',
      );
    } catch (e) {
      // Cerrar el diálogo de progreso si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      _showSnackBar('Error al exportar PNG: $e');
    }
  }

  /// Exporta el diagrama actual como imagen JPG
  Future<void> _exportDiagramAsJPG() async {
    try {
      if (nodes.isEmpty) {
        _showSnackBar('No hay nodos para exportar');
        return;
      }

      // Mostrar indicador de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Exportando imagen JPG...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Generar nombre del archivo
      final String diagramName = currentDiagram?.name ?? 'diagrama';

      // Exportar usando el servicio
      final String filePath = await DiagramExportService.exportDiagramToJPG(
        canvasKey: _canvasKey,
        diagramName: diagramName,
      );

      // Cerrar el diálogo de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado exitoso
      _showSuccessDialog(
        'JPG exportado exitosamente',
        'El diagrama se guardó en:\n$filePath',
      );
    } catch (e) {
      // Cerrar el diálogo de progreso si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      _showSnackBar('Error al exportar JPG: $e');
    }
  }

  /// Muestra un diálogo de éxito con información detallada
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
