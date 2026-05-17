import 'dart:async';
import 'package:flutter/services.dart';

// Execution event hierarchy
sealed class ExecutionEvent {}

class OutputEvent extends ExecutionEvent {
  final String text;
  final bool isError;
  OutputEvent(this.text, {this.isError = false});
}

class StdinPromptEvent extends ExecutionEvent {
  final String hint;
  StdinPromptEvent(this.hint);
}

class CompletedEvent extends ExecutionEvent {
  final int exitCode;
  final int elapsedMs;
  CompletedEvent(this.exitCode, this.elapsedMs);
}

class CancelledEvent extends ExecutionEvent {
  final String reason;
  CancelledEvent(this.reason);
}

class RuntimeErrorEvent extends ExecutionEvent {
  final String message;
  RuntimeErrorEvent(this.message);
}

/// Service that communicates with the native C runner via MethodChannel / EventChannel.
class CExecutionService {
  static const _methodChannel = MethodChannel('com.flowcode.app/c_runner');
  static const _eventChannel = EventChannel('com.flowcode.app/c_runner_events');

  StreamSubscription? _eventSub;
  final StreamController<ExecutionEvent> _controller =
      StreamController<ExecutionEvent>.broadcast();

  Stream<ExecutionEvent> get events => _controller.stream;

  /// Execute C code. Optionally provide pre‑loaded stdin lines.
  Future<void> execute({
    required String cCode,
    List<String> preloadedStdin = const [],
    int maxInstructions = 500000,
  }) async {
    // Cancel any previous subscription
    await _eventSub?.cancel();

    _eventSub = _eventChannel.receiveBroadcastStream().listen((raw) {
      if (raw is Map) {
        _controller.add(_parseEvent(Map<String, dynamic>.from(raw)));
      }
    }, onError: (e) {
      _controller.add(RuntimeErrorEvent(e.toString()));
    });

    await _methodChannel.invokeMethod('execute', {
      'cCode': cCode,
      'stdinLines': preloadedStdin.join('\n'),
      'maxInstructions': maxInstructions,
    });
  }

  /// Provide a line of input when the program requests stdin.
  Future<void> provideInput(String line) async {
    await _methodChannel.invokeMethod('provideInput', {'line': '$line\n'});
  }

  /// Cancel the currently running execution.
  Future<void> cancel() async {
    await _methodChannel.invokeMethod('cancel');
  }

  /// Validate C code without executing it.
  Future<String?> validate(String cCode) async {
    return await _methodChannel.invokeMethod<String>('validate', {'cCode': cCode});
  }

  /// Get interpreter version.
  Future<String> getVersion() async {
    return await _methodChannel.invokeMethod<String>('getVersion') ?? 'unknown';
  }

  ExecutionEvent _parseEvent(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'output':
        return OutputEvent(data['text'] as String,
            isError: data['isError'] as bool? ?? false);
      case 'stdin_prompt':
        return StdinPromptEvent(data['hint'] as String? ?? '');
      case 'completed':
        return CompletedEvent(data['exitCode'] as int, data['elapsedMs'] as int);
      case 'cancelled':
        return CancelledEvent(data['reason'] as String);
      case 'error':
        return RuntimeErrorEvent(data['message'] as String);
      default:
        return RuntimeErrorEvent('Unknown event type: ${data['type']}');
    }
  }

  void dispose() {
    _eventSub?.cancel();
    _controller.close();
  }
}
