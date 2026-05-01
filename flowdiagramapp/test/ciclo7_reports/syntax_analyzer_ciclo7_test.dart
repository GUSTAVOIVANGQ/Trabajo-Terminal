/// Pruebas Selectivas del Análisis Sintáctico - Ciclo 7
/// Subconjunto representativo de 8 casos de prueba
/// Ejecutar con: flutter test test/ciclo7_reports/syntax_analyzer_ciclo7_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/ast_nodes.dart';
import 'package:flowdiagramapp/compiler/symbol_table.dart';

void main() {
  group('Análisis Sintáctico - Ciclo 7', () {
    // Caso 1: Nodo literal entero
    test('SN-01: Crear nodo de literal entero', () {
      final node = IntegerLiteralNode(
        value: 42,
        position: const SourcePosition(line: 1, column: 1),
      );
      expect(node.value, 42);
      expect(node.toTreeString(), contains('IntegerLiteral'));
    });

    // Caso 2: Nodo literal flotante
    test('SN-02: Crear nodo de literal flotante', () {
      final node = FloatLiteralNode(
        value: 3.14,
        position: const SourcePosition(line: 1, column: 1),
      );
      expect(node.value, 3.14);
      expect(node.toTreeString(), contains('FloatLiteral'));
    });

    // Caso 3: Nodo identificador
    test('SN-03: Crear nodo identificador', () {
      final node = IdentifierNode(
        name: 'myVar',
        position: const SourcePosition(line: 1, column: 1),
      );
      expect(node.name, 'myVar');
      expect(node.toTreeString(), contains('Identifier'));
    });

    // Caso 4: Expresión binaria simple (suma)
    test('SN-04: Crear expresión binaria (suma)', () {
      final left = IntegerLiteralNode(
        value: 5,
        position: const SourcePosition(line: 1, column: 1),
      );
      final right = IntegerLiteralNode(
        value: 3,
        position: const SourcePosition(line: 1, column: 5),
      );
      final binary = BinaryExpressionNode(
        operator: BinaryOperator.add,
        left: left,
        right: right,
        position: const SourcePosition(line: 1, column: 3),
      );
      expect(binary.operator, BinaryOperator.add);
      expect(binary.left, left);
      expect(binary.right, right);
    });

    // Caso 5: Expresión binaria de multiplicación
    test('SN-05: Crear expresión binaria (multiplicación)', () {
      final left = IntegerLiteralNode(
        value: 4,
        position: const SourcePosition(line: 1, column: 1),
      );
      final right = IntegerLiteralNode(
        value: 2,
        position: const SourcePosition(line: 1, column: 5),
      );
      final binary = BinaryExpressionNode(
        operator: BinaryOperator.multiply,
        left: left,
        right: right,
        position: const SourcePosition(line: 1, column: 3),
      );
      expect(binary.operator, BinaryOperator.multiply);
    });

    // Caso 6: Asignación de variable
    test('SN-06: Crear nodo de asignación', () {
      final identifier = IdentifierNode(
        name: 'x',
        position: const SourcePosition(line: 1, column: 1),
      );
      final value = IntegerLiteralNode(
        value: 10,
        position: const SourcePosition(line: 1, column: 5),
      );
      final assignment = AssignmentExpressionNode(
        target: identifier,
        operator: AssignmentOperator.assign,
        value: value,
        position: const SourcePosition(line: 1, column: 1),
      );
      expect((assignment.target as IdentifierNode).name, 'x');
    });

    // Caso 7: Declaración de variable con tipo
    test('SN-07: Crear nodo de declaración de variable', () {
      final decl = DeclarationStatementNode(
        dataType: DataType.integer,
        variableName: 'contador',
        initializer: IntegerLiteralNode(
          value: 0,
          position: const SourcePosition(line: 1, column: 10),
        ),
        position: const SourcePosition(line: 1, column: 1),
      );
      expect(decl.dataType, DataType.integer);
      expect(decl.variableName, 'contador');
    });

    // Caso 8: Validar estructura de árbol sintáctico
    test('SN-08: Validar jerarquía del AST', () {
      final left = IntegerLiteralNode(
        value: 1,
        position: const SourcePosition(line: 1, column: 1),
      );
      final right = IntegerLiteralNode(
        value: 2,
        position: const SourcePosition(line: 1, column: 5),
      );
      final binary = BinaryExpressionNode(
        operator: BinaryOperator.add,
        left: left,
        right: right,
        position: const SourcePosition(line: 1, column: 3),
      );
      expect(binary.children.length, 2);
      expect(binary.children.first, left);
    });
  });
}
