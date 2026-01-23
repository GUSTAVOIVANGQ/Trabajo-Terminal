/// Test for Phase 5: Code Generation
/// Tests the advanced code generator with multiple variables output

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flutter/material.dart';

void main() {
  group('FASE 5: Generación de Código Avanzado', () {
    test('Plantilla 02 - Múltiples variables en printf', () {
      // Simular la plantilla 02: Declaración y Tipos de Datos
      final now = DateTime.now();
      final baseId = now.millisecondsSinceEpoch;

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
        Connection(
            source: declareFloatNode, target: declareCharNode, label: ""),
        Connection(source: declareCharNode, target: outputNode, label: ""),
        Connection(source: outputNode, target: endNode, label: ""),
      ];

      // Compilar con el pipeline avanzado
      final compiler = DiagramCompilerPipeline(
        options: const CompilerOptions(
          optimizationLevel: 0, // Sin optimización para este test
          generateComments: true,
        ),
      );

      final result = compiler.compile(nodes, connections);

      // Verificar que la compilación fue exitosa
      expect(result.success, isTrue, reason: 'La compilación debe ser exitosa');

      // Verificar que se generó código
      expect(result.generatedCode, isNotNull,
          reason: 'Debe generarse código C');

      final code = result.generatedCode!;
      print('Código generado:');
      print(code);

      // Verificar declaraciones
      expect(code.contains('int x = 10'), isTrue,
          reason: 'Debe declarar int x = 10');
      expect(code.contains('float y = 3.14'), isTrue,
          reason: 'Debe declarar float y = 3.14');
      expect(code.contains("char z = 'A'"), isTrue,
          reason: "Debe declarar char z = 'A'");

      // Verificar que el printf tiene las 3 variables
      // Debe contener un printf con x, y, z
      expect(code.contains('printf('), isTrue, reason: 'Debe tener un printf');

      // Verificar que se imprimen todas las variables
      final printfMatch =
          RegExp(r'printf\([^;]+x[^;]+y[^;]+z[^;]*\);').hasMatch(code);
      expect(printfMatch, isTrue, reason: 'El printf debe incluir x, y, z');

      // Imprimir información de debug
      print('\n--- Tabla de símbolos ---');
      if (result.symbolTable != null) {
        for (final symbol in result.symbolTable!.allSymbols) {
          print(
              '${symbol.name}: ${symbol.dataType.cRepresentation} (${symbol.dataType.formatSpecifier})');
        }
      }
    });

    test('Generador avanzado usa tabla de símbolos para tipos', () {
      // Crear nodos con tipos conocidos
      final startNode = DiagramNode(
        id: "start_1",
        type: NodeType.terminal,
        position: const Offset(250, 50),
        text: "Inicio",
      );

      final declareNode = DiagramNode(
        id: "process_1",
        type: NodeType.process,
        position: const Offset(250, 150),
        text: "float temperatura = 25.5",
      );

      final outputNode = DiagramNode(
        id: "output_1",
        type: NodeType.data,
        position: const Offset(250, 250),
        text: "Escribir temperatura",
        metadata: {'isOutput': true},
      );

      final endNode = DiagramNode(
        id: "end_1",
        type: NodeType.terminal,
        position: const Offset(250, 350),
        text: "Fin",
      );

      final nodes = [startNode, declareNode, outputNode, endNode];
      final connections = [
        Connection(source: startNode, target: declareNode, label: ""),
        Connection(source: declareNode, target: outputNode, label: ""),
        Connection(source: outputNode, target: endNode, label: ""),
      ];

      final compiler = DiagramCompilerPipeline();
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);

      final code = result.generatedCode!;
      print('Código generado (temperatura float):');
      print(code);

      // Verificar que usa %f para float (no %d)
      expect(code.contains('%f'), isTrue,
          reason: 'Debe usar %f para variables float');
    });

    test('Pipeline completo genera código funcional', () {
      // Test simple de flujo completo
      final startNode = DiagramNode(
        id: "start",
        type: NodeType.terminal,
        position: const Offset(100, 50),
        text: "Inicio",
      );

      final processNode = DiagramNode(
        id: "process",
        type: NodeType.process,
        position: const Offset(100, 150),
        text: "int resultado = 5 + 3",
      );

      final outputNode = DiagramNode(
        id: "output",
        type: NodeType.data,
        position: const Offset(100, 250),
        text: "Escribir resultado",
        metadata: {'isOutput': true},
      );

      final endNode = DiagramNode(
        id: "end",
        type: NodeType.terminal,
        position: const Offset(100, 350),
        text: "Fin",
      );

      final nodes = [startNode, processNode, outputNode, endNode];
      final connections = [
        Connection(source: startNode, target: processNode, label: ""),
        Connection(source: processNode, target: outputNode, label: ""),
        Connection(source: outputNode, target: endNode, label: ""),
      ];

      final result = nodes.compile(connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);

      print('Código del pipeline completo:');
      print(result.generatedCode);

      // Verificar estructura básica del código C
      expect(result.generatedCode!.contains('#include <stdio.h>'), isTrue);
      expect(result.generatedCode!.contains('int main()'), isTrue);
      expect(result.generatedCode!.contains('return 0;'), isTrue);
    });
  });
}
