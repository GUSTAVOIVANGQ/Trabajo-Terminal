/// Modelo para un paso individual del tutorial
class TutorialStep {
  final String title;
  final String description;
  final String? imageAsset;
  final String? nodeType; // Tipo de nodo relacionado (opcional)
  final List<String> keyPoints; // Puntos clave para aprender
  final String? example; // Ejemplo de código o uso

  TutorialStep({
    required this.title,
    required this.description,
    this.imageAsset,
    this.nodeType,
    this.keyPoints = const [],
    this.example,
  });
}

/// Categoría de tutorial
enum TutorialCategory {
  welcome, // Tutorial de bienvenida
  basics, // Conceptos básicos
  nodes, // Nodos individuales
  connections, // Conexiones entre nodos
  validation, // Validación de diagramas
  codeGeneration, // Generación de código
}

/// Modelo para una página completa de tutorial
class TutorialPage {
  final String id;
  final String title;
  final String subtitle;
  final TutorialCategory category;
  final List<TutorialStep> steps;
  final int estimatedMinutes; // Tiempo estimado de lectura

  TutorialPage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.steps,
    this.estimatedMinutes = 5,
  });
}
