import 'package:flutter/foundation.dart';

import '../../services/tutorial_event_service.dart';
import '../models/interactive_tutorial_models.dart';
import '../services/interactive_tutorial_catalog.dart';
import '../services/interactive_tutorial_storage_service.dart';

class InteractiveTutorialProvider extends ChangeNotifier {
  InteractiveTutorialProvider({
    InteractiveTutorialCatalog? catalog,
    InteractiveTutorialStorageService? storage,
  })  : _catalog = catalog ?? const InteractiveTutorialCatalog(),
        _storage = storage ?? InteractiveTutorialStorageService();

  final InteractiveTutorialCatalog _catalog;
  final InteractiveTutorialStorageService _storage;

  List<InteractiveTutorialDefinition> _tutorials = const [];
  InteractiveTutorialDefinition? _activeTutorial;
  InteractiveTutorialProgress? _progress;
  bool _initialized = false;

  List<InteractiveTutorialDefinition> get tutorials => _tutorials;
  InteractiveTutorialDefinition? get activeTutorial => _activeTutorial;
  InteractiveTutorialProgress? get progress => _progress;
  bool get initialized => _initialized;

  int get currentStepIndex => _progress?.currentStepIndex ?? 0;

  InteractiveTutorialStep? get currentStep {
    final tutorial = _activeTutorial;
    if (tutorial == null || tutorial.steps.isEmpty) {
      return null;
    }

    final safeIndex = currentStepIndex.clamp(0, tutorial.steps.length - 1);
    return tutorial.steps[safeIndex];
  }

  bool get isCurrentStepEventDriven {
    final step = currentStep;
    if (step == null) {
      return false;
    }

    return _expectedEventForStep(step) != null;
  }

  bool get isCurrentStepStrictControl {
    final step = currentStep;
    if (step == null) {
      return false;
    }

    return step.lockPolicy == InteractiveTutorialLockPolicy.strict;
  }

