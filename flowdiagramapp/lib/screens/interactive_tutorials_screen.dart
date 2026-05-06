// interactive_tutorials_screen.dart
// Pantalla de tutoriales — reemplaza el sistema event-driven manual
// por el nuevo sistema de tutorial automático con spotlight.
import 'package:flutter/material.dart';
import '../interactive_tutorials/auto_tutorial_models.dart';
import '../interactive_tutorials/auto_tutorial_overlay.dart';
import 'editor_screen.dart';

class InteractiveTutorialsScreen extends StatelessWidget {
  const InteractiveTutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTutorialCatalogPage(
      onStart: (AutoTutorialDefinition definition) =>
          _launchTutorial(context, definition),
    );
  }

  void _launchTutorial(BuildContext context, AutoTutorialDefinition definition) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorScreen(autoTutorial: definition),
      ),
    );
  }
}
