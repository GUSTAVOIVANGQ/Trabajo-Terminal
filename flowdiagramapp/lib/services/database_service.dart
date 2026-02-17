import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/saved_diagram.dart';
import 'template_definitions.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'flowdiagram.db');

    final db = await openDatabase(
      path,
      version: 3, // Incrementar versión para agregar columna user_id
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Verificar y cargar plantillas cada vez que se abre la base de datos
        await _ensureTemplatesExist(db);
      },
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diagrams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        nodes_data TEXT NOT NULL,
        connections_data TEXT NOT NULL,
        is_template INTEGER NOT NULL DEFAULT 0,
        user_id TEXT
      )
    ''');

    // Inicializar con plantillas predeterminadas (20 plantillas educativas)
    await _loadTemplates(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Eliminar plantillas antiguas y cargar las nuevas
      await _migrateToNewTemplates(db);
    }
    if (oldVersion < 3) {
      // Agregar columna user_id para separar diagramas por usuario
      await db.execute('ALTER TABLE diagrams ADD COLUMN user_id TEXT');
      print(
          'Migración v3: Columna user_id agregada para separar diagramas por usuario');
    }
  }

  /// Migra de las plantillas antiguas (4) a las nuevas (20)
  Future<void> _migrateToNewTemplates(Database db) async {
    // Nombres de las plantillas antiguas a eliminar
    final oldTemplateNames = [
      'Suma de dos números',
      'Verificación par/impar',
      'Contador con bucle while',
      'Factorial con subprocesos',
    ];

    // Eliminar plantillas antiguas
    for (final name in oldTemplateNames) {
      await db.delete(
        'diagrams',
        where: 'name = ? AND is_template = ?',
        whereArgs: [name, 1],
      );
      print('Plantilla antigua eliminada: $name');
    }

    // Cargar las 20 nuevas plantillas
    await _loadTemplates(db);
    print('Migración completada: 20 nuevas plantillas educativas cargadas');
  }

  Future<void> _ensureTemplatesExist(Database db) async {
    // Obtener los nombres de las 20 plantillas educativas
    final expectedTemplates = TemplateDefinitions.expectedTemplateNames;

    // Verificar qué plantillas ya existen
    final List<Map<String, dynamic>> existingTemplates = await db.query(
      'diagrams',
      where: 'is_template = ?',
      whereArgs: [1],
      columns: ['name'],
    );

    final existingNames =
        existingTemplates.map((t) => t['name'] as String).toSet();

    // Detectar y eliminar plantillas antiguas que ya no son parte del nuevo sistema
    final oldTemplateNames = [
      'Suma de dos números',
      'Verificación par/impar',
      'Contador con bucle while',
      'Factorial con subprocesos',
    ];

    for (final oldName in oldTemplateNames) {
      if (existingNames.contains(oldName)) {
        await db.delete(
          'diagrams',
          where: 'name = ? AND is_template = ?',
          whereArgs: [oldName, 1],
        );
        existingNames.remove(oldName);
        print('Plantilla antigua eliminada: $oldName');
      }
    }

    // Cargar solo las plantillas que faltan
    for (final templateName in expectedTemplates) {
      if (!existingNames.contains(templateName)) {
        print('Cargando plantilla: $templateName');
        final template =
            await TemplateDefinitions.getTemplateByName(templateName);

        if (template != null) {
          await db.insert(
            'diagrams',
            template.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }

  Future<void> _loadTemplates(Database db) async {
    // Cargar las 20 plantillas educativas basadas en el temario de Fundamentos de Programación
    final templates = await TemplateDefinitions.getAllTemplates();

    for (final template in templates) {
      await db.insert(
        'diagrams',
        template.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Plantilla cargada: ${template.name}');
    }

    print('Total de plantillas cargadas: ${templates.length}');
  }

  // Operaciones CRUD para los diagramas

  // Crear un nuevo diagrama
  Future<int> saveDiagram(SavedDiagram diagram) async {
    final Database db = await database;
    return await db.insert(
      'diagrams',
      diagram.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Actualizar un diagrama existente
  Future<int> updateDiagram(SavedDiagram diagram) async {
    final Database db = await database;
    return await db.update(
      'diagrams',
      diagram.toMap(),
      where: 'id = ?',
      whereArgs: [diagram.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener un diagrama por su ID
  Future<SavedDiagram?> getDiagram(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagrams',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return SavedDiagram.fromMap(maps.first);
  }

  // Obtener todos los diagramas del usuario actual (excluyendo plantillas por defecto)
  Future<List<SavedDiagram>> getAllDiagrams({
    bool includeTemplates = false,
    String? userId,
  }) async {
    final Database db = await database;

    List<Map<String, dynamic>> maps;
    if (!includeTemplates) {
      if (userId != null) {
        // Filtrar por usuario: diagramas del usuario actual
        maps = await db.query(
          'diagrams',
          where: 'is_template = ? AND (user_id = ? OR user_id IS NULL)',
          whereArgs: [0, userId],
          orderBy: 'updated_at DESC',
        );
      } else {
        // Sin filtro de usuario (compatibilidad hacia atrás)
        maps = await db.query(
          'diagrams',
          where: 'is_template = ?',
          whereArgs: [0],
          orderBy: 'updated_at DESC',
        );
      }
    } else {
      maps = await db.query('diagrams', orderBy: 'updated_at DESC');
    }

    return List.generate(maps.length, (i) {
      return SavedDiagram.fromMap(maps[i]);
    });
  }

  // Obtener diagramas de un usuario específico
  Future<List<SavedDiagram>> getDiagramsByUser(String userId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagrams',
      where: 'is_template = ? AND user_id = ?',
      whereArgs: [0, userId],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavedDiagram.fromMap(maps[i]);
    });
  }

  // Obtener solo las plantillas
  Future<List<SavedDiagram>> getAllTemplates() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagrams',
      where: 'is_template = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return SavedDiagram.fromMap(maps[i]);
    });
  }

  // Eliminar un diagrama
  Future<int> deleteDiagram(int id) async {
    final Database db = await database;
    return await db.delete('diagrams', where: 'id = ?', whereArgs: [id]);
  }

  // Eliminar todos los diagramas de un usuario específico
  Future<int> deleteDiagramsByUser(String userId) async {
    final Database db = await database;
    return await db.delete(
      'diagrams',
      where: 'user_id = ? AND is_template = ?',
      whereArgs: [userId, 0],
    );
  }

  /// Fuerza la recarga de todas las plantillas (útil para desarrollo)
  Future<void> reloadAllTemplates() async {
    final Database db = await database;

    // Eliminar todas las plantillas existentes
    await db.delete(
      'diagrams',
      where: 'is_template = ?',
      whereArgs: [1],
    );

    // Cargar las 20 nuevas plantillas
    await _loadTemplates(db);
    print('Plantillas recargadas exitosamente');
  }
}
