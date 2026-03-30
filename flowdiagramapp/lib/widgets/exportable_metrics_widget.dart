import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/metric_model.dart';

class ExportableMetricsWidget extends StatelessWidget {
  final GlobalMetrics metrics;
  final List<Map<String, dynamic>> usersMetrics;

  const ExportableMetricsWidget({
    super.key,
    required this.metrics,
    required this.usersMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildOverview(),
          const SizedBox(height: 20),
          _buildTechnicalMetrics(),
          const SizedBox(height: 20),
          _buildEducationalMetrics(),
          const SizedBox(height: 20),
          _buildTopUsers(),
          const SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FlowCode - Reporte de Métricas',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Divider(thickness: 2, color: Colors.purple),
      ],
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Usuarios',
                metrics.totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Usuarios Activos',
                metrics.activeUsers.toString(),
                Icons.person_outline,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Diagramas Creados',
                metrics.totalDiagrams.toString(),
                Icons.account_tree,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas Técnicas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              _buildMetricRow(
                'Precisión del Compilador',
                '${(metrics.performanceMetrics['completionRate'] ?? 0.0 * 100).toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Detección de Errores',
                '${(metrics.performanceMetrics['errorRate'] ?? 0.0 * 100).toStringAsFixed(1)}%',
                Icons.error_outline,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Total Validaciones',
                '${metrics.totalValidations}',
                Icons.code,
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationalMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas Educativas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Column(
            children: [
              _buildMetricRow(
                'Tiempo Promedio de Sesión',
                '${(metrics.performanceMetrics['averageSessionTime'] ?? 0.0).toStringAsFixed(1)} min',
                Icons.timer,
                Colors.purple,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Progreso Promedio de Usuario',
                '${(metrics.averageUserProgress * 100).toStringAsFixed(1)}%',
                Icons.assignment_turned_in,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Total de Diagramas',
                '${metrics.totalDiagrams}',
                Icons.trending_up,
                Colors.indigo,
              ),
              const SizedBox(height: 8),
              _buildMetricRow(
                'Usuarios Activos vs Total',
                '${metrics.activeUsers}/${metrics.totalUsers}',
                Icons.sentiment_satisfied,
                Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopUsers() {
    if (usersMetrics.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 Usuarios Más Activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text('No hay datos de usuarios disponibles'),
        ],
      );
    }

    // Tomar los primeros 5 usuarios y ordenarlos por actividad
    final topUsers = usersMetrics.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 5 Usuarios Más Activos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('Usuario',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 2,
                        child: Text('Diagramas',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 2,
                        child: Text('Éxito (%)',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        flex: 2,
                        child: Text('Último Acceso',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Datos
              ...topUsers.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          (user['email']?.toString() ?? '').length > 20
                              ? '${user['email']?.toString().substring(0, 20)}...'
                              : user['email']?.toString() ?? 'N/A',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          (user['diagramas_creados'] ?? 0).toString(),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${((user['tasa_exito'] ?? 0) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatDate(user['ultimo_acceso']),
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FlowCode - Panel Administrativo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Página 1 de 1',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yy').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return 'N/A';
    }
  }
}
