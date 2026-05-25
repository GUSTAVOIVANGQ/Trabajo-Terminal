/*
 * flowcode_runner.c
 * JNI bridge between Flutter/Kotlin and the PicoC C interpreter.
 *
 * Design:
 *   - One FlowCodeRunnerState lives in global storage (only one execution
 *     at a time is allowed).
 *   - The Kotlin CRunner object passes callbacks; we store them as JNI
 *     GlobalRef objects so that the native execution thread (pthread) can
 *     call back into Java safely.
 *   - Output (printf etc.) is forwarded via onStdout().
 *   - Input  (scanf  etc.) is forwarded via onStdinRequest().
 *   - Timeout: Android Bionic does NOT have pthread_timedjoin_np or
 *     pthread_cancel.  We implement timeout via a watchdog thread that
 *     sets g_state.cancelled after 10 seconds; the sandbox tick in
 *     picoc_platform_android.c then calls PlatformExit().
 */

#include "flowcode_runner.h"
#include "picoc/picoc.h"
#include <android/log.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <semaphore.h>

#define LOG_TAG "FlowCodeRunner"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

/* ─── Global state ─────────────────────────────────────────────────────── */
FlowCodeRunnerState g_state;               /* defined here, extern in platform .c */
static volatile int  g_execution_active = 0;

/* Semaphore posted when execution finishes — used by watchdog */
static sem_t g_done_sem;

/* JNI globals kept alive across the native execution thread */
static JavaVM   *g_jvm            = NULL;
static jobject   g_callback_gref  = NULL;
static jmethodID g_on_stdout_mid  = NULL;
static jmethodID g_on_stdin_mid   = NULL;

/* ─── JNI_OnLoad — grab the JavaVM for AttachCurrentThread ─────────────── */
JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void)reserved;
    g_jvm = vm;
    return JNI_VERSION_1_6;
}

/* ─── Helper: get/attach JNIEnv for the current thread ─────────────────── */
static JNIEnv *get_env(int *attached) {
    if (g_jvm == NULL) { *attached = 0; return NULL; }
    JNIEnv *env = NULL;
    jint res = (*g_jvm)->GetEnv(g_jvm, (void **)&env, JNI_VERSION_1_6);
    if (res == JNI_EDETACHED) {
        (*g_jvm)->AttachCurrentThread(g_jvm, &env, NULL);
        *attached = 1;
    } else {
        *attached = 0;
    }
    return env;
}

static void detach_if_needed(int attached) {
    if (attached && g_jvm) (*g_jvm)->DetachCurrentThread(g_jvm);
}

/* ─── Callback: stdout ──────────────────────────────────────────────────── */
void on_stdout_callback(const char *text, void *user_data) {
    (void)user_data;
    if (!g_callback_gref || !g_on_stdout_mid) return;
    int attached;
    JNIEnv *env = get_env(&attached);
    if (!env) return;
    jstring jtext = (*env)->NewStringUTF(env, text ? text : "");
    (*env)->CallVoidMethod(env, g_callback_gref, g_on_stdout_mid, jtext);
    (*env)->DeleteLocalRef(env, jtext);
    if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
    detach_if_needed(attached);
}

/* ─── Callback: stdin request ───────────────────────────────────────────── */
static int on_stdin_request_callback(char *buffer, int buffer_size, void *user_data) {
    (void)user_data;
    if (!g_callback_gref || !g_on_stdin_mid) return 0;
    int attached;
    JNIEnv *env = get_env(&attached);
    if (!env) return 0;
    jstring jline = (jstring)(*env)->CallObjectMethod(env, g_callback_gref, g_on_stdin_mid);
    int bytes = 0;
    if (jline && !(*env)->ExceptionCheck(env)) {
        const char *cline = (*env)->GetStringUTFChars(env, jline, NULL);
        if (cline) {
            int len = (int)strlen(cline);
            if (len >= buffer_size) len = buffer_size - 1;
            memcpy(buffer, cline, len);
            buffer[len] = '\0';
            bytes = len;
            (*env)->ReleaseStringUTFChars(env, jline, cline);
        }
        (*env)->DeleteLocalRef(env, jline);
    }
    if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
    detach_if_needed(attached);
    return bytes;
}

/* ─── Execution thread ──────────────────────────────────────────────────── */
typedef struct {
    char *c_code;
    int   exit_code;
} ExecThreadArgs;

/*
 * Forward declaration of the header registration function defined in
 * flowcode_stdlib_android.c (only compiled when BUILTIN_MINI_STDLIB).
 */
