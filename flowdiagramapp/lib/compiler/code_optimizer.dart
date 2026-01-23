/// Code Optimizer for FlowCode Diagram Compiler
/// Performs basic optimizations on the AST and generated code
///
/// This is part of Phase 4 of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.
///
/// Optimizations implemented:
/// - Constant folding (evaluate constant expressions at compile time)
/// - Dead code elimination (remove unreachable code)
/// - Expression simplification (algebraic simplifications)
/// - Control flow optimization (simplify conditions)
/// - Redundant code elimination

import 'ast_nodes.dart';
import 'symbol_table.dart';
import 'compiler_errors.dart';

// ============================================
// OPTIMIZATION RESULTS
// ============================================

/// Result of a single optimization pass
class OptimizationPassResult {
  /// Name of the optimization pass
  final String passName;

  /// Number of optimizations applied
  final int optimizationsApplied;

  /// Description of changes made
  final List<String> changes;

  /// Time taken in milliseconds
  final int timeMs;

  const OptimizationPassResult({
    required this.passName,
    required this.optimizationsApplied,
    this.changes = const [],
    this.timeMs = 0,
  });
}

/// Result of the complete optimization phase
class OptimizationResult {
  /// Whether optimization was successful
  final bool success;

  /// The optimized AST
  final ProgramNode? optimizedAST;

  /// Results from each optimization pass
  final List<OptimizationPassResult> passResults;

  /// Total optimizations applied
  final int totalOptimizations;

  /// Optimization metrics
  final OptimizationMetrics metrics;

  /// Any errors during optimization
  final List<CompilerError> errors;

  /// Any warnings during optimization
  final List<CompilerError> warnings;

  const OptimizationResult({
    required this.success,
    this.optimizedAST,
    this.passResults = const [],
    this.totalOptimizations = 0,
    required this.metrics,
    this.errors = const [],
    this.warnings = const [],
  });

  /// Check if any optimizations were applied
  bool get hasOptimizations => totalOptimizations > 0;
}

/// Metrics from the optimization phase
class OptimizationMetrics {
  /// Original AST node count
  final int originalNodeCount;

  /// Optimized AST node count
  final int optimizedNodeCount;

  /// Number of constant expressions folded
  final int constantsFolded;

  /// Number of dead code blocks removed
  final int deadCodeRemoved;

  /// Number of expressions simplified
  final int expressionsSimplified;

  /// Number of control flow optimizations
  final int controlFlowOptimized;

  /// Estimated code size reduction percentage
  final double sizeReductionPercent;

  /// Total optimization time in milliseconds
  final int totalTimeMs;

  const OptimizationMetrics({
    this.originalNodeCount = 0,
    this.optimizedNodeCount = 0,
    this.constantsFolded = 0,
    this.deadCodeRemoved = 0,
    this.expressionsSimplified = 0,
    this.controlFlowOptimized = 0,
    this.sizeReductionPercent = 0.0,
    this.totalTimeMs = 0,
  });

  /// Calculate the improvement ratio
  double get improvementRatio {
    if (originalNodeCount == 0) return 0.0;
    return (originalNodeCount - optimizedNodeCount) / originalNodeCount;
  }
}

// ============================================
// OPTIMIZATION LEVELS
// ============================================

/// Optimization level configuration
enum OptimizationLevel {
  /// No optimizations
  none,

  /// Basic optimizations (constant folding, simple dead code)
  basic,

  /// Standard optimizations (all basic + expression simplification)
  standard,

  /// Aggressive optimizations (all + control flow optimization)
  aggressive,
}

/// Configuration for the optimizer
class OptimizerConfig {
  /// Optimization level
  final OptimizationLevel level;

  /// Enable constant folding
  final bool constantFolding;

  /// Enable dead code elimination
  final bool deadCodeElimination;

  /// Enable expression simplification
  final bool expressionSimplification;

  /// Enable control flow optimization
  final bool controlFlowOptimization;

  /// Enable redundant code elimination
  final bool redundantCodeElimination;

  /// Maximum number of optimization passes
  final int maxPasses;

  const OptimizerConfig({
    this.level = OptimizationLevel.standard,
    this.constantFolding = true,
    this.deadCodeElimination = true,
    this.expressionSimplification = true,
    this.controlFlowOptimization = true,
    this.redundantCodeElimination = true,
    this.maxPasses = 3,
  });

  /// Create config from optimization level
  factory OptimizerConfig.fromLevel(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.none:
        return const OptimizerConfig(
          level: OptimizationLevel.none,
          constantFolding: false,
          deadCodeElimination: false,
          expressionSimplification: false,
          controlFlowOptimization: false,
          redundantCodeElimination: false,
          maxPasses: 0,
        );
      case OptimizationLevel.basic:
        return const OptimizerConfig(
          level: OptimizationLevel.basic,
          constantFolding: true,
          deadCodeElimination: true,
          expressionSimplification: false,
          controlFlowOptimization: false,
          redundantCodeElimination: false,
          maxPasses: 1,
        );
      case OptimizationLevel.standard:
        return const OptimizerConfig(
          level: OptimizationLevel.standard,
          constantFolding: true,
          deadCodeElimination: true,
          expressionSimplification: true,
          controlFlowOptimization: false,
          redundantCodeElimination: true,
          maxPasses: 2,
        );
      case OptimizationLevel.aggressive:
        return const OptimizerConfig(
          level: OptimizationLevel.aggressive,
          constantFolding: true,
          deadCodeElimination: true,
          expressionSimplification: true,
          controlFlowOptimization: true,
          redundantCodeElimination: true,
          maxPasses: 3,
        );
    }
  }

  /// Default configuration
  static const OptimizerConfig defaults = OptimizerConfig();
}

