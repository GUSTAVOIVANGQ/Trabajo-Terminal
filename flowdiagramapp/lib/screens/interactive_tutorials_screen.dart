import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../interactive_tutorials/interactive_tutorials.dart';
import '../models/saved_diagram.dart';
import '../services/database_service.dart';
import 'interactive_tutorial_session_screen.dart';

class InteractiveTutorialsScreen extends StatefulWidget {
  const InteractiveTutorialsScreen({super.key});

  @override
  State<InteractiveTutorialsScreen> createState() =>
      _InteractiveTutorialsScreenState();
}

class _InteractiveTutorialsScreenState
    extends State<InteractiveTutorialsScreen> {
  late final InteractiveTutorialProvider _provider;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _provider = InteractiveTutorialProvider();
    _provider.initialize();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InteractiveTutorialProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tutoriales interactivos'),
        ),
        body: Consumer<InteractiveTutorialProvider>(
          builder: (context, tutorialProvider, _) {
            if (!tutorialProvider.initialized) {
              return const Center(child: CircularProgressIndicator());
            }

            final tutorials = tutorialProvider.tutorials;
            if (tutorials.isEmpty) {
              return const Center(
                child: Text('No hay tutoriales interactivos disponibles.'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIntroCard(context),
                const SizedBox(height: 16),
                _buildInteractionModelCard(context),
                const SizedBox(height: 18),
                ...List.generate(tutorials.length, (index) {
                  final tutorial = tutorials[index];
                  return _buildTutorialCard(
                    context,
                    tutorialProvider,
                    tutorial,
                    index,
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_lesson, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Ruta Guiada de Construcción',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Esta sección ejecuta una sesión operativa controlada en el editor. '
            'Cada paso solicita acciones concretas para completar un diagrama desde la plantilla base.',
            style: TextStyle(
              color: Colors.white,
              height: 1.45,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 320.ms)
        .slideY(begin: -0.08, end: 0, duration: 320.ms);
  }

  Widget _buildInteractionModelCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Modo de interacción',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const _Bullet(
                text: 'Plantilla preparada automáticamente al iniciar.'),
            const _Bullet(
                text: 'Avance guiado paso a paso con objetivo técnico.'),
            const _Bullet(
                text:
                    'Seguimiento por acciones del editor y progreso persistente.'),
            const _Bullet(
                text: 'Cierre con validacion, vista de C y guardado local.'),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 60.ms, duration: 340.ms)
        .slideY(begin: 0.1, end: 0, duration: 340.ms);
  }

  Widget _buildTutorialCard(
    BuildContext context,
    InteractiveTutorialProvider tutorialProvider,
    InteractiveTutorialDefinition tutorial,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.route,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tutorial.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              tutorial.summary,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.82,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.integration_instructions, size: 18),
                  label: Text('Plantilla: ${tutorial.templateName}'),
                ),
                Chip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text('Duración: ${tutorial.estimatedMinutes} min'),
                ),
                Chip(
                  avatar: const Icon(Icons.format_list_numbered, size: 18),
                  label: Text('Pasos: ${tutorial.steps.length}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _startTutorial(
                      tutorialProvider: tutorialProvider,
                      tutorial: tutorial,
                      resetProgress: false,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar sesión'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startTutorial(
                      tutorialProvider: tutorialProvider,
                      tutorial: tutorial,
                      resetProgress: true,
                    ),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar ruta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 70).ms, duration: 360.ms)
        .slideX(begin: 0.08, end: 0, duration: 360.ms);
  }

  Future<void> _startTutorial({
    required InteractiveTutorialProvider tutorialProvider,
    required InteractiveTutorialDefinition tutorial,
    required bool resetProgress,
  }) async {
    final started = await tutorialProvider.startTutorial(tutorial.id);
    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible iniciar el tutorial seleccionado.'),
        ),
      );
      return;
    }

    if (resetProgress) {
      await tutorialProvider.resetActiveTutorial();
      if (!mounted) return;
    }

    final tutorialTemplate =
        await _prepareTutorialTemplate(tutorial.templateName);
    if (!mounted) return;

    if (tutorialTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('No se encontró la plantilla ${tutorial.templateName}.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InteractiveTutorialSessionScreen(
          provider: tutorialProvider,
          initialDiagram: tutorialTemplate,
        ),
      ),
    );
  }

  Future<SavedDiagram?> _prepareTutorialTemplate(String templateName) async {
    final templates = await _databaseService.getAllTemplates();

    SavedDiagram? selectedTemplate;
    for (final template in templates) {
      if (template.name == templateName) {
        selectedTemplate = template;
        break;
      }
    }

    if (selectedTemplate == null) {
      return null;
    }

    final now = DateTime.now();
    return selectedTemplate.copyWith(
      id: null,
      name: 'Tutorial - ${selectedTemplate.name}',
      description: 'Sesion interactiva de practica',
      isTemplate: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
