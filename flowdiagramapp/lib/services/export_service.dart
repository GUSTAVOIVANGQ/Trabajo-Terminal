import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import '../models/metric_model.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportService {
  /// Genera un PDF con las métricas del administrador
  static Future<String> generateMetricsPDF(
    GlobalMetrics metrics,
    List<Map<String, dynamic>> usersMetrics,
  ) async {
    final pdf = pw.Document();

    // Crear las páginas del PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildPDFHeader(),
            pw.SizedBox(height: 20),
            _buildPDFOverview(metrics),
            pw.SizedBox(height: 20),
            _buildPDFTechnicalMetrics(metrics),
            pw.SizedBox(height: 20),
            _buildPDFEducationalMetrics(metrics),
            pw.SizedBox(height: 20),
            _buildPDFUsersTable(usersMetrics),
          ];
        },
      ),
    );

    // Guardar el archivo
    final output = await _getOutputDirectory();
    final file = File('${output.path}/metricas_admin_${_getTimestamp()}.pdf');
    await file.writeAsBytes(await pdf.save());

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
      final output = await _getOutputDirectory();
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
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Convertir PNG a JPG usando la librería image
      img.Image? pngImage = img.decodePng(pngBytes);
      if (pngImage == null) {
        throw Exception('Error al decodificar la imagen PNG');
      }

      // Crear un fondo blanco y componer la imagen sobre él
      img.Image jpgImage = img.Image(
        width: pngImage.width,
        height: pngImage.height,
      );
      img.fill(jpgImage, color: img.ColorRgb8(255, 255, 255));
      img.compositeImage(jpgImage, pngImage);

      // Codificar como JPG
      List<int> jpgBytes = img.encodeJpg(jpgImage, quality: 95);

      // Guardar el archivo
      final output = await _getOutputDirectory();
      final file = File('${output.path}/metricas_admin_${_getTimestamp()}.jpg');
      await file.writeAsBytes(jpgBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error al generar JPG: $e');
    }
  }

  /// Solicita permisos de almacenamiento si es necesario
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android 10+ necesitamos permisos específicos
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      return await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted;
    }
    return true; // En iOS los permisos se manejan automáticamente
  }

  /// Obtiene el directorio de salida para los archivos
  static Future<Directory> _getOutputDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, usar la carpeta de Descargas
      try {
        // Intentar acceder a la carpeta de Descargas externa
        final downloadsPath = '/storage/emulated/0/Download';
        final downloadsDir = Directory(downloadsPath);

        if (await downloadsDir.exists()) {
          // Crear subcarpeta para FlowDiagram App
          final appDownloadsDir = Directory('${downloadsPath}/FlowDiagramApp');
          if (!await appDownloadsDir.exists()) {
            await appDownloadsDir.create(recursive: true);
          }
          return appDownloadsDir;
        } else {
          // Fallback al directorio de documentos de la app
          final appDir = await getApplicationDocumentsDirectory();
          final exportDir = Directory('${appDir.path}/exports');
          if (!await exportDir.exists()) {
            await exportDir.create(recursive: true);
          }
          return exportDir;
        }
      } catch (e) {
        // Si hay error, usar directorio de documentos como fallback
        final appDir = await getApplicationDocumentsDirectory();
        final exportDir = Directory('${appDir.path}/exports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    } else {
      // Para iOS, usar el directorio de documentos
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Genera un timestamp para el nombre del archivo
  static String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  // Métodos para construir el contenido del PDF

  static pw.Widget _buildPDFHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FlowDiagram App - Reporte de Métricas Administrativas',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generado el: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildPDFOverview(GlobalMetrics metrics) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumen General',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildPDFMetricCard(
                'Total Usuarios', metrics.totalUsers.toString()),
            _buildPDFMetricCard(
                'Usuarios Activos', metrics.activeUsers.toString()),
            _buildPDFMetricCard(
                'Diagramas Creados', metrics.totalDiagrams.toString()),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPDFTechnicalMetrics(GlobalMetrics metrics) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Métricas Técnicas',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildPDFMetricRow('Tasa de Finalización',
            '${(metrics.performanceMetrics['completionRate'] ?? 0.0 * 100).toStringAsFixed(1)}%'),
        _buildPDFMetricRow('Tasa de Errores',
            '${(metrics.performanceMetrics['errorRate'] ?? 0.0 * 100).toStringAsFixed(1)}%'),
        _buildPDFMetricRow('Total Validaciones', '${metrics.totalValidations}'),
      ],
    );
  }

  static pw.Widget _buildPDFEducationalMetrics(GlobalMetrics metrics) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Métricas Educativas',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildPDFMetricRow('Tiempo Promedio de Sesión',
            '${(metrics.performanceMetrics['averageSessionTime'] ?? 0.0).toStringAsFixed(1)} min'),
        _buildPDFMetricRow('Progreso Promedio de Usuario',
            '${(metrics.averageUserProgress * 100).toStringAsFixed(1)}%'),
        _buildPDFMetricRow('Total de Diagramas', '${metrics.totalDiagrams}'),
        _buildPDFMetricRow('Usuarios Activos vs Total',
            '${metrics.activeUsers}/${metrics.totalUsers}'),
      ],
    );
  }

  static pw.Widget _buildPDFUsersTable(
      List<Map<String, dynamic>> usersMetrics) {
    if (usersMetrics.isEmpty) {
      return pw.Text('No hay datos de usuarios disponibles');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalle de Usuarios',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            // Encabezado
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                _buildPDFTableCell('Usuario', isHeader: true),
                _buildPDFTableCell('Diagramas', isHeader: true),
                _buildPDFTableCell('Éxito (%)', isHeader: true),
                _buildPDFTableCell('Último Acceso', isHeader: true),
              ],
            ),
            // Datos
            ...usersMetrics.take(10).map((user) => pw.TableRow(
                  children: [
                    _buildPDFTableCell(user['email'] ?? 'N/A'),
                    _buildPDFTableCell(
                        (user['diagramas_creados'] ?? 0).toString()),
                    _buildPDFTableCell(
                        '${((user['tasa_exito'] ?? 0) * 100).toStringAsFixed(1)}%'),
                    _buildPDFTableCell(
                        _formatDateForPDF(user['ultimo_acceso'])),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPDFMetricCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPDFMetricRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPDFTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static String _formatDateForPDF(dynamic date) {
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
