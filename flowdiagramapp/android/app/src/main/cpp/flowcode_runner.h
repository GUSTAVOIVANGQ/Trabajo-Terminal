#ifndef FLOWCODE_RUNNER_H
#define FLOWCODE_RUNNER_H

#include <stddef.h>
#include <stdbool.h>
#include <jni.h>

/* ---------- Callbacks for I/O ---------- */

/* Called when the running C program produces output (printf/puts/putchar) */
typedef void (*OnStdoutCallback)(const char *text, void *user_data);

/* Called when the running C program needs input (scanf/getchar/gets).
 * Must fill `buffer` with the line (including trailing '\n') and return
 * the number of bytes written (>0), or 0/negative for EOF. */
typedef int (*OnStdinRequestCallback)(char *buffer, int buffer_size, void *user_data);

/* ---------- Execution state ---------- */
typedef struct {
    /* Callbacks (set by JNI layer before execution) */
    OnStdoutCallback       on_stdout;
    OnStdinRequestCallback on_stdin_request;
    void                  *callback_user_data;

    /* Sandbox control */
    long    instruction_count;
    long    max_instructions;   /* e.g. 500 000 */
    bool    cancelled;          /* Dart/Kotlin can set this to true to stop */

    /* stdin pre-load buffer */
    char    stdin_buffer[4096];
    int     stdin_buffer_len;
    int     stdin_buffer_pos;

    /* Result info (filled after execution) */
    int     exit_code;
    long    elapsed_ms;

    /* Pointer to the live Picoc instance so platform overrides can call
     * PlatformExit() when the output limit is exceeded. */
    void   *picoc_instance;     /* actually Picoc* — opaque here to avoid including interpreter.h */
} FlowCodeRunnerState;

/* ---------- Internal helpers called from picoc_platform_android.c ---------- */
void flowcode_set_runner_state(FlowCodeRunnerState *state);

/* ---------- JNI exported functions ---------- */
#ifdef __cplusplus
extern "C" {
#endif

/* Execute C code. Returns the program's exit code (0 = success).
 * This call is blocking; invoke it from a dedicated thread. */
JNIEXPORT jint JNICALL
Java_com_flowcode_app_CRunner_nativeRunC(
    JNIEnv  *env,
    jobject  thiz,
    jstring  j_code,           /* C source code */
    jstring  j_stdin,          /* pre-loaded stdin lines, separated by '\n' */
    jint     max_instructions,
    jobject  callback_obj      /* Kotlin object implementing CRunnerCallback */
);

/* Cancel the current execution (safe to call from any thread) */
JNIEXPORT void JNICALL
Java_com_flowcode_app_CRunner_nativeCancelExecution(
    JNIEnv  *env,
    jobject  thiz
);

/* Returns a version string for the embedded interpreter */
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeGetVersion(
    JNIEnv  *env,
    jobject  thiz
);

/* Validates C code syntactically without executing it.
 * Returns null if valid, or an error string if not. */
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeValidateC(
    JNIEnv  *env,
    jobject  thiz,
    jstring  j_code
);

#ifdef __cplusplus
}
#endif

#endif /* FLOWCODE_RUNNER_H */
