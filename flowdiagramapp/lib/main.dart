import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/load_diagram_screen.dart';
import 'services/analytics_service.dart';
import 'services/crash_reporting_service.dart';
import 'widgets/auth_guard.dart';
import 'services/theme_service.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Analytics starts disabled and is enabled only with explicit consent.
    await AnalyticsService().initialize();
    await CrashReportingService().initialize();
  } catch (e) {
    print('Error inicializando Firebase: $e');
    // La app puede funcionar sin Firebase en modo offline
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    CrashReportingService().recordFlutterError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    CrashReportingService().recordError(
      error,
      stack,
      reason: 'platform_dispatcher_uncaught',
      fatal: true,
    );
    return false;
  };

  // Inicializar el servicio de temas
  await ThemeService().initialize();

  runApp(const FlowDiagramApp());
}

class FlowDiagramApp extends StatelessWidget {
  const FlowDiagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Flow Diagram App',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeService().themeMode,
          navigatorObservers: AnalyticsService().navigatorObservers,
          home: const AuthGuard(
            child: LoadDiagramScreen(),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