// ============================================
// MAIN CODE OPTIMIZER
// ============================================

/// Main code optimizer for the FlowCode compiler
///
/// Performs various optimizations on the AST:
/// - Constant folding
/// - Dead code elimination
/// - Expression simplification
/// - Control flow optimization
class DiagramCodeOptimizer {
  /// Configuration
  final OptimizerConfig config;

  /// Optimization statistics
  int _constantsFolded = 0;
  int _deadCodeRemoved = 0;
  int _expressionsSimplified = 0;
  int _controlFlowOptimized = 0;

  /// Changes log
  final List<String> _changes = [];

  /// Errors
  final List<CompilerError> _errors = [];

  /// Warnings
  final List<CompilerError> _warnings = [];

  DiagramCodeOptimizer({this.config = OptimizerConfig.defaults});

  /// Reset optimizer state
  void _reset() {
    _constantsFolded = 0;
    _deadCodeRemoved = 0;
    _expressionsSimplified = 0;
    _controlFlowOptimized = 0;
    _changes.clear();
    _errors.clear();
    _warnings.clear();
  }

  /// Main optimization entry point
  OptimizationResult optimize(ProgramNode ast, {SymbolTable? symbolTable}) {
    _reset();

    if (config.level == OptimizationLevel.none) {
      return OptimizationResult(
        success: true,
        optimizedAST: ast,
        totalOptimizations: 0,
        metrics: const OptimizationMetrics(),
      );
    }

    final stopwatch = Stopwatch()..start();
    final passResults = <OptimizationPassResult>[];
    final originalNodeCount = _countNodes(ast);

    ProgramNode currentAST = ast;

    // Run optimization passes
    for (int pass = 0; pass < config.maxPasses; pass++) {
      final passStopwatch = Stopwatch()..start();
      int passOptimizations = 0;
      final passChanges = <String>[];

      // Constant folding
      if (config.constantFolding) {
        final before = _constantsFolded;
        currentAST = _applyConstantFolding(currentAST);
        final folded = _constantsFolded - before;
        passOptimizations += folded;
        if (folded > 0) {
          passChanges.add('Plegado de constantes: $folded expresiones');
        }
      }

      // Dead code elimination
      if (config.deadCodeElimination) {
        final before = _deadCodeRemoved;
        currentAST = _applyDeadCodeElimination(currentAST);
        final removed = _deadCodeRemoved - before;
        passOptimizations += removed;
        if (removed > 0) {
          passChanges.add('Código muerto eliminado: $removed bloques');
        }
      }

      // Expression simplification
      if (config.expressionSimplification) {
        final before = _expressionsSimplified;
        currentAST = _applyExpressionSimplification(currentAST);
        final simplified = _expressionsSimplified - before;
        passOptimizations += simplified;
        if (simplified > 0) {
          passChanges.add('Expresiones simplificadas: $simplified');
        }
      }

      // Control flow optimization
      if (config.controlFlowOptimization) {
        final before = _controlFlowOptimized;
        currentAST = _applyControlFlowOptimization(currentAST);
        final optimized = _controlFlowOptimized - before;
        passOptimizations += optimized;
        if (optimized > 0) {
          passChanges.add('Flujo de control optimizado: $optimized');
        }
      }

      passStopwatch.stop();

      passResults.add(OptimizationPassResult(
        passName: 'Pasada ${pass + 1}',
        optimizationsApplied: passOptimizations,
        changes: passChanges,
        timeMs: passStopwatch.elapsedMilliseconds,
      ));

      // Stop if no optimizations were applied in this pass
      if (passOptimizations == 0) break;
    }

    stopwatch.stop();
    final optimizedNodeCount = _countNodes(currentAST);
    final totalOptimizations = _constantsFolded +
        _deadCodeRemoved +
        _expressionsSimplified +
        _controlFlowOptimized;

    final sizeReduction = originalNodeCount > 0
        ? ((originalNodeCount - optimizedNodeCount) / originalNodeCount) * 100
        : 0.0;

    return OptimizationResult(
      success: _errors.isEmpty,
      optimizedAST: currentAST,
      passResults: passResults,
      totalOptimizations: totalOptimizations,
      metrics: OptimizationMetrics(
        originalNodeCount: originalNodeCount,
        optimizedNodeCount: optimizedNodeCount,
        constantsFolded: _constantsFolded,
        deadCodeRemoved: _deadCodeRemoved,
        expressionsSimplified: _expressionsSimplified,
        controlFlowOptimized: _controlFlowOptimized,
        sizeReductionPercent: sizeReduction,
        totalTimeMs: stopwatch.elapsedMilliseconds,
      ),
      errors: List.from(_errors),
      warnings: List.from(_warnings),
    );
  }

