import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CrashReportingService {
  static final CrashReportingService _instance =
      CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  FirebaseCrashlytics? _crashlytics;
  bool _initialized = false;
  bool _collectionEnabled = false;

  bool get isCollectionEnabled => _collectionEnabled;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (Firebase.apps.isEmpty) {
      return;
    }

    try {
      _crashlytics = FirebaseCrashlytics.instance;
      await _crashlytics!.setCrashlyticsCollectionEnabled(false);
      _collectionEnabled = false;
    } catch (e) {
      debugPrint('CrashReportingService.initialize error: $e');
      _crashlytics = null;
      _collectionEnabled = false;
    }
  }

  Future<void> configureCollection({
    required bool crashReportsOptIn,
    required bool isGuest,
  }) async {
    await initialize();
    if (_crashlytics == null) return;

    final shouldEnable = crashReportsOptIn && !isGuest;

    try {
      await _crashlytics!.setCrashlyticsCollectionEnabled(shouldEnable);
      _collectionEnabled = shouldEnable;

      await _crashlytics!.setCustomKey('auth_mode', isGuest ? 'guest' : 'user');
      await _crashlytics!
          .setCustomKey('crash_reports_opt_in', crashReportsOptIn);

      if (!shouldEnable) {
        await _crashlytics!.deleteUnsentReports();
      }
    } catch (e) {
      debugPrint('CrashReportingService.configureCollection error: $e');
    }
  }

  Future<void> disableCollection() async {
    await initialize();
    if (_crashlytics == null) return;

    try {
      await _crashlytics!.setCrashlyticsCollectionEnabled(false);
      await _crashlytics!.deleteUnsentReports();
      _collectionEnabled = false;
    } catch (e) {
      debugPrint('CrashReportingService.disableCollection error: $e');
    }
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (!_collectionEnabled || _crashlytics == null) return;

    try {
      await _crashlytics!.recordFlutterFatalError(details);
    } catch (e) {
      debugPrint('CrashReportingService.recordFlutterError error: $e');
    }
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String reason = 'UnhandledError',
    bool fatal = false,
  }) async {
    if (!_collectionEnabled || _crashlytics == null) return;

    try {
      await _crashlytics!.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('CrashReportingService.recordError error: $e');
    }
  }
}
