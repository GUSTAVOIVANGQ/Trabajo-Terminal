// auto_tutorial_models.dart
// Modelos para el sistema de tutorial automático con spotlight (tutorial_coach_mark).
// Reemplaza el modelo interactivo-manual por un flujo autoplay observable.

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Tipos de acción automática que el controlador ejecuta en el editor
// ---------------------------------------------------------------------------

enum AutoTutorialAutoAction {
  /// No ejecuta ninguna acción; solo muestra el spotlight con texto.
  none,

  /// Agrega un nodo al canvas en la posición indicada.
  addNode,

  /// Conecta dos nodos ya existentes en el canvas.
  connectNodes,

  /// Abre el diálogo de propiedades de un nodo y escribe contenido.
  editNodeContent,

  /// Ejecuta la validación estructural del diagrama.
  runValidation,

  /// Abre el visor de código C generado.
  viewGeneratedCode,

  /// Guarda el diagrama en SQLite local.
  saveDiagram,
}

// ---------------------------------------------------------------------------
// Nodo visual que el tutorial puede agregar automáticamente
// ---------------------------------------------------------------------------

enum AutoTutorialNodeType {
  start,
  end,
  process,
  decision,
  dataInput,
  dataOutput,
}

// ---------------------------------------------------------------------------
// Descripción de un paso del tutorial
// ---------------------------------------------------------------------------

/// Un paso combina:
/// - Un spotlight circular sobre un área del canvas o un widget clave de la UI.
/// - Una acción automática que el controlador ejecuta al mostrar el paso.
/// - Texto breve (≤ 2 líneas) que aparece en el tooltip del coach mark.
@immutable
class AutoTutorialStep {
  const AutoTutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.spotlightTarget,
    this.autoAction = AutoTutorialAutoAction.none,
    this.autoActionDelayMs = 600,
    this.nodeType,
    this.nodeId,
    this.nodeContent,
    this.nodePosition,
    this.sourceNodeId,
    this.targetNodeId,
    this.spotlightRadius = 72.0,
    this.tooltipPosition = AutoTooltipPosition.bottom,
    this.targetFractionX = 0.5,
    this.targetFractionY = 0.38,
  });

  /// Identificador único del paso (para logging y persistencia).
  final String id;

  /// Título corto mostrado en el tooltip (≤ 4 palabras).
  final String title;

  /// Descripción breve (≤ 2 líneas) mostrada bajo el título.
  final String description;

  /// GlobalKey del widget sobre el que se centra el spotlight.
  /// Si es null, el spotlight se centra en [nodePosition].
  final GlobalKey? spotlightTarget;

  /// Acción automática que el controlador ejecuta después de [autoActionDelayMs].
  final AutoTutorialAutoAction autoAction;

  /// Milisegundos de espera antes de ejecutar [autoAction].
  final int autoActionDelayMs;

  // Parámetros para addNode
  final AutoTutorialNodeType? nodeType;
  final String? nodeId;
  final String? nodeContent;
  final Offset? nodePosition;

  // Parámetros para connectNodes
  final String? sourceNodeId;
  final String? targetNodeId;

  /// Radio del spotlight circular en píxeles lógicos.
  final double spotlightRadius;

  /// Posición del tooltip respecto al spotlight.
  final AutoTooltipPosition tooltipPosition;

  /// Fracción X de pantalla (0.0=izq, 1.0=der) para centrar el spotlight
  /// cuando [spotlightTarget] es null. Default 0.5 (centro horizontal).
  final double targetFractionX;

  /// Fracción Y de pantalla (0.0=arriba, 1.0=abajo) para centrar el spotlight
  /// cuando [spotlightTarget] es null. Default 0.38 (un poco arriba del centro).
  final double targetFractionY;
}

enum AutoTooltipPosition { top, bottom, left, right }

// ---------------------------------------------------------------------------
// Definición completa de un tutorial
// ---------------------------------------------------------------------------

@immutable
class AutoTutorialDefinition {
  const AutoTutorialDefinition({
    required this.id,
    required this.title,
    required this.summary,
    required this.templateName,
    required this.level,
    required this.estimatedSeconds,
    required this.steps,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String summary;

  /// Nombre de la plantilla que se carga al inicio del tutorial.
  final String templateName;

  final AutoTutorialLevel level;

  /// Duración estimada en segundos (para mostrar en la tarjeta del catálogo).
  final int estimatedSeconds;

  final List<AutoTutorialStep> steps;
  final bool enabled;
}

enum AutoTutorialLevel { basic, intermediate, advanced }

extension AutoTutorialLevelUi on AutoTutorialLevel {
  String get label {
    switch (this) {
      case AutoTutorialLevel.basic:
        return 'Básico';
      case AutoTutorialLevel.intermediate:
        return 'Intermedio';
      case AutoTutorialLevel.advanced:
        return 'Avanzado';
    }
  }

  Color get color {
    switch (this) {
      case AutoTutorialLevel.basic:
        return const Color(0xFF4CAF50);
      case AutoTutorialLevel.intermediate:
        return const Color(0xFFFF9800);
      case AutoTutorialLevel.advanced:
        return const Color(0xFFE53935);
    }
  }

  IconData get icon {
    switch (this) {
      case AutoTutorialLevel.basic:
        return Icons.stars_outlined;
      case AutoTutorialLevel.intermediate:
        return Icons.auto_awesome;
      case AutoTutorialLevel.advanced:
        return Icons.rocket_launch_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Estado de reproducción del tutorial
// ---------------------------------------------------------------------------

enum AutoTutorialPlayState { idle, playing, paused, completed }

@immutable
class AutoTutorialState {
  const AutoTutorialState({
    this.activeTutorial,
    this.currentStepIndex = 0,
    this.playState = AutoTutorialPlayState.idle,
  });

  final AutoTutorialDefinition? activeTutorial;
  final int currentStepIndex;
  final AutoTutorialPlayState playState;

  bool get isActive => activeTutorial != null;
  bool get isPlaying => playState == AutoTutorialPlayState.playing;
  bool get isPaused => playState == AutoTutorialPlayState.paused;
  bool get isCompleted => playState == AutoTutorialPlayState.completed;

  int get totalSteps => activeTutorial?.steps.length ?? 0;

  AutoTutorialStep? get currentStep {
    final t = activeTutorial;
    if (t == null || t.steps.isEmpty) return null;
    final i = currentStepIndex.clamp(0, t.steps.length - 1);
    return t.steps[i];
  }

  AutoTutorialState copyWith({
    AutoTutorialDefinition? activeTutorial,
    int? currentStepIndex,
    AutoTutorialPlayState? playState,
  }) {
    return AutoTutorialState(
      activeTutorial: activeTutorial ?? this.activeTutorial,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      playState: playState ?? this.playState,
    );
  }
}
