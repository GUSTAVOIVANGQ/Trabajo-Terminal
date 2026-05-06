// auto_tutorial_script.dart
// Scripts de cada tutorial autoplay con GlobalKeys del editor.
import 'package:flutter/material.dart';
import 'auto_tutorial_models.dart';

// ---------------------------------------------------------------------------
// GlobalKeys del editor — asignados en EditorScreen
// ---------------------------------------------------------------------------

class EditorTutorialKeys {
  EditorTutorialKeys._();

  /// Área principal del canvas.
  static final canvas = GlobalKey(debugLabel: 'tutorial_canvas');

  /// Botón de compilar / ver código C (también usado para validación).
  static final compileButton = GlobalKey(debugLabel: 'tutorial_compileButton');

  /// Vista del código C generado.
  static final codeView = GlobalKey(debugLabel: 'tutorial_codeView');

  /// Botón de guardar diagrama.
  static final saveButton = GlobalKey(debugLabel: 'tutorial_saveButton');

  /// Nodo Inicio creado en el canvas.
  static final nodeStart = GlobalKey(debugLabel: 'tutorial_nodeStart');

  /// Nodo Fin creado en el canvas.
  static final nodeEnd = GlobalKey(debugLabel: 'tutorial_nodeEnd');

  /// Nodo de proceso/salida de datos.
  static final nodeOutput = GlobalKey(debugLabel: 'tutorial_nodeOutput');

  /// Nodo de decisión.
  static final nodeDecision = GlobalKey(debugLabel: 'tutorial_nodeDecision');

  /// Nodo de proceso genérico.
  static final nodeProcess = GlobalKey(debugLabel: 'tutorial_nodeProcess');

  /// Panel lateral de símbolos (NodePalette completo).
  static final sidePanel = GlobalKey(debugLabel: 'tutorial_sidePanel');

  /// Botón Terminal en la paleta lateral (Inicio / Fin).
  static final terminalButton = GlobalKey(debugLabel: 'tutorial_terminalButton');

  /// Botón Data en la paleta lateral (paralelogramo E/S).
  static final dataButton = GlobalKey(debugLabel: 'tutorial_dataButton');

  /// Botón Process en la paleta lateral.
  static final processButton = GlobalKey(debugLabel: 'tutorial_processButton');

  /// Botón Decision en la paleta lateral.
  static final decisionButton = GlobalKey(debugLabel: 'tutorial_decisionButton');

  /// Área de la AppBar (barra de herramientas superior).
  static final appBarArea = GlobalKey(debugLabel: 'tutorial_appBarArea');

  /// Botón Deshacer en la AppBar.
  static final undoButton = GlobalKey(debugLabel: 'tutorial_undoButton');

  /// Botón Rehacer en la AppBar.
  static final redoButton = GlobalKey(debugLabel: 'tutorial_redoButton');

  /// Botón Cargar diagrama en la AppBar.
  static final loadButton = GlobalKey(debugLabel: 'tutorial_loadButton');

  /// Botón Exportar diagrama en la AppBar.
  static final exportButton = GlobalKey(debugLabel: 'tutorial_exportButton');
}

// ---------------------------------------------------------------------------
// Catálogo de tutoriales
// ---------------------------------------------------------------------------

class AutoTutorialScripts {
  AutoTutorialScripts._();

  static List<AutoTutorialDefinition> all() => [
        _holaMundo(),
        _parOImpar(),
        _burbuja(),
      ];

  // ── Tutorial 1: Hola Mundo (Básico, ~60 s) ─────────────────────────────

