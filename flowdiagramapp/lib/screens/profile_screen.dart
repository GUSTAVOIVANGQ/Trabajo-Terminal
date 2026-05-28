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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

  final GlobalKey _avatarKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _syncKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadAutoSavePreference();
    _loadTelemetryConsent();
    _loadCrashReportsConsent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeProfile();
    });
  }

  Future<void> _checkFirstTimeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('tutorial_shown_profile') ?? false;
    if (!hasShown && mounted) {
      await prefs.setBool('tutorial_shown_profile', true);
      _showProfileTour();
    }
  }

  void _showProfileTour() {
    List<TargetFocus> targets = [];
    
    targets.add(TargetFocus(
      identify: "avatar",
      keyTarget: _avatarKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Personaliza tu perfil", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Aquí puedes ver tu información básica y cambiar tu foto de perfil tocando el ícono de cámara.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "settings",
      keyTarget: _settingsKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Configuración de la app", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Ajusta el tema, autoguardado y permisos.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    targets.add(TargetFocus(
      identify: "sync",
      keyTarget: _syncKey,
      shape: ShapeLightFocus.RRect,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Sincronización y datos", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Respalda tus diagramas en la nube.", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            );
          },
        )
      ],
    ));

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "SALTAR",
      paddingFocus: 10,
      opacityShadow: 0.8,
    ).show(context: context);
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

  void _showSubscriptionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Suscripción Pro',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.star_border, color: Colors.blue),
                title: const Text('Gratuita'),
                subtitle: const Text('Funciones básicas'),
                trailing: const Icon(Icons.check, color: Colors.green),
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.purple),
                title: const Text('Premium Mensual'),
                subtitle: const Text('\$49 MXN / mes'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonToast('Suscripción Mensual');
                },
              ),
              ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.orange),
                title: const Text('Premium Anual'),
                subtitle: const Text('\$499 MXN / año'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonToast('Suscripción Anual');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonToast(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${feature}: Próximamente'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const LoginScreen();
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2), Color(0xFF4CA1AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (_settingsKey.currentContext != null) {
                Scrollable.ensureVisible(_settingsKey.currentContext!, duration: const Duration(milliseconds: 500));
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                // Tarjeta de perfil con avatar superpuesto
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 50),
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            user.displayName.isEmpty ? 'Usuario' : user.displayName,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${user.email.split("@")[0]}',
                            style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Imagen de perfil circular sobresaliendo arriba
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 4),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: _isPickingImage ? null : _pickAndSaveProfileImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: user.isAdmin ? Colors.purple : Colors.blue,
                              foregroundImage: _profileImagePath != null
                                  ? FileImage(File(_profileImagePath!))
                                  : null,
                              child: _profileImagePath == null
                                  ? Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName.substring(0, 1).toUpperCase()
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
                            right: -4,
                            bottom: -4,
                            child: Material(
                              color: Theme.of(context).primaryColor,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _isPickingImage ? null : _pickAndSaveProfileImage,
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
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildGradientButton(
                  text: 'Editar Perfil',
                  colors: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
                  onTap: () => _showComingSoonToast('Editar Perfil'),
                ),
                const SizedBox(height: 12),
                _buildGradientButton(
                  text: 'Suscripción',
                  colors: [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
                  onTap: _showSubscriptionModal,
                ),

                const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Información de la cuenta',
                  children: [
                    _buildListTile(icon: Icons.email_outlined, title: user.email, subtitle: 'Correo electrónico'),
                    _buildListTile(icon: Icons.admin_panel_settings_outlined, title: user.isAdmin ? 'Administrador' : 'Usuario', subtitle: 'Tipo de cuenta'),
                    _buildListTile(icon: Icons.calendar_today_outlined, title: DateFormat("dd/MM/yyyy").format(user.createdAt), subtitle: 'Fecha de registro'),
                    _buildListTile(icon: Icons.access_time_outlined, title: DateFormat("dd/MM/yyyy HH:mm").format(user.lastLogin), subtitle: 'Último acceso'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Mis Métricas',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.analytics_outlined),
                      title: const Text('Ver estadísticas de uso y progreso'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MetricsScreen()));
                      },
                    ),
                    if (user.metrics.isNotEmpty) ...[
                      const Divider(height: 1),
                      if (user.metrics.containsKey("diagramas_creados"))
                        _buildListTile(icon: Icons.account_tree, title: user.metrics["diagramas_creados"].toString(), subtitle: 'Diagramas creados'),
                      if (user.metrics.containsKey("codigo_generado"))
                        _buildListTile(icon: Icons.code, title: user.metrics["codigo_generado"].toString(), subtitle: 'Código generado'),
                      if (user.metrics.containsKey("total_validaciones"))
                        _buildListTile(icon: Icons.check_circle, title: user.metrics["total_validaciones"].toString(), subtitle: 'Validaciones realizadas'),
                    ]
                  ],
                ),

                _buildSectionCard(
                  title: 'Estado de suscripción',
                  children: [
                    _buildListTile(icon: Icons.workspace_premium_outlined, title: 'Plan Gratuito', subtitle: 'Actualiza para obtener más funciones'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Seguridad',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Cambiar contraseña, sesiones'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoonToast('Seguridad'),
                    ),
                  ],
                ),

                _buildSectionCard(
                  title: 'Cuentas conectadas',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.link_outlined),
                      title: Row(
                        children: [
                          _buildIconBadge(Icons.code, isDark ? Colors.white : Colors.black),
                          const SizedBox(width: 8),
                          _buildIconBadge(Icons.brush, Colors.blue),
                          const SizedBox(width: 8),
                          _buildIconBadge(Icons.g_mobiledata, Colors.red),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoonToast('Cuentas conectadas'),
                    ),
                  ],
                ),

                _buildSectionCard(
                  key: _settingsKey,
                  title: 'Configuración general',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Tema'),
                      subtitle: Text(ThemeService().getThemeName()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.save_as_outlined),
                      title: const Text('Autoguardado (2s)'),
                      subtitle: Text(_updatingAutoSavePreference ? 'Guardando...' : 'Guarda cambios automáticamente'),
                      value: _autoSaveEnabled,
                      onChanged: _updatingAutoSavePreference ? null : _updateAutoSavePreference,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.analytics_outlined),
                      title: const Text('Telemetría de uso'),
                      value: user.isGuest ? false : _telemetryConsent,
                      onChanged: user.isGuest || _updatingTelemetryConsent ? null : _updateTelemetryConsent,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      secondary: const Icon(Icons.bug_report_outlined),
                      title: const Text('Reportes de fallos'),
                      value: user.isGuest ? false : _crashReportsConsent,
                      onChanged: user.isGuest || _updatingCrashReportsConsent ? null : _updateCrashReportsConsent,
                    ),
                  ],
                ),

                _buildSectionCard(
                  key: _syncKey,
                  title: 'Datos',
                  children: [
                    ListTile(
                      leading: _isSyncing
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_sync, color: Colors.blue),
                      title: const Text('Sincronizar datos'),
                      subtitle: Text(user.isGuest ? 'No disponible para invitados' : 'Respalda tus diagramas en la nube'),
                      trailing: user.isGuest ? const Icon(Icons.lock_outline, color: Colors.grey) : const Icon(Icons.chevron_right),
                      enabled: !user.isGuest && !_isSyncing,
                      onTap: user.isGuest ? null : _performSync,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: _isDeleting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                          : const Icon(Icons.delete_forever, color: Colors.red),
                      title: Text(user.isGuest ? 'Eliminar datos locales' : 'Eliminar cuenta', style: const TextStyle(color: Colors.red)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      enabled: !_isDeleting,
                      onTap: user.isGuest ? _deleteGuestData : _showDeleteAccountDialog,
                    ),
                  ],
                ),

                if (user.isAdmin) ...[
                  _buildSectionCard(
                    title: 'Administración',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                        title: const Text('Panel de Administración'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AdminMetricsScreen()));
                        },
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                _buildGradientButton(
                  text: 'Cerrar Sesión',
                  colors: [Colors.red.shade400, Colors.red.shade700],
                  onTap: _signOut,
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required List<Color> colors, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children, Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required String subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[700]),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}