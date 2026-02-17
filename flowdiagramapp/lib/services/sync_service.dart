import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/saved_diagram.dart';
import 'database_service.dart';
import 'auth_service.dart';

/// Resultado de una operación de sincronización
class SyncResult {
  final int uploaded;
  final int downloaded;
  final int conflicts;
  final List<String> errors;
  final bool success;

  SyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.conflicts,
    required this.errors,
    required this.success,
  });

  @override
  String toString() {
    return 'Subidos: $uploaded, Descargados: $downloaded, Conflictos: $conflicts';
  }
}

/// Servicio para sincronizar diagramas entre la base de datos local y Firebase Firestore
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  /// Verifica si hay conexión a internet
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Obtiene el ID del usuario actual
  String? _getCurrentUserId() {
    final user = _authService.currentUser;
    if (user == null) return null;
    return user.isGuest ? 'guest_${user.uid}' : user.uid;
  }

  /// Verifica si el usuario puede sincronizar (debe tener cuenta, no invitado)
  bool canSync() {
    final user = _authService.currentUser;
    return user != null && !user.isGuest;
  }

  /// Colección de diagramas del usuario en Firestore
  CollectionReference<Map<String, dynamic>> _getUserDiagramsCollection(
      String userId) {
    return _firestore.collection('users').doc(userId).collection('diagrams');
  }

  /// Sincroniza los diagramas locales con Firebase
  /// Estrategia: Los cambios más recientes ganan (basado en updated_at)
  Future<SyncResult> syncDiagrams() async {
    final errors = <String>[];
    int uploaded = 0;
    int downloaded = 0;
    int conflicts = 0;

    // Verificar conexión a internet
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Sin conexión a internet'],
        success: false,
      );
    }

    // Verificar que el usuario puede sincronizar
    if (!canSync()) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: [
          'Los usuarios invitados no pueden sincronizar. Inicia sesión con una cuenta.'
        ],
        success: false,
      );
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Usuario no autenticado'],
        success: false,
      );
    }

    try {
      final collection = _getUserDiagramsCollection(userId);

      // Obtener diagramas locales del usuario
      final localDiagrams = await _databaseService.getDiagramsByUser(userId);

      // Obtener diagramas de Firebase
      final firebaseSnapshot = await collection.get();
      final firebaseDiagrams = <String, Map<String, dynamic>>{};

      for (final doc in firebaseSnapshot.docs) {
        firebaseDiagrams[doc.id] = doc.data();
      }

      // Crear mapas para comparación rápida
      final localDiagramMap = <String, SavedDiagram>{};
      for (final diagram in localDiagrams) {
        if (diagram.id != null) {
          localDiagramMap['local_${diagram.id}'] = diagram;
        }
      }

      // PASO 1: Subir diagramas locales nuevos o actualizados a Firebase
      for (final diagram in localDiagrams) {
        if (diagram.id == null) continue;

        final diagramKey = 'local_${diagram.id}';
        final existingInFirebase = firebaseDiagrams[diagramKey];

        if (existingInFirebase == null) {
          // Diagrama nuevo - subir a Firebase
          try {
            await collection.doc(diagramKey).set(_diagramToFirestore(diagram));
            uploaded++;
          } catch (e) {
            errors.add('Error subiendo ${diagram.name}: $e');
          }
        } else {
          // Diagrama existe en ambos lados - comparar fechas
          final localUpdated = diagram.updatedAt;
          final firebaseUpdated =
              DateTime.parse(existingInFirebase['updated_at']);

          if (localUpdated.isAfter(firebaseUpdated)) {
            // Local es más reciente - subir
            try {
              await collection
                  .doc(diagramKey)
                  .set(_diagramToFirestore(diagram));
              uploaded++;
            } catch (e) {
              errors.add('Error actualizando ${diagram.name}: $e');
            }
          } else if (firebaseUpdated.isAfter(localUpdated)) {
            // Firebase es más reciente - descargar
            try {
              final updatedDiagram = _firestoreToLocalDiagram(
                existingInFirebase,
                diagram.id!,
                userId,
              );
              await _databaseService.updateDiagram(updatedDiagram);
              downloaded++;
            } catch (e) {
              errors.add('Error descargando ${diagram.name}: $e');
              conflicts++;
            }
          }
          // Si son iguales, no hacer nada
        }
      }

      // PASO 2: Descargar diagramas que existen en Firebase pero no localmente
      for (final entry in firebaseDiagrams.entries) {
        final diagramKey = entry.key;

        if (!localDiagramMap.containsKey(diagramKey)) {
          // Diagrama existe solo en Firebase - descargar
          try {
            final newDiagram = _firestoreToNewLocalDiagram(entry.value, userId);
            await _databaseService.saveDiagram(newDiagram);
            downloaded++;
          } catch (e) {
            errors.add('Error descargando diagrama desde Firebase: $e');
          }
        }
      }

      return SyncResult(
        uploaded: uploaded,
        downloaded: downloaded,
        conflicts: conflicts,
        errors: errors,
        success: errors.isEmpty,
      );
    } catch (e) {
      return SyncResult(
        uploaded: uploaded,
        downloaded: downloaded,
        conflicts: conflicts,
        errors: [...errors, 'Error general de sincronización: $e'],
        success: false,
      );
    }
  }

  /// Sube todos los diagramas locales a Firebase (sobrescribe)
  Future<SyncResult> uploadAllDiagrams() async {
    final errors = <String>[];
    int uploaded = 0;

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Sin conexión a internet'],
        success: false,
      );
    }

    if (!canSync()) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Los usuarios invitados no pueden sincronizar'],
        success: false,
      );
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Usuario no autenticado'],
        success: false,
      );
    }

    try {
      final collection = _getUserDiagramsCollection(userId);
      final localDiagrams = await _databaseService.getDiagramsByUser(userId);

      for (final diagram in localDiagrams) {
        if (diagram.id == null) continue;
        try {
          final diagramKey = 'local_${diagram.id}';
          await collection.doc(diagramKey).set(_diagramToFirestore(diagram));
          uploaded++;
        } catch (e) {
          errors.add('Error subiendo ${diagram.name}: $e');
        }
      }

      return SyncResult(
        uploaded: uploaded,
        downloaded: 0,
        conflicts: 0,
        errors: errors,
        success: errors.isEmpty,
      );
    } catch (e) {
      return SyncResult(
        uploaded: uploaded,
        downloaded: 0,
        conflicts: 0,
        errors: [...errors, 'Error: $e'],
        success: false,
      );
    }
  }

  /// Descarga todos los diagramas desde Firebase (sobrescribe locales)
  Future<SyncResult> downloadAllDiagrams() async {
    final errors = <String>[];
    int downloaded = 0;

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Sin conexión a internet'],
        success: false,
      );
    }

    if (!canSync()) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Los usuarios invitados no pueden sincronizar'],
        success: false,
      );
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      return SyncResult(
        uploaded: 0,
        downloaded: 0,
        conflicts: 0,
        errors: ['Usuario no autenticado'],
        success: false,
      );
    }

    try {
      final collection = _getUserDiagramsCollection(userId);
      final firebaseSnapshot = await collection.get();

      // Eliminar diagramas locales del usuario
      await _databaseService.deleteDiagramsByUser(userId);

      // Descargar todos desde Firebase
      for (final doc in firebaseSnapshot.docs) {
        try {
          final diagram = _firestoreToNewLocalDiagram(doc.data(), userId);
          await _databaseService.saveDiagram(diagram);
          downloaded++;
        } catch (e) {
          errors.add('Error descargando diagrama: $e');
        }
      }

      return SyncResult(
        uploaded: 0,
        downloaded: downloaded,
        conflicts: 0,
        errors: errors,
        success: errors.isEmpty,
      );
    } catch (e) {
      return SyncResult(
        uploaded: 0,
        downloaded: downloaded,
        conflicts: 0,
        errors: [...errors, 'Error: $e'],
        success: false,
      );
    }
  }

  /// Elimina todos los diagramas del usuario en Firebase
  Future<void> deleteAllFirebaseDiagrams(String userId) async {
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      throw Exception('Sin conexión a internet');
    }

    final collection = _getUserDiagramsCollection(userId);
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Convierte un SavedDiagram a formato Firestore
  Map<String, dynamic> _diagramToFirestore(SavedDiagram diagram) {
    return {
      'name': diagram.name,
      'description': diagram.description,
      'created_at': diagram.createdAt.toIso8601String(),
      'updated_at': diagram.updatedAt.toIso8601String(),
      'nodes_data': diagram.toMap()['nodes_data'],
      'connections_data': diagram.toMap()['connections_data'],
      'is_template': diagram.isTemplate,
      'user_id': diagram.userId,
      'synced_at': DateTime.now().toIso8601String(),
    };
  }

  /// Convierte datos de Firestore a SavedDiagram para actualizar uno existente
  SavedDiagram _firestoreToLocalDiagram(
    Map<String, dynamic> data,
    int localId,
    String userId,
  ) {
    return SavedDiagram.fromMap({
      'id': localId,
      'name': data['name'],
      'description': data['description'] ?? '',
      'created_at': data['created_at'],
      'updated_at': data['updated_at'],
      'nodes_data': data['nodes_data'],
      'connections_data': data['connections_data'],
      'is_template': data['is_template'] == true ? 1 : 0,
      'user_id': userId,
    });
  }

  /// Convierte datos de Firestore a SavedDiagram nuevo (sin ID local)
  SavedDiagram _firestoreToNewLocalDiagram(
    Map<String, dynamic> data,
    String userId,
  ) {
    return SavedDiagram.fromMap({
      'id': null,
      'name': data['name'],
      'description': data['description'] ?? '',
      'created_at': data['created_at'],
      'updated_at': data['updated_at'],
      'nodes_data': data['nodes_data'],
      'connections_data': data['connections_data'],
      'is_template': data['is_template'] == true ? 1 : 0,
      'user_id': userId,
    });
  }
}
