import 'package:flutter/material.dart';
import '../models/saved_diagram.dart';
import '../models/diagram_node.dart';

/// Definiciones de las 20 plantillas educativas basadas en el temario
/// de Fundamentos de Programación (ESCOM - ISC 2020)
///
/// UNIDAD I: Programación Estructurada (16 plantillas)
/// UNIDAD II: Apuntadores y Funciones (4 plantillas)

class TemplateDefinitions {
  /// Lista de nombres de todas las plantillas esperadas
  static List<String> get expectedTemplateNames => [
        // UNIDAD I - Nivel 1: Básico - Secuencia
        '01. Hola Mundo',
        '02. Declaración y Tipos de Datos',
        '03. Calculadora Básica',
        '04. Conversión de Temperatura',
        // UNIDAD I - Nivel 2: Decisiones - Selección
        '05. Par o Impar',
        '06. Mayor de Tres Números',
        '07. Calculadora con Menú',
        '08. Clasificación de Triángulos',
        // UNIDAD I - Nivel 3: Iteración - Bucles
        '09. Contador While',
        '10. Validación de Entrada (Do-While)',
        '11. Tabla de Multiplicar (For)',
        '12. Factorial Iterativo',
        // UNIDAD I - Nivel 4: Arreglos
        '13. Suma de Arreglo',
        '14. Búsqueda Secuencial',
        '15. Ordenamiento Burbuja',
        '16. Ordenamiento Selección',
        // UNIDAD II - Nivel 5: Funciones y Apuntadores
        '17. Función Suma',
        '18. Función Factorial',
        '19. Intercambio (Swap)',
        '20. Apuntadores y Arreglos',
        // BENCHMARK - Plantillas de medición de rendimiento
        'BM-10. Benchmark 10 Nodos',
        'BM-25. Benchmark 25 Nodos',
        'BM-50. Benchmark 50 Nodos',
        'BM-75. Benchmark 75 Nodos',
        'BM-100. Benchmark 100 Nodos',
      ];

  // ============================================================
  // UNIDAD I - NIVEL 1: BÁSICO - SECUENCIA
  // ============================================================

