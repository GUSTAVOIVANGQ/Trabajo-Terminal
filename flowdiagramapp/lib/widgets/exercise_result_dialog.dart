import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/exercise_model.dart';

class ExerciseResultDialog extends StatefulWidget {
  final ExerciseResult result;
  final Exercise exercise;

  const ExerciseResultDialog({
    super.key,
    required this.result,
    required this.exercise,
  });

  @override
  State<ExerciseResultDialog> createState() => _ExerciseResultDialogState();
}

class _ExerciseResultDialogState extends State<ExerciseResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Si la respuesta es correcta, mostrar confeti
    if (widget.result.isCorrect) {
      _confettiController.play();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
                _buildActions(),
              ],
            ),
          ),
        ),
        // Confeti para respuestas correctas
        if (widget.result.isCorrect)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
              numberOfParticles: 30,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final isCorrect = widget.result.isCorrect;
    final backgroundColor = isCorrect ? Colors.green : Colors.orange;
    final icon = isCorrect ? Icons.check_circle : Icons.lightbulb_outline;
    final title = isCorrect ? '¡Excelente!' : '¡Casi lo logras!';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '+${widget.result.pointsEarned} puntos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estadísticas
        _buildStatsCard(),
        const SizedBox(height: 20),

        // Retroalimentación
        _buildFeedbackCard(),
        const SizedBox(height: 20),

        // Respuestas
        if (!widget.result.isCorrect) ...[
          _buildAnswersComparison(),
          const SizedBox(height: 20),
        ],

        // Explicación adicional
        _buildExplanation(),
      ],
    );
  }

  Widget _buildStatsCard() {
    final accuracy = widget.result.accuracy;
    final timeSpent = widget.result.timeSpentSeconds;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.timer,
                  label: 'Tiempo',
                  value: '$timeSpent seg',
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.percent,
                  label: 'Precisión',
                  value: '${accuracy.toStringAsFixed(0)}%',
                  color: accuracy >= 70 ? Colors.green : Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.stars,
                  label: 'Puntos',
                  value: '${widget.result.pointsEarned}',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.result.isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.result.isCorrect
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.result.isCorrect ? Icons.check_circle : Icons.info_outline,
            color: widget.result.isCorrect ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.exercise.feedback,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comparación de respuestas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.close, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tu respuesta:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.result.userAnswers.map((answerId) {
                final option = widget.exercise.options
                    .firstWhere((opt) => opt.id == answerId);
                return Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text('• ${option.text}'),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Respuesta correcta:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...widget.result.correctAnswers.map((answerId) {
                final option = widget.exercise.options
                    .firstWhere((opt) => opt.id == answerId);
                return Padding(
                  padding: const EdgeInsets.only(left: 28, top: 4),
                  child: Text('• ${option.text}'),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation() {
    if (widget.exercise.explanation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.school, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Aprende más',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise.explanation!,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
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
}
