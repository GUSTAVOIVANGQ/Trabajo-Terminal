/// Resultado del diálogo de edición de nodos
///
/// Esta clase encapsula el resultado de la edición de un nodo,
/// incluyendo el texto del nodo y si se debe generar una estructura
/// de bucle o switch automáticamente.
class NodeDialogResult {
  final String text;
  final bool generateLoopStructure;
  final String? loopVariable;
  final String? loopLimit;
  final String? loopCondition;

  // Campos para generación de estructura switch-case
  final bool generateSwitchStructure;
  final String? switchVariable;
  final List<SwitchCaseData>? switchCases;
  final bool hasDefaultCase;

  NodeDialogResult({
    required this.text,
    this.generateLoopStructure = false,
    this.loopVariable,
    this.loopLimit,
    this.loopCondition,
    this.generateSwitchStructure = false,
    this.switchVariable,
    this.switchCases,
    this.hasDefaultCase = true,
  });

  /// Constructor factory para crear un resultado simple (solo texto)
  factory NodeDialogResult.simple(String text) {
    return NodeDialogResult(text: text);
  }
}

/// Datos de un caso del switch
class SwitchCaseData {
  final String value;
  final String label;

  SwitchCaseData({
    required this.value,
    required this.label,
  });
}