#ifdef BUILTIN_MINI_STDLIB
extern void FlowCodeRegisterHeaders(Picoc *pc);
#endif

static void *exec_thread_func(void *arg) {
    ExecThreadArgs *args = (ExecThreadArgs *)arg;

    Picoc pc;
    PicocInitialise(&pc, STACK_SIZE > 0 ? STACK_SIZE : 65536);

    /* Register built-in headers so #include <stdio.h> etc. resolve.         */
    /* CLibrary functions (printf, getchar, strlen, etc.) are already set up */
    /* by PicocInitialise. This call only makes the includes work and adds   */
    /* custom scanf/putchar/puts implementations that route through our I/O  */
    /* callbacks instead of the real system stdin/stdout.                    */
#ifdef BUILTIN_MINI_STDLIB
    FlowCodeRegisterHeaders(&pc);
#endif

    /* Allow platform overrides to access the Picoc instance */
    g_state.picoc_instance = &pc;

    int exit_val = 0;

    if (PicocPlatformSetExitPoint(&pc)) {
        exit_val = pc.PicocExitValue;
    } else {
        PicocParse(&pc,
                   "program.c",
                   args->c_code,
                   (int)strlen(args->c_code),
                   1,   /* RunIt          */
                   0,   /* CleanupNow     */
                   0,   /* CleanupSource  */
                   0);  /* EnableDebugger */
        PicocCallMain(&pc, 0, NULL);
        exit_val = pc.PicocExitValue;
    }

    PicocCleanup(&pc);
    g_state.picoc_instance = NULL;
    args->exit_code = exit_val;

    /* Signal watchdog that we are done */
    sem_post(&g_done_sem);
    return NULL;
}

/* ─── Watchdog thread ───────────────────────────────────────────────────── */
/*
 * Android Bionic does NOT have pthread_timedjoin_np or pthread_cancel.
 * Instead: a watchdog thread waits on the semaphore with a wall-clock
 * timeout.  If the timeout fires, it sets g_state.cancelled = true.
 * The PlatformInstructionTick (in picoc_platform_android.c) then calls
 * PlatformExit() on the next instruction tick, cleanly unwinding PicoC.
 */
typedef struct { int timeout_sec; } WatchdogArgs;

static void *watchdog_thread_func(void *arg) {
    WatchdogArgs *wa = (WatchdogArgs *)arg;

    struct timespec deadline;
    clock_gettime(CLOCK_REALTIME, &deadline);
    deadline.tv_sec += wa->timeout_sec;

    int timed_out = (sem_timedwait(&g_done_sem, &deadline) != 0);
    if (timed_out) {
        /* Set the cancellation flag — execution thread will call PlatformExit */
        g_state.cancelled = true;
        LOGE("Execution watchdog: timeout after %d seconds", wa->timeout_sec);
        on_stdout_callback(
            "\n[FlowCode] Timeout: la ejecución excedió 10 segundos.\n", NULL);

        /* Wait for the execution thread to actually exit via PlatformExit */
        sem_wait(&g_done_sem);
    }
    return NULL;
}

