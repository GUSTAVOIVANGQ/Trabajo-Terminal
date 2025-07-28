import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/editor_screen.dart';
import 'screens/load_diagram_screen.dart';
import 'widgets/auth_guard.dart';
import 'services/theme_service.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error inicializando Firebase: $e');
    // La app puede funcionar sin Firebase en modo offline
  }

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
          home: const AuthGuard(
            child: LoadDiagramScreen(),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