  Future<void> initialize() async {
    _tutorials = _catalog.getAllTutorials();
    TutorialEventService().clearStepGate();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> startTutorial(String tutorialId) async {
    final tutorial =
        _tutorials.where((item) => item.id == tutorialId).firstOrNull;
    if (tutorial == null) {
      return false;
    }

    _activeTutorial = tutorial;
    _progress = await _storage.loadProgress(tutorialId) ??
        InteractiveTutorialProgress(
          tutorialId: tutorial.id,
          currentStepIndex: 0,
          completed: false,
          updatedAt: DateTime.now(),
        );

    _syncStepGate();
    notifyListeners();
    return true;
  }

  Future<void> nextStep() async {
    final tutorial = _activeTutorial;
    final progress = _progress;
    if (tutorial == null || progress == null) {
      return;
    }

    final nextIndex = progress.currentStepIndex + 1;
    if (nextIndex >= tutorial.steps.length) {
      await completeTutorial();
      return;
    }

    _progress = progress.copyWith(
      currentStepIndex: nextIndex,
      updatedAt: DateTime.now(),
    );
    await _storage.saveProgress(_progress!);
    _syncStepGate();
    notifyListeners();
  }

  Future<void> previousStep() async {
    final progress = _progress;
    if (progress == null) {
      return;
    }

    final previousIndex = progress.currentStepIndex - 1;
    _progress = progress.copyWith(
      currentStepIndex: previousIndex < 0 ? 0 : previousIndex,
      updatedAt: DateTime.now(),
    );
    await _storage.saveProgress(_progress!);
    _syncStepGate();
    notifyListeners();
  }

  Future<void> completeTutorial() async {
    final progress = _progress;
    final tutorial = _activeTutorial;
    if (progress == null || tutorial == null) {
      return;
    }

    _progress = progress.copyWith(
      currentStepIndex: tutorial.steps.length - 1,
      completed: true,
      updatedAt: DateTime.now(),
    );
    await _storage.saveProgress(_progress!);
    _syncStepGate();
    notifyListeners();
  }

  Future<void> resetActiveTutorial() async {
    final tutorialId = _activeTutorial?.id;
    if (tutorialId == null) {
      return;
    }

    _progress = InteractiveTutorialProgress(
      tutorialId: tutorialId,
      currentStepIndex: 0,
      completed: false,
      updatedAt: DateTime.now(),
    );

    await _storage.saveProgress(_progress!);
    _syncStepGate();
    notifyListeners();
  }

  Future<void> closeTutorial() async {
    _activeTutorial = null;
    _progress = null;
    TutorialEventService().clearStepGate();
    notifyListeners();
  }

  Future<bool> tryAdvanceForSignal(TutorialEditorSignal signal) async {
    final step = currentStep;
    if (step == null) {
      return false;
    }

    final expectedEvent = _expectedEventForStep(step);
    if (expectedEvent == null || expectedEvent != signal.event) {
      return false;
    }

    if (step.requireTargetMatch &&
        step.targetElementId != null &&
        signal.targetElementId != step.targetElementId) {
      return false;
    }

    await nextStep();
    return true;
  }

  void _syncStepGate() {
    final step = currentStep;
    if (step == null ||
        step.lockPolicy != InteractiveTutorialLockPolicy.strict) {
      TutorialEventService().clearStepGate();
      return;
    }

    final mappedActions = <TutorialEditorAction>[];
    for (final action in step.allowedActions) {
      final mapped = _mapTutorialActionToEditorAction(action);
      if (mapped != null && !mappedActions.contains(mapped)) {
        mappedActions.add(mapped);
      }
    }

    if (mappedActions.isEmpty && step.requiredAction != null) {
      final fallback = _mapTutorialActionToEditorAction(step.requiredAction!);
      if (fallback != null) {
        mappedActions.add(fallback);
      }
    }

    TutorialEventService().configureStepGate(
      TutorialStepGate(
        strictControl: true,
        allowedActions: mappedActions,
        stepId: step.id,
        hint: _buildGateHint(step.requiredAction),
      ),
    );
  }

  String _buildGateHint(InteractiveTutorialActionType? requiredAction) {
    switch (requiredAction) {
      case InteractiveTutorialActionType.inspectNode:
        return 'Selecciona el nodo solicitado para continuar.';
      case InteractiveTutorialActionType.editNode:
        return 'Edita el nodo indicado para continuar.';
      case InteractiveTutorialActionType.connectNodes:
        return 'Realiza la conexion solicitada para continuar.';
      case InteractiveTutorialActionType.runValidation:
        return 'Ejecuta la validacion del diagrama para continuar.';
      case InteractiveTutorialActionType.viewGeneratedCode:
        return 'Genera la salida C para continuar.';
      case InteractiveTutorialActionType.saveDiagram:
        return 'Guarda el diagrama para continuar.';
      case InteractiveTutorialActionType.openTemplate:
      case null:
        return 'Completa la accion requerida del paso actual.';
    }
  }

  TutorialEditorAction? _mapTutorialActionToEditorAction(
    InteractiveTutorialActionType action,
  ) {
    switch (action) {
      case InteractiveTutorialActionType.inspectNode:
        return TutorialEditorAction.inspectNode;
      case InteractiveTutorialActionType.editNode:
        return TutorialEditorAction.editNode;
      case InteractiveTutorialActionType.connectNodes:
        return TutorialEditorAction.connectNodes;
      case InteractiveTutorialActionType.runValidation:
        return TutorialEditorAction.runValidation;
      case InteractiveTutorialActionType.viewGeneratedCode:
        return TutorialEditorAction.viewGeneratedCode;
      case InteractiveTutorialActionType.saveDiagram:
        return TutorialEditorAction.saveDiagram;
      case InteractiveTutorialActionType.openTemplate:
        return null;
    }
  }

  TutorialEditorEvent? _expectedEventForStep(InteractiveTutorialStep step) {
    if (step.requiredAction == InteractiveTutorialActionType.inspectNode) {
      return _mapTargetElementToInspectEvent(step.targetElementId);
    }

    return _mapActionToEvent(step.requiredAction);
  }

  TutorialEditorEvent? _mapTargetElementToInspectEvent(
      String? targetElementId) {
    switch (targetElementId) {
      case 'node_start':
        return TutorialEditorEvent.nodeStartSelected;
      case 'node_end':
        return TutorialEditorEvent.nodeEndSelected;
      default:
        return null;
    }
  }

  TutorialEditorEvent? _mapActionToEvent(
    InteractiveTutorialActionType? action,
  ) {
    switch (action) {
      case InteractiveTutorialActionType.editNode:
        return TutorialEditorEvent.nodeEdited;
      case InteractiveTutorialActionType.connectNodes:
        return TutorialEditorEvent.nodesConnected;
      case InteractiveTutorialActionType.runValidation:
        return TutorialEditorEvent.diagramValidated;
      case InteractiveTutorialActionType.viewGeneratedCode:
        return TutorialEditorEvent.codeGenerated;
      case InteractiveTutorialActionType.saveDiagram:
        return TutorialEditorEvent.diagramSaved;
      case InteractiveTutorialActionType.openTemplate:
      case InteractiveTutorialActionType.inspectNode:
      case null:
        return null;
    }
  }
}
