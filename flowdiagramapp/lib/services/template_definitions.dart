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
          "Programa básico que muestra un mensaje en pantalla.\nConcepto: printf() - salida estándar",
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
          "Declara variables de tipo int, float y char.\nConcepto: Tipos de datos primitivos en C",
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
      text: "int entero = 10",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'entero',
        'value': '10'
      },
    );

    final declareFloatNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(250, 250),
      text: "float decimal = 3.14",
      metadata: {
        'processType': 'initialization',
        'varType': 'float',
        'varName': 'decimal',
        'value': '3.14'
      },
    );

    final declareCharNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(250, 350),
      text: "char letra = 'A'",
      metadata: {
        'processType': 'initialization',
        'varType': 'char',
        'varName': 'letra',
        'value': "'A'"
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(250, 450),
      text: "Escribir entero, decimal, letra",
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
          "Realiza las 5 operaciones aritméticas básicas.\nConcepto: Operadores +, -, *, /, %",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputANode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(250, 150),
      text: "Leer a",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'a'},
    );

    final inputBNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(250, 250),
      text: "Leer b",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'b'},
    );

    final sumNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(250, 350),
      text: "suma = a + b",
      metadata: {'processType': 'arithmetic', 'operator': '+'},
    );

    final subNode = DiagramNode(
      id: "process_${baseId}_5",
      type: NodeType.process,
      position: const Offset(250, 450),
      text: "resta = a - b",
      metadata: {'processType': 'arithmetic', 'operator': '-'},
    );

    final mulNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(250, 550),
      text: "multiplicacion = a * b",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final divNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(250, 650),
      text: "division = a / b",
      metadata: {'processType': 'arithmetic', 'operator': '/'},
    );

    final modNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(250, 750),
      text: "modulo = a % b",
      metadata: {'processType': 'arithmetic', 'operator': '%'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(250, 850),
      text: "Escribir suma, resta, multiplicacion, division, modulo",
      metadata: {'isOutput': true, 'outputType': 'variables'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_10",
      type: NodeType.terminal,
      position: const Offset(250, 950),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
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
      Connection(source: startNode, target: inputANode, label: ""),
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
          "Convierte temperatura de Celsius a Fahrenheit.\nFórmula: F = (C × 9/5) + 32",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(250, 150),
      text: "Leer celsius",
      metadata: {'isOutput': false, 'inputType': 'float', 'varName': 'celsius'},
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(250, 250),
      text: "fahrenheit = (celsius * 9.0 / 5.0) + 32.0",
      metadata: {'processType': 'arithmetic'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(250, 350),
      text: "Escribir fahrenheit",
      metadata: {'isOutput': true, 'outputType': 'float'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_5",
      type: NodeType.terminal,
      position: const Offset(250, 450),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      processNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
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
          "Determina si un número es par o impar.\nConcepto: if-else, operador módulo (%)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(250, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(250, 150),
      text: "Leer numero",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'numero'},
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_3",
      type: NodeType.decision,
      position: const Offset(250, 270),
      text: "numero % 2 == 0",
    );

    final outputParNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(420, 400),
      text: "Escribir \"El número es par\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputImparNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(80, 400),
      text: "Escribir \"El número es impar\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(250, 530),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      decisionNode,
      outputParNode,
      outputImparNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
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
      text: "Encuentra el mayor de tres números.\nConcepto: if-else anidados",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    final inputANode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(300, 140),
      text: "Leer a, b, c",
      metadata: {'isOutput': false, 'inputType': 'int'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_3",
      type: NodeType.decision,
      position: const Offset(300, 250),
      text: "a > b",
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(480, 370),
      text: "a > c",
    );

    final decision3Node = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(120, 370),
      text: "b > c",
    );

    final outputANode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(580, 490),
      text: "Escribir \"Mayor: \", a",
      metadata: {'isOutput': true},
    );

    final outputCNode1 = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(380, 490),
      text: "Escribir \"Mayor: \", c",
      metadata: {'isOutput': true},
    );

    final outputBNode = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(20, 490),
      text: "Escribir \"Mayor: \", b",
      metadata: {'isOutput': true},
    );

    final outputCNode2 = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(220, 490),
      text: "Escribir \"Mayor: \", c",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_10",
      type: NodeType.terminal,
      position: const Offset(300, 610),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
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
      Connection(source: startNode, target: inputANode, label: ""),
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
          "Calculadora con menú de opciones.\nConcepto: switch-case (if-else múltiple)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(300, 50),
      text: "Inicio",
    );

    final inputNumsNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(300, 140),
      text: "Leer a, b",
      metadata: {'isOutput': false, 'inputType': 'float'},
    );

    final outputMenuNode = DiagramNode(
      id: "output_${baseId}_3",
      type: NodeType.data,
      position: const Offset(300, 230),
      text: "Escribir \"1-Suma, 2-Resta, 3-Mult, 4-Div\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final inputOpcionNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(300, 320),
      text: "Leer opcion",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'opcion'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(300, 430),
      text: "opcion == 1",
      metadata: {'switchVar': 'opcion', 'caseValue': '1'},
    );

    final processSumaNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(520, 430),
      text: "resultado = a + b",
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_7",
      type: NodeType.decision,
      position: const Offset(300, 550),
      text: "opcion == 2",
      metadata: {'switchVar': 'opcion', 'caseValue': '2'},
    );

    final processRestaNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(520, 550),
      text: "resultado = a - b",
    );

    final decision3Node = DiagramNode(
      id: "decision_${baseId}_9",
      type: NodeType.decision,
      position: const Offset(300, 670),
      text: "opcion == 3",
      metadata: {'switchVar': 'opcion', 'caseValue': '3'},
    );

    final processMultNode = DiagramNode(
      id: "process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(520, 670),
      text: "resultado = a * b",
    );

    final decision4Node = DiagramNode(
      id: "decision_${baseId}_11",
      type: NodeType.decision,
      position: const Offset(300, 790),
      text: "opcion == 4",
      metadata: {'switchVar': 'opcion', 'caseValue': '4'},
    );

    final processDivNode = DiagramNode(
      id: "process_${baseId}_12",
      type: NodeType.process,
      position: const Offset(520, 790),
      text: "resultado = a / b",
    );

    final outputErrorNode = DiagramNode(
      id: "output_${baseId}_13",
      type: NodeType.data,
      position: const Offset(300, 910),
      text: "Escribir \"Opción inválida\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputResultNode = DiagramNode(
      id: "output_${baseId}_14",
      type: NodeType.data,
      position: const Offset(520, 910),
      text: "Escribir resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_15",
      type: NodeType.terminal,
      position: const Offset(400, 1020),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
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
      Connection(source: startNode, target: inputNumsNode, label: ""),
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
          "Clasifica un triángulo según sus lados.\nConcepto: Operadores lógicos (&&, ||)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer a, b, c",
      metadata: {'isOutput': false, 'inputType': 'float'},
    );

    final decision1Node = DiagramNode(
      id: "decision_${baseId}_3",
      type: NodeType.decision,
      position: const Offset(280, 260),
      text: "a == b && b == c",
    );

    final outputEquiNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(500, 260),
      text: "Escribir \"Equilátero\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final decision2Node = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(280, 400),
      text: "a == b || b == c || a == c",
    );

    final outputIsoNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(500, 400),
      text: "Escribir \"Isósceles\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputEscNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 520),
      text: "Escribir \"Escaleno\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(380, 640),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      decision1Node,
      outputEquiNode,
      decision2Node,
      outputIsoNode,
      outputEscNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
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
          "Cuenta del 1 al N usando while.\nConcepto: Bucle pre-condición con símbolo de decisión (rombo)",
    );

    // Nodo inicial
    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    // Leer el límite
    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer limite",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'limite'},
    );

    // Inicializar contador (instrucciones antes del ciclo)
    final initNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 230),
      text: "contador = 1",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'contador',
        'value': '1'
      },
    );

    // Nodo de decisión del while (rombo) - símbolo correcto según ISO 5807
    final whileDecisionNode = DiagramNode(
      id: "decision_${baseId}_4",
      type: NodeType.decision,
      position: const Offset(280, 340),
      text: "contador <= limite",
    );

    // Cuerpo del ciclo: Escribir contador
    final outputContadorNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 340),
      text: "Escribir contador",
      metadata: {'isOutput': true},
    );

    // Cuerpo del ciclo: Incrementar contador
    final incrementNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(500, 450),
      text: "contador = contador + 1",
      metadata: {'processType': 'increment'},
    );

    // Después del ciclo: mensaje de fin
    final outputFinNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 550),
      text: "Escribir \"Fin del conteo\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    // Nodo final
    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(280, 650),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
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
      Connection(source: startNode, target: inputNode, label: ""),
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
  static Future<SavedDiagram> createValidacionDoWhileTemplate() async {
    final now = DateTime.now();
    final baseId = now.millisecondsSinceEpoch;

    final commentNode = DiagramNode(
      id: "comment_${baseId}_0",
      type: NodeType.comment,
      position: const Offset(500, 50),
      text:
          "Valida entrada de número positivo.\nConcepto: Bucle do-while (post-condición)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final loopStartNode = DiagramNode(
      id: "loop_${baseId}_2",
      type: NodeType.preparation,
      position: const Offset(280, 150),
      text: "do",
      metadata: {'loopType': 'do-while-start'},
    );

    final outputPromptNode = DiagramNode(
      id: "output_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 250),
      text: "Escribir \"Ingrese un número positivo:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(280, 350),
      text: "Leer numero",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'numero'},
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_5",
      type: NodeType.decision,
      position: const Offset(280, 470),
      text: "numero <= 0",
      metadata: {'loopType': 'do-while-condition'},
    );

    final outputErrorNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(500, 470),
      text: "Escribir \"Error: debe ser positivo\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final outputSuccessNode = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 600),
      text: "Escribir \"Número válido:\", numero",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(280, 700),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      loopStartNode,
      outputPromptNode,
      inputNode,
      decisionNode,
      outputErrorNode,
      outputSuccessNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: loopStartNode, label: ""),
      Connection(source: loopStartNode, target: outputPromptNode, label: ""),
      Connection(source: outputPromptNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: decisionNode, label: ""),
      Connection(source: decisionNode, target: outputErrorNode, label: "Sí"),
      Connection(
          source: outputErrorNode,
          target: loopStartNode,
          label: "",
          isLoopBack: true),
      Connection(source: decisionNode, target: outputSuccessNode, label: "No"),
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
          "Genera la tabla de multiplicar del 1 al 10.\nConcepto: Bucle for controlado",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer numero",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'numero'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_3",
      type: NodeType.preparation,
      position: const Offset(280, 250),
      text: "for (i = 1; i <= 10; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 1',
        'forCondition': 'i <= 10',
        'forIncrement': 'i++',
      },
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(500, 250),
      text: "resultado = numero * i",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(500, 360),
      text: "Escribir numero, \"x\", i, \"=\", resultado",
      metadata: {'isOutput': true},
    );

    final outputFinNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(280, 470),
      text: "Escribir \"Tabla completada\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(280, 570),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      forNode,
      processNode,
      outputNode,
      outputFinNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
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
          "Calcula el factorial de N usando un acumulador.\nConcepto: Acumulador en bucle for",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer n",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'n'},
    );

    final initNode = DiagramNode(
      id: "process_${baseId}_3",
      type: NodeType.process,
      position: const Offset(280, 230),
      text: "factorial = 1",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'factorial',
        'value': '1'
      },
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_4",
      type: NodeType.preparation,
      position: const Offset(280, 340),
      text: "for (i = 1; i <= n; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 1',
        'forCondition': 'i <= n',
        'forIncrement': 'i++',
      },
    );

    final processNode = DiagramNode(
      id: "process_${baseId}_5",
      type: NodeType.process,
      position: const Offset(500, 340),
      text: "factorial = factorial * i",
      metadata: {'processType': 'arithmetic', 'operator': '*'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(280, 470),
      text: "Escribir \"Factorial:\", factorial",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(280, 570),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      initNode,
      forNode,
      processNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: inputNode, label: ""),
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
          "Suma todos los elementos de un arreglo.\nConcepto: Declaración y recorrido de arreglos",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareNode = DiagramNode(
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

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_3",
      type: NodeType.preparation,
      position: const Offset(280, 240),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(500, 240),
      text: "Leer arr[i]",
      metadata: {'isOutput': false, 'inputType': 'int'},
    );

    final initSumaNode = DiagramNode(
      id: "process_${baseId}_5",
      type: NodeType.process,
      position: const Offset(280, 360),
      text: "suma = 0",
      metadata: {
        'processType': 'initialization',
        'varType': 'int',
        'varName': 'suma',
        'value': '0'
      },
    );

    final forSumaNode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(280, 460),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final processSumaNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(500, 460),
      text: "suma = suma + arr[i]",
      metadata: {'processType': 'arithmetic', 'operator': '+'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_8",
      type: NodeType.data,
      position: const Offset(280, 580),
      text: "Escribir \"Suma total:\", suma",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_9",
      type: NodeType.terminal,
      position: const Offset(280, 680),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareNode,
      forInputNode,
      inputNode,
      initSumaNode,
      forSumaNode,
      processSumaNode,
      outputNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareNode, label: ""),
      Connection(source: declareNode, target: forInputNode, label: ""),
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
      position: const Offset(550, 50),
      text:
          "Busca un elemento en un arreglo (búsqueda lineal).\nConcepto: Recorrido con bandera de búsqueda",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int arr[5] = {10, 25, 8, 42, 17}",
      metadata: {'processType': 'array_init'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 210),
      text: "Leer valorBuscado",
      metadata: {
        'isOutput': false,
        'inputType': 'int',
        'varName': 'valorBuscado'
      },
    );

    final initVarsNode = DiagramNode(
      id: "process_${baseId}_4",
      type: NodeType.process,
      position: const Offset(280, 290),
      text: "encontrado = 0, posicion = -1",
      metadata: {'processType': 'initialization'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_5",
      type: NodeType.preparation,
      position: const Offset(280, 390),
      text: "for (i = 0; i < 5; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 5',
        'forIncrement': 'i++'
      },
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_6",
      type: NodeType.decision,
      position: const Offset(500, 390),
      text: "arr[i] == valorBuscado",
    );

    final foundNode = DiagramNode(
      id: "process_${baseId}_7",
      type: NodeType.process,
      position: const Offset(700, 390),
      text: "encontrado = 1\nposicion = i",
      metadata: {'processType': 'assignment'},
    );

    final checkFoundNode = DiagramNode(
      id: "decision_${baseId}_8",
      type: NodeType.decision,
      position: const Offset(280, 530),
      text: "encontrado == 1",
    );

    final outputFoundNode = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(500, 530),
      text: "Escribir \"Encontrado en posición:\", posicion",
      metadata: {'isOutput': true},
    );

    final outputNotFoundNode = DiagramNode(
      id: "output_${baseId}_10",
      type: NodeType.data,
      position: const Offset(280, 650),
      text: "Escribir \"No encontrado\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_11",
      type: NodeType.terminal,
      position: const Offset(380, 750),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareNode,
      inputNode,
      initVarsNode,
      forNode,
      decisionNode,
      foundNode,
      checkFoundNode,
      outputFoundNode,
      outputNotFoundNode,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareNode, label: ""),
      Connection(source: declareNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: initVarsNode, label: ""),
      Connection(source: initVarsNode, target: forNode, label: ""),
      Connection(source: forNode, target: decisionNode, label: "Verdadero"),
      Connection(source: decisionNode, target: foundNode, label: "Sí"),
      Connection(
          source: decisionNode, target: forNode, label: "No", isLoopBack: true),
      Connection(
          source: foundNode, target: forNode, label: "", isLoopBack: true),
      Connection(source: forNode, target: checkFoundNode, label: "Falso"),
      Connection(source: checkFoundNode, target: outputFoundNode, label: "Sí"),
      Connection(
          source: checkFoundNode, target: outputNotFoundNode, label: "No"),
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
          "Ordena un arreglo usando Bubble Sort.\nCompara elementos adyacentes e intercambia si están desordenados.\nComplejidad: O(n²)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareNode = DiagramNode(
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

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_3",
      type: NodeType.preparation,
      position: const Offset(280, 210),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(500, 210),
      text: "Leer arr[i]",
      metadata: {'isOutput': false},
    );

    final forINode = DiagramNode(
      id: "loop_${baseId}_5",
      type: NodeType.preparation,
      position: const Offset(280, 320),
      text: "for (i = 0; i < 4; i++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int i = 0',
        'forCondition': 'i < 4',
        'forIncrement': 'i++'
      },
    );

    final forJNode = DiagramNode(
      id: "loop_${baseId}_6",
      type: NodeType.preparation,
      position: const Offset(500, 320),
      text: "for (j = 0; j < 4-i; j++)",
      metadata: {
        'loopType': 'for',
        'forInit': 'int j = 0',
        'forCondition': 'j < 4-i',
        'forIncrement': 'j++'
      },
    );

    final decisionNode = DiagramNode(
      id: "decision_${baseId}_7",
      type: NodeType.decision,
      position: const Offset(700, 320),
      text: "arr[j] > arr[j+1]",
    );

    final swapNode = DiagramNode(
      id: "process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(700, 460),
      text: "temp = arr[j]\narr[j] = arr[j+1]\narr[j+1] = temp",
      metadata: {'processType': 'swap'},
    );

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_9",
      type: NodeType.data,
      position: const Offset(280, 560),
      text: "Escribir \"Arreglo ordenado:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forOutputNode = DiagramNode(
      id: "loop_${baseId}_10",
      type: NodeType.preparation,
      position: const Offset(280, 660),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_11",
      type: NodeType.data,
      position: const Offset(500, 660),
      text: "Escribir arr[i]",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_12",
      type: NodeType.terminal,
      position: const Offset(280, 780),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareNode,
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
      Connection(source: startNode, target: declareNode, label: ""),
      Connection(source: declareNode, target: forInputNode, label: ""),
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
          "Ordena un arreglo usando Selection Sort.\nBusca el mínimo en cada iteración y lo coloca al inicio.\nComplejidad: O(n²)",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final declareNode = DiagramNode(
      id: "process_${baseId}_2",
      type: NodeType.process,
      position: const Offset(280, 130),
      text: "int arr[5]",
      metadata: {'processType': 'array_declaration'},
    );

    final forInputNode = DiagramNode(
      id: "loop_${baseId}_3",
      type: NodeType.preparation,
      position: const Offset(280, 210),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_4",
      type: NodeType.data,
      position: const Offset(500, 210),
      text: "Leer arr[i]",
      metadata: {'isOutput': false},
    );

    final forINode = DiagramNode(
      id: "loop_${baseId}_5",
      type: NodeType.preparation,
      position: const Offset(280, 320),
      text: "for (i = 0; i < 4; i++)",
      metadata: {'loopType': 'for'},
    );

    final initMinNode = DiagramNode(
      id: "process_${baseId}_6",
      type: NodeType.process,
      position: const Offset(500, 320),
      text: "minIdx = i",
      metadata: {'processType': 'assignment'},
    );

    final forJNode = DiagramNode(
      id: "loop_${baseId}_7",
      type: NodeType.preparation,
      position: const Offset(500, 420),
      text: "for (j = i+1; j < 5; j++)",
      metadata: {'loopType': 'for'},
    );

    final decisionMinNode = DiagramNode(
      id: "decision_${baseId}_8",
      type: NodeType.decision,
      position: const Offset(700, 420),
      text: "arr[j] < arr[minIdx]",
    );

    final updateMinNode = DiagramNode(
      id: "process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(700, 540),
      text: "minIdx = j",
      metadata: {'processType': 'assignment'},
    );

    final decisionSwapNode = DiagramNode(
      id: "decision_${baseId}_10",
      type: NodeType.decision,
      position: const Offset(500, 640),
      text: "minIdx != i",
    );

    final swapNode = DiagramNode(
      id: "process_${baseId}_11",
      type: NodeType.process,
      position: const Offset(700, 640),
      text: "temp = arr[i]\narr[i] = arr[minIdx]\narr[minIdx] = temp",
      metadata: {'processType': 'swap'},
    );

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_12",
      type: NodeType.data,
      position: const Offset(280, 760),
      text: "Escribir \"Arreglo ordenado:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forOutputNode = DiagramNode(
      id: "loop_${baseId}_13",
      type: NodeType.preparation,
      position: const Offset(280, 850),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_14",
      type: NodeType.data,
      position: const Offset(500, 850),
      text: "Escribir arr[i]",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_15",
      type: NodeType.terminal,
      position: const Offset(280, 970),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareNode,
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
      Connection(source: startNode, target: declareNode, label: ""),
      Connection(source: declareNode, target: forInputNode, label: ""),
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
          "Demuestra el uso de funciones con parámetros y retorno.\nConcepto: Subproceso predefinido, paso por valor",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final inputANode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer a",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'a'},
    );

    final inputBNode = DiagramNode(
      id: "input_${baseId}_3",
      type: NodeType.data,
      position: const Offset(280, 230),
      text: "Leer b",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'b'},
    );

    final callFunctionNode = DiagramNode(
      id: "subprocess_${baseId}_4",
      type: NodeType.predefinedProcess,
      position: const Offset(280, 330),
      text: "resultado = Suma(a, b)",
      metadata: {
        'functionName': 'Suma',
        'parameters': 'a, b',
        'returnVar': 'resultado'
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_5",
      type: NodeType.data,
      position: const Offset(280, 430),
      text: "Escribir \"La suma es:\", resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(280, 530),
      text: "Fin",
    );

    // Subproceso Suma
    final subStartNode = DiagramNode(
      id: "sub_start_${baseId}_7",
      type: NodeType.terminal,
      position: const Offset(600, 140),
      text: "Inicio Suma(x, y)",
    );

    final subProcessNode = DiagramNode(
      id: "sub_process_${baseId}_8",
      type: NodeType.process,
      position: const Offset(600, 240),
      text: "retorno = x + y",
      metadata: {'processType': 'arithmetic'},
    );

    final subReturnNode = DiagramNode(
      id: "sub_return_${baseId}_9",
      type: NodeType.data,
      position: const Offset(600, 340),
      text: "return retorno",
      metadata: {'isOutput': true, 'isReturn': true},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_10",
      type: NodeType.terminal,
      position: const Offset(600, 440),
      text: "Fin Suma",
    );

    final nodes = [
      commentNode,
      startNode,
      inputANode,
      inputBNode,
      callFunctionNode,
      outputNode,
      endNode,
      subStartNode,
      subProcessNode,
      subReturnNode,
      subEndNode
    ];

    final connections = [
      // Programa principal
      Connection(source: startNode, target: inputANode, label: ""),
      Connection(source: inputANode, target: inputBNode, label: ""),
      Connection(source: inputBNode, target: callFunctionNode, label: ""),
      Connection(source: callFunctionNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
      // Subproceso
      Connection(source: subStartNode, target: subProcessNode, label: ""),
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
          "Calcula factorial usando una función separada.\nConcepto: Modularización con subprocesos",
    );

    final startNode = DiagramNode(
      id: "start_${baseId}_1",
      type: NodeType.terminal,
      position: const Offset(280, 50),
      text: "Inicio",
    );

    final inputNode = DiagramNode(
      id: "input_${baseId}_2",
      type: NodeType.data,
      position: const Offset(280, 140),
      text: "Leer n",
      metadata: {'isOutput': false, 'inputType': 'int', 'varName': 'n'},
    );

    final callFunctionNode = DiagramNode(
      id: "subprocess_${baseId}_3",
      type: NodeType.predefinedProcess,
      position: const Offset(280, 240),
      text: "resultado = Factorial(n)",
      metadata: {
        'functionName': 'Factorial',
        'parameters': 'n',
        'returnVar': 'resultado'
      },
    );

    final outputNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(280, 340),
      text: "Escribir \"Factorial:\", resultado",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_5",
      type: NodeType.terminal,
      position: const Offset(280, 440),
      text: "Fin",
    );

    // Subproceso Factorial
    final subStartNode = DiagramNode(
      id: "sub_start_${baseId}_6",
      type: NodeType.terminal,
      position: const Offset(600, 50),
      text: "Inicio Factorial(num)",
    );

    final subInitNode = DiagramNode(
      id: "sub_init_${baseId}_7",
      type: NodeType.process,
      position: const Offset(600, 140),
      text: "fact = 1",
      metadata: {'processType': 'initialization'},
    );

    final subForNode = DiagramNode(
      id: "sub_loop_${baseId}_8",
      type: NodeType.preparation,
      position: const Offset(600, 240),
      text: "for (i = 1; i <= num; i++)",
      metadata: {'loopType': 'for'},
    );

    final subProcessNode = DiagramNode(
      id: "sub_process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(800, 240),
      text: "fact = fact * i",
      metadata: {'processType': 'arithmetic'},
    );

    final subReturnNode = DiagramNode(
      id: "sub_return_${baseId}_10",
      type: NodeType.data,
      position: const Offset(600, 370),
      text: "return fact",
      metadata: {'isOutput': true, 'isReturn': true},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_11",
      type: NodeType.terminal,
      position: const Offset(600, 470),
      text: "Fin Factorial",
    );

    final nodes = [
      commentNode,
      startNode,
      inputNode,
      callFunctionNode,
      outputNode,
      endNode,
      subStartNode,
      subInitNode,
      subForNode,
      subProcessNode,
      subReturnNode,
      subEndNode
    ];

    final connections = [
      // Programa principal
      Connection(source: startNode, target: inputNode, label: ""),
      Connection(source: inputNode, target: callFunctionNode, label: ""),
      Connection(source: callFunctionNode, target: outputNode, label: ""),
      Connection(source: outputNode, target: endNode, label: ""),
      // Subproceso
      Connection(source: subStartNode, target: subInitNode, label: ""),
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
          "Intercambia dos variables usando apuntadores.\nConcepto: Paso por referencia con * y &",
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

    final subTempNode = DiagramNode(
      id: "sub_process_${baseId}_9",
      type: NodeType.process,
      position: const Offset(600, 240),
      text: "temp = *x",
      metadata: {'processType': 'pointer_deref'},
    );

    final subAssign1Node = DiagramNode(
      id: "sub_process_${baseId}_10",
      type: NodeType.process,
      position: const Offset(600, 340),
      text: "*x = *y",
      metadata: {'processType': 'pointer_deref'},
    );

    final subAssign2Node = DiagramNode(
      id: "sub_process_${baseId}_11",
      type: NodeType.process,
      position: const Offset(600, 440),
      text: "*y = temp",
      metadata: {'processType': 'pointer_deref'},
    );

    final subEndNode = DiagramNode(
      id: "sub_end_${baseId}_12",
      type: NodeType.terminal,
      position: const Offset(600, 540),
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
      Connection(source: subStartNode, target: subTempNode, label: ""),
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
          "Recorre un arreglo usando aritmética de apuntadores.\nConcepto: *(ptr+i) equivale a arr[i]",
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

    final outputLabelNode = DiagramNode(
      id: "output_${baseId}_4",
      type: NodeType.data,
      position: const Offset(280, 320),
      text: "Escribir \"Recorrido con aritmética de punteros:\"",
      metadata: {'isOutput': true, 'outputType': 'string'},
    );

    final forNode = DiagramNode(
      id: "loop_${baseId}_5",
      type: NodeType.preparation,
      position: const Offset(280, 420),
      text: "for (i = 0; i < 5; i++)",
      metadata: {'loopType': 'for'},
    );

    final outputElementNode = DiagramNode(
      id: "output_${baseId}_6",
      type: NodeType.data,
      position: const Offset(500, 420),
      text: "Escribir *(ptr + i)",
      metadata: {'isOutput': true, 'pointerArithmetic': true},
    );

    final outputLabel2Node = DiagramNode(
      id: "output_${baseId}_7",
      type: NodeType.data,
      position: const Offset(280, 540),
      text: "Escribir \"Dirección del arreglo:\", ptr",
      metadata: {'isOutput': true},
    );

    final endNode = DiagramNode(
      id: "end_${baseId}_8",
      type: NodeType.terminal,
      position: const Offset(280, 640),
      text: "Fin",
    );

    final nodes = [
      commentNode,
      startNode,
      declareArrNode,
      declarePtrNode,
      outputLabelNode,
      forNode,
      outputElementNode,
      outputLabel2Node,
      endNode
    ];

    final connections = [
      Connection(source: startNode, target: declareArrNode, label: ""),
      Connection(source: declareArrNode, target: declarePtrNode, label: ""),
      Connection(source: declarePtrNode, target: outputLabelNode, label: ""),
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
