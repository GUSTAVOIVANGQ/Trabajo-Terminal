/*
 * picoc_platform_android.c
 * Platform implementation for PicoC running on Android via JNI.
 *
 * Implements the required platform.h interface functions so that PicoC
 * routes its I/O through our JNI callbacks instead of stdin/stdout.
 *
 * Functions implemented here (replacing platform/platform_unix.c):
 *   PlatformInit, PlatformCleanup, PlatformGetLine,
 *   PlatformGetCharacter, PlatformPutc, PlatformExit,
 *   PlatformLibraryInit
 */

#include "picoc/picoc.h"
#include "picoc/interpreter.h"
#include "flowcode_runner.h"
#include <android/log.h>
#include <string.h>
#include <setjmp.h>

#define LOG_TAG "FlowCodePlatform"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

/* ─── Global runner state (defined in flowcode_runner.c) ─────────────────── */
extern FlowCodeRunnerState g_state;

/* Setter called by flowcode_runner.c to update the pointer from NULL→&g_state */
void flowcode_set_runner_state(FlowCodeRunnerState *state) {
    /* g_state is a global struct; when state==NULL we just ensure callbacks
     * are cleared so stray calls are no-ops after execution ends. */
    if (state == NULL) {
        g_state.on_stdout        = NULL;
        g_state.on_stdin_request = NULL;
        g_state.picoc_instance   = NULL;
    }
    /* When state == &g_state, the struct is already in place — nothing to do. */
}

/* ─── Output accumulator ───────────────────────────────────────────────── */
/* PicoC calls PlatformPutc one character at a time.  We buffer them and   */
/* flush on newline or when the buffer is full.                              */
#define OUT_BUF_SIZE 4096
static char  s_out_buf[OUT_BUF_SIZE];
static int   s_out_pos     = 0;
static long  s_total_chars = 0;
#define MAX_OUTPUT_CHARS 100000

static void flush_output_buf(void) {
    if (s_out_pos <= 0) { s_out_pos = 0; return; }
    s_out_buf[s_out_pos] = '\0';
    if (g_state.on_stdout) {
        g_state.on_stdout(s_out_buf, g_state.callback_user_data);
    }
    s_out_pos = 0;
}

/* ─── PlatformInit / PlatformCleanup ────────────────────────────────────── */
void PlatformInit(Picoc *pc) {
    s_out_pos     = 0;
    s_total_chars = 0;
    (void)pc;
}

void PlatformCleanup(Picoc *pc) {
    flush_output_buf();
    (void)pc;
}

/* ─── PlatformPutc — character-level output hook ────────────────────────── */
void PlatformPutc(unsigned char OutCh, union OutputStreamInfo *Stream) {
    (void)Stream;

    s_total_chars++;
    if (s_total_chars > MAX_OUTPUT_CHARS) {
        flush_output_buf();
        if (g_state.on_stdout) {
            g_state.on_stdout(
                "\n[FlowCode] Salida excede límite de 100k caracteres. Ejecución terminada.\n",
                g_state.callback_user_data);
        }
        if (g_state.picoc_instance) {
            PlatformExit((Picoc *)g_state.picoc_instance, -4);
        }
        return;
    }

    s_out_buf[s_out_pos++] = (char)OutCh;
    if (OutCh == '\n' || s_out_pos >= OUT_BUF_SIZE - 1) {
        flush_output_buf();
    }
}

/* ─── PlatformGetLine — line-level stdin hook ─────────────────────────────── */
char *PlatformGetLine(char *Buf, int MaxLen, const char *Prompt) {
    (void)Prompt;
    if (!g_state.on_stdin_request) return NULL;

    if (g_state.stdin_buffer_pos < g_state.stdin_buffer_len) {
        int i;
        int available = g_state.stdin_buffer_len - g_state.stdin_buffer_pos;
        int copy_max  = available < MaxLen - 1 ? available : MaxLen - 1;
        for (i = 0; i < copy_max; i++) {
            char c = g_state.stdin_buffer[g_state.stdin_buffer_pos + i];
            Buf[i] = c;
            if (c == '\n') { i++; break; }
        }
        Buf[i] = '\0';
        g_state.stdin_buffer_pos += i;
        return Buf;
    }

    int received = g_state.on_stdin_request(
        g_state.stdin_buffer, sizeof(g_state.stdin_buffer),
        g_state.callback_user_data);
    if (received <= 0) return NULL;
    g_state.stdin_buffer_len = received;
    g_state.stdin_buffer_pos = 0;
    return PlatformGetLine(Buf, MaxLen, NULL);
}

/* ─── PlatformGetCharacter — single-char stdin hook ─────────────────────── */
int PlatformGetCharacter(void) {
    if (!g_state.on_stdin_request) return EOF;

    if (g_state.stdin_buffer_pos < g_state.stdin_buffer_len) {
        return (unsigned char)g_state.stdin_buffer[g_state.stdin_buffer_pos++];
    }

    int received = g_state.on_stdin_request(
        g_state.stdin_buffer, sizeof(g_state.stdin_buffer),
        g_state.callback_user_data);
    if (received <= 0) return EOF;
    g_state.stdin_buffer_len = received;
    g_state.stdin_buffer_pos = 0;
    return (unsigned char)g_state.stdin_buffer[g_state.stdin_buffer_pos++];
}

/* ─── PlatformExit — longjmp out of PicoC ───────────────────────────────── */
void PlatformExit(Picoc *pc, int ExitVal) {
    pc->PicocExitValue = ExitVal;
    longjmp(pc->PicocExitBuf, 1);
}

/* ─── PlatformLibraryInit — no extra platform libraries needed ───────────── */
void PlatformLibraryInit(Picoc *pc) {
    (void)pc;
}

/* ─── PlatformInstructionTick — instruction-level sandbox ──────────────── */
/* Called by PicoC at the start of every instruction.                       */
void PlatformInstructionTick(Picoc *pc) {
    if (g_state.cancelled) {
        PlatformExit(pc, -2); /* Cancelled by user/watchdog */
        return;
    }

    g_state.instruction_count++;
    if (g_state.instruction_count > g_state.max_instructions) {
        if (g_state.on_stdout) {
            g_state.on_stdout(
                "\n[FlowCode] Límite de instrucciones alcanzado. Ejecución terminada.\n",
                g_state.callback_user_data);
        }
        PlatformExit(pc, -1); /* Instruction limit reached */
    }
}
