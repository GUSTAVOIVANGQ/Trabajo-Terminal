import 'dart:async';

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

class TutorialEventService {
  TutorialEventService._internal();

  static final TutorialEventService _instance =
      TutorialEventService._internal();

  factory TutorialEventService() {
    return _instance;
  }

  final StreamController<TutorialEditorEvent> _controller =
      StreamController<TutorialEditorEvent>.broadcast();

  Stream<TutorialEditorEvent> get events => _controller.stream;

  void emit(TutorialEditorEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
