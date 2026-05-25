/// AST Interpreter Unit Tests — Pieza 5
/// FlowCode Trabajo Terminal 2026-A038
///
/// Tests the pure-Dart AST interpreter by building AST nodes directly
/// and running the interpreter, verifying output and behaviour.
///
/// Run with: flutter test test/compiler/ast_interpreter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/ast_interpreter.dart';
import 'package:flowdiagramapp/compiler/ast_nodes.dart';
import 'package:flowdiagramapp/compiler/symbol_table.dart';

// ─── Shared position (dummy) ─────────────────────────────────────────────────

const _p = SourcePosition(line: 1, column: 1);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Build a minimal ProgramNode wrapping a list of statements.
ProgramNode _program(List<StatementNode> statements) {
  return ProgramNode(
    globalDeclarations: [],
    diagramNodes: [
      DiagramASTNode(
        diagramNodeId: 'test',
        nodeType: 'process',
        statements: statements,
        position: _p,
      ),
    ],
    position: _p,
  );
}

/// Build an interpreter with an output collector.
(ASTInterpreter, List<String>) _makeInterpreter({
  List<String> inputs = const [],
}) {
  final output = <String>[];
  int inputIndex = 0;
  final interp = ASTInterpreter(
    maxSteps: 5000,
    maxDuration: const Duration(seconds: 3),
    onOutput: (text) => output.add(text),
    onInput: inputs.isEmpty
        ? null
        : (_, __) async => inputs[inputIndex++],
  );
  return (interp, output);
}

// ─── Node builders ───────────────────────────────────────────────────────────

DeclarationStatementNode _declInt(String name, {int? value}) =>
    DeclarationStatementNode(
      variableName: name,
      dataType: DataType.integer,
      initializer: value != null ? IntegerLiteralNode(value: value, position: _p) : null,
      isArray: false,
      arraySize: null,
      position: _p,
    );

DeclarationStatementNode _declFloat(String name, {double? value}) =>
    DeclarationStatementNode(
      variableName: name,
      dataType: DataType.float,
      initializer: value != null ? FloatLiteralNode(value: value, position: _p) : null,
      isArray: false,
      arraySize: null,
      position: _p,
    );

ExpressionStatementNode _assign(String name, ASTNode expr,
        [AssignmentOperator op = AssignmentOperator.assign]) =>
    ExpressionStatementNode(
      expression: AssignmentExpressionNode(
        target: IdentifierNode(name: name, position: _p),
        operator: op,
        value: expr,
        position: _p,
      ),
      position: _p,
    );

OutputStatementNode _output(List<ASTNode> exprs) =>
    OutputStatementNode(expressions: exprs, position: _p);

InputStatementNode _input(String varName) =>
    InputStatementNode(
        variables: [IdentifierNode(name: varName, position: _p)],
        position: _p);

IdentifierNode _id(String name) => IdentifierNode(name: name, position: _p);
IntegerLiteralNode _int(int v) => IntegerLiteralNode(value: v, position: _p);
FloatLiteralNode _float(double v) => FloatLiteralNode(value: v, position: _p);
StringLiteralNode _str(String v) => StringLiteralNode(value: v, position: _p);
BooleanLiteralNode _bool(bool v) => BooleanLiteralNode(value: v, position: _p);

BinaryExpressionNode _bin(ASTNode l, BinaryOperator op, ASTNode r) =>
    BinaryExpressionNode(left: l, operator: op, right: r, position: _p);

