import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';
import 'analytics_service.dart';
import 'crash_reporting_service.dart';
import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// NOTA DE SEGURIDAD
// - El caché se almacena en flutter_secure_storage (Android Keystore / iOS
//   Secure Enclave), no en SharedPreferences (texto plano).
// - En modo offline NUNCA se valida contraseña contra caché. Solo se permite
//   continuar la última sesión activa (UID ya conocido por Firebase).
// - Los métodos de administrador han sido eliminados del cliente. El rol admin
//   debe gestionarse exclusivamente desde Firebase Console o Cloud Functions.
//
// CREDENCIALES DE ADMIN (eliminadas del código activo):
// ─── Solo para referencia interna, NUNCA descomentarlas en producción ────────
// const _adminEmail    = 'admin@flowdiagram.com';   // ← MOVER a Firebase Console
// const _adminPassword = 'Admin123456';             // ← CAMBIAR antes de usar
// ─────────────────────────────────────────────────────────────────────────────

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analyticsService = AnalyticsService();
  final CrashReportingService _crashReportingService = CrashReportingService();

  // Almacenamiento seguro cifrado (Android Keystore / iOS Secure Enclave)
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  UserModel? _currentUser;

  // ── Estado ────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  UserModel? get currentUser => _currentUser;
  bool get isGuestUser => _currentUser?.isGuest ?? false;
  bool get isAuthenticated => _currentUser != null && !isGuestUser;

  // ── Conectividad ──────────────────────────────────────────────────────────

  Future<bool> _hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ── Caché seguro ──────────────────────────────────────────────────────────

  /// Guarda [user] en el almacén cifrado del dispositivo.
  /// Nunca almacena contraseña; solo datos de sesión (uid, email, rol, etc.).
  Future<void> _saveUserToCache(UserModel user) async {
    await _secureStorage.write(
      key: 'cached_user',
      value: jsonEncode(user.toMap()),
    );
  }

  Future<UserModel?> _loadUserFromCache() async {
    try {
      final data = await _secureStorage.read(key: 'cached_user');
      if (data != null) {
        return UserModel.fromMap(jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (_) {
      // Caché corrupto: lo limpiamos para no dejar basura
      await _clearUserCache();
    }
    return null;
  }

  Future<void> _clearUserCache() async {
    await _secureStorage.delete(key: 'cached_user');
  }

  // ── Inicialización ────────────────────────────────────────────────────────

  /// Llama esto en main.dart antes de mostrar la UI.
  /// Detecta si hay una sesión Firebase vigente y la restaura.
  /// Si no hay internet pero hay sesión guardada, permite continuar offline.
  Future<UserModel?> initialize() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      try {
        _currentUser = await _getUserFromFirestore(firebaseUser.uid);
        if (_currentUser != null) {
          await _saveUserToCache(_currentUser!);
          await _updateLastLogin(_currentUser!.uid);
          await _configureConsentServicesForCurrentUser();
        }
      } catch (_) {
        // Sin acceso a Firestore: restaurar desde caché cifrado
        _currentUser = await _loadUserFromCache();
        await _configureConsentServicesForCurrentUser();
      }
    } else {
      // Sin internet: restaurar desde caché cifrado
      _currentUser = await _loadUserFromCache();
      if (_currentUser != null) {
        await _configureConsentServicesForCurrentUser();
      }
    }
    return _currentUser;
  }

  // ── Modo invitado ─────────────────────────────────────────────────────────

  /// Crea una sesión local de invitado, sin tocar Firebase.
  /// El invitado tiene acceso completo al editor y compilador (offline).
  /// No se sincronizan datos con Firestore.
  Future<UserModel> signInAsGuest() async {
    _currentUser = UserModel.guest();
    // No guardamos en caché para que cada vez sea una sesión limpia.
    // Si deseas persistencia entre cierres, descomenta la siguiente línea:
    // await _saveUserToCache(_currentUser!);
    await _configureConsentServicesForCurrentUser();
    return _currentUser!;
  }

  // ── Login con email/contraseña ────────────────────────────────────────────

  /// Inicio de sesión online: verifica credenciales contra Firebase Auth.
  /// Solo funciona con conexión a internet. Para continuar offline usa
  /// [continueLastSession].
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
        'Sin conexión a internet. Si ya iniciaste sesión antes, '
        'usa "Continuar última sesión" para trabajar offline.',
      );
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Error al iniciar sesión');

      _currentUser = await _getUserFromFirestore(user.uid);
      if (_currentUser != null) {
        await _saveUserToCache(_currentUser!);
        await _updateLastLogin(_currentUser!.uid);
        await _configureConsentServicesForCurrentUser();
      }

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // ── Continuar última sesión (modo offline) ────────────────────────────────

  /// Permite al usuario registrado continuar trabajando sin internet usando
  /// la sesión guardada en el caché cifrado.
  ///
  /// Criterios de seguridad:
  /// • Solo funciona si existe un caché válido de una sesión previa.
  /// • No verifica contraseña (no hay forma segura de hacerlo offline).
  /// • El usuario obtiene acceso equivalente al de su última sesión online.
  /// • Al recuperar internet, Firebase Auth renueva el token automáticamente.
  Future<UserModel?> continueLastSession() async {
    final cachedUser = await _loadUserFromCache();
    if (cachedUser == null || cachedUser.isGuest) {
      throw Exception(
        'No hay sesión guardada. Conéctate a internet para iniciar sesión.',
      );
    }

    // Verificar que Firebase Auth todavía reconoce al usuario localmente
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      // Token expirado: necesita login online para renovarlo
      await _clearUserCache();
      throw Exception(
        'La sesión expiró. Conéctate a internet para iniciar sesión nuevamente.',
      );
    }

    // Validar que el caché corresponde al mismo usuario de Firebase
    if (firebaseUser.uid != cachedUser.uid) {
      await _clearUserCache();
      throw Exception(
        'Los datos de sesión no coinciden. Inicia sesión nuevamente.',
      );
    }

    _currentUser = cachedUser;
    await _configureConsentServicesForCurrentUser();
    return _currentUser;
  }

  /// Indica si existe una sesión guardada para mostrar el botón
  /// "Continuar última sesión" en la pantalla de login.
  Future<bool> hasLastSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return false;
    final cached = await _loadUserFromCache();
    return cached != null && !cached.isGuest && cached.uid == firebaseUser.uid;
  }

  // ── Registro ──────────────────────────────────────────────────────────────

  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    bool telemetryOptIn = false,
    bool crashReportsOptIn = false,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'Se requiere conexión a internet para registrar un nuevo usuario');
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Error al crear usuario');

      try {
        await user.updateDisplayName(displayName);
        await user.reload();
      } catch (_) {
        // No crítico: el nombre se guarda en Firestore de todas formas
      }

      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.user,
        createdAt: now,
        lastLogin: now,
        metrics: {
          'privacy_notice_accepted': true,
          'privacy_notice_accepted_at': now.toIso8601String(),
          'telemetry_opt_in': telemetryOptIn,
          'telemetry_updated_at': now.toIso8601String(),
          'crash_reports_opt_in': crashReportsOptIn,
          'crash_reports_updated_at': now.toIso8601String(),
        },
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      _currentUser = userModel;
      await _saveUserToCache(userModel);
      await _configureConsentServicesForCurrentUser();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Error al registrar usuario: ${e.toString()}');
    }
  }

  // ── Cerrar sesión ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    final hasInternet = await _hasInternetConnection();
    if (hasInternet) {
      try {
        await _auth.signOut();
      } catch (_) {}
    }
    _currentUser = null;
    await _clearUserCache();
    await _analyticsService.disableCollection();
    await _crashReportingService.disableCollection();
  }

  // ── Eliminar cuenta ───────────────────────────────────────────────────────

  /// Elimina la cuenta del usuario autenticado y todos sus datos.
  /// Requiere contraseña para re-autenticar (operación sensible).
  Future<void> deleteAccountAndAllData({
    required String password,
    Function(String)? onProgress,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'Se requiere conexión a internet para eliminar la cuenta');
    }

    final authUser = _auth.currentUser;
    if (authUser == null) throw Exception('No hay usuario autenticado');
    if (_currentUser?.isGuest == true) {
      throw Exception(
          'Los usuarios invitados no tienen cuenta que eliminar. Cierra sesión para salir.');
    }

    final email = authUser.email;
    if (email == null) {
      throw Exception('No se puede verificar el email del usuario');
    }

    try {
      onProgress?.call('Verificando credenciales...');
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await authUser.reauthenticateWithCredential(credential);

      onProgress?.call('Eliminando diagramas sincronizados...');
      try {
        final diagramsSnapshot = await _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('diagrams')
            .get();
        for (final doc in diagramsSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}

      onProgress?.call('Eliminando datos de usuario...');
      try {
        await _firestore.collection('users').doc(authUser.uid).delete();
      } catch (_) {}

      onProgress?.call('Eliminando métricas...');
      try {
        await _firestore.collection('user_metrics').doc(authUser.uid).delete();
      } catch (_) {}

      onProgress?.call('Eliminando cuenta de autenticación...');
      await authUser.delete();

      onProgress?.call('Limpiando datos locales...');
      _currentUser = null;
      await _clearUserCache();
      await _analyticsService.disableCollection();
      await _crashReportingService.disableCollection();

      onProgress?.call('Cuenta eliminada exitosamente');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception(
              'Contraseña incorrecta. Verifica e intenta de nuevo.');
        case 'requires-recent-login':
          throw Exception(
              'Por seguridad, cierra sesión e inicia sesión nuevamente antes de eliminar tu cuenta.');
        case 'too-many-requests':
          throw Exception(
              'Demasiados intentos. Espera un momento e intenta de nuevo.');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Error al eliminar cuenta: ${e.toString()}');
    }
  }

  // ── Métricas de usuario ───────────────────────────────────────────────────

  Future<void> updateUserMetrics(
      String uid, Map<String, dynamic> metrics) async {
    final hasInternet = await _hasInternetConnection();

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(metrics: metrics);
      await _saveUserToCache(_currentUser!);
      await _configureConsentServicesForCurrentUser();
    }

    if (hasInternet && _currentUser != null && !_currentUser!.isGuest) {
      try {
        await _firestore
            .collection('users')
            .doc(uid)
            .update({'metrics': metrics});
      } catch (_) {
        // Fallo silencioso: ya actualizamos el caché local arriba
      }
    }
  }

  // ── Sincronización ────────────────────────────────────────────────────────

  Future<UserModel?> syncAuthUserWithFirestore() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet para sincronizar');
    }

    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('No hay usuario autenticado en Firebase');
    }

    try {
      final firestoreUser = await _getUserFromFirestore(authUser.uid);
      if (firestoreUser != null) {
        _currentUser = firestoreUser;
        await _saveUserToCache(firestoreUser);
        await _configureConsentServicesForCurrentUser();
        return firestoreUser;
      }

      // Crear documento si no existe (registro incompleto previo)
      final now = DateTime.now();
      final userModel = UserModel(
        uid: authUser.uid,
        email: authUser.email ?? '',
        displayName: authUser.displayName ?? 'Usuario',
        role: UserRole.user,
        createdAt: now,
        lastLogin: now,
      );

      await _firestore
          .collection('users')
          .doc(authUser.uid)
          .set(userModel.toMap());
      _currentUser = userModel;
      await _saveUserToCache(userModel);
      await _configureConsentServicesForCurrentUser();
      return userModel;
    } catch (e) {
      throw Exception('Error al sincronizar usuario: ${e.toString()}');
    }
  }

  // ── Diagnóstico (solo desarrollo) ─────────────────────────────────────────

  Future<Map<String, dynamic>> diagnoseUserState() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) return {'error': 'Sin conexión a internet'};

    final authUser = _auth.currentUser;
    UserModel? firestoreUser;
    if (authUser != null) {
      try {
        firestoreUser = await _getUserFromFirestore(authUser.uid);
      } catch (_) {}
    }

    return {
      'internet': true,
      'has_firebase_session': authUser != null,
      'firebase_uid': authUser?.uid,
      'firebase_email': authUser?.email,
      'firestore_user_exists': firestoreUser != null,
      'current_user_role': _currentUser?.role.toString(),
      'is_guest': isGuestUser,
    };
  }

  // ── Privado: helpers ──────────────────────────────────────────────────────

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromSnapshot(doc);
    } catch (_) {}
    return null;
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  bool _isTelemetryOptIn(UserModel? user) =>
      user?.metrics['telemetry_opt_in'] == true;

  bool _isCrashReportsOptIn(UserModel? user) =>
      user?.metrics['crash_reports_opt_in'] == true;

  Future<void> _configureConsentServicesForCurrentUser() async {
    if (_currentUser == null) {
      await _analyticsService.disableCollection();
      await _crashReportingService.disableCollection();
      return;
    }
    await _analyticsService.configureCollection(
      telemetryOptIn: _isTelemetryOptIn(_currentUser),
      isGuest: _currentUser!.isGuest,
    );
    await _crashReportingService.configureCollection(
      crashReportsOptIn: _isCrashReportsOptIn(_currentUser),
      isGuest: _currentUser!.isGuest,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'email-already-in-use':
        return 'El correo ya está registrado. Intenta iniciar sesión.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado.';
      case 'network-request-failed':
        return 'Error de red. Verifica tu conexión a internet.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}