import 'package:flutter/material.dart';
import '../models/tutorial_step.dart';
import '../services/tutorial_service.dart';
import '../widgets/tutorial_widget.dart';

/// Pantalla que muestra la lista de todos los tutoriales disponibles
class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({super.key});

  @override
  State<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  final TutorialService _tutorialService = TutorialService();
  late List<TutorialPage> _allTutorials;
  Map<String, bool> _completionStatus = {};

  @override
  void initState() {
    super.initState();
    _allTutorials = _tutorialService.getAllTutorials();
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    final status = <String, bool>{};
    for (var tutorial in _allTutorials) {
      status[tutorial.id] =
          await _tutorialService.isTutorialCompleted(tutorial.id);
    }
    if (mounted) {
      setState(() {
        _completionStatus = status;
      });
    }
  }

  List<TutorialPage> _getTutorialsByCategory(TutorialCategory category) {
    return _allTutorials
        .where((tutorial) => tutorial.category == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
            tooltip: 'Acerca de los tutoriales',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildCategorySection(
            'Comenzar',
            TutorialCategory.welcome,
            Icons.waving_hand,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            'Conceptos Básicos',
            TutorialCategory.basics,
            Icons.school,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            'Símbolos de Nodos',
            TutorialCategory.nodes,
            Icons.account_tree,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            'Conexiones',
            TutorialCategory.connections,
            Icons.share,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            'Validación',
            TutorialCategory.validation,
            Icons.check_circle_outline,
            Colors.teal,
          ),
          const SizedBox(height: 16),
          _buildCategorySection(
            'Generación de Código',
            TutorialCategory.codeGeneration,
            Icons.code,
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.school,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Centro de Aprendizaje',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aprende a crear diagramas de flujo y comprende los conceptos básicos de programación.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_completionStatus.values.where((completed) => completed).length}/${_allTutorials.length} completados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    TutorialCategory category,
    IconData icon,
    Color color,
  ) {
    final tutorials = _getTutorialsByCategory(category);
    if (tutorials.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tutorials.map((tutorial) => _buildTutorialCard(tutorial, color)),
      ],
    );
  }

  Widget _buildTutorialCard(TutorialPage tutorial, Color categoryColor) {
    final isCompleted = _completionStatus[tutorial.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTutorial(tutorial),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de estado
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                  color: isCompleted ? Colors.green : categoryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información del tutorial
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tutorial.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.article_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tutorial.steps.length} pasos',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTutorial(TutorialPage tutorial) {
    showDialog(
      context: context,
      builder: (context) => TutorialWidget(
        tutorial: tutorial,
        onComplete: () {
          _loadCompletionStatus();
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de los Tutoriales'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nivel de Aprendizaje: Comprensión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Estos tutoriales están diseñados según la Taxonomía de Bloom, enfocándose en el nivel de COMPRENSIÓN.',
              ),
              SizedBox(height: 16),
              Text(
                '¿Qué aprenderás?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Identificar símbolos y su función'),
              Text('• Distinguir entre diferentes operaciones'),
              Text('• Comparar soluciones algorítmicas'),
              Text('• Explicar el flujo de ejecución'),
              SizedBox(height: 16),
              Text(
                'Tómate tu tiempo y practica con los ejemplos. ¡El aprendizaje es un proceso!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
