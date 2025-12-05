/// Modelo para ejercicios de comprensión de diagramas de flujo
/// Enfocado en el Nivel 2 de la Taxonomía de Bloom (Comprensión)

import 'diagram_node.dart';

/// Tipo de ejercicio según habilidades de comprensión
enum ExerciseType {
  matching, // Relacionar conceptos con símbolos
  multipleChoice, // Identificar el símbolo correcto
  ordering, // Ordenar pasos de un algoritmo
  trueOrFalse, // Distinguir afirmaciones correctas
  dragAndDrop, // Arrastrar elementos a su lugar correcto
}

/// Categoría del ejercicio
enum ExerciseCategory {
  basicSymbols, // Símbolos básicos (inicio, fin, proceso)
  controlFlow, // Estructuras de control (decisión, bucle)
  dataFlow, // Entrada, salida, variables
  connections, // Conexiones y flujo lógico
  advanced, // Conectores, comentarios, subprocesos
}

/// Nivel de dificultad
enum ExerciseDifficulty {
  easy, // 3-4 opciones, conceptos básicos
  medium, // 5-6 opciones, requiere distinción
  hard, // 6+ opciones, requiere comparación
}

/// Modelo de un ejercicio individual
class Exercise {
  final String id;
  final ExerciseType type;
  final ExerciseCategory category;
  final ExerciseDifficulty difficulty;
  final String question;
  final String? explanation; // Explicación adicional para la pregunta
  final List<ExerciseOption> options;
  final List<String> correctAnswers; // IDs de las respuestas correctas
  final String feedback; // Retroalimentación al completar
  final int points; // Puntos otorgados
  final NodeType? relatedNodeType; // Tipo de nodo relacionado (opcional)

  Exercise({
    required this.id,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.question,
    this.explanation,
    required this.options,
    required this.correctAnswers,
    required this.feedback,
    required this.points,
    this.relatedNodeType,
  });
}

/// Opción de respuesta para un ejercicio
class ExerciseOption {
  final String id;
  final String text;
  final NodeType? nodeType; // Para ejercicios que muestran símbolos
  final String? imageUrl; // URL o asset para imagen (opcional)
  final String? description; // Descripción adicional

  ExerciseOption({
    required this.id,
    required this.text,
    this.nodeType,
    this.imageUrl,
    this.description,
  });
}

/// Resultado de un ejercicio completado
class ExerciseResult {
  final String exerciseId;
  final List<String> userAnswers;
  final List<String> correctAnswers;
  final bool isCorrect;
  final int pointsEarned;
  final DateTime completedAt;
  final int timeSpentSeconds;

  ExerciseResult({
    required this.exerciseId,
    required this.userAnswers,
    required this.correctAnswers,
    required this.isCorrect,
    required this.pointsEarned,
    required this.completedAt,
    required this.timeSpentSeconds,
  });

  /// Calcula el porcentaje de acierto
  double get accuracy {
    if (correctAnswers.isEmpty) return 0.0;
    int correct = 0;
    for (var answer in userAnswers) {
      if (correctAnswers.contains(answer)) {
        correct++;
      }
    }
    return (correct / correctAnswers.length) * 100;
  }

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'exerciseId': exerciseId,
      'userAnswers': userAnswers.join(','),
      'correctAnswers': correctAnswers.join(','),
      'isCorrect': isCorrect ? 1 : 0,
      'pointsEarned': pointsEarned,
      'completedAt': completedAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  /// Crea desde Map
  factory ExerciseResult.fromMap(Map<String, dynamic> map) {
    return ExerciseResult(
      exerciseId: map['exerciseId'],
      userAnswers: (map['userAnswers'] as String).split(','),
      correctAnswers: (map['correctAnswers'] as String).split(','),
      isCorrect: map['isCorrect'] == 1,
      pointsEarned: map['pointsEarned'],
      completedAt: DateTime.parse(map['completedAt']),
      timeSpentSeconds: map['timeSpentSeconds'],
    );
  }
}

/// Progreso del usuario en ejercicios
class ExerciseProgress {
  final String userId;
  final ExerciseCategory category;
  final int totalExercises;
  final int completedExercises;
  final int totalPoints;
  final int earnedPoints;
  final double averageAccuracy;
  final int totalTimeSpentSeconds;

  ExerciseProgress({
    required this.userId,
    required this.category,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalPoints,
    required this.earnedPoints,
    required this.averageAccuracy,
    required this.totalTimeSpentSeconds,
  });

  /// Calcula el porcentaje de progreso
  double get progressPercentage {
    if (totalExercises == 0) return 0.0;
    return (completedExercises / totalExercises) * 100;
  }

  /// Calcula el porcentaje de puntos obtenidos
  double get pointsPercentage {
    if (totalPoints == 0) return 0.0;
    return (earnedPoints / totalPoints) * 100;
  }

  /// Determina si la categoría está completa
  bool get isCompleted => completedExercises >= totalExercises;

  /// Convierte a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category.toString(),
      'totalExercises': totalExercises,
      'completedExercises': completedExercises,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'averageAccuracy': averageAccuracy,
      'totalTimeSpentSeconds': totalTimeSpentSeconds,
    };
  }

  /// Crea desde Map
  factory ExerciseProgress.fromMap(Map<String, dynamic> map) {
    return ExerciseProgress(
      userId: map['userId'],
      category: ExerciseCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
      ),
      totalExercises: map['totalExercises'],
      completedExercises: map['completedExercises'],
      totalPoints: map['totalPoints'],
      earnedPoints: map['earnedPoints'],
      averageAccuracy: map['averageAccuracy'],
      totalTimeSpentSeconds: map['totalTimeSpentSeconds'],
    );
  }
}
