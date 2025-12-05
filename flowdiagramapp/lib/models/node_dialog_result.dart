/// Resultado del diálogo de edición de nodos
///
/// Esta clase encapsula el resultado de la edición de un nodo,
/// incluyendo el texto del nodo y si se debe generar una estructura
/// de bucle automáticamente.
class NodeDialogResult {
  final String text;
  final bool generateLoopStructure;
  final String? loopVariable;
  final String? loopLimit;
  final String? loopCondition;

  NodeDialogResult({
    required this.text,
    this.generateLoopStructure = false,
    this.loopVariable,
    this.loopLimit,
    this.loopCondition,
  });

  /// Constructor factory para crear un resultado simple (solo texto)
  factory NodeDialogResult.simple(String text) {
    return NodeDialogResult(text: text);
  }
}
