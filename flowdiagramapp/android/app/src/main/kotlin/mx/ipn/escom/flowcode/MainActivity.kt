package mx.ipn.escom.flowcode

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import com.flowcode.app.CRunner
import com.flowcode.app.ExecutionEvent

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.flowcode.app/c_runner"
    private val EVENT_CHANNEL = "com.flowcode.app/c_runner_events"

    private var eventSink: EventChannel.EventSink? = null
    private var executionJob: Job? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Event channel for streaming execution events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })

        // Method channel for commands from Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "execute" -> {
                        val cCode = call.argument<String>("cCode") ?: ""
                        val stdinLines = call.argument<String>("stdinLines") ?: ""
                        val maxInstr = call.argument<Int>("maxInstructions") ?: 500_000
                        executionJob = CoroutineScope(Dispatchers.IO).launch {
                            CRunner.execute(cCode, stdinLines, maxInstr).collect { event ->
                                runOnUiThread {
                                    eventSink?.success(event.toMap())
                                }
                            }
                        }
                        result.success(null)
                    }
                    "cancel" -> {
                        CRunner.cancel()
                        executionJob?.cancel()
                        result.success(null)
                    }
                    "validate" -> {
                        val cCode = call.argument<String>("cCode") ?: ""
                        result.success(CRunner.validate(cCode))
                    }
                    "getVersion" -> {
                        result.success(CRunner.nativeGetVersion())
                    }
                    "provideInput" -> {
                        val line = call.argument<String>("line") ?: ""
                        CRunner.provideStdinLine(line)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

// Extension to map ExecutionEvent to a plain map for the EventChannel
fun ExecutionEvent.toMap(): Map<String, Any?> = when (this) {
    is ExecutionEvent.Output -> mapOf("type" to "output", "text" to text, "isError" to isError)
    is ExecutionEvent.StdinPrompt -> mapOf("type" to "stdin_prompt", "hint" to hint)
    is ExecutionEvent.Completed -> mapOf("type" to "completed", "exitCode" to exitCode, "elapsedMs" to elapsedMs)
    is ExecutionEvent.Cancelled -> mapOf("type" to "cancelled", "reason" to reason)
    is ExecutionEvent.RuntimeError -> mapOf("type" to "error", "message" to message)
}
