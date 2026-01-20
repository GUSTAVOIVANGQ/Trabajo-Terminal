import 'package:flutter/material.dart';
import 'dart:async';
import '../models/exercise_model.dart';
import '../models/diagram_node.dart';
import '../services/exercise_service.dart';
import '../themes/app_themes.dart';
import '../services/theme_service.dart';
import '../widgets/exercise_result_dialog.dart';

// Nota: Los simbolos "connector" y "comment" han sido comentados en el servicio de ejercicios porque no están definidos en DiagramNode.dart

class ExerciseQuestionScreen extends StatefulWidget {
  final List<Exercise> exercises;
  final ExerciseCategory category;

  const ExerciseQuestionScreen({
    super.key,
    required this.exercises,
    required this.category,
  });

  @override
  State<ExerciseQuestionScreen> createState() => _ExerciseQuestionScreenState();
}

class _ExerciseQuestionScreenState extends State<ExerciseQuestionScreen>
    with TickerProviderStateMixin {
  final ExerciseService _exerciseService = ExerciseService();

  int _currentIndex = 0;
  List<String> _selectedAnswers = [];
  DateTime? _startTime;
  bool _isAnswered = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Exercise get _currentExercise => widget.exercises[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmation();
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Ejercicio ${_currentIndex + 1}/${widget.exercises.length}',
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_currentExercise.points} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildExerciseContent(),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / widget.exercises.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCategoryName(widget.category),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(_currentIndex + 1)}/${widget.exercises.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDifficultyBadge(),
        const SizedBox(height: 16),
        _buildQuestionCard(),
        const SizedBox(height: 24),
        if (_currentExercise.explanation != null) ...[
          _buildExplanationCard(),
          const SizedBox(height: 24),
        ],
        _buildAnswerOptions(),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    String text;
    IconData icon;

    switch (_currentExercise.difficulty) {
      case ExerciseDifficulty.easy:
        color = Colors.green;
        text = 'Fácil';
        icon = Icons.sentiment_satisfied;
        break;
      case ExerciseDifficulty.medium:
        color = Colors.orange;
        text = 'Medio';
        icon = Icons.sentiment_neutral;
        break;
      case ExerciseDifficulty.hard:
        color = Colors.red;
        text = 'Difícil';
        icon = Icons.sentiment_very_dissatisfied;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pregunta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentExercise.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentExercise.explanation!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions() {
    switch (_currentExercise.type) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoiceOptions();
      case ExerciseType.trueOrFalse:
        return _buildTrueFalseOptions();
      case ExerciseType.matching:
        return _buildMatchingOptions();
      case ExerciseType.ordering:
        return _buildOrderingOptions();
      case ExerciseType.dragAndDrop:
        return _buildDragAndDropOptions();
    }
  }

  Widget _buildMultipleChoiceOptions() {
    final themeService = ThemeService();
    final isDarkMode = themeService.isDarkMode(context);
    final nodeColors = AppThemes.getNodeColors(isDarkMode);

    return Column(
      children: _currentExercise.options.map((option) {
        final isSelected = _selectedAnswers.contains(option.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: isSelected ? 4 : 1,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswers = [option.id];
                      });
                    },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                ),
                child: Row(
                  children: [
                    if (option.nodeType != null) ...[
                      _buildNodePreview(option.nodeType!, nodeColors),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (option.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              option.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNodePreview(NodeType nodeType, Map<String, Color> nodeColors) {
    // Crear un nodo temporal para obtener su tamaño
    final tempNode = DiagramNode(
      id: 'temp',
      type: nodeType,
      position: Offset.zero,
    );
    final size = tempNode.size;
    final scaleFactor = 0.1; // Reducido a 10% del tamaño original

    return Container(
      width: size.width * scaleFactor,
      height: size.height * scaleFactor,
      alignment: Alignment.center, // Centrar verticalmente
      child: CustomPaint(
        painter: NodePreviewPainter(
          nodeType: nodeType,
          color: _getNodeColor(nodeType, nodeColors),
        ),
      ),
    );
  }

  Color _getNodeColor(NodeType nodeType, Map<String, Color> nodeColors) {
    switch (nodeType) {
      case NodeType.terminal:
        return nodeColors['terminal'] ?? nodeColors['start'] ?? Colors.green;
      case NodeType.process:
        return nodeColors['process'] ?? Colors.blue;
      case NodeType.decision:
        return nodeColors['decision'] ?? Colors.orange;
      case NodeType.data:
        return nodeColors['data'] ?? nodeColors['input'] ?? Colors.purple;
      case NodeType.preparation:
        return nodeColors['preparation'] ??
            nodeColors['loop'] ??
            Colors.deepOrange;
      case NodeType.predefinedProcess:
        return nodeColors['predefinedProcess'] ??
            nodeColors['subprocess'] ??
            Colors.indigo;
      default:
        // Para símbolos ISO 5807 adicionales
        return Colors.grey;
    }
  }

  Widget _buildTrueFalseOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            text: 'Verdadero',
            icon: Icons.check_circle,
            color: Colors.green,
            optionId: 'true',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTrueFalseButton(
            text: 'Falso',
            icon: Icons.cancel,
            color: Colors.red,
            optionId: 'false',
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton({
    required String text,
    required IconData icon,
    required Color color,
    required String optionId,
  }) {
    final isSelected = _selectedAnswers.contains(optionId);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        elevation: isSelected ? 6 : 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isAnswered
              ? null
              : () {
                  setState(() {
                    _selectedAnswers = [optionId];
                  });
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
              color: isSelected ? color.withOpacity(0.1) : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: isSelected ? color : Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingOptions() {
    // Para este tipo, mostrar todas las opciones como seleccionables
    return _buildMultipleChoiceOptions();
  }

  Widget _buildOrderingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arrastra para ordenar los pasos:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            if (_isAnswered) return;
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = _currentExercise.options.removeAt(oldIndex);
              _currentExercise.options.insert(newIndex, item);
            });
          },
          children: _currentExercise.options.map((option) {
            return Container(
              key: ValueKey(option.id),
              margin: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.drag_handle),
                  title: Text(option.text),
                  trailing: Icon(
                    Icons.reorder,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDragAndDropOptions() {
    // Similar a ordering pero con áreas de drop específicas
    return _buildMultipleChoiceOptions();
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedAnswers.isEmpty ? null : _submitAnswer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentIndex < widget.exercises.length - 1
                    ? 'Verificar'
                    : 'Finalizar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswers = [];
        _isAnswered = false;
        _fadeController.reset();
        _fadeController.forward();
      });
    }
  }

  Future<void> _submitAnswer() async {
    final timeSpent = DateTime.now().difference(_startTime!).inSeconds;
    final isCorrect = _checkAnswer();

    final result = ExerciseResult(
      exerciseId: _currentExercise.id,
      userAnswers: _selectedAnswers,
      correctAnswers: _currentExercise.correctAnswers,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? _currentExercise.points : 0,
      completedAt: DateTime.now(),
      timeSpentSeconds: timeSpent,
    );

    await _exerciseService.saveExerciseResult(result);

    if (!mounted) return;

    // Mostrar resultado
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseResultDialog(
        result: result,
        exercise: _currentExercise,
      ),
    );

    if (shouldContinue == true) {
      if (_currentIndex < widget.exercises.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswers = [];
          _isAnswered = false;
          _startTime = DateTime.now();
          _fadeController.reset();
          _fadeController.forward();
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  bool _checkAnswer() {
    if (_currentExercise.type == ExerciseType.ordering) {
      // Para ordenamiento, verificar el orden correcto
      final userOrder = _currentExercise.options.map((o) => o.id).toList();
      return _listsEqual(userOrder, _currentExercise.correctAnswers);
    } else {
      // Para otros tipos, verificar si las respuestas seleccionadas son correctas
      return _selectedAnswers.every(
              (answer) => _currentExercise.correctAnswers.contains(answer)) &&
          _selectedAnswers.length == _currentExercise.correctAnswers.length;
    }
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.basicSymbols:
        return 'Símbolos Básicos';
      case ExerciseCategory.controlFlow:
        return 'Estructuras de Control';
      case ExerciseCategory.dataFlow:
        return 'Flujo de Datos';
      case ExerciseCategory.connections:
        return 'Conexiones';
      case ExerciseCategory.advanced:
        return 'Avanzado';
    }
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de los ejercicios?'),
        content:
            const Text('Tu progreso en el ejercicio actual no se guardará.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

// Painter para previsualizar nodos
class NodePreviewPainter extends CustomPainter {
  final NodeType nodeType;
  final Color color;

  NodePreviewPainter({required this.nodeType, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Crear un nodo temporal para obtener su path
    final tempNode = DiagramNode(
      id: 'temp',
      type: nodeType,
      position: Offset.zero,
    );
    final path = tempNode.getPath();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
