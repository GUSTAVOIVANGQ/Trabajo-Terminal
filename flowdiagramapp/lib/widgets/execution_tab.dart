import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../compiler/ast_interpreter.dart';
import '../compiler/ast_nodes.dart';
import '../services/c_execution_service.dart';

/// Terminal-style tab that executes the diagram's AST directly in Dart.
class ExecutionTab extends StatefulWidget {
  /// The optimized AST from the compilation pipeline (null if compilation failed).
  final ProgramNode? ast;

  /// The C source code generated (for display purposes only).
  final String cCode;

  /// Whether the compilation was successful.
  final bool compilationSuccess;

  const ExecutionTab({
    super.key,
    this.ast,
    required this.cCode,
    required this.compilationSuccess,
  });

  @override
  State<ExecutionTab> createState() => _ExecutionTabState();
}

class _ExecutionTabState extends State<ExecutionTab>
    with AutomaticKeepAliveClientMixin {
  final CExecutionService _service = CExecutionService();
  StreamSubscription<ExecutionEvent>? _sub;

  final List<_TerminalLine> _lines = [];
  bool _running = false;
  bool _awaitingInput = false;
  int? _exitCode;
  int? _elapsedMs;
  int? _steps;

  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _sub?.cancel();
    _service.dispose();
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ── Execution control ────────────────────────────────────────────────────

  Future<void> _run() async {
    if (_running || widget.ast == null) return;
    setState(() {
      _lines.clear();
      _running = true;
      _awaitingInput = false;
      _exitCode = null;
      _elapsedMs = null;
      _steps = null;
    });

    _sub?.cancel();
    _sub = _service.events.listen(_onEvent);

    try {
      await _service.execute(ast: widget.ast!);
    } catch (e) {
      _appendLine('[FlowCode] Error al iniciar: $e', _LineType.error);
      setState(() => _running = false);
    }
  }

  void _cancel() {
    _service.cancel();
    _appendLine('\n[FlowCode] Ejecución cancelada por el usuario.', _LineType.system);
    setState(() {
      _running = false;
      _awaitingInput = false;
    });
  }

  void _onEvent(ExecutionEvent event) {
    switch (event) {
      case OutputEvent(:final text):
        _appendLine(text, _LineType.output);
      case StdinPromptEvent(:final variableName, :final typeName):
        _appendLine(
            '[Ingresa valor para "$variableName" ($typeName):]', _LineType.system);
        setState(() => _awaitingInput = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _inputFocus.requestFocus();
        });
      case CompletedEvent(:final exitCode, :final elapsedMs, :final steps, :final stopReason):
        setState(() {
          _running = false;
          _awaitingInput = false;
          _exitCode = exitCode;
          _elapsedMs = elapsedMs;
          _steps = steps;
        });
        _appendFooter(exitCode, elapsedMs, steps, stopReason);
      case ErrorEvent(:final message):
        _appendLine('\n[Error: $message]', _LineType.error);
    }
  }

  void _submitInput() {
    final text = _inputCtrl.text;
    _inputCtrl.clear();
    if (!_awaitingInput) return;
    _appendLine('> $text', _LineType.input);
    setState(() => _awaitingInput = false);
    _service.provideInput(text);
  }

  void _appendLine(String text, _LineType type) {
    setState(() {
      final parts = text.split('\n');
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i == 0 && _lines.isNotEmpty && _lines.last.type == type) {
          _lines.last = _TerminalLine(_lines.last.text + part, type);
        } else {
          if (part.isNotEmpty || i < parts.length - 1) {
            _lines.add(_TerminalLine(part, type));
          }
        }
      }
    });
    _scrollToBottom();
  }

  void _appendFooter(int exitCode, int elapsedMs, int steps, StopReason reason) {
    String reasonText;
    _LineType lineType;
    switch (reason) {
      case StopReason.completed:
        reasonText = 'Completado';
        lineType = _LineType.system;
      case StopReason.error:
        reasonText = 'Error';
        lineType = _LineType.error;
      case StopReason.iterationLimit:
        reasonText = 'Límite de iteraciones (posible bucle infinito)';
        lineType = _LineType.warning;
      case StopReason.timeout:
        reasonText = 'Timeout';
        lineType = _LineType.warning;
      case StopReason.cancelled:
        reasonText = 'Cancelado';
        lineType = _LineType.system;
    }
    _appendLine('', lineType);
    _appendLine(
      '─── $reasonText · ${elapsedMs}ms · $steps pasos ───',
      lineType,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canRun = widget.compilationSuccess && widget.ast != null && !_running;

    return Column(
      children: [
        _buildToolbar(theme, isDark, canRun),
        Expanded(child: _buildTerminal(isDark)),
        _buildStatusBar(theme, isDark),
        if (_awaitingInput) _buildInputRow(theme, isDark),
      ],
    );
  }

  Widget _buildToolbar(ThemeData theme, bool isDark, bool canRun) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: canRun ? _run : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Ejecutar'),
          ),
          const SizedBox(width: 8),
          if (_running)
            OutlinedButton.icon(
              onPressed: _cancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Cancelar'),
            ),
          const Spacer(),
          if (_running) ...[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _awaitingInput ? 'Esperando entrada…' : 'Ejecutando…',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
          ],
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            tooltip: 'Limpiar terminal',
            onPressed: () => setState(() {
              _lines.clear();
              _exitCode = null;
              _elapsedMs = null;
              _steps = null;
            }),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tooltip: 'Copiar salida',
            onPressed: _lines.isEmpty
                ? null
                : () {
                    final text = _lines.map((l) => l.text).join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Salida copiada al portapapeles'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildTerminal(bool isDark) {
    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFF1E1E1E);

    if (_lines.isEmpty && !_running) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.compilationSuccess && widget.ast != null
                    ? Icons.terminal
                    : Icons.error_outline,
                size: 48,
                color: widget.compilationSuccess && widget.ast != null
                    ? Colors.grey[600]
                    : Colors.red[400],
              ),
              const SizedBox(height: 12),
              Text(
                widget.compilationSuccess && widget.ast != null
                    ? 'Presiona Ejecutar para correr el diagrama'
                    : 'Corrige los errores del compilador antes de ejecutar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.compilationSuccess && widget.ast != null
                      ? Colors.grey[500]
                      : Colors.red[300],
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: SelectionArea(
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(12),
          itemCount: _lines.length,
          itemBuilder: (context, i) => _buildTerminalLine(_lines[i]),
        ),
      ),
    );
  }

  Widget _buildTerminalLine(_TerminalLine line) {
    Color color;
    switch (line.type) {
      case _LineType.output:
        color = Colors.green[300]!;
      case _LineType.error:
        color = Colors.red[300]!;
      case _LineType.system:
        color = Colors.cyan[300]!;
      case _LineType.input:
        color = Colors.grey[400]!;
      case _LineType.warning:
        color = Colors.orange[300]!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        line.text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: color,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme, bool isDark) {
    final hasDone = _exitCode != null;
    final success = _exitCode == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isDark ? const Color(0xFF161B22) : Colors.grey[200],
      child: Row(
        children: [
          if (hasDone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: success ? Colors.green[900] : Colors.red[900],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                success ? '✓ exit 0' : '✗ exit $_exitCode',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: success ? Colors.green[200] : Colors.red[200],
                ),
              ),
            ),
          if (hasDone && _elapsedMs != null) ...[
            const SizedBox(width: 8),
            Text(
              '${_elapsedMs}ms',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (hasDone && _steps != null) ...[
            const SizedBox(width: 8),
            Text(
              '$_steps pasos',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.memory,
                size: 12,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                'Intérprete Dart · 10k pasos · 5s timeout',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isDark ? const Color(0xFF161B22) : Colors.grey[100],
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[900],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'stdin',
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              focusNode: _inputFocus,
              autofocus: true,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: isDark ? Colors.green[300] : Colors.green[800],
              ),
              decoration: InputDecoration(
                hintText: 'Escribe la entrada y presiona Enter…',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green[700]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green[500]!),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onSubmitted: (_) => _submitInput(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _submitInput,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            child: const Icon(Icons.send, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

enum _LineType { output, error, system, input, warning }

class _TerminalLine {
  final String text;
  final _LineType type;
  _TerminalLine(this.text, this.type);
}
