/// Tests for the Code Optimizer (Phase 4)
/// Tests constant folding, dead code elimination, expression simplification,
/// and control flow optimization

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/code_optimizer.dart';
import 'package:flowdiagramapp/compiler/ast_nodes.dart';
import 'package:flowdiagramapp/compiler/symbol_table.dart';

void main() {
  group('DiagramCodeOptimizer - Basic Tests', () {
    late DiagramCodeOptimizer optimizer;

    setUp(() {
      optimizer = DiagramCodeOptimizer();
    });

    test('Create optimizer instance', () {
      expect(optimizer, isNotNull);
    });

    test('Optimizer with no optimizations level', () {
      final config = OptimizerConfig.fromLevel(OptimizationLevel.none);
      final opt = DiagramCodeOptimizer(config: config);

      final ast = _createSimpleAST();
      final result = opt.optimize(ast);

      expect(result.success, true);
      expect(result.totalOptimizations, 0);
    });

    test('Optimizer with basic level', () {
      final config = OptimizerConfig.fromLevel(OptimizationLevel.basic);
      expect(config.constantFolding, true);
      expect(config.deadCodeElimination, true);
      expect(config.expressionSimplification, false);
    });

    test('Optimizer with standard level', () {
      final config = OptimizerConfig.fromLevel(OptimizationLevel.standard);
      expect(config.constantFolding, true);
      expect(config.deadCodeElimination, true);
      expect(config.expressionSimplification, true);
    });

    test('Optimizer with aggressive level', () {
      final config = OptimizerConfig.fromLevel(OptimizationLevel.aggressive);
      expect(config.constantFolding, true);
      expect(config.deadCodeElimination, true);
      expect(config.expressionSimplification, true);
      expect(config.controlFlowOptimization, true);
    });
  });

  group('DiagramCodeOptimizer - Constant Folding', () {
    late DiagramCodeOptimizer optimizer;

    setUp(() {
      optimizer = DiagramCodeOptimizer(
        config: const OptimizerConfig(
          constantFolding: true,
          deadCodeElimination: false,
          expressionSimplification: false,
          controlFlowOptimization: false,
        ),
      );
    });

    test('Fold integer addition: 2 + 3 = 5', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 2, position: _pos),
          operator: BinaryOperator.add,
          right: const IntegerLiteralNode(value: 3, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.constantsFolded, greaterThan(0));

      // Verify the folded value
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 5);
    });

    test('Fold integer subtraction: 10 - 4 = 6', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 10, position: _pos),
          operator: BinaryOperator.subtract,
          right: const IntegerLiteralNode(value: 4, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 6);
    });

    test('Fold integer multiplication: 3 * 4 = 12', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 3, position: _pos),
          operator: BinaryOperator.multiply,
          right: const IntegerLiteralNode(value: 4, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 12);
    });

    test('Fold integer division: 20 / 4 = 5', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 20, position: _pos),
          operator: BinaryOperator.divide,
          right: const IntegerLiteralNode(value: 4, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 5);
    });

    test('Fold integer modulo: 17 % 5 = 2', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 17, position: _pos),
          operator: BinaryOperator.modulo,
          right: const IntegerLiteralNode(value: 5, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 2);
    });

    test('Fold float addition: 1.5 + 2.5 = 4.0', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const FloatLiteralNode(value: 1.5, position: _pos),
          operator: BinaryOperator.add,
          right: const FloatLiteralNode(value: 2.5, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<FloatLiteralNode>());
      expect((optimizedExpr as FloatLiteralNode).value, 4.0);
    });

    test('Fold comparison: 5 > 3 = true', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 5, position: _pos),
          operator: BinaryOperator.greater,
          right: const IntegerLiteralNode(value: 3, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, true);
    });

    test('Fold comparison: 2 == 2 = true', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 2, position: _pos),
          operator: BinaryOperator.equal,
          right: const IntegerLiteralNode(value: 2, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, true);
    });

    test('Fold boolean AND: true && false = false', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const BooleanLiteralNode(value: true, position: _pos),
          operator: BinaryOperator.and,
          right: const BooleanLiteralNode(value: false, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, false);
    });

    test('Fold boolean OR: true || false = true', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const BooleanLiteralNode(value: true, position: _pos),
          operator: BinaryOperator.or,
          right: const BooleanLiteralNode(value: false, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, true);
    });

    test('Fold unary negation: -5', () {
      final ast = _createASTWithExpression(
        const UnaryExpressionNode(
          operator: UnaryOperator.negate,
          operand: IntegerLiteralNode(value: 5, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, -5);
    });

    test('Fold unary NOT: !true = false', () {
      final ast = _createASTWithExpression(
        const UnaryExpressionNode(
          operator: UnaryOperator.not,
          operand: BooleanLiteralNode(value: true, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, false);
    });

    test('Fold nested expressions: (2 + 3) * 4 = 20', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: BinaryExpressionNode(
            left: const IntegerLiteralNode(value: 2, position: _pos),
            operator: BinaryOperator.add,
            right: const IntegerLiteralNode(value: 3, position: _pos),
            position: _pos,
          ),
          operator: BinaryOperator.multiply,
          right: const IntegerLiteralNode(value: 4, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 20);
    });

    test('Fold bitwise operations: 5 & 3 = 1', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 5, position: _pos),
          operator: BinaryOperator.bitAnd,
          right: const IntegerLiteralNode(value: 3, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 1);
    });

    test('Do not fold division by zero', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 10, position: _pos),
          operator: BinaryOperator.divide,
          right: const IntegerLiteralNode(value: 0, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      // Should not fold - expression remains unchanged
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BinaryExpressionNode>());
    });

    test('Fold conditional expression with constant condition', () {
      final ast = _createASTWithExpression(
        ConditionalExpressionNode(
          condition: const BooleanLiteralNode(value: true, position: _pos),
          trueExpression: const IntegerLiteralNode(value: 1, position: _pos),
          falseExpression: const IntegerLiteralNode(value: 2, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 1);
    });
  });

  group('DiagramCodeOptimizer - Dead Code Elimination', () {
    late DiagramCodeOptimizer optimizer;

    setUp(() {
      optimizer = DiagramCodeOptimizer(
        config: const OptimizerConfig(
          constantFolding: true,
          deadCodeElimination: true,
          expressionSimplification: false,
          controlFlowOptimization: false,
        ),
      );
    });

    test('Remove if with always-true condition (keep then branch)', () {
      final ast = _createASTWithStatement(
        IfStatementNode(
          condition: const BooleanLiteralNode(value: true, position: _pos),
          thenBranch: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 1, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          elseBranch: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 2, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.deadCodeRemoved, greaterThan(0));

      // Verify only then branch remains
      final stmt = _extractStatement(result.optimizedAST!);
      expect(stmt, isA<ExpressionStatementNode>());
    });

    test('Remove if with always-false condition (keep else branch)', () {
      final ast = _createASTWithStatement(
        IfStatementNode(
          condition: const BooleanLiteralNode(value: false, position: _pos),
          thenBranch: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 1, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          elseBranch: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 2, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.deadCodeRemoved, greaterThan(0));
    });

    test('Remove while with always-false condition', () {
      final ast = _createASTWithStatement(
        WhileStatementNode(
          condition: const BooleanLiteralNode(value: false, position: _pos),
          body: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 1, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.deadCodeRemoved, greaterThan(0));
    });

    test('Remove for with always-false condition', () {
      final ast = _createASTWithStatement(
        ForStatementNode(
          initializer: AssignmentExpressionNode(
            target: const IdentifierNode(name: 'i', position: _pos),
            operator: AssignmentOperator.assign,
            value: const IntegerLiteralNode(value: 0, position: _pos),
            position: _pos,
          ),
          condition: const BooleanLiteralNode(value: false, position: _pos),
          update: UnaryExpressionNode(
            operator: UnaryOperator.postIncrement,
            operand: const IdentifierNode(name: 'i', position: _pos),
            position: _pos,
          ),
          body: ExpressionStatementNode(
            expression: const IdentifierNode(name: 'x', position: _pos),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.deadCodeRemoved, greaterThan(0));
    });

    test('Remove code after return statement', () {
      final ast = _createASTWithStatement(
        BlockStatementNode(
          statements: [
            ExpressionStatementNode(
              expression: AssignmentExpressionNode(
                target: const IdentifierNode(name: 'x', position: _pos),
                operator: AssignmentOperator.assign,
                value: const IntegerLiteralNode(value: 1, position: _pos),
                position: _pos,
              ),
              position: _pos,
            ),
            const ReturnStatementNode(
              value: IntegerLiteralNode(value: 0, position: _pos),
              position: _pos,
            ),
            ExpressionStatementNode(
              expression: AssignmentExpressionNode(
                target: const IdentifierNode(name: 'y', position: _pos),
                operator: AssignmentOperator.assign,
                value: const IntegerLiteralNode(value: 2, position: _pos),
                position: _pos,
              ),
              position: _pos,
            ), // This should be removed
          ],
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.metrics.deadCodeRemoved, greaterThan(0));

      // Verify only 2 statements remain
      final stmt = _extractStatement(result.optimizedAST!);
      expect(stmt, isA<BlockStatementNode>());
      expect((stmt as BlockStatementNode).statements.length, 2);
    });
  });

  group('DiagramCodeOptimizer - Expression Simplification', () {
    late DiagramCodeOptimizer optimizer;

    setUp(() {
      optimizer = DiagramCodeOptimizer(
        config: const OptimizerConfig(
          constantFolding: false,
          deadCodeElimination: false,
          expressionSimplification: true,
          controlFlowOptimization: false,
        ),
      );
    });

    test('Simplify x + 0 = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.add,
          right: const IntegerLiteralNode(value: 0, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
      expect((optimizedExpr as IdentifierNode).name, 'x');
    });

    test('Simplify 0 + x = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 0, position: _pos),
          operator: BinaryOperator.add,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
      expect((optimizedExpr as IdentifierNode).name, 'x');
    });

    test('Simplify x - 0 = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.subtract,
          right: const IntegerLiteralNode(value: 0, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify x * 1 = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.multiply,
          right: const IntegerLiteralNode(value: 1, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify 1 * x = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 1, position: _pos),
          operator: BinaryOperator.multiply,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify x * 0 = 0', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.multiply,
          right: const IntegerLiteralNode(value: 0, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 0);
    });

    test('Simplify x / 1 = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.divide,
          right: const IntegerLiteralNode(value: 1, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify x % 1 = 0', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.modulo,
          right: const IntegerLiteralNode(value: 1, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 0);
    });

    test('Simplify x && true = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.and,
          right: const BooleanLiteralNode(value: true, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify x && false = false', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.and,
          right: const BooleanLiteralNode(value: false, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, false);
    });

    test('Simplify x || false = x', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.or,
          right: const BooleanLiteralNode(value: false, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify x || true = true', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.or,
          right: const BooleanLiteralNode(value: true, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, true);
    });

    test('Simplify x - x = 0', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.subtract,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 0);
    });

    test('Simplify x / x = 1', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.divide,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IntegerLiteralNode>());
      expect((optimizedExpr as IntegerLiteralNode).value, 1);
    });

    test('Simplify x == x = true', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.equal,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, true);
    });

    test('Simplify x != x = false', () {
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IdentifierNode(name: 'x', position: _pos),
          operator: BinaryOperator.notEqual,
          right: const IdentifierNode(name: 'x', position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<BooleanLiteralNode>());
      expect((optimizedExpr as BooleanLiteralNode).value, false);
    });

    test('Simplify double negation: --x = x', () {
      final ast = _createASTWithExpression(
        UnaryExpressionNode(
          operator: UnaryOperator.negate,
          operand: const UnaryExpressionNode(
            operator: UnaryOperator.negate,
            operand: IdentifierNode(name: 'x', position: _pos),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });

    test('Simplify double NOT: !!x = x', () {
      final ast = _createASTWithExpression(
        UnaryExpressionNode(
          operator: UnaryOperator.not,
          operand: const UnaryExpressionNode(
            operator: UnaryOperator.not,
            operand: IdentifierNode(name: 'x', position: _pos),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final optimizedExpr = _extractExpression(result.optimizedAST!);
      expect(optimizedExpr, isA<IdentifierNode>());
    });
  });

  group('DiagramCodeOptimizer - Control Flow Optimization', () {
    late DiagramCodeOptimizer optimizer;

    setUp(() {
      optimizer = DiagramCodeOptimizer(
        config: const OptimizerConfig(
          constantFolding: false,
          deadCodeElimination: false,
          expressionSimplification: false,
          controlFlowOptimization: true,
        ),
      );
    });

    test('Remove empty else branch', () {
      final ast = _createASTWithStatement(
        IfStatementNode(
          condition: const IdentifierNode(name: 'x', position: _pos),
          thenBranch: ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'y', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 1, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
          elseBranch: const BlockStatementNode(
            statements: [], // Empty else
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      expect(result.success, true);
      expect(result.metrics.controlFlowOptimized, greaterThan(0));

      final stmt = _extractStatement(result.optimizedAST!);
      expect(stmt, isA<IfStatementNode>());
      expect((stmt as IfStatementNode).elseBranch, isNull);
    });

    test('Flatten single-statement block', () {
      final ast = _createASTWithStatement(
        BlockStatementNode(
          statements: [
            BlockStatementNode(
              statements: [
                ExpressionStatementNode(
                  expression: AssignmentExpressionNode(
                    target: const IdentifierNode(name: 'x', position: _pos),
                    operator: AssignmentOperator.assign,
                    value: const IntegerLiteralNode(value: 1, position: _pos),
                    position: _pos,
                  ),
                  position: _pos,
                ),
              ],
              position: _pos,
            ),
          ],
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      expect(result.success, true);

      final stmt = _extractStatement(result.optimizedAST!);
      expect(stmt, isA<BlockStatementNode>());
      final block = stmt as BlockStatementNode;
      expect(block.statements.length, 1);
      expect(block.statements.first, isA<ExpressionStatementNode>());
    });
  });

  group('DiagramCodeOptimizer - Combined Optimizations', () {
    test('Multiple optimization passes', () {
      final optimizer = DiagramCodeOptimizer(
        config: OptimizerConfig.fromLevel(OptimizationLevel.aggressive),
      );

      // Create complex expression that benefits from multiple passes
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: BinaryExpressionNode(
            left: const IntegerLiteralNode(value: 2, position: _pos),
            operator: BinaryOperator.add,
            right: const IntegerLiteralNode(value: 3, position: _pos),
            position: _pos,
          ),
          operator: BinaryOperator.multiply,
          right: BinaryExpressionNode(
            left: const IdentifierNode(name: 'x', position: _pos),
            operator: BinaryOperator.add,
            right: const IntegerLiteralNode(value: 0, position: _pos),
            position: _pos,
          ),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.success, true);
      expect(result.totalOptimizations, greaterThan(0));
      expect(result.passResults.length, greaterThan(0));
    });

    test('Optimization metrics are accurate', () {
      final optimizer = DiagramCodeOptimizer();

      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 10, position: _pos),
          operator: BinaryOperator.add,
          right: const IntegerLiteralNode(value: 5, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);

      expect(result.metrics.originalNodeCount, greaterThan(0));
      expect(result.metrics.optimizedNodeCount, greaterThan(0));
      expect(result.metrics.constantsFolded, greaterThanOrEqualTo(0));
    });
  });

  group('OptimizationResult Tests', () {
    test('Result properties', () {
      const metrics = OptimizationMetrics(
        originalNodeCount: 10,
        optimizedNodeCount: 8,
        constantsFolded: 2,
        deadCodeRemoved: 1,
        expressionsSimplified: 1,
        controlFlowOptimized: 0,
        sizeReductionPercent: 20.0,
        totalTimeMs: 5,
      );

      expect(metrics.improvementRatio, closeTo(0.2, 0.01));
    });

    test('Empty metrics', () {
      const metrics = OptimizationMetrics();
      expect(metrics.improvementRatio, 0.0);
    });
  });

  group('Report Generation', () {
    test('Generate optimization report', () {
      final optimizer = DiagramCodeOptimizer();
      final ast = _createASTWithExpression(
        BinaryExpressionNode(
          left: const IntegerLiteralNode(value: 2, position: _pos),
          operator: BinaryOperator.add,
          right: const IntegerLiteralNode(value: 3, position: _pos),
          position: _pos,
        ),
      );

      final result = optimizer.optimize(ast);
      final report = optimizer.generateReport(result);

      expect(report, contains('REPORTE DE OPTIMIZACIÓN'));
      expect(report, contains('RESUMEN'));
      expect(report, contains('MÉTRICAS'));
    });
  });

  group('ProgramNode Extension', () {
    test('Optimize extension method', () {
      final ast = _createSimpleAST();
      final result = ast.optimize();

      expect(result.success, true);
      expect(result.optimizedAST, isNotNull);
    });

    test('Optimize with custom config', () {
      final ast = _createSimpleAST();
      final result = ast.optimize(
        config: OptimizerConfig.fromLevel(OptimizationLevel.aggressive),
      );

      expect(result.success, true);
    });
  });
}

// Helper constant for positions
const _pos = SourcePosition(line: 1, column: 1);

// Helper to create a simple AST
ProgramNode _createSimpleAST() {
  return ProgramNode(
    diagramNodes: [
      DiagramASTNode(
        diagramNodeId: 'node1',
        nodeType: 'process',
        statements: [
          ExpressionStatementNode(
            expression: AssignmentExpressionNode(
              target: const IdentifierNode(name: 'x', position: _pos),
              operator: AssignmentOperator.assign,
              value: const IntegerLiteralNode(value: 5, position: _pos),
              position: _pos,
            ),
            position: _pos,
          ),
        ],
        position: _pos,
      ),
    ],
    globalDeclarations: const [],
    position: _pos,
  );
}

// Helper to create AST with a single expression
ProgramNode _createASTWithExpression(ASTNode expression) {
  return ProgramNode(
    diagramNodes: [
      DiagramASTNode(
        diagramNodeId: 'node1',
        nodeType: 'process',
        statements: [
          ExpressionStatementNode(
            expression: expression,
            position: _pos,
          ),
        ],
        position: _pos,
      ),
    ],
    globalDeclarations: const [],
    position: _pos,
  );
}

// Helper to create AST with a single statement
ProgramNode _createASTWithStatement(StatementNode statement) {
  return ProgramNode(
    diagramNodes: [
      DiagramASTNode(
        diagramNodeId: 'node1',
        nodeType: 'process',
        statements: [statement],
        position: _pos,
      ),
    ],
    globalDeclarations: const [],
    position: _pos,
  );
}

// Helper to extract expression from optimized AST
ASTNode _extractExpression(ProgramNode ast) {
  final stmt = ast.diagramNodes.first.statements.first;
  if (stmt is ExpressionStatementNode) {
    return stmt.expression;
  }
  throw StateError('Expected ExpressionStatementNode');
}

// Helper to extract statement from optimized AST
StatementNode _extractStatement(ProgramNode ast) {
  return ast.diagramNodes.first.statements.first;
}
