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

  Future<void> initialize() async {
    _tutorials = _catalog.getAllTutorials();
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
    notifyListeners();
  }

  Future<void> closeTutorial() async {
    _activeTutorial = null;
    _progress = null;
    notifyListeners();
  }

  Future<bool> tryAdvanceForEvent(TutorialEditorEvent event) async {
    final step = currentStep;
    if (step == null) {
      return false;
    }

    final expectedEvent = _expectedEventForStep(step);
    if (expectedEvent == null || expectedEvent != event) {
      return false;
    }

    await nextStep();
    return true;
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
      case InteractiveTutorialActionType.runValidation:
        return TutorialEditorEvent.diagramValidated;
      case InteractiveTutorialActionType.viewGeneratedCode:
        return TutorialEditorEvent.codeGenerated;
      case InteractiveTutorialActionType.saveDiagram:
        return TutorialEditorEvent.diagramSaved;
      case InteractiveTutorialActionType.openTemplate:
      case InteractiveTutorialActionType.inspectNode:
      case InteractiveTutorialActionType.connectNodes:
      case null:
        return null;
    }
  }
}
