import 'package:flutter/material.dart';
import '../lib/widgets/process_node_dialog.dart';
import '../lib/models/diagram_node.dart';

/// Ejemplo para probar el nuevo diálogo del nodo de proceso
///
/// Este archivo demuestra cómo funciona el nuevo diálogo especializado
/// para nodos de proceso diseñado para usuarios no programadores.
///
/// Uso: Ejecutar `flutter test test/process_node_dialog_test.dart`

void main() {
  print('🚀 Iniciando demostración del nuevo diálogo de nodo de proceso');
  print('');

  // Crear un nodo de proceso de ejemplo
  final processNode = DiagramNode(
    id: 'test-process-1',
    type: NodeType.process,
    position: Offset(100, 100),
    text: 'suma = a + b', // Texto existente para probar el parseo
  );

  print('📝 Nodo de proceso creado:');
  print('   - ID: ${processNode.id}');
  print('   - Tipo: ${processNode.type}');
  print('   - Texto inicial: "${processNode.text}"');
  print('');

  // Simular diferentes casos de uso
  _demonstrateUseCases();
}

void _demonstrateUseCases() {
  print('🔍 Casos de uso del nuevo diálogo:');
  print('');

  // Caso 1: Asignación simple
  print('1. 📋 Asignación Simple:');
  print('   - Usuario selecciona: "Asignación Simple"');
  print('   - Introduce: Variable = "edad", Valor = "25"');
  print('   - Resultado: "edad = 25"');
  print('   - Beneficio: Usuario no necesita conocer sintaxis');
  print('');

  // Caso 2: Operación matemática
  print('2. 🧮 Operación Matemática:');
  print('   - Usuario selecciona: "Operación Matemática"');
  print(
      '   - Introduce: Resultado = "suma", Variable1 = "a", Operador = "+", Variable2 = "b"');
  print('   - Resultado: "suma = a + b"');
  print('   - Beneficio: Interfaz visual para operadores matemáticos');
  print('');

  // Caso 3: Incremento
  print('3. ⬆️ Incrementar Variable:');
  print('   - Usuario selecciona: "Incrementar Variable"');
  print('   - Introduce: Variable = "contador"');
  print('   - Resultado: "contador = contador + 1"');
  print('   - Beneficio: Operación común simplificada');
  print('');

  // Caso 4: Decremento
  print('4. ⬇️ Decrementar Variable:');
  print('   - Usuario selecciona: "Decrementar Variable"');
  print('   - Introduce: Variable = "contador"');
  print('   - Resultado: "contador = contador - 1"');
  print('   - Beneficio: Operación común simplificada');
  print('');

  // Caso 5: Texto personalizado
  print('5. ✏️ Escritura Manual:');
  print('   - Usuario selecciona: "Escribir Manualmente"');
  print('   - Introduce: "resultado = (a + b) * c"');
  print('   - Resultado: "resultado = (a + b) * c"');
  print('   - Beneficio: Flexibilidad para usuarios avanzados');
  print('');

  _demonstrateParsingCapabilities();
}

void _demonstrateParsingCapabilities() {
  print('🧠 Capacidades de interpretación inteligente:');
  print('');

  final testCases = [
    'suma = a + b',
    'edad = 25',
    'contador = contador + 1',
    'i = i - 1',
    'resultado = x * y',
    'division = num / den',
    'modulo = a % b',
    'contador++',
    'i--',
    'variable = otro_valor',
  ];

  for (final testCase in testCases) {
    final interpretedType = _interpretText(testCase);
    print('   • "$testCase" → $interpretedType');
  }

  print('');
  print('✨ Ventajas del nuevo diálogo:');
  print('   • Reduce la curva de aprendizaje para usuarios no programadores');
  print('   • Previene errores de sintaxis mediante interfaz guiada');
  print('   • Proporciona vista previa en tiempo real');
  print('   • Permite aprendizaje progresivo (ver código generado)');
  print('   • Mantiene flexibilidad para usuarios avanzados');
  print('   • Cumple estándares ANSI/ISO 5807');
  print('');

  _demonstrateCodeGeneration();
}

String _interpretText(String text) {
  text = text.trim();

  // Detectar operación aritmética
  if (RegExp(r'^\w+\s*=\s*\w+\s*[+\-*/]\s*\w+$').hasMatch(text)) {
    return 'Operación Matemática';
  }

  // Detectar asignación simple
  if (RegExp(r'^\w+\s*=\s*\w+$').hasMatch(text)) {
    return 'Asignación Simple';
  }

  // Detectar incremento
  if (text.contains('++') || text.contains('+ 1')) {
    return 'Incrementar Variable';
  }

  // Detectar decremento
  if (text.contains('--') || text.contains('- 1')) {
    return 'Decrementar Variable';
  }

  return 'Escritura Manual';
}

void _demonstrateCodeGeneration() {
  print('💻 Generación de código mejorada:');
  print('');
  print(
      'Con el nuevo diálogo, el proceso de generación de código es más robusto:');
  print('');
  print('Antes:');
  print('   Usuario escribe: "suma=a+b" (posibles errores de espaciado)');
  print('   Generador: Debe manejar múltiples formatos');
  print('');
  print('Ahora:');
  print('   Usuario selecciona opciones en interfaz guiada');
  print('   Sistema genera: "suma = a + b" (formato consistente)');
  print('   Generador: Recibe entrada estandarizada');
  print('');
  print('🎯 Próximos pasos sugeridos:');
  print('   1. Implementar diálogos similares para otros tipos de nodos');
  print('   2. Agregar validación de tipos de datos');
  print('   3. Incluir plantillas de algoritmos comunes');
  print('   4. Implementar ayuda contextual');
  print('   5. Agregar ejemplos interactivos');
}
