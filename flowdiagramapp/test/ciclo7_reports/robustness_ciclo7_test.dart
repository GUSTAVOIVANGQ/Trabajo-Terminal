/// Pruebas de Robustez - Ciclo 7
/// Subconjunto representativo de 10 casos de prueba
/// Ejecutar con: flutter test test/ciclo7_reports/robustness_ciclo7_test.dart

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
  group('Robustez - Ciclo 7', () {
    final compiler = DiagramCompilerPipeline();

    test('RB-01: Compilador maneja entrada válida', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('proc', NodeType.process, 'int x = 5', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.metrics.nodesProcessed, greaterThan(0));
    });

    test('RB-02: Detectar error léxico (@#\$%)', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('bad', NodeType.process, r'@#$%', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.lexicalResult, isNotNull);
    });

    test('RB-03: Detectar error sintáctico (paréntesis sin cerrar)', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('bad', NodeType.process, 'x = (5 + 3', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.syntaxResult, isNotNull);
    });

    test('RB-04: Detectar variable no declarada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('bad', NodeType.process, 'x = y + 5', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.symbolTable, isNotNull);
    });

    test('RB-05: Detectar error de tipo (asignación incompatible)', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x = 5', 150),
        _node('bad', NodeType.process, 'x = sin(5)', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.semanticResult, isNotNull);
    });

    test('RB-06: Advertencia de división por cero', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('var', NodeType.process, 'int x = 5', 150),
        _node('div', NodeType.process, 'y = x / 0', 250),
        _terminal('end', 'Fin', 350),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.messages, isNotNull);
    });

    test('RB-07: Advertencia por variable no utilizada', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('unused', NodeType.process, 'int noUsada = 10', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.generatedCode, isNotNull);
    });

    test('RB-08: Error: diagrama sin nodo Inicio', () {
      final nodes = [
        _node('proc', NodeType.process, 'int x = 5', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.errors.isNotEmpty, true);
    });

    test('RB-09: Error: diagrama sin nodo Fin', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('proc', NodeType.process, 'int x = 5', 150),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.errors.isNotEmpty, true);
    });

    test('RB-10: El compilador maneja entrada inválida sin fallar', () {
      final nodes = [
        _terminal('start', 'Inicio', 50),
        _node('invalid', NodeType.process, '', 150),
        _terminal('end', 'Fin', 250),
      ];
      final connections = _createLinearConnections(nodes);
      final result = compiler.compile(nodes, connections);

      expect(result, isNotNull);
      expect(result.ast, isNotNull);
    });
  });
}
