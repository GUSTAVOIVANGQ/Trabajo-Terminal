import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/metrics_service.dart';
import '../services/auth_service.dart';
import '../services/export_service_simple.dart';
import '../models/metric_model.dart';
import '../widgets/exportable_metrics_widget.dart';

class AdminMetricsScreen extends StatefulWidget {
  const AdminMetricsScreen({super.key});

  @override
  State<AdminMetricsScreen> createState() => _AdminMetricsScreenState();
}

class _AdminMetricsScreenState extends State<AdminMetricsScreen>
    with SingleTickerProviderStateMixin {
  final MetricsService _metricsService = MetricsService();
  final AuthService _authService = AuthService();
  final GlobalKey _exportKey = GlobalKey();

  late TabController _tabController;
  GlobalMetrics? _globalMetrics;
  List<Map<String, dynamic>>? _usersMetrics;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAdminAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAdminAccess() {
    final user = _authService.currentUser;
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Acceso denegado: Solo administradores pueden ver esta sección'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _loadAllMetrics();
  }

  Future<void> _loadAllMetrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final globalMetrics = await _metricsService.getGlobalMetrics();
      final usersMetrics = await _metricsService.getUsersWithMetrics();

      setState(() {
        _globalMetrics = globalMetrics;
        _usersMetrics = usersMetrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.analytics), text: 'Análisis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllMetrics,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: _onExportSelected,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'txt',
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Exportar TXT'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Exportar PNG'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'jpg',
                child: Row(
                  children: [
                    Icon(Icons.photo, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Exportar JPG'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando métricas del sistema...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar métricas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllMetrics,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildUsersTab(),
        _buildAnalyticsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    final metrics = _globalMetrics;
    if (metrics == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadAllMetrics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget exportable envuelto en RepaintBoundary
            RepaintBoundary(
              key: _exportKey,
              child: ExportableMetricsWidget(
                metrics: metrics,
                usersMetrics: _usersMetrics ?? [],
              ),
            ),
            const SizedBox(height: 24),
            // Información adicional no exportable
            _buildExportInfo(),
            const SizedBox(height: 16),
            Text(
              'Información Detallada del Sistema',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildUserDistribution(metrics),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(metrics),
            const SizedBox(height: 24),
            _buildSystemInfo(metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildExportInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Información de Exportación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Use el botón de descarga en la barra superior para exportar las métricas',
            style: TextStyle(color: Colors.blue.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '• Los archivos se guardan en Downloads/FlowDiagramApp/ (o documentos internos)',
            style: TextStyle(color: Colors.blue.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '• Funciona completamente sin conexión a internet',
            style: TextStyle(color: Colors.blue.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '• Formatos: TXT (reporte completo), PNG/JPG (imagen visual)',
            style: TextStyle(color: Colors.blue.shade600),
          ),
          if (_isExporting) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Generando archivo...',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserDistribution(GlobalMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución de Usuarios',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...metrics.usersByRole.entries.map((entry) {
              final percentage = metrics.totalUsers > 0
                  ? (entry.value / metrics.totalUsers * 100)
                  : 0.0;
              return _buildRoleBar(
                entry.key == 'admin' ? 'Administradores' : 'Usuarios',
                entry.value,
                percentage,
                entry.key == 'admin' ? Colors.purple : Colors.blue,
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasa de Actividad',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${((metrics.performanceMetrics['activity_rate'] ?? 0.0) * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
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

  Widget _buildRoleBar(String role, int count, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(role),
              Text('$count (${percentage.toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(GlobalMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas de Rendimiento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceRow(
              'Diagramas por Usuario',
              (metrics.performanceMetrics['diagrams_per_user'] ?? 0.0)
                  .toStringAsFixed(1),
              Icons.account_tree,
            ),
            _buildPerformanceRow(
              'Validaciones por Usuario',
              (metrics.performanceMetrics['validations_per_user'] ?? 0.0)
                  .toStringAsFixed(1),
              Icons.check_circle,
            ),
            _buildPerformanceRow(
              'Progreso Promedio',
              metrics.averageUserProgress.toStringAsFixed(1),
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfo(GlobalMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Sistema',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Última Actualización',
              DateFormat('dd/MM/yyyy HH:mm').format(metrics.generatedAt),
            ),
            _buildInfoRow(
              'Tiempo de Operación',
              _calculateUptime(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final usersMetrics = _usersMetrics;
    if (usersMetrics == null || usersMetrics.isEmpty) {
      return const Center(child: Text('No hay datos de usuarios disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadAllMetrics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: usersMetrics.length,
        itemBuilder: (context, index) {
          final userMetrics = usersMetrics[index];
          return _buildUserMetricCard(userMetrics);
        },
      ),
    );
  }

  Widget _buildUserMetricCard(Map<String, dynamic> userMetrics) {
    final user = userMetrics['user'];
    final summary = userMetrics['summary'] as MetricsSummary?;

    // Verificar que user no sea null
    if (user == null) {
      return const Card(
        child: ListTile(
          title: Text('Usuario no válido'),
          subtitle: Text('Datos de usuario corruptos'),
        ),
      );
    }

    // Verificar que summary no sea null
    if (summary == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: user.isAdmin == true ? Colors.purple : Colors.blue,
            child: Text(
              (user.displayName?.isNotEmpty == true)
                  ? user.displayName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(user.displayName ?? 'Usuario sin nombre'),
          subtitle: Text(user.email ?? 'Sin email'),
          trailing: const Text('Sin datos de métricas'),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin == true ? Colors.purple : Colors.blue,
          child: Text(
            (user.displayName?.isNotEmpty == true)
                ? user.displayName[0].toUpperCase()
                : 'U',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.displayName ?? 'Usuario sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email ?? 'Sin email'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: user.isAdmin == true ? Colors.purple : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.isAdmin == true ? 'Admin' : 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildUserMetricItem(
                        'Diagramas',
                        summary.totalDiagrams.toString(),
                        Icons.account_tree,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildUserMetricItem(
                        'Validaciones',
                        summary.totalValidations.toString(),
                        Icons.check_circle,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserMetricItem(
                        'Tasa Éxito',
                        '${(summary.successRate * 100).toStringAsFixed(1)}%',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildUserMetricItem(
                        'Último Acceso',
                        _formatLastLogin(user.lastLogin),
                        Icons.access_time,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMetricItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final metrics = _globalMetrics;
    if (metrics == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: _loadAllMetrics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis Detallado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTopUsersCard(metrics),
            const SizedBox(height: 16),
            _buildTrendsCard(),
            const SizedBox(height: 16),
            _buildRecommendationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUsersCard(GlobalMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top 10 Usuarios',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...metrics.topUsers.take(10).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return _buildTopUserItem(index + 1, user);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUserItem(int rank, Map<String, dynamic> user) {
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        break;
      case 2:
        rankColor = Colors.grey;
        break;
      case 3:
        rankColor = Colors.brown;
        break;
      default:
        rankColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['displayName'] ?? 'Usuario',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${user['diagramas']} diagramas, ${user['validaciones']} validaciones',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(user['progreso'] as double).toStringAsFixed(0)} pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rankColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendencias del Sistema',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildTrendItem(
              'Crecimiento de Usuarios',
              '+12%',
              'Última semana',
              Icons.trending_up,
              Colors.green,
            ),
            _buildTrendItem(
              'Actividad de Diagramas',
              '+8%',
              'Último mes',
              Icons.account_tree,
              Colors.blue,
            ),
            _buildTrendItem(
              'Uso de Plantillas',
              '+15%',
              'Última semana',
              Icons.description,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(
    String title,
    String change,
    String period,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              change,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Recomendaciones del Sistema',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Añadir más plantillas de ejercicios para mantener el engagement',
              Icons.add_circle_outline,
            ),
            _buildRecommendationItem(
              'Implementar sistema de logros para aumentar la motivación',
              Icons.emoji_events,
            ),
            _buildRecommendationItem(
              'Crear tutoriales para usuarios con baja actividad',
              Icons.school,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(lastLogin);
    }
  }

  String _calculateUptime() {
    // Simulación de uptime - en una implementación real, esto vendría del servidor
    return '99.5% (30 días)';
  }

  /// Maneja la selección del tipo de exportación
  void _onExportSelected(String format) async {
    if (_globalMetrics == null || _usersMetrics == null) {
      _showSnackBar('No hay datos para exportar', Colors.orange);
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Solicitar permisos de almacenamiento
      final hasPermission = await ExportService.requestStoragePermission();
      if (!hasPermission) {
        _showSnackBar('Permisos de almacenamiento denegados', Colors.red);
        return;
      }

      String filePath;
      switch (format) {
        case 'txt':
          filePath = await ExportService.generateMetricsText(
              _globalMetrics!, _usersMetrics!);
          break;
        case 'png':
          filePath = await ExportService.generateMetricsPNG(_exportKey);
          break;
        case 'jpg':
          filePath = await ExportService.generateMetricsJPG(_exportKey);
          break;
        default:
          throw Exception('Formato no soportado: $format');
      }

      _showSnackBar(
          'Archivo exportado: ${filePath.split('/').last}', Colors.green);

      // Mostrar información adicional sobre la ubicación
      _showExportLocationDialog(filePath);
    } catch (e) {
      _showSnackBar('Error al exportar: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  /// Muestra un SnackBar con un mensaje
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un diálogo con información sobre dónde se guardó el archivo
  void _showExportLocationDialog(String filePath) {
    final fileName = filePath.split('/').last;
    final directory = filePath.substring(0, filePath.lastIndexOf('/'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Archivo Exportado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El archivo se ha guardado exitosamente:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Archivo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      fileName,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ubicación:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      directory,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '💡 Puedes encontrar este archivo en tu gestor de archivos o en la carpeta de Descargas.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }
}
