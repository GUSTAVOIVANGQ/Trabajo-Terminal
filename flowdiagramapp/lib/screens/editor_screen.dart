import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/flow_diagram_canvas_final.dart';
import '../widgets/programming_concepts_palette.dart';
import '../widgets/editor_side_panel.dart';
import '../widgets/node_editor_dialog.dart';
import '../widgets/validation_result_dialog.dart';
import '../widgets/compiler_results_dialog.dart'; // Dialog del conversor
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
import '../services/auth_service.dart'; // Importación para autenticación
import '../services/auto_save_settings_service.dart';
import '../compiler/compiler.dart'; // Conversor completo
import '../interactive_tutorials/auto_tutorial_models.dart';
import '../interactive_tutorials/auto_tutorial_controller.dart';
import '../interactive_tutorials/auto_tutorial_script.dart';
import '../interactive_tutorials/auto_tutorial_overlay.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class _DiagramHistorySnapshot {
  final List<DiagramNode> nodes;
  final List<Connection> connections;
  final String? selectedNodeId;

  const _DiagramHistorySnapshot({
    required this.nodes,
    required this.connections,
    required this.selectedNodeId,
  });
}

class EditorScreen extends StatefulWidget {
  final SavedDiagram? initialDiagram;

  /// Si se proporciona, abre el editor vacío y lanza el tutorial automático.
  final AutoTutorialDefinition? autoTutorial;

  const EditorScreen({super.key, this.initialDiagram, this.autoTutorial});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  static const double _minZoomScale = 0.5;
  static const double _maxZoomScale = 2.0;
  static const double _zoomStep = 0.1;
  static const int _maxHistoryStates = 100;
  static const Duration _autoSaveInterval = Duration(seconds: 2);

  final List<DiagramNode> nodes = [];
  final List<Connection> connections = [];
  DiagramNode? selectedNode;
  Connection? selectedConnection; // Nueva propiedad para conexión seleccionada
  DiagramNode? connectionStart;
  Offset panOffset = Offset.zero;
  double currentScale = 1.0;
  bool isConnecting = false;

  // Variables para manejar zoom con punto focal
  double _scaleStart = 1.0;
  Offset _focalPointStart = Offset.zero;
  Offset _panOffsetStart = Offset.zero;

  // Para control de guardado
  SavedDiagram? currentDiagram;
  final DatabaseService _databaseService = DatabaseService();
  final MetricsService _metricsService = MetricsService(); // Nuevo servicio
  final AuthService _authService = AuthService(); // Servicio de autenticación
  final AutoSaveSettingsService _autoSaveSettingsService =
      AutoSaveSettingsService();
  bool _hasUnsavedChanges = false;
  bool _autoSaveEnabled = false;
  bool _isAutoSaving = false;
  Timer? _autoSaveTimer;

  final List<_DiagramHistorySnapshot> _history = [];
  int _historyIndex = -1;
  int _savedHistoryIndex = -1;
  bool _isApplyingHistory = false;
  bool _showPageBoundary = false; // Estado del límite de página

  bool get _canUndo => _historyIndex > 0;
  bool get _canRedo =>
      _historyIndex >= 0 && _historyIndex < _history.length - 1;

  // GlobalKey para capturar el canvas y exportar
  final GlobalKey _canvasKey = GlobalKey();

  // Keys para el Tour de la App
  final GlobalKey _editorSidePanelKey = GlobalKey();
  final GlobalKey _editorSaveKey = GlobalKey();
  final GlobalKey _editorCompileKey = GlobalKey();
  final GlobalKey _editorZoomKey = GlobalKey();

  // ── Tutorial automático ──────────────────────────────────────────────────
  late final AutoTutorialController _tutorialController;

  /// Obtiene el ID del usuario actual (o 'guest' para invitados)
  String? _getCurrentUserId() {
    final user = _authService.currentUser;
    if (user == null) return null;
    return user.isGuest ? 'guest_${user.uid}' : user.uid;
  }