  static AutoTutorialDefinition _holaMundo() {
    return AutoTutorialDefinition(
      id: 'auto_01_hola_mundo',
      title: 'Hola Mundo',
      summary: 'Crea tu primer diagrama y genera código C en 60 segundos.',
      templateName: '01. Hola Mundo',
      level: AutoTutorialLevel.basic,
      estimatedSeconds: 60,
      steps: [
        // ── 1. Bienvenida ─────────────────────────────────────────────────
        const AutoTutorialStep(
          id: 'welcome',
          title: '¡Bienvenido a FlowCode!',
          description:
              'Observa cómo se construye un diagrama de flujo paso a paso y se traduce automáticamente a código C.',
          spotlightTarget: null,
          spotlightRadius: 140,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          tooltipPosition: AutoTooltipPosition.bottom,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
        ),

        // ── 2. Panel lateral ──────────────────────────────────────────────
        const AutoTutorialStep(
          id: 'intro_panel',
          title: 'Panel de símbolos ISO 5807',
          description:
              'Este panel contiene las figuras del estándar ISO 5807. Los de la categoría "Basic" generan código C automáticamente.',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.27,
          targetFractionY: 0.5,
          tooltipPosition: AutoTooltipPosition.right,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
        ),

        // ── 3. Barra de herramientas ──────────────────────────────────────
        AutoTutorialStep(
          id: 'intro_toolbar',
          title: 'Barra de herramientas',
          description:
              'Botones de guardar 💾, compilar </> y exportar. El compilador traduce el diagrama a código C funcional.',
          spotlightTarget: EditorTutorialKeys.compileButton,
          spotlightRadius: 52,
          tooltipPosition: AutoTooltipPosition.bottom,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
        ),

        // ── 4. Área de trabajo ────────────────────────────────────────────
        const AutoTutorialStep(
          id: 'intro_canvas',
          title: 'Área de trabajo',
          description:
              'Aquí colocas los nodos. Haz zoom con los botones flotantes y desplázate arrastrando el fondo del canvas.',
          spotlightTarget: null,
          spotlightRadius: 140,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          tooltipPosition: AutoTooltipPosition.bottom,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
        ),

        // ── 5. Resaltar botón Terminal ────────────────────────────────────
        AutoTutorialStep(
          id: 'highlight_terminal_start',
          title: 'Símbolo Terminal',
          description:
              'El óvalo Terminal representa Inicio y Fin del algoritmo. ¡Observa cómo se agrega automáticamente al canvas!',
          spotlightTarget: EditorTutorialKeys.terminalButton,
          spotlightRadius: 44,
          tooltipPosition: AutoTooltipPosition.right,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 1200,
        ),

        // ── 6. Crear nodo Inicio ──────────────────────────────────────────
        const AutoTutorialStep(
          id: 'add_start',
          title: 'Nodo Inicio creado',
          description:
              'El nodo Terminal "Inicio" aparece en el canvas. En C genera la función main() con sus llaves de apertura.',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 500,
          nodeType: AutoTutorialNodeType.start,
          nodeId: 'tut_start',
          nodePosition: Offset(180, 120),
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 7. Resaltar botón Data ────────────────────────────────────────
        AutoTutorialStep(
          id: 'highlight_data',
          title: 'Símbolo Data (E/S)',
          description:
              'El paralelogramo Data representa entrada/salida. En C genera printf() para salida o scanf() para entrada.',
          spotlightTarget: EditorTutorialKeys.dataButton,
          spotlightRadius: 44,
          tooltipPosition: AutoTooltipPosition.right,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 1200,
        ),

        // ── 8. Crear nodo Salida ──────────────────────────────────────────
        const AutoTutorialStep(
          id: 'add_output',
          title: 'Nodo de Salida creado',
          description:
              'Se agrega un nodo Data con printf("Hola Mundo\\n"). Este será el mensaje que imprimirá el programa en C.',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 500,
          nodeType: AutoTutorialNodeType.dataOutput,
          nodeId: 'tut_output',
          nodeContent: 'printf("Hola Mundo\\n")',
          nodePosition: Offset(180, 270),
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 9. Resaltar botón Terminal (Fin) ──────────────────────────────
        AutoTutorialStep(
          id: 'highlight_terminal_end',
          title: 'Terminal también es Fin',
          description:
              'El mismo símbolo Terminal cierra el algoritmo. En C genera return 0; indicando que el programa terminó correctamente.',
          spotlightTarget: EditorTutorialKeys.terminalButton,
          spotlightRadius: 44,
          tooltipPosition: AutoTooltipPosition.right,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 1200,
        ),

        // ── 10. Crear nodo Fin ────────────────────────────────────────────
        const AutoTutorialStep(
          id: 'add_end',
          title: 'Nodo Fin creado',
          description:
              'El nodo Fin cierra el flujo. En C genera la llave de cierre de main() y return 0;',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 500,
          nodeType: AutoTutorialNodeType.end,
          nodeId: 'tut_end',
          nodePosition: Offset(180, 420),
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 11. Explicar conexiones ───────────────────────────────────────
        const AutoTutorialStep(
          id: 'intro_connections',
          title: 'Conectando los nodos',
          description:
              'Las flechas definen el orden de ejecución. Sin conexiones el compilador no puede generar código.',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          tooltipPosition: AutoTooltipPosition.bottom,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
        ),

        // ── 12. Conectar Inicio → Salida ──────────────────────────────────
        const AutoTutorialStep(
          id: 'connect_start_output',
          title: 'Inicio → Salida',
          description:
              'La flecha conecta el Inicio con printf. Después de iniciar, el programa ejecuta la salida de datos.',
          spotlightTarget: null,
          spotlightRadius: 120,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 600,
          sourceNodeId: 'tut_start',
          targetNodeId: 'tut_output',
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 13. Conectar Salida → Fin ─────────────────────────────────────
        const AutoTutorialStep(
          id: 'connect_output_end',
          title: 'Salida → Fin',
          description:
              'La segunda flecha cierra el flujo. Todo nodo del diagrama debe tener un camino hacia el nodo Fin.',
          spotlightTarget: null,
          spotlightRadius: 120,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 600,
          sourceNodeId: 'tut_output',
          targetNodeId: 'tut_end',
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 14. Guardar ───────────────────────────────────────────────────
        AutoTutorialStep(
          id: 'save',
          title: 'Guardar el diagrama 💾',
          description:
              'Pulsa el ícono de guardar para persistir el diagrama en SQLite. Puedes cargarlo después desde el botón de carpeta.',
          spotlightTarget: EditorTutorialKeys.saveButton,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 15. Deshacer ──────────────────────────────────────────────────
        AutoTutorialStep(
          id: 'undo',
          title: 'Deshacer acción',
          description:
              'Si te equivocas, puedes deshacer el último cambio con este botón o usando Ctrl+Z.',
          spotlightTarget: EditorTutorialKeys.undoButton,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 16. Rehacer ───────────────────────────────────────────────────
        AutoTutorialStep(
          id: 'redo',
          title: 'Rehacer acción',
          description:
              'Recupera una acción deshecha con este botón o usando Ctrl+Y.',
          spotlightTarget: EditorTutorialKeys.redoButton,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 17. Cargar diagrama ───────────────────────────────────────────
        AutoTutorialStep(
          id: 'load',
          title: 'Cargar diagrama 📂',
          description:
              'Abre la lista de diagramas guardados en la base de datos para continuar editándolos.',
          spotlightTarget: EditorTutorialKeys.loadButton,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 18. Exportar diagrama ─────────────────────────────────────────
        AutoTutorialStep(
          id: 'export',
          title: 'Exportar ⬇️',
          description:
              'Puedes descargar tu diagrama como imagen PNG, JPG, documento PDF o incluso como archivo de código C.',
          spotlightTarget: EditorTutorialKeys.exportButton,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 19. ¿Cómo funciona el compilador? ─────────────────────────────
        AutoTutorialStep(
          id: 'highlight_compile',
          title: '¿Cómo funciona el compilador?',
          description:
              '5 fases: Análisis léxico → Sintáctico → Semántico → Representación intermedia → Generación de código C.',
          spotlightTarget: EditorTutorialKeys.compileButton,
          spotlightRadius: 52,
          tooltipPosition: AutoTooltipPosition.bottom,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 1500,
        ),

        // ── 16. Compilar ──────────────────────────────────────────────────
        AutoTutorialStep(
          id: 'compile',
          title: 'Generando código C',
          description:
              '¡El compilador ejecuta ahora! Traduce el diagrama completo a un programa C funcional.',
          spotlightTarget: EditorTutorialKeys.compileButton,
          autoAction: AutoTutorialAutoAction.viewGeneratedCode,
          autoActionDelayMs: 700,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),

        // ── 17. Completado ────────────────────────────────────────────────
        const AutoTutorialStep(
          id: 'complete',
          title: '¡Tutorial completado! 🎉',
          description:
              'Has creado tu primer diagrama funcional. Prueba con los tutoriales "Par o Impar" y "Ordenamiento Burbuja".',
          spotlightTarget: null,
          spotlightRadius: 130,
          targetFractionX: 0.5,
          targetFractionY: 0.5,
          autoAction: AutoTutorialAutoAction.none,
          autoActionDelayMs: 800,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
      ],
    );
  }

  // ── Tutorial 2: Par o Impar (Intermedio, ~65 s) ─────────────────────────

  static AutoTutorialDefinition _parOImpar() {
    return AutoTutorialDefinition(
      id: 'auto_02_par_impar',
      title: 'Par o Impar',
      summary: 'Agrega una decisión y genera if/else en código C.',
      templateName: '05. Par o Impar',
      level: AutoTutorialLevel.intermediate,
      estimatedSeconds: 65,
      steps: [
        AutoTutorialStep(
          id: 'welcome',
          title: 'Decisiones',
          description: 'Aprende a representar if/else con el nodo Decisión.',
          spotlightTarget: EditorTutorialKeys.canvas,
          spotlightRadius: 160,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_start',
          title: 'Nodo Inicio',
          description: 'Punto de entrada del algoritmo.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.start,
          nodeId: 'pi_start',
          nodePosition: Offset(180, 80),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_input',
          title: 'Entrada de datos',
          description: 'El nodo Dato genera scanf() para leer un entero.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.dataInput,
          nodeId: 'pi_input',
          nodeContent: 'scanf("%d", &n)',
          nodePosition: Offset(180, 200),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_decision',
          title: 'Nodo Decisión',
          description: 'El rombo genera if (n % 2 == 0) en código C.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.decision,
          nodeId: 'pi_decision',
          nodeContent: 'n % 2 == 0',
          nodePosition: Offset(180, 340),
          spotlightRadius: 80,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_output_par',
          title: 'Rama verdadera',
          description: 'Nodo de salida si n es par.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.dataOutput,
          nodeId: 'pi_out_par',
          nodeContent: 'printf("Es par")',
          nodePosition: Offset(60, 480),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_output_impar',
          title: 'Rama falsa',
          description: 'Nodo de salida si n es impar.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.dataOutput,
          nodeId: 'pi_out_impar',
          nodeContent: 'printf("Es impar")',
          nodePosition: Offset(300, 480),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_end',
          title: 'Nodo Fin',
          description: 'Ambas ramas convergen hacia el Fin.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.end,
          nodeId: 'pi_end',
          nodePosition: Offset(180, 610),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_1',
          title: 'Conectando nodos',
          description: 'Inicio → Entrada de datos.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_start',
          targetNodeId: 'pi_input',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_2',
          title: 'Conectando nodos',
          description: 'Entrada → Decisión.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_input',
          targetNodeId: 'pi_decision',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_3',
          title: 'Rama verdadera',
          description: 'Decisión (Sí) → Es par.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_decision',
          targetNodeId: 'pi_out_par',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_4',
          title: 'Rama falsa',
          description: 'Decisión (No) → Es impar.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_decision',
          targetNodeId: 'pi_out_impar',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_5',
          title: 'Convergencia',
          description: 'Ambas ramas llegan al Fin.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_out_par',
          targetNodeId: 'pi_end',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_6',
          title: 'Convergencia',
          description: 'Rama impar también llega al Fin.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 700,
          sourceNodeId: 'pi_out_impar',
          targetNodeId: 'pi_end',
          spotlightRadius: 100,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        AutoTutorialStep(
          id: 'compile',
          title: 'Código C con if/else',
          description: 'Observa cómo se genera el if/else automáticamente.',
          spotlightTarget: EditorTutorialKeys.compileButton,
          autoAction: AutoTutorialAutoAction.viewGeneratedCode,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'complete',
          title: '¡Listo!',
          description: 'Ahora puedes crear diagramas con decisiones en C.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.none,
          spotlightRadius: 160,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
      ],
    );
  }

  // ── Tutorial 3: Ordenamiento Burbuja (Avanzado, ~90 s) ───────────────────────

  static AutoTutorialDefinition _burbuja() {
    return AutoTutorialDefinition(
      id: 'auto_03_burbuja',
      title: 'Ordenamiento Burbuja',
      summary: 'Construye un flujo iterativo y genera el bucle while en C.',
      templateName: '15. Ordenamiento Burbuja',
      level: AutoTutorialLevel.advanced,
      estimatedSeconds: 90,
      steps: [
        AutoTutorialStep(
          id: 'welcome',
          title: 'Bucles',
          description: 'Los bucles se representan con flechas de retorno.',
          spotlightTarget: EditorTutorialKeys.canvas,
          spotlightRadius: 160,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_start',
          title: 'Nodo Inicio',
          description: 'Inicia el algoritmo de ordenamiento.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.start,
          nodeId: 'bb_start',
          nodePosition: Offset(200, 60),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_init',
          title: 'Inicialización',
          description: 'El nodo Proceso inicializa el contador i = 0.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.process,
          nodeId: 'bb_init',
          nodeContent: 'i = 0',
          nodePosition: Offset(200, 180),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'add_condition',
          title: 'Condición del bucle',
          description: 'El rombo genera while (i < n-1) en código C.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.decision,
          nodeId: 'bb_cond',
          nodeContent: 'i < n - 1',
          nodePosition: Offset(200, 310),
          spotlightRadius: 80,
          tooltipPosition: AutoTooltipPosition.right,
        ),
        const AutoTutorialStep(
          id: 'add_swap',
          title: 'Intercambio',
          description: 'Nodo Proceso para el intercambio de elementos.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.process,
          nodeId: 'bb_swap',
          nodeContent: 'temp = a[j]; a[j] = a[j+1]; a[j+1] = temp',
          nodePosition: Offset(200, 450),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.right,
        ),
        const AutoTutorialStep(
          id: 'add_increment',
          title: 'Incremento',
          description: 'El contador debe actualizarse dentro del bucle.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.process,
          nodeId: 'bb_inc',
          nodeContent: 'i = i + 1',
          nodePosition: Offset(200, 570),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.right,
        ),
        const AutoTutorialStep(
          id: 'add_end',
          title: 'Nodo Fin',
          description: 'La rama falsa de la condición termina el flujo.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.addNode,
          autoActionDelayMs: 600,
          nodeType: AutoTutorialNodeType.end,
          nodeId: 'bb_end',
          nodePosition: Offset(380, 310),
          spotlightRadius: 72,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'connect_loop',
          title: 'Flecha de retorno',
          description: 'La flecha de retorno crea el bucle while.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.connectNodes,
          autoActionDelayMs: 800,
          sourceNodeId: 'bb_inc',
          targetNodeId: 'bb_cond',
          spotlightRadius: 120,
          tooltipPosition: AutoTooltipPosition.right,
        ),
        AutoTutorialStep(
          id: 'compile',
          title: 'Código C con while',
          description: 'El bucle while se genera con indentación correcta.',
          spotlightTarget: EditorTutorialKeys.compileButton,
          autoAction: AutoTutorialAutoAction.viewGeneratedCode,
          autoActionDelayMs: 800,
          spotlightRadius: 48,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
        const AutoTutorialStep(
          id: 'complete',
          title: '¡Avanzado completado!',
          description: 'Dominas flujos iterativos con FlowCode.',
          spotlightTarget: null,
          autoAction: AutoTutorialAutoAction.none,
          spotlightRadius: 160,
          tooltipPosition: AutoTooltipPosition.bottom,
        ),
      ],
    );
  }
}
