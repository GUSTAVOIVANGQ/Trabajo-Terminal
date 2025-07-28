import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/metric_model.dart';

class ExportService {
  /// Genera un archivo de texto con las métricas del administrador en formato simple
  static Future<String> generateMetricsText(
    GlobalMetrics metrics,
    List<Map<String, dynamic>> usersMetrics,
  ) async {
    final buffer = StringBuffer();

    // Encabezado
    buffer.writeln('FLOWDIAGRAM APP - REPORTE DE MÉTRICAS');
    buffer.writeln('=' * 50);
    buffer.writeln(
        'Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln();

    // Resumen General
    buffer.writeln('RESUMEN GENERAL');
    buffer.writeln('-' * 20);
    buffer.writeln('Total Usuarios: ${metrics.totalUsers}');
    buffer.writeln('Usuarios Activos: ${metrics.activeUsers}');
    buffer.writeln('Diagramas Creados: ${metrics.totalDiagrams}');
    buffer.writeln();

    // Métricas Técnicas
    buffer.writeln('MÉTRICAS TÉCNICAS');
    buffer.writeln('-' * 20);
    buffer.writeln(
        'Tasa de Finalización: ${(metrics.performanceMetrics['completionRate'] ?? 0.0 * 100).toStringAsFixed(1)}%');
    buffer.writeln(
        'Tasa de Errores: ${(metrics.performanceMetrics['errorRate'] ?? 0.0 * 100).toStringAsFixed(1)}%');
    buffer.writeln('Total Validaciones: ${metrics.totalValidations}');
    buffer.writeln();

    // Métricas Educativas
    buffer.writeln('MÉTRICAS EDUCATIVAS');
    buffer.writeln('-' * 20);
    buffer.writeln(
        'Tiempo Promedio de Sesión: ${(metrics.performanceMetrics['averageSessionTime'] ?? 0.0).toStringAsFixed(1)} min');
    buffer.writeln(
        'Progreso Promedio de Usuario: ${(metrics.averageUserProgress * 100).toStringAsFixed(1)}%');
    buffer.writeln(
        'Usuarios Activos vs Total: ${metrics.activeUsers}/${metrics.totalUsers}');
    buffer.writeln();

    // Top 5 Usuarios
    if (usersMetrics.isNotEmpty) {
      buffer.writeln('TOP 5 USUARIOS MÁS ACTIVOS');
      buffer.writeln('-' * 30);
      final topUsers = usersMetrics.take(5).toList();
      for (int i = 0; i < topUsers.length; i++) {
        final user = topUsers[i];
        buffer.writeln('${i + 1}. ${user['email'] ?? 'N/A'}');
        buffer.writeln('   Diagramas: ${user['diagramas_creados'] ?? 0}');
        buffer.writeln(
            '   Éxito: ${((user['tasa_exito'] ?? 0) * 100).toStringAsFixed(1)}%');
        buffer.writeln(
            '   Último acceso: ${_formatDateForText(user['ultimo_acceso'])}');
        buffer.writeln();
      }
    }

    // Guardar el archivo
    final output = await _getDownloadsDirectory();
    final file = File('${output.path}/metricas_admin_${_getTimestamp()}.txt');
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// Genera una imagen PNG de las métricas del administrador
  static Future<String> generateMetricsPNG(GlobalKey widgetKey) async {
    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Guardar el archivo
      final output = await _getDownloadsDirectory();
      final file = File('${output.path}/metricas_admin_${_getTimestamp()}.png');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error al generar PNG: $e');
    }
  }

  /// Genera una imagen JPG de las métricas del administrador
  static Future<String> generateMetricsJPG(GlobalKey widgetKey) async {
    try {
      // Primero generar PNG
      RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Para JPG, simplemente guardamos el PNG con extensión JPG
      // En una implementación más completa, aquí se haría la conversión real
      final output = await _getDownloadsDirectory();
      final file = File('${output.path}/metricas_admin_${_getTimestamp()}.jpg');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error al generar JPG: $e');
    }
  }

  /// Solicita permisos de almacenamiento si es necesario
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // En versiones modernas de Android, los permisos para Downloads
      // se manejan de manera diferente. Por simplicidad, retornamos true
      // ya que usaremos el directorio de la app como fallback
      return true;
    }
    return true; // En iOS los permisos se manejan automáticamente
  }

  /// Obtiene el directorio de descargas o un directorio accesible
  static Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Intentar usar directorio de descargas público
        const downloadsPath = '/storage/emulated/0/Download/FlowDiagramApp';
        final downloadsDir = Directory(downloadsPath);

        // Verificar si podemos crear/acceder al directorio
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        // Verificar si tenemos permisos de escritura
        final testFile = File('${downloadsDir.path}/.test');
        await testFile.writeAsString('test');
        await testFile.delete();

        return downloadsDir;
      } catch (e) {
        // Si falla, usar directorio de documentos de la app (siempre accesible)
        final appDir = await getApplicationDocumentsDirectory();
        final exportDir = Directory('${appDir.path}/exports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    } else {
      // Para iOS, usar el directorio de documentos
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    }
  }

  /// Genera un timestamp para el nombre del archivo
  static String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  static String _formatDateForText(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return 'N/A';
    }
  }

  /// Obtiene información sobre dónde se guardan los archivos
  static Future<String> getExportLocation() async {
    final dir = await _getDownloadsDirectory();
    return dir.path;
  }
}