  @override
  void initState() {
    super.initState();

    // Inicializar el controlador de tutorial automático
    _tutorialController = AutoTutorialController(
      onAddNode: ({required type, required nodeId, required position, content}) async {
        if (!mounted) return;
        await _addTutorialNode(
          type: type,
          nodeId: nodeId,
          position: position,
          content: content,
        );
      },
      onConnectNodes: ({required sourceId, required targetId}) async {
        if (!mounted) return;
        await _createConnectionByIds(
          sourceId: sourceId,
          targetId: targetId,
        );
      },
      onRunValidation: () async {
        if (!mounted) return;
        _compileWithFullPipeline();
      },
      onViewGeneratedCode: () async {
        if (!mounted) return;
        _compileWithFullPipeline();
      },
      onSaveDiagram: () async {
        if (!mounted) return;
        _showSaveDiagramDialog();
      },
    );

    // Si se proporciona un diagrama inicial, cargarlo
    if (widget.initialDiagram != null) {
      _loadDiagram(widget.initialDiagram!);
    } else {
      _resetHistoryFromCurrentState();
    }

    _initializeAutoSave();

    // Arrancar tutorial automático tras el primer frame
    if (widget.autoTutorial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _tutorialController.startTutorial(widget.autoTutorial!, context);
          }
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFirstTimeEditor();
      });
    }
  }

  Future<void> _checkFirstTimeEditor() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('tutorial_shown_editor') ?? false;
    if (!hasShown && mounted) {
      await prefs.setBool('tutorial_shown_editor', true);
      _showEditorTour();
    }
  }

  void _showEditorTour() {
    List<TargetFocus> targets = [];
    
    targets.add(TargetFocus(
      identify: "sidePanel",
      keyTarget: _editorSidePanelKey,
      shape: ShapeLightFocus.RRect,
      alignSkip: Alignment.topRight,
      contents: [
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            left: 110, // Just to the right of the side panel
            top: MediaQuery.of(context).size.height * 0.3,
          ),
          builder: (context, controller) {
            return Container(
              width: MediaQuery.of(context).size.width - 130, // Fit the remaining screen
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Panel de Herramientas", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Aquí encontrarás todos los nodos disponibles. Solo toca uno para agregarlo al diagrama.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "canvas",
      keyTarget: _canvasKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.custom,
          customPosition: CustomTargetContentPosition(
            left: 40,
            top: MediaQuery.of(context).size.height * 0.3,
          ),
          builder: (context, controller) {
            return Container(
              width: MediaQuery.of(context).size.width - 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Área de Trabajo", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Este es tu lienzo. Arrastra los nodos para moverlos. Si mantienes presionado un nodo, podrás arrastrar una flecha para conectarlo con otro.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "save",
      keyTarget: _editorSaveKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Guardar Progreso", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Guarda tu diagrama para no perder el trabajo. Si tienes autoguardado activado, se hará solo.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "compile",
      keyTarget: _editorCompileKey,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Magia: Generar Código", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Presiona aquí para validar tu diagrama y convertirlo automáticamente a código fuente funcional en lenguaje C.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "zoom",
      keyTarget: _editorZoomKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Control de Vista", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Usa estos botones para acercar, alejar o centrar el diagrama en la pantalla.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SALTAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    ).show(context: context);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tutorialController.dispose();
    super.dispose();
  }

  void _loadDiagram(SavedDiagram diagram) {
    final loadedNodes = _cloneNodes(diagram.nodes);
    final loadedNodeById = {for (final node in loadedNodes) node.id: node};
    final loadedConnections =
        _cloneConnections(diagram.connections, loadedNodeById);

    setState(() {
      nodes.clear();
      connections.clear();

      // Agregar nodos y conexiones del diagrama cargado
      nodes.addAll(loadedNodes);
      connections.addAll(loadedConnections);
      selectedNode = null;
      selectedConnection = null;
      connectionStart = null;
      isConnecting = false;

      // Almacenar referencia al diagrama actual
      currentDiagram = diagram;
      _hasUnsavedChanges = false;
    });

    _resetHistoryFromCurrentState();
  }

  Future<void> _initializeAutoSave() async {
    final userId = _authService.currentUser?.uid;
    final enabled =
        await _autoSaveSettingsService.isAutoSaveEnabled(userId: userId);

    if (!mounted) return;

    _autoSaveEnabled = enabled;
    _configureAutoSaveTimer();
  }

  void _configureAutoSaveTimer() {
    _autoSaveTimer?.cancel();

    if (!_autoSaveEnabled) {
      return;
    }

    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      _performAutoSave();
    });
  }

  Future<void> _performAutoSave() async {
    if (!_autoSaveEnabled || _isAutoSaving || !_hasUnsavedChanges) {
      return;
    }

    _isAutoSaving = true;

    try {
      final now = DateTime.now();
      final userId = _getCurrentUserId();

      if (currentDiagram == null) {
        final String draftName =
            'borrador_${DateFormat('yyyyMMdd_HHmmss').format(now)}';
        final draftDiagram = SavedDiagram(
          name: draftName,
          description: 'Autoguardado',
          createdAt: now,
          updatedAt: now,
          nodes: nodes,
          connections: connections,
          userId: userId,
        );

        final id = await _databaseService.saveDiagram(draftDiagram);

        if (!mounted) return;

        setState(() {
          currentDiagram = draftDiagram.copyWith(id: id);
          _markCurrentStateAsSavedInHistory();
        });
      } else {
        final updatedDiagram = currentDiagram!.copyWith(
          updatedAt: now,
          nodes: nodes,
          connections: connections,
          userId: currentDiagram!.userId ?? userId,
        );

        await _databaseService.updateDiagram(updatedDiagram);

        if (!mounted) return;

        setState(() {
          currentDiagram = updatedDiagram;
          _markCurrentStateAsSavedInHistory();
        });
      }
    } catch (_) {
      // El autoguardado no debe bloquear la edición si falla.
    } finally {
      _isAutoSaving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): _redo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): _redo,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(currentDiagram?.name ?? 'Diagrama de Flujo', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2), Color(0xFF4CA1AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _handleBackNavigation(context),
            ),
            actions: [
              IconButton(
                key: EditorTutorialKeys.undoButton,
                icon: const Icon(Icons.undo),
                tooltip: 'Deshacer',
                onPressed: _canUndo ? _undo : null,
              ),
              IconButton(
                key: EditorTutorialKeys.redoButton,
                icon: const Icon(Icons.redo),
                tooltip: 'Rehacer',
                onPressed: _canRedo ? _redo : null,
              ),
              // Botón para guardar diagrama
              Container(
                key: _editorSaveKey,
                child: IconButton(
                  key: EditorTutorialKeys.saveButton,
                  icon: _hasUnsavedChanges
                      ? const Icon(Icons.save, color: Colors.amber)
                      : const Icon(Icons.save),
                  tooltip: 'Guardar diagrama',
                  onPressed: _showSaveDiagramDialog,
                ),
              ),
              // Botón para cargar diagrama
              IconButton(
                key: EditorTutorialKeys.loadButton,
                icon: const Icon(Icons.folder_open),
                tooltip: 'Cargar diagrama',
                onPressed: () => _navigateToLoadDiagram(context),
              ),
              // Botón para visualizar área de página
              IconButton(
                icon: Icon(_showPageBoundary ? Icons.border_clear : Icons.border_outer),
                tooltip: _showPageBoundary ? 'Ocultar área de página' : 'Mostrar área de página',
                onPressed: () {
                  setState(() {
                    _showPageBoundary = !_showPageBoundary;
                  });
                },
              ),
              // Botón de compilación: ejecuta el conversor completo (validación + análisis + generación)
              Container(
                key: _editorCompileKey,
                child: IconButton(
                  key: EditorTutorialKeys.compileButton,
                  icon: const Icon(Icons.code),
                  tooltip: 'Generar código',
                  onPressed: _compileWithFullPipeline,
                ),
              ),
              // MENÚ COMENTADO — opciones separadas (Generador Simple / Conversor Avanzado)
              // PopupMenuButton<String>(
              //   icon: const Icon(Icons.code),
              //   tooltip: 'Generar código',
              //   onSelected: (value) {
              //     if (value == 'simple') {
              //       _generateCode();           // Generador Simple: traducción directa a C
              //     } else if (value == 'compiler') {
              //       _compileWithFullPipeline(); // Conversor Avanzado: análisis completo + optimización
              //     }
              //   },
              //   itemBuilder: (context) => [
              //     const PopupMenuItem(
              //       value: 'simple',
              //       child: Row(
              //         children: [
              //           Icon(Icons.flash_on, color: Colors.orange),
              //           SizedBox(width: 8),
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Generador Simple'),
              //               Text(
              //                 'Traducción directa a C',
              //                 style: TextStyle(fontSize: 11, color: Colors.grey),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //     const PopupMenuItem(
              //       value: 'compiler',
              //       child: Row(
              //         children: [
              //           Icon(Icons.precision_manufacturing, color: Colors.blue),
              //           SizedBox(width: 8),
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text('Conversor Avanzado'),
              //               Text(
              //                 'Análisis completo + Optimización',
              //                 style: TextStyle(fontSize: 11, color: Colors.grey),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              // Menú de exportación
              PopupMenuButton<String>(
                key: EditorTutorialKeys.exportButton,
                icon: const Icon(Icons.file_download),
                tooltip: 'Exportar diagrama',
                onSelected: (value) {
                  if (value == 'png') {
                    _exportDiagramAsPNG();
                  } else if (value == 'jpg') {
                    _exportDiagramAsJPG();
                  } else if (value == 'pdf') {
                    _exportDiagramAsPDF();
                  } else if (value == 'c') {
                    _exportCodeAsCFile();
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
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf),
                        SizedBox(width: 8),
                        Text('Exportar como PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'c',
                    child: Row(
                      children: [
                        Icon(Icons.description),
                        SizedBox(width: 8),
                        Text('Exportar código .c'),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
          body: Row(
            children: [
              // Panel lateral con pestañas para símbolos y conceptos
              Container(
                key: _editorSidePanelKey,
                child: EditorSidePanel(
                  onNodeSelected: (nodeType) {
                    // No seleccionar automáticamente el nodo si estamos en modo conexión
                    _addNode(nodeType, autoSelect: !isConnecting);
                  },
                  onConceptSelected: (conceptType) {
                    _addConcept(conceptType);
                  },
                ),
              ),

              // Área principal del canvas
              Expanded(
                child: Stack(
                  children: [
                    FlowDiagramCanvas(
                      key: EditorTutorialKeys.canvas,
                      nodes: nodes,
                      connections: connections,
                      selectedNode: selectedNode,
                      selectedConnection: selectedConnection,
                      panOffset: panOffset,
                      scale: currentScale,
                      showPageBoundary: _showPageBoundary,
                      canvasKey: _canvasKey, // Agregar el GlobalKey
                      onPanUpdate: (details) {
                        if (!isConnecting) {
                          setState(() {
                            panOffset += details.delta;
                          });
                        }
                      },
                      onScaleStart: (details) {
                        // Guardar estado inicial del zoom para cálculo correcto
                        _scaleStart = currentScale;
                        _focalPointStart = details.localFocalPoint;
                        _panOffsetStart = panOffset;
                      },
                      onScaleUpdate: (details) {
                        if (!isConnecting) {
                          setState(() {
                            // Calcular la nueva escala basada en la escala inicial
                            final newScale = (_scaleStart * details.scale)
                                .clamp(_minZoomScale, _maxZoomScale)
                                .toDouble();

                            // Calcular el punto focal en coordenadas del canvas (antes de la transformación)
                            // focalPoint = panOffset + focalPointLocal / scale
                            final focalPointCanvas =
                                (_focalPointStart - _panOffsetStart) /
                                    _scaleStart;

                            // Calcular el nuevo panOffset para mantener el punto focal en la misma posición
                            // Queremos que: focalPointLocal = panOffset + focalPointCanvas * scale
                            // Por lo tanto: panOffset = focalPointLocal - focalPointCanvas * scale
                            final newPanOffset = details.localFocalPoint -
                                focalPointCanvas * newScale;

                            currentScale = newScale;
                            panOffset = newPanOffset;
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
                        });
                      },
                      onNodeDragEnd: (didMove) {
                        if (!didMove) return;

                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                        _recordHistoryState();
                      },
                      onConnectionTap: (connection) {
                        // Single-tap: solo seleccionar la conexión (sin abrir diálogo)
                        setState(() {
                          selectedConnection = connection;
                          selectedNode = null;
                        });
                      },
                      onConnectionLongPress: (connection) {
                        // Long-press: abrir opciones avanzadas de la conexión
                        setState(() {
                          selectedConnection = connection;
                          selectedNode = null;
                        });
                        _showConnectionOptionsDialog(connection);
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

                    // ── Toolbar flotante de nodo seleccionado ──
                    if (selectedNode != null && !isConnecting)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(28),
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Nombre del tipo de nodo
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      _getNodeTypeName(selectedNode!.type),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 4,
                                      child: VerticalDivider(thickness: 1)),
                                  // Editar nodo
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Editar nodo',
                                    onPressed: () => _editSelectedNode(),
                                  ),
                                  // Cambiar color
                                  IconButton(
                                    icon: const Icon(Icons.palette_outlined),
                                    tooltip: 'Cambiar color',
                                    onPressed: () => _showColorPicker(),
                                  ),
                                  // Crear conexión
                                  IconButton(
                                    icon: const Icon(Icons.link),
                                    tooltip: 'Crear conexión',
                                    onPressed: () {
                                      setState(() {
                                        connectionStart = selectedNode;
                                        isConnecting = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                      width: 4,
                                      child: VerticalDivider(thickness: 1)),
                                  // Eliminar nodo
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    tooltip: 'Eliminar nodo',
                                    onPressed: () => _deleteSelectedNode(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Toolbar de conexión seleccionada ──
                    if (selectedConnection != null && !isConnecting)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(28),
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Etiqueta
                                  IconButton(
                                    icon: const Icon(Icons.label_outline),
                                    tooltip: 'Editar etiqueta',
                                    onPressed: () async {
                                      final conn = selectedConnection!;
                                      await _editConnectionLabel(conn);
                                      setState(() {});
                                    },
                                  ),
                                  // Tipo (recta / cuadrada)
                                  IconButton(
                                    icon: Icon(selectedConnection!.isLoopBack
                                        ? Icons.timeline
                                        : Icons.turn_left),
                                    tooltip: selectedConnection!.isLoopBack
                                        ? 'Cambiar a recta'
                                        : 'Cambiar a cuadrada',
                                    onPressed: () {
                                      _toggleConnectionType(selectedConnection!);
                                    },
                                  ),
                                  // Más opciones (abre el diálogo completo)
                                  IconButton(
                                    icon: const Icon(Icons.tune),
                                    tooltip: 'Más opciones',
                                    onPressed: () =>
                                        _showConnectionOptionsDialog(
                                            selectedConnection!),
                                  ),
                                  const SizedBox(
                                      width: 4,
                                      child: VerticalDivider(thickness: 1)),
                                  // Eliminar
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    tooltip: 'Eliminar flecha',
                                    onPressed: () {
                                      final conn = selectedConnection!;
                                      setState(() {
                                        selectedConnection = null;
                                      });
                                      _deleteConnection(conn);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Barra de control del tutorial automático ──
                    ListenableBuilder(
                      listenable: _tutorialController,
                      builder: (ctx, _) {
                        if (!_tutorialController.state.isActive) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          bottom: 100,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: AutoTutorialControlBar(
                              controller: _tutorialController,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            key: _editorZoomKey,
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
                onPressed: currentScale >= _maxZoomScale
                    ? null
                    : () => _zoomCanvas(zoomIn: true),
                heroTag: 'zoom_in',
                mini: true,
                tooltip: 'Acercar (+)',
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: currentScale <= _minZoomScale
                    ? null
                    : () => _zoomCanvas(zoomIn: false),
                heroTag: 'zoom_out',
                mini: true,
                tooltip: 'Alejar (-)',
                child: const Icon(Icons.zoom_out),
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
        ),
      ),
    );
  }



  void _zoomCanvas({required bool zoomIn}) {
    if (isConnecting) return;

    final renderObject = _canvasKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final focalPointLocal = renderObject.size.center(Offset.zero);
    final targetScale =
        zoomIn ? (currentScale + _zoomStep) : (currentScale - _zoomStep);
    final newScale = targetScale.clamp(_minZoomScale, _maxZoomScale).toDouble();

    if ((newScale - currentScale).abs() < 0.0001) return;

    setState(() {
      // Mantener fijo el centro visible del canvas al aplicar zoom por botón.
      final focalPointCanvas = (focalPointLocal - panOffset) / currentScale;
      panOffset = focalPointLocal - focalPointCanvas * newScale;
      currentScale = newScale;
    });
  }

  List<DiagramNode> _cloneNodes(List<DiagramNode> sourceNodes) {
    return sourceNodes
        .map(
          (node) => node.copyWith(
            position: Offset(node.position.dx, node.position.dy),
            metadata: Map<String, dynamic>.from(node.metadata),
          ),
        )
        .toList();
  }

  List<Connection> _cloneConnections(
    List<Connection> sourceConnections,
    Map<String, DiagramNode> nodeById,
  ) {
    final clonedConnections = <Connection>[];

    for (final connection in sourceConnections) {
      final source = nodeById[connection.source.id];
      final target = nodeById[connection.target.id];

      if (source == null || target == null) continue;

      clonedConnections.add(
        Connection(
          source: source,
          target: target,
          label: connection.label,
          isLoopBack: connection.isLoopBack,
          sourceAnchor: connection.sourceAnchor,
          targetAnchor: connection.targetAnchor,
        ),
      );
    }

    return clonedConnections;
  }

  _DiagramHistorySnapshot _createSnapshotFromCurrentState() {
    final snapshotNodes = _cloneNodes(nodes);
    final nodeById = {for (final node in snapshotNodes) node.id: node};
    final snapshotConnections = _cloneConnections(connections, nodeById);

    return _DiagramHistorySnapshot(
      nodes: snapshotNodes,
      connections: snapshotConnections,
      selectedNodeId: selectedNode?.id,
    );
  }

  void _applySnapshot(_DiagramHistorySnapshot snapshot) {
    _isApplyingHistory = true;

    final restoredNodes = _cloneNodes(snapshot.nodes);
    final restoredNodeById = {for (final node in restoredNodes) node.id: node};
    final restoredConnections =
        _cloneConnections(snapshot.connections, restoredNodeById);

    nodes
      ..clear()
      ..addAll(restoredNodes);
    connections
      ..clear()
      ..addAll(restoredConnections);

    selectedNode = snapshot.selectedNodeId != null
        ? restoredNodeById[snapshot.selectedNodeId!]
        : null;
    selectedConnection = null;
    connectionStart = null;
    isConnecting = false;

    _isApplyingHistory = false;
  }

  void _updateUnsavedChangesFlagFromHistory() {
    _hasUnsavedChanges =
        _savedHistoryIndex < 0 || _historyIndex != _savedHistoryIndex;
  }

  void _resetHistoryFromCurrentState() {
    _history
      ..clear()
      ..add(_createSnapshotFromCurrentState());
    _historyIndex = 0;
    _savedHistoryIndex = 0;
    _updateUnsavedChangesFlagFromHistory();
  }

  void _recordHistoryState() {
    if (_isApplyingHistory) return;

    if (_historyIndex >= 0 && _historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
      if (_savedHistoryIndex > _historyIndex) {
        _savedHistoryIndex = -1;
      }
    }

    _history.add(_createSnapshotFromCurrentState());
    _historyIndex = _history.length - 1;

    if (_history.length > _maxHistoryStates) {
      _history.removeAt(0);
      _historyIndex--;

      if (_savedHistoryIndex >= 0) {
        _savedHistoryIndex--;
        if (_savedHistoryIndex < 0) {
          _savedHistoryIndex = -1;
        }
      }
    }

    _updateUnsavedChangesFlagFromHistory();
  }

  void _markCurrentStateAsSavedInHistory() {
    _savedHistoryIndex = _historyIndex;
    _updateUnsavedChangesFlagFromHistory();
  }

  void _undo() {
    if (!_canUndo) return;

    setState(() {
      _historyIndex--;
      _applySnapshot(_history[_historyIndex]);
      _updateUnsavedChangesFlagFromHistory();
    });
  }

  void _redo() {
    if (!_canRedo) return;

    setState(() {
      _historyIndex++;
      _applySnapshot(_history[_historyIndex]);
      _updateUnsavedChangesFlagFromHistory();
    });
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
    _recordHistoryState();

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
      case ProgrammingConceptType.loopDoWhile:
        _addDoWhileLoopConcept(centerPosition);
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
    _recordHistoryState();

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
    _recordHistoryState();

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
    _recordHistoryState();

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
    _recordHistoryState();

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
    _recordHistoryState();

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
    _recordHistoryState();

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
    _recordHistoryState();

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
  /// Basado en diagrama ISO 5807 y plantilla 11 (Tabla de Multiplicar):
  /// - 1 nodo preparación/hexágono (for con init, condición, incremento)
  /// - 1 nodo proceso (cuerpo del for)
  /// - Conexión "Verdadero" del for al cuerpo
  /// - Conexión de retorno del cuerpo al for (isLoopBack)
  /// - Salida "Falso" para conectar al siguiente nodo
  void _addForLoopConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Nodo 1: Preparación/Hexágono (estructura for completa)
    final forNode = DiagramNode(
      id: '${timestamp}_for_loop',
      type: NodeType.preparation,
      position: position,
      text: 'for (i = 0; i < 10; i++)',
      metadata: {
        'structureType': 'loop',
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 10',
        'forIncrement': 'i++',
        'role': 'loop-header',
      },
    );

    // Nodo 2: Proceso (cuerpo del for) - posicionado a la derecha
    final bodyNode = DiagramNode(
      id: '${timestamp}_for_body',
      type: NodeType.process,
      position: Offset(position.dx + 220, position.dy),
      text: '// Cuerpo del for',
      metadata: {
        'structureType': 'loop',
        'loopType': 'for',
        'role': 'loop-body',
      },
    );

    // Conexión "Verdadero" del for al cuerpo
    final trueConnection = Connection(
      source: forNode,
      target: bodyNode,
      label: 'Verdadero',
    );

    // Conexión de retorno (loop back) del cuerpo al for
    final loopBackConnection = Connection(
      source: bodyNode,
      target: forNode,
      label: '',
      isLoopBack: true,
    );

    setState(() {
      nodes.addAll([forNode, bodyNode]);
      connections.addAll([trueConnection, loopBackConnection]);
      selectedNode = forNode;
      _hasUnsavedChanges = true;
    });
    _recordHistoryState();

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'forLoop', 'nodes_created': 2},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura For creada. Conecta la salida "Falso" para continuar el flujo después del bucle.'),
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
    _recordHistoryState();

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

  /// Agrega estructura Do-While Loop (2 nodos + conexiones)
  /// Basado en diagrama de flujo estándar para do-while:
  /// - 1 nodo proceso (cuerpo del do-while, se ejecuta primero)
  /// - 1 nodo decisión (condición al final)
  /// - Conexión "Verdadero/True" de la condición regresa al cuerpo
  /// - Conexión "Falso/False" sale del bucle
  void _addDoWhileLoopConcept(Offset position) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Nodo 1: Proceso (cuerpo del do-while, se ejecuta primero)
    final bodyNode = DiagramNode(
      id: '${timestamp}_dowhile_body',
      type: NodeType.process,
      position: position,
      text: '// Cuerpo del do-while',
      metadata: {
        'structureType': 'loop',
        'loopType': 'do-while',
        'role': 'loop-body',
      },
    );

    // Nodo 2: Decisión (condición evaluada después del cuerpo)
    final conditionNode = DiagramNode(
      id: '${timestamp}_dowhile_condition',
      type: NodeType.decision,
      position: Offset(position.dx, position.dy + 150),
      text: 'condicion',
      metadata: {
        'structureType': 'loop',
        'loopType': 'do-while',
        'role': 'loop-condition',
      },
    );

    // Conexión del cuerpo a la condición
    final bodyToConditionConnection = Connection(
      source: bodyNode,
      target: conditionNode,
      label: '',
    );

    // Conexión de retorno (loop back): True/Verdadero regresa al cuerpo
    final loopBackConnection = Connection(
      source: conditionNode,
      target: bodyNode,
      label: 'Verdadero',
      isLoopBack: true,
    );

    setState(() {
      nodes.addAll([bodyNode, conditionNode]);
      connections.addAll([bodyToConditionConnection, loopBackConnection]);
      selectedNode = bodyNode;
      _hasUnsavedChanges = true;
    });
    _recordHistoryState();

    _metricsService.trackUserAction(
      action: 'concepto_agregado',
      category: 'editor',
      metadata: {'concept_type': 'doWhileLoop', 'nodes_created': 2},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Estructura Do-While creada. Conecta un nodo de entrada al cuerpo y la salida "Falso" para salir del bucle.'),
        duration: Duration(seconds: 3),
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
    _recordHistoryState();

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
    _recordHistoryState();

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
        _recordHistoryState();

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

  // Detectar si una conexión crea un ciclo (back-edge) en el grafo.
  // Detecta conexiones de retorno para ciclos while, do-while, etc.
  // Si ya existe un camino del target al source, crear esta conexión
  // formaría un ciclo, indicando que es una conexión de retorno (loopback).
  bool _isReturnToDecisionNode(DiagramNode source, DiagramNode target) {
    // Verificar si ya existe una ruta del target al source
    // Si existe, esta conexión crearía un ciclo (es un back-edge)
    return _hasPathBetweenNodes(target, source, {});
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
      _recordHistoryState();

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
    _recordHistoryState();
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
            const SizedBox(height: 4),
            Text(
              'Salida: ${_getAnchorName(connection.sourceAnchor)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Entrada: ${_getAnchorName(connection.targetAnchor)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop('rotate_source'),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotar punto de salida',
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop('rotate_target'),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotar punto de entrada',
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('edit_label'),
            icon: const Icon(Icons.label),
            label: const Text('Etiqueta'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop('toggle_type'),
            icon:
                Icon(connection.isLoopBack ? Icons.timeline : Icons.turn_left),
            label: Text(
              connection.isLoopBack ? 'Recta' : 'Cuadrada',
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
        case 'rotate_source':
          setState(() {
            connection.sourceAnchor = _getNextAnchor(connection.sourceAnchor);
            _hasUnsavedChanges = true;
          });
          _recordHistoryState();
          _showConnectionOptionsDialog(connection);
          break;
        case 'rotate_target':
          setState(() {
            connection.targetAnchor = _getNextAnchor(connection.targetAnchor);
            _hasUnsavedChanges = true;
          });
          _recordHistoryState();
          _showConnectionOptionsDialog(connection);
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

  ConnectionAnchor _getNextAnchor(ConnectionAnchor current) {
    switch (current) {
      case ConnectionAnchor.auto:
        return ConnectionAnchor.top;
      case ConnectionAnchor.top:
        return ConnectionAnchor.right;
      case ConnectionAnchor.right:
        return ConnectionAnchor.bottom;
      case ConnectionAnchor.bottom:
        return ConnectionAnchor.left;
      case ConnectionAnchor.left:
        return ConnectionAnchor.auto;
    }
  }

  String _getAnchorName(ConnectionAnchor anchor) {
    switch (anchor) {
      case ConnectionAnchor.auto:
        return 'Auto';
      case ConnectionAnchor.top:
        return 'Arriba';
      case ConnectionAnchor.bottom:
        return 'Abajo';
      case ConnectionAnchor.left:
        return 'Izquierda';
      case ConnectionAnchor.right:
        return 'Derecha';
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
      _recordHistoryState();
      // _showSnackBar('Etiqueta actualizada');
    }
  }

  // Cambiar tipo de conexión entre recta y cuadrada
  void _toggleConnectionType(Connection connection) {
    setState(() {
      connection.isLoopBack = !connection.isLoopBack;
      _hasUnsavedChanges = true;
    });
    _recordHistoryState();
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
      _showSnackBar('Un nodo terminal de fin no puede tener conexiones de salida');
      return false;
    }

    // Un nodo terminal de inicio no puede tener entradas
    final targetIsStart = target.type == NodeType.terminal &&
        (target.text.toLowerCase().contains('inicio') ||
            target.text.toLowerCase().contains('start') ||
            target.text.isEmpty);

    if (targetIsStart) {
      _showSnackBar('Un nodo terminal de inicio no puede tener conexiones de entrada');
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
      _recordHistoryState();
    }
  }

  Future<void> _showColorPicker() async {
    if (selectedNode == null) return;

    final List<Color> predefinedColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
      Colors.blueGrey,
    ];

    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elegir color'),
        content: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: predefinedColors.map((color) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(Colors.transparent),
            child: const Text('Por defecto'),
          ),
        ],
      ),
    );

    if (pickedColor != null && mounted) {
      setState(() {
        if (pickedColor == Colors.transparent) {
          selectedNode!.metadata.remove('customColor');
        } else {
          selectedNode!.metadata['customColor'] = pickedColor.value;
        }
        _hasUnsavedChanges = true;
      });
      _recordHistoryState();
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
    _recordHistoryState();
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

  // Método para generar código con el generador simple (original)
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
        'generator': 'simple',
      },
    );

    _showCodeDialog(code);
  }

  // Método para convertir con el pipeline completo (todas las fases).
  // Este método es el único punto de entrada para compilar: ejecuta primero
  // la validación estructural (Fase 0 / E-SYN) y luego el pipeline completo.
  // El botón "Generar código" del AppBar llama directamente a este método.
  void _compileWithFullPipeline() {
    // Verificar que hay nodos en el diagrama
    if (nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El diagrama está vacío'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ── Fase 0: Validación estructural del grafo (E-SYN) ────────────────────
    // Se ejecuta siempre, antes que cualquier fase del compilador.
    // El resultado se pasa al diálogo para mostrarse en la primera pestaña.
    final ValidationResult structuralResult = DiagramValidator.validateDiagram(
      nodes,
      connections,
    );

    // ── Fases 1-5: Pipeline del conversor ──────────────────────────────────
    // Crear el conversor con opciones estándar
    final compiler = DiagramCompilerPipeline(
      options: const CompilerOptions(
        optimizationLevel: 2, // Nivel estándar de optimización
        generateComments: true,
        strictTypeChecking: false,
      ),
    );

    // Ejecutar el pipeline completo (léxico → sintáctico → semántico → RI → código)
    final result = compiler.compile(nodes, connections);

    // Generar código con el generador legacy para la pestaña de código del diálogo
    String? legacyCode;
    if (result.success || result.errors.errorCount == 0) {
      legacyCode = CodeGenerator.generateCode(
        nodes,
        connections,
        ProgrammingLanguage.c,
      );
    }

    // Registrar métrica de conversión
    _metricsService.trackUserAction(
      action: 'compilacion_completa',
      category: 'code_generation',
      metadata: {
        'nodes_count': nodes.length,
        'connections_count': connections.length,
        'structural_valid': structuralResult.isValid,
        'success': result.success,
        'errors': result.errors.errorCount,
        'warnings': result.errors.warningCount,
        'compilation_time_ms': result.metrics.compilationTimeMs,
        'tokens_generated': result.metrics.tokensGenerated,
        'symbols_in_table': result.metrics.symbolsInTable,
        'generator': 'compiler_pipeline',
      },
    );

    // Mostrar el diálogo de resultados del conversor.
    // structuralResult se pasa para que la primera pestaña muestre
    // la validación estructural (E-SYN) antes que las fases del compilador.
    showDialog(
      context: context,
      builder: (context) => CompilerResultsDialog(
        result: result,
        legacyCode: legacyCode,
        structuralResult: structuralResult, // Resultado Fase 0 (E-SYN)
      ),
    );
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
      final userId = _getCurrentUserId(); // Obtener userId actual

      try {
        if (currentDiagram == null) {
          // Crear un nuevo diagrama con el userId del usuario actual
          final newDiagram = SavedDiagram(
            name: result['name'],
            description: result['description'],
            createdAt: now,
            updatedAt: now,
            nodes: nodes,
            connections: connections,
            userId: userId, // Asignar el userId
          );

          final id = await _databaseService.saveDiagram(newDiagram);
          setState(() {
            currentDiagram = newDiagram.copyWith(id: id);
            _markCurrentStateAsSavedInHistory();
          });
          // _showSnackBar('Diagrama guardado correctamente');
        } else {
          // Actualizar diagrama existente (mantener userId original o asignar si no tiene)
          final updatedDiagram = currentDiagram!.copyWith(
            name: result['name'],
            description: result['description'],
            updatedAt: now,
            nodes: nodes,
            connections: connections,
            userId:
                currentDiagram!.userId ?? userId, // Mantener userId o asignar
          );

          await _databaseService.updateDiagram(updatedDiagram);
          setState(() {
            currentDiagram = updatedDiagram;
            _markCurrentStateAsSavedInHistory();
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

      final ThemeData exportTheme = Theme.of(context);
      final bool isDarkMode = exportTheme.brightness == Brightness.dark;

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
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
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

      final ThemeData exportTheme = Theme.of(context);
      final bool isDarkMode = exportTheme.brightness == Brightness.dark;

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
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
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

  /// Exporta el diagrama actual como PDF básico
  Future<void> _exportDiagramAsPDF() async {
    try {
      if (nodes.isEmpty) {
        _showSnackBar('No hay nodos para exportar');
        return;
      }

      final ThemeData exportTheme = Theme.of(context);
      final bool isDarkMode = exportTheme.brightness == Brightness.dark;

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
                  Text('Exportando PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final String diagramName = currentDiagram?.name ?? 'diagrama';

      final String filePath = await DiagramExportService.exportDiagramToPDF(
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
        diagramName: diagramName,
      );

      _metricsService.trackUserAction(
        action: 'exportacion_pdf',
        category: 'export',
        metadata: {
          'nodes_count': nodes.length,
          'connections_count': connections.length,
          'format': 'pdf',
        },
      );

      if (mounted) Navigator.of(context).pop();

      _showFileSuccessDialog(
        'PDF exportado exitosamente',
        'El archivo PDF se guardó en:\n$filePath',
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnackBar('Error al exportar PDF: $e');
    }
  }

  /// Exporta el código C generado como archivo .c
  Future<void> _exportCodeAsCFile() async {
    try {
      if (nodes.isEmpty) {
        _showSnackBar('No hay nodos para exportar');
        return;
      }

      final validationResult = DiagramValidator.validateDiagram(
        nodes,
        connections,
      );

      if (!validationResult.isValid) {
        _showValidationDialog(validationResult);
        return;
      }

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
                  Text('Exportando código .c...'),
                ],
              ),
            ),
          ),
        ),
      );

      final String code = CodeGenerator.generateCode(
        nodes,
        connections,
        ProgrammingLanguage.c,
      );

      if (code.trim().isEmpty || code.trim().startsWith('// Error:')) {
        throw Exception('No se pudo generar código C válido para exportación');
      }

      final String diagramName = currentDiagram?.name ?? 'diagrama';
      final String filePath = await DiagramExportService.exportCodeToCFile(
        code: code,
        diagramName: diagramName,
      );

      _metricsService.trackUserAction(
        action: 'exportacion_codigo_c',
        category: 'export',
        metadata: {
          'nodes_count': nodes.length,
          'connections_count': connections.length,
          'code_lines': code.split('\n').length,
          'format': 'c',
        },
      );

      if (mounted) Navigator.of(context).pop();

      _showFileSuccessDialog(
        'Código C exportado exitosamente',
        'El archivo .c se guardó en:\n$filePath',
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnackBar('Error al exportar código .c: $e');
    }
  }

  /// Muestra un diálogo genérico para archivos exportados
  void _showFileSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de éxito con información detallada
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_library,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Puedes encontrar la imagen en:\n📁 Galería > FlowDiagramApp\n📁 Archivos > Pictures > FlowDiagramApp',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Métodos del tutorial automático
  // ─────────────────────────────────────────────────────────────────────────

  /// Agrega un nodo con ID fijo para que el script pueda referenciarlo.
  Future<void> _addTutorialNode({
    required AutoTutorialNodeType type,
    required String nodeId,
    required Offset position,
    String? content,
  }) async {
    final nodeType = _mapAutoNodeType(type);
    final text = content ?? _defaultTextForAutoType(type);
    final node = DiagramNode(
      id: nodeId,
      type: nodeType,
      position: position,
      text: text,
    );
    setState(() {
      nodes.add(node);
      _hasUnsavedChanges = true;
    });
    _recordHistoryState();
  }

  /// Crea una conexión buscando los nodos por sus IDs.
  Future<void> _createConnectionByIds({
    required String sourceId,
    required String targetId,
  }) async {
    final source = nodes.where((n) => n.id == sourceId).firstOrNull;
    final target = nodes.where((n) => n.id == targetId).firstOrNull;
    if (source == null || target == null) return;
    _createConnection(source, target);
  }

  /// Mapea AutoTutorialNodeType al NodeType de la app.
  NodeType _mapAutoNodeType(AutoTutorialNodeType type) {
    switch (type) {
      case AutoTutorialNodeType.start:
      case AutoTutorialNodeType.end:
        return NodeType.terminal;
      case AutoTutorialNodeType.process:
        return NodeType.process;
      case AutoTutorialNodeType.decision:
        return NodeType.decision;
      case AutoTutorialNodeType.dataInput:
      case AutoTutorialNodeType.dataOutput:
        return NodeType.data;
    }
  }

  /// Texto por defecto cuando el script no especifica content.
  String _defaultTextForAutoType(AutoTutorialNodeType type) {
    switch (type) {
      case AutoTutorialNodeType.start:
        return 'Inicio';
      case AutoTutorialNodeType.end:
        return 'Fin';
      case AutoTutorialNodeType.process:
        return 'Proceso';
      case AutoTutorialNodeType.decision:
        return 'Condición';
      case AutoTutorialNodeType.dataInput:
        return 'Entrada';
      case AutoTutorialNodeType.dataOutput:
        return 'Salida';
    }
  }
}
