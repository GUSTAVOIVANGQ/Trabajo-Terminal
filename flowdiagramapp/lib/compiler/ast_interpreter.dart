/// AST Interpreter for FlowCode Diagram Compiler
/// Executes the AST directly in pure Dart without any native dependencies.
///
/// This is a new Visitor that walks the AST and executes the program logic
/// step by step, maintaining a variable table in memory.

import 'dart:async';
import 'dart:math' as math;
import 'ast_nodes.dart';
import 'symbol_table.dart';

// ─── Execution exceptions ───────────────────────────────────────────────────

/// Signals that the interpreter needs stdin input.
class InterpreterInputRequest {
  final String variableName;
  final DataType expectedType;
  InterpreterInputRequest(this.variableName, this.expectedType);
}

/// Signals a break statement inside a loop.
class _BreakSignal implements Exception {}

/// Signals a continue statement inside a loop.
class _ContinueSignal implements Exception {}

/// Signals a return statement.
class _ReturnSignal implements Exception {
  final dynamic value;
  _ReturnSignal(this.value);
}

/// Runtime error during interpretation.
class InterpreterError implements Exception {
  final String message;
  final String? nodeId;
  InterpreterError(this.message, {this.nodeId});

  @override
  String toString() => 'InterpreterError: $message';
}

/// The reason the interpreter stopped.
enum StopReason { completed, error, iterationLimit, timeout, cancelled }

/// Result of an interpretation run.
class InterpreterResult {
  final List<String> output;
  final int steps;
  final int elapsedMs;
  final StopReason stopReason;
  final String? errorMessage;
  final Map<String, dynamic> finalVariables;

  const InterpreterResult({
    required this.output,
    required this.steps,
    required this.elapsedMs,
    required this.stopReason,
    this.errorMessage,
    this.finalVariables = const {},
  });
}

// ─── Callbacks for communication with the UI ────────────────────────────────

typedef OnOutputCallback = void Function(String text);
typedef OnInputRequestCallback = Future<String> Function(
    String variableName, DataType expectedType);

// ─── The Interpreter ────────────────────────────────────────────────────────

class ASTInterpreter implements ASTVisitor<dynamic> {
  /// Variable table: name → current value
  final Map<String, dynamic> _variables = {};

  /// Variable types: name → DataType
  final Map<String, DataType> _variableTypes = {};

  /// Output lines produced by the program
  final List<String> _outputLines = [];

  /// Step counter for infinite-loop protection
  int _stepCount = 0;

  /// Maximum allowed steps (default 10,000)
  final int maxSteps;

  /// Maximum execution time
  final Duration maxDuration;

  /// Whether cancellation has been requested
  bool _cancelled = false;

  /// Stopwatch for timeout
  final Stopwatch _stopwatch = Stopwatch();

  /// Callback when the program produces output
  OnOutputCallback? onOutput;

  /// Callback when the program requests input
  OnInputRequestCallback? onInput;

  ASTInterpreter({
    this.maxSteps = 10000,
    this.maxDuration = const Duration(seconds: 5),
    this.onOutput,
    this.onInput,
  });

  /// Cancel the execution.
  void cancel() => _cancelled = true;

  /// Reset the interpreter state.
  void reset() {
    _variables.clear();
    _variableTypes.clear();
    _outputLines.clear();
    _stepCount = 0;
    _cancelled = false;
  }

  /// Execute a ProgramNode and return the result.
  Future<InterpreterResult> execute(ProgramNode program) async {
    reset();
    _stopwatch
      ..reset()
      ..start();

    StopReason stopReason = StopReason.completed;
    String? errorMessage;

    try {
      // Process global declarations first
      for (final decl in program.globalDeclarations) {
        _tick();
        await decl.accept(this);
      }

      // Process diagram nodes in order
      for (final node in program.diagramNodes) {
        _tick();
        await node.accept(this);
      }
    } on InterpreterError catch (e) {
      stopReason = StopReason.error;
      errorMessage = e.message;
    } on _IterationLimitException {
      stopReason = StopReason.iterationLimit;
      errorMessage =
          'El programa superó $maxSteps pasos. Posible bucle infinito.';
    } on _TimeoutException {
      stopReason = StopReason.timeout;
      errorMessage =
          'El programa tardó más de ${maxDuration.inSeconds} segundos y fue detenido.';
    } on _CancelledException {
      stopReason = StopReason.cancelled;
      errorMessage = 'Ejecución cancelada por el usuario.';
    } on _ReturnSignal {
      // Normal return from main — program completed
    } catch (e) {
      stopReason = StopReason.error;
      errorMessage = 'Error inesperado: $e';
    } finally {
      _stopwatch.stop();
    }

    return InterpreterResult(
      output: List.from(_outputLines),
      steps: _stepCount,
      elapsedMs: _stopwatch.elapsedMilliseconds,
      stopReason: stopReason,
      errorMessage: errorMessage,
      finalVariables: Map.from(_variables),
    );
  }

