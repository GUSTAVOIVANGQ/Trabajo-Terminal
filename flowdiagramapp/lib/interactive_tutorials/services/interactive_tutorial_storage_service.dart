import 'package:shared_preferences/shared_preferences.dart';

import '../models/interactive_tutorial_models.dart';

class InteractiveTutorialStorageService {
  static const String _progressPrefix = 'interactive_tutorial_progress_';

  String _progressKey(String tutorialId) {
    return '$_progressPrefix$tutorialId';
  }

  Future<InteractiveTutorialProgress?> loadProgress(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_progressKey(tutorialId));
    if (raw == null || raw.length < 4) {
      return null;
    }

    final map = <String, String>{};
    for (final entry in raw) {
      final separatorIndex = entry.indexOf('=');
      if (separatorIndex <= 0 || separatorIndex >= entry.length - 1) {
        continue;
      }
      final key = entry.substring(0, separatorIndex);
      final value = entry.substring(separatorIndex + 1);
      map[key] = value;
    }

    if (map.isEmpty) {
      return null;
    }

    return InteractiveTutorialProgress.fromStorageMap(map);
  }

  Future<void> saveProgress(InteractiveTutorialProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final storageValues = progress.toStorageMap();
    final encoded = storageValues.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .toList(growable: false);

    await prefs.setStringList(_progressKey(progress.tutorialId), encoded);
  }

  Future<void> clearProgress(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey(tutorialId));
  }

  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_progressPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
