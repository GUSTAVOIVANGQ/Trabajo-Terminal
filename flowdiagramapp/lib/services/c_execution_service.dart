import 'dart:async';

import '../compiler/ast_interpreter.dart';
import '../compiler/ast_nodes.dart';
import '../compiler/symbol_table.dart';

// ─── Events emitted by the execution service ────────────────────────────────

sealed class ExecutionEvent {}

class OutputEvent extends ExecutionEvent {
  final String text;
  OutputEvent(this.text);
}

class StdinPromptEvent extends ExecutionEvent {
  final String variableName;
  final String typeName;
  StdinPromptEvent(this.variableName, this.typeName);
}

class CompletedEvent extends ExecutionEvent {
  final int exitCode;
  final int elapsedMs;
  final int steps;
  final StopReason stopReason;
  CompletedEvent(this.exitCode, this.elapsedMs, this.steps, this.stopReason);
}

class ErrorEvent extends ExecutionEvent {
  final String message;
  ErrorEvent(this.message);
}

// ─── Execution states ───────────────────────────────────────────────────────

enum ExecutionState { idle, running, awaitingInput, completed, error }

// ─── The service ────────────────────────────────────────────────────────────

/// Service that manages the lifecycle of AST interpretation.
///
/// Runs the pure-Dart AST interpreter, receiving output events and
/// forwarding input requests to the UI.
class CExecutionService {
  ASTInterpreter? _interpreter;
  Completer<String>? _inputCompleter;

  ExecutionState _state = ExecutionState.idle;
  ExecutionState get state => _state;

  final StreamController<ExecutionEvent> _controller =
      StreamController<ExecutionEvent>.broadcast();

  Stream<ExecutionEvent> get events => _controller.stream;

  /// Start executing the given AST.
  Future<void> execute({
    required ProgramNode ast,
    int maxSteps = 10000,
    int maxDurationSeconds = 5,
  }) async {
    _state = ExecutionState.running;

    _interpreter = ASTInterpreter(
      maxSteps: maxSteps,
      maxDuration: Duration(seconds: maxDurationSeconds),
      onOutput: (text) {
        _controller.add(OutputEvent(text));
      },
      onInput: (varName, expectedType) async {
        _state = ExecutionState.awaitingInput;
        _controller.add(StdinPromptEvent(varName, expectedType.cRepresentation));
        _inputCompleter = Completer<String>();
        return _inputCompleter!.future;
      },
    );

    final result = await _interpreter!.execute(ast);

    final exitCode = result.stopReason == StopReason.completed ? 0 : 1;

    if (result.errorMessage != null) {
      _controller.add(ErrorEvent(result.errorMessage!));
    }

    _controller.add(CompletedEvent(
      exitCode,
      result.elapsedMs,
      result.steps,
      result.stopReason,
    ));

    _state = ExecutionState.completed;
    _interpreter = null;
  }

  /// Provide a line of stdin input.
  void provideInput(String value) {
    if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
      _inputCompleter!.complete(value);
      _state = ExecutionState.running;
    }
  }

  /// Cancel the currently running execution.
  void cancel() {
    _interpreter?.cancel();
    if (_inputCompleter != null && !_inputCompleter!.isCompleted) {
      _inputCompleter!.completeError(Exception('Cancelado'));
    }
    _state = ExecutionState.idle;
    _interpreter = null;
  }

  void dispose() {
    cancel();
    _controller.close();
  }
}
