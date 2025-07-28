import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DiagramExportService {
  /// Exporta el diagrama como imagen PNG usando un GlobalKey
  static Future<String> exportDiagramToPNG({
    required GlobalKey canvasKey,
    required String diagramName,
  }) async {
    try {
      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Permisos de almacenamiento denegados');
      }

      // Obtener la imagen del canvas
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convertir a bytes PNG
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Error al convertir imagen a bytes');
      }

      // Guardar en la carpeta de Descargas
      final String filePath = await _saveImageToDownloads(
        byteData.buffer.asUint8List(),
        diagramName,
        'png',
      );

      return filePath;
    } catch (e) {
      throw Exception('Error al exportar PNG: $e');
    }
  }

  /// Exporta el diagrama como imagen JPG usando un GlobalKey
  static Future<String> exportDiagramToJPG({
    required GlobalKey canvasKey,
    required String diagramName,
    int quality = 85,
  }) async {
    try {
      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Permisos de almacenamiento denegados');
      }

      // Obtener la imagen del canvas
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convertir a bytes PNG primero
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Error al convertir imagen a bytes');
      }

      // Convertir PNG a JPG usando la librería image
      final img.Image? pngImage = img.decodePng(byteData.buffer.asUint8List());
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
      final List<int> jpgBytes = img.encodeJpg(jpgImage, quality: quality);

      // Guardar en la carpeta de Descargas
      final String filePath = await _saveImageToDownloads(
        Uint8List.fromList(jpgBytes),
        diagramName,
        'jpg',
      );

      return filePath;
    } catch (e) {
      throw Exception('Error al exportar JPG: $e');
    }
  }

  /// Guarda la imagen en la carpeta de Descargas
  static Future<String> _saveImageToDownloads(
    Uint8List imageBytes,
    String diagramName,
    String extension,
  ) async {
    try {
      // Obtener el directorio de Descargas
      Directory? downloadsDir = await _getDownloadsDirectory();

      if (downloadsDir == null) {
        throw Exception('No se pudo acceder a la carpeta de Descargas');
      }

      // Crear nombre de archivo único
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String cleanName = _sanitizeFileName(diagramName);
      final String fileName = '${cleanName}_$timestamp.$extension';

      // Crear el archivo
      final File file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error al guardar archivo: $e');
    }
  }

  /// Obtiene el directorio de Descargas
  static Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, intentar obtener el directorio de Descargas
      try {
        final Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Navegar al directorio de Descargas
          final String downloadsPath = '/storage/emulated/0/Download';
          final Directory downloadsDir = Directory(downloadsPath);

          if (await downloadsDir.exists()) {
            return downloadsDir;
          }

          // Si no existe, usar el directorio de documentos de la app
          return externalDir;
        }
      } catch (e) {
        print('Error accediendo a almacenamiento externo: $e');
      }

      // Fallback a directorio de documentos de la aplicación
      return await getApplicationDocumentsDirectory();
    } else {
      // Para otras plataformas, usar directorio de documentos
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }
  }

  /// Solicita permisos de almacenamiento
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Verificar versión de Android
      const int androidVersion = 30; // Android 11

      // Para Android 11+ (API 30+)
      if (androidVersion >= 30) {
        // En Android 11+, no necesitamos permisos especiales para escribir en Descargas
        // usando MediaStore API o SAF, pero para simplicidad usaremos el directorio de la app
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      } else {
        // Para versiones anteriores de Android
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }

    // Para otras plataformas (iOS, etc.)
    return true;
  }

  /// Limpia el nombre del archivo de caracteres no válidos
  static String _sanitizeFileName(String fileName) {
    // Reemplazar caracteres no válidos con guiones bajos
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Obtiene información sobre dónde se guardan los archivos
  static Future<String> getExportLocation() async {
    final Directory? dir = await _getDownloadsDirectory();
    if (dir != null) {
      return dir.path;
    }
    return 'Directorio de documentos de la aplicación';
  }
}
