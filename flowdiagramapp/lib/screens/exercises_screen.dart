import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';
import '../services/auth_service.dart';
import 'exercise_question_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  final ExerciseService _exerciseService = ExerciseService();
  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<ExerciseCategory, ExerciseProgress> _progressMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProgress();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    if (user == null) return;

    Map<ExerciseCategory, ExerciseProgress> progressMap = {};
    for (var category in ExerciseCategory.values) {
      final progress =
          await _exerciseService.getCategoryProgress(category, user.uid);
      progressMap[category] = progress;
    }

    setState(() {
      _progressMap = progressMap;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios de Comprensión'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'Información',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(),
              ),
            ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Header con estadísticas generales
        SliverToBoxAdapter(
          child: _buildHeaderStats(),
        ),

        // Categorías de ejercicios
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = ExerciseCategory.values[index];
                return _buildCategoryCard(category, index);
              },
              childCount: ExerciseCategory.values.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    int totalCompleted = _progressMap.values
        .fold(0, (sum, progress) => sum + progress.completedExercises);
    int totalExercises = _progressMap.values
        .fold(0, (sum, progress) => sum + progress.totalExercises);
    int totalPoints = _progressMap.values
        .fold(0, (sum, progress) => sum + progress.earnedPoints);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tu Progreso',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                value: '$totalCompleted',
                label: 'Completados',
              ),
              _buildStatItem(
                icon: Icons.quiz,
                value: '$totalExercises',
                label: 'Total',
              ),
              _buildStatItem(
                icon: Icons.stars,
                value: '$totalPoints',
                label: 'Puntos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ExerciseCategory category, int index) {
    final progress = _progressMap[category];
    if (progress == null) return const SizedBox.shrink();

    final categoryInfo = _getCategoryInfo(category);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _openCategory(category),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    categoryInfo.color.withOpacity(0.1),
                    categoryInfo.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryInfo.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          categoryInfo.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryInfo.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryInfo.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: categoryInfo.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                                Text(
                                  '${progress.completedExercises}/${progress.totalExercises}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: categoryInfo.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress.progressPercentage / 100,
                                backgroundColor:
                                    categoryInfo.color.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    categoryInfo.color),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryInfo.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: categoryInfo.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${progress.earnedPoints} pts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: categoryInfo.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (progress.isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '¡Categoría completada!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CategoryInfo _getCategoryInfo(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.basicSymbols:
        return CategoryInfo(
          title: 'Símbolos Básicos',
          description: 'Aprende los símbolos fundamentales',
          icon: Icons.category,
          color: Colors.blue,
        );
      case ExerciseCategory.controlFlow:
        return CategoryInfo(
          title: 'Estructuras de Control',
          description: 'Decisiones y bucles',
          icon: Icons.account_tree,
          color: Colors.purple,
        );
      case ExerciseCategory.dataFlow:
        return CategoryInfo(
          title: 'Flujo de Datos',
          description: 'Entrada, salida y variables',
          icon: Icons.data_usage,
          color: Colors.orange,
        );
      case ExerciseCategory.connections:
        return CategoryInfo(
          title: 'Conexiones',
          description: 'Flujo lógico del diagrama',
          icon: Icons.share,
          color: Colors.teal,
        );
      case ExerciseCategory.advanced:
        return CategoryInfo(
          title: 'Avanzado',
          description: 'Conectores y subprocesos',
          icon: Icons.auto_awesome,
          color: Colors.deepPurple,
        );
    }
  }

  void _openCategory(ExerciseCategory category) {
    final exercises = _exerciseService.getExercisesByCategory(category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseQuestionScreen(
          exercises: exercises,
          category: category,
        ),
      ),
    ).then((_) => _loadProgress());
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.school, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sobre los Ejercicios'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nivel de Comprensión (Taxonomía de Bloom)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estos ejercicios están diseñados para evaluar tu comprensión de los conceptos básicos de programación:',
              ),
              const SizedBox(height: 12),
              _buildInfoItem(
                  Icons.visibility, 'Identificar símbolos y su función'),
              _buildInfoItem(Icons.compare, 'Distinguir entre operaciones'),
              _buildInfoItem(Icons.insights, 'Comparar soluciones'),
              _buildInfoItem(
                  Icons.description, 'Explicar el flujo de ejecución'),
              const SizedBox(height: 12),
              const Text(
                '¡Completa todos los ejercicios para mejorar tu comprensión!',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class CategoryInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  CategoryInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
