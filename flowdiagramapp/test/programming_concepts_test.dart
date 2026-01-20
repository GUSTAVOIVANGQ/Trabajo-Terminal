/// Test para validar la generación de código de los conceptos de programación
/// Fase 1: Nodos simples (scanf, printf, declareInt, assignment, function, struct, pointer)

import '../lib/models/diagram_node.dart';
import '../lib/models/code_generator.dart';

void main() {
  print('=== TEST: Conceptos de Programación - Fase 1 ===\n');

  // Crear nodo terminal de inicio (requerido por el generador)
  final startNode = DiagramNode(
    id: 'start',
    type: NodeType.terminal,
    position: const Offset(100, 50),
    text: 'Inicio',
  );

  // Crear nodo terminal de fin
  final endNode = DiagramNode(
    id: 'end',
    type: NodeType.terminal,
    position: const Offset(100, 500),
    text: 'Fin',
  );

  print('1️⃣ TEST: scanf() - Entrada de datos');
  print('   Símbolo ISO 5807: Paralelogramo (data)');
  _testScanfConcept(startNode, endNode);
  print('');

  print('2️⃣ TEST: printf() - Salida de datos');
  print('   Símbolo ISO 5807: Paralelogramo (data)');
  _testPrintfConcept(startNode, endNode);
  print('');

  print('3️⃣ TEST: Declarar int - Declaración de variable');
  print('   Símbolo ISO 5807: Rectángulo (process)');
  _testDeclareIntConcept(startNode, endNode);
  print('');

  print('4️⃣ TEST: Asignación - Asignación de valor');
  print('   Símbolo ISO 5807: Rectángulo (process)');
  _testAssignmentConcept(startNode, endNode);
  print('');

  print('5️⃣ TEST: Función - Llamada a subproceso');
  print('   Símbolo ISO 5807: Rectángulo con doble línea (predefinedProcess)');
  _testFunctionConcept(startNode, endNode);
  print('');

  print('6️⃣ TEST: Struct - Declaración de estructura');
  print('   Símbolo ISO 5807: Rectángulo (process)');
  _testStructConcept(startNode, endNode);
  print('');

  print('7️⃣ TEST: Puntero - Declaración de puntero');
  print('   Símbolo ISO 5807: Rectángulo (process)');
  _testPointerConcept(startNode, endNode);
  print('');

  print('=== TODOS LOS TESTS COMPLETADOS ===');
}

void _testScanfConcept(DiagramNode startNode, DiagramNode endNode) {
  final scanfNode = DiagramNode(
    id: 'scanf1',
    type: NodeType.data,
    position: const Offset(100, 150),
    text: 'scanf("%d", &x)',
  );

  final nodes = [startNode, scanfNode, endNode];
  final connections = [
    Connection(source: startNode, target: scanfNode, label: ''),
    Connection(source: scanfNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${scanfNode.text}"');
  print('   Tipo de nodo: ${scanfNode.type}');

  if (code.contains('scanf("%d", &x)')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró scanf en el código');
  }

  _printGeneratedCode(code);
}

void _testPrintfConcept(DiagramNode startNode, DiagramNode endNode) {
  final printfNode = DiagramNode(
    id: 'printf1',
    type: NodeType.data,
    position: const Offset(100, 150),
    text: 'printf("Resultado: %d\\n", x)',
  );

  final nodes = [startNode, printfNode, endNode];
  final connections = [
    Connection(source: startNode, target: printfNode, label: ''),
    Connection(source: printfNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${printfNode.text}"');
  print('   Tipo de nodo: ${printfNode.type}');

  if (code.contains('printf')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró printf en el código');
  }

  _printGeneratedCode(code);
}

void _testDeclareIntConcept(DiagramNode startNode, DiagramNode endNode) {
  final declareNode = DiagramNode(
    id: 'declare1',
    type: NodeType.process,
    position: const Offset(100, 150),
    text: 'int x = 0',
  );

  final nodes = [startNode, declareNode, endNode];
  final connections = [
    Connection(source: startNode, target: declareNode, label: ''),
    Connection(source: declareNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${declareNode.text}"');
  print('   Tipo de nodo: ${declareNode.type}');

  if (code.contains('int x = 0')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró la declaración en el código');
  }

  _printGeneratedCode(code);
}

void _testAssignmentConcept(DiagramNode startNode, DiagramNode endNode) {
  final assignNode = DiagramNode(
    id: 'assign1',
    type: NodeType.process,
    position: const Offset(100, 150),
    text: 'x = 10',
  );

  final nodes = [startNode, assignNode, endNode];
  final connections = [
    Connection(source: startNode, target: assignNode, label: ''),
    Connection(source: assignNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${assignNode.text}"');
  print('   Tipo de nodo: ${assignNode.type}');

  if (code.contains('x = 10')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró la asignación en el código');
  }

  _printGeneratedCode(code);
}

void _testFunctionConcept(DiagramNode startNode, DiagramNode endNode) {
  final functionNode = DiagramNode(
    id: 'func1',
    type: NodeType.predefinedProcess,
    position: const Offset(100, 150),
    text: 'miFuncion()',
  );

  final nodes = [startNode, functionNode, endNode];
  final connections = [
    Connection(source: startNode, target: functionNode, label: ''),
    Connection(source: functionNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${functionNode.text}"');
  print('   Tipo de nodo: ${functionNode.type}');

  if (code.contains('miFuncion()')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró la llamada a función en el código');
  }

  _printGeneratedCode(code);
}

void _testStructConcept(DiagramNode startNode, DiagramNode endNode) {
  final structNode = DiagramNode(
    id: 'struct1',
    type: NodeType.process,
    position: const Offset(100, 150),
    text: 'struct Punto { int x; int y; }',
  );

  final nodes = [startNode, structNode, endNode];
  final connections = [
    Connection(source: startNode, target: structNode, label: ''),
    Connection(source: structNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${structNode.text}"');
  print('   Tipo de nodo: ${structNode.type}');

  if (code.contains('struct Punto')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró la definición struct en el código');
  }

  _printGeneratedCode(code);
}

void _testPointerConcept(DiagramNode startNode, DiagramNode endNode) {
  final pointerNode = DiagramNode(
    id: 'ptr1',
    type: NodeType.process,
    position: const Offset(100, 150),
    text: 'int *ptr = NULL',
  );

  final nodes = [startNode, pointerNode, endNode];
  final connections = [
    Connection(source: startNode, target: pointerNode, label: ''),
    Connection(source: pointerNode, target: endNode, label: ''),
  ];

  final code = CodeGenerator.generateCode(
    nodes,
    connections,
    ProgrammingLanguage.c,
  );

  print('   Texto del nodo: "${pointerNode.text}"');
  print('   Tipo de nodo: ${pointerNode.type}');

  if (code.contains('int *ptr = NULL')) {
    print('   ✅ Código generado correctamente');
  } else {
    print('   ❌ Error: No se encontró la declaración de puntero en el código');
  }

  _printGeneratedCode(code);
}

void _printGeneratedCode(String code) {
  print('   --- Código generado (resumen) ---');
  final lines = code.split('\n');
  // Mostrar solo las líneas relevantes (dentro de main)
  bool inMain = false;
  for (var line in lines) {
    if (line.contains('int main()')) {
      inMain = true;
    }
    if (inMain && !line.contains('//') && line.trim().isNotEmpty) {
      print('   $line');
    }
    if (line.contains('return 0;')) {
      break;
    }
  }
  print('   ---------------------------------');
}
