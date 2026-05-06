import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/diagram_node.dart';
import '../widgets/flow_diagram_canvas_final.dart';

class DiagramExportService {
  // Cache para la versión de Android SDK
  static int? _androidSdkVersion;
  static const double _exportPadding = 48.0;
  static const double _connectionOverflowPadding = 80.0;
  static const double _maxLogicalSide = 2200.0;
  static const double _basePixelRatio = 2.5;
  static const int _maxImageSidePixels = 6000;

  /// Obtiene la versión del SDK de Android
  static Future<int> _getAndroidSdkVersion() async {
    if (_androidSdkVersion != null) return _androidSdkVersion!;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _androidSdkVersion = androidInfo.version.sdkInt;
      return _androidSdkVersion!;
    }
    return 0;
  }

  /// Exporta el diagrama completo como imagen PNG usando renderizado off-screen.
  static Future<String> exportDiagramToPNG({
    required ThemeData exportTheme,
    required bool isDarkMode,
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required String diagramName,
  }) async {
    try {
      if (nodes.isEmpty) {
        throw Exception('No hay nodos para exportar');
      }

      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception(
            'Permisos de almacenamiento denegados. Por favor, habilita los permisos en Configuración de la app.');
      }

      final Uint8List pngBytes = await _renderDiagramAsPngBytes(
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
      );

      // Crear nombre de archivo único
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String cleanName = _sanitizeFileName(diagramName);
      final String fileName = '${cleanName}_$timestamp.png';

      // Guardar usando SaverGallery (guarda en Pictures/FlowDiagramApp)
      final result = await SaverGallery.saveImage(
        pngBytes,
        fileName: fileName,
        androidRelativePath: "Pictures/FlowDiagramApp",
        skipIfExists: false,
      );

      if (result.isSuccess) {
        return 'Pictures/FlowDiagramApp/$fileName';
      } else {
        // Fallback: guardar en directorio de la app
        return await _saveToAppDirectory(pngBytes, fileName);
      }
    } catch (e) {
      throw Exception('Error al exportar PNG: $e');
    }
  }

  /// Exporta el diagrama completo como imagen JPG usando renderizado off-screen.
  static Future<String> exportDiagramToJPG({
    required ThemeData exportTheme,
    required bool isDarkMode,
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required String diagramName,
    int quality = 85,
  }) async {
    try {
      if (nodes.isEmpty) {
      throw Exception('No hay nodos para exportar');
    }

      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception(
            'Permisos de almacenamiento denegados. Por favor, habilita los permisos en Configuración de la app.');
      }

      final Uint8List pngBytes = await _renderDiagramAsPngBytes(
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
      );

      // Convertir PNG a JPG usando la librería image
      final img.Image? pngImage = img.decodePng(pngBytes);
      if (pngImage == null) {
        throw Exception('Error al decodificar imagen PNG');
      }

      // Crear fondo blanco para JPG (ya que JPG no soporta transparencia)
      final img.Image jpgImage = img.fill(
        img.Image(
          width: pngImage.width,
          height: pngImage.height,
        ),
        color: img.ColorRgb8(255, 255, 255), // Fondo blanco
      );

      // Componer la imagen del diagrama sobre el fondo blanco
      img.compositeImage(jpgImage, pngImage);

      // Codificar como JPG
      final Uint8List jpgBytes =
          Uint8List.fromList(img.encodeJpg(jpgImage, quality: quality));

      // Crear nombre de archivo único
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String cleanName = _sanitizeFileName(diagramName);
      final String fileName = '${cleanName}_$timestamp.jpg';

      // Guardar usando SaverGallery (guarda en Pictures/FlowDiagramApp)
      final result = await SaverGallery.saveImage(
        jpgBytes,
        fileName: fileName,
        androidRelativePath: "Pictures/FlowDiagramApp",
        skipIfExists: false,
      );

      if (result.isSuccess) {
        return 'Pictures/FlowDiagramApp/$fileName';
      } else {
        // Fallback: guardar en directorio de la app
        return await _saveToAppDirectory(jpgBytes, fileName);
      }
    } catch (e) {
      throw Exception('Error al exportar JPG: $e');
    }
  }

  /// Exporta el diagrama completo a PDF y permite guardarlo o compartirlo.
  static Future<String> exportDiagramToPDF({
    required ThemeData exportTheme,
    required bool isDarkMode,
    required List<DiagramNode> nodes,
    required List<Connection> connections,
    required String diagramName,
  }) async {
    try {
      if (nodes.isEmpty) {
        throw Exception('No hay nodos para exportar');
      }

      final Uint8List pngBytes = await _renderDiagramAsPngBytes(
        exportTheme: exportTheme,
        isDarkMode: isDarkMode,
        nodes: nodes,
        connections: connections,
      );

      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String cleanName = _sanitizeFileName(diagramName);
      final String fileName = '${cleanName}_$timestamp.pdf';

      final pw.Document pdf = pw.Document();
      final pw.MemoryImage diagramImage = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FlowCode - $diagramName',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 16),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Image(
                      diagramImage,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final Uint8List pdfBytes = Uint8List.fromList(await pdf.save());

      if (Platform.isAndroid || Platform.isIOS) {
        // En móviles, Printing.sharePdf es lo mejor porque permite al usuario
        // elegir "Guardar en Archivos" o "Guardar en Descargas" fácilmente.
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
          subject: 'Diagrama de Flujo - $diagramName',
        );
        return 'PDF generado y enviado al sistema para guardar/compartir';
      }

      return await _saveToDownloads(pdfBytes, fileName);
    } catch (e) {
      throw Exception('Error al exportar PDF: $e');
    }
  }

  /// Exporta el código fuente C como archivo .c en la carpeta de Descargas
  static Future<String> exportCodeToCFile({
    required String code,
    required String diagramName,
  }) async {
    try {
      if (code.trim().isEmpty) {
        throw Exception('El código a exportar está vacío');
      }

      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String cleanName = _sanitizeFileName(diagramName);
      final String fileName = '${cleanName}_$timestamp.c';

      final Uint8List codeBytes = Uint8List.fromList(utf8.encode(code));
      return await _saveToDownloads(codeBytes, fileName);
    } catch (e) {
      throw Exception('Error al exportar archivo .c: $e');
    }
  }

  /// Guarda el archivo en la carpeta de descargas pública si es posible, o en el directorio de la app
  static Future<String> _saveToDownloads(
      Uint8List bytes, String fileName) async {
    try {
      if (Platform.isAndroid) {
        // Intentar guardar en la carpeta de Descargas pública de Android
        // Esto funciona en muchas versiones si se tienen los permisos adecuados
        const String downloadPath = '/storage/emulated/0/Download';
        final Directory downloadDir = Directory(downloadPath);

        if (await downloadDir.exists()) {
          final File file = File('$downloadPath/$fileName');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      } else if (Platform.isIOS || Platform.isMacOS || Platform.isWindows) {
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final File file = File('${downloadsDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Error intentando guardar en Descargas públicas: $e');
    }

    // Fallback al directorio de la app
    return await _saveToAppDirectory(bytes, fileName);
  }

  /// Guarda el archivo en el directorio de la app (fallback)
  static Future<String> _saveToAppDirectory(
      Uint8List bytes, String fileName) async {
    final Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir != null) {
      final Directory exportDir =
          Directory('${externalDir.path}/FlowDiagramExports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final File file = File('${exportDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Solicita permisos de almacenamiento según la versión de Android
  static Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true; // En otras plataformas no necesitamos permisos especiales
    }

    final int sdkVersion = await _getAndroidSdkVersion();

    // Android 13+ (API 33+): Necesita READ_MEDIA_IMAGES para guardar en galería
    if (sdkVersion >= 33) {
      final status = await Permission.photos.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }

      final result = await Permission.photos.request();
      // Intentamos pedir también el de almacenamiento general por si acaso para Downloads
      await Permission.storage.request();
      
      return result.isGranted || result.isLimited || result.isDenied;
    }
    // Android 10-12 (API 29-32):
    else if (sdkVersion >= 29) {
      final status = await Permission.storage.status;
      if (status.isGranted) return true;
      await Permission.storage.request();
      return true; 
    }
    // Android 9 y anteriores (API < 29): Permisos legacy
    else {
      final status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }

      final result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  /// Verifica si los permisos están disponibles (para mostrar UI)
  static Future<PermissionCheckResult> checkStoragePermission() async {
    if (!Platform.isAndroid) {
      return PermissionCheckResult(
        hasPermission: true,
        sdkVersion: 0,
        message: 'Permisos no requeridos en esta plataforma',
      );
    }

    final int sdkVersion = await _getAndroidSdkVersion();

    if (sdkVersion >= 33) {
      final status = await Permission.photos.status;
      return PermissionCheckResult(
        hasPermission: true,
        sdkVersion: sdkVersion,
        message:
            'Android 13+: Las imágenes se guardarán en Galería > FlowDiagramApp',
        photosPermissionGranted: status.isGranted || status.isLimited,
      );
    } else if (sdkVersion >= 29) {
      return PermissionCheckResult(
        hasPermission: true,
        sdkVersion: sdkVersion,
        message:
            'Android 10+: Las imágenes se guardarán en Galería > FlowDiagramApp',
      );
    } else {
      final status = await Permission.storage.status;
      return PermissionCheckResult(
        hasPermission: status.isGranted,
        sdkVersion: sdkVersion,
        message: status.isGranted
            ? 'Permisos de almacenamiento concedidos'
            : 'Se requieren permisos de almacenamiento',
      );
    }
  }

  /// Limpia el nombre del archivo de caracteres no válidos
  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Obtiene información sobre dónde se guardan los archivos
  static Future<String> getExportLocation() async {
    return 'Galería > Pictures > FlowDiagramApp';
  }

  /// Obtiene una descripción amigable de la ubicación de exportación
  static Future<String> getExportLocationDescription() async {
    if (Platform.isAndroid) {
      return 'Imágenes: Galería > FlowDiagramApp\nPDF y Código: Carpeta de Descargas (Downloads)';
    }
    return 'Carpeta de descargas o documentos del sistema';
  }

  /// Renderiza todo el diagrama fuera de pantalla para evitar depender del zoom/pan visible.
  static Future<Uint8List> _renderDiagramAsPngBytes({
    required ThemeData exportTheme,
    required bool isDarkMode,
    required List<DiagramNode> nodes,
    required List<Connection> connections,
  }) async {
    final Rect bounds = _calculateDiagramBounds(nodes);

    final double expandedLeft = bounds.left - _connectionOverflowPadding;
    final double expandedTop = bounds.top - _connectionOverflowPadding;
    final double expandedWidth =
        bounds.width + (_connectionOverflowPadding * 2);
    final double expandedHeight =
        bounds.height + (_connectionOverflowPadding * 2);

    final double rawMaxSide = math.max(expandedWidth, expandedHeight);
    final double diagramScale =
        rawMaxSide > _maxLogicalSide ? _maxLogicalSide / rawMaxSide : 1.0;

    final double logicalWidth =
        expandedWidth * diagramScale + (_exportPadding * 2);
    final double logicalHeight =
        expandedHeight * diagramScale + (_exportPadding * 2);

    final double largestLogicalSide = math.max(logicalWidth, logicalHeight);
    final double constrainedPixelRatio = math.min(
      _basePixelRatio,
      _maxImageSidePixels / largestLogicalSide,
    );
    final double pixelRatio = constrainedPixelRatio.clamp(1.0, _basePixelRatio);

    final int imageWidth = math.max(1, (logicalWidth * pixelRatio).round());
    final int imageHeight = math.max(1, (logicalHeight * pixelRatio).round());

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
    );

    canvas.scale(pixelRatio, pixelRatio);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, logicalWidth, logicalHeight),
      Paint()..color = exportTheme.colorScheme.surface,
    );

    final FlowDiagramPainter painter = FlowDiagramPainter(
      nodes: nodes,
      connections: connections,
      selectedNode: null,
      draggingNode: null,
      currentDragPosition: null,
      panOffset: Offset(
        _exportPadding - (expandedLeft * diagramScale),
        _exportPadding - (expandedTop * diagramScale),
      ),
      scale: diagramScale,
      themeOverride: exportTheme,
      isDarkModeOverride: isDarkMode,
    );

    painter.paint(canvas, Size(logicalWidth, logicalHeight));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(imageWidth, imageHeight);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    image.dispose();
    picture.dispose();

    if (byteData == null) {
      throw Exception('Error al convertir imagen renderizada a bytes PNG');
    }

    return byteData.buffer.asUint8List();
  }

  static Rect _calculateDiagramBounds(List<DiagramNode> nodes) {
    Rect bounds = Rect.fromLTWH(
      nodes.first.position.dx,
      nodes.first.position.dy,
      nodes.first.size.width,
      nodes.first.size.height,
    );

    for (int i = 1; i < nodes.length; i++) {
      final node = nodes[i];
      bounds = bounds.expandToInclude(
        Rect.fromLTWH(
          node.position.dx,
          node.position.dy,
          node.size.width,
          node.size.height,
        ),
      );
    }

    return bounds;
  }
}

/// Resultado de la verificación de permisos
class PermissionCheckResult {
  final bool hasPermission;
  final int sdkVersion;
  final String message;
  final bool? photosPermissionGranted;

  PermissionCheckResult({
    required this.hasPermission,
    required this.sdkVersion,
    required this.message,
    this.photosPermissionGranted,
  });
}
