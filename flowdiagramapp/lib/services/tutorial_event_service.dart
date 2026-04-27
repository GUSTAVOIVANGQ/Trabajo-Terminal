import 'dart:async';

enum TutorialEditorAction {
  inspectNode,
  editNode,
  deleteNode,
  connectNodes,
  runValidation,
  viewGeneratedCode,
  saveDiagram,
  addNode,
  addConcept,
}

enum TutorialEditorEvent {
  nodeCreated,
  nodeEdited,
  nodesConnected,
  nodeStartSelected,
  nodeEndSelected,
  diagramValidated,
  codeGenerated,
  diagramSaved,
}

class TutorialEditorSignal {
  final TutorialEditorEvent event;
  final String? targetElementId;

  const TutorialEditorSignal({
    required this.event,
    this.targetElementId,
  });
}

class TutorialStepGate {
  final bool strictControl;
  final List<TutorialEditorAction> allowedActions;
  final String? stepId;
  final String? hint;

  const TutorialStepGate({
    required this.strictControl,
    this.allowedActions = const [],
    this.stepId,
    this.hint,
  });

  const TutorialStepGate.none()
      : strictControl = false,
        allowedActions = const [],
        stepId = null,
        hint = null;
}

class TutorialEventService {
  TutorialEventService._internal();

  static final TutorialEventService _instance =
      TutorialEventService._internal();

  factory TutorialEventService() {
    return _instance;
  }

  final StreamController<TutorialEditorSignal> _controller =
      StreamController<TutorialEditorSignal>.broadcast();
  TutorialStepGate _activeGate = const TutorialStepGate.none();

  Stream<TutorialEditorSignal> get events => _controller.stream;
  TutorialStepGate get activeGate => _activeGate;

  void configureStepGate(TutorialStepGate gate) {
    _activeGate = gate;
  }

  void clearStepGate() {
    _activeGate = const TutorialStepGate.none();
  }

  bool isActionAllowed(TutorialEditorAction action) {
    if (!_activeGate.strictControl) {
      return true;
    }

    return _activeGate.allowedActions.contains(action);
  }

  void emit(
    TutorialEditorEvent event, {
    String? targetElementId,
  }) {
    if (!_controller.isClosed) {
      _controller.add(
        TutorialEditorSignal(
          event: event,
          targetElementId: targetElementId,
        ),
      );
    }
  }

  void dispose() {
    _controller.close();
  }
}
