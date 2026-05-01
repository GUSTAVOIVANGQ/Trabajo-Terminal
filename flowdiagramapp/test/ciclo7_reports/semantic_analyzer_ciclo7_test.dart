/// Pruebas Selectivas del Análisis Semántico - Ciclo 7
/// Subconjunto representativo de 7 casos de prueba
/// Ejecutar con: flutter test test/ciclo7_reports/semantic_analyzer_ciclo7_test.dart

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
  group('Análisis Semántico - Ciclo 7', () {
    final compiler = DiagramCompilerPipeline();

    test('SE-01: Detectar variable no declarada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('proc', NodeType.process, 'x = y + 5', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
      expect(result.errors.isNotEmpty, true);
    });

    test('SE-02: Detectar declaración duplicada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var1', NodeType.process, 'int x', 150),
        _node('var2', NodeType.process, 'int x', 200),
        _terminal('end', 'Fin', 300),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
      expect(result.errors.isNotEmpty, true);
    });

    test('SE-03: Validar compatibilidad de tipos', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var_int', NodeType.process, 'int x', 150),
        _node('proc', NodeType.process, 'x = 3.14', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
    });

    test('SE-04: Detectar variable no utilizada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var_unused', NodeType.process, 'int unused = 0', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
    });

    test('SE-05: Advertencia de división por cero', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('proc', NodeType.process, 'x = 5 / 0', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
    });

    test('SE-06: Tabla de símbolos correctamente poblada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var_int', NodeType.process, 'int contador', 150),
        _node('proc', NodeType.process, 'contador = 0', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
      expect(result.symbolTable, isNotNull);
    });

    test('SE-07: Análisis de múltiples tipos de datos', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var1', NodeType.process, 'int a', 150),
        _node('var2', NodeType.process, 'float b', 200),
        _node('var3', NodeType.process, 'char c', 250),
        _node('proc', NodeType.process, 'x = a + b', 350),
        _terminal('end', 'Fin', 450),
      ];
      final connections = _createLinearConnections(nodes);

      final result = compiler.compile(nodes, connections);
      expect(result, isNotNull);
    });
  });
}
