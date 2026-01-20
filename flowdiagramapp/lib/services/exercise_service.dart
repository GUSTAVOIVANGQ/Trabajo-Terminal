/// Servicio para gestionar ejercicios de comprensión
/// Proporciona ejercicios predefinidos organizados por categoría

import '../models/exercise_model.dart';
import '../models/diagram_node.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  // Claves para SharedPreferences
  static const String _completedExercisesKey = 'completed_exercises';
  static const String _exerciseResultsKey = 'exercise_results';

  /// Obtiene todos los ejercicios disponibles
  List<Exercise> getAllExercises() {
    return [
      ..._getBasicSymbolsExercises(),
      ..._getControlFlowExercises(),
      ..._getDataFlowExercises(),
      ..._getConnectionsExercises(),
      ..._getAdvancedExercises(),
    ];
  }

  /// Obtiene ejercicios por categoría
  List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return getAllExercises()
        .where((exercise) => exercise.category == category)
        .toList();
  }

  /// Obtiene un ejercicio por ID
  Exercise? getExerciseById(String id) {
    try {
      return getAllExercises().firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Guarda el resultado de un ejercicio
  Future<void> saveExerciseResult(ExerciseResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getExerciseResults();
    results.add(result);

    // Guardar en SharedPreferences
    final resultsJson = results.map((r) => json.encode(r.toMap())).toList();
    await prefs.setStringList(_exerciseResultsKey, resultsJson);

    // Marcar como completado
    await _markExerciseCompleted(result.exerciseId);
  }

  /// Obtiene todos los resultados guardados
  Future<List<ExerciseResult>> getExerciseResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList(_exerciseResultsKey) ?? [];
    return resultsJson
        .map((jsonStr) => ExerciseResult.fromMap(json.decode(jsonStr)))
        .toList();
  }

  /// Marca un ejercicio como completado
  Future<void> _markExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedExercisesKey) ?? [];
    if (!completed.contains(exerciseId)) {
      completed.add(exerciseId);
      await prefs.setStringList(_completedExercisesKey, completed);
    }
  }

  /// Verifica si un ejercicio está completado
  Future<bool> isExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedExercisesKey) ?? [];
    return completed.contains(exerciseId);
  }

  /// Obtiene el progreso por categoría
  Future<ExerciseProgress> getCategoryProgress(
      ExerciseCategory category, String userId) async {
    final exercises = getExercisesByCategory(category);
    final results = await getExerciseResults();
    final categoryResults = results
        .where((r) => exercises.any((e) => e.id == r.exerciseId))
        .toList();

    int totalPoints = exercises.fold(0, (sum, e) => sum + e.points);
    int earnedPoints =
        categoryResults.fold(0, (sum, r) => sum + r.pointsEarned);
    double avgAccuracy = categoryResults.isEmpty
        ? 0.0
        : categoryResults.fold(0.0, (sum, r) => sum + r.accuracy) /
            categoryResults.length;
    int totalTime =
        categoryResults.fold(0, (sum, r) => sum + r.timeSpentSeconds);

    return ExerciseProgress(
      userId: userId,
      category: category,
      totalExercises: exercises.length,
      completedExercises: categoryResults.length,
      totalPoints: totalPoints,
      earnedPoints: earnedPoints,
      averageAccuracy: avgAccuracy,
      totalTimeSpentSeconds: totalTime,
    );
  }

  /// Reinicia el progreso (solo para testing)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedExercisesKey);
    await prefs.remove(_exerciseResultsKey);
  }

  // ========== EJERCICIOS DE SÍMBOLOS BÁSICOS ==========

  List<Exercise> _getBasicSymbolsExercises() {
    return [
      // Ejercicio 1: Identificar símbolo de inicio
      Exercise(
        id: 'basic_001',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.basicSymbols,
        difficulty: ExerciseDifficulty.easy,
        question: '¿Qué símbolo representa el INICIO de un algoritmo?',
        explanation:
            'Identifica el símbolo correcto para comenzar un diagrama de flujo',
        options: [
          ExerciseOption(
            id: 'opt_start',
            text: 'Óvalo',
            nodeType: NodeType.terminal,
            description: 'Forma ovalada para inicio y fin',
          ),
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo',
            nodeType: NodeType.process,
            description: 'Rectángulo para procesos',
          ),
          ExerciseOption(
            id: 'opt_decision',
            text: 'Rombo',
            nodeType: NodeType.decision,
            description: 'Rombo para decisiones',
          ),
          ExerciseOption(
            id: 'opt_input',
            text: 'Paralelogramo',
            nodeType: NodeType.data,
            description: 'Paralelogramo para entrada',
          ),
        ],
        correctAnswers: ['opt_start'],
        feedback: '¡Correcto! El óvalo se usa para INICIO y FIN del algoritmo.',
        points: 10,
        relatedNodeType: NodeType.terminal,
      ),

      // Ejercicio 2: Distinguir proceso de decisión
      Exercise(
        id: 'basic_002',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.basicSymbols,
        difficulty: ExerciseDifficulty.easy,
        question:
            '¿Qué símbolo usarías para representar una OPERACIÓN o CÁLCULO?',
        explanation: 'Distingue entre diferentes tipos de símbolos',
        options: [
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo',
            nodeType: NodeType.process,
            description: 'Para operaciones y cálculos',
          ),
          ExerciseOption(
            id: 'opt_decision',
            text: 'Rombo',
            nodeType: NodeType.decision,
            description: 'Para preguntas y decisiones',
          ),
          ExerciseOption(
            id: 'opt_input',
            text: 'Paralelogramo',
            nodeType: NodeType.data,
            description: 'Para lectura de datos',
          ),
          ExerciseOption(
            id: 'opt_connector',
            text: 'Círculo',
//            nodeType: NodeType.connector,
            description: 'Para conectar páginas',
          ),
        ],
        correctAnswers: ['opt_process'],
        feedback:
            '¡Excelente! El rectángulo se usa para PROCESOS como suma = a + b.',
        points: 10,
        relatedNodeType: NodeType.process,
      ),

      // Ejercicio 3: Relacionar símbolos con funciones (Matching)
      Exercise(
        id: 'basic_003',
        type: ExerciseType.matching,
        category: ExerciseCategory.basicSymbols,
        difficulty: ExerciseDifficulty.medium,
        question: 'Relaciona cada símbolo con su función correcta',
        explanation: 'Conecta cada forma con su propósito en el diagrama',
        options: [
          ExerciseOption(
            id: 'match_1',
            text: 'Óvalo → Inicio/Fin',
            nodeType: NodeType.terminal,
          ),
          ExerciseOption(
            id: 'match_2',
            text: 'Rectángulo → Proceso',
            nodeType: NodeType.process,
          ),
          ExerciseOption(
            id: 'match_3',
            text: 'Rombo → Decisión',
            nodeType: NodeType.decision,
          ),
          ExerciseOption(
            id: 'match_4',
            text: 'Paralelogramo → Entrada/Salida',
            nodeType: NodeType.data,
          ),
        ],
        correctAnswers: ['match_1', 'match_2', 'match_3', 'match_4'],
        feedback:
            '¡Perfecto! Has identificado correctamente todos los símbolos básicos.',
        points: 15,
      ),

      // Ejercicio 4: Verdadero o Falso
      Exercise(
        id: 'basic_004',
        type: ExerciseType.trueOrFalse,
        category: ExerciseCategory.basicSymbols,
        difficulty: ExerciseDifficulty.easy,
        question:
            'VERDADERO o FALSO: Un diagrama de flujo puede tener múltiples nodos de INICIO',
        explanation: 'Distingue las reglas básicas de los diagramas de flujo',
        options: [
          ExerciseOption(id: 'true', text: 'Verdadero'),
          ExerciseOption(id: 'false', text: 'Falso'),
        ],
        correctAnswers: ['false'],
        feedback:
            '¡Correcto! Un diagrama debe tener UN SOLO nodo de inicio y puede tener varios de fin.',
        points: 10,
        relatedNodeType: NodeType.terminal,
      ),
    ];
  }

  // ========== EJERCICIOS DE ESTRUCTURAS DE CONTROL ==========

  List<Exercise> _getControlFlowExercises() {
    return [
      // Ejercicio 1: Identificar decisión
      Exercise(
        id: 'control_001',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.controlFlow,
        difficulty: ExerciseDifficulty.medium,
        question: '¿Qué símbolo representa una PREGUNTA o CONDICIÓN?',
        explanation: 'Identifica el símbolo usado para tomar decisiones',
        options: [
          ExerciseOption(
            id: 'opt_decision',
            text: 'Rombo',
            nodeType: NodeType.decision,
            description: 'Para condiciones y preguntas',
          ),
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo',
            nodeType: NodeType.process,
            description: 'Para operaciones',
          ),
          ExerciseOption(
            id: 'opt_loop',
            text: 'Hexágono',
            nodeType: NodeType.preparation,
            description: 'Para preparación de bucles',
          ),
        ],
        correctAnswers: ['opt_decision'],
        feedback: '¡Bien! El rombo se usa para DECISIONES como "¿edad >= 18?".',
        points: 15,
        relatedNodeType: NodeType.decision,
      ),

      // Ejercicio 2: Comparar decisión vs bucle
      Exercise(
        id: 'control_002',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.controlFlow,
        difficulty: ExerciseDifficulty.medium,
        question:
            '¿Cuál es la diferencia entre un nodo de DECISIÓN y un nodo de BUCLE?',
        explanation: 'Compara las funciones de estos dos símbolos',
        options: [
          ExerciseOption(
            id: 'opt_1',
            text:
                'La decisión evalúa una condición, el bucle prepara repeticiones',
            description: 'Correcto',
          ),
          ExerciseOption(
            id: 'opt_2',
            text: 'Son el mismo símbolo con diferente nombre',
            description: 'Incorrecto',
          ),
          ExerciseOption(
            id: 'opt_3',
            text: 'El bucle no puede tener condiciones',
            description: 'Incorrecto',
          ),
        ],
        correctAnswers: ['opt_1'],
        feedback:
            '¡Perfecto! La decisión (rombo) evalúa SÍ/NO, el bucle (hexágono) prepara repeticiones.',
        points: 20,
        relatedNodeType: NodeType.decision,
      ),

      // Ejercicio 3: Ordenar pasos de un algoritmo
      Exercise(
        id: 'control_003',
        type: ExerciseType.ordering,
        category: ExerciseCategory.controlFlow,
        difficulty: ExerciseDifficulty.hard,
        question:
            'Ordena los pasos para crear un algoritmo que sume números hasta 10',
        explanation: 'Organiza los pasos en el orden lógico correcto',
        options: [
          ExerciseOption(id: 'step_1', text: '1. Inicio'),
          ExerciseOption(id: 'step_2', text: '2. Inicializar contador = 0'),
          ExerciseOption(id: 'step_3', text: '3. Inicializar suma = 0'),
          ExerciseOption(id: 'step_4', text: '4. ¿contador < 10?'),
          ExerciseOption(id: 'step_5', text: '5. Incrementar contador'),
          ExerciseOption(id: 'step_6', text: '6. suma = suma + contador'),
          ExerciseOption(id: 'step_7', text: '7. Mostrar suma'),
          ExerciseOption(id: 'step_8', text: '8. Fin'),
        ],
        correctAnswers: [
          'step_1',
          'step_2',
          'step_3',
          'step_4',
          'step_6',
          'step_5',
          'step_4',
          'step_7',
          'step_8'
        ],
        feedback:
            '¡Excelente! Has ordenado correctamente el flujo del algoritmo.',
        points: 25,
      ),
    ];
  }

  // ========== EJERCICIOS DE FLUJO DE DATOS ==========

  List<Exercise> _getDataFlowExercises() {
    return [
      // Ejercicio 1: Identificar entrada vs salida
      Exercise(
        id: 'data_001',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.dataFlow,
        difficulty: ExerciseDifficulty.easy,
        question: '¿Qué símbolo usarías para LEER un dato del usuario?',
        explanation: 'Identifica el símbolo de entrada de datos',
        options: [
          ExerciseOption(
            id: 'opt_input',
            text: 'Paralelogramo',
            nodeType: NodeType.data,
            description: 'Para entrada y salida',
          ),
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo',
            nodeType: NodeType.process,
            description: 'Para procesos',
          ),
          ExerciseOption(
            id: 'opt_variable',
            text: 'Hexágono',
            nodeType: NodeType.process,
            description: 'Para variables',
          ),
        ],
        correctAnswers: ['opt_input'],
        feedback:
            '¡Correcto! El paralelogramo se usa para ENTRADA y SALIDA de datos.',
        points: 10,
        relatedNodeType: NodeType.data,
      ),

      // Ejercicio 2: Distinguir variable de proceso
      Exercise(
        id: 'data_002',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.dataFlow,
        difficulty: ExerciseDifficulty.medium,
        question: '¿Cuándo usarías el símbolo de VARIABLE (hexágono lateral)?',
        explanation: 'Distingue cuándo declarar variables',
        options: [
          ExerciseOption(
            id: 'opt_1',
            text: 'Para declarar variables al inicio del programa',
            description: 'Correcto',
          ),
          ExerciseOption(
            id: 'opt_2',
            text: 'Para realizar cálculos matemáticos',
            description: 'Incorrecto',
          ),
          ExerciseOption(
            id: 'opt_3',
            text: 'Para leer datos del usuario',
            description: 'Incorrecto',
          ),
        ],
        correctAnswers: ['opt_1'],
        feedback:
            '¡Bien! El símbolo de variable se usa para DECLARAR variables (int edad).',
        points: 15,
        relatedNodeType: NodeType.process,
      ),

      // Ejercicio 3: Verdadero o Falso sobre entrada/salida
      Exercise(
        id: 'data_003',
        type: ExerciseType.trueOrFalse,
        category: ExerciseCategory.dataFlow,
        difficulty: ExerciseDifficulty.easy,
        question:
            'VERDADERO o FALSO: El mismo símbolo (paralelogramo) se usa tanto para ENTRADA como para SALIDA',
        explanation: 'Distingue el uso del símbolo de entrada/salida',
        options: [
          ExerciseOption(id: 'true', text: 'Verdadero'),
          ExerciseOption(id: 'false', text: 'Falso'),
        ],
        correctAnswers: ['true'],
        feedback:
            '¡Correcto! El paralelogramo se usa para AMBOS: leer (entrada) y mostrar (salida).',
        points: 10,
        relatedNodeType: NodeType.data,
      ),
    ];
  }

  // ========== EJERCICIOS DE CONEXIONES ==========

  List<Exercise> _getConnectionsExercises() {
    return [
      // Ejercicio 1: Identificar dirección del flujo
      Exercise(
        id: 'conn_001',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.connections,
        difficulty: ExerciseDifficulty.easy,
        question: '¿En qué dirección fluye un diagrama de flujo normalmente?',
        explanation: 'Identifica la dirección estándar del flujo',
        options: [
          ExerciseOption(
            id: 'opt_1',
            text: 'De arriba hacia abajo',
            description: 'Correcto',
          ),
          ExerciseOption(
            id: 'opt_2',
            text: 'De abajo hacia arriba',
            description: 'Incorrecto',
          ),
          ExerciseOption(
            id: 'opt_3',
            text: 'De derecha a izquierda',
            description: 'Incorrecto',
          ),
          ExerciseOption(
            id: 'opt_4',
            text: 'No tiene dirección definida',
            description: 'Incorrecto',
          ),
        ],
        correctAnswers: ['opt_1'],
        feedback:
            '¡Correcto! Los diagramas fluyen de ARRIBA hacia ABAJO y de izquierda a derecha.',
        points: 10,
      ),

      // Ejercicio 2: Entender salidas de decisión
      Exercise(
        id: 'conn_002',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.connections,
        difficulty: ExerciseDifficulty.medium,
        question: '¿Cuántas salidas debe tener un nodo de DECISIÓN?',
        explanation: 'Comprende la estructura de las decisiones',
        options: [
          ExerciseOption(id: 'opt_1', text: 'Una salida'),
          ExerciseOption(id: 'opt_2', text: 'Dos salidas (Sí y No)'),
          ExerciseOption(id: 'opt_3', text: 'Tres o más salidas'),
          ExerciseOption(id: 'opt_4', text: 'No necesita salidas'),
        ],
        correctAnswers: ['opt_2'],
        feedback:
            '¡Exacto! Una decisión tiene DOS salidas: una para SÍ y otra para NO.',
        points: 15,
        relatedNodeType: NodeType.decision,
      ),
    ];
  }

  // ========== EJERCICIOS AVANZADOS ==========

  List<Exercise> _getAdvancedExercises() {
    return [
      // Ejercicio 1: Identificar conector
      Exercise(
        id: 'adv_001',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.advanced,
        difficulty: ExerciseDifficulty.hard,
        question: '¿Para qué se usa el CONECTOR (círculo)?',
        explanation: 'Comprende el propósito de los conectores',
        options: [
          ExerciseOption(
            id: 'opt_1',
            text: 'Para conectar partes del diagrama en diferentes páginas',
//            nodeType: NodeType.connector,
          ),
          ExerciseOption(
            id: 'opt_2',
            text: 'Para indicar el inicio del programa',
          ),
          ExerciseOption(
            id: 'opt_3',
            text: 'Para representar bucles',
          ),
        ],
        correctAnswers: ['opt_1'],
        feedback:
            '¡Perfecto! Los conectores unen partes del diagrama que están separadas.',
        points: 20,
//        relatedNodeType: NodeType.connector,
      ),

      // Ejercicio 2: Identificar comentario
      Exercise(
        id: 'adv_002',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.advanced,
        difficulty: ExerciseDifficulty.medium,
        question: '¿Qué símbolo se usa para agregar NOTAS o COMENTARIOS?',
        explanation: 'Identifica el símbolo de documentación',
        options: [
          ExerciseOption(
            id: 'opt_comment',
            text: 'Rectángulo con esquina doblada',
//            nodeType: NodeType.comment,
            description: 'Para anotaciones',
          ),
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo normal',
            nodeType: NodeType.process,
          ),
          ExerciseOption(
            id: 'opt_connector',
            text: 'Círculo',
//            nodeType: NodeType.connector,
          ),
        ],
        correctAnswers: ['opt_comment'],
        feedback:
            '¡Excelente! El rectángulo con esquina doblada es para COMENTARIOS.',
        points: 15,
//        relatedNodeType: NodeType.comment,
      ),

      // Ejercicio 3: Identificar subproceso
      Exercise(
        id: 'adv_003',
        type: ExerciseType.multipleChoice,
        category: ExerciseCategory.advanced,
        difficulty: ExerciseDifficulty.hard,
        question: '¿Qué símbolo representa un SUBPROCESO o FUNCIÓN?',
        explanation: 'Identifica símbolos avanzados',
        options: [
          ExerciseOption(
            id: 'opt_subprocess',
            text: 'Rectángulo con doble línea vertical',
            nodeType: NodeType.predefinedProcess,
            description: 'Para funciones',
          ),
          ExerciseOption(
            id: 'opt_process',
            text: 'Rectángulo simple',
            nodeType: NodeType.process,
          ),
          ExerciseOption(
            id: 'opt_loop',
            text: 'Hexágono',
            nodeType: NodeType.preparation,
          ),
        ],
        correctAnswers: ['opt_subprocess'],
        feedback:
            '¡Perfecto! El rectángulo con doble línea representa SUBPROCESOS.',
        points: 20,
        relatedNodeType: NodeType.predefinedProcess,
      ),
    ];
  }
}