  /// Check limits before each step.
  void _tick() {
    _stepCount++;
    if (_cancelled) throw _CancelledException();
    if (_stepCount > maxSteps) throw _IterationLimitException();
    if (_stopwatch.elapsed > maxDuration) throw _TimeoutException();
  }

  /// Emit a line of output.
  void _emit(String text) {
    _outputLines.add(text);
    onOutput?.call(text);
  }

  /// Get the default value for a data type.
  dynamic _defaultValue(DataType type) {
    switch (type) {
      case DataType.integer:
        return 0;
      case DataType.float:
      case DataType.double_:
        return 0.0;
      case DataType.char:
        return '\x00';
      case DataType.string:
        return '';
      case DataType.boolean:
        return false;
      default:
        return 0;
    }
  }

  /// Convert a value to the expected type.
  dynamic _coerce(dynamic value, DataType targetType) {
    if (value == null) return _defaultValue(targetType);
    switch (targetType) {
      case DataType.integer:
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is bool) return value ? 1 : 0;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      case DataType.float:
      case DataType.double_:
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      case DataType.char:
        if (value is String && value.isNotEmpty) return value[0];
        if (value is int) return String.fromCharCode(value);
        return '\x00';
      case DataType.string:
        return value.toString();
      case DataType.boolean:
        if (value is bool) return value;
        if (value is int) return value != 0;
        if (value is double) return value != 0.0;
        return false;
      default:
        return value;
    }
  }

  /// Check if a value is truthy (C-style).
  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is double) return value != 0.0;
    if (value is String) return value.isNotEmpty;
    return true;
  }

  // ════════════════════════════════════════════════════════════
  // VISITOR IMPLEMENTATIONS
  // ════════════════════════════════════════════════════════════

  @override
  dynamic visitProgram(ProgramNode node) async {
    for (final decl in node.globalDeclarations) {
      _tick();
      await decl.accept(this);
    }
    for (final diagNode in node.diagramNodes) {
      _tick();
      await diagNode.accept(this);
    }
    return null;
  }

  @override
  dynamic visitDiagramNode(DiagramASTNode node) async {
    for (final stmt in node.statements) {
      _tick();
      await stmt.accept(this);
    }
    return null;
  }

  // ── Literals ──────────────────────────────────────────────────────────────

  @override
  dynamic visitIntegerLiteral(IntegerLiteralNode node) => node.value;

  @override
  dynamic visitFloatLiteral(FloatLiteralNode node) => node.value;

  @override
  dynamic visitStringLiteral(StringLiteralNode node) => node.value;

  @override
  dynamic visitCharLiteral(CharLiteralNode node) => node.value;

  @override
  dynamic visitBooleanLiteral(BooleanLiteralNode node) => node.value;

  // ── Identifier ────────────────────────────────────────────────────────────

  @override
  dynamic visitIdentifier(IdentifierNode node) {
    if (!_variables.containsKey(node.name)) {
      throw InterpreterError(
        'Variable "${node.name}" no está declarada.',
        nodeId: node.nodeId,
      );
    }
    return _variables[node.name];
  }

  // ── Binary Expression ─────────────────────────────────────────────────────

  @override
  dynamic visitBinaryExpression(BinaryExpressionNode node) async {
    _tick();
    final left = await node.left.accept(this);
    final right = await node.right.accept(this);

    // Promote to double if either operand is double
    final useDouble = left is double || right is double;

    switch (node.operator) {
      case BinaryOperator.add:
        if (left is String || right is String) {
          return '$left$right';
        }
        return useDouble
            ? (left as num).toDouble() + (right as num).toDouble()
            : (left as num).toInt() + (right as num).toInt();
      case BinaryOperator.subtract:
        return useDouble
            ? (left as num).toDouble() - (right as num).toDouble()
            : (left as num).toInt() - (right as num).toInt();
      case BinaryOperator.multiply:
        return useDouble
            ? (left as num).toDouble() * (right as num).toDouble()
            : (left as num).toInt() * (right as num).toInt();
      case BinaryOperator.divide:
        if (right is num && right == 0) {
          throw InterpreterError(
            'División entre cero.',
            nodeId: node.nodeId,
          );
        }
        return useDouble
            ? (left as num).toDouble() / (right as num).toDouble()
            : (left as num).toInt() ~/ (right as num).toInt();
      case BinaryOperator.modulo:
        if (right is num && right == 0) {
          throw InterpreterError(
            'Módulo entre cero.',
            nodeId: node.nodeId,
          );
        }
        return (left as num).toInt() % (right as num).toInt();
      case BinaryOperator.equal:
        return left == right;
      case BinaryOperator.notEqual:
        return left != right;
      case BinaryOperator.less:
        return (left as Comparable).compareTo(right as Comparable) < 0;
      case BinaryOperator.lessEqual:
        return (left as Comparable).compareTo(right as Comparable) <= 0;
      case BinaryOperator.greater:
        return (left as Comparable).compareTo(right as Comparable) > 0;
      case BinaryOperator.greaterEqual:
        return (left as Comparable).compareTo(right as Comparable) >= 0;
      case BinaryOperator.and:
        return _isTruthy(left) && _isTruthy(right);
      case BinaryOperator.or:
        return _isTruthy(left) || _isTruthy(right);
      case BinaryOperator.bitAnd:
        return (left as int) & (right as int);
      case BinaryOperator.bitOr:
        return (left as int) | (right as int);
      case BinaryOperator.bitXor:
        return (left as int) ^ (right as int);
      case BinaryOperator.shiftLeft:
        return (left as int) << (right as int);
      case BinaryOperator.shiftRight:
        return (left as int) >> (right as int);
    }
  }

  // ── Unary Expression ──────────────────────────────────────────────────────

  @override
  dynamic visitUnaryExpression(UnaryExpressionNode node) async {
    _tick();

    switch (node.operator) {
      case UnaryOperator.negate:
        final val = await node.operand.accept(this);
        return val is double ? -val : -(val as int);
      case UnaryOperator.not:
        final val = await node.operand.accept(this);
        return !_isTruthy(val);
      case UnaryOperator.bitNot:
        final val = await node.operand.accept(this);
        return ~(val as int);
      case UnaryOperator.preIncrement:
        final name = _getIdentifierName(node.operand);
        _variables[name] = (_variables[name] as num) + 1;
        return _variables[name];
      case UnaryOperator.preDecrement:
        final name = _getIdentifierName(node.operand);
        _variables[name] = (_variables[name] as num) - 1;
        return _variables[name];
      case UnaryOperator.postIncrement:
        final name = _getIdentifierName(node.operand);
        final old = _variables[name];
        _variables[name] = (old as num) + 1;
        return old;
      case UnaryOperator.postDecrement:
        final name = _getIdentifierName(node.operand);
        final old = _variables[name];
        _variables[name] = (old as num) - 1;
        return old;
      case UnaryOperator.addressOf:
      case UnaryOperator.dereference:
        throw InterpreterError(
          'Punteros no soportados en el intérprete.',
          nodeId: node.nodeId,
        );
    }
  }

  String _getIdentifierName(ASTNode node) {
    if (node is IdentifierNode) return node.name;
    throw InterpreterError('Se esperaba un identificador.');
  }

  // ── Assignment ────────────────────────────────────────────────────────────

  @override
  dynamic visitAssignmentExpression(AssignmentExpressionNode node) async {
    _tick();
    final name = _getIdentifierName(node.target);
    dynamic value = await node.value.accept(this);

    // Coerce to target type if known
    if (_variableTypes.containsKey(name)) {
      value = _coerce(value, _variableTypes[name]!);
    }

    switch (node.operator) {
      case AssignmentOperator.assign:
        _variables[name] = value;
      case AssignmentOperator.addAssign:
        _variables[name] = (_variables[name] as num) + (value as num);
      case AssignmentOperator.subtractAssign:
        _variables[name] = (_variables[name] as num) - (value as num);
      case AssignmentOperator.multiplyAssign:
        _variables[name] = (_variables[name] as num) * (value as num);
      case AssignmentOperator.divideAssign:
        if (value == 0) {
          throw InterpreterError('División entre cero.', nodeId: node.nodeId);
        }
        final cur = _variables[name];
        if (cur is double || value is double) {
          _variables[name] = (cur as num).toDouble() / (value as num).toDouble();
        } else {
          _variables[name] = (cur as int) ~/ (value as int);
        }
      case AssignmentOperator.moduloAssign:
        if (value == 0) {
          throw InterpreterError('Módulo entre cero.', nodeId: node.nodeId);
        }
        _variables[name] = (_variables[name] as int) % (value as int);
    }
    return _variables[name];
  }

  // ── Conditional Expression ────────────────────────────────────────────────

  @override
  dynamic visitConditionalExpression(ConditionalExpressionNode node) async {
    _tick();
    final cond = await node.condition.accept(this);
    return _isTruthy(cond)
        ? await node.trueExpression.accept(this)
        : await node.falseExpression.accept(this);
  }

  // ── Function Call ─────────────────────────────────────────────────────────

  @override
  dynamic visitFunctionCall(FunctionCallNode node) async {
    _tick();
    final name = node.functionName.toLowerCase();

    // Standard library functions
    switch (name) {
      case 'abs':
        final arg = await node.arguments[0].accept(this);
        return (arg as num).abs();
      case 'sqrt':
        final arg = await node.arguments[0].accept(this);
        return math.sqrt((arg as num).toDouble());
      case 'pow':
        final base = await node.arguments[0].accept(this);
        final exp = await node.arguments[1].accept(this);
        return math.pow((base as num).toDouble(), (exp as num).toDouble());
      case 'sin':
        final arg = await node.arguments[0].accept(this);
        return math.sin((arg as num).toDouble());
      case 'cos':
        final arg = await node.arguments[0].accept(this);
        return math.cos((arg as num).toDouble());
      case 'tan':
        final arg = await node.arguments[0].accept(this);
        return math.tan((arg as num).toDouble());
      case 'ceil':
        final arg = await node.arguments[0].accept(this);
        return (arg as num).toDouble().ceil();
      case 'floor':
        final arg = await node.arguments[0].accept(this);
        return (arg as num).toDouble().floor();
      case 'fabs':
        final arg = await node.arguments[0].accept(this);
        return (arg as num).toDouble().abs();
      case 'rand':
        return math.Random().nextInt(32768);
      case 'srand':
        // No-op for simplicity
        return null;
      case 'strlen':
        final arg = await node.arguments[0].accept(this);
        return (arg as String).length;
      case 'exit':
        final arg =
            node.arguments.isNotEmpty ? await node.arguments[0].accept(this) : 0;
        throw _ReturnSignal(arg);
      default:
        throw InterpreterError(
          'Función "$name" no soportada en el intérprete.',
          nodeId: node.nodeId,
        );
    }
  }

  // ── Array Access ──────────────────────────────────────────────────────────

  @override
  dynamic visitArrayAccess(ArrayAccessNode node) async {
    _tick();
    final array = await node.array.accept(this);
    final index = await node.index.accept(this);
    if (array is List) {
      final i = (index as num).toInt();
      if (i < 0 || i >= array.length) {
        throw InterpreterError(
          'Índice $i fuera de rango [0, ${array.length - 1}].',
          nodeId: node.nodeId,
        );
      }
      return array[i];
    }
    if (array is String) {
      final i = (index as num).toInt();
      if (i < 0 || i >= array.length) {
        throw InterpreterError(
          'Índice $i fuera de rango [0, ${array.length - 1}].',
          nodeId: node.nodeId,
        );
      }
      return array[i];
    }
    throw InterpreterError('No es un arreglo.', nodeId: node.nodeId);
  }

  // ── Array Initializer ─────────────────────────────────────────────────────

  @override
  dynamic visitArrayInitializer(ArrayInitializerNode node) async {
    final values = <dynamic>[];
    for (final elem in node.elements) {
      values.add(await elem.accept(this));
    }
    return values;
  }

  // ── Expression Statement ──────────────────────────────────────────────────

  @override
  dynamic visitExpressionStatement(ExpressionStatementNode node) async {
    _tick();
    return await node.expression.accept(this);
  }

  // ── Declaration Statement ─────────────────────────────────────────────────

  @override
  dynamic visitDeclarationStatement(DeclarationStatementNode node) async {
    _tick();
    final name = node.variableName;
    final type = node.dataType;

    _variableTypes[name] = type;

    if (node.isArray && node.arraySize != null) {
      if (node.initializer != null) {
        _variables[name] = await node.initializer!.accept(this);
      } else {
        _variables[name] =
            List.filled(node.arraySize!, _defaultValue(type));
      }
    } else if (node.initializer != null) {
      final val = await node.initializer!.accept(this);
      _variables[name] = _coerce(val, type);
    } else {
      _variables[name] = _defaultValue(type);
    }
    return null;
  }

  // ── Input Statement ───────────────────────────────────────────────────────

  @override
  dynamic visitInputStatement(InputStatementNode node) async {
    _tick();
    for (final varNode in node.variables) {
      final name = varNode.name;
      final type = _variableTypes[name] ?? DataType.integer;

      if (onInput == null) {
        throw InterpreterError(
          'El programa requiere entrada pero no hay fuente de input configurada.',
          nodeId: node.nodeId,
        );
      }

      final raw = await onInput!(name, type);
      _variables[name] = _coerce(raw, type);
    }
    return null;
  }

  // ── Output Statement ──────────────────────────────────────────────────────

  @override
  dynamic visitOutputStatement(OutputStatementNode node) async {
    _tick();
    final parts = <String>[];
    for (final expr in node.expressions) {
      final val = await expr.accept(this);
      if (val is double) {
        // Format like C printf %f (6 decimal places)
        parts.add(val.toStringAsFixed(6));
      } else {
        parts.add(val.toString());
      }
    }
    _emit(parts.join(' '));
    return null;
  }

  // ── If Statement ──────────────────────────────────────────────────────────

  @override
  dynamic visitIfStatement(IfStatementNode node) async {
    _tick();
    final cond = await node.condition.accept(this);
    if (_isTruthy(cond)) {
      await node.thenBranch.accept(this);
    } else if (node.elseBranch != null) {
      await node.elseBranch!.accept(this);
    }
    return null;
  }

  // ── While Statement ───────────────────────────────────────────────────────

  @override
  dynamic visitWhileStatement(WhileStatementNode node) async {
    while (true) {
      _tick();
      final cond = await node.condition.accept(this);
      if (!_isTruthy(cond)) break;
      try {
        await node.body.accept(this);
      } on _BreakSignal {
        break;
      } on _ContinueSignal {
        continue;
      }
    }
    return null;
  }

  // ── For Statement ─────────────────────────────────────────────────────────

  @override
  dynamic visitForStatement(ForStatementNode node) async {
    _tick();
    if (node.initializer != null) {
      await node.initializer!.accept(this);
    }
    while (true) {
      _tick();
      if (node.condition != null) {
        final cond = await node.condition!.accept(this);
        if (!_isTruthy(cond)) break;
      }
      try {
        await node.body.accept(this);
      } on _BreakSignal {
        break;
      } on _ContinueSignal {
        // fall through to update
      }
      if (node.update != null) {
        await node.update!.accept(this);
      }
    }
    return null;
  }

  // ── Do-While Statement ────────────────────────────────────────────────────

  @override
  dynamic visitDoWhileStatement(DoWhileStatementNode node) async {
    do {
      _tick();
      try {
        await node.body.accept(this);
      } on _BreakSignal {
        return null;
      } on _ContinueSignal {
        // fall through to condition
      }
      final cond = await node.condition.accept(this);
      if (!_isTruthy(cond)) break;
    } while (true);
    return null;
  }

  // ── Block Statement ───────────────────────────────────────────────────────

  @override
  dynamic visitBlockStatement(BlockStatementNode node) async {
    for (final stmt in node.statements) {
      _tick();
      await stmt.accept(this);
    }
    return null;
  }

  // ── Return Statement ──────────────────────────────────────────────────────

  @override
  dynamic visitReturnStatement(ReturnStatementNode node) async {
    _tick();
    final val = node.value != null ? await node.value!.accept(this) : null;
    throw _ReturnSignal(val);
  }

  // ── Break / Continue ──────────────────────────────────────────────────────

  @override
  dynamic visitBreakStatement(BreakStatementNode node) {
    throw _BreakSignal();
  }

  @override
  dynamic visitContinueStatement(ContinueStatementNode node) {
    throw _ContinueSignal();
  }
}

// ─── Internal exception types ───────────────────────────────────────────────

class _IterationLimitException implements Exception {}

class _TimeoutException implements Exception {}

class _CancelledException implements Exception {}
