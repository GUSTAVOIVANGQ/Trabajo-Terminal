package com.flowcode.app

import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*

/** Callbacks invoked from JNI (running on a native thread) */
interface CRunnerCallback {
    fun onStdout(text: String)
    fun onStdinRequest(): String  // blocking — called from a native thread
}

/** Events emitted to Flutter via the EventChannel */
sealed class ExecutionEvent {
    data class Output(val text: String, val isError: Boolean = false) : ExecutionEvent()
    data class StdinPrompt(val hint: String = "") : ExecutionEvent()
    data class Completed(val exitCode: Int, val elapsedMs: Long) : ExecutionEvent()
    data class Cancelled(val reason: String) : ExecutionEvent()
    data class RuntimeError(val message: String) : ExecutionEvent()
}

object CRunner {

    init {
        System.loadLibrary("flowcode_runner")
    }

    // ── JNI native declarations ──────────────────────────────────────────
    private external fun nativeRunC(
        cCode: String,
        stdinLines: String,
        maxInstructions: Int,
        callback: CRunnerCallback
    ): Int

    private external fun nativeCancelExecution()
    external fun nativeGetVersion(): String
    external fun nativeValidateC(cCode: String): String?

    // ── Live stdin channel for interactive input ─────────────────────────
    // Replaced on each new execute() call; provideStdinLine() writes here.
    @Volatile
    private var stdinChannel: Channel<String>? = null

    /**
     * Execute C code and return a Flow of [ExecutionEvent].
     *
     * @param cCode          Generated C source.
     * @param stdinLines     Optional pre-loaded stdin (newline-separated).
     * @param maxInstructions Sandbox limit (default 500 000).
     */
    fun execute(
        cCode: String,
        stdinLines: String = "",
        maxInstructions: Int = 500_000
    ): Flow<ExecutionEvent> = channelFlow {

        // Fresh stdin channel for this run
        val ch = Channel<String>(Channel.UNLIMITED)
        stdinChannel = ch

        // Pre-load any provided stdin lines
        if (stdinLines.isNotBlank()) {
            stdinLines.lines().forEach { line -> ch.trySend(line + "\n") }
        }

        val startMs = System.currentTimeMillis()

        val callback = object : CRunnerCallback {
            override fun onStdout(text: String) {
                trySend(ExecutionEvent.Output(text))
            }

            override fun onStdinRequest(): String {
                // This is called from a native thread.  We block on the
                // channel until the user (or pre-loaded data) provides a line.
                return runBlocking {
                    val pending = ch.tryReceive().getOrNull()
                    if (pending != null) {
                        pending
                    } else {
                        // Signal the UI that stdin is needed
                        send(ExecutionEvent.StdinPrompt())
                        ch.receive()
                    }
                }
            }
        }

        val exitCode = withContext(Dispatchers.IO) {
            try {
                nativeRunC(cCode, "", maxInstructions, callback)
            } catch (e: Throwable) {
                send(ExecutionEvent.RuntimeError(e.message ?: "Unknown error"))
                -1
            }
        }

        val elapsed = System.currentTimeMillis() - startMs
        stdinChannel = null

        when (exitCode) {
            0    -> send(ExecutionEvent.Completed(0, elapsed))
            -1   -> send(ExecutionEvent.Cancelled("Límite de instrucciones alcanzado"))
            -2   -> send(ExecutionEvent.Cancelled("Cancelado por el usuario"))
            -3   -> send(ExecutionEvent.Cancelled("Timeout (10 segundos)"))
            -4   -> send(ExecutionEvent.Cancelled("Salida excede límite de 100 k caracteres"))
            -99  -> send(ExecutionEvent.RuntimeError("Ya hay una ejecución en progreso"))
            else -> send(ExecutionEvent.Completed(exitCode, elapsed))
        }
    }

    /**
     * Provide a line of user input to the currently running program.
     * No-op if no execution is active.
     */
    fun provideStdinLine(line: String) {
        stdinChannel?.trySend(if (line.endsWith("\n")) line else "$line\n")
    }

    /** Cancel the execution in progress. */
    fun cancel() {
        nativeCancelExecution()
    }

    /** Validate C code without executing. Returns null if valid, error string otherwise. */
    fun validate(cCode: String): String? = nativeValidateC(cCode)
}
