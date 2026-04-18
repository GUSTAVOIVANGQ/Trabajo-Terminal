import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';

/// Pantalla de bienvenida para usuarios nuevos
class WelcomeScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onComplete;

  const WelcomeScreen({
    super.key,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TutorialService _tutorialService = TutorialService();

  final List<WelcomePageData> _pages = [
    WelcomePageData(
      icon: Icons.account_tree,
      title: '¡Bienvenido a FlowCode!',
      description:
          'Crea algoritmos de forma visual usando diagramas de flujo estándar.',
      color: Colors.blue,
      features: [
        'Editor visual intuitivo',
        'Símbolos estándar ANSI/ISO',
        'Fácil de usar',
      ],
    ),
    WelcomePageData(
      icon: Icons.code,
      title: 'Genera Código Automáticamente',
      description:
          'Convierte tus diagramas de flujo en código C funcional con un solo clic.',
      color: Colors.green,
      features: [
        'Generación automática de código',
        'Código listo para compilar',
        'Traducción directa de diagrama a código',
      ],
    ),
    WelcomePageData(
      icon: Icons.verified_user_outlined,
      title: 'Valida tus Diagramas',
      description:
          'Asegura la integridad estructural y lógica de tus algoritmos antes de generar el código.',
      color: Colors.purple,
      features: [
        'Detección de errores y advertencias',
        'Validación de nodos y conexiones',
        'Garantiza un código funcional',
      ],
    ),
    WelcomePageData(
      icon: Icons.check_circle_outline,
      title: '¡Comencemos!',
      description:
          'Consulta las guías y plantillas para comenzar a crear tus propios algoritmos rápidamente.',
      color: Colors.orange,
      features: [
        'Guías interactivas',
        'Plantillas de inicio',
        'Explora a tu ritmo',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _complete() async {
    await _tutorialService.markFirstTimeComplete(userId: widget.userId);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _complete,
                  child: const Text('Saltar'),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            _buildPageIndicator(),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(WelcomePageData page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            page.color,
                            page.color.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: page.color.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        page.icon,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),

              // Features
              ...page.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: page.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: page.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 32 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
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
    final isLast = _currentPage == _pages.length - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Anterior'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            )
          else
            const SizedBox(width: 100),

          // Next/Start button
          ElevatedButton.icon(
            onPressed: _nextPage,
            icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
            label: Text(isLast ? 'Comenzar' : 'Siguiente'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              backgroundColor: _pages[_currentPage].color,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  WelcomePageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}
