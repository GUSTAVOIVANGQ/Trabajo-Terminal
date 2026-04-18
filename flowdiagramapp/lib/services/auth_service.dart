import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';
import 'analytics_service.dart';
import 'crash_reporting_service.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analyticsService = AnalyticsService();
  final CrashReportingService _crashReportingService = CrashReportingService();
  UserModel? _currentUser;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  UserModel? get currentUser => _currentUser;

  // Verificar conexión a internet
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Guardar usuario en cache local
  Future<void> _saveUserToCache(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_user', jsonEncode(user.toMap()));
  }

  // Cargar usuario desde cache local
  Future<UserModel?> _loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUserString = prefs.getString('cached_user');
    if (cachedUserString != null) {
      final userMap = jsonDecode(cachedUserString) as Map<String, dynamic>;
      return UserModel.fromMap(userMap);
    }
    return null;
  }

  // Limpiar cache de usuario
  Future<void> _clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
  }

  // Inicializar el servicio de autenticación
  Future<UserModel?> initialize() async {
    // COMENTADO: Autenticación automática deshabilitada para permitir modo invitado
    // El usuario debe iniciar sesión manualmente o continuar como invitado

    /*
    final hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      // Si hay internet, verificar usuario autenticado en Firebase
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        try {
          _currentUser = await _getUserFromFirestore(firebaseUser.uid);
          if (_currentUser != null) {
            await _saveUserToCache(_currentUser!);
            // Actualizar último login
            await _updateLastLogin(_currentUser!.uid);
          }
        } catch (e) {
          // Si hay error con Firestore, usar cache local
          _currentUser = await _loadUserFromCache();
        }
      }
    } else {
      // Sin internet, usar cache local
      _currentUser = await _loadUserFromCache();
    }
    */

    return _currentUser;
  }

  // Continuar como invitado (sin conexión requerida)
  Future<UserModel> signInAsGuest() async {
    _currentUser = UserModel.guest();
    await _saveUserToCache(_currentUser!);
    await _configureConsentServicesForCurrentUser();
    return _currentUser!;
  }

  // Verificar si el usuario actual es invitado
  bool get isGuestUser => _currentUser?.isGuest ?? false;

  bool _isTelemetryOptIn(UserModel? user) {
    if (user == null) return false;
    final value = user.metrics['telemetry_opt_in'];
    return value == true;
  }

  bool _isCrashReportsOptIn(UserModel? user) {
    if (user == null) return false;
    final value = user.metrics['crash_reports_opt_in'];
    return value == true;
  }

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

  // Registro de usuario
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
    bool telemetryOptIn = false,
    bool crashReportsOptIn = false,
  }) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'Se requiere conexión a internet para registrar un nuevo usuario');
    }

    try {
      // Primero verificar si el email ya existe en Firestore
      final emailExists = await checkIfEmailExists(email);
      if (emailExists) {
        throw Exception(
            'El email ya está registrado. Intenta iniciar sesión en su lugar.');
      }

      // Crear usuario en Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Error al crear usuario');

      // Actualizar el perfil del usuario de forma más robusta
      try {
        await user.updateDisplayName(displayName);
        // Forzar recarga para asegurar que los cambios se apliquen
        await user.reload();
      } catch (e) {
        print(
            'Advertencia: No se pudo actualizar el displayName en Firebase Auth: $e');
        // Continuamos ya que el nombre se guardará en Firestore de todas formas
      }

      // Crear el documento del usuario en Firestore
      final now = DateTime.now();
      final initialMetrics = <String, dynamic>{
        'privacy_notice_accepted': true,
        'privacy_notice_accepted_at': now.toIso8601String(),
        'telemetry_opt_in': telemetryOptIn,
        'telemetry_updated_at': now.toIso8601String(),
        'crash_reports_opt_in': crashReportsOptIn,
        'crash_reports_updated_at': now.toIso8601String(),
      };

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName, // Usar el displayName que nos pasaron
        role: role,
        createdAt: now,
        lastLogin: now,
        metrics: initialMetrics,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      _currentUser = userModel;
      await _saveUserToCache(userModel);
      await _configureConsentServicesForCurrentUser();

      return userModel;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'El email ya está registrado. Intenta iniciar sesión en su lugar.';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del email no es válido.';
          break;
        case 'weak-password':
          errorMessage =
              'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'El registro con email/contraseña no está habilitado.';
          break;
        default:
          errorMessage = 'Error al registrar usuario: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow; // Re-lanzar excepciones personalizadas
      }
      throw Exception('Error al registrar usuario: ${e.toString()}');
    }
  }

  // Inicio de sesión
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final hasInternet = await _hasInternetConnection();

    if (hasInternet) {
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
      } catch (e) {
        throw Exception('Error al iniciar sesión: ${e.toString()}');
      }
    } else {
      // Modo offline: verificar con cache local
      final cachedUser = await _loadUserFromCache();
      if (cachedUser != null && cachedUser.email == email) {
        _currentUser = cachedUser;
        await _configureConsentServicesForCurrentUser();
        return _currentUser;
      } else {
        throw Exception(
            'Sin conexión a internet. No se puede verificar las credenciales.');
      }
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    final hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      await _auth.signOut();
    }

    _currentUser = null;
    await _clearUserCache();
    await _analyticsService.disableCollection();
    await _crashReportingService.disableCollection();
  }

  // Obtener usuario desde Firestore
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
    } catch (e) {
      print('Error obteniendo usuario de Firestore: $e');
    }
    return null;
  }

  // Actualizar último login
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error actualizando último login: $e');
    }
  }

  // Obtener todos los usuarios (solo para administradores)
  Future<List<UserModel>> getAllUsers() async {
    if (_currentUser?.role != UserRole.admin) {
      throw Exception(
          'Acceso denegado: Solo administradores pueden ver todos los usuarios');
    }

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception(
          'Se requiere conexión a internet para obtener la lista de usuarios');
    }

    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Error obteniendo usuarios: ${e.toString()}');
    }
  }

  // Actualizar métricas del usuario
  Future<void> updateUserMetrics(
      String uid, Map<String, dynamic> metrics) async {
    final hasInternet = await _hasInternetConnection();

    if (hasInternet && _currentUser != null && !_currentUser!.isGuest) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'metrics': metrics,
        });

        // Actualizar usuario en cache
        _currentUser = _currentUser!.copyWith(metrics: metrics);
        await _saveUserToCache(_currentUser!);
        await _configureConsentServicesForCurrentUser();
      } catch (e) {
        print('Error actualizando métricas: $e');
        // En caso de error, actualizar solo en cache local
        _currentUser = _currentUser!.copyWith(metrics: metrics);
        await _saveUserToCache(_currentUser!);
        await _configureConsentServicesForCurrentUser();
      }
    } else {
      // Sin internet, actualizar solo en cache local
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(metrics: metrics);
        await _saveUserToCache(_currentUser!);
        await _configureConsentServicesForCurrentUser();
      }
    }
  }

  // Verificar si el usuario actual es administrador
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Promover un usuario a administrador (solo para desarrollo/configuración inicial)
  Future<void> promoteToAdmin(String email) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet para promover usuarios');
    }

    try {
      // Buscar usuario por email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({'role': 'admin'});

        // Si es el usuario actual, actualizar en memoria
        if (_currentUser?.email == email) {
          _currentUser = _currentUser!.copyWith(role: UserRole.admin);
          await _saveUserToCache(_currentUser!);
        }

        print('✅ Usuario $email promovido a administrador');
      } else {
        throw Exception('Usuario con email $email no encontrado');
      }
    } catch (e) {
      throw Exception('Error promoviendo usuario: ${e.toString()}');
    }
  }

  // Crear usuario administrador por defecto
  Future<void> createDefaultAdmin() async {
    const adminEmail = 'admin@flowdiagram.com';
    const adminPassword = 'Admin123456';
    const adminName = 'Administrador';

    try {
      // Verificar si ya existe
      final exists = await checkIfEmailExists(adminEmail);
      if (exists) {
        print('ℹ️ Usuario administrador ya existe');
        return;
      }

      // Crear usuario administrador
      await registerWithEmailPassword(
        email: adminEmail,
        password: adminPassword,
        displayName: adminName,
        role: UserRole.admin,
      );

      print('✅ Usuario administrador creado: $adminEmail');
      print('🔑 Contraseña: $adminPassword');
    } catch (e) {
      print('❌ Error creando administrador: $e');
    }
  }

  // MÉTODOS DE DIAGNÓSTICO Y LIMPIEZA

  // Verificar el estado actual de Authentication vs Firestore
  Future<Map<String, dynamic>> diagnoseUserState() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return {
        'error': 'Sin conexión a internet',
        'internet': false,
      };
    }

    final authUser = _auth.currentUser;
    UserModel? firestoreUser;

    if (authUser != null) {
      try {
        firestoreUser = await _getUserFromFirestore(authUser.uid);
      } catch (e) {
        // Error al obtener desde Firestore
      }
    }

    return {
      'internet': true,
      'auth_user': authUser != null
          ? {
              'uid': authUser.uid,
              'email': authUser.email,
              'displayName': authUser.displayName,
            }
          : null,
      'firestore_user': firestoreUser?.toMap(),
      'current_user': _currentUser?.toMap(),
      'cache_user': (await _loadUserFromCache())?.toMap(),
    };
  }

  // Limpiar completamente el estado del usuario
  Future<void> forceSignOut() async {
    try {
      final hasInternet = await _hasInternetConnection();
      if (hasInternet && _auth.currentUser != null) {
        await _auth.signOut();
      }
    } catch (e) {
      print('Error al cerrar sesión en Firebase: $e');
    }

    _currentUser = null;
    await _clearUserCache();
    await _analyticsService.disableCollection();
    await _crashReportingService.disableCollection();
  }

  // Sincronizar usuario de Authentication con Firestore
  Future<UserModel?> syncAuthUserWithFirestore() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet para sincronizar');
    }

    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('No hay usuario autenticado en Firebase Authentication');
    }

    try {
      // Intentar obtener desde Firestore
      final firestoreUser = await _getUserFromFirestore(authUser.uid);
      if (firestoreUser != null) {
        _currentUser = firestoreUser;
        await _saveUserToCache(firestoreUser);
        await _configureConsentServicesForCurrentUser();
        return firestoreUser;
      }

      // Si no existe en Firestore, crear el documento
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

  // Método de emergencia para eliminar usuario problemático (solo para desarrollo)
  Future<void> deleteCurrentAuthUser() async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet para eliminar usuario');
    }

    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw Exception('No hay usuario autenticado para eliminar');
    }

    try {
      final uid = authUser.uid;

      // Eliminar de Firestore primero
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (e) {
        print('Error al eliminar de Firestore (puede que no exista): $e');
      }

      // Eliminar de Authentication
      await authUser.delete();

      // Limpiar estado local
      _currentUser = null;
      await _clearUserCache();
      await _analyticsService.disableCollection();
      await _crashReportingService.disableCollection();
    } catch (e) {
      throw Exception('Error al eliminar usuario: ${e.toString()}');
    }
  }

  // Método para eliminar usuario por email (útil para limpiar duplicados)
  Future<void> deleteUserByEmail(String email, String password) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet');
    }

    try {
      // Primero hacer login con el usuario problemático
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        final uid = user.uid;

        // Eliminar de Firestore
        try {
          await _firestore.collection('users').doc(uid).delete();
        } catch (e) {
          print('Error al eliminar de Firestore: $e');
        }

        // Eliminar de Authentication
        await user.delete();

        // Limpiar estado local
        _currentUser = null;
        await _clearUserCache();
        await _analyticsService.disableCollection();
        await _crashReportingService.disableCollection();
      }
    } catch (e) {
      throw Exception('Error al eliminar usuario por email: ${e.toString()}');
    }
  }

  // Método mejorado para verificar si un email existe usando solo Firestore
  Future<bool> checkIfEmailExists(String email) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Se requiere conexión a internet');
    }

    try {
      // Buscar en Firestore si existe un documento con este email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar email en Firestore: $e');
      // En caso de error con Firestore, asumimos que no existe para permitir el registro
      return false;
    }
  }

  /// Elimina la cuenta del usuario actual y todos sus datos asociados.
  /// Incluye: datos de Firebase Auth, documento de Firestore, diagramas sincronizados,
  /// y datos locales.
  ///
  /// Requiere que el usuario esté autenticado y haya iniciado sesión recientemente.
  /// Para cuentas antiguas, puede ser necesario re-autenticarse.
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
    if (authUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    if (_currentUser?.isGuest == true) {
      throw Exception(
          'Los usuarios invitados no pueden eliminar cuenta. Cierra sesión para salir.');
    }

    final uid = authUser.uid;
    final email = authUser.email;

    if (email == null) {
      throw Exception('No se puede verificar el email del usuario');
    }

    try {
      // PASO 1: Re-autenticar para operaciones sensibles
      onProgress?.call('Verificando credenciales...');
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await authUser.reauthenticateWithCredential(credential);

      // PASO 2: Eliminar diagramas sincronizados en Firebase
      onProgress?.call('Eliminando diagramas sincronizados...');
      try {
        final diagramsCollection =
            _firestore.collection('users').doc(uid).collection('diagrams');
        final diagramsSnapshot = await diagramsCollection.get();
        for (final doc in diagramsSnapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error eliminando diagramas de Firebase: $e');
        // Continuar con la eliminación aunque falle esto
      }

      // PASO 3: Eliminar documento de usuario en Firestore
      onProgress?.call('Eliminando datos de usuario...');
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (e) {
        print('Error eliminando documento de usuario: $e');
        // Continuar con la eliminación aunque falle esto
      }

      // PASO 4: Eliminar métricas del usuario (si existen en colección separada)
      onProgress?.call('Eliminando métricas...');
      try {
        await _firestore.collection('user_metrics').doc(uid).delete();
      } catch (e) {
        print('Info: No se encontraron métricas para eliminar o error: $e');
      }

      // PASO 5: Eliminar cuenta de Firebase Authentication
      onProgress?.call('Eliminando cuenta de autenticación...');
      await authUser.delete();

      // PASO 6: Limpiar datos locales
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
              'Por seguridad, debes cerrar sesión e iniciar sesión nuevamente antes de eliminar tu cuenta.');
        case 'too-many-requests':
          throw Exception(
              'Demasiados intentos. Espera un momento e intenta de nuevo.');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error al eliminar cuenta: ${e.toString()}');
    }
  }
}
