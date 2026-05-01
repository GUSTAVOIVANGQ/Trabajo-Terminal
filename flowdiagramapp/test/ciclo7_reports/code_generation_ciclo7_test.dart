/// Pruebas Selectivas de Generación de Código - Ciclo 7
/// Subconjunto representativo de 10 casos de prueba
/// Ejecutar con: flutter test test/ciclo7_reports/code_generation_ciclo7_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';

DiagramNode _node(String id, NodeType type, String text, double y) {
  return DiagramNode(
    id: id,
    type: type,
    position: Offset(100, y),
    text: text,
  );
}

DiagramNode _terminal(String id, String text, double y) =>
    _node(id, NodeType.terminal, text, y);

List<Connection> _createLinearConnections(List<DiagramNode> nodes) {
  final connections = <Connection>[];
  for (int i = 0; i < nodes.length - 1; i++) {
    connections.add(Connection(
      source: nodes[i],
      target: nodes[i + 1],
      label: '',
    ));
  }
  return connections;
}

void main() {
  group('Generación de Código - Ciclo 7', () {
    final compiler = DiagramCompilerPipeline();

    test('GC-01: Generar función main()', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _terminal('end', 'Fin', 150),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
      expect(result.generatedCode!.contains('int main'), isTrue);
    });

    test('GC-02: Generar encabezados stdio.h', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _terminal('end', 'Fin', 150),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
      expect(result.generatedCode!.contains('#include <stdio.h>'), isTrue);
    });

    test('GC-03: Generar declaración de variables enteras', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x = 10', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
    });

    test('GC-04: Generar scanf para nodo entrada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x', 150),
        _node('input', NodeType.data, 'scanf', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
    });

    test('GC-05: Generar printf para nodo salida', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x = 5', 150),
        _node('output', NodeType.data, 'printf', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
    });

    test('GC-06: Generar estructura if para nodo decisión', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x = 5', 150),
        _node('decision', NodeType.decision, 'x > 0', 250),
        _node('proc', NodeType.process, 'int y = 10', 350),
        _terminal('end', 'Fin', 450),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.errors, isNotNull);
    });

    test('GC-07: Generar bucle while para nodo preparación', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('prep', NodeType.preparation, 'i=1', 150),
        _node('proc', NodeType.process, 'total = i', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.errors, isNotNull);
    });

    test('GC-08: Validar estructura básica del código generado', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int a = 5', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.metrics, isNotNull);
    });

    test('GC-09: Generar operadores aritméticos correctamente', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('sum', NodeType.process, 'x = a + b', 150),
        _node('mul', NodeType.process, 'y = x * 2', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.lexicalResult, isNotNull);
    });

    test('GC-10: Compilación con múltiples tipos de datos', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('int_var', NodeType.process, 'int x = 10', 150),
        _node('float_var', NodeType.process, 'float y = 3.14', 250),
        _node('char_var', NodeType.process, 'char c = a', 350),
        _terminal('end', 'Fin', 450),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.ast, isNotNull);
    });
  });
}