BlockStatementNode _block(List<StatementNode> stmts) =>
    BlockStatementNode(statements: stmts, position: _p);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ══════════════════════════════════════════════════════════════════
  // GROUP 1 — Literals & declarations
  // ══════════════════════════════════════════════════════════════════

  group('INT-01: Literals and variable declarations', () {
    test('INT-01.1: Integer declaration initialised to value', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('x', value: 42),
        _output([_id('x')]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.completed);
      expect(out, ['42']);
    });

    test('INT-01.2: Float declaration emits value', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declFloat('f', value: 3.14),
        _output([_id('f')]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.completed);
      expect(double.parse(out.first), closeTo(3.14, 0.001));
    });

    test('INT-01.3: Undeclared variable access is a runtime error', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([_output([_id('noExiste')])]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.error);
      expect(result.errorMessage, contains('noExiste'));
    });

    test('INT-01.4: Default value for int is 0', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([_declInt('z'), _output([_id('z')])]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.completed);
      expect(out, ['0']);
    });

    test('INT-01.5: String literal output', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([_output([_str('Hola mundo')])]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.completed);
      expect(out, ['Hola mundo']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 2 — Arithmetic
  // ══════════════════════════════════════════════════════════════════

  group('INT-02: Arithmetic operations', () {
    test('INT-02.1: Addition of integers', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('a', value: 10),
        _declInt('b', value: 7),
        _output([_bin(_id('a'), BinaryOperator.add, _id('b'))]),
      ]);
      await interp.execute(prog);
      expect(out, ['17']);
    });

    test('INT-02.2: Subtraction', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(20), BinaryOperator.subtract, _int(8))]),
      ]);
      await interp.execute(prog);
      expect(out, ['12']);
    });

    test('INT-02.3: Multiplication', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(6), BinaryOperator.multiply, _int(7))]),
      ]);
      await interp.execute(prog);
      expect(out, ['42']);
    });

    test('INT-02.4: Integer division truncates', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(10), BinaryOperator.divide, _int(3))]),
      ]);
      await interp.execute(prog);
      expect(out, ['3']);
    });

    test('INT-02.5: Float division', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_float(10.0), BinaryOperator.divide, _float(4.0))]),
      ]);
      await interp.execute(prog);
      expect(double.parse(out.first), closeTo(2.5, 0.001));
    });

    test('INT-02.6: Modulo', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(10), BinaryOperator.modulo, _int(3))]),
      ]);
      await interp.execute(prog);
      expect(out, ['1']);
    });

    test('INT-02.7: Division by zero raises error', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(5), BinaryOperator.divide, _int(0))]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.error);
      expect(result.errorMessage, contains('cero'));
    });

    test('INT-02.8: Nested expression: (2+3)*4 = 20', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([
          _bin(
            _bin(_int(2), BinaryOperator.add, _int(3)),
            BinaryOperator.multiply,
            _int(4),
          ),
        ]),
      ]);
      await interp.execute(prog);
      expect(out, ['20']);
    });

    test('INT-02.9: String concatenation via add', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_str('Hola '), BinaryOperator.add, _str('mundo'))]),
      ]);
      await interp.execute(prog);
      expect(out, ['Hola mundo']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 3 — Assignment
  // ══════════════════════════════════════════════════════════════════

  group('INT-03: Assignment operations', () {
    test('INT-03.1: Simple assignment updates variable', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('x', value: 1),
        _assign('x', _int(99)),
        _output([_id('x')]),
      ]);
      await interp.execute(prog);
      expect(out, ['99']);
    });

    test('INT-03.2: Add-assign (+=)', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('n', value: 10),
        _assign('n', _int(5), AssignmentOperator.addAssign),
        _output([_id('n')]),
      ]);
      await interp.execute(prog);
      expect(out, ['15']);
    });

    test('INT-03.3: Subtract-assign (-=)', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('n', value: 10),
        _assign('n', _int(3), AssignmentOperator.subtractAssign),
        _output([_id('n')]),
      ]);
      await interp.execute(prog);
      expect(out, ['7']);
    });

    test('INT-03.4: Pre-increment', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('i', value: 0),
        ExpressionStatementNode(
          expression: UnaryExpressionNode(
            operator: UnaryOperator.preIncrement,
            operand: _id('i'),
            position: _p,
          ),
          position: _p,
        ),
        _output([_id('i')]),
      ]);
      await interp.execute(prog);
      expect(out, ['1']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 4 — Conditionals
  // ══════════════════════════════════════════════════════════════════

  group('INT-04: If / if-else statements', () {
    test('INT-04.1: True branch executes', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: _bool(true),
          thenBranch: _block([_output([_str('si')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['si']);
    });

    test('INT-04.2: False condition runs else branch', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: _bool(false),
          thenBranch: _block([_output([_str('si')])]),
          elseBranch: _block([_output([_str('no')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['no']);
    });

    test('INT-04.3: Comparison condition: x > 5', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('x', value: 10),
        IfStatementNode(
          condition: _bin(_id('x'), BinaryOperator.greater, _int(5)),
          thenBranch: _block([_output([_str('mayor')])]),
          elseBranch: _block([_output([_str('menor')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['mayor']);
    });

    test('INT-04.4: Equality check', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('x', value: 42),
        IfStatementNode(
          condition: _bin(_id('x'), BinaryOperator.equal, _int(42)),
          thenBranch: _block([_output([_str('igual')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['igual']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 5 — Loops
  // ══════════════════════════════════════════════════════════════════

  group('INT-05: While / for / do-while loops', () {
    test('INT-05.1: While loop runs N times', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('i', value: 0),
        WhileStatementNode(
          condition: _bin(_id('i'), BinaryOperator.less, _int(3)),
          body: _block([
            _output([_id('i')]),
            _assign('i', _int(1), AssignmentOperator.addAssign),
          ]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['0', '1', '2']);
    });

    test('INT-05.2: For loop sums 1..5 = 15', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('sum', value: 0),
        ForStatementNode(
          initializer: _declInt('i', value: 1),
          condition: _bin(_id('i'), BinaryOperator.lessEqual, _int(5)),
          update: _assign('i', _int(1), AssignmentOperator.addAssign),
          body: _block([
            _assign('sum', _id('i'), AssignmentOperator.addAssign),
          ]),
          position: _p,
        ),
        _output([_id('sum')]),
      ]);
      await interp.execute(prog);
      expect(out, ['15']);
    });

    test('INT-05.3: Do-while executes body at least once', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        DoWhileStatementNode(
          body: _block([_output([_str('ejecutado')])]),
          condition: _bool(false),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['ejecutado']);
    });

    test('INT-05.4: Break exits loop early', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('i', value: 0),
        WhileStatementNode(
          condition: _bool(true),
          body: _block([
            IfStatementNode(
              condition: _bin(_id('i'), BinaryOperator.equal, _int(2)),
              thenBranch: _block([BreakStatementNode(position: _p)]),
              position: _p,
            ),
            _output([_id('i')]),
            _assign('i', _int(1), AssignmentOperator.addAssign),
          ]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['0', '1']);
    });

    test('INT-05.5: Continue skips rest of body', () async {
      final (interp, out) = _makeInterpreter();
      // Print only odd numbers 1,3 from 0..4
      final prog = _program([
        _declInt('i', value: 0),
        WhileStatementNode(
          condition: _bin(_id('i'), BinaryOperator.less, _int(4)),
          body: _block([
            _assign('i', _int(1), AssignmentOperator.addAssign),
            IfStatementNode(
              condition: _bin(
                _bin(_id('i'), BinaryOperator.modulo, _int(2)),
                BinaryOperator.equal,
                _int(0),
              ),
              thenBranch: _block([ContinueStatementNode(position: _p)]),
              position: _p,
            ),
            _output([_id('i')]),
          ]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['1', '3']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 6 — Input / Output
  // ══════════════════════════════════════════════════════════════════

  group('INT-06: Input / Output', () {
    test('INT-06.1: Output emits string', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([_output([_str('FlowCode')])]);
      await interp.execute(prog);
      expect(out, ['FlowCode']);
    });

    test('INT-06.2: Input reads integer', () async {
      final (interp, out) = _makeInterpreter(inputs: ['7']);
      final prog = _program([
        _declInt('n'),
        _input('n'),
        _output([_id('n')]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.completed);
      expect(out, ['7']);
    });

    test('INT-06.3: Multiple outputs appear in order', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _output([_str('uno')]),
        _output([_str('dos')]),
        _output([_str('tres')]),
      ]);
      await interp.execute(prog);
      expect(out, ['uno', 'dos', 'tres']);
    });

    test('INT-06.4: Input coerces string to float', () async {
      final (interp, out) = _makeInterpreter(inputs: ['3.14']);
      final prog = _program([
        _declFloat('pi'),
        _input('pi'),
        _output([_id('pi')]),
      ]);
      await interp.execute(prog);
      expect(double.parse(out.first), closeTo(3.14, 0.001));
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 7 — Safety limits
  // ══════════════════════════════════════════════════════════════════

  group('INT-07: Safety constraints', () {
    test('INT-07.1: Iteration limit stops infinite loop', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([
        WhileStatementNode(
          condition: _bool(true),
          body: _block([_output([_str('x')])]),
          position: _p,
        ),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.iterationLimit);
      expect(result.errorMessage, contains('pasos'));
    });

    test('INT-07.2: Division by zero returns error', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(1), BinaryOperator.divide, _int(0))]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.error);
    });

    test('INT-07.3: Modulo by zero returns error', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([
        _output([_bin(_int(5), BinaryOperator.modulo, _int(0))]),
      ]);
      final result = await interp.execute(prog);
      expect(result.stopReason, StopReason.error);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 8 — InterpreterResult metadata
  // ══════════════════════════════════════════════════════════════════

  group('INT-08: InterpreterResult metadata', () {
    test('INT-08.1: Steps counter is positive', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([_declInt('a', value: 1), _output([_id('a')])]);
      final result = await interp.execute(prog);
      expect(result.steps, greaterThan(0));
    });

    test('INT-08.2: ElapsedMs is non-negative', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([_output([_int(1)])]);
      final result = await interp.execute(prog);
      expect(result.elapsedMs, greaterThanOrEqualTo(0));
    });

    test('INT-08.3: FinalVariables contains declared variables', () async {
      final (interp, _) = _makeInterpreter();
      final prog = _program([_declInt('score', value: 100)]);
      final result = await interp.execute(prog);
      expect(result.finalVariables['score'], 100);
    });

    test('INT-08.4: Interpreter can be reused for multiple programs', () async {
      final (interp, out) = _makeInterpreter();
      await interp.execute(_program([_output([_str('primera')])]));
      await interp.execute(_program([_output([_str('segunda')])]));
      expect(out, ['primera', 'segunda']);
    });
  });

  // ══════════════════════════════════════════════════════════════════
  // GROUP 9 — Logical operators
  // ══════════════════════════════════════════════════════════════════

  group('INT-09: Logical and comparison operators', () {
    test('INT-09.1: AND true && true', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: _bin(_bool(true), BinaryOperator.and, _bool(true)),
          thenBranch: _block([_output([_str('ok')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['ok']);
    });

    test('INT-09.2: OR false || true', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: _bin(_bool(false), BinaryOperator.or, _bool(true)),
          thenBranch: _block([_output([_str('ok')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['ok']);
    });

    test('INT-09.3: NOT negates false → true', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: UnaryExpressionNode(
            operator: UnaryOperator.not,
            operand: _bool(false),
            position: _p,
          ),
          thenBranch: _block([_output([_str('negado')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['negado']);
    });

    test('INT-09.4: Greater-equal: 5 >= 5 → true', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        _declInt('x', value: 5),
        IfStatementNode(
          condition: _bin(_id('x'), BinaryOperator.greaterEqual, _int(5)),
          thenBranch: _block([_output([_str('ok')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['ok']);
    });

    test('INT-09.5: Not-equal: 3 != 4 → true', () async {
      final (interp, out) = _makeInterpreter();
      final prog = _program([
        IfStatementNode(
          condition: _bin(_int(3), BinaryOperator.notEqual, _int(4)),
          thenBranch: _block([_output([_str('distinto')])]),
          position: _p,
        ),
      ]);
      await interp.execute(prog);
      expect(out, ['distinto']);
    });
  });
}
