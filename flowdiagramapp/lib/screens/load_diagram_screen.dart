import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure this import is present
import '../models/saved_diagram.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/metrics_service.dart'; // Nueva importación
import '../services/tutorial_service.dart'; // Nueva importación para tutoriales
import 'editor_screen.dart';
import 'help_screen.dart';
import 'profile_screen.dart';
import 'tutorial_list_screen.dart'; // Nueva importación para tutoriales
import 'interactive_tutorials_screen.dart';
import 'welcome_screen.dart'; // Nueva importación para pantalla de bienvenida
// import 'exercises_screen.dart'; // Nueva importación para ejercicios
import '../widgets/theme_selector_widget.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LoadDiagramScreen extends StatefulWidget {
  const LoadDiagramScreen({super.key});

  @override
  State<LoadDiagramScreen> createState() => _LoadDiagramScreenState();
}

class _LoadDiagramScreenState extends State<LoadDiagramScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final MetricsService _metricsService = MetricsService(); // Nuevo servicio
  final TutorialService _tutorialService =
      TutorialService(); // Servicio de tutoriales
  final AuthService _authService = AuthService(); // Servicio de autenticación
  List<SavedDiagram> _diagrams = [];
  List<SavedDiagram> _templates = [];
  bool _isLoading = true;
  bool _hasShownWelcome = false;

  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _createFabKey = GlobalKey();
  final GlobalKey _tutorialsFabKey = GlobalKey();
  final GlobalKey _interactiveTutorialsFabKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _themeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _checkFirstTime();
  }

  /// Obtiene el ID del usuario actual (o 'guest' para invitados)
  String? _getCurrentUserId() {
    final user = _authService.currentUser;
    if (user == null) return null;
    return user.isGuest ? 'guest_${user.uid}' : user.uid;
  }

  /// Obtiene la clave para tutoriales de bienvenida (estable por usuario).
  String _getTutorialUserKey() {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) return 'guest';
    return user.uid;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _getCurrentUserId();
      // Cargar diagramas filtrados por usuario
      final diagrams = await _databaseService.getAllDiagrams(userId: userId);
      final templates = await _databaseService.getAllTemplates();

      setState(() {
        _diagrams = diagrams;
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando diagramas: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkFirstTime() async {
    final tutorialUserKey = _getTutorialUserKey();
    // Verificar si es la primera vez del usuario
    final isFirstTime =
        await _tutorialService.isFirstTime(userId: tutorialUserKey);
    if (isFirstTime && mounted && !_hasShownWelcome) {
      _hasShownWelcome = true;
      // Esperar a que se cargue la pantalla
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                userId: tutorialUserKey,
                onComplete: () {
                  Navigator.of(context).pop();
                  // Esperar a que la animación de pop termine antes de mostrar el tour
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _showAppTour();
                    }
                  });
                },
              ),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAppTour() {
    List<TargetFocus> targets = [];
    
    targets.add(
      TargetFocus(
        identify: "tabBar",
        keyTarget: _tabBarKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tus Diagramas y Plantillas",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aquí podrás ver los diagramas que has guardado, o usar una plantilla prediseñada para empezar rápidamente.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          )
        ],
      )
    );

    targets.add(
      TargetFocus(
        identify: "createFab",
        keyTarget: _createFabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crear Nuevo Diagrama",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Toca aquí para abrir el editor y comenzar a diseñar un algoritmo desde cero.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          )
        ],
      )
    );

    targets.add(
      TargetFocus(
        identify: "tutorialsFab",
        keyTarget: _tutorialsFabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Guías de Uso",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aquí puedes leer sobre cómo funciona la aplicación y sus características principales.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          )
        ],
      )
    );

    targets.add(
      TargetFocus(
        identify: "interactiveTutorialsFab",
        keyTarget: _interactiveTutorialsFabKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¡Aprende Jugando!",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Ahora te invitamos a experimentar y ver tutoriales automatizados de mi app. En esta sección puedes aprender paso a paso cómo armar algoritmos.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              );
            },
          )
        ],
      )
    );

    TutorialCoachMark(
      targets: targets,
      colorShadow: Theme.of(context).primaryColor,
      textSkip: "SALTAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    ).show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final appBarForeground =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cargar diagrama'),
        centerTitle: false,
        actions: [
          /*
          // Botón de ejercicios
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExercisesScreen(),
                ),
              );
            },
            tooltip: 'Ejercicios de comprensión',
          ),
          */
          // Botón para cambiar tema
          Container(
            key: _themeKey,
            child: const ThemeToggleButton(),
          ),

          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
            tooltip: 'Ayuda',
          ),

          IconButton(
            key: _profileKey,
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            tooltip: 'Mi perfil',
          ),
        ],
        bottom: TabBar(
          key: _tabBarKey,
          controller: _tabController,
          labelColor: appBarForeground,
          unselectedLabelColor: appBarForeground.withOpacity(0.75),
          indicatorColor: appBarForeground,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'Mis diagramas'), Tab(text: 'Plantillas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de diagramas guardados
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _diagrams.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay diagramas guardados',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildDiagramList(_diagrams, canDelete: true),

          // Pestaña de plantillas
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDiagramList(_templates),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botón de tutoriales interactivos (nuevo)
          FloatingActionButton(
            key: _interactiveTutorialsFabKey,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InteractiveTutorialsScreen(),
                ),
              );
            },
            heroTag: 'interactive_tutorials_fab',
            tooltip: 'Tutoriales interactivos',
            child: const Icon(Icons.play_lesson),
            backgroundColor: Colors.teal,
          ),
          const SizedBox(height: 12),
          // Botón de tutoriales (nuevo)
          FloatingActionButton(
            key: _tutorialsFabKey,
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TutorialListScreen(),
                ),
              );
              if (result == 'start_tour' && mounted) {
                // Pequeño delay para dejar que la pantalla termine de aparecer
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) _showAppTour();
                });
              }
            },
            heroTag: 'tutorials_fab',
            tooltip: 'Guías de Uso',
            child: const Icon(Icons.quiz),
            backgroundColor: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          // Botón crear nuevo
          FloatingActionButton(
            key: _createFabKey,
            onPressed: () {
              // En lugar de cerrar la pantalla actual, navegamos a la pantalla del editor
              Navigator.of(
                context,
              ).push(MaterialPageRoute(
                  builder: (context) => const EditorScreen()));
            },
            heroTag: 'create_fab',
            tooltip: 'Crear nuevo',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramList(List<SavedDiagram> items, {bool canDelete = false}) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  'Modificado: ${DateFormat('dd/MM/yyyy HH:mm').format(item.updatedAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: item.isTemplate ? Colors.amber : Colors.blue,
              child: Icon(
                item.isTemplate ? Icons.article : Icons.insert_chart,
                color: Colors.white,
              ),
            ),
            trailing: canDelete
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDeleteDiagram(item),
                  )
                : null,
            onTap: () {
              // Registrar uso de plantilla si es una plantilla
              if (!canDelete) {
                // Las plantillas no se pueden eliminar
                _metricsService.trackUserAction(
                  action: 'plantilla_usada',
                  category: 'templates',
                  metadata: {
                    'template_name': item.name,
                    'template_id': item.id.toString(),
                  },
                );
              }

              // En lugar de cerrar la pantalla, navegamos al editor con el diagrama seleccionado
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditorScreen(initialDiagram: item),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteDiagram(SavedDiagram diagram) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar diagrama'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${diagram.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _databaseService.deleteDiagram(diagram.id!);
        setState(() {
          _diagrams.removeWhere((d) => d.id == diagram.id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Diagrama eliminado')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando diagrama: ${e.toString()}')),
        );
      }
    }
  }
}
