import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart'; // Añadimos esta importación para Offset
import '../models/saved_diagram.dart';
import '../models/diagram_node.dart';
import 'package:flutter/services.dart' show rootBundle;

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
      version: 1,
      onCreate: _onCreate,
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
        is_template INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Inicializar con plantillas predeterminadas
    await _loadTemplates(db);
  }

  Future<void> _ensureTemplatesExist(Database db) async {
    // Obtener los nombres de las plantillas que deberían existir
    final expectedTemplates = [
      'Suma de dos números',
      'Verificación par/impar',
      'Contador con bucle while',
      'Menú de opciones con conectores',
      'Promedio con comentarios',
      'Factorial con subprocesos',
    ];

    // Verificar qué plantillas ya existen
    final List<Map<String, dynamic>> existingTemplates = await db.query(
      'diagrams',
      where: 'is_template = ?',
      whereArgs: [1],
      columns: ['name'],
    );

    final existingNames =
        existingTemplates.map((t) => t['name'] as String).toSet();

    // Cargar solo las plantillas que faltan
    for (final templateName in expectedTemplates) {
      if (!existingNames.contains(templateName)) {
        print('Cargando plantilla faltante: $templateName');
        SavedDiagram? template;

        switch (templateName) {
          case 'Suma de dos números':
            template = await _createSumTemplate();
            break;
          case 'Verificación par/impar':
            template = await _createEvenOddTemplate();
            break;
          case 'Contador con bucle while':
            template = await _createLoopTemplate();
            break;
          case 'Menú de opciones con conectores':
            template = await _createConnectorTemplate();
            break;
          case 'Promedio con comentarios':
            template = await _createCommentTemplate();
            break;
          case 'Factorial con subprocesos':
            template = await _createSubprocessTemplate();
            break;
        }

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
    // Plantilla 1: Suma de dos números
    SavedDiagram sumTemplate = await _createSumTemplate();
    await db.insert(
      'diagrams',
      sumTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Plantilla 2: Verificación de número par/impar
    SavedDiagram evenOddTemplate = await _createEvenOddTemplate();
    await db.insert(
      'diagrams',
      evenOddTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Plantilla 3: Contador con bucle while
    SavedDiagram loopTemplate = await _createLoopTemplate();
    await db.insert(
      'diagrams',
      loopTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Plantilla 4: Conector - Flujo complejo con conectores
    SavedDiagram connectorTemplate = await _createConnectorTemplate();
    await db.insert(
      'diagrams',
      connectorTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Plantilla 5: Comentario - Documentación de diagrama
    SavedDiagram commentTemplate = await _createCommentTemplate();
    await db.insert(
      'diagrams',
      commentTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Plantilla 6: Subproceso - Cálculo de factorial
    SavedDiagram subprocessTemplate = await _createSubprocessTemplate();
    await db.insert(
      'diagrams',
      subprocessTemplate.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Crear plantilla para suma de dos números
  Future<SavedDiagram> _createSumTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_1",
      type: NodeType.start,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputANode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_2",
      type: NodeType.input,
      position: const Offset(250, 150),
      text: "Ingrese el primer número (a)",
    );

    final inputBNode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_3",
      type: NodeType.input,
      position: const Offset(250, 250),
      text: "Ingrese el segundo número (b)",
    );

    final processNode = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_4",
      type: NodeType.process,
      position: const Offset(250, 350),
      text: "resultado = a + b",
    );

    final outputNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_5",
      type: NodeType.output,
      position: const Offset(250, 450),
      text: "Mostrar resultado",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_6",
      type: NodeType.end,
      position: const Offset(250, 550),
      text: "Fin",
    );

    final nodes = [
      startNode,
      inputANode,
      inputBNode,
      processNode,
      outputNode,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: inputANode, label: ""),
      Connection(source: inputANode, target: inputBNode, label: ""),
      Connection(source: inputBNode, target: processNode, label: ""),
      Connection(source: processNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Suma de dos números",
      description: "Plantilla para sumar dos números ingresados por el usuario",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // Crear plantilla para verificar si un número es par o impar
  Future<SavedDiagram> _createEvenOddTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_10",
      type: NodeType.start,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_11",
      type: NodeType.input,
      position: const Offset(250, 150),
      text: "Ingrese un número",
    );

    final decisionNode = DiagramNode(
      id: "decision_${now.millisecondsSinceEpoch}_12",
      type: NodeType.decision,
      position: const Offset(250, 250),
      text: "numero % 2 == 0",
    );

    final outputEvenNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_13",
      type: NodeType.output,
      position: const Offset(400, 350),
      text: "El número es par",
    );

    final outputOddNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_14",
      type: NodeType.output,
      position: const Offset(100, 350),
      text: "El número es impar",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_15",
      type: NodeType.end,
      position: const Offset(250, 450),
      text: "Fin",
    );

    final nodes = [
      startNode,
      inputNode,
      decisionNode,
      outputEvenNode,
      outputOddNode,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decisionNode, label: ""),
      Connection(source: decisionNode, target: outputEvenNode, label: "Sí"),
      Connection(source: decisionNode, target: outputOddNode, label: "No"),
      Connection(source: outputEvenNode, target: endNode, label: ""),
      Connection(source: outputOddNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Verificación par/impar",
      description: "Plantilla para verificar si un número es par o impar",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
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

  // Obtener todos los diagramas (excluyendo plantillas por defecto)
  Future<List<SavedDiagram>> getAllDiagrams({
    bool includeTemplates = false,
  }) async {
    final Database db = await database;

    List<Map<String, dynamic>> maps;
    if (!includeTemplates) {
      maps = await db.query(
        'diagrams',
        where: 'is_template = ?',
        whereArgs: [0],
        orderBy: 'updated_at DESC',
      );
    } else {
      maps = await db.query('diagrams', orderBy: 'updated_at DESC');
    }

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

  // Crear plantilla para contador con bucle while
  Future<SavedDiagram> _createLoopTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_20",
      type: NodeType.start,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final variableNode = DiagramNode(
      id: "variable_${now.millisecondsSinceEpoch}_21",
      type: NodeType.variable,
      position: const Offset(250, 150),
      text: "int contador = 0",
    );

    final inputNode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_22",
      type: NodeType.input,
      position: const Offset(250, 250),
      text: "Ingrese el límite",
    );

    final loopNode = DiagramNode(
      id: "loop_${now.millisecondsSinceEpoch}_23",
      type: NodeType.loop,
      position: const Offset(250, 350),
      text: "while(contador < limite)",
    );

    final outputNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_24",
      type: NodeType.output,
      position: const Offset(400, 450),
      text: "Mostrar contador",
    );

    final processNode = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_25",
      type: NodeType.process,
      position: const Offset(400, 550),
      text: "contador = contador + 1",
    );

    final finalOutputNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_26",
      type: NodeType.output,
      position: const Offset(250, 650),
      text: "Mostrar 'Bucle terminado'",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_27",
      type: NodeType.end,
      position: const Offset(250, 750),
      text: "Fin",
    );

    final nodes = [
      startNode,
      variableNode,
      inputNode,
      loopNode,
      outputNode,
      processNode,
      finalOutputNode,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: variableNode, label: ""),
      Connection(source: variableNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: loopNode, label: ""),
      Connection(source: loopNode, target: outputNode, label: "Verdadero"),
      Connection(source: outputNode, target: processNode, label: ""),
      Connection(
          source: processNode,
          target: loopNode,
          label: "",
          isLoopBack: true), // Retorno del bucle con forma cuadrada
      Connection(source: loopNode, target: finalOutputNode, label: "Falso"),
      Connection(source: finalOutputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Contador con bucle while",
      description:
          "Plantilla que demuestra el uso de un bucle while para contar números",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // Crear plantilla para conector - Flujo complejo con conectores
  Future<SavedDiagram> _createConnectorTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_30",
      type: NodeType.start,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_31",
      type: NodeType.input,
      position: const Offset(250, 150),
      text: "Ingrese opción (1-3)",
    );

    final decisionNode = DiagramNode(
      id: "decision_${now.millisecondsSinceEpoch}_32",
      type: NodeType.decision,
      position: const Offset(250, 250),
      text: "opcion == 1",
    );

    // Conector de salida A
    final connectorAOut = DiagramNode(
      id: "connector_${now.millisecondsSinceEpoch}_33",
      type: NodeType.connector,
      position: const Offset(450, 250),
      text: "→ A",
    );

    final decision2Node = DiagramNode(
      id: "decision_${now.millisecondsSinceEpoch}_34",
      type: NodeType.decision,
      position: const Offset(250, 350),
      text: "opcion == 2",
    );

    // Conector de salida B
    final connectorBOut = DiagramNode(
      id: "connector_${now.millisecondsSinceEpoch}_35",
      type: NodeType.connector,
      position: const Offset(450, 350),
      text: "→ B",
    );

    final outputDefaultNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_36",
      type: NodeType.output,
      position: const Offset(250, 450),
      text: "Opción inválida",
    );

    // Conector de entrada A (continuación)
    final connectorAIn = DiagramNode(
      id: "connector_${now.millisecondsSinceEpoch}_37",
      type: NodeType.connector,
      position: const Offset(600, 250),
      text: "← A",
    );

    final outputOption1Node = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_38",
      type: NodeType.output,
      position: const Offset(600, 350),
      text: "Procesando opción 1",
    );

    // Conector de entrada B (continuación)
    final connectorBIn = DiagramNode(
      id: "connector_${now.millisecondsSinceEpoch}_39",
      type: NodeType.connector,
      position: const Offset(600, 450),
      text: "← B",
    );

    final outputOption2Node = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_40",
      type: NodeType.output,
      position: const Offset(600, 550),
      text: "Procesando opción 2",
    );

    // Conector de convergencia
    final connectorEnd = DiagramNode(
      id: "connector_${now.millisecondsSinceEpoch}_41",
      type: NodeType.connector,
      position: const Offset(250, 550),
      text: "⇄ FIN",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_42",
      type: NodeType.end,
      position: const Offset(250, 650),
      text: "Fin",
    );

    final nodes = [
      startNode,
      inputNode,
      decisionNode,
      connectorAOut,
      decision2Node,
      connectorBOut,
      outputDefaultNode,
      connectorAIn,
      outputOption1Node,
      connectorBIn,
      outputOption2Node,
      connectorEnd,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decisionNode, label: ""),
      Connection(source: decisionNode, target: connectorAOut, label: "Sí"),
      Connection(source: decisionNode, target: decision2Node, label: "No"),
      Connection(source: decision2Node, target: connectorBOut, label: "Sí"),
      Connection(source: decision2Node, target: outputDefaultNode, label: "No"),
      Connection(source: connectorAOut, target: connectorAIn, label: ""),
      Connection(source: connectorAIn, target: outputOption1Node, label: ""),
      Connection(source: connectorBOut, target: connectorBIn, label: ""),
      Connection(source: connectorBIn, target: outputOption2Node, label: ""),
      Connection(source: outputOption1Node, target: connectorEnd, label: ""),
      Connection(source: outputOption2Node, target: connectorEnd, label: ""),
      Connection(source: outputDefaultNode, target: connectorEnd, label: ""),
      Connection(source: connectorEnd, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Menú de opciones con conectores",
      description:
          "Plantilla que demuestra el uso de conectores para organizar flujos complejos y evitar cruces de líneas",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // Crear plantilla para comentario - Documentación de diagrama
  Future<SavedDiagram> _createCommentTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_50",
      type: NodeType.start,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    // Comentario principal
    final commentStartNode = DiagramNode(
      id: "comment_${now.millisecondsSinceEpoch}_51",
      type: NodeType.comment,
      position: const Offset(450, 30),
      text: "Este algoritmo calcula el promedio de 3 números",
    );

    final variableNode = DiagramNode(
      id: "variable_${now.millisecondsSinceEpoch}_52",
      type: NodeType.variable,
      position: const Offset(300, 150),
      text: "float suma = 0",
    );

    // Comentario sobre variables
    final commentVarNode = DiagramNode(
      id: "comment_${now.millisecondsSinceEpoch}_53",
      type: NodeType.comment,
      position: const Offset(450, 130),
      text: "Acumulador para la suma",
    );

    final inputNode1 = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_54",
      type: NodeType.input,
      position: const Offset(300, 250),
      text: "Ingrese número 1",
    );

    final processNode1 = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_55",
      type: NodeType.process,
      position: const Offset(300, 350),
      text: "suma = suma + numero1",
    );

    final inputNode2 = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_56",
      type: NodeType.input,
      position: const Offset(300, 450),
      text: "Ingrese número 2",
    );

    final processNode2 = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_57",
      type: NodeType.process,
      position: const Offset(300, 550),
      text: "suma = suma + numero2",
    );

    final inputNode3 = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_58",
      type: NodeType.input,
      position: const Offset(300, 650),
      text: "Ingrese número 3",
    );

    final processNode3 = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_59",
      type: NodeType.process,
      position: const Offset(300, 750),
      text: "suma = suma + numero3",
    );

    final processAverageNode = DiagramNode(
      id: "process_${now.millisecondsSinceEpoch}_60",
      type: NodeType.process,
      position: const Offset(300, 850),
      text: "promedio = suma / 3",
    );

    // Comentario sobre cálculo
    final commentCalcNode = DiagramNode(
      id: "comment_${now.millisecondsSinceEpoch}_61",
      type: NodeType.comment,
      position: const Offset(450, 830),
      text: "Dividimos entre 3 porque tenemos 3 números",
    );

    final outputNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_62",
      type: NodeType.output,
      position: const Offset(300, 950),
      text: "Mostrar promedio",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_63",
      type: NodeType.end,
      position: const Offset(300, 1050),
      text: "Fin",
    );

    final nodes = [
      startNode,
      commentStartNode,
      variableNode,
      commentVarNode,
      inputNode1,
      processNode1,
      inputNode2,
      processNode2,
      inputNode3,
      processNode3,
      processAverageNode,
      commentCalcNode,
      outputNode,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: variableNode, label: ""),
      Connection(source: variableNode, target: inputNode1, label: ""),
      Connection(source: inputNode1, target: processNode1, label: ""),
      Connection(source: processNode1, target: inputNode2, label: ""),
      Connection(source: inputNode2, target: processNode2, label: ""),
      Connection(source: processNode2, target: inputNode3, label: ""),
      Connection(source: inputNode3, target: processNode3, label: ""),
      Connection(source: processNode3, target: processAverageNode, label: ""),
      Connection(source: processAverageNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Promedio con comentarios",
      description:
          "Plantilla que demuestra el uso de comentarios para documentar y explicar el diagrama de flujo",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // Crear plantilla para subproceso - Cálculo de factorial
  Future<SavedDiagram> _createSubprocessTemplate() async {
    final now = DateTime.now();

    final startNode = DiagramNode(
      id: "start_${now.millisecondsSinceEpoch}_70",
      type: NodeType.start,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${now.millisecondsSinceEpoch}_71",
      type: NodeType.input,
      position: const Offset(300, 150),
      text: "Ingrese un número",
    );

    // Validación
    final decisionValidateNode = DiagramNode(
      id: "decision_${now.millisecondsSinceEpoch}_72",
      type: NodeType.decision,
      position: const Offset(300, 250),
      text: "numero >= 0",
    );

    final outputErrorNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_73",
      type: NodeType.output,
      position: const Offset(100, 350),
      text: "Error: número negativo",
    );

    // Subproceso de validación
    final subprocessValidateNode = DiagramNode(
      id: "subprocess_${now.millisecondsSinceEpoch}_74",
      type: NodeType.subprocess,
      position: const Offset(300, 350),
      text: "ValidarEntrada(numero)",
    );

    // Subproceso de cálculo de factorial
    final subprocessFactorialNode = DiagramNode(
      id: "subprocess_${now.millisecondsSinceEpoch}_75",
      type: NodeType.subprocess,
      position: const Offset(300, 450),
      text: "CalcularFactorial(numero)",
    );

    // Subproceso de formato de salida
    final subprocessFormatNode = DiagramNode(
      id: "subprocess_${now.millisecondsSinceEpoch}_76",
      type: NodeType.subprocess,
      position: const Offset(300, 550),
      text: "FormatearResultado(resultado)",
    );

    final outputNode = DiagramNode(
      id: "output_${now.millisecondsSinceEpoch}_77",
      type: NodeType.output,
      position: const Offset(300, 650),
      text: "Mostrar resultado",
    );

    final endNode = DiagramNode(
      id: "end_${now.millisecondsSinceEpoch}_78",
      type: NodeType.end,
      position: const Offset(300, 750),
      text: "Fin",
    );

    final nodes = [
      startNode,
      inputNode,
      decisionValidateNode,
      outputErrorNode,
      subprocessValidateNode,
      subprocessFactorialNode,
      subprocessFormatNode,
      outputNode,
      endNode,
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decisionValidateNode, label: ""),
      Connection(
          source: decisionValidateNode, target: outputErrorNode, label: "No"),
      Connection(
          source: decisionValidateNode,
          target: subprocessValidateNode,
          label: "Sí"),
      Connection(
          source: subprocessValidateNode,
          target: subprocessFactorialNode,
          label: ""),
      Connection(
          source: subprocessFactorialNode,
          target: subprocessFormatNode,
          label: ""),
      Connection(source: subprocessFormatNode, target: outputNode, label: ""),
      Connection(source: outputErrorNode, target: endNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "Factorial con subprocesos",
      description:
          "Plantilla que demuestra el uso de subprocesos para modularizar operaciones complejas como validación, cálculo y formato",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }
}
