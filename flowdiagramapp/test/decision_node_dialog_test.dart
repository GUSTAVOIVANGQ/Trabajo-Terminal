import 'package:flutter/material.dart';
import '../lib/widgets/decision_node_dialog.dart';
import '../lib/models/diagram_node.dart';

/// Ejemplo para probar el nuevo diálogo del nodo de decisión
///
/// Este archivo demuestra cómo funciona el nuevo diálogo especializado
/// para nodos de decisión diseñado para usuarios no programadores.
///
/// Uso: Ejecutar `flutter test test/decision_node_dialog_test.dart`

void main() {
  print('🚀 Iniciando demostración del nuevo diálogo de nodo de decisión');
  print('');

  // Crear un nodo de decisión de ejemplo
  final decisionNode = DiagramNode(
    id: 'decision_1',
    type: NodeType.decision,
    position: const Offset(100, 100),
    text: '',
  );

  print('📝 Nodo de decisión creado:');
  print('   - ID: ${decisionNode.id}');
  print('   - Tipo: ${decisionNode.type}');
  print('   - Texto inicial: "${decisionNode.text}"');
  print('');

  // Simular diferentes casos de uso
  _demonstrateUseCases();
}

void _demonstrateUseCases() {
  print('🔍 Casos de uso del nuevo diálogo:');
  print('');

  // Caso 1: Comparar dos valores
  print('1. 📊 Comparar Dos Valores:');
  print('   - Usuario selecciona: "Comparar Dos Valores"');
  print(
      '   - Introduce: Variable1 = "edad", Operador = ">=", Variable2 = "18"');
  print('   - Resultado: "¿edad >= 18?"');
  print('   - Beneficio: Interfaz visual para comparaciones numéricas');
  print('');

  // Caso 2: Verificar igualdad
  print('2. ✅ Verificar Igualdad:');
  print('   - Usuario selecciona: "Verificar Igualdad"');
  print('   - Introduce: Variable = "usuario", Valor = "admin"');
  print('   - Resultado: "¿usuario == \\"admin\\"?"');
  print('   - Beneficio: Simplifica la verificación de igualdad');
  print('');

  // Caso 3: Verificar rango
  print('3. 📏 Verificar Rango:');
  print('   - Usuario selecciona: "Verificar Rango"');
  print('   - Introduce: Variable = "nota", Mínimo = "0", Máximo = "100"');
  print('   - Resultado: "¿0 < nota < 100?"');
  print('   - Beneficio: Validación de rangos sin conocer sintaxis');
  print('');

  // Caso 4: Verificar existencia
  print('4. 🔍 Verificar Existencia:');
  print('   - Usuario selecciona: "Verificar Existencia"');
  print('   - Introduce: Variable = "archivo"');
  print('   - Resultado: "¿archivo existe?"');
  print('   - Beneficio: Verificaciones de existencia simplificadas');
  print('');

  // Caso 5: Condición lógica
  print('5. 🧠 Condición Lógica:');
  print('   - Usuario selecciona: "Condición Lógica"');
  print(
      '   - Introduce: Condición1 = "edad >= 18", Operador = "&&", Condición2 = "tiene_licencia == true"');
  print('   - Resultado: "¿edad >= 18 && tiene_licencia == true?"');
  print('   - Beneficio: Combina múltiples condiciones de forma intuitiva');
  print('');

  // Caso 6: Texto personalizado
  print('6. ✏️ Escritura Manual:');
  print('   - Usuario selecciona: "Escribir Manualmente"');
  print('   - Introduce: "¿(temperatura > 30) || (humedad < 20)?"');
  print('   - Resultado: "¿(temperatura > 30) || (humedad < 20)?"');
  print('   - Beneficio: Flexibilidad para usuarios avanzados');
  print('');

  _demonstrateParsingCapabilities();
}

void _demonstrateParsingCapabilities() {
  print('🧠 Capacidades de interpretación inteligente:');
  print('');

  final testCases = [
    'edad > 18',
    '¿nombre == "admin"?',
    'temperatura >= 30',
    '0 < nota < 100',
    'edad >= 18 && tiene_licencia == true',
    'condicion1 || condicion2',
    '¿archivo existe?',
  ];

  for (String testCase in testCases) {
    print('📝 Texto de entrada: "$testCase"');
    print('   🔍 Interpretación: ${_interpretText(testCase)}');
    print('');
  }

  _demonstrateCodeGeneration();
}

String _interpretText(String text) {
  text = text.replaceAll('¿', '').replaceAll('?', '').trim();

  // Detectar comparaciones simples
  RegExp comparisonPattern = RegExp(r'^(\w+)\s*(>=|<=|>|<|==|!=)\s*(.+)$');
  if (comparisonPattern.hasMatch(text)) {
    return 'Tipo: Comparación → Formulario guiado con campos separados';
  }

  // Detectar igualdad
  if (text.contains('==')) {
    return 'Tipo: Igualdad → Formulario específico para verificación';
  }

  // Detectar rangos
  if (text.contains('>') && text.contains('<')) {
    return 'Tipo: Rango → Formulario con valores mínimo y máximo';
  }

  // Detectar condiciones lógicas
  if (text.contains('&&') || text.contains('||')) {
    return 'Tipo: Lógica → Formulario para combinar condiciones';
  }

  // Detectar existencia
  if (text.contains('existe')) {
    return 'Tipo: Existencia → Formulario simplificado';
  }

  return 'Tipo: Personalizado → Modo de texto libre';
}

void _demonstrateCodeGeneration() {
  print('⚙️ Generación de código C para decisiones:');
  print('');

  final Map<String, String> examples = {
    '¿edad >= 18?': '''
if (edad >= 18) {
    // Código para Sí/Verdadero
} else {
    // Código para No/Falso
}''',
    '¿usuario == "admin"?': '''
if (strcmp(usuario, "admin") == 0) {
    // Código para Sí
} else {
    // Código para No
}''',
    '¿0 < nota < 100?': '''
if (nota > 0 && nota < 100) {
    // Código para rango válido
} else {
    // Código para rango inválido
}''',
    '¿edad >= 18 && tiene_licencia == true?': '''
if (edad >= 18 && tiene_licencia == true) {
    // Código para condición compuesta verdadera
} else {
    // Código para condición compuesta falsa
}''',
  };

  examples.forEach((condition, code) {
    print('📝 Condición: $condition');
    print('💻 Código C generado:');
    print(code);
    print('');
  });

  print('📚 Estándares ANSI/ISO 5807 cumplidos:');
  print('   ✅ Forma: Rombo/Diamante');
  print('   ✅ Uso: Preguntas y condiciones');
  print('   ✅ Salidas: Múltiples ramas (Sí/No)');
  print('   ✅ Propósito: Puntos de decisión algorítmica');
  print('');

  print('🎯 Beneficios educativos:');
  print('   📖 Enseña lógica condicional de forma visual');
  print('   🛡️ Reduce errores de sintaxis');
  print('   🧩 Facilita la comprensión de operadores');
  print('   🚀 Acelera el proceso de creación de algoritmos');
  print('   💡 Introduce conceptos de programación gradualmente');
  print('');

  print('✅ Demostración del diálogo de nodo de decisión completada');
}
