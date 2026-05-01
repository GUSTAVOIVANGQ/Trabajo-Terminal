import 'dart:ui';

import 'tutorial_event_service.dart';

class TutorialSpotlightService {
  TutorialSpotlightService._internal();

  static final TutorialSpotlightService _instance =
      TutorialSpotlightService._internal();

  factory TutorialSpotlightService() {
    return _instance;
  }

  final Map<TutorialEditorAction, Rect> _rects = {};

  Rect? rectForAction(TutorialEditorAction action) {
    return _rects[action];
  }

  void registerActionRect(TutorialEditorAction action, Rect rect) {
    _rects[action] = rect;
  }

  void clear() {
    _rects.clear();
  }
}