/* ─── nativeRunC ──────────────────────────────────────────────────────── */
JNIEXPORT jint JNICALL
Java_com_flowcode_app_CRunner_nativeRunC(
    JNIEnv  *env,
    jobject  thiz,
    jstring  j_code,
    jstring  j_stdin,
    jint     max_instructions,
    jobject  callback_obj)
{
    (void)thiz;

    if (g_execution_active) {
        LOGE("Execution already in progress");
        return -99;
    }
    g_execution_active = 1;

    /* ── Resolve callback method IDs ── */
    jclass cb_class = (*env)->GetObjectClass(env, callback_obj);
    g_on_stdout_mid = (*env)->GetMethodID(env, cb_class, "onStdout",
                                          "(Ljava/lang/String;)V");
    g_on_stdin_mid  = (*env)->GetMethodID(env, cb_class, "onStdinRequest",
                                          "()Ljava/lang/String;");
    (*env)->DeleteLocalRef(env, cb_class);

    if (g_callback_gref) (*env)->DeleteGlobalRef(env, g_callback_gref);
    g_callback_gref = (*env)->NewGlobalRef(env, callback_obj);

    /* ── Convert Java strings ── */
    const char *code_cstr  = (*env)->GetStringUTFChars(env, j_code,  NULL);
    const char *stdin_cstr = (*env)->GetStringUTFChars(env, j_stdin, NULL);
    char *code_copy = strdup(code_cstr);

    /* ── Prepare global state ── */
    memset(&g_state, 0, sizeof(g_state));
    g_state.on_stdout          = on_stdout_callback;
    g_state.on_stdin_request   = on_stdin_request_callback;
    g_state.callback_user_data = NULL;
    g_state.max_instructions   = max_instructions > 0 ? max_instructions : 500000;
    g_state.instruction_count  = 0;
    g_state.cancelled          = false;
    g_state.picoc_instance     = NULL;

    /* Pre-load stdin buffer */
    if (stdin_cstr && stdin_cstr[0]) {
        int slen = (int)strlen(stdin_cstr);
        if (slen >= (int)sizeof(g_state.stdin_buffer))
            slen = (int)sizeof(g_state.stdin_buffer) - 1;
        memcpy(g_state.stdin_buffer, stdin_cstr, slen);
        g_state.stdin_buffer[slen]  = '\0';
        g_state.stdin_buffer_len    = slen;
        g_state.stdin_buffer_pos    = 0;
    }

    (*env)->ReleaseStringUTFChars(env, j_code,  code_cstr);
    (*env)->ReleaseStringUTFChars(env, j_stdin, stdin_cstr);

    /* Publish state to platform overrides */
    flowcode_set_runner_state(&g_state);

    /* ── Initialise semaphore ── */
    sem_init(&g_done_sem, 0, 0);

    /* ── Timing ── */
    struct timespec t_start, t_end;
    clock_gettime(CLOCK_MONOTONIC, &t_start);

    /* ── Launch execution + watchdog threads ── */
    ExecThreadArgs exec_args = { .c_code = code_copy, .exit_code = 0 };
    WatchdogArgs   wd_args   = { .timeout_sec = 10 };
    pthread_t exec_thread, wd_thread;
    pthread_create(&exec_thread, NULL, exec_thread_func, &exec_args);
    pthread_create(&wd_thread,   NULL, watchdog_thread_func, &wd_args);

    /* Wait for both to finish */
    pthread_join(exec_thread, NULL);
    pthread_join(wd_thread,   NULL);

    /* ── Stop timer ── */
    clock_gettime(CLOCK_MONOTONIC, &t_end);
    g_state.elapsed_ms = (t_end.tv_sec  - t_start.tv_sec)  * 1000L
                        + (t_end.tv_nsec - t_start.tv_nsec) / 1000000L;

    /* ── Cleanup ── */
    sem_destroy(&g_done_sem);
    free(code_copy);
    flowcode_set_runner_state(NULL);
    if (g_callback_gref) {
        (*env)->DeleteGlobalRef(env, g_callback_gref);
        g_callback_gref = NULL;
    }
    g_on_stdout_mid    = NULL;
    g_on_stdin_mid     = NULL;
    g_execution_active = 0;

    /* Map special exit codes from watchdog/sandbox */
    if (g_state.cancelled && exec_args.exit_code != -4)
        return -3; /* timeout */
    return (jint)exec_args.exit_code;
}

/* ─── nativeCancelExecution ──────────────────────────────────────────────── */
JNIEXPORT void JNICALL
Java_com_flowcode_app_CRunner_nativeCancelExecution(
    JNIEnv *env, jobject thiz)
{
    (void)env; (void)thiz;
    g_state.cancelled = true;
    LOGI("Execution cancelled by user");
}

/* ─── nativeGetVersion ───────────────────────────────────────────────────── */
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeGetVersion(
    JNIEnv *env, jobject thiz)
{
    (void)thiz;
    return (*env)->NewStringUTF(env, "PicoC-FlowCode 1.0 (arm64/armeabi-v7a)");
}

/* ─── nativeValidateC ────────────────────────────────────────────────────── */
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeValidateC(
    JNIEnv *env, jobject thiz, jstring j_code)
{
    (void)thiz;
    const char *code = (*env)->GetStringUTFChars(env, j_code, NULL);
    Picoc pc;
    PicocInitialise(&pc, 65536);
    char errbuf[512] = {0};
    int  has_error   = 0;
    if (PicocPlatformSetExitPoint(&pc)) {
        snprintf(errbuf, sizeof(errbuf),
                 "Error de compilación (código %d)", pc.PicocExitValue);
        has_error = 1;
    } else {
        PicocParse(&pc, "validate.c", code, (int)strlen(code), 1, 1, 0, 0);
    }
    PicocCleanup(&pc);
    (*env)->ReleaseStringUTFChars(env, j_code, code);
    if (has_error) return (*env)->NewStringUTF(env, errbuf);
    return NULL;
}
