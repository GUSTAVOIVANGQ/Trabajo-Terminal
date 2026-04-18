import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/sync_service.dart';
import '../services/database_service.dart';
import '../services/auto_save_settings_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'metrics_screen.dart';
import 'admin_metrics_screen.dart';
import 'theme_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  final DatabaseService _databaseService = DatabaseService();
  final AutoSaveSettingsService _autoSaveSettingsService =
      AutoSaveSettingsService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSyncing = false;
  bool _isDeleting = false;
  bool _isPickingImage = false;
  String? _profileImagePath;
  bool _autoSaveEnabled = false;
  bool _updatingAutoSavePreference = false;
  bool _telemetryConsent = false;
  bool _updatingTelemetryConsent = false;
  bool _crashReportsConsent = false;
  bool _updatingCrashReportsConsent = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadAutoSavePreference();
    _loadTelemetryConsent();
    _loadCrashReportsConsent();
  }

  Future<void> _loadAutoSavePreference() async {
    final userId = _authService.currentUser?.uid;
    final enabled =
        await _autoSaveSettingsService.isAutoSaveEnabled(userId: userId);

    if (!mounted) return;

    setState(() {
      _autoSaveEnabled = enabled;
    });
  }

  Future<void> _updateAutoSavePreference(bool enabled) async {
    if (_updatingAutoSavePreference) return;

    final userId = _authService.currentUser?.uid;
    final previousValue = _autoSaveEnabled;

    setState(() {
      _updatingAutoSavePreference = true;
      _autoSaveEnabled = enabled;
    });

    try {
      await _autoSaveSettingsService.setAutoSaveEnabled(
        enabled,
        userId: userId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Autoguardado activado (cada 2 segundos)'
                  : 'Autoguardado desactivado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _autoSaveEnabled = previousValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo actualizar el autoguardado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingAutoSavePreference = false;
        });
      }
    }
  }

  void _loadTelemetryConsent() {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) {
      _telemetryConsent = false;
      return;
    }

    _telemetryConsent = user.metrics['telemetry_opt_in'] == true;
  }

  void _loadCrashReportsConsent() {
    final user = _authService.currentUser;
    if (user == null || user.isGuest) {
      _crashReportsConsent = false;
      return;
    }

    _crashReportsConsent = user.metrics['crash_reports_opt_in'] == true;
  }

  Future<void> _updateTelemetryConsent(bool enabled) async {
    if (_updatingTelemetryConsent) return;

    final user = _authService.currentUser;
    if (user == null || user.isGuest) return;

    final previousValue = _telemetryConsent;

    setState(() {
      _updatingTelemetryConsent = true;
      _telemetryConsent = enabled;
    });

    try {
      final updatedMetrics = Map<String, dynamic>.from(user.metrics);
      updatedMetrics['telemetry_opt_in'] = enabled;
      updatedMetrics['telemetry_updated_at'] = DateTime.now().toIso8601String();

      await _authService.updateUserMetrics(user.uid, updatedMetrics);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Telemetría de uso activada'
                  : 'Telemetría de uso desactivada',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _telemetryConsent = previousValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo actualizar el consentimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingTelemetryConsent = false;
        });
      }
    }
  }

  Future<void> _updateCrashReportsConsent(bool enabled) async {
    if (_updatingCrashReportsConsent) return;

    final user = _authService.currentUser;
    if (user == null || user.isGuest) return;

    final previousValue = _crashReportsConsent;

    setState(() {
      _updatingCrashReportsConsent = true;
      _crashReportsConsent = enabled;
    });

    try {
      final updatedMetrics = Map<String, dynamic>.from(user.metrics);
      updatedMetrics['crash_reports_opt_in'] = enabled;
      updatedMetrics['crash_reports_updated_at'] =
          DateTime.now().toIso8601String();

      await _authService.updateUserMetrics(user.uid, updatedMetrics);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Reporte de fallos activado'
                  : 'Reporte de fallos desactivado',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _crashReportsConsent = previousValue;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo actualizar el consentimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingCrashReportsConsent = false;
        });
      }
    }
  }

  String _getProfileImageStorageKey(UserModel user) {
    return 'profile_image_path_${user.uid}';
  }

  Future<void> _loadProfileImage() async {
    final user = _authService.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final storageKey = _getProfileImageStorageKey(user);
    final savedPath = prefs.getString(storageKey);

    if (savedPath == null) return;

    final savedFile = File(savedPath);
    if (!await savedFile.exists()) {
      await prefs.remove(storageKey);
      return;
    }

    if (mounted) {
      setState(() {
        _profileImagePath = savedPath;
      });
    }
  }

  Future<String> _copyImageToLocalStorage(
      String sourcePath, UserModel user) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final profileImagesDirectory = Directory(
      p.join(appDirectory.path, 'profile_images'),
    );

    if (!await profileImagesDirectory.exists()) {
      await profileImagesDirectory.create(recursive: true);
    }

    final extension =
        p.extension(sourcePath).isNotEmpty ? p.extension(sourcePath) : '.jpg';
    final targetPath = p.join(
      profileImagesDirectory.path,
      '${user.uid}_avatar$extension',
    );

    final copiedFile = await File(sourcePath).copy(targetPath);
    return copiedFile.path;
  }

  Future<void> _pickAndSaveProfileImage() async {
    if (_isPickingImage) return;

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isPickingImage = true);

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFile == null) return;

      final localImagePath = await _copyImageToLocalStorage(
        pickedFile.path,
        user,
      );

      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getProfileImageStorageKey(user);
      final previousImagePath = prefs.getString(storageKey);
      await prefs.setString(storageKey, localImagePath);

      if (previousImagePath != null && previousImagePath != localImagePath) {
        final previousFile = File(previousImagePath);
        if (await previousFile.exists()) {
          await previousFile.delete();
        }
      }

      if (mounted) {
        setState(() {
          _profileImagePath = localImagePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada localmente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo actualizar la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _resetProfileImage() async {
    if (_isPickingImage || _profileImagePath == null) return;

    final user = _authService.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer foto de perfil'),
        content: const Text(
          'Se eliminará la foto local y volverás a ver la inicial del usuario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isPickingImage = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = _getProfileImageStorageKey(user);
      final savedPath = prefs.getString(storageKey) ?? _profileImagePath;
      await prefs.remove(storageKey);

      if (savedPath != null) {
        final savedFile = File(savedPath);
        if (await savedFile.exists()) {
          await savedFile.delete();
        }
      }

      if (mounted) {
        setState(() {
          _profileImagePath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil restablecida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo restablecer la foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Muestra opciones de sincronización
  void _showSyncOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Opciones de Sincronización',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.blue),
                title: const Text('Sincronización inteligente'),
                subtitle:
                    const Text('Sincroniza cambios (los más recientes ganan)'),
                onTap: () {
                  Navigator.pop(context);
                  _performSync();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload, color: Colors.green),
                title: const Text('Subir todo a la nube'),
                subtitle: const Text(
                    'Sobrescribe los datos en la nube con los locales'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadAll();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download, color: Colors.orange),
                title: const Text('Descargar todo de la nube'),
                subtitle: const Text(
                    'Sobrescribe los datos locales con los de la nube'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadAll();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ejecuta sincronización inteligente
  Future<void> _performSync() async {
    setState(() => _isSyncing = true);

    try {
      final result = await _syncService.syncDiagrams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '✓ Sincronización completada: ${result.uploaded} subidos, ${result.downloaded} descargados'
                  : '⚠ Sincronización parcial: ${result.errors.join(", ")}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// Sube todos los diagramas a la nube
  Future<void> _uploadAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir a la nube'),
        content: const Text(
          '¿Estás seguro? Esto sobrescribirá los diagramas en la nube con tus diagramas locales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Subir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSyncing = true);

    try {
      final result = await _syncService.uploadAllDiagrams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '✓ ${result.uploaded} diagramas subidos a la nube'
                  : '⚠ Error: ${result.errors.join(", ")}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// Descarga todos los diagramas de la nube
  Future<void> _downloadAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descargar de la nube'),
        content: const Text(
          '¿Estás seguro? Esto eliminará tus diagramas locales y los reemplazará con los de la nube.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descargar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSyncing = true);

    try {
      final result = await _syncService.downloadAllDiagrams();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? '✓ ${result.downloaded} diagramas descargados de la nube'
                  : '⚠ Error: ${result.errors.join(", ")}',
            ),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// Muestra diálogo para eliminar cuenta
  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    String? errorMessage;
    String progressMessage = '';
    bool isProcessing = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
              const SizedBox(width: 8),
              const Text('Eliminar cuenta'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Esta acción es IRREVERSIBLE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Se eliminarán permanentemente:\n'
                  '• Tu cuenta de usuario\n'
                  '• Todos tus diagramas sincronizados\n'
                  '• Tus métricas y progreso\n'
                  '• Todos los datos asociados',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isProcessing,
                  decoration: InputDecoration(
                    labelText: 'Confirma tu contraseña',
                    hintText: 'Ingresa tu contraseña actual',
                    border: const OutlineInputBorder(),
                    errorText: errorMessage,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                if (progressMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          progressMessage,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  isProcessing ? null : () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: isProcessing
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'Ingresa tu contraseña';
                        });
                        return;
                      }

                      setDialogState(() {
                        isProcessing = true;
                        errorMessage = null;
                        progressMessage = 'Iniciando...';
                      });

                      try {
                        await _authService.deleteAccountAndAllData(
                          password: passwordController.text,
                          onProgress: (message) {
                            if (context.mounted) {
                              setDialogState(() {
                                progressMessage = message;
                              });
                            }
                          },
                        );

                        // Eliminar datos locales también
                        final userId = _authService.currentUser?.uid;
                        if (userId != null) {
                          await _databaseService.deleteDiagramsByUser(userId);
                        }

                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setDialogState(() {
                            isProcessing = false;
                            progressMessage = '';
                            errorMessage =
                                e.toString().replaceAll('Exception: ', '');
                          });
                        }
                      }
                    },
              child: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Eliminar cuenta'),
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();

    if (confirmed == true && mounted) {
      // Cuenta eliminada exitosamente, redirigir a login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu cuenta ha sido eliminada'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Elimina datos locales para usuarios invitados
  Future<void> _deleteGuestData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar datos locales'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todos tus diagramas guardados localmente?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userId = user.isGuest ? 'guest_${user.uid}' : user.uid;
        await _databaseService.deleteDiagramsByUser(userId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Datos locales eliminados'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar y información básica
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap:
                            _isPickingImage ? null : _pickAndSaveProfileImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              user.isAdmin ? Colors.purple : Colors.blue,
                          foregroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : null,
                          child: _profileImagePath == null
                              ? Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Material(
                          color: Theme.of(context).colorScheme.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _isPickingImage
                                ? null
                                : _pickAndSaveProfileImage,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _isPickingImage
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.photo_camera,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cambiar foto',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_profileImagePath != null) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _isPickingImage ? null : _resetProfileImage,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restablecer foto'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: user.isAdmin
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user.isAdmin
                            ? Colors.purple.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      user.isAdmin ? 'Administrador' : 'Usuario',
                      style: TextStyle(
                        color: user.isAdmin
                            ? Colors.purple[700]
                            : Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Información detallada
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard(
                    title: 'Información de la cuenta',
                    items: [
                      _buildInfoItem(
                        icon: Icons.email_outlined,
                        label: 'Correo electrónico',
                        value: user.email,
                      ),
                      _buildInfoItem(
                        icon: Icons.person_outline,
                        label: 'Nombre',
                        value: user.displayName,
                      ),
                      _buildInfoItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Tipo de cuenta',
                        value: user.isAdmin ? 'Administrador' : 'Usuario',
                      ),
                      _buildInfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha de registro',
                        value: DateFormat('dd/MM/yyyy').format(user.createdAt),
                      ),
                      _buildInfoItem(
                        icon: Icons.access_time_outlined,
                        label: 'Último acceso',
                        value: DateFormat('dd/MM/yyyy HH:mm')
                            .format(user.lastLogin),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón para ver métricas personales
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.analytics_outlined),
                      title: const Text('Mis Métricas'),
                      subtitle:
                          const Text('Ver estadísticas de uso y progreso'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MetricsScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Métricas resumidas (si existen)
                  if (user.metrics.isNotEmpty)
                    _buildInfoCard(
                      title: 'Resumen de actividad',
                      items: [
                        if (user.metrics['diagramas_creados'] != null)
                          _buildInfoItem(
                            icon: Icons.account_tree,
                            label: 'Diagramas creados',
                            value: user.metrics['diagramas_creados'].toString(),
                          ),
                        if (user.metrics['codigo_generado'] != null)
                          _buildInfoItem(
                            icon: Icons.code,
                            label: 'Código generado',
                            value: user.metrics['codigo_generado'].toString(),
                          ),
                        if (user.metrics['total_validaciones'] != null)
                          _buildInfoItem(
                            icon: Icons.check_circle,
                            label: 'Validaciones realizadas',
                            value:
                                user.metrics['total_validaciones'].toString(),
                          ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Opciones administrativas
                  if (user.isAdmin) ...[
                    Card(
                      color: Colors.purple.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.admin_panel_settings,
                            color: Colors.purple),
                        title: const Text('Panel de Administración'),
                        subtitle: const Text(
                            'Ver métricas globales y gestionar usuarios'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AdminMetricsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Configuración de tema
                  _buildInfoCard(
                    title: 'Configuración de la aplicación',
                    items: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: const Text('Tema'),
                        subtitle: Text(ThemeService().getThemeName()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ThemeSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        secondary: const Icon(Icons.save_as_outlined),
                        title: const Text(
                            'Autoguardado de diagramas (2 segundos)'),
                        subtitle: Text(
                          _updatingAutoSavePreference
                              ? 'Guardando preferencia...'
                              : 'Guarda automáticamente los cambios en el editor cada 2 segundos.',
                        ),
                        value: _autoSaveEnabled,
                        onChanged: _updatingAutoSavePreference
                            ? null
                            : _updateAutoSavePreference,
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        secondary: const Icon(Icons.analytics_outlined),
                        title: const Text('Permitir telemetría de uso'),
                        subtitle: Text(
                          user.isGuest
                              ? 'No disponible en modo invitado'
                              : (_updatingTelemetryConsent
                                  ? 'Guardando cambios...'
                                  : 'Puedes cambiar este consentimiento en cualquier momento'),
                        ),
                        value: user.isGuest ? false : _telemetryConsent,
                        onChanged: user.isGuest || _updatingTelemetryConsent
                            ? null
                            : _updateTelemetryConsent,
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        secondary: const Icon(Icons.bug_report_outlined),
                        title: const Text(
                            'Permitir reportes de fallos (Crash Report)'),
                        subtitle: Text(
                          user.isGuest
                              ? 'No disponible en modo invitado'
                              : (_updatingCrashReportsConsent
                                  ? 'Guardando cambios...'
                                  : 'Envía errores técnicos para diagnóstico'),
                        ),
                        value: user.isGuest ? false : _crashReportsConsent,
                        onChanged: user.isGuest || _updatingCrashReportsConsent
                            ? null
                            : _updateCrashReportsConsent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sección de Sincronización y Gestión de Datos
                  _buildInfoCard(
                    title: 'Sincronización y datos',
                    items: [
                      // Botón de sincronización
                      ListTile(
                        leading: _isSyncing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_sync, color: Colors.blue),
                        title: const Text('Sincronizar con la nube'),
                        subtitle: Text(
                          user.isGuest
                              ? 'No disponible para usuarios invitados'
                              : 'Sincroniza tus diagramas con Firebase',
                        ),
                        trailing: user.isGuest
                            ? const Icon(Icons.lock_outline, color: Colors.grey)
                            : const Icon(Icons.chevron_right),
                        enabled: !user.isGuest && !_isSyncing,
                        onTap: user.isGuest ? null : _showSyncOptions,
                      ),
                      const Divider(),
                      // Botón de eliminar cuenta
                      ListTile(
                        leading: _isDeleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.delete_forever,
                                color: Colors.red),
                        title: Text(
                          user.isGuest
                              ? 'Eliminar datos locales'
                              : 'Eliminar cuenta',
                          style: const TextStyle(color: Colors.red),
                        ),
                        subtitle: Text(
                          user.isGuest
                              ? 'Elimina todos los diagramas guardados localmente'
                              : 'Elimina tu cuenta y todos los datos asociados',
                        ),
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.red),
                        enabled: !_isDeleting,
                        onTap: user.isGuest
                            ? _deleteGuestData
                            : _showDeleteAccountDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón de cerrar sesión
                  Card(
                    color: Colors.red.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Cerrar Sesión'),
                      subtitle: const Text('Salir de la aplicación'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _signOut,
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

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
