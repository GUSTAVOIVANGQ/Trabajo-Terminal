import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/saved_diagram.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/metrics_service.dart';
import '../services/tutorial_service.dart';
import 'editor_screen.dart';
import 'help_screen.dart';
import 'profile_screen.dart';
import 'tutorial_list_screen.dart';
import 'interactive_tutorials_screen.dart';
import 'welcome_screen.dart';
import '../widgets/theme_selector_widget.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LoadDiagramScreen extends StatefulWidget {
  const LoadDiagramScreen({super.key});

  @override
  State<LoadDiagramScreen> createState() => _LoadDiagramScreenState();
}

class _LoadDiagramScreenState extends State<LoadDiagramScreen> {
  int _currentIndex = 0; // 0: Home (Mis diagramas), 1: Plantillas, 2: Ajustes/Perfil
  final DatabaseService _databaseService = DatabaseService();
  final MetricsService _metricsService = MetricsService();
  final TutorialService _tutorialService = TutorialService();
  final AuthService _authService = AuthService();
  List<SavedDiagram> _diagrams = [];
  List<SavedDiagram> _templates = [];
  bool _isLoading = true;
  bool _hasShownWelcome = false;

  final GlobalKey _bottomNavKey = GlobalKey();
  final GlobalKey _createBtnKey = GlobalKey();
  final GlobalKey _tutorialsFabKey = GlobalKey();
  final GlobalKey _interactiveTutorialsFabKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkFirstTime();
  }

  String? _getCurrentUserId() {
    final user = _authService.currentUser;
    if (user == null) return null;
    return user.isGuest ? 'guest_${user.uid}' : user.uid;
  }

  String _getTutorialUserKey() {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) return 'guest';
    return user.uid;
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final userId = _getCurrentUserId();
      final diagrams = await _databaseService.getAllDiagrams(userId: userId);
      final templates = await _databaseService.getAllTemplates();
      setState(() {
        _diagrams = diagrams;
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando diagramas: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkFirstTime() async {
    final tutorialUserKey = _getTutorialUserKey();
    final isFirstTime = await _tutorialService.isFirstTime(userId: tutorialUserKey);
    if (isFirstTime && mounted && !_hasShownWelcome) {
      _hasShownWelcome = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                userId: tutorialUserKey,
                onComplete: () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) _showAppTour();
                  });
                },
              ),
            ),
          );
        }
      });
    }
  }

  void _showAppTour() {
    List<TargetFocus> targets = [];
    
    targets.add(
      TargetFocus(
        identify: "bottomNav",
        keyTarget: _bottomNavKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Navegación Principal", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Alterna entre tus diagramas, las plantillas disponibles y tus ajustes.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          )
        ],
      )
    );

    targets.add(
      TargetFocus(
        identify: "createBtn",
        keyTarget: _createBtnKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nuevo Diagrama", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Toca aquí para abrir el editor y comenzar a diseñar.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          )
        ],
      )
    );

    // Mantenemos los tutoriales interactivos y guías
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
                  Text("Guías de Uso", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Aquí puedes leer sobre cómo funciona la aplicación.", style: TextStyle(color: Colors.white, fontSize: 16)),
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFD8F2EE), // Cyan claro
              const Color(0xFFF3E7FC), // Morado/rosa claro
              const Color(0xFFF0F6FF), // Azul muy claro
            ],
            stops: const [0.1, 0.6, 0.9],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildBodyContent(),
                  ),
                ],
              ),
              // Floating Action Buttons for tutorials
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      key: _interactiveTutorialsFabKey,
                      heroTag: 'interactive_tutorials_fab',
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.play_lesson, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const InteractiveTutorialsScreen()),
                        );
                      },
                      tooltip: 'Tutoriales interactivos',
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      key: _tutorialsFabKey,
                      heroTag: 'tutorials_fab',
                      backgroundColor: Colors.deepPurple,
                      child: const Icon(Icons.quiz, color: Colors.white),
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const TutorialListScreen()),
                        );
                        if (result == 'start_tour' && mounted) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) _showAppTour();
                          });
                        }
                      },
                      tooltip: 'Guías de Uso',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        key: _bottomNavKey,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              // Don't change index to 2, keep on current so when returning it stays
            } else {
              setState(() { _currentIndex = index; });
            }
          },
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Mis Diagramas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.file_copy_outlined),
              activeIcon: Icon(Icons.file_copy),
              label: 'Plantillas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Flowcode',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  const ThemeToggleButton(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    key: _profileKey,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // New Flowchart Button
          GestureDetector(
            key: _createBtnKey,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditorScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF20B2AA), Color(0xFF9370DB)], // Teal a Morado
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9370DB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 32),
                  SizedBox(height: 4),
                  Text(
                    'Nuevo Diagrama',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isHome = _currentIndex == 0;
    final items = isHome ? _diagrams : _templates;
    final title = isHome ? 'Proyectos Recientes' : 'Plantillas Disponibles';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    isHome ? 'No hay diagramas guardados' : 'No hay plantillas disponibles',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // 80 bottom padding for FABs
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildDiagramCard(items[index], canDelete: isHome);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDiagramCard(SavedDiagram item, {bool canDelete = false}) {
    return GestureDetector(
      onTap: () {
        if (!canDelete) {
          _metricsService.trackUserAction(
            action: 'plantilla_usada',
            category: 'templates',
            metadata: {
              'template_name': item.name,
              'template_id': item.id.toString(),
            },
          );
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => EditorScreen(initialDiagram: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Area (simulated)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        item.isTemplate ? Icons.article : Icons.account_tree,
                        size: 48,
                        color: item.isTemplate ? Colors.amber[300] : const Color(0xFF9370DB).withOpacity(0.5),
                      ),
                    ),
                    if (canDelete)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            color: Colors.grey[600],
                            onPressed: () {
                              _showDiagramOptions(item);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Text Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yy').format(item.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagramOptions(SavedDiagram diagram) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar diagrama', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteDiagram(diagram);
                },
              ),
            ],
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
        content: Text('¿Estás seguro de que deseas eliminar "${diagram.name}"?'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagrama eliminado')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando diagrama: ${e.toString()}')),
        );
      }
    }
  }
}