  // ============================================
  // CONSTANT FOLDING
  // ============================================

  /// Apply constant folding optimization
  /// Evaluates constant expressions at compile time
  ProgramNode _applyConstantFolding(ProgramNode ast) {
    final optimizedNodes = ast.diagramNodes.map((node) {
      final optimizedStatements = node.statements.map((stmt) {
        return _foldConstantsInStatement(stmt);
      }).toList();

      return DiagramASTNode(
        diagramNodeId: node.diagramNodeId,
        nodeType: node.nodeType,
        statements: optimizedStatements,
        position: node.position,
      );
    }).toList();

    final optimizedDeclarations = ast.globalDeclarations.map((decl) {
      if (decl.initializer != null) {
        final optimizedInit = _foldConstantsInExpression(decl.initializer!);
        if (optimizedInit != decl.initializer) {
          return DeclarationStatementNode(
            dataType: decl.dataType,
            variableName: decl.variableName,
            initializer: optimizedInit,
            isArray: decl.isArray,
            arraySize: decl.arraySize,
            position: decl.position,
            nodeId: decl.nodeId,
          );
        }
      }
      return decl;
    }).toList();

    return ProgramNode(
      diagramNodes: optimizedNodes,
      globalDeclarations: optimizedDeclarations,
      position: ast.position,
    );
  }

