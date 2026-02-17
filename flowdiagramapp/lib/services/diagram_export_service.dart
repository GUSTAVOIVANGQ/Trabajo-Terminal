import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

class DiagramExportService {
  // Cache para la versión de Android SDK
  static int? _androidSdkVersion;

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

  /// Exporta el diagrama como imagen PNG usando un GlobalKey
  static Future<String> exportDiagramToPNG({
    required GlobalKey canvasKey,
    required String diagramName,
  }) async {
    try {
      // Solicitar permisos de almacenamiento
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception(
            'Permisos de almacenamiento denegados. Por favor, habilita los permisos en Configuración de la app.');
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

      final Uint8List pngBytes = byteData.buffer.asUint8List();

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
        throw Exception(
            'Permisos de almacenamiento denegados. Por favor, habilita los permisos en Configuración de la app.');
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
      // Incluso si se deniega, SaverGallery puede funcionar en algunos casos
      return result.isGranted || result.isLimited || result.isDenied;
    }
    // Android 10-12 (API 29-32): No necesita permisos para escribir en MediaStore
    else if (sdkVersion >= 29) {
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
      return 'Galería de fotos > FlowDiagramApp\n(También visible en: Archivos > Pictures > FlowDiagramApp)';
    }
    return 'Carpeta de documentos de la aplicación';
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
