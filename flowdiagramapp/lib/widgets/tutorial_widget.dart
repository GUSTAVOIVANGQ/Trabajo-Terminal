import 'package:flutter/material.dart';
import '../models/tutorial_step.dart';
import '../services/tutorial_service.dart';

/// Widget principal del tutorial con animaciones y diseño atractivo
class TutorialWidget extends StatefulWidget {
  final TutorialPage tutorial;
  final VoidCallback? onComplete;
  final bool showInDialog; // Para mostrar en diálogo o pantalla completa

  const TutorialWidget({
    super.key,
    required this.tutorial,
    this.onComplete,
    this.showInDialog = true,
  });

  @override
  State<TutorialWidget> createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TutorialService _tutorialService = TutorialService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Animación de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Animación de slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < widget.tutorial.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );

      // Reiniciar animaciones
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    } else {
      _completeTutorial();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
      _pageController.animateToPage(
        _currentStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );

      // Reiniciar animaciones
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    }
  }

  void _completeTutorial() async {
    await _tutorialService.markTutorialComplete(widget.tutorial.id);
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showInDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: _buildContent(),
      );
    } else {
      return Scaffold(
        body: SafeArea(
          child: _buildContent(),
        ),
      );
    }
  }

  Widget _buildContent() {
    final step = widget.tutorial.steps[_currentStepIndex];

    return Container(
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con título y progreso
          _buildHeader(),

          // Contenido del paso actual
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.tutorial.steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStepIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildStepContent(widget.tutorial.steps[index]);
              },
            ),
          ),

          // Indicador de progreso
          _buildProgressIndicator(),

          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(widget.tutorial.category),
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
                      widget.tutorial.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tutorial.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.tutorial.estimatedMinutes} min',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.article_outlined,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                'Paso ${_currentStepIndex + 1} de ${widget.tutorial.steps.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del paso
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Icono animado del nodo (si aplica)
              if (step.nodeType != null) _buildNodeIcon(step.nodeType!),

              // Descripción
              Text(
                step.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Puntos clave
              if (step.keyPoints.isNotEmpty) _buildKeyPoints(step.keyPoints),

              // Ejemplo de código
              if (step.example != null) _buildExample(step.example!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeIcon(String nodeType) {
    final color = _getNodeColor(nodeType);

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: CustomPaint(
                size: _getNodeSize(nodeType),
                painter: NodeShapePainter(
                  nodeType: nodeType,
                  color: color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Size _getNodeSize(String nodeType) {
    switch (nodeType) {
      case 'start':
      case 'end':
        return const Size(120, 60);
      case 'process':
        return const Size(140, 80);
      case 'decision':
        return const Size(140, 140);
      case 'input':
      case 'output':
        return const Size(140, 80);
      case 'variable':
      case 'loop':
        return const Size(140, 80);
      case 'connector':
        return const Size(80, 80);
      case 'comment':
        return const Size(140, 100);
      case 'subprocess':
        return const Size(140, 80);
      default:
        return const Size(100, 100);
    }
  }

  Widget _buildKeyPoints(List<String> keyPoints) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Puntos Clave',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExample(String example) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ejemplo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            example,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.tutorial.steps.length,
          (index) {
            final isActive = index == _currentStepIndex;
            final isCompleted = index < _currentStepIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isFirst = _currentStepIndex == 0;
    final isLast = _currentStepIndex == widget.tutorial.steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Anterior
          if (!isFirst)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else
            const SizedBox(width: 100),

          // Botón Siguiente/Finalizar
          ElevatedButton.icon(
            onPressed: _nextStep,
            icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
            label: Text(isLast ? 'Finalizar' : 'Siguiente'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(TutorialCategory category) {
    switch (category) {
      case TutorialCategory.welcome:
        return Icons.waving_hand;
      case TutorialCategory.basics:
        return Icons.school;
      case TutorialCategory.nodes:
        return Icons.account_tree;
      case TutorialCategory.connections:
        return Icons.share;
      case TutorialCategory.validation:
        return Icons.check_circle_outline;
      case TutorialCategory.codeGeneration:
        return Icons.code;
    }
  }

  Color _getNodeColor(String nodeType) {
    switch (nodeType) {
      case 'start':
        return Colors.green;
      case 'end':
        return Colors.red;
      case 'process':
        return Colors.blue;
      case 'decision':
        return Colors.orange;
      case 'input':
        return Colors.green;
      case 'output':
        return Colors.blue;
      case 'variable':
        return Colors.purple;
      case 'loop':
        return Colors.amber;
      case 'connector':
        return Colors.indigo;
      case 'comment':
        return Colors.yellow.shade700;
      case 'subprocess':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}

/// Custom painter para dibujar las formas reales de los nodos
class NodeShapePainter extends CustomPainter {
  final String nodeType;
  final Color color;

  NodeShapePainter({
    required this.nodeType,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = _getNodePath(size);

    // Dibujar relleno
    canvas.drawPath(path, paint);
    // Dibujar borde
    canvas.drawPath(path, borderPaint);
  }

  Path _getNodePath(Size size) {
    final path = Path();

    switch (nodeType) {
      case 'start':
      case 'end':
        // Cápsula/píldora
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(size.height / 2),
        ));
        break;

      case 'process':
        // Rectángulo
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;

      case 'decision':
        // Rombo
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;

      case 'input':
        // Paralelogramo inclinado hacia la derecha
        final offset = size.height * 0.2;
        path.moveTo(offset, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width - offset, size.height);
        path.lineTo(0, size.height);
        path.close();
        break;

      case 'output':
        // Paralelogramo inclinado hacia la izquierda
        final offset = size.height * 0.2;
        path.moveTo(0, 0);
        path.lineTo(size.width - offset, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(offset, size.height);
        path.close();
        break;

      case 'variable':
      case 'loop':
        // Hexágono
        final indent = size.width * 0.15;
        path.moveTo(indent, 0);
        path.lineTo(size.width - indent, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - indent, size.height);
        path.lineTo(indent, size.height);
        path.lineTo(0, size.height / 2);
        path.close();
        break;

      case 'connector':
        // Círculo
        path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
        break;

      case 'comment':
        // Rectángulo con esquina doblada
        final foldSize = 15.0;
        path.moveTo(0, 0);
        path.lineTo(size.width - foldSize, 0);
        path.lineTo(size.width, foldSize);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        path.close();
        // Línea de la esquina doblada
        path.moveTo(size.width - foldSize, 0);
        path.lineTo(size.width - foldSize, foldSize);
        path.lineTo(size.width, foldSize);
        break;

      case 'subprocess':
        // Rectángulo con líneas dobles verticales
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        // Líneas verticales internas
        final lineOffset = size.width * 0.1;
        path.moveTo(lineOffset, 0);
        path.lineTo(lineOffset, size.height);
        path.moveTo(size.width - lineOffset, 0);
        path.lineTo(size.width - lineOffset, size.height);
        break;

      default:
        // Rectángulo por defecto
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }

    return path;
  }

  @override
  bool shouldRepaint(NodeShapePainter oldDelegate) {
    return oldDelegate.nodeType != nodeType || oldDelegate.color != color;
  }
}
