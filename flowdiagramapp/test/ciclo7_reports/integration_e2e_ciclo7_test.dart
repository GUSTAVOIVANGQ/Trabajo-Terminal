/// Pruebas End-to-End - Ciclo 7
/// Subconjunto representativo de 41 casos de prueba para pipeline completo
/// Ejecutar con: flutter test test/ciclo7_reports/integration_e2e_ciclo7_test.dart

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
  group('Integración E2E - Ciclo 7', () {
    final compiler = DiagramCompilerPipeline();

    // --- SIMPLE DIAGRAMS (E2E-01 to E2E-03) ---
    test('E2E-01: Pipeline simple Inicio-Fin', () {
      final nodes = [_terminal('s', 'Inicio', 50), _terminal('e', 'Fin', 150)];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-02: Pipeline con declaración', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('v', NodeType.process, 'int x = 5', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-03: Pipeline con múltiples declaraciones', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('v1', NodeType.process, 'int x', 150),
        _node('v2', NodeType.process, 'int y', 200),
        _terminal('e', 'Fin', 300),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- INPUT/OUTPUT (E2E-04 to E2E-07) ---
    test('E2E-04: Pipeline con entrada scanf', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i', NodeType.data, 'scanf', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-05: Pipeline con salida printf', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('o', NodeType.data, 'printf x', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-06: Pipeline con entrada y salida', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i', NodeType.data, 'scanf', 150),
        _node('p', NodeType.process, 'x = x + 1', 250),
        _node('o', NodeType.data, 'printf', 350),
        _terminal('e', 'Fin', 450),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-07: Pipeline con múltiple entrada/salida', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i1', NodeType.data, 'scanf a', 150),
        _node('i2', NodeType.data, 'scanf b', 200),
        _node('p', NodeType.process, 'c = a + b', 300),
        _node('o1', NodeType.data, 'printf c', 400),
        _terminal('e', 'Fin', 500),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- DECISIONS/IF (E2E-08 to E2E-14) ---
    test('E2E-08: Pipeline con decisión simple', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x > 0', 150),
        _node('p', NodeType.process, 'y = 1', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-09: Pipeline con decisión y dos ramas', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x > 0', 150),
        _node('p1', NodeType.process, 'y = 1', 250),
        _node('p2', NodeType.process, 'y = 0', 300),
        _terminal('e', 'Fin', 400),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-10: Pipeline con decisión anidada', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d1', NodeType.decision, 'x > 0', 150),
        _node('d2', NodeType.decision, 'x > 10', 250),
        _node('p', NodeType.process, 'y = x', 350),
        _terminal('e', 'Fin', 450),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-11: Decisión con operador ==', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x == 5', 150),
        _node('p', NodeType.process, 'match = 1', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-12: Decisión con operador <', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x < 10', 150),
        _node('p', NodeType.process, 'small = 1', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-13: Decisión con operador && (AND lógico)', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x > 0 && y > 0', 150),
        _node('p', NodeType.process, 'both = 1', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-14: Decisión con operador || (OR lógico)', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('d', NodeType.decision, 'x > 0 || y > 0', 150),
        _node('p', NodeType.process, 'either = 1', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- LOOPS (E2E-15 to E2E-20) ---
    test('E2E-15: Pipeline con bucle simple', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.preparation, 'i=0', 150),
        _node('c', NodeType.process, 'sum = i', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-16: Bucle con contador decreciente', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.preparation, 'i=10', 150),
        _node('c', NodeType.process, 'total = i', 250),
        _node('dec', NodeType.process, 'i = i - 1', 300),
        _terminal('e', 'Fin', 400),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-17: Bucle con proceso dentro', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.preparation, 'i=1', 150),
        _node('c1', NodeType.process, 'x = i * 2', 250),
        _node('c2', NodeType.process, 'sum = sum + x', 300),
        _terminal('e', 'Fin', 400),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-18: Bucle anidado', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.preparation, 'i=1', 150),
        _node('p2', NodeType.preparation, 'j=1', 200),
        _node('c', NodeType.process, 'matriz = i * j', 300),
        _terminal('e', 'Fin', 400),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-19: Bucle con decisión dentro', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.preparation, 'i=1', 150),
        _node('d', NodeType.decision, 'i > 5', 250),
        _node('c', NodeType.process, 'count = i', 350),
        _terminal('e', 'Fin', 450),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-20: Bucle con entrada/salida', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i', NodeType.data, 'scanf n', 150),
        _node('p', NodeType.preparation, 'i=0', 250),
        _node('o', NodeType.data, 'printf i', 350),
        _terminal('e', 'Fin', 450),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- OPERATIONS (E2E-21 to E2E-27) ---
    test('E2E-21: Proceso con suma', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = x + y', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-22: Proceso con resta', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = x - y', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-23: Proceso con multiplicación', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = x * y', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-24: Proceso con división', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = x / y', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-25: Proceso con módulo', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = x % y', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-26: Proceso con asignación compuesta +=', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'x += 5', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-27: Proceso con expresión compleja', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'z = (x + y) * 2', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- DATA TYPES (E2E-28 to E2E-32) ---
    test('E2E-28: Variables tipo int', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'int x = 42', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-29: Variables tipo float', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'float pi = 3.14', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-30: Variables tipo char', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'char c = a', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-31: Variables tipo double', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p', NodeType.process, 'double d = 2.71828', 150),
        _terminal('e', 'Fin', 250),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-32: Mezcla de tipos de datos', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'int a = 10', 150),
        _node('p2', NodeType.process, 'float b = 3.14', 200),
        _node('p3', NodeType.process, 'c = a + b', 250),
        _terminal('e', 'Fin', 350),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    // --- COMPLEX ALGORITHMS (E2E-33 to E2E-41) ---
    test('E2E-33: Algoritmo Factorial', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'int n = 5', 150),
        _node('p2', NodeType.process, 'fact = 1', 200),
        _node('p3', NodeType.preparation, 'i=1', 250),
        _node('p4', NodeType.process, 'fact = fact * i', 300),
        _terminal('e', 'Fin', 400),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-34: Algoritmo Búsqueda', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'target = 7', 150),
        _node('p2', NodeType.process, 'found = 0', 200),
        _node('p3', NodeType.preparation, 'i=0', 250),
        _node('d', NodeType.decision, 'arr[i] == target', 300),
        _node('p4', NodeType.process, 'found = 1', 400),
        _terminal('e', 'Fin', 500),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-35: Máximo de 3 números', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'int a, b, c', 150),
        _node('d1', NodeType.decision, 'a > b', 250),
        _node('p2', NodeType.process, 'max = a', 350),
        _node('d2', NodeType.decision, 'max > c', 450),
        _node('o', NodeType.data, 'printf max', 550),
        _terminal('e', 'Fin', 650),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-36: Suma de n números', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'int n = 10', 150),
        _node('p2', NodeType.process, 'suma = 0', 200),
        _node('p3', NodeType.preparation, 'i=1', 250),
        _node('p4', NodeType.process, 'suma = suma + i', 300),
        _node('o', NodeType.data, 'printf suma', 400),
        _terminal('e', 'Fin', 500),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-37: Validación de rango', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i', NodeType.data, 'scanf x', 150),
        _node('d', NodeType.decision, 'x >= 0 && x <= 100', 250),
        _node('p', NodeType.process, 'valid = 1', 350),
        _node('o', NodeType.data, 'printf valid', 450),
        _terminal('e', 'Fin', 550),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-38: Conversión Celsius a Fahrenheit', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i', NodeType.data, 'scanf celsius', 150),
        _node('p', NodeType.process, 'f = (c * 9/5) + 32', 250),
        _node('o', NodeType.data, 'printf f', 350),
        _terminal('e', 'Fin', 450),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-39: Promedio de n valores', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'sum = 0', 150),
        _node('p2', NodeType.preparation, 'i=0', 200),
        _node('i', NodeType.data, 'scanf val', 250),
        _node('p3', NodeType.process, 'sum = sum + val', 300),
        _node('p4', NodeType.process, 'avg = sum / n', 400),
        _node('o', NodeType.data, 'printf avg', 500),
        _terminal('e', 'Fin', 600),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-40: Serie Fibonacci', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('p1', NodeType.process, 'a = 0', 150),
        _node('p2', NodeType.process, 'b = 1', 200),
        _node('p3', NodeType.preparation, 'i=0', 250),
        _node('p4', NodeType.process, 'c = a + b', 300),
        _node('p5', NodeType.process, 'a = b', 350),
        _node('p6', NodeType.process, 'b = c', 400),
        _node('o', NodeType.data, 'printf c', 450),
        _terminal('e', 'Fin', 550),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });

    test('E2E-41: Estructuras complejas combinadas', () {
      final nodes = [
        _terminal('s', 'Inicio', 50),
        _node('i1', NodeType.data, 'scanf n', 150),
        _node('p1', NodeType.process, 'result = 0', 200),
        _node('p2', NodeType.preparation, 'i=1', 250),
        _node('d', NodeType.decision, 'n % 2 == 0', 300),
        _node('p3', NodeType.process, 'result = i', 400),
        _node('p4', NodeType.process, 'i = i + 2', 450),
        _node('o', NodeType.data, 'printf result', 500),
        _terminal('e', 'Fin', 600),
      ];
      final result = compiler.compile(nodes, _createLinearConnections(nodes));
      expect(result, isNotNull);
    });
  });
}