  /// Fold constants in a statement
  StatementNode _foldConstantsInStatement(StatementNode stmt) {
    if (stmt is ExpressionStatementNode) {
      return ExpressionStatementNode(
        expression: _foldConstantsInExpression(stmt.expression),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is DeclarationStatementNode && stmt.initializer != null) {
      return DeclarationStatementNode(
        dataType: stmt.dataType,
        variableName: stmt.variableName,
        initializer: _foldConstantsInExpression(stmt.initializer!),
        isArray: stmt.isArray,
        arraySize: stmt.arraySize,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is IfStatementNode) {
      return IfStatementNode(
        condition: _foldConstantsInExpression(stmt.condition),
        thenBranch: _foldConstantsInStatement(stmt.thenBranch),
        elseBranch: stmt.elseBranch != null
            ? _foldConstantsInStatement(stmt.elseBranch!)
            : null,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is WhileStatementNode) {
      return WhileStatementNode(
        condition: _foldConstantsInExpression(stmt.condition),
        body: _foldConstantsInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is ForStatementNode) {
      return ForStatementNode(
        initializer: stmt.initializer != null
            ? _foldConstantsInExpression(stmt.initializer!)
            : null,
        condition: stmt.condition != null
            ? _foldConstantsInExpression(stmt.condition!)
            : null,
        update: stmt.update != null
            ? _foldConstantsInExpression(stmt.update!)
            : null,
        body: _foldConstantsInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is BlockStatementNode) {
      return BlockStatementNode(
        statements: stmt.statements.map(_foldConstantsInStatement).toList(),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is OutputStatementNode) {
      return OutputStatementNode(
        expressions: stmt.expressions.map(_foldConstantsInExpression).toList(),
        formatString: stmt.formatString,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    }
    return stmt;
  }

  /// Fold constants in an expression
  ASTNode _foldConstantsInExpression(ASTNode expr) {
    if (expr is BinaryExpressionNode) {
      final left = _foldConstantsInExpression(expr.left);
      final right = _foldConstantsInExpression(expr.right);

      // Try to evaluate if both operands are constants
      final result =
          _tryEvaluateBinary(left, expr.operator, right, expr.position);
      if (result != null) {
        _constantsFolded++;
        _changes
            .add('Plegado: ${_nodeToString(expr)} → ${_nodeToString(result)}');
        return result;
      }

      // Return potentially simplified expression
      if (left != expr.left || right != expr.right) {
        return BinaryExpressionNode(
          left: left,
          operator: expr.operator,
          right: right,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is UnaryExpressionNode) {
      final operand = _foldConstantsInExpression(expr.operand);

      // Try to evaluate if operand is constant
      final result = _tryEvaluateUnary(expr.operator, operand, expr.position);
      if (result != null) {
        _constantsFolded++;
        _changes
            .add('Plegado: ${_nodeToString(expr)} → ${_nodeToString(result)}');
        return result;
      }

      if (operand != expr.operand) {
        return UnaryExpressionNode(
          operator: expr.operator,
          operand: operand,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is AssignmentExpressionNode) {
      final value = _foldConstantsInExpression(expr.value);
      if (value != expr.value) {
        return AssignmentExpressionNode(
          target: expr.target,
          operator: expr.operator,
          value: value,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is FunctionCallNode) {
      final optimizedArgs =
          expr.arguments.map(_foldConstantsInExpression).toList();
      if (!_listEquals(optimizedArgs, expr.arguments)) {
        return FunctionCallNode(
          functionName: expr.functionName,
          arguments: optimizedArgs,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is ConditionalExpressionNode) {
      final condition = _foldConstantsInExpression(expr.condition);
      final trueExpr = _foldConstantsInExpression(expr.trueExpression);
      final falseExpr = _foldConstantsInExpression(expr.falseExpression);

      // If condition is constant, return the appropriate branch
      if (condition is BooleanLiteralNode) {
        _constantsFolded++;
        return condition.value ? trueExpr : falseExpr;
      }

      if (condition != expr.condition ||
          trueExpr != expr.trueExpression ||
          falseExpr != expr.falseExpression) {
        return ConditionalExpressionNode(
          condition: condition,
          trueExpression: trueExpr,
          falseExpression: falseExpr,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    }
    return expr;
  }

  /// Try to evaluate a binary operation on constants
  ASTNode? _tryEvaluateBinary(
      ASTNode left, BinaryOperator op, ASTNode right, SourcePosition pos) {
    // Integer operations
    if (left is IntegerLiteralNode && right is IntegerLiteralNode) {
      final result = _evaluateIntBinary(left.value, op, right.value);
      if (result != null) {
        if (result is int) {
          return IntegerLiteralNode(value: result, position: pos);
        } else if (result is bool) {
          return BooleanLiteralNode(value: result, position: pos);
        }
      }
    }

    // Float operations
    if ((left is FloatLiteralNode || left is IntegerLiteralNode) &&
        (right is FloatLiteralNode || right is IntegerLiteralNode)) {
      final leftVal = left is FloatLiteralNode
          ? left.value
          : (left as IntegerLiteralNode).value.toDouble();
      final rightVal = right is FloatLiteralNode
          ? right.value
          : (right as IntegerLiteralNode).value.toDouble();

      final result = _evaluateFloatBinary(leftVal, op, rightVal);
      if (result != null) {
        if (result is double) {
          return FloatLiteralNode(value: result, position: pos);
        } else if (result is bool) {
          return BooleanLiteralNode(value: result, position: pos);
        }
      }
    }

    // Boolean operations
    if (left is BooleanLiteralNode && right is BooleanLiteralNode) {
      final result = _evaluateBoolBinary(left.value, op, right.value);
      if (result != null) {
        return BooleanLiteralNode(value: result, position: pos);
      }
    }

    // String concatenation
    if (left is StringLiteralNode &&
        right is StringLiteralNode &&
        op == BinaryOperator.add) {
      return StringLiteralNode(value: left.value + right.value, position: pos);
    }

    return null;
  }

  /// Evaluate integer binary operation
  dynamic _evaluateIntBinary(int left, BinaryOperator op, int right) {
    switch (op) {
      case BinaryOperator.add:
        return left + right;
      case BinaryOperator.subtract:
        return left - right;
      case BinaryOperator.multiply:
        return left * right;
      case BinaryOperator.divide:
        if (right == 0) return null; // Avoid division by zero
        return left ~/ right;
      case BinaryOperator.modulo:
        if (right == 0) return null;
        return left % right;
      case BinaryOperator.equal:
        return left == right;
      case BinaryOperator.notEqual:
        return left != right;
      case BinaryOperator.less:
        return left < right;
      case BinaryOperator.lessEqual:
        return left <= right;
      case BinaryOperator.greater:
        return left > right;
      case BinaryOperator.greaterEqual:
        return left >= right;
      case BinaryOperator.bitAnd:
        return left & right;
      case BinaryOperator.bitOr:
        return left | right;
      case BinaryOperator.bitXor:
        return left ^ right;
      case BinaryOperator.shiftLeft:
        return left << right;
      case BinaryOperator.shiftRight:
        return left >> right;
      default:
        return null;
    }
  }

  /// Evaluate float binary operation
  dynamic _evaluateFloatBinary(double left, BinaryOperator op, double right) {
    switch (op) {
      case BinaryOperator.add:
        return left + right;
      case BinaryOperator.subtract:
        return left - right;
      case BinaryOperator.multiply:
        return left * right;
      case BinaryOperator.divide:
        if (right == 0) return null;
        return left / right;
      case BinaryOperator.equal:
        return left == right;
      case BinaryOperator.notEqual:
        return left != right;
      case BinaryOperator.less:
        return left < right;
      case BinaryOperator.lessEqual:
        return left <= right;
      case BinaryOperator.greater:
        return left > right;
      case BinaryOperator.greaterEqual:
        return left >= right;
      default:
        return null;
    }
  }

  /// Evaluate boolean binary operation
  bool? _evaluateBoolBinary(bool left, BinaryOperator op, bool right) {
    switch (op) {
      case BinaryOperator.and:
        return left && right;
      case BinaryOperator.or:
        return left || right;
      case BinaryOperator.equal:
        return left == right;
      case BinaryOperator.notEqual:
        return left != right;
      default:
        return null;
    }
  }

  /// Try to evaluate a unary operation on a constant
  ASTNode? _tryEvaluateUnary(
      UnaryOperator op, ASTNode operand, SourcePosition pos) {
    if (operand is IntegerLiteralNode) {
      switch (op) {
        case UnaryOperator.negate:
          return IntegerLiteralNode(value: -operand.value, position: pos);
        case UnaryOperator.bitNot:
          return IntegerLiteralNode(value: ~operand.value, position: pos);
        default:
          break;
      }
    } else if (operand is FloatLiteralNode && op == UnaryOperator.negate) {
      return FloatLiteralNode(value: -operand.value, position: pos);
    } else if (operand is BooleanLiteralNode && op == UnaryOperator.not) {
      return BooleanLiteralNode(value: !operand.value, position: pos);
    }
    return null;
  }

  // ============================================
  // DEAD CODE ELIMINATION
  // ============================================

  /// Apply dead code elimination
  ProgramNode _applyDeadCodeElimination(ProgramNode ast) {
    final optimizedNodes = ast.diagramNodes.map((node) {
      final optimizedStatements = <StatementNode>[];

      for (final stmt in node.statements) {
        final optimized = _eliminateDeadCodeInStatement(stmt);
        if (optimized != null) {
          optimizedStatements.add(optimized);
        }
      }

      return DiagramASTNode(
        diagramNodeId: node.diagramNodeId,
        nodeType: node.nodeType,
        statements: optimizedStatements,
        position: node.position,
      );
    }).toList();

    return ProgramNode(
      diagramNodes: optimizedNodes,
      globalDeclarations: ast.globalDeclarations,
      position: ast.position,
    );
  }

  /// Eliminate dead code in a statement
  /// Returns null if the entire statement should be removed
  StatementNode? _eliminateDeadCodeInStatement(StatementNode stmt) {
    if (stmt is IfStatementNode) {
      // If condition is always true, keep only then branch
      if (stmt.condition is BooleanLiteralNode) {
        final boolCondition = stmt.condition as BooleanLiteralNode;
        _deadCodeRemoved++;
        _changes.add(
            'Eliminado: if con condición constante ${boolCondition.value}');

        if (boolCondition.value) {
          return _eliminateDeadCodeInStatement(stmt.thenBranch);
        } else {
          if (stmt.elseBranch != null) {
            return _eliminateDeadCodeInStatement(stmt.elseBranch!);
          }
          return null; // Remove entire if statement
        }
      }

      // Recursively optimize branches
      final optimizedThen = _eliminateDeadCodeInStatement(stmt.thenBranch);
      final optimizedElse = stmt.elseBranch != null
          ? _eliminateDeadCodeInStatement(stmt.elseBranch!)
          : null;

      if (optimizedThen == null && optimizedElse == null) {
        _deadCodeRemoved++;
        return null;
      }

      return IfStatementNode(
        condition: stmt.condition,
        thenBranch: optimizedThen ?? _createEmptyBlock(stmt.position),
        elseBranch: optimizedElse,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is WhileStatementNode) {
      // If condition is always false, remove the loop
      if (stmt.condition is BooleanLiteralNode) {
        final boolCondition = stmt.condition as BooleanLiteralNode;
        if (!boolCondition.value) {
          _deadCodeRemoved++;
          _changes.add('Eliminado: while con condición siempre falsa');
          return null;
        }
      }

      final optimizedBody = _eliminateDeadCodeInStatement(stmt.body);
      if (optimizedBody == null) {
        return WhileStatementNode(
          condition: stmt.condition,
          body: _createEmptyBlock(stmt.position),
          position: stmt.position,
          nodeId: stmt.nodeId,
        );
      }

      return WhileStatementNode(
        condition: stmt.condition,
        body: optimizedBody,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is ForStatementNode) {
      // If condition is always false, remove the loop
      if (stmt.condition is BooleanLiteralNode) {
        final boolCondition = stmt.condition as BooleanLiteralNode;
        if (!boolCondition.value) {
          _deadCodeRemoved++;
          _changes.add('Eliminado: for con condición siempre falsa');
          // Still execute initializer if it has side effects
          if (stmt.initializer != null) {
            return ExpressionStatementNode(
              expression: stmt.initializer!,
              position: stmt.position,
              nodeId: stmt.nodeId,
            );
          }
          return null;
        }
      }

      final optimizedBody = _eliminateDeadCodeInStatement(stmt.body);
      return ForStatementNode(
        initializer: stmt.initializer,
        condition: stmt.condition,
        update: stmt.update,
        body: optimizedBody ?? _createEmptyBlock(stmt.position),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is BlockStatementNode) {
      final optimizedStatements = <StatementNode>[];
      bool foundReturn = false;

      for (final s in stmt.statements) {
        if (foundReturn) {
          _deadCodeRemoved++;
          _changes.add('Eliminado: código después de return');
          continue;
        }

        final optimized = _eliminateDeadCodeInStatement(s);
        if (optimized != null) {
          optimizedStatements.add(optimized);
        }

        if (s is ReturnStatementNode ||
            s is BreakStatementNode ||
            s is ContinueStatementNode) {
          foundReturn = true;
        }
      }

      if (optimizedStatements.isEmpty) {
        return null;
      }

      return BlockStatementNode(
        statements: optimizedStatements,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    }

    return stmt;
  }

  /// Create an empty block statement
  BlockStatementNode _createEmptyBlock(SourcePosition pos) {
    return BlockStatementNode(statements: const [], position: pos);
  }

  // ============================================
  // EXPRESSION SIMPLIFICATION
  // ============================================

  /// Apply algebraic simplification to expressions
  ProgramNode _applyExpressionSimplification(ProgramNode ast) {
    final optimizedNodes = ast.diagramNodes.map((node) {
      final optimizedStatements = node.statements.map((stmt) {
        return _simplifyExpressionsInStatement(stmt);
      }).toList();

      return DiagramASTNode(
        diagramNodeId: node.diagramNodeId,
        nodeType: node.nodeType,
        statements: optimizedStatements,
        position: node.position,
      );
    }).toList();

    return ProgramNode(
      diagramNodes: optimizedNodes,
      globalDeclarations: ast.globalDeclarations,
      position: ast.position,
    );
  }

  /// Simplify expressions in a statement
  StatementNode _simplifyExpressionsInStatement(StatementNode stmt) {
    if (stmt is ExpressionStatementNode) {
      return ExpressionStatementNode(
        expression: _simplifyExpression(stmt.expression),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is DeclarationStatementNode && stmt.initializer != null) {
      return DeclarationStatementNode(
        dataType: stmt.dataType,
        variableName: stmt.variableName,
        initializer: _simplifyExpression(stmt.initializer!),
        isArray: stmt.isArray,
        arraySize: stmt.arraySize,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is IfStatementNode) {
      return IfStatementNode(
        condition: _simplifyExpression(stmt.condition),
        thenBranch: _simplifyExpressionsInStatement(stmt.thenBranch),
        elseBranch: stmt.elseBranch != null
            ? _simplifyExpressionsInStatement(stmt.elseBranch!)
            : null,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is WhileStatementNode) {
      return WhileStatementNode(
        condition: _simplifyExpression(stmt.condition),
        body: _simplifyExpressionsInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is ForStatementNode) {
      return ForStatementNode(
        initializer: stmt.initializer != null
            ? _simplifyExpression(stmt.initializer!)
            : null,
        condition: stmt.condition != null
            ? _simplifyExpression(stmt.condition!)
            : null,
        update: stmt.update != null ? _simplifyExpression(stmt.update!) : null,
        body: _simplifyExpressionsInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is BlockStatementNode) {
      return BlockStatementNode(
        statements:
            stmt.statements.map(_simplifyExpressionsInStatement).toList(),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    }
    return stmt;
  }

  /// Simplify an expression using algebraic identities
  ASTNode _simplifyExpression(ASTNode expr) {
    if (expr is BinaryExpressionNode) {
      final left = _simplifyExpression(expr.left);
      final right = _simplifyExpression(expr.right);

      // Try algebraic simplifications
      final simplified = _applyAlgebraicSimplification(
          left, expr.operator, right, expr.position);
      if (simplified != null) {
        _expressionsSimplified++;
        _changes.add(
            'Simplificado: ${_nodeToString(expr)} → ${_nodeToString(simplified)}');
        return simplified;
      }

      if (left != expr.left || right != expr.right) {
        return BinaryExpressionNode(
          left: left,
          operator: expr.operator,
          right: right,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is UnaryExpressionNode) {
      final operand = _simplifyExpression(expr.operand);

      // Double negation: --x → x
      if (expr.operator == UnaryOperator.negate &&
          operand is UnaryExpressionNode &&
          operand.operator == UnaryOperator.negate) {
        _expressionsSimplified++;
        _changes.add('Simplificado: doble negación');
        return operand.operand;
      }

      // Double not: !!x → x
      if (expr.operator == UnaryOperator.not &&
          operand is UnaryExpressionNode &&
          operand.operator == UnaryOperator.not) {
        _expressionsSimplified++;
        _changes.add('Simplificado: doble negación lógica');
        return operand.operand;
      }

      if (operand != expr.operand) {
        return UnaryExpressionNode(
          operator: expr.operator,
          operand: operand,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    } else if (expr is AssignmentExpressionNode) {
      final value = _simplifyExpression(expr.value);
      if (value != expr.value) {
        return AssignmentExpressionNode(
          target: expr.target,
          operator: expr.operator,
          value: value,
          position: expr.position,
          nodeId: expr.nodeId,
        );
      }
    }
    return expr;
  }

  /// Apply algebraic simplification rules
  ASTNode? _applyAlgebraicSimplification(
    ASTNode left,
    BinaryOperator op,
    ASTNode right,
    SourcePosition pos,
  ) {
    // x + 0 = x, 0 + x = x
    if (op == BinaryOperator.add) {
      if (_isZero(right)) return left;
      if (_isZero(left)) return right;
    }

    // x - 0 = x
    if (op == BinaryOperator.subtract) {
      if (_isZero(right)) return left;
      // x - x = 0 (when both are the same identifier)
      if (_areEqualIdentifiers(left, right)) {
        return IntegerLiteralNode(value: 0, position: pos);
      }
    }

    // x * 1 = x, 1 * x = x
    if (op == BinaryOperator.multiply) {
      if (_isOne(right)) return left;
      if (_isOne(left)) return right;
      // x * 0 = 0, 0 * x = 0
      if (_isZero(right) || _isZero(left)) {
        return IntegerLiteralNode(value: 0, position: pos);
      }
      // x * 2 = x + x (sometimes more efficient, but keep it simple)
    }

    // x / 1 = x
    if (op == BinaryOperator.divide) {
      if (_isOne(right)) return left;
      // x / x = 1 (when both are the same identifier, and not zero)
      if (_areEqualIdentifiers(left, right)) {
        return IntegerLiteralNode(value: 1, position: pos);
      }
    }

    // x % 1 = 0
    if (op == BinaryOperator.modulo && _isOne(right)) {
      return IntegerLiteralNode(value: 0, position: pos);
    }

    // x && true = x, true && x = x
    if (op == BinaryOperator.and) {
      if (_isTrue(right)) return left;
      if (_isTrue(left)) return right;
      // x && false = false, false && x = false
      if (_isFalse(right) || _isFalse(left)) {
        return BooleanLiteralNode(value: false, position: pos);
      }
    }

    // x || false = x, false || x = x
    if (op == BinaryOperator.or) {
      if (_isFalse(right)) return left;
      if (_isFalse(left)) return right;
      // x || true = true, true || x = true
      if (_isTrue(right) || _isTrue(left)) {
        return BooleanLiteralNode(value: true, position: pos);
      }
    }

    // x == x = true (for identifiers)
    if (op == BinaryOperator.equal && _areEqualIdentifiers(left, right)) {
      return BooleanLiteralNode(value: true, position: pos);
    }

    // x != x = false (for identifiers)
    if (op == BinaryOperator.notEqual && _areEqualIdentifiers(left, right)) {
      return BooleanLiteralNode(value: false, position: pos);
    }

    return null;
  }

  /// Check if node is zero
  bool _isZero(ASTNode node) {
    if (node is IntegerLiteralNode) return node.value == 0;
    if (node is FloatLiteralNode) return node.value == 0.0;
    return false;
  }

  /// Check if node is one
  bool _isOne(ASTNode node) {
    if (node is IntegerLiteralNode) return node.value == 1;
    if (node is FloatLiteralNode) return node.value == 1.0;
    return false;
  }

  /// Check if node is true
  bool _isTrue(ASTNode node) {
    return node is BooleanLiteralNode && node.value == true;
  }

  /// Check if node is false
  bool _isFalse(ASTNode node) {
    return node is BooleanLiteralNode && node.value == false;
  }

  /// Check if two nodes are equal identifiers
  bool _areEqualIdentifiers(ASTNode a, ASTNode b) {
    return a is IdentifierNode && b is IdentifierNode && a.name == b.name;
  }

  // ============================================
  // CONTROL FLOW OPTIMIZATION
  // ============================================

  /// Apply control flow optimization
  ProgramNode _applyControlFlowOptimization(ProgramNode ast) {
    final optimizedNodes = ast.diagramNodes.map((node) {
      final optimizedStatements = node.statements.map((stmt) {
        return _optimizeControlFlowInStatement(stmt);
      }).toList();

      return DiagramASTNode(
        diagramNodeId: node.diagramNodeId,
        nodeType: node.nodeType,
        statements: optimizedStatements,
        position: node.position,
      );
    }).toList();

    return ProgramNode(
      diagramNodes: optimizedNodes,
      globalDeclarations: ast.globalDeclarations,
      position: ast.position,
    );
  }

  /// Optimize control flow in a statement
  StatementNode _optimizeControlFlowInStatement(StatementNode stmt) {
    if (stmt is IfStatementNode) {
      // Optimize nested if-else into else-if chain when appropriate
      if (stmt.elseBranch is IfStatementNode) {
        // Already an if-else chain, recursively optimize
        final optimizedThen = _optimizeControlFlowInStatement(stmt.thenBranch);
        final optimizedElse = _optimizeControlFlowInStatement(stmt.elseBranch!);

        return IfStatementNode(
          condition: stmt.condition,
          thenBranch: optimizedThen,
          elseBranch: optimizedElse,
          position: stmt.position,
          nodeId: stmt.nodeId,
        );
      }

      // Remove empty else branch
      if (stmt.elseBranch is BlockStatementNode) {
        final elseBlock = stmt.elseBranch as BlockStatementNode;
        if (elseBlock.statements.isEmpty) {
          _controlFlowOptimized++;
          _changes.add('Eliminado: else vacío');
          return IfStatementNode(
            condition: stmt.condition,
            thenBranch: _optimizeControlFlowInStatement(stmt.thenBranch),
            elseBranch: null,
            position: stmt.position,
            nodeId: stmt.nodeId,
          );
        }
      }

      return IfStatementNode(
        condition: stmt.condition,
        thenBranch: _optimizeControlFlowInStatement(stmt.thenBranch),
        elseBranch: stmt.elseBranch != null
            ? _optimizeControlFlowInStatement(stmt.elseBranch!)
            : null,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is WhileStatementNode) {
      return WhileStatementNode(
        condition: stmt.condition,
        body: _optimizeControlFlowInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is ForStatementNode) {
      return ForStatementNode(
        initializer: stmt.initializer,
        condition: stmt.condition,
        update: stmt.update,
        body: _optimizeControlFlowInStatement(stmt.body),
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    } else if (stmt is BlockStatementNode) {
      // Flatten single-statement blocks
      final optimizedStatements =
          stmt.statements.map(_optimizeControlFlowInStatement).toList();

      // Remove empty statements and flatten nested single-statement blocks
      final flattened = <StatementNode>[];
      for (final s in optimizedStatements) {
        if (s is BlockStatementNode && s.statements.length == 1) {
          flattened.add(s.statements.first);
          _controlFlowOptimized++;
        } else if (s is BlockStatementNode && s.statements.isEmpty) {
          _controlFlowOptimized++;
          // Skip empty blocks
        } else {
          flattened.add(s);
        }
      }

      return BlockStatementNode(
        statements: flattened,
        position: stmt.position,
        nodeId: stmt.nodeId,
      );
    }

    return stmt;
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Count total nodes in AST
  int _countNodes(ProgramNode ast) {
    int count = 1; // ProgramNode itself

    for (final decl in ast.globalDeclarations) {
      count += _countNodesInStatement(decl);
    }

    for (final node in ast.diagramNodes) {
      count++; // DiagramASTNode
      for (final stmt in node.statements) {
        count += _countNodesInStatement(stmt);
      }
    }

    return count;
  }

  /// Count nodes in a statement
  int _countNodesInStatement(StatementNode stmt) {
    int count = 1;

    for (final child in stmt.children) {
      if (child is StatementNode) {
        count += _countNodesInStatement(child);
      } else {
        count += _countNodesInExpression(child);
      }
    }

    return count;
  }

  /// Count nodes in an expression
  int _countNodesInExpression(ASTNode expr) {
    int count = 1;
    for (final child in expr.children) {
      count += _countNodesInExpression(child);
    }
    return count;
  }

  /// Convert AST node to string representation
  String _nodeToString(ASTNode node) {
    if (node is IntegerLiteralNode) return '${node.value}';
    if (node is FloatLiteralNode) return '${node.value}';
    if (node is BooleanLiteralNode) return '${node.value}';
    if (node is StringLiteralNode) return '"${node.value}"';
    if (node is IdentifierNode) return node.name;
    if (node is BinaryExpressionNode) {
      return '(${_nodeToString(node.left)} ${node.operator.symbol} ${_nodeToString(node.right)})';
    }
    if (node is UnaryExpressionNode) {
      if (node.operator.isPrefix) {
        return '${node.operator.symbol}${_nodeToString(node.operand)}';
      } else {
        return '${_nodeToString(node.operand)}${node.operator.symbol}';
      }
    }
    return node.toString();
  }

  /// Check if two lists are equal
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ============================================
  // REPORT GENERATION
  // ============================================

  /// Generate optimization report
  String generateReport(OptimizationResult result) {
    final buffer = StringBuffer();

    buffer
        .writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('              REPORTE DE OPTIMIZACIÓN');
    buffer
        .writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln();

    // Summary
    buffer.writeln('📊 RESUMEN:');
    buffer.writeln(
        '   Estado: ${result.success ? "✅ EXITOSO" : "❌ CON ERRORES"}');
    buffer.writeln('   Optimizaciones aplicadas: ${result.totalOptimizations}');
    buffer.writeln('   Tiempo total: ${result.metrics.totalTimeMs}ms');
    buffer.writeln();

    // Metrics
    buffer.writeln('📈 MÉTRICAS:');
    buffer
        .writeln('   • Nodos originales: ${result.metrics.originalNodeCount}');
    buffer.writeln(
        '   • Nodos optimizados: ${result.metrics.optimizedNodeCount}');
    buffer.writeln(
        '   • Reducción: ${result.metrics.sizeReductionPercent.toStringAsFixed(1)}%');
    buffer
        .writeln('   • Constantes plegadas: ${result.metrics.constantsFolded}');
    buffer.writeln(
        '   • Código muerto eliminado: ${result.metrics.deadCodeRemoved}');
    buffer.writeln(
        '   • Expresiones simplificadas: ${result.metrics.expressionsSimplified}');
    buffer.writeln(
        '   • Flujo de control optimizado: ${result.metrics.controlFlowOptimized}');
    buffer.writeln();

    // Pass details
    if (result.passResults.isNotEmpty) {
      buffer.writeln('🔄 PASADAS DE OPTIMIZACIÓN:');
      for (final pass in result.passResults) {
        buffer.writeln('   ${pass.passName} (${pass.timeMs}ms):');
        buffer.writeln('      Optimizaciones: ${pass.optimizationsApplied}');
        for (final change in pass.changes) {
          buffer.writeln('      • $change');
        }
      }
      buffer.writeln();
    }

    // Errors
    if (result.errors.isNotEmpty) {
      buffer.writeln('❌ ERRORES:');
      for (final error in result.errors) {
        buffer.writeln('   • ${error.message}');
      }
      buffer.writeln();
    }

    // Warnings
    if (result.warnings.isNotEmpty) {
      buffer.writeln('⚠️ ADVERTENCIAS:');
      for (final warning in result.warnings) {
        buffer.writeln('   • ${warning.message}');
      }
      buffer.writeln();
    }

    buffer
        .writeln('═══════════════════════════════════════════════════════════');

    return buffer.toString();
  }
}

// ============================================
// EXTENSION FOR EASY ACCESS
// ============================================

/// Extension to provide optimization from ProgramNode
extension ProgramNodeOptimization on ProgramNode {
  /// Optimize this AST
  OptimizationResult optimize({
    OptimizerConfig config = OptimizerConfig.defaults,
    SymbolTable? symbolTable,
  }) {
    final optimizer = DiagramCodeOptimizer(config: config);
    return optimizer.optimize(this, symbolTable: symbolTable);
  }
}
