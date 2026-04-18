import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _initialized = false;
  bool _collectionEnabled = false;

  bool get isCollectionEnabled => _collectionEnabled;

  List<NavigatorObserver> get navigatorObservers {
    final observer = _observer;
    if (observer == null) {
      return const [];
    }
    return <NavigatorObserver>[observer];
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      // Start disabled and wait for explicit consent.
      await _analytics!.setAnalyticsCollectionEnabled(false);
      await _analytics!.setUserId(id: null);
      _collectionEnabled = false;
    } catch (e) {
      debugPrint('AnalyticsService.initialize error: $e');
      _analytics = null;
      _observer = null;
      _collectionEnabled = false;
    }
  }

  Future<void> configureCollection({
    required bool telemetryOptIn,
    required bool isGuest,
  }) async {
    await initialize();
    if (_analytics == null) return;

    final shouldEnable = telemetryOptIn && !isGuest;

    try {
      await _analytics!.setAnalyticsCollectionEnabled(shouldEnable);
      _collectionEnabled = shouldEnable;

      // Keep telemetry anonymous to simplify privacy and retention handling.
      await _analytics!.setUserId(id: null);
      await _analytics!.setUserProperty(
        name: 'telemetry_opt_in',
        value: telemetryOptIn ? 'true' : 'false',
      );
      await _analytics!.setUserProperty(
        name: 'auth_mode',
        value: isGuest ? 'guest' : 'registered',
      );
    } catch (e) {
      debugPrint('AnalyticsService.configureCollection error: $e');
    }
  }

  Future<void> disableCollection() async {
    await initialize();
    if (_analytics == null) return;

    try {
      await _analytics!.setAnalyticsCollectionEnabled(false);
      await _analytics!.setUserId(id: null);
      _collectionEnabled = false;
    } catch (e) {
      debugPrint('AnalyticsService.disableCollection error: $e');
    }
  }

  Future<void> logUserAction({
    required String action,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_collectionEnabled || _analytics == null) return;

    try {
      final parameters = <String, Object?>{
        'action': _safeString(action),
        'category': _safeString(category),
      };

      if (metadata != null && metadata.isNotEmpty) {
        parameters.addAll(_sanitizeParameters(metadata));
      }

      await _analytics!.logEvent(
        name: 'fc_user_action',
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('AnalyticsService.logUserAction error: $e');
    }
  }

  Future<void> logEducationalMetric({
    required bool successful,
    required int errorsFound,
    required int hintsUsed,
    required int timeSpentSeconds,
  }) async {
    if (!_collectionEnabled || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'fc_exercise_result',
        parameters: <String, Object?>{
          'successful': successful ? 1 : 0,
          'errors_found': errorsFound,
          'hints_used': hintsUsed,
          'time_spent_sec': timeSpentSeconds,
        },
      );
    } catch (e) {
      debugPrint('AnalyticsService.logEducationalMetric error: $e');
    }
  }

  Map<String, Object?> _sanitizeParameters(Map<String, dynamic> metadata) {
    final sanitized = <String, Object?>{};
    for (final entry in metadata.entries) {
      if (sanitized.length >= 20) break;

      final key = _normalizeParameterName(entry.key);
      if (key.isEmpty) continue;

      final value = entry.value;
      if (value is int || value is double || value is String) {
        sanitized[key] = value is String ? _safeString(value) : value;
      } else if (value is bool) {
        sanitized[key] = value ? 1 : 0;
      } else if (value != null) {
        sanitized[key] = _safeString(value.toString());
      }
    }
    return sanitized;
  }

  String _normalizeParameterName(String rawKey) {
    final base = rawKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final compact = base.replaceAll(RegExp(r'_+'), '_');
    if (compact.isEmpty) return '';

    var result = compact;
    if (RegExp(r'^[0-9]').hasMatch(result)) {
      result = 'p_$result';
    }
    if (result.startsWith('firebase_')) {
      result = 'fc_${result.substring(9)}';
    }
    if (result.length > 40) {
      result = result.substring(0, 40);
    }
    return result;
  }

  String _safeString(String value) {
    final normalized = value.trim();
    if (normalized.length <= 100) {
      return normalized;
    }
    return normalized.substring(0, 100);
  }
}
