import 'package:shared_preferences/shared_preferences.dart';

class AutoSaveSettingsService {
  static final AutoSaveSettingsService _instance =
      AutoSaveSettingsService._internal();
  factory AutoSaveSettingsService() => _instance;
  AutoSaveSettingsService._internal();

  static const String _baseKey = 'editor_auto_save_enabled';

  String _buildKey(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _baseKey;
    }
    return '${_baseKey}_$userId';
  }

  Future<bool> isAutoSaveEnabled({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_buildKey(userId)) ?? false;
  }

  Future<void> setAutoSaveEnabled(
    bool enabled, {
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_buildKey(userId), enabled);
  }
}