  /// P1: Hola Mundo - Primer programa básico
  static Future<SavedDiagram> createHolaMundoTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(420, 50),
      text:
          "/* Programa básico que muestra un mensaje en pantalla.\nConcepto: printf() - salida estándar */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_2",
      type: NodeType.data,
      position: const Offset(250, 150),
      text: "Escribir \"Hola Mundo\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_3",
      type: NodeType.terminal,
      position: const Offset(250, 250),
      text: "Fin",
    );

    final nodes = [commentNode, startNode, outputNode, endNode];

    final connections = [
      Connection(source: startNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "01. Hola Mundo",
      description:
          "UNIDAD I - Nivel Básico: Primer programa que muestra un mensaje en pantalla usando printf()",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P2: Declaración y Tipos de Datos
  static Future<SavedDiagram> createTiposDatosTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(420, 50),
      text:
          "/* Declara variables de tipo int, float y char.\nConcepto: Tipos de datos primitivos en C */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final declareIntNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(250, 150),
      text: "int x = 10",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'x',
        'value': '10'
      },
    );

    final declareFloatNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(250, 250),
      text: "float y = 3.14",
      metadata: {
        'processType': 'initialization',
        'varType': 'float',
        'varName': 'y',
        'value': '3.14'
      },
    );

    final declareCharNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(250, 350),
      text: "char z = 'A'",
      metadata: {
        'processType': 'initialization',
        'varType': 'char',
        'varName': 'z',
        'value': "'A'"
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(250, 450),
      text: "Escribir x, y, z",
      metadata: {'isOutput': true, 'outputType': 'variables'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(250, 550),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareIntNode,
      declareFloatNode,
      declareCharNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareIntNode, label: ""),
      Connection(source: declareIntNode, target: declareFloatNode, label: ""),
      Connection(source: declareFloatNode, target: declareCharNode, label: ""),
      Connection(source: declareCharNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "02. Declaración y Tipos de Datos",
      description:
          "UNIDAD I - Nivel Básico: Declaración de variables int, float y char con inicialización",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P3: Calculadora Básica - Operaciones aritméticas
  static Future<SavedDiagram> createCalculadoraBasicaTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(420, 50),
      text:
          "/* Realiza las 5 operaciones aritméticas básicas.\nConcepto: Operadores +, -, *, /, % */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    // Declaración de variables de entrada (agrupadas)
    final declareInputVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(250, 150),
      text: "int a, b",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['a', 'b']
      },
    );

    // Declaración de variables de resultado (agrupadas)
    final declareResultVarsNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(250, 250),
      text: "int suma, resta, multiplicacion, division, modulo",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['suma', 'resta', 'multiplicacion', 'division', 'modulo']
      },
    );

    // Entrada de datos
    final inputANode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(250, 350),
      text: "Leer a",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'a'},
    );

    final inputBNode = DiagramNode(
      id: "input_${baseId}_5",
      type: NodeType.data,
      position: const Offset(250, 450),
      text: "Leer b",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'b'},
    );

    // Operaciones aritméticas
    final sumNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(250, 550),
      text: "suma = a + b",
      metadata: {'processType': 'arithmetic', 'operator': '+'},
    );

    final subNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(250, 650),
      text: "resta = a - b",
      metadata: {'processType': 'arithmetic', 'operator': '-'},
    );

    final mulNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(250, 750),
      text: "multiplicacion = a * b",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final divNode = DiagramNode(
      id: "process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(250, 850),
      text: "division = a / b",
      metadata: {'processType': 'arithmetic', 'operator': '/'},
    );

    final modNode = DiagramNode(
      id: "process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(250, 950),
      text: "modulo = a % b",
      metadata: {'processType': 'arithmetic', 'operator': '%'},
    );

    // Salida de resultados
    final outputNode = DiagramNode(
      id: "output_${baseId}_11",
      type: NodeType.data,
      position: const Offset(250, 1050),
      text: "Escribir suma, resta, multiplicacion, division, modulo",
      metadata: {'isOutput': true, 'outputType': 'variables'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_12",
      type: NodeType.terminal,
      position: const Offset(250, 1150),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareInputVarsNode,
      declareResultVarsNode,
      inputANode,
      inputBNode,
      sumNode,
      subNode,
      mulNode,
      divNode,
      modNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareInputVarsNode, label: ""),
      Connection(
          source: declareInputVarsNode,
          target: declareResultVarsNode,
          label: ""),
      Connection(source: declareResultVarsNode, target: inputANode, label: ""),
      Connection(source: inputANode, target: inputBNode, label: ""),
      Connection(source: inputBNode, target: sumNode, label: ""),
      Connection(source: sumNode, target: subNode, label: ""),
      Connection(source: subNode, target: mulNode, label: ""),
      Connection(source: mulNode, target: divNode, label: ""),
      Connection(source: divNode, target: modNode, label: ""),
      Connection(source: modNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "03. Calculadora Básica",
      description:
          "UNIDAD I - Nivel Básico: Operaciones aritméticas (+, -, *, /, %) con dos números",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P4: Conversión de Temperatura
  static Future<SavedDiagram> createConversionTemperaturaTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(420, 50),
      text:
          "/* Convierte temperatura de Celsius a Fahrenheit.\nFórmula: F = (C × 9/5) + 32 */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(250, 150),
      text: "float celsius, fahrenheit",
      metadata: {
        'processType': 'declaration',
        'varType': 'float',
        'varNames': ['celsius', 'fahrenheit']
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(250, 250),
      text: "Leer celsius",
      metadata: {'isOutput': false, 'inputType': 'float', 'varName': 'celsius'},
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(250, 350),
      text: "fahrenheit = (celsius * 9.0 / 5.0) + 32.0",
      metadata: {'processType': 'arithmetic'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(250, 450),
      text: "Escribir fahrenheit",
      metadata: {'isOutput': true, 'outputType': 'float'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(250, 550),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      processNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: processNode, label: ""),
      Connection(source: processNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "04. Conversión de Temperatura",
      description:
          "UNIDAD I - Nivel Básico: Conversión de Celsius a Fahrenheit usando fórmulas matemáticas",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // ============================================================
  // UNIDAD I - NIVEL 2: DECISIONES - SELECCIÓN
  // ============================================================

  /// P5: Par o Impar
  static Future<SavedDiagram> createParImparTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Determina si un número es par o impar.\nConcepto: if-else, operador módulo (%) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    // Declaración de variable
    final declareVarNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(250, 150),
      text: "int numero",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varName': 'numero'
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(250, 250),
      text: "Leer numero",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'numero'},
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(250, 370),
      text: "numero % 2 == 0",
    );

    final outputParNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(420, 500),
      text: "Escribir \"El número es par\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputImparNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(80, 500),
      text: "Escribir \"El número es impar\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(250, 630),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarNode,
      inputNode,
      decisionNode,
      outputParNode,
      outputImparNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarNode, label: ""),
      Connection(source: declareVarNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decisionNode, label: ""),
      Connection(source: decisionNode, target: outputParNode, label: "Sí"),
      Connection(source: decisionNode, target: outputImparNode, label: "No"),
      Connection(source: outputParNode, target: endNode, label: ""),
      Connection(source: outputImparNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "05. Par o Impar",
      description:
          "UNIDAD I - Nivel Decisiones: Condicional simple if-else con operador módulo",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P6: Mayor de Tres Números
  static Future<SavedDiagram> createMayorDeTresTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(550, 50),
      text:
          "/* Encuentra el mayor de tres números.\nConcepto: if-else anidados */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(300, 140),
      text: "int a, b, c",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['a', 'b', 'c']
      },
    );

    final inputANode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(300, 230),
      text: "Leer a, b, c",
      metadata: {'isOutput': false, 'inputType': 'int'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(300, 340),
      text: "a > b",
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(480, 460),
      text: "a > c",
    );

    final decision3Node = DiagramNode(
      id: "decision_${baseId}_6",
      type: NodeType.decision,
      position: const Offset(120, 460),
      text: "b > c",
    );

    final outputANode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(580, 580),
      text: "Escribir \"Mayor: \", a",
      metadata: {'isOutput': true},
    );

    final outputCNode1 = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(380, 580),
      text: "Escribir \"Mayor: \", c",
      metadata: {'isOutput': true},
    );

    final outputBNode = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(20, 580),
      text: "Escribir \"Mayor: \", b",
      metadata: {'isOutput': true},
    );

    final outputCNode2 = DiagramNode(
      id: "output_${baseId}_10",
      type: NodeType.data,
      position: const Offset(220, 580),
      text: "Escribir \"Mayor: \", c",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_11",
      type: NodeType.terminal,
      position: const Offset(300, 700),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputANode,
      decision1Node,
      decision2Node,
      decision3Node,
      outputANode,
      outputCNode1,
      outputBNode,
      outputCNode2,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputANode, label: ""),
      Connection(source: inputANode, target: decision1Node, label: ""),
      Connection(source: decision1Node, target: decision2Node, label: "Sí"),
      Connection(source: decision1Node, target: decision3Node, label: "No"),
      Connection(source: decision2Node, target: outputANode, label: "Sí"),
      Connection(source: decision2Node, target: outputCNode1, label: "No"),
      Connection(source: decision3Node, target: outputBNode, label: "Sí"),
      Connection(source: decision3Node, target: outputCNode2, label: "No"),
      Connection(source: outputANode, target: endNode, label: ""),
      Connection(source: outputCNode1, target: endNode, label: ""),
      Connection(source: outputBNode, target: endNode, label: ""),
      Connection(source: outputCNode2, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "06. Mayor de Tres Números",
      description:
          "UNIDAD I - Nivel Decisiones: Uso de if-else anidados para encontrar el mayor",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P7: Calculadora con Menú (simula switch-case)
  static Future<SavedDiagram> createCalculadoraMenuTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(550, 50),
      text:
          "/* Calculadora con menú de opciones.\nConcepto: switch-case (if-else múltiple) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(300, 140),
      text: "float a, b, resultado",
      metadata: {
        'processType': 'declaration',
        'varType': 'float',
        'varNames': ['a', 'b', 'resultado']
      },
    );

    final declareOpcionNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(300, 230),
      text: "int opcion",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varName': 'opcion'
      },
    );

    final inputNumsNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(300, 320),
      text: "Leer a, b",
      metadata: {'isOutput': false, 'inputType': 'float'},
    );

    final outputMenuNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(300, 410),
      text: "Escribir \"1-Suma, 2-Resta, 3-Mult, 4-Div\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final inputOpcionNode = DiagramNode(
      id: "input_${baseId}_6",
      type: NodeType.data,
      position: const Offset(300, 500),
      text: "Leer opcion",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'opcion'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_7",
      type: NodeType.decision,
      position: const Offset(300, 610),
      text: "opcion == 1",
      metadata: {'switchVar': 'opcion', 'caseValue': '1'},
    );

    final processSumaNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(520, 610),
      text: "resultado = a + b",
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_9",
      type: NodeType.decision,
      position: const Offset(300, 730),
      text: "opcion == 2",
      metadata: {'switchVar': 'opcion', 'caseValue': '2'},
    );

    final processRestaNode = DiagramNode(
      id: "process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(520, 730),
      text: "resultado = a - b",
    );

    final decision3Node = DiagramNode(
      id: "decision_${baseId}_11",
      type: NodeType.decision,
      position: const Offset(300, 850),
      text: "opcion == 3",
      metadata: {'switchVar': 'opcion', 'caseValue': '3'},
    );

    final processMultNode = DiagramNode(
      id: "process_${baseId}_12",
      type: NodeType.process,
      position: const Offset(520, 850),
      text: "resultado = a * b",
    );

    final decision4Node = DiagramNode(
      id: "decision_${baseId}_13",
      type: NodeType.decision,
      position: const Offset(300, 970),
      text: "opcion == 4",
      metadata: {'switchVar': 'opcion', 'caseValue': '4'},
    );

    final processDivNode = DiagramNode(
      id: "process_${baseId}_14",
      type: NodeType.process,
      position: const Offset(520, 970),
      text: "resultado = a / b",
    );

    final outputErrorNode = DiagramNode(
      id: "output_${baseId}_15",
      type: NodeType.data,
      position: const Offset(300, 1090),
      text: "Escribir \"Opción inválida\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputResultNode = DiagramNode(
      id: "output_${baseId}_16",
      type: NodeType.data,
      position: const Offset(520, 1090),
      text: "Escribir resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_17",
      type: NodeType.terminal,
      position: const Offset(400, 1200),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      declareOpcionNode,
      inputNumsNode,
      outputMenuNode,
      inputOpcionNode,
      decision1Node,
      processSumaNode,
      decision2Node,
      processRestaNode,
      decision3Node,
      processMultNode,
      decision4Node,
      processDivNode,
      outputErrorNode,
      outputResultNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: declareOpcionNode, label: ""),
      Connection(source: declareOpcionNode, target: inputNumsNode, label: ""),
      Connection(source: inputNumsNode, target: outputMenuNode, label: ""),
      Connection(source: outputMenuNode, target: inputOpcionNode, label: ""),
      Connection(source: inputOpcionNode, target: decision1Node, label: ""),
      Connection(source: decision1Node, target: processSumaNode, label: "Sí"),
      Connection(source: decision1Node, target: decision2Node, label: "No"),
      Connection(source: processSumaNode, target: outputResultNode, label: ""),
      Connection(source: decision2Node, target: processRestaNode, label: "Sí"),
      Connection(source: decision2Node, target: decision3Node, label: "No"),
      Connection(source: processRestaNode, target: outputResultNode, label: ""),
      Connection(source: decision3Node, target: processMultNode, label: "Sí"),
      Connection(source: decision3Node, target: decision4Node, label: "No"),
      Connection(source: processMultNode, target: outputResultNode, label: ""),
      Connection(source: decision4Node, target: processDivNode, label: "Sí"),
      Connection(source: decision4Node, target: outputErrorNode, label: "No"),
      Connection(source: processDivNode, target: outputResultNode, label: ""),
      Connection(source: outputErrorNode, target: endNode, label: ""),
      Connection(source: outputResultNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "07. Calculadora con Menú",
      description:
          "UNIDAD I - Nivel Decisiones: Selección múltiple simulando switch-case",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P8: Clasificación de Triángulos
  static Future<SavedDiagram> createClasificacionTriangulosTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Clasifica un triángulo según sus lados.\nConcepto: Operadores lógicos (&&, ||) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "float a, b, c",
      metadata: {
        'processType': 'declaration',
        'varType': 'float',
        'varNames': ['a', 'b', 'c']
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 230),
      text: "Leer a, b, c",
      metadata: {'isOutput': false, 'inputType': 'float'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(280, 350),
      text: "a == b && b == c",
    );

    final outputEquiNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 350),
      text: "Escribir \"Equilátero\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_6",
      type: NodeType.decision,
      position: const Offset(280, 490),
      text: "a == b || b == c || a == c",
    );

    final outputIsoNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(500, 490),
      text: "Escribir \"Isósceles\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputEscNode = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(280, 610),
      text: "Escribir \"Escaleno\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_9",
      type: NodeType.terminal,
      position: const Offset(380, 730),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      decision1Node,
      outputEquiNode,
      decision2Node,
      outputIsoNode,
      outputEscNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decision1Node, label: ""),
      Connection(source: decision1Node, target: outputEquiNode, label: "Sí"),
      Connection(source: decision1Node, target: decision2Node, label: "No"),
      Connection(source: outputEquiNode, target: endNode, label: ""),
      Connection(source: decision2Node, target: outputIsoNode, label: "Sí"),
      Connection(source: decision2Node, target: outputEscNode, label: "No"),
      Connection(source: outputIsoNode, target: endNode, label: ""),
      Connection(source: outputEscNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "08. Clasificación de Triángulos",
      description:
          "UNIDAD I - Nivel Decisiones: Uso de operadores lógicos && y ||",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // ============================================================
  // UNIDAD I - NIVEL 3: ITERACIÓN - BUCLES
  // ============================================================

  /// P9: Contador While
  static Future<SavedDiagram> createContadorWhileTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    // Comentario explicativo
    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Cuenta del 1 al N usando while.\nConcepto: Bucle pre-condición con símbolo de decisión (rombo) */",
    );

    // Nodo inicial
    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int limite, contador",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['limite', 'contador']
      },
    );

    // Leer el límite
    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 230),
      text: "Leer limite",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'limite'},
    );

    // Inicializar contador (instrucciones antes del ciclo)
    final initNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(280, 320),
      text: "contador = 1",
      metadata: {
        'processType': 'assignment',
        'varName': 'contador',
        'value': '1'
      },
    );

    // Nodo de decisión del while (rombo) - símbolo correcto según ISO 5807
    final whileDecisionNode = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(280, 430),
      text: "contador <= limite",
      metadata: {
        'structureType': 'loop',
        'loopType': 'while',
        'role': 'loop-condition',
        'condition': 'contador <= limite'
      },
    );

    // Cuerpo del ciclo: Escribir contador
    final outputContadorNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(500, 430),
      text: "Escribir contador",
      metadata: {'isOutput': true},
    );

    // Cuerpo del ciclo: Incrementar contador
    final incrementNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(500, 540),
      text: "contador = contador + 1",
      metadata: {'processType': 'increment'},
    );

    // Después del ciclo: mensaje de fin
    final outputFinNode = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(280, 640),
      text: "Escribir \"Fin del conteo\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    // Nodo final
    final endNode = DiagramNode(
      id: "end_${baseId}_9",
      type: NodeType.terminal,
      position: const Offset(280, 740),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      initNode,
      whileDecisionNode,
      outputContadorNode,
      incrementNode,
      outputFinNode,
      endNode
    ];

    final connections = [
      // Secuencia inicial
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: initNode, label: ""),
      Connection(source: initNode, target: whileDecisionNode, label: ""),
      // Rama "Sí" - entra al cuerpo del ciclo
      Connection(
          source: whileDecisionNode, target: outputContadorNode, label: "Sí"),
      Connection(source: outputContadorNode, target: incrementNode, label: ""),
      // Loop back - regresa a la decisión del while
      Connection(
          source: incrementNode,
          target: whileDecisionNode,
          label: "",
          isLoopBack: true),
      // Rama "No" - sale del ciclo
      Connection(source: whileDecisionNode, target: outputFinNode, label: "No"),
      Connection(source: outputFinNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "09. Contador While",
      description:
          "UNIDAD I - Nivel Bucles: Bucle while con símbolo de decisión (rombo) según ISO 5807",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P10: Validación de Entrada (Do-While)
  /// Estructura correcta de do-while según diagrama estándar:
  /// Entrada -> Cuerpo (proceso) -> Condición (decisión) -> True: loop back al cuerpo, False: sale
  static Future<SavedDiagram> createValidacionDoWhileTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Valida entrada de número positivo.\nConcepto: Bucle do-while (post-condición) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Nodo para mostrar el prompt (reemplaza la declaración)
    final promptNode = DiagramNode(
      id: "output_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Mostrar \"Ingresar numero:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    // Cuerpo del do-while: Pedir entrada (este nodo se ejecuta primero en el bucle)
    final bodyNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 240),
      text: "Leer numero",
      metadata: {
        'structureType': 'loop',
        'loopType': 'do-while',
        'role': 'loop-body',
        'isOutput': false,
        'inputType': 'int',
        'varName': 'numero'
      },
    );

    // Condición del do-while (se evalúa después del cuerpo)
    final conditionNode = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(280, 380),
      text: "numero <= 0",
      metadata: {
        'structureType': 'loop',
        'loopType': 'do-while',
        'role': 'loop-condition',
        'condition': 'numero <= 0'
      },
    );

    final outputSuccessNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(280, 520),
      text: "Escribir \"Número válido:\", numero",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(280, 620),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      promptNode,
      bodyNode,
      conditionNode,
      outputSuccessNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: promptNode, label: ""),
      Connection(source: promptNode, target: bodyNode, label: ""),
      Connection(source: bodyNode, target: conditionNode, label: ""),
      // Verdadero: la condición se cumple, repetir (loop back al cuerpo)
      Connection(
          source: conditionNode,
          target: bodyNode,
          label: "",
          isLoopBack: true),
      // Falso: la condición no se cumple, salir del bucle
      Connection(source: conditionNode, target: outputSuccessNode, label: "No"),
      Connection(source: outputSuccessNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "10. Validación de Entrada (Do-While)",
      description:
          "UNIDAD I - Nivel Bucles: Bucle do-while para validar entrada de datos",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P11: Tabla de Multiplicar (For)
  static Future<SavedDiagram> createTablaMultiplicarForTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Genera la tabla de multiplicar del 1 al 10.\nConcepto: Bucle for controlado */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int numero, resultado, i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['numero', 'resultado', 'i']
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 230),
      text: "Leer numero",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'numero'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_4",
      type: NodeType.preparation,
      position: const Offset(280, 340),
      text: "for (i = 1; i <= 10; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 1',
        'forCondition': 'i <= 10',
        'forIncrement': 'i++',
      },
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_5",
      type: NodeType.process,
      position: const Offset(500, 340),
      text: "resultado = numero * i",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(500, 450),
      text: "Escribir numero, \"x\", i, \"=\", resultado",
      metadata: {'isOutput': true},
    );

    final outputFinNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 560),
      text: "Escribir \"Tabla completada\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(280, 660),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      forNode,
      processNode,
      outputNode,
      outputFinNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: forNode, label: ""),
      Connection(source: forNode, target: processNode, label: "Verdadero"),
      Connection(source: processNode, target: outputNode, label: ""),
      Connection(
          source: outputNode, target: forNode, label: "", isLoopBack: true),
      Connection(source: forNode, target: outputFinNode, label: "Falso"),
      Connection(source: outputFinNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "11. Tabla de Multiplicar (For)",
      description:
          "UNIDAD I - Nivel Bucles: Bucle for para generar tabla de multiplicar",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P12: Factorial Iterativo
  static Future<SavedDiagram> createFactorialIterativoTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Calcula el factorial de N usando un acumulador.\nConcepto: Acumulador en bucle for */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaración de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int n, factorial, i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['n', 'factorial', 'i']
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 230),
      text: "Leer n",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'n'},
    );

    final initNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(280, 320),
      text: "factorial = 1",
      metadata: {
        'processType': 'assignment',
        'varName': 'factorial',
        'value': '1'
      },
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_5",
      type: NodeType.preparation,
      position: const Offset(280, 430),
      text: "for (i = 1; i <= n; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 1',
        'forCondition': 'i <= n',
        'forIncrement': 'i++',
      },
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(500, 430),
      text: "factorial = factorial * i",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 560),
      text: "Escribir \"Factorial:\", factorial",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(280, 660),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      initNode,
      forNode,
      processNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: initNode, label: ""),
      Connection(source: initNode, target: forNode, label: ""),
      Connection(source: forNode, target: processNode, label: "Verdadero"),
      Connection(
          source: processNode, target: forNode, label: "", isLoopBack: true),
      Connection(source: forNode, target: outputNode, label: "Falso"),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "12. Factorial Iterativo",
      description:
          "UNIDAD I - Nivel Bucles: Cálculo de factorial usando acumulador",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // ============================================================
  // UNIDAD I - NIVEL 4: ARREGLOS
  // ============================================================

  /// P13: Suma de Arreglo
  static Future<SavedDiagram> createSumaArregloTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(520, 50),
      text:
          "/* Suma todos los elementos de un arreglo.\nConcepto: Declaración y recorrido de arreglos */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaración de arreglo y variable suma
    final declareArrNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int arr[5]",
      metadata: {
        'processType': 'array_declaration',
        'varType': 'int',
        'varName': 'arr',
        'size': '5'
      },
    );

    final declareSumaNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 230),
      text: "int suma, i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['suma', 'i']
      },
    );

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_4",
      type: NodeType.preparation,
      position: const Offset(280, 330),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 330),
      text: "Leer arr[i]",
      metadata: {'isOutput': false, 'inputType': 'int'},
    );

    final initSumaNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(280, 450),
      text: "suma = 0",
      metadata: {'processType': 'assignment', 'varName': 'suma', 'value': '0'},
    );

    final forSumaNode = DiagramNode(
      id: "loop_${baseId}_7",
      type: NodeType.preparation,
      position: const Offset(280, 550),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final processSumaNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(500, 550),
      text: "suma = suma + arr[i]",
      metadata: {'processType': 'arithmetic', 'operator': '+'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(280, 670),
      text: "Escribir \"Suma total:\", suma",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_10",
      type: NodeType.terminal,
      position: const Offset(280, 770),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareArrNode,
      declareSumaNode,
      forInputNode,
      inputNode,
      initSumaNode,
      forSumaNode,
      processSumaNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: declareSumaNode, label: ""),
      Connection(source: declareSumaNode, target: forInputNode, label: ""),
      Connection(source: forInputNode, target: inputNode, label: "Verdadero"),
      Connection(
          source: inputNode, target: forInputNode, label: "", isLoopBack: true),
      Connection(source: forInputNode, target: initSumaNode, label: "Falso"),
      Connection(source: initSumaNode, target: forSumaNode, label: ""),
      Connection(
          source: forSumaNode, target: processSumaNode, label: "Verdadero"),
      Connection(
          source: processSumaNode,
          target: forSumaNode,
          label: "",
          isLoopBack: true),
      Connection(source: forSumaNode, target: outputNode, label: "Falso"),
      Connection(source: outputNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "13. Suma de Arreglo",
      description:
          "UNIDAD I - Nivel Arreglos: Declaración, lectura y suma de elementos de un arreglo",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P14: Búsqueda Secuencial
  static Future<SavedDiagram> createBusquedaSecuencialTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(550, 150),
      text:
          "/* Busca un elemento\nen un arreglo\n(búsqueda lineal).\nConcepto: Recorrido\ncon bandera de\nbúsqueda */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    // Declaraciones de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(300, 140),
      text: "int valorBuscado,\nencontrado, posicion, i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['valorBuscado', 'encontrado', 'posicion', 'i']
      },
    );

    final declareArrNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(300, 240),
      text: "int arr[5] = {10, 25, 8, 42,\n17}",
      metadata: {'processType': 'array_init'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(100, 320),
      text: "Leer valorBuscado",
      metadata: {
        'isOutput': false,
        'inputType': 'int',
        'varName': 'valorBuscado'
      },
    );

    final initEncontradoNode = DiagramNode(
      id: "process_${baseId}_5a",
      type: NodeType.process,
      position: const Offset(100, 420),
      text: "encontrado = 0",
      metadata: {'processType': 'assignment'},
    );

    final initPosicionNode = DiagramNode(
      id: "process_${baseId}_5b",
      type: NodeType.process,
      position: const Offset(300, 420),
      text: "posicion = -1",
      metadata: {'processType': 'assignment'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(300, 530),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_7",
      type: NodeType.decision,
      position: const Offset(650, 530),
      text: "arr[i] ==\nvalorBuscado",
    );

    final foundEncontradoNode = DiagramNode(
      id: "process_${baseId}_8a",
      type: NodeType.process,
      position: const Offset(650, 420),
      text: "encontrado = 1",
      metadata: {'processType': 'assignment'},
    );

    final foundPosicionNode = DiagramNode(
      id: "process_${baseId}_8b",
      type: NodeType.process,
      position: const Offset(480, 420),
      text: "posicion = i",
      metadata: {'processType': 'assignment'},
    );

    final checkFoundNode = DiagramNode(
      id: "decision_${baseId}_9",
      type: NodeType.decision,
      position: const Offset(300, 650),
      text: "encontrado == 1",
    );

    final outputFoundNode = DiagramNode(
      id: "output_${baseId}_10",
      type: NodeType.data,
      position: const Offset(550, 650),
      text: "Escribir \"Encontrado en posición:\", posicion",
      metadata: {'isOutput': true},
    );

    final outputNotFoundNode = DiagramNode(
      id: "output_${baseId}_11",
      type: NodeType.data,
      position: const Offset(300, 770),
      text: "Escribir \"No encontrado\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_12",
      type: NodeType.terminal,
      position: const Offset(300, 880),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      declareArrNode,
      inputNode,
      initEncontradoNode,
      initPosicionNode,
      forNode,
      decisionNode,
      foundEncontradoNode,
      foundPosicionNode,
      checkFoundNode,
      outputFoundNode,
      outputNotFoundNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: initEncontradoNode, label: ""),
      Connection(source: initEncontradoNode, target: initPosicionNode, label: ""),
      Connection(source: initPosicionNode, target: forNode, label: ""),
      Connection(source: forNode, target: decisionNode, label: "Verdadero"),
      Connection(source: decisionNode, target: forNode, label: "Falso", isLoopBack: true),
      Connection(source: decisionNode, target: foundEncontradoNode, label: "Verdadero"),
      Connection(source: foundEncontradoNode, target: foundPosicionNode, label: ""),
      Connection(source: foundPosicionNode, target: forNode, label: "", isLoopBack: true),
      Connection(source: forNode, target: checkFoundNode, label: "Falso"),
      Connection(source: checkFoundNode, target: outputFoundNode, label: "Sí"),
      Connection(source: checkFoundNode, target: outputNotFoundNode, label: "No"),
      Connection(source: outputFoundNode, target: endNode, label: ""),
      Connection(source: outputNotFoundNode, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "14. Búsqueda Secuencial",
      description:
          "UNIDAD I - Nivel Arreglos: Búsqueda lineal con bandera de encontrado",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P15: Ordenamiento Burbuja (Bubble Sort)
  static Future<SavedDiagram> createBubbleSortTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(580, 50),
      text:
          "/* Ordena un arreglo usando Bubble Sort.\nCompara elementos adyacentes e intercambia si están desordenados.\nComplejidad: O(n²) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareArrNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int arr[5]",
      metadata: {
        'processType': 'array_declaration',
        'varType': 'int',
        'varName': 'arr',
        'size': '5'
      },
    );

    final declareTempNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 210),
      text: "int temp, i, j",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['temp', 'i', 'j']
      },
    );

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_4",
      type: NodeType.preparation,
      position: const Offset(280, 300),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 300),
      text: "Leer arr[i]",
      metadata: {'isOutput': false},
    );

    final forINode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(280, 410),
      text: "for (i = 0; i < 4; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 4',
        'forIncrement': 'i++'
      },
    );

    final forJNode = DiagramNode(
      id: "loop_${baseId}_7",
      type: NodeType.preparation,
      position: const Offset(500, 410),
      text: "for (j = 0; j < 4-i; j++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int j = 0',
        'forCondition': 'j < 4-i',
        'forIncrement': 'j++'
      },
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_8",
      type: NodeType.decision,
      position: const Offset(700, 410),
      text: "arr[j] > arr[j+1]",
    );

    final swapNode = DiagramNode(
      id: "process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(700, 550),
      text: "temp = arr[j]\narr[j] = arr[j+1]\narr[j+1] = temp",
      metadata: {'processType': 'swap'},
    );

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_10",
      type: NodeType.data,
      position: const Offset(280, 650),
      text: "Escribir \"Arreglo ordenado:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forOutputNode = DiagramNode(
      id: "loop_${baseId}_11",
      type: NodeType.preparation,
      position: const Offset(280, 750),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_12",
      type: NodeType.data,
      position: const Offset(500, 750),
      text: "Escribir arr[i]",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_13",
      type: NodeType.terminal,
      position: const Offset(280, 870),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareArrNode,
      declareTempNode,
      forInputNode,
      inputNode,
      forINode,
      forJNode,
      decisionNode,
      swapNode,
      outputLabelNode,
      forOutputNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: declareTempNode, label: ""),
      Connection(source: declareTempNode, target: forInputNode, label: ""),
      Connection(source: forInputNode, target: inputNode, label: "Verdadero"),
      Connection(
          source: inputNode, target: forInputNode, label: "", isLoopBack: true),
      Connection(source: forInputNode, target: forINode, label: "Falso"),
      Connection(source: forINode, target: forJNode, label: "Verdadero"),
      Connection(source: forJNode, target: decisionNode, label: "Verdadero"),
      Connection(source: decisionNode, target: swapNode, label: "Sí"),
      Connection(
          source: decisionNode,
          target: forJNode,
          label: "No",
          isLoopBack: true),
      Connection(
          source: swapNode, target: forJNode, label: "", isLoopBack: true),
      Connection(
          source: forJNode, target: forINode, label: "Falso", isLoopBack: true),
      Connection(source: forINode, target: outputLabelNode, label: "Falso"),
      Connection(source: outputLabelNode, target: forOutputNode, label: ""),
      Connection(source: forOutputNode, target: outputNode, label: "Verdadero"),
      Connection(
          source: outputNode,
          target: forOutputNode,
          label: "",
          isLoopBack: true),
      Connection(source: forOutputNode, target: endNode, label: "Falso"),
    ];

    return SavedDiagram(
      name: "15. Ordenamiento Burbuja",
      description:
          "UNIDAD I - Nivel Arreglos: Algoritmo Bubble Sort con bucles anidados",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P16: Ordenamiento Selección (Selection Sort)
  static Future<SavedDiagram> createSelectionSortTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(580, 50),
      text:
          "/* Ordena un arreglo usando Selection Sort.\nBusca el mínimo en cada iteración y lo coloca al inicio.\nComplejidad: O(n²) */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareArrNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int arr[5]",
      metadata: {'processType': 'array_declaration'},
    );

    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 210),
      text: "int minIdx, temp, i, j",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['minIdx', 'temp', 'i', 'j']
      },
    );

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_4",
      type: NodeType.preparation,
      position: const Offset(280, 300),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 300),
      text: "Leer arr[i]",
      metadata: {'isOutput': false},
    );

    final forINode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(280, 400),
      text: "for (i = 0; i < 4; i++)",
      metadata: {'loopType': 'for'},
    );

    final initMinNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(500, 400),
      text: "minIdx = i",
      metadata: {'processType': 'assignment'},
    );

    final forJNode = DiagramNode(
      id: "loop_${baseId}_8",
      type: NodeType.preparation,
      position: const Offset(500, 500),
      text: "for (j = i+1; j < 5; j++)",
      metadata: {'loopType': 'for'},
    );

    final decisionMinNode = DiagramNode(
      id: "decision_${baseId}_9",
      type: NodeType.decision,
      position: const Offset(700, 500),
      text: "arr[j] < arr[minIdx]",
    );

    final updateMinNode = DiagramNode(
      id: "process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(700, 620),
      text: "minIdx = j",
      metadata: {'processType': 'assignment'},
    );

    final decisionSwapNode = DiagramNode(
      id: "decision_${baseId}_11",
      type: NodeType.decision,
      position: const Offset(500, 720),
      text: "minIdx != i",
    );

    final swapNode = DiagramNode(
      id: "process_${baseId}_12",
      type: NodeType.process,
      position: const Offset(700, 720),
      text: "temp = arr[i]\narr[i] = arr[minIdx]\narr[minIdx] = temp",
      metadata: {'processType': 'swap'},
    );

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_13",
      type: NodeType.data,
      position: const Offset(280, 840),
      text: "Escribir \"Arreglo ordenado:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forOutputNode = DiagramNode(
      id: "loop_${baseId}_14",
      type: NodeType.preparation,
      position: const Offset(280, 930),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_15",
      type: NodeType.data,
      position: const Offset(500, 930),
      text: "Escribir arr[i]",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_16",
      type: NodeType.terminal,
      position: const Offset(280, 1050),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareArrNode,
      declareVarsNode,
      forInputNode,
      inputNode,
      forINode,
      initMinNode,
      forJNode,
      decisionMinNode,
      updateMinNode,
      decisionSwapNode,
      swapNode,
      outputLabelNode,
      forOutputNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: forInputNode, label: ""),
      Connection(source: forInputNode, target: inputNode, label: "Verdadero"),
      Connection(
          source: inputNode, target: forInputNode, label: "", isLoopBack: true),
      Connection(source: forInputNode, target: forINode, label: "Falso"),
      Connection(source: forINode, target: initMinNode, label: "Verdadero"),
      Connection(source: initMinNode, target: forJNode, label: ""),
      Connection(source: forJNode, target: decisionMinNode, label: "Verdadero"),
      Connection(source: decisionMinNode, target: updateMinNode, label: "Sí"),
      Connection(
          source: decisionMinNode,
          target: forJNode,
          label: "No",
          isLoopBack: true),
      Connection(
          source: updateMinNode, target: forJNode, label: "", isLoopBack: true),
      Connection(source: forJNode, target: decisionSwapNode, label: "Falso"),
      Connection(source: decisionSwapNode, target: swapNode, label: "Sí"),
      Connection(
          source: decisionSwapNode,
          target: forINode,
          label: "No",
          isLoopBack: true),
      Connection(
          source: swapNode, target: forINode, label: "", isLoopBack: true),
      Connection(source: forINode, target: outputLabelNode, label: "Falso"),
      Connection(source: outputLabelNode, target: forOutputNode, label: ""),
      Connection(source: forOutputNode, target: outputNode, label: "Verdadero"),
      Connection(
          source: outputNode,
          target: forOutputNode,
          label: "",
          isLoopBack: true),
      Connection(source: forOutputNode, target: endNode, label: "Falso"),
    ];

    return SavedDiagram(
      name: "16. Ordenamiento Selección",
      description:
          "UNIDAD I - Nivel Arreglos: Algoritmo Selection Sort buscando mínimo",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // ============================================================
  // UNIDAD II - NIVEL 5: FUNCIONES Y APUNTADORES
  // ============================================================

  /// P17: Función Suma (Subproceso)
  static Future<SavedDiagram> createFuncionSumaTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Demuestra el uso de funciones con parámetros y retorno.\nConcepto: Subproceso predefinido, paso por valor */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaraciones de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int a, b, resultado",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['a', 'b', 'resultado']
      },
    );

    final inputANode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 210),
      text: "Leer a",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'a'},
    );

    final inputBNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(280, 290),
      text: "Leer b",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'b'},
    );

    final callFunctionNode = DiagramNode(
      id: "subprocess_${baseId}_5",
      type: NodeType.predefinedProcess,
      position: const Offset(280, 380),
      text: "resultado = Suma(a, b)",
      metadata: {
        'functionName': 'Suma',
        'parameters': 'a, b',
        'returnVar': 'resultado'
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(280, 470),
      text: "Escribir \"La suma es:\", resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(280, 560),
      text: "Fin",
    );

    // Subproceso Suma
    final subStartNode = DiagramNode(
      id: "sub_start_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(600, 130),
      text: "Inicio Suma(x, y)",
    );

    final subDeclareNode = DiagramNode(
      id: "sub_process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(600, 210),
      text: "int retorno",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varName': 'retorno'
      },
    );

    final subProcessNode = DiagramNode(
      id: "sub_process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(600, 290),
      text: "retorno = x + y",
      metadata: {'processType': 'arithmetic'},
    );

    final subReturnNode = DiagramNode(
      id: "sub_return_${baseId}_11",
      type: NodeType.data,
      position: const Offset(600, 370),
      text: "return retorno",
      metadata: {'isOutput': true, 'isReturn': true},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_12",
      type: NodeType.terminal,
      position: const Offset(600, 450),
      text: "Fin Suma",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputANode,
      inputBNode,
      callFunctionNode,
      outputNode,
      endNode,
      subStartNode,
      subDeclareNode,
      subProcessNode,
      subReturnNode,
      subEndNode
    ];

    final connections = [
      // Programa principal
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputANode, label: ""),
      Connection(source: inputANode, target: inputBNode, label: ""),
      Connection(source: inputBNode, target: callFunctionNode, label: ""),
      Connection(source: callFunctionNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
      // Subproceso
      Connection(source: subStartNode, target: subDeclareNode, label: ""),
      Connection(source: subDeclareNode, target: subProcessNode, label: ""),
      Connection(source: subProcessNode, target: subReturnNode, label: ""),
      Connection(source: subReturnNode, target: subEndNode, label: ""),
    ];

    return SavedDiagram(
      name: "17. Función Suma",
      description:
          "UNIDAD II - Nivel Funciones: Subproceso con parámetros y retorno",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P18: Función Factorial (Subproceso)
  static Future<SavedDiagram> createFuncionFactorialTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Calcula factorial usando una función separada.\nConcepto: Modularización con subprocesos */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Declaraciones de variables
    final declareVarsNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int n, resultado",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['n', 'resultado']
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 210),
      text: "Leer n",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'n'},
    );

    final callFunctionNode = DiagramNode(
      id: "subprocess_${baseId}_4",
      type: NodeType.predefinedProcess,
      position: const Offset(280, 300),
      text: "resultado = Factorial(n)",
      metadata: {
        'functionName': 'Factorial',
        'parameters': 'n',
        'returnVar': 'resultado'
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(280, 390),
      text: "Escribir \"Factorial:\", resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(280, 480),
      text: "Fin",
    );

    // Subproceso Factorial
    final subStartNode = DiagramNode(
      id: "sub_start_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(600, 50),
      text: "Inicio Factorial(num)",
    );

    final subDeclareNode = DiagramNode(
      id: "sub_process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(600, 130),
      text: "int fact, i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varNames': ['fact', 'i']
      },
    );

    final subInitNode = DiagramNode(
      id: "sub_init_${baseId}_9",
      type: NodeType.process,
      position: const Offset(600, 210),
      text: "fact = 1",
      metadata: {'processType': 'assignment'},
    );

    final subForNode = DiagramNode(
      id: "sub_loop_${baseId}_10",
      type: NodeType.preparation,
      position: const Offset(600, 300),
      text: "for (i = 1; i <= num; i++)",
      metadata: {'loopType': 'for'},
    );

    final subProcessNode = DiagramNode(
      id: "sub_process_${baseId}_11",
      type: NodeType.process,
      position: const Offset(800, 300),
      text: "fact = fact * i",
      metadata: {'processType': 'arithmetic'},
    );

    final subReturnNode = DiagramNode(
      id: "sub_return_${baseId}_12",
      type: NodeType.data,
      position: const Offset(600, 420),
      text: "return fact",
      metadata: {'isOutput': true, 'isReturn': true},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_13",
      type: NodeType.terminal,
      position: const Offset(600, 510),
      text: "Fin Factorial",
    );

    final nodes = [
      commentNode,
      startNode,
      declareVarsNode,
      inputNode,
      callFunctionNode,
      outputNode,
      endNode,
      subStartNode,
      subDeclareNode,
      subInitNode,
      subForNode,
      subProcessNode,
      subReturnNode,
      subEndNode
    ];

    final connections = [
      // Programa principal
      Connection(source: startNode, target: declareVarsNode, label: ""),
      Connection(source: declareVarsNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: callFunctionNode, label: ""),
      Connection(source: callFunctionNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
      // Subproceso
      Connection(source: subStartNode, target: subDeclareNode, label: ""),
      Connection(source: subDeclareNode, target: subInitNode, label: ""),
      Connection(source: subInitNode, target: subForNode, label: ""),
      Connection(
          source: subForNode, target: subProcessNode, label: "Verdadero"),
      Connection(
          source: subProcessNode,
          target: subForNode,
          label: "",
          isLoopBack: true),
      Connection(source: subForNode, target: subReturnNode, label: "Falso"),
      Connection(source: subReturnNode, target: subEndNode, label: ""),
    ];

    return SavedDiagram(
      name: "18. Función Factorial",
      description:
          "UNIDAD II - Nivel Funciones: Función con bucle interno y retorno",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P19: Intercambio Swap (Paso por Referencia)
  static Future<SavedDiagram> createSwapTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Intercambia dos variables usando apuntadores.\nConcepto: Paso por referencia con * y & */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final initANode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int a = 5",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'a',
        'value': '5'
      },
    );

    final initBNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 230),
      text: "int b = 10",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'b',
        'value': '10'
      },
    );

    final outputBeforeNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(280, 320),
      text: "Escribir \"Antes: a=\", a, \"b=\", b",
      metadata: {'isOutput': true},
    );

    final callSwapNode = DiagramNode(
      id: "subprocess_${baseId}_5",
      type: NodeType.predefinedProcess,
      position: const Offset(280, 420),
      text: "Swap(&a, &b)",
      metadata: {
        'functionName': 'Swap',
        'parameters': '&a, &b',
        'passByReference': true
      },
    );

    final outputAfterNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(280, 520),
      text: "Escribir \"Después: a=\", a, \"b=\", b",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(280, 620),
      text: "Fin",
    );

    // Subproceso Swap con apuntadores
    final subStartNode = DiagramNode(
      id: "sub_start_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(600, 140),
      text: "Inicio Swap(int *x, int *y)",
    );

    final subDeclareNode = DiagramNode(
      id: "sub_process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(600, 230),
      text: "int temp",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varName': 'temp'
      },
    );

    final subTempNode = DiagramNode(
      id: "sub_process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(600, 320),
      text: "temp = *x",
      metadata: {'processType': 'pointer_deref'},
    );

    final subAssign1Node = DiagramNode(
      id: "sub_process_${baseId}_11",
      type: NodeType.process,
      position: const Offset(600, 410),
      text: "*x = *y",
      metadata: {'processType': 'pointer_deref'},
    );

    final subAssign2Node = DiagramNode(
      id: "sub_process_${baseId}_12",
      type: NodeType.process,
      position: const Offset(600, 500),
      text: "*y = temp",
      metadata: {'processType': 'pointer_deref'},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_13",
      type: NodeType.terminal,
      position: const Offset(600, 590),
      text: "Fin Swap",
    );

    final nodes = [
      commentNode,
      startNode,
      initANode,
      initBNode,
      outputBeforeNode,
      callSwapNode,
      outputAfterNode,
      endNode,
      subStartNode,
      subDeclareNode,
      subTempNode,
      subAssign1Node,
      subAssign2Node,
      subEndNode
    ];

    final connections = [
      // Programa principal
      Connection(source: startNode, target: initANode, label: ""),
      Connection(source: initANode, target: initBNode, label: ""),
      Connection(source: initBNode, target: outputBeforeNode, label: ""),
      Connection(source: outputBeforeNode, target: callSwapNode, label: ""),
      Connection(source: callSwapNode, target: outputAfterNode, label: ""),
      Connection(source: outputAfterNode, target: endNode, label: ""),
      // Subproceso
      Connection(source: subStartNode, target: subDeclareNode, label: ""),
      Connection(source: subDeclareNode, target: subTempNode, label: ""),
      Connection(source: subTempNode, target: subAssign1Node, label: ""),
      Connection(source: subAssign1Node, target: subAssign2Node, label: ""),
      Connection(source: subAssign2Node, target: subEndNode, label: ""),
    ];

    return SavedDiagram(
      name: "19. Intercambio (Swap)",
      description:
          "UNIDAD II - Nivel Apuntadores: Paso por referencia con operadores & y *",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// P20: Apuntadores y Arreglos
  static Future<SavedDiagram> createApuntadoresArreglosTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "/* Recorre un arreglo usando aritmética de apuntadores.\nConcepto: *(ptr+i) equivale a arr[i] */",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareArrNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 140),
      text: "int arr[5] = {10, 20, 30, 40, 50}",
      metadata: {'processType': 'array_init'},
    );

    final declarePtrNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 230),
      text: "int *ptr = arr",
      metadata: {'processType': 'pointer_init', 'pointerType': 'int'},
    );

    final declareINode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(280, 320),
      text: "int i",
      metadata: {
        'processType': 'declaration',
        'varType': 'int',
        'varName': 'i'
      },
    );

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(280, 410),
      text: "Escribir \"Recorrido con aritmética de punteros:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(280, 510),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputElementNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(500, 510),
      text: "Escribir *(ptr + i)",
      metadata: {'isOutput': true, 'pointerArithmetic': true},
    );

    final outputLabel2Node = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(280, 630),
      text: "Escribir \"Dirección del arreglo:\", ptr",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_9",
      type: NodeType.terminal,
      position: const Offset(280, 730),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareArrNode,
      declarePtrNode,
      declareINode,
      outputLabelNode,
      forNode,
      outputElementNode,
      outputLabel2Node,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: declarePtrNode, label: ""),
      Connection(source: declarePtrNode, target: declareINode, label: ""),
      Connection(source: declareINode, target: outputLabelNode, label: ""),
      Connection(source: outputLabelNode, target: forNode, label: ""),
      Connection(
          source: forNode, target: outputElementNode, label: "Verdadero"),
      Connection(
          source: outputElementNode,
          target: forNode,
          label: "",
          isLoopBack: true),
      Connection(source: forNode, target: outputLabel2Node, label: "Falso"),
      Connection(source: outputLabel2Node, target: endNode, label: ""),
    ];

    return SavedDiagram(
      name: "20. Apuntadores y Arreglos",
      description:
          "UNIDAD II - Nivel Apuntadores: Aritmética de punteros para recorrer arreglos",
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  // ============================================================
  // BENCHMARK - PLANTILLAS DE MEDICIÓN DE RENDIMIENTO
  // ============================================================

  /// BM-10: Benchmark 10 nodos - Búsqueda Binaria simplificada
  /// Nodos totales: 10 (1 comment + 1 start + 3 process + 1 data input + 3 decision + 1 end)
  static Future<SavedDiagram> createBenchmark10Template() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    // Nodo 1: comment
    final n1 = DiagramNode(
      id: 'bm10_comment_${baseId}_1',
      type: NodeType.comment,
      position: const Offset(450, 40),
      text: '/* BENCHMARK 10 NODOS\nBúsqueda Binaria (iteración única)\nNodos: 10 */',
    );
    // Nodo 2: start
    final n2 = DiagramNode(
      id: 'bm10_start_${baseId}_2',
      type: NodeType.terminal,
      position: const Offset(250, 40),
      text: 'Inicio',
    );
    // Nodo 3: declarar variables
    final n3 = DiagramNode(
      id: 'bm10_proc_${baseId}_3',
      type: NodeType.process,
      position: const Offset(250, 140),
      text: 'int arr[10], bajo, alto, medio, objetivo',
      metadata: {'processType': 'declaration'},
    );
    // Nodo 4: inicializar índices
    final n4 = DiagramNode(
      id: 'bm10_proc_${baseId}_4',
      type: NodeType.process,
      position: const Offset(250, 240),
      text: 'bajo = 0\nalto = 9',
      metadata: {'processType': 'initialization'},
    );
    // Nodo 5: leer objetivo
    final n5 = DiagramNode(
      id: 'bm10_data_${baseId}_5',
      type: NodeType.data,
      position: const Offset(250, 340),
      text: 'Leer objetivo',
      metadata: {'isOutput': false},
    );
    // Nodo 6: calcular medio
    final n6 = DiagramNode(
      id: 'bm10_proc_${baseId}_6',
      type: NodeType.process,
      position: const Offset(250, 440),
      text: 'medio = (bajo + alto) / 2',
      metadata: {'processType': 'arithmetic'},
    );
    // Nodo 7: decisión arr[medio] == objetivo
    final n7 = DiagramNode(
      id: 'bm10_dec_${baseId}_7',
      type: NodeType.decision,
      position: const Offset(250, 550),
      text: 'arr[medio] == objetivo',
    );
    // Nodo 8: encontrado
    final n8 = DiagramNode(
      id: 'bm10_data_${baseId}_8',
      type: NodeType.data,
      position: const Offset(460, 680),
      text: 'Escribir "Encontrado en:", medio',
      metadata: {'isOutput': true},
    );
    // Nodo 9: decisión arr[medio] < objetivo
    final n9 = DiagramNode(
      id: 'bm10_dec_${baseId}_9',
      type: NodeType.decision,
      position: const Offset(60, 680),
      text: 'arr[medio] < objetivo',
    );
    // Nodo 10: end
    final n10 = DiagramNode(
      id: 'bm10_end_${baseId}_10',
      type: NodeType.terminal,
      position: const Offset(250, 820),
      text: 'Fin',
    );

    final nodes = [n1, n2, n3, n4, n5, n6, n7, n8, n9, n10];
    final connections = [
      Connection(source: n2, target: n3, label: ''),
      Connection(source: n3, target: n4, label: ''),
      Connection(source: n4, target: n5, label: ''),
      Connection(source: n5, target: n6, label: ''),
      Connection(source: n6, target: n7, label: ''),
      Connection(source: n7, target: n8, label: 'Sí'),
      Connection(source: n7, target: n9, label: 'No'),
      Connection(source: n8, target: n10, label: ''),
      Connection(source: n9, target: n10, label: ''),
    ];

    return SavedDiagram(
      name: 'BM-10. Benchmark 10 Nodos',
      description:
          'BENCHMARK: Búsqueda Binaria simplificada. 10 nodos exactos para medición de rendimiento.',
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// BM-25: Benchmark 25 nodos - Verificación de número primo
  /// Nodos totales: 25
  static Future<SavedDiagram> createBenchmark25Template() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    // Nodo 1
    final n1 = DiagramNode(
      id: 'bm25_comment_${baseId}_1',
      type: NodeType.comment,
      position: const Offset(520, 40),
      text: '/* BENCHMARK 25 NODOS\nVerificación de Número Primo\nNodos: 25 */',
    );
    // Nodo 2
    final n2 = DiagramNode(
      id: 'bm25_start_${baseId}_2',
      type: NodeType.terminal,
      position: const Offset(280, 40),
      text: 'Inicio',
    );
    // Nodo 3 - Declaración de TODAS las variables del programa (una sola línea)
    final n3 = DiagramNode(
      id: 'bm25_proc_${baseId}_3',
      type: NodeType.process,
      position: const Offset(280, 130),
      text: 'int n, i, esPrimo, contadorPrimos, sumaTotal, digitos, raizCuadrada, logaritmo, categoria',
      metadata: {'processType': 'declaration'},
    );
    // Nodo 4
    final n4 = DiagramNode(
      id: 'bm25_data_${baseId}_4',
      type: NodeType.data,
      position: const Offset(280, 220),
      text: 'Leer n',
      metadata: {'isOutput': false},
    );
    // Nodo 5
    final n5 = DiagramNode(
      id: 'bm25_dec_${baseId}_5',
      type: NodeType.decision,
      position: const Offset(280, 320),
      text: 'n <= 1',
    );
    // Nodo 6
    final n6 = DiagramNode(
      id: 'bm25_data_${baseId}_6',
      type: NodeType.data,
      position: const Offset(480, 320),
      text: 'Escribir "No es primo"',
      metadata: {'isOutput': true},
    );
    // Nodo 7 - Inicializar contadores junto con esPrimo e i
    final n7 = DiagramNode(
      id: 'bm25_proc_${baseId}_7',
      type: NodeType.process,
      position: const Offset(280, 440),
      text: 'esPrimo = 1\ni = 2\ncontadorPrimos = 0\nsumaTotal = 0',
      metadata: {'processType': 'initialization'},
    );
    // Nodo 8 - prep (hexágono for)
    final n8 = DiagramNode(
      id: 'bm25_prep_${baseId}_8',
      type: NodeType.preparation,
      position: const Offset(280, 540),
      text: 'i = 2; i < n; i++',
    );
    // Nodo 9
    final n9 = DiagramNode(
      id: 'bm25_dec_${baseId}_9',
      type: NodeType.decision,
      position: const Offset(280, 650),
      text: 'n % i == 0',
    );
    // Nodo 10
    final n10 = DiagramNode(
      id: 'bm25_proc_${baseId}_10',
      type: NodeType.process,
      position: const Offset(480, 650),
      text: 'esPrimo = 0',
      metadata: {'processType': 'assignment'},
    );
    // Nodo 11
    final n11 = DiagramNode(
      id: 'bm25_dec_${baseId}_11',
      type: NodeType.decision,
      position: const Offset(280, 780),
      text: 'esPrimo == 1',
    );
    // Nodo 12
    final n12 = DiagramNode(
      id: 'bm25_data_${baseId}_12',
      type: NodeType.data,
      position: const Offset(480, 780),
      text: 'Escribir n, "es primo"',
      metadata: {'isOutput': true},
    );
    // Nodo 13
    final n13 = DiagramNode(
      id: 'bm25_data_${baseId}_13',
      type: NodeType.data,
      position: const Offset(80, 780),
      text: 'Escribir n, "no es primo"',
      metadata: {'isOutput': true},
    );
    // Nodos 14-24: proceso de validación de múltiples entradas (secuencia de pasos)
    final n14 = DiagramNode(
      id: 'bm25_proc_${baseId}_14',
      type: NodeType.process,
      position: const Offset(280, 900),
      text: 'contadorPrimos++',
      metadata: {'processType': 'arithmetic'},
    );
    // Nodo 15 - Salida que LEE sumaTotal (evita warning "declarada pero no usada")
    final n15 = DiagramNode(
      id: 'bm25_data_${baseId}_15',
      type: NodeType.data,
      position: const Offset(280, 980),
      text: 'Escribir "Suma acumulada:", sumaTotal',
      metadata: {'isOutput': true},
    );
    final n16 = DiagramNode(
      id: 'bm25_dec_${baseId}_16',
      type: NodeType.decision,
      position: const Offset(280, 1060),
      text: 'n > 100',
    );
    final n17 = DiagramNode(
      id: 'bm25_data_${baseId}_17',
      type: NodeType.data,
      position: const Offset(480, 1060),
      text: 'Escribir "Primo grande"',
      metadata: {'isOutput': true},
    );
    final n18 = DiagramNode(
      id: 'bm25_proc_${baseId}_18',
      type: NodeType.process,
      position: const Offset(280, 1160),
      text: 'categoria = 0',
      metadata: {'processType': 'assignment'},
    );
    final n19 = DiagramNode(
      id: 'bm25_proc_${baseId}_19',
      type: NodeType.process,
      position: const Offset(280, 1240),
      text: 'digitos = n / 10 + 1',
      metadata: {'processType': 'arithmetic'},
    );
    final n20 = DiagramNode(
      id: 'bm25_proc_${baseId}_20',
      type: NodeType.process,
      position: const Offset(280, 1320),
      text: 'raizCuadrada = sqrt(n)',
      metadata: {'processType': 'arithmetic'},
    );
    final n21 = DiagramNode(
      id: 'bm25_data_${baseId}_21',
      type: NodeType.data,
      position: const Offset(280, 1400),
      text: 'Escribir "Raiz:", raizCuadrada',
      metadata: {'isOutput': true},
    );
    final n22 = DiagramNode(
      id: 'bm25_proc_${baseId}_22',
      type: NodeType.process,
      position: const Offset(280, 1480),
      text: 'logaritmo = log2(n)',
      metadata: {'processType': 'arithmetic'},
    );
    final n23 = DiagramNode(
      id: 'bm25_data_${baseId}_23',
      type: NodeType.data,
      position: const Offset(280, 1560),
      text: 'Escribir "Log2:", logaritmo',
      metadata: {'isOutput': true},
    );
    final n24 = DiagramNode(
      id: 'bm25_data_${baseId}_24',
      type: NodeType.data,
      position: const Offset(280, 1640),
      text: 'Escribir "Digitos:", digitos, "Categoria:", categoria',
      metadata: {'isOutput': true},
    );
    // Nodo 25
    final n25 = DiagramNode(
      id: 'bm25_end_${baseId}_25',
      type: NodeType.terminal,
      position: const Offset(280, 1740),
      text: 'Fin',
    );

    final nodes = [
      n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
      n11, n12, n13, n14, n15, n16, n17, n18, n19, n20,
      n21, n22, n23, n24, n25,
    ];
    final connections = [
      Connection(source: n2, target: n3, label: ''),
      Connection(source: n3, target: n4, label: ''),
      Connection(source: n4, target: n5, label: ''),
      Connection(source: n5, target: n6, label: 'Sí'),
      Connection(source: n5, target: n7, label: 'No'),
      Connection(source: n6, target: n25, label: ''),
      Connection(source: n7, target: n8, label: ''),
      Connection(source: n8, target: n9, label: 'Verdadero'),
      Connection(source: n9, target: n10, label: 'Sí'),
      Connection(source: n9, target: n8, label: 'No', isLoopBack: true),
      Connection(source: n10, target: n8, label: '', isLoopBack: true),
      Connection(source: n8, target: n11, label: 'Falso'),
      Connection(source: n11, target: n12, label: 'Sí'),
      Connection(source: n11, target: n13, label: 'No'),
      Connection(source: n12, target: n14, label: ''),
      Connection(source: n13, target: n14, label: ''),
      Connection(source: n14, target: n15, label: ''),
      Connection(source: n15, target: n16, label: ''),
      Connection(source: n16, target: n17, label: 'Sí'),
      Connection(source: n16, target: n18, label: 'No'),
      Connection(source: n17, target: n19, label: ''),
      Connection(source: n18, target: n19, label: ''),
      Connection(source: n19, target: n20, label: ''),
      Connection(source: n20, target: n21, label: ''),
      Connection(source: n21, target: n22, label: ''),
      Connection(source: n22, target: n23, label: ''),
      Connection(source: n23, target: n24, label: ''),
      Connection(source: n24, target: n25, label: ''),
    ];

    return SavedDiagram(
      name: 'BM-25. Benchmark 25 Nodos',
      description:
          'BENCHMARK: Verificación de Número Primo con análisis extendido. 25 nodos exactos para medición de rendimiento.',
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// BM-50: Benchmark 50 nodos - Ordenamiento Burbuja con estadísticas
  /// Nodos totales: 50
  static Future<SavedDiagram> createBenchmark50Template() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final nodes = <DiagramNode>[];
    final connections = <Connection>[];

    // ---- Sección 1: Encabezado (nodos 1-3) ----
    final n1 = DiagramNode(
      id: 'bm50_${baseId}_1', type: NodeType.comment,
      position: const Offset(560, 40),
      text: '/* BENCHMARK 50 NODOS\nOrdenamiento Burbuja + Estadísticas\nNodos: 50 */',
    );
    final n2 = DiagramNode(
      id: 'bm50_${baseId}_2', type: NodeType.terminal,
      position: const Offset(280, 40), text: 'Inicio',
    );
    final n3 = DiagramNode(
      id: 'bm50_${baseId}_3', type: NodeType.process,
      position: const Offset(280, 130),
      text: 'int arr[20], n, i, j, temp, suma, min, max, rango, intercambios, mediana, eficiencia, varianza, desviacion, promedio',
      metadata: {'processType': 'declaration'},
    );
    nodes.addAll([n1, n2, n3]);

    // ---- Sección 2: Lectura de datos (nodos 4-7) ----
    final n4 = DiagramNode(
      id: 'bm50_${baseId}_4', type: NodeType.data,
      position: const Offset(280, 230), text: 'Leer n',
      metadata: {'isOutput': false},
    );
    final n5 = DiagramNode(
      id: 'bm50_${baseId}_5', type: NodeType.decision,
      position: const Offset(280, 320), text: 'n >= 1 && n <= 20',
    );
    final n6 = DiagramNode(
      id: 'bm50_${baseId}_6', type: NodeType.data,
      position: const Offset(500, 320), text: 'Escribir "Error: tamaño inválido"',
      metadata: {'isOutput': true},
    );
    final n7 = DiagramNode(
      id: 'bm50_${baseId}_7', type: NodeType.preparation,
      position: const Offset(280, 430), text: 'i = 0; i < n; i++',
    );
    nodes.addAll([n4, n5, n6, n7]);

    // ---- Sección 3: Lectura arreglo (nodos 8-10) ----
    final n8 = DiagramNode(
      id: 'bm50_${baseId}_8', type: NodeType.data,
      position: const Offset(280, 530), text: 'Leer arr[i]',
      metadata: {'isOutput': false},
    );
    final n9 = DiagramNode(
      id: 'bm50_${baseId}_9', type: NodeType.process,
      position: const Offset(280, 620), text: 'suma += arr[i]',
      metadata: {'processType': 'arithmetic'},
    );
    final n10 = DiagramNode(
      id: 'bm50_${baseId}_10', type: NodeType.process,
      position: const Offset(280, 710), text: 'suma = 0\nmin = arr[0]\nmax = arr[0]\nintercambios = 0',
      metadata: {'processType': 'initialization'},
    );
    nodes.addAll([n8, n9, n10]);

    // ---- Sección 4: Búsqueda de min/max (nodos 11-20) ----
    final n11 = DiagramNode(
      id: 'bm50_${baseId}_11', type: NodeType.preparation,
      position: const Offset(280, 800), text: 'i = 1; i < n; i++',
    );
    final n12 = DiagramNode(
      id: 'bm50_${baseId}_12', type: NodeType.decision,
      position: const Offset(280, 900), text: 'arr[i] < min',
    );
    final n13 = DiagramNode(
      id: 'bm50_${baseId}_13', type: NodeType.process,
      position: const Offset(480, 900), text: 'min = arr[i]',
      metadata: {'processType': 'assignment'},
    );
    final n14 = DiagramNode(
      id: 'bm50_${baseId}_14', type: NodeType.decision,
      position: const Offset(280, 1010), text: 'arr[i] > max',
    );
    final n15 = DiagramNode(
      id: 'bm50_${baseId}_15', type: NodeType.process,
      position: const Offset(480, 1010), text: 'max = arr[i]',
      metadata: {'processType': 'assignment'},
    );
    final n16 = DiagramNode(
      id: 'bm50_${baseId}_16', type: NodeType.process,
      position: const Offset(280, 1120), text: 'promedio = suma / n',
      metadata: {'processType': 'arithmetic'},
    );
    final n17 = DiagramNode(
      id: 'bm50_${baseId}_17', type: NodeType.data,
      position: const Offset(280, 1210), text: 'Escribir "Suma:", suma, "Min:", min, "Max:", max',
      metadata: {'isOutput': true},
    );
    final n18 = DiagramNode(
      id: 'bm50_${baseId}_18', type: NodeType.data,
      position: const Offset(280, 1300), text: 'Escribir "Promedio:", promedio',
      metadata: {'isOutput': true},
    );
    final n19 = DiagramNode(
      id: 'bm50_${baseId}_19', type: NodeType.process,
      position: const Offset(280, 1390), text: 'rango = max - min',
      metadata: {'processType': 'arithmetic'},
    );
    final n20 = DiagramNode(
      id: 'bm50_${baseId}_20', type: NodeType.data,
      position: const Offset(280, 1480), text: 'Escribir "Rango:", rango',
      metadata: {'isOutput': true},
    );
    nodes.addAll([n11, n12, n13, n14, n15, n16, n17, n18, n19, n20]);

    // ---- Sección 5: Ordenamiento Burbuja (nodos 21-35) ----
    final n21 = DiagramNode(
      id: 'bm50_${baseId}_21', type: NodeType.preparation,
      position: const Offset(280, 1570), text: 'i = 0; i < n-1; i++',
    );
    final n22 = DiagramNode(
      id: 'bm50_${baseId}_22', type: NodeType.preparation,
      position: const Offset(280, 1660), text: 'j = 0; j < n-i-1; j++',
    );
    final n23 = DiagramNode(
      id: 'bm50_${baseId}_23', type: NodeType.decision,
      position: const Offset(280, 1760), text: 'arr[j] > arr[j+1]',
    );
    final n24 = DiagramNode(
      id: 'bm50_${baseId}_24', type: NodeType.process,
      position: const Offset(480, 1760), text: 'temp = arr[j]',
      metadata: {'processType': 'assignment'},
    );
    final n25 = DiagramNode(
      id: 'bm50_${baseId}_25', type: NodeType.process,
      position: const Offset(480, 1850), text: 'arr[j] = arr[j+1]',
      metadata: {'processType': 'assignment'},
    );
    final n26 = DiagramNode(
      id: 'bm50_${baseId}_26', type: NodeType.process,
      position: const Offset(480, 1940), text: 'arr[j+1] = temp',
      metadata: {'processType': 'assignment'},
    );
    final n27 = DiagramNode(
      id: 'bm50_${baseId}_27', type: NodeType.process,
      position: const Offset(280, 2030), text: 'intercambios++',
      metadata: {'processType': 'arithmetic'},
    );
    final n28 = DiagramNode(
      id: 'bm50_${baseId}_28', type: NodeType.data,
      position: const Offset(280, 2120), text: 'Escribir "Arreglo ordenado:"',
      metadata: {'isOutput': true},
    );
    final n29 = DiagramNode(
      id: 'bm50_${baseId}_29', type: NodeType.preparation,
      position: const Offset(280, 2210), text: 'i = 0; i < n; i++',
    );
    final n30 = DiagramNode(
      id: 'bm50_${baseId}_30', type: NodeType.data,
      position: const Offset(280, 2310), text: 'Escribir arr[i]',
      metadata: {'isOutput': true},
    );
    final n31 = DiagramNode(
      id: 'bm50_${baseId}_31', type: NodeType.data,
      position: const Offset(280, 2400), text: 'Escribir "Intercambios:", intercambios',
      metadata: {'isOutput': true},
    );
    final n32 = DiagramNode(
      id: 'bm50_${baseId}_32', type: NodeType.process,
      position: const Offset(280, 2490), text: 'eficiencia = (n * n - intercambios) * 100 / (n * n)',
      metadata: {'processType': 'arithmetic'},
    );
    final n33 = DiagramNode(
      id: 'bm50_${baseId}_33', type: NodeType.data,
      position: const Offset(280, 2580), text: 'Escribir "Eficiencia:", eficiencia, "%"',
      metadata: {'isOutput': true},
    );
    final n34 = DiagramNode(
      id: 'bm50_${baseId}_34', type: NodeType.decision,
      position: const Offset(280, 2670), text: 'eficiencia >= 75.0',
    );
    final n35 = DiagramNode(
      id: 'bm50_${baseId}_35', type: NodeType.data,
      position: const Offset(480, 2670), text: 'Escribir "Resultado: Eficiente"',
      metadata: {'isOutput': true},
    );
    nodes.addAll([n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
                  n31, n32, n33, n34, n35]);

    // ---- Sección 6: Análisis final (nodos 36-50) ----
    final n36 = DiagramNode(
      id: 'bm50_${baseId}_36', type: NodeType.data,
      position: const Offset(80, 2670), text: 'Escribir "Resultado: Mejorable"',
      metadata: {'isOutput': true},
    );
    final n37 = DiagramNode(
      id: 'bm50_${baseId}_37', type: NodeType.process,
      position: const Offset(280, 2780), text: 'mediana = arr[n/2]',
      metadata: {'processType': 'assignment'},
    );
    final n38 = DiagramNode(
      id: 'bm50_${baseId}_38', type: NodeType.data,
      position: const Offset(280, 2870), text: 'Escribir "Mediana:", mediana',
      metadata: {'isOutput': true},
    );
    final n39 = DiagramNode(
      id: 'bm50_${baseId}_39', type: NodeType.process,
      position: const Offset(280, 2960), text: 'varianza = 0.0',
      metadata: {'processType': 'initialization'},
    );
    final n40 = DiagramNode(
      id: 'bm50_${baseId}_40', type: NodeType.preparation,
      position: const Offset(280, 3050), text: 'i = 0; i < n; i++',
    );
    final n41 = DiagramNode(
      id: 'bm50_${baseId}_41', type: NodeType.process,
      position: const Offset(280, 3150), text: 'varianza = varianza + (arr[i] - promedio) * (arr[i] - promedio)',
      metadata: {'processType': 'arithmetic'},
    );
    final n42 = DiagramNode(
      id: 'bm50_${baseId}_42', type: NodeType.process,
      position: const Offset(280, 3240), text: 'varianza = varianza / n',
      metadata: {'processType': 'arithmetic'},
    );
    final n43 = DiagramNode(
      id: 'bm50_${baseId}_43', type: NodeType.process,
      position: const Offset(280, 3330), text: 'desviacion = varianza / n',
      metadata: {'processType': 'arithmetic'},
    );
    final n44 = DiagramNode(
      id: 'bm50_${baseId}_44', type: NodeType.data,
      position: const Offset(280, 3420), text: 'Escribir "Varianza:", varianza',
      metadata: {'isOutput': true},
    );
    final n45 = DiagramNode(
      id: 'bm50_${baseId}_45', type: NodeType.data,
      position: const Offset(280, 3510), text: 'Escribir "Desviacion:", desviacion',
      metadata: {'isOutput': true},
    );
    final n46 = DiagramNode(
      id: 'bm50_${baseId}_46', type: NodeType.decision,
      position: const Offset(280, 3600), text: 'desviacion < promedio * 0.1',
    );
    final n47 = DiagramNode(
      id: 'bm50_${baseId}_47', type: NodeType.data,
      position: const Offset(480, 3600), text: 'Escribir "Datos homogéneos"',
      metadata: {'isOutput': true},
    );
    final n48 = DiagramNode(
      id: 'bm50_${baseId}_48', type: NodeType.data,
      position: const Offset(80, 3600), text: 'Escribir "Datos heterogéneos"',
      metadata: {'isOutput': true},
    );
    final n49 = DiagramNode(
      id: 'bm50_${baseId}_49', type: NodeType.data,
      position: const Offset(280, 3710), text: 'Escribir "--- Análisis completo ---"',
      metadata: {'isOutput': true},
    );
    final n50 = DiagramNode(
      id: 'bm50_${baseId}_50', type: NodeType.terminal,
      position: const Offset(280, 3800), text: 'Fin',
    );
    nodes.addAll([n36, n37, n38, n39, n40, n41, n42, n43, n44, n45,
                  n46, n47, n48, n49, n50]);

    connections.addAll([
      Connection(source: n2, target: n3, label: ''),
      Connection(source: n3, target: n4, label: ''),
      Connection(source: n4, target: n5, label: ''),
      Connection(source: n5, target: n6, label: 'No'),
      Connection(source: n5, target: n7, label: 'Sí'),
      Connection(source: n6, target: n50, label: ''),
      Connection(source: n7, target: n8, label: 'Verdadero'),
      Connection(source: n8, target: n9, label: ''),
      Connection(source: n9, target: n7, label: '', isLoopBack: true),
      Connection(source: n7, target: n10, label: 'Falso'),
      Connection(source: n10, target: n11, label: ''),
      Connection(source: n11, target: n12, label: 'Verdadero'),
      Connection(source: n12, target: n13, label: 'Sí'),
      Connection(source: n12, target: n14, label: 'No'),
      Connection(source: n13, target: n14, label: ''),
      Connection(source: n14, target: n15, label: 'Sí'),
      Connection(source: n14, target: n11, label: 'No', isLoopBack: true),
      Connection(source: n15, target: n11, label: '', isLoopBack: true),
      Connection(source: n11, target: n16, label: 'Falso'),
      Connection(source: n16, target: n17, label: ''),
      Connection(source: n17, target: n18, label: ''),
      Connection(source: n18, target: n19, label: ''),
      Connection(source: n19, target: n20, label: ''),
      Connection(source: n20, target: n21, label: ''),
      Connection(source: n21, target: n22, label: 'Verdadero'),
      Connection(source: n22, target: n23, label: 'Verdadero'),
      Connection(source: n23, target: n24, label: 'Sí'),
      Connection(source: n23, target: n22, label: 'No', isLoopBack: true),
      Connection(source: n24, target: n25, label: ''),
      Connection(source: n25, target: n26, label: ''),
      Connection(source: n26, target: n27, label: ''),
      Connection(source: n27, target: n22, label: '', isLoopBack: true),
      Connection(source: n22, target: n21, label: 'Falso', isLoopBack: true),
      Connection(source: n21, target: n28, label: 'Falso'),
      Connection(source: n28, target: n29, label: ''),
      Connection(source: n29, target: n30, label: 'Verdadero'),
      Connection(source: n30, target: n29, label: '', isLoopBack: true),
      Connection(source: n29, target: n31, label: 'Falso'),
      Connection(source: n31, target: n32, label: ''),
      Connection(source: n32, target: n33, label: ''),
      Connection(source: n33, target: n34, label: ''),
      Connection(source: n34, target: n35, label: 'Sí'),
      Connection(source: n34, target: n36, label: 'No'),
      Connection(source: n35, target: n37, label: ''),
      Connection(source: n36, target: n37, label: ''),
      Connection(source: n37, target: n38, label: ''),
      Connection(source: n38, target: n39, label: ''),
      Connection(source: n39, target: n40, label: ''),
      Connection(source: n40, target: n41, label: 'Verdadero'),
      Connection(source: n41, target: n40, label: '', isLoopBack: true),
      Connection(source: n40, target: n42, label: 'Falso'),
      Connection(source: n42, target: n43, label: ''),
      Connection(source: n43, target: n44, label: ''),
      Connection(source: n44, target: n45, label: ''),
      Connection(source: n45, target: n46, label: ''),
      Connection(source: n46, target: n47, label: 'Sí'),
      Connection(source: n46, target: n48, label: 'No'),
      Connection(source: n47, target: n49, label: ''),
      Connection(source: n48, target: n49, label: ''),
      Connection(source: n49, target: n50, label: ''),
    ]);

    return SavedDiagram(
      name: 'BM-50. Benchmark 50 Nodos',
      description:
          'BENCHMARK: Ordenamiento Burbuja con estadísticas completas (min, max, promedio, varianza, desviación). 50 nodos exactos.',
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// BM-75: Benchmark 75 nodos - Gestión de Inventario Básico
  /// Nodos totales: 75
  static Future<SavedDiagram> createBenchmark75Template() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final nodes = <DiagramNode>[];
    final connections = <Connection>[];

    // ---- Bloque A: Inicialización (1-5) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_1', type: NodeType.comment,
        position: const Offset(600, 40),
        text: '/* BENCHMARK 75 NODOS\nGestión de Inventario Básico\nNodos: 75 */'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_2', type: NodeType.terminal,
        position: const Offset(280, 40), text: 'Inicio'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_3', type: NodeType.process,
        position: const Offset(280, 130),
        text: 'int productos[20], precios[20], cantidades[20]\nint n, i, j, opcion, encontrado, contador, totalFinal',
        metadata: {'processType': 'declaration'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_4', type: NodeType.process,
        position: const Offset(280, 230),
        text: 'float total, descuento, impuesto, subtotal, tasaOcupacion, promedioPrecio',
        metadata: {'processType': 'declaration'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_5', type: NodeType.process,
        position: const Offset(280, 320),
        text: 'n = 0\ntotal = 0.0\ndescuento = 0.0',
        metadata: {'processType': 'initialization'}));

    // ---- Bloque B: Menú principal (6-16) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_6', type: NodeType.data,
        position: const Offset(280, 410),
        text: 'Escribir "=== INVENTARIO ==="', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_7', type: NodeType.data,
        position: const Offset(280, 500),
        text: 'Escribir "1-Agregar 2-Eliminar 3-Buscar 4-Reporte 5-Salir"',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_8', type: NodeType.data,
        position: const Offset(280, 590),
        text: 'Leer opcion', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_9', type: NodeType.decision,
        position: const Offset(280, 690), text: 'opcion == 5'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_10', type: NodeType.decision,
        position: const Offset(280, 800), text: 'opcion == 1'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_11', type: NodeType.decision,
        position: const Offset(280, 910), text: 'opcion == 2'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_12', type: NodeType.decision,
        position: const Offset(280, 1020), text: 'opcion == 3'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_13', type: NodeType.decision,
        position: const Offset(280, 1130), text: 'opcion == 4'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_14', type: NodeType.data,
        position: const Offset(480, 1130),
        text: 'Escribir "Opción inválida"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_15', type: NodeType.decision,
        position: const Offset(280, 1240), text: 'n < 20'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_16', type: NodeType.data,
        position: const Offset(480, 1240),
        text: 'Escribir "Inventario lleno"', metadata: {'isOutput': true}));

    // ---- Bloque C: Agregar producto (17-26) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_17', type: NodeType.data,
        position: const Offset(280, 1350),
        text: 'Leer productos[n]', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_18', type: NodeType.data,
        position: const Offset(280, 1440),
        text: 'Leer precios[n]', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_19', type: NodeType.data,
        position: const Offset(280, 1530),
        text: 'Leer cantidades[n]', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_20', type: NodeType.decision,
        position: const Offset(280, 1620), text: 'precios[n] > 0'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_21', type: NodeType.data,
        position: const Offset(480, 1620),
        text: 'Escribir "Precio inválido"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_22', type: NodeType.decision,
        position: const Offset(280, 1730), text: 'cantidades[n] >= 0'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_23', type: NodeType.data,
        position: const Offset(480, 1730),
        text: 'Escribir "Cantidad inválida"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_24', type: NodeType.process,
        position: const Offset(280, 1840),
        text: 'n++', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_25', type: NodeType.data,
        position: const Offset(280, 1930),
        text: 'Escribir "Producto agregado"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_26', type: NodeType.process,
        position: const Offset(280, 2020),
        text: 'subtotal = precios[n-1] * cantidades[n-1]',
        metadata: {'processType': 'arithmetic'}));

    // ---- Bloque D: Eliminar producto (27-34) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_27', type: NodeType.decision,
        position: const Offset(280, 2110), text: 'opcion == 2 && n > 0'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_28', type: NodeType.data,
        position: const Offset(480, 2110),
        text: 'Escribir "Sin productos"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_29', type: NodeType.data,
        position: const Offset(280, 2220),
        text: 'Escribir "Índice a eliminar:"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_30', type: NodeType.data,
        position: const Offset(280, 2310),
        text: 'Leer i', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_31', type: NodeType.decision,
        position: const Offset(280, 2400), text: 'i >= 0 && i < n'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_32', type: NodeType.data,
        position: const Offset(480, 2400),
        text: 'Escribir "Índice inválido"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_33', type: NodeType.preparation,
        position: const Offset(280, 2510), text: 'j = i; j < n-1; j++'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_34', type: NodeType.process,
        position: const Offset(280, 2610),
        text: 'productos[j] = productos[j+1]\nprecios[j] = precios[j+1]\ncantidades[j] = cantidades[j+1]',
        metadata: {'processType': 'assignment'}));

    // ---- Bloque E: Búsqueda (35-44) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_35', type: NodeType.process,
        position: const Offset(280, 2700),
        text: 'n--', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_36', type: NodeType.data,
        position: const Offset(280, 2790),
        text: 'Escribir "Clave de búsqueda:"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_37', type: NodeType.data,
        position: const Offset(280, 2880),
        text: 'Leer clave', metadata: {'isOutput': false}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_38', type: NodeType.process,
        position: const Offset(280, 2970),
        text: 'encontrado = -1', metadata: {'processType': 'initialization'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_39', type: NodeType.preparation,
        position: const Offset(280, 3060), text: 'i = 0; i < n; i++'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_40', type: NodeType.decision,
        position: const Offset(280, 3160), text: 'productos[i] == clave'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_41', type: NodeType.process,
        position: const Offset(480, 3160),
        text: 'encontrado = i', metadata: {'processType': 'assignment'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_42', type: NodeType.decision,
        position: const Offset(280, 3270), text: 'encontrado >= 0'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_43', type: NodeType.data,
        position: const Offset(480, 3270),
        text: 'Escribir "Encontrado en:", encontrado',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_44', type: NodeType.data,
        position: const Offset(80, 3270),
        text: 'Escribir "No encontrado"', metadata: {'isOutput': true}));

    // ---- Bloque F: Reporte (45-60) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_45', type: NodeType.data,
        position: const Offset(280, 3380),
        text: 'Escribir "=== REPORTE ==="', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_46', type: NodeType.process,
        position: const Offset(280, 3470),
        text: 'total = 0.0\ncontador = 0', metadata: {'processType': 'initialization'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_47', type: NodeType.preparation,
        position: const Offset(280, 3560), text: 'i = 0; i < n; i++'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_48', type: NodeType.process,
        position: const Offset(280, 3660),
        text: 'subtotal = precios[i] * cantidades[i]',
        metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_49', type: NodeType.process,
        position: const Offset(280, 3750),
        text: 'total += subtotal', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_50', type: NodeType.data,
        position: const Offset(280, 3840),
        text: 'Escribir productos[i], precios[i], cantidades[i], subtotal',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_51', type: NodeType.decision,
        position: const Offset(280, 3930), text: 'cantidades[i] < 5'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_52', type: NodeType.data,
        position: const Offset(480, 3930),
        text: 'Escribir "ALERTA: Stock bajo"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_53', type: NodeType.decision,
        position: const Offset(280, 4040), text: 'precios[i] > 1000'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_54', type: NodeType.data,
        position: const Offset(480, 4040),
        text: 'Escribir "Producto premium"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_55', type: NodeType.process,
        position: const Offset(280, 4150),
        text: 'contador++', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_56', type: NodeType.process,
        position: const Offset(280, 4240),
        text: 'descuento = total * 0.05', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_57', type: NodeType.process,
        position: const Offset(280, 4330),
        text: 'impuesto = total * 0.16', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_58', type: NodeType.process,
        position: const Offset(280, 4420),
        text: 'totalFinal = total - descuento + impuesto',
        metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_59', type: NodeType.data,
        position: const Offset(280, 4510),
        text: 'Escribir "Total:", total, "Desc:", descuento, "IVA:", impuesto',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_60', type: NodeType.data,
        position: const Offset(280, 4600),
        text: 'Escribir "Total Final:", totalFinal', metadata: {'isOutput': true}));

    // ---- Bloque G: Análisis de categorías (61-74) ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_61', type: NodeType.decision,
        position: const Offset(280, 4690), text: 'totalFinal > 10000'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_62', type: NodeType.data,
        position: const Offset(480, 4690),
        text: 'Escribir "Compra mayor"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_63', type: NodeType.decision,
        position: const Offset(280, 4800), text: 'totalFinal > 5000'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_64', type: NodeType.data,
        position: const Offset(480, 4800),
        text: 'Escribir "Compra mediana"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_65', type: NodeType.data,
        position: const Offset(80, 4800),
        text: 'Escribir "Compra menor"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_66', type: NodeType.process,
        position: const Offset(280, 4910),
        text: 'promedioPrecio = total / n', metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_67', type: NodeType.data,
        position: const Offset(280, 5000),
        text: 'Escribir "Promedio precio:", promedioPrecio',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_68', type: NodeType.decision,
        position: const Offset(280, 5090), text: 'n > 0'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_69', type: NodeType.process,
        position: const Offset(280, 5190),
        text: 'tasaOcupacion = n * 100 / 20',
        metadata: {'processType': 'arithmetic'}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_70', type: NodeType.data,
        position: const Offset(280, 5280),
        text: 'Escribir "Ocupación:", tasaOcupacion, "%"',
        metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_71', type: NodeType.decision,
        position: const Offset(280, 5370), text: 'tasaOcupacion > 80'));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_72', type: NodeType.data,
        position: const Offset(480, 5370),
        text: 'Escribir "Inventario casi lleno"', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_73', type: NodeType.data,
        position: const Offset(280, 5480),
        text: 'Escribir "=== FIN REPORTE ==="', metadata: {'isOutput': true}));
    nodes.add(DiagramNode(id: 'bm75_${baseId}_74', type: NodeType.data,
        position: const Offset(480, 5090),
        text: 'Escribir "Inventario vacío"', metadata: {'isOutput': true}));

    // ---- Nodo 75: Fin ----
    nodes.add(DiagramNode(id: 'bm75_${baseId}_75', type: NodeType.terminal,
        position: const Offset(280, 5580), text: 'Fin'));

    final nodeMap = {for (var nd in nodes) nd.id: nd};
    String id(int i) => 'bm75_${baseId}_$i';
    DiagramNode nd(int i) => nodeMap[id(i)]!;

    connections.addAll([
      Connection(source: nd(2), target: nd(3), label: ''),
      Connection(source: nd(3), target: nd(4), label: ''),
      Connection(source: nd(4), target: nd(5), label: ''),
      Connection(source: nd(5), target: nd(6), label: ''),
      Connection(source: nd(6), target: nd(7), label: ''),
      Connection(source: nd(7), target: nd(8), label: ''),
      Connection(source: nd(8), target: nd(9), label: ''),
      Connection(source: nd(9), target: nd(75), label: 'Sí'),
      Connection(source: nd(9), target: nd(10), label: 'No'),
      Connection(source: nd(10), target: nd(15), label: 'Sí'),
      Connection(source: nd(10), target: nd(11), label: 'No'),
      Connection(source: nd(15), target: nd(16), label: 'No'),
      Connection(source: nd(15), target: nd(17), label: 'Sí'),
      Connection(source: nd(16), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(17), target: nd(18), label: ''),
      Connection(source: nd(18), target: nd(19), label: ''),
      Connection(source: nd(19), target: nd(20), label: ''),
      Connection(source: nd(20), target: nd(21), label: 'No'),
      Connection(source: nd(20), target: nd(22), label: 'Sí'),
      Connection(source: nd(21), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(22), target: nd(23), label: 'No'),
      Connection(source: nd(22), target: nd(24), label: 'Sí'),
      Connection(source: nd(23), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(24), target: nd(25), label: ''),
      Connection(source: nd(25), target: nd(26), label: ''),
      Connection(source: nd(26), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(11), target: nd(27), label: 'Sí'),
      Connection(source: nd(11), target: nd(12), label: 'No'),
      Connection(source: nd(27), target: nd(28), label: 'No'),
      Connection(source: nd(27), target: nd(29), label: 'Sí'),
      Connection(source: nd(28), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(29), target: nd(30), label: ''),
      Connection(source: nd(30), target: nd(31), label: ''),
      Connection(source: nd(31), target: nd(32), label: 'No'),
      Connection(source: nd(31), target: nd(33), label: 'Sí'),
      Connection(source: nd(32), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(33), target: nd(34), label: 'Verdadero'),
      Connection(source: nd(34), target: nd(33), label: '', isLoopBack: true),
      Connection(source: nd(33), target: nd(35), label: 'Falso'),
      Connection(source: nd(35), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(12), target: nd(36), label: 'Sí'),
      Connection(source: nd(12), target: nd(13), label: 'No'),
      Connection(source: nd(36), target: nd(37), label: ''),
      Connection(source: nd(37), target: nd(38), label: ''),
      Connection(source: nd(38), target: nd(39), label: ''),
      Connection(source: nd(39), target: nd(40), label: 'Verdadero'),
      Connection(source: nd(40), target: nd(41), label: 'Sí'),
      Connection(source: nd(40), target: nd(39), label: 'No', isLoopBack: true),
      Connection(source: nd(41), target: nd(39), label: '', isLoopBack: true),
      Connection(source: nd(39), target: nd(42), label: 'Falso'),
      Connection(source: nd(42), target: nd(43), label: 'Sí'),
      Connection(source: nd(42), target: nd(44), label: 'No'),
      Connection(source: nd(43), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(44), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(13), target: nd(45), label: 'Sí'),
      Connection(source: nd(13), target: nd(14), label: 'No'),
      Connection(source: nd(14), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(45), target: nd(46), label: ''),
      Connection(source: nd(46), target: nd(47), label: ''),
      Connection(source: nd(47), target: nd(48), label: 'Verdadero'),
      Connection(source: nd(48), target: nd(49), label: ''),
      Connection(source: nd(49), target: nd(50), label: ''),
      Connection(source: nd(50), target: nd(51), label: ''),
      Connection(source: nd(51), target: nd(52), label: 'Sí'),
      Connection(source: nd(51), target: nd(53), label: 'No'),
      Connection(source: nd(52), target: nd(53), label: ''),
      Connection(source: nd(53), target: nd(54), label: 'Sí'),
      Connection(source: nd(53), target: nd(55), label: 'No'),
      Connection(source: nd(54), target: nd(55), label: ''),
      Connection(source: nd(55), target: nd(47), label: '', isLoopBack: true),
      Connection(source: nd(47), target: nd(56), label: 'Falso'),
      Connection(source: nd(56), target: nd(57), label: ''),
      Connection(source: nd(57), target: nd(58), label: ''),
      Connection(source: nd(58), target: nd(59), label: ''),
      Connection(source: nd(59), target: nd(60), label: ''),
      Connection(source: nd(60), target: nd(61), label: ''),
      Connection(source: nd(61), target: nd(62), label: 'Sí'),
      Connection(source: nd(61), target: nd(63), label: 'No'),
      Connection(source: nd(62), target: nd(66), label: ''),
      Connection(source: nd(63), target: nd(64), label: 'Sí'),
      Connection(source: nd(63), target: nd(65), label: 'No'),
      Connection(source: nd(64), target: nd(66), label: ''),
      Connection(source: nd(65), target: nd(66), label: ''),
      Connection(source: nd(66), target: nd(67), label: ''),
      Connection(source: nd(67), target: nd(68), label: ''),
      Connection(source: nd(68), target: nd(74), label: 'No'),
      Connection(source: nd(68), target: nd(69), label: 'Sí'),
      Connection(source: nd(74), target: nd(73), label: ''),
      Connection(source: nd(69), target: nd(70), label: ''),
      Connection(source: nd(70), target: nd(71), label: ''),
      Connection(source: nd(71), target: nd(72), label: 'Sí'),
      Connection(source: nd(71), target: nd(73), label: 'No'),
      Connection(source: nd(72), target: nd(73), label: ''),
      Connection(source: nd(73), target: nd(6), label: '', isLoopBack: true),
      Connection(source: nd(75), target: nd(75), label: ''),
    ]);

    return SavedDiagram(
      name: 'BM-75. Benchmark 75 Nodos',
      description:
          'BENCHMARK: Sistema de Gestión de Inventario (agregar, eliminar, buscar, reporte). 75 nodos exactos.',
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// BM-100: Benchmark 100 nodos - Sistema de Calificaciones Universitario
  /// Nodos totales: 100
  static Future<SavedDiagram> createBenchmark100Template() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final nodes = <DiagramNode>[];
    final connections = <Connection>[];

    void addNode(int i, NodeType type, Offset pos, String text,
        [Map<String, dynamic>? meta]) {
      nodes.add(DiagramNode(
        id: 'bm100_${baseId}_$i',
        type: type,
        position: pos,
        text: text,
        metadata: meta,
      ));
    }

    // ---- Bloque A: Inicialización (1-6) ----
    addNode(1, NodeType.comment, const Offset(620, 40),
        '/* BENCHMARK 100 NODOS\nSistema de Calificaciones Universitario\nNodos: 100 */');
    addNode(2, NodeType.terminal, const Offset(300, 40), 'Inicio');
    addNode(3, NodeType.process, const Offset(300, 130),
        'int numAlumnos, numMaterias, aprobados, reprobados, i, j, k, idxMax, idxMin, modaIdx',
        {'processType': 'declaration'});
    addNode(4, NodeType.process, const Offset(300, 230),
        'float promAlumno, promMateria, promedioGrupo, tasaAprobacion, maxProm, minProm, rango, varianza, desviacion, indiceEficiencia',
        {'processType': 'declaration'});
    addNode(5, NodeType.data, const Offset(300, 330),
        'Leer numAlumnos, numMaterias', {'isOutput': false});
    addNode(6, NodeType.decision, const Offset(300, 430),
        'numAlumnos >= 1 && numAlumnos <= 30 && numMaterias >= 1 && numMaterias <= 10');

    // ---- Bloque B: Validación de entrada (7-14) ----
    addNode(7, NodeType.data, const Offset(560, 430),
        'Escribir "Parámetros fuera de rango"', {'isOutput': true});
    addNode(8, NodeType.process, const Offset(300, 540),
        'aprobados = 0\nreprobados = 0\npromedioGrupo = 0', {'processType': 'initialization'});
    addNode(9, NodeType.preparation, const Offset(300, 630),
        'i = 0; i < numAlumnos; i++');
    addNode(10, NodeType.process, const Offset(300, 730),
        'promAlumno = 0', {'processType': 'initialization'});
    addNode(11, NodeType.preparation, const Offset(300, 820),
        'j = 0; j < numMaterias; j++');
    addNode(12, NodeType.data, const Offset(300, 920),
        'Leer promAlumno', {'isOutput': false});
    addNode(13, NodeType.decision, const Offset(300, 1020),
        'promAlumno >= 0 && promAlumno <= 10');
    addNode(14, NodeType.data, const Offset(500, 1020),
        'Escribir "Calificación inválida"', {'isOutput': true});

    // ---- Bloque C: Cálculo promedio por alumno (15-26) ----
    addNode(15, NodeType.process, const Offset(300, 1130),
        'promAlumno = promAlumno + promMateria', {'processType': 'arithmetic'});
    addNode(16, NodeType.process, const Offset(300, 1220),
        'promAlumno = promAlumno / numMaterias', {'processType': 'arithmetic'});
    addNode(17, NodeType.decision, const Offset(300, 1320),
        'promAlumno >= 6');
    addNode(18, NodeType.process, const Offset(500, 1320),
        'aprobados++', {'processType': 'assignment'});
    addNode(19, NodeType.process, const Offset(100, 1320),
        'reprobados++', {'processType': 'assignment'});
    addNode(20, NodeType.decision, const Offset(300, 1450),
        'promAlumno >= 9');
    addNode(21, NodeType.data, const Offset(500, 1450),
        'Escribir "Alumno", i, "Distinción"', {'isOutput': true});
    addNode(22, NodeType.decision, const Offset(300, 1570),
        'promAlumno >= 8');
    addNode(23, NodeType.data, const Offset(500, 1570),
        'Escribir "Alumno", i, "Notable"', {'isOutput': true});
    addNode(24, NodeType.decision, const Offset(300, 1690),
        'promAlumno >= 7');
    addNode(25, NodeType.data, const Offset(500, 1690),
        'Escribir "Alumno", i, "Bien"', {'isOutput': true});
    addNode(26, NodeType.data, const Offset(100, 1690),
        'Escribir "Alumno", i, "Suficiente o Reprobado"', {'isOutput': true});

    // ---- Bloque D: Promedio por materia (27-40) ----
    addNode(27, NodeType.process, const Offset(300, 1820),
        'promedioGrupo = promedioGrupo + promAlumno', {'processType': 'arithmetic'});
    addNode(28, NodeType.preparation, const Offset(300, 1910),
        'j = 0; j < numMaterias; j++');
    addNode(29, NodeType.process, const Offset(300, 2010),
        'promMateria = 0', {'processType': 'initialization'});
    addNode(30, NodeType.preparation, const Offset(300, 2100),
        'i = 0; i < numAlumnos; i++');
    addNode(31, NodeType.process, const Offset(300, 2200),
        'promMateria = promMateria + promAlumno', {'processType': 'arithmetic'});
    addNode(32, NodeType.process, const Offset(300, 2300),
        'promMateria = promMateria / numAlumnos', {'processType': 'arithmetic'});
    addNode(33, NodeType.decision, const Offset(300, 2400),
        'promMateria < 6');
    addNode(34, NodeType.data, const Offset(500, 2400),
        'Escribir "Materia", j, "REPROBADA"', {'isOutput': true});
    addNode(35, NodeType.process, const Offset(300, 2510),
        'promedioGrupo = promedioGrupo / numAlumnos', {'processType': 'arithmetic'});
    addNode(36, NodeType.data, const Offset(300, 2610),
        'Escribir "Promedio Grupo:", promedioGrupo', {'isOutput': true});
    addNode(37, NodeType.data, const Offset(300, 2700),
        'Escribir "Aprobados:", aprobados, "Reprobados:", reprobados',
        {'isOutput': true});
    addNode(38, NodeType.process, const Offset(300, 2790),
        'tasaAprobacion = aprobados * 100 / numAlumnos',
        {'processType': 'arithmetic'});
    addNode(39, NodeType.data, const Offset(300, 2880),
        'Escribir "Tasa aprobación:", tasaAprobacion, "%"', {'isOutput': true});
    addNode(40, NodeType.decision, const Offset(300, 2970),
        'tasaAprobacion >= 70.0');

    // ---- Bloque E: Análisis avanzado (41-60) ----
    addNode(41, NodeType.data, const Offset(500, 2970),
        'Escribir "Grupo aprobado"', {'isOutput': true});
    addNode(42, NodeType.data, const Offset(100, 2970),
        'Escribir "Grupo con dificultades"', {'isOutput': true});
    addNode(43, NodeType.process, const Offset(300, 3090),
        'maxProm = promAlumno\nminProm = promAlumno', {'processType': 'initialization'});
    addNode(44, NodeType.process, const Offset(300, 3180),
        'idxMax = 0\nidxMin = 0', {'processType': 'initialization'});
    addNode(45, NodeType.preparation, const Offset(300, 3270),
        'i = 1; i < numAlumnos; i++');
    addNode(46, NodeType.decision, const Offset(300, 3370),
        'promAlumno > maxProm');
    addNode(47, NodeType.process, const Offset(500, 3370),
        'maxProm = promAlumno\nidxMax = i', {'processType': 'assignment'});
    addNode(48, NodeType.decision, const Offset(300, 3490),
        'promAlumno < minProm');
    addNode(49, NodeType.process, const Offset(500, 3490),
        'minProm = promAlumno\nidxMin = i', {'processType': 'assignment'});
    addNode(50, NodeType.data, const Offset(300, 3610),
        'Escribir "Mejor alumno:", idxMax, maxProm', {'isOutput': true});
    addNode(51, NodeType.data, const Offset(300, 3700),
        'Escribir "Peor alumno:", idxMin, minProm', {'isOutput': true});
    addNode(52, NodeType.process, const Offset(300, 3790),
        'rango = maxProm - minProm', {'processType': 'arithmetic'});
    addNode(53, NodeType.data, const Offset(300, 3880),
        'Escribir "Rango promedios:", rango', {'isOutput': true});
    addNode(54, NodeType.process, const Offset(300, 3970),
        'varianza = 0.0', {'processType': 'initialization'});
    addNode(55, NodeType.preparation, const Offset(300, 4060),
        'i = 0; i < numAlumnos; i++');
    addNode(56, NodeType.process, const Offset(300, 4160),
        'varianza = varianza + (promAlumno - promedioGrupo) * (promAlumno - promedioGrupo)',
        {'processType': 'arithmetic'});
    addNode(57, NodeType.process, const Offset(300, 4260),
        'varianza = varianza / numAlumnos', {'processType': 'arithmetic'});
    addNode(58, NodeType.process, const Offset(300, 4350),
        'desviacion = varianza / numAlumnos', {'processType': 'arithmetic'});
    addNode(59, NodeType.data, const Offset(300, 4440),
        'Escribir "Varianza:", varianza, "Desv:", desviacion', {'isOutput': true});
    addNode(60, NodeType.decision, const Offset(300, 4540),
        'desviacion < 1.5');

    // ---- Bloque F: Histograma de calificaciones (61-80) ----
    addNode(61, NodeType.data, const Offset(500, 4540),
        'Escribir "Grupo homogéneo"', {'isOutput': true});
    addNode(62, NodeType.data, const Offset(100, 4540),
        'Escribir "Grupo heterogéneo"', {'isOutput': true});
    addNode(63, NodeType.process, const Offset(300, 4660),
        'int hist0, hist1, hist2, hist3, hist4', {'processType': 'declaration'});
    addNode(64, NodeType.preparation, const Offset(300, 4750),
        'i = 0; i < numAlumnos; i++');
    addNode(65, NodeType.decision, const Offset(300, 4850),
        'promAlumno >= 9');
    addNode(66, NodeType.process, const Offset(500, 4850),
        'hist0++', {'processType': 'arithmetic'});
    addNode(67, NodeType.decision, const Offset(300, 4970),
        'promAlumno >= 8');
    addNode(68, NodeType.process, const Offset(500, 4970),
        'hist1++', {'processType': 'arithmetic'});
    addNode(69, NodeType.decision, const Offset(300, 5090),
        'promAlumno >= 7');
    addNode(70, NodeType.process, const Offset(500, 5090),
        'hist2++', {'processType': 'arithmetic'});
    addNode(71, NodeType.decision, const Offset(300, 5210),
        'promAlumno >= 6');
    addNode(72, NodeType.process, const Offset(500, 5210),
        'hist3++', {'processType': 'arithmetic'});
    addNode(73, NodeType.process, const Offset(100, 5210),
        'hist4++', {'processType': 'arithmetic'});
    addNode(74, NodeType.data, const Offset(300, 5330),
        'Escribir "=== HISTOGRAMA ==="', {'isOutput': true});
    addNode(75, NodeType.data, const Offset(300, 5420),
        'Escribir "9-10:", hist0', {'isOutput': true});
    addNode(76, NodeType.data, const Offset(300, 5510),
        'Escribir "8-9:", hist1', {'isOutput': true});
    addNode(77, NodeType.data, const Offset(300, 5600),
        'Escribir "7-8:", hist2', {'isOutput': true});
    addNode(78, NodeType.data, const Offset(300, 5690),
        'Escribir "6-7:", hist3', {'isOutput': true});
    addNode(79, NodeType.data, const Offset(300, 5780),
        'Escribir "0-6:", hist4', {'isOutput': true});
    addNode(80, NodeType.process, const Offset(300, 5870),
        'modaIdx = 0', {'processType': 'initialization'});

    // ---- Bloque G: Moda del histograma y reporte final (81-100) ----
    addNode(81, NodeType.preparation, const Offset(300, 5960),
        'k = 1; k < 5; k++');
    addNode(82, NodeType.decision, const Offset(300, 6060),
        'k > modaIdx');
    addNode(83, NodeType.process, const Offset(500, 6060),
        'modaIdx = k', {'processType': 'assignment'});
    addNode(84, NodeType.data, const Offset(300, 6180),
        'Escribir "Moda en rango:", modaIdx', {'isOutput': true});
    addNode(85, NodeType.decision, const Offset(300, 6280),
        'aprobados > reprobados');
    addNode(86, NodeType.data, const Offset(500, 6280),
        'Escribir "Balance: positivo"', {'isOutput': true});
    addNode(87, NodeType.data, const Offset(100, 6280),
        'Escribir "Balance: negativo o neutro"', {'isOutput': true});
    addNode(88, NodeType.process, const Offset(300, 6400),
        'indiceEficiencia = tasaAprobacion * (promedioGrupo / 10.0)',
        {'processType': 'arithmetic'});
    addNode(89, NodeType.data, const Offset(300, 6490),
        'Escribir "Índice eficiencia:", indiceEficiencia', {'isOutput': true});
    addNode(90, NodeType.decision, const Offset(300, 6590),
        'indiceEficiencia >= 60.0');
    addNode(91, NodeType.data, const Offset(500, 6590),
        'Escribir "Desempeño: SATISFACTORIO"', {'isOutput': true});
    addNode(92, NodeType.data, const Offset(100, 6590),
        'Escribir "Desempeño: INSATISFACTORIO"', {'isOutput': true});
    addNode(93, NodeType.data, const Offset(300, 6710),
        'Escribir "=== RESUMEN FINAL ==="', {'isOutput': true});
    addNode(94, NodeType.data, const Offset(300, 6800),
        'Escribir "Total alumnos:", numAlumnos', {'isOutput': true});
    addNode(95, NodeType.data, const Offset(300, 6890),
        'Escribir "Total materias:", numMaterias', {'isOutput': true});
    addNode(96, NodeType.data, const Offset(300, 6980),
        'Escribir "Promedio grupo:", promedioGrupo', {'isOutput': true});
    addNode(97, NodeType.data, const Offset(300, 7070),
        'Escribir "Máximo:", maxProm, "Mínimo:", minProm', {'isOutput': true});
    addNode(98, NodeType.data, const Offset(300, 7160),
        'Escribir "Desviación estándar:", desviacion', {'isOutput': true});
    addNode(99, NodeType.data, const Offset(300, 7250),
        'Escribir "=== FIN DEL SISTEMA ==="', {'isOutput': true});
    addNode(100, NodeType.terminal, const Offset(300, 7350), 'Fin');

    final nodeMap = {for (var nd in nodes) nd.id: nd};
    String id(int i) => 'bm100_${baseId}_$i';
    DiagramNode nd(int i) => nodeMap[id(i)]!;

    connections.addAll([
      // Bloque A
      Connection(source: nd(2), target: nd(3), label: ''),
      Connection(source: nd(3), target: nd(4), label: ''),
      Connection(source: nd(4), target: nd(5), label: ''),
      Connection(source: nd(5), target: nd(6), label: ''),
      Connection(source: nd(6), target: nd(7), label: 'No'),
      Connection(source: nd(6), target: nd(8), label: 'Sí'),
      Connection(source: nd(7), target: nd(100), label: ''),
      // Bloque B - lectura calificaciones
      Connection(source: nd(8), target: nd(9), label: ''),
      Connection(source: nd(9), target: nd(10), label: 'Verdadero'),
      Connection(source: nd(10), target: nd(11), label: ''),
      Connection(source: nd(11), target: nd(12), label: 'Verdadero'),
      Connection(source: nd(12), target: nd(13), label: ''),
      Connection(source: nd(13), target: nd(14), label: 'No'),
      Connection(source: nd(13), target: nd(15), label: 'Sí'),
      Connection(source: nd(14), target: nd(11), label: '', isLoopBack: true),
      Connection(source: nd(15), target: nd(11), label: '', isLoopBack: true),
      Connection(source: nd(11), target: nd(16), label: 'Falso'),
      // Bloque C - promedios alumno
      Connection(source: nd(16), target: nd(17), label: ''),
      Connection(source: nd(17), target: nd(18), label: 'Sí'),
      Connection(source: nd(17), target: nd(19), label: 'No'),
      Connection(source: nd(18), target: nd(20), label: ''),
      Connection(source: nd(19), target: nd(20), label: ''),
      Connection(source: nd(20), target: nd(21), label: 'Sí'),
      Connection(source: nd(20), target: nd(22), label: 'No'),
      Connection(source: nd(21), target: nd(27), label: ''),
      Connection(source: nd(22), target: nd(23), label: 'Sí'),
      Connection(source: nd(22), target: nd(24), label: 'No'),
      Connection(source: nd(23), target: nd(27), label: ''),
      Connection(source: nd(24), target: nd(25), label: 'Sí'),
      Connection(source: nd(24), target: nd(26), label: 'No'),
      Connection(source: nd(25), target: nd(27), label: ''),
      Connection(source: nd(26), target: nd(27), label: ''),
      Connection(source: nd(27), target: nd(9), label: '', isLoopBack: true),
      Connection(source: nd(9), target: nd(28), label: 'Falso'),
      // Bloque D - promedios materia
      Connection(source: nd(28), target: nd(29), label: 'Verdadero'),
      Connection(source: nd(29), target: nd(30), label: ''),
      Connection(source: nd(30), target: nd(31), label: 'Verdadero'),
      Connection(source: nd(31), target: nd(30), label: '', isLoopBack: true),
      Connection(source: nd(30), target: nd(32), label: 'Falso'),
      Connection(source: nd(32), target: nd(33), label: ''),
      Connection(source: nd(33), target: nd(34), label: 'Sí'),
      Connection(source: nd(33), target: nd(28), label: 'No', isLoopBack: true),
      Connection(source: nd(34), target: nd(28), label: '', isLoopBack: true),
      Connection(source: nd(28), target: nd(35), label: 'Falso'),
      Connection(source: nd(35), target: nd(36), label: ''),
      Connection(source: nd(36), target: nd(37), label: ''),
      Connection(source: nd(37), target: nd(38), label: ''),
      Connection(source: nd(38), target: nd(39), label: ''),
      Connection(source: nd(39), target: nd(40), label: ''),
      Connection(source: nd(40), target: nd(41), label: 'Sí'),
      Connection(source: nd(40), target: nd(42), label: 'No'),
      Connection(source: nd(41), target: nd(43), label: ''),
      Connection(source: nd(42), target: nd(43), label: ''),
      // Bloque E - estadísticas
      Connection(source: nd(43), target: nd(44), label: ''),
      Connection(source: nd(44), target: nd(45), label: ''),
      Connection(source: nd(45), target: nd(46), label: 'Verdadero'),
      Connection(source: nd(46), target: nd(47), label: 'Sí'),
      Connection(source: nd(46), target: nd(48), label: 'No'),
      Connection(source: nd(47), target: nd(48), label: ''),
      Connection(source: nd(48), target: nd(49), label: 'Sí'),
      Connection(source: nd(48), target: nd(45), label: 'No', isLoopBack: true),
      Connection(source: nd(49), target: nd(45), label: '', isLoopBack: true),
      Connection(source: nd(45), target: nd(50), label: 'Falso'),
      Connection(source: nd(50), target: nd(51), label: ''),
      Connection(source: nd(51), target: nd(52), label: ''),
      Connection(source: nd(52), target: nd(53), label: ''),
      Connection(source: nd(53), target: nd(54), label: ''),
      Connection(source: nd(54), target: nd(55), label: ''),
      Connection(source: nd(55), target: nd(56), label: 'Verdadero'),
      Connection(source: nd(56), target: nd(55), label: '', isLoopBack: true),
      Connection(source: nd(55), target: nd(57), label: 'Falso'),
      Connection(source: nd(57), target: nd(58), label: ''),
      Connection(source: nd(58), target: nd(59), label: ''),
      Connection(source: nd(59), target: nd(60), label: ''),
      Connection(source: nd(60), target: nd(61), label: 'Sí'),
      Connection(source: nd(60), target: nd(62), label: 'No'),
      Connection(source: nd(61), target: nd(63), label: ''),
      Connection(source: nd(62), target: nd(63), label: ''),
      // Bloque F - histograma
      Connection(source: nd(63), target: nd(64), label: ''),
      Connection(source: nd(64), target: nd(65), label: 'Verdadero'),
      Connection(source: nd(65), target: nd(66), label: 'Sí'),
      Connection(source: nd(65), target: nd(67), label: 'No'),
      Connection(source: nd(66), target: nd(64), label: '', isLoopBack: true),
      Connection(source: nd(67), target: nd(68), label: 'Sí'),
      Connection(source: nd(67), target: nd(69), label: 'No'),
      Connection(source: nd(68), target: nd(64), label: '', isLoopBack: true),
      Connection(source: nd(69), target: nd(70), label: 'Sí'),
      Connection(source: nd(69), target: nd(71), label: 'No'),
      Connection(source: nd(70), target: nd(64), label: '', isLoopBack: true),
      Connection(source: nd(71), target: nd(72), label: 'Sí'),
      Connection(source: nd(71), target: nd(73), label: 'No'),
      Connection(source: nd(72), target: nd(64), label: '', isLoopBack: true),
      Connection(source: nd(73), target: nd(64), label: '', isLoopBack: true),
      Connection(source: nd(64), target: nd(74), label: 'Falso'),
      Connection(source: nd(74), target: nd(75), label: ''),
      Connection(source: nd(75), target: nd(76), label: ''),
      Connection(source: nd(76), target: nd(77), label: ''),
      Connection(source: nd(77), target: nd(78), label: ''),
      Connection(source: nd(78), target: nd(79), label: ''),
      Connection(source: nd(79), target: nd(80), label: ''),
      // Bloque G - moda y reporte
      Connection(source: nd(80), target: nd(81), label: ''),
      Connection(source: nd(81), target: nd(82), label: 'Verdadero'),
      Connection(source: nd(82), target: nd(83), label: 'Sí'),
      Connection(source: nd(82), target: nd(81), label: 'No', isLoopBack: true),
      Connection(source: nd(83), target: nd(81), label: '', isLoopBack: true),
      Connection(source: nd(81), target: nd(84), label: 'Falso'),
      Connection(source: nd(84), target: nd(85), label: ''),
      Connection(source: nd(85), target: nd(86), label: 'Sí'),
      Connection(source: nd(85), target: nd(87), label: 'No'),
      Connection(source: nd(86), target: nd(88), label: ''),
      Connection(source: nd(87), target: nd(88), label: ''),
      Connection(source: nd(88), target: nd(89), label: ''),
      Connection(source: nd(89), target: nd(90), label: ''),
      Connection(source: nd(90), target: nd(91), label: 'Sí'),
      Connection(source: nd(90), target: nd(92), label: 'No'),
      Connection(source: nd(91), target: nd(93), label: ''),
      Connection(source: nd(92), target: nd(93), label: ''),
      Connection(source: nd(93), target: nd(94), label: ''),
      Connection(source: nd(94), target: nd(95), label: ''),
      Connection(source: nd(95), target: nd(96), label: ''),
      Connection(source: nd(96), target: nd(97), label: ''),
      Connection(source: nd(97), target: nd(98), label: ''),
      Connection(source: nd(98), target: nd(99), label: ''),
      Connection(source: nd(99), target: nd(100), label: ''),
    ]);

    return SavedDiagram(
      name: 'BM-100. Benchmark 100 Nodos',
      description:
          'BENCHMARK: Sistema completo de Calificaciones Universitarias con estadísticas, histograma y reporte. 100 nodos exactos.',
      createdAt: now,
      updatedAt: now,
      nodes: nodes,
      connections: connections,
      isTemplate: true,
    );
  }

  /// Obtiene una plantilla por su nombre
  static Future<SavedDiagram?> getTemplateByName(String name) async {
    switch (name) {
      case '01. Hola Mundo':
        return createHolaMundoTemplate();
      case '02. Declaración y Tipos de Datos':
        return createTiposDatosTemplate();
      case '03. Calculadora Básica':
        return createCalculadoraBasicaTemplate();
      case '04. Conversión de Temperatura':
        return createConversionTemperaturaTemplate();
      case '05. Par o Impar':
        return createParImparTemplate();
      case '06. Mayor de Tres Números':
        return createMayorDeTresTemplate();
      case '07. Calculadora con Menú':
        return createCalculadoraMenuTemplate();
      case '08. Clasificación de Triángulos':
        return createClasificacionTriangulosTemplate();
      case '09. Contador While':
        return createContadorWhileTemplate();
      case '10. Validación de Entrada (Do-While)':
        return createValidacionDoWhileTemplate();
      case '11. Tabla de Multiplicar (For)':
        return createTablaMultiplicarForTemplate();
      case '12. Factorial Iterativo':
        return createFactorialIterativoTemplate();
      case '13. Suma de Arreglo':
        return createSumaArregloTemplate();
      case '14. Búsqueda Secuencial':
        return createBusquedaSecuencialTemplate();
      case '15. Ordenamiento Burbuja':
        return createBubbleSortTemplate();
      case '16. Ordenamiento Selección':
        return createSelectionSortTemplate();
      case '17. Función Suma':
        return createFuncionSumaTemplate();
      case '18. Función Factorial':
        return createFuncionFactorialTemplate();
      case '19. Intercambio (Swap)':
        return createSwapTemplate();
      case '20. Apuntadores y Arreglos':
        return createApuntadoresArreglosTemplate();
      // BENCHMARK
      case 'BM-10. Benchmark 10 Nodos':
        return createBenchmark10Template();
      case 'BM-25. Benchmark 25 Nodos':
        return createBenchmark25Template();
      case 'BM-50. Benchmark 50 Nodos':
        return createBenchmark50Template();
      case 'BM-75. Benchmark 75 Nodos':
        return createBenchmark75Template();
      case 'BM-100. Benchmark 100 Nodos':
        return createBenchmark100Template();
      default:
        return null;
    }
  }

  /// Obtiene todas las plantillas
  static Future<List<SavedDiagram>> getAllTemplates() async {
    final templates = <SavedDiagram>[];
    for (final name in expectedTemplateNames) {
      final template = await getTemplateByName(name);
      if (template != null) {
        templates.add(template);
      }
    }
    return templates;
  }
}
