/*
 * flowcode_stdlib_android.c
 * Android-specific C standard library for PicoC mini stdlib.
 *
 * This file is compiled ONLY when BUILTIN_MINI_STDLIB is defined.
 * It provides:
 *   1. scanf() implementation reading via PlatformGetCharacter
 *   2. putchar() / puts() implementations writing via PlatformPutc
 *   3. Header registration for stdio.h, stdlib.h, math.h, string.h, stdbool.h
 *
 * The goal is to route all I/O through the JNI callbacks (flowcode_runner.c)
 * instead of going to the real system stdin/stdout (which is invisible
 * from the Flutter app on Android).
 */

#include "picoc/picoc.h"
#include "picoc/interpreter.h"
#include "flowcode_runner.h"
#include <android/log.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdarg.h>

#ifdef BUILTIN_MINI_STDLIB

#define LOG_TAG "FlowCodeStdLib"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

/* ─── Forward declarations ───────────────────────────────────────────────── */
static void FlowCodePutcharFunc(struct ParseState *Parser, struct Value *ReturnValue,
                                 struct Value **Param, int NumArgs);
static void FlowCodePutsFunc(struct ParseState *Parser, struct Value *ReturnValue,
                              struct Value **Param, int NumArgs);
static void FlowCodeScanfFunc(struct ParseState *Parser, struct Value *ReturnValue,
                               struct Value **Param, int NumArgs);

/* ─── Helpers to access runner state ─────────────────────────────────────── */
extern FlowCodeRunnerState g_state;

static int read_input_char(void) {
    if (g_state.stdin_buffer_pos < g_state.stdin_buffer_len) {
        return (unsigned char)g_state.stdin_buffer[g_state.stdin_buffer_pos++];
    }
    if (!g_state.on_stdin_request) return EOF;
    int received = g_state.on_stdin_request(
        g_state.stdin_buffer, sizeof(g_state.stdin_buffer),
        g_state.callback_user_data);
    if (received <= 0) return EOF;
    g_state.stdin_buffer_len = received;
    g_state.stdin_buffer_pos = 0;
    return (unsigned char)g_state.stdin_buffer[g_state.stdin_buffer_pos++];
}

static void unread_input_char(int c) {
    if (c != EOF && g_state.stdin_buffer_pos > 0) {
        g_state.stdin_buffer_pos--;
        g_state.stdin_buffer[g_state.stdin_buffer_pos] = (char)c;
    }
}

static void write_output_char(unsigned char c) {
    PlatformPutc(c, NULL);
}

static void write_output_str(const char *s) {
    while (*s) write_output_char((unsigned char)*s++);
}

/* ─── putchar(c) ──────────────────────────────────────────────────────────── */
static void FlowCodePutcharFunc(struct ParseState *Parser, struct Value *ReturnValue,
                                 struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    int ch = Param[0]->Val->Integer;
    write_output_char((unsigned char)ch);
    ReturnValue->Val->Integer = ch;
}

/* ─── puts(s) ─────────────────────────────────────────────────────────────── */
static void FlowCodePutsFunc(struct ParseState *Parser, struct Value *ReturnValue,
                              struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    const char *s = Param[0]->Val->Pointer;
    if (s) write_output_str(s);
    write_output_char('\n');
    ReturnValue->Val->Integer = 1;
}

/* ─── Character-class helpers for scanf ─────────────────────────────────── */
static void skip_whitespace(void) {
    int c;
    while ((c = read_input_char()) != EOF && isspace(c)) /* skip */;
    if (c != EOF) unread_input_char(c);
}

/* ─── scanf(format, ...) ──────────────────────────────────────────────────── */
static void FlowCodeScanfFunc(struct ParseState *Parser, struct Value *ReturnValue,
                               struct Value **Param, int NumArgs) {
    (void)Parser;
    int matched = 0;
    const char *fmt = Param[0]->Val->Pointer;
    if (!fmt) { ReturnValue->Val->Integer = 0; return; }

    int arg_idx = 1;

    while (*fmt) {
        if (isspace((unsigned char)*fmt)) {
            skip_whitespace();
            fmt++;
            continue;
        }
        if (*fmt != '%') {
            int c = read_input_char();
            if (c != (unsigned char)*fmt) {
                if (c != EOF) unread_input_char(c);
                break;
            }
            fmt++;
            continue;
        }
        fmt++;
        if (!*fmt) break;

        int suppress = 0;
        int width = -1;
        if (*fmt == '*') { suppress = 1; fmt++; }
        if (*fmt && isdigit((unsigned char)*fmt)) {
            width = 0;
            while (*fmt && isdigit((unsigned char)*fmt)) {
                width = width * 10 + (*fmt - '0');
                fmt++;
            }
        }

        skip_whitespace();
        if (read_input_char() == EOF) break;
        unread_input_char(EOF);

        char spec = *fmt++;
        int store_ok = 0;

        switch (spec) {
        case 'd': case 'i': {
            int sign = 1;
            int base = (spec == 'i') ? 0 : 10;
            int c = read_input_char();
            int started = 0;
            long val = 0;
            if (c == '-') { sign = -1; c = read_input_char(); }
            else if (c == '+') { c = read_input_char(); }
            if (base == 0) {
                if (c == '0') {
                    c = read_input_char();
                    if (c == 'x' || c == 'X') { base = 16; c = read_input_char(); }
                    else { base = 8; if (c != EOF) unread_input_char(c); }
                } else { base = 10; if (c != EOF) unread_input_char(c); }
            } else if (base == 16) {
                if (c == '0') { int c2 = read_input_char();
                    if (c2 == 'x' || c2 == 'X') c = read_input_char(); else { if (c2 != EOF) unread_input_char(c2); } }
            }
            if (c == EOF) break;
            while (c != EOF && ((base == 16) ? isxdigit(c) : isdigit(c))) {
                int d = (c >= 'a') ? (c - 'a' + 10) : (c >= 'A') ? (c - 'A' + 10) : (c - '0');
                if (base != 16 && d >= base) { unread_input_char(c); break; }
                if (base == 16 && !isxdigit(c)) { unread_input_char(c); break; }
                val = val * base + d;
                started = 1;
                c = read_input_char();
                if (width > 0 && (--width == 0)) break;
            }
            if (c != EOF) unread_input_char(c);
            if (started) {
                val *= sign;
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        int *p = (int *)arg->Val->Pointer;
                        if (p) { *p = (int)val; store_ok = 1; }
                    } else if (arg->Typ->Base == TypeArray && arg->Typ->FromType->Base == TypeInt) {
                        int *p = (int *)&arg->Val->ArrayMem[0];
                        *p = (int)val; store_ok = 1;
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 'u': {
            int c = read_input_char();
            unsigned long val = 0;
            int started = 0;
            if (c == '+') c = read_input_char();
            while (c != EOF && isdigit(c)) {
                val = val * 10 + (unsigned)(c - '0');
                started = 1;
                c = read_input_char();
                if (width > 0 && (--width == 0)) break;
            }
            if (c != EOF) unread_input_char(c);
            if (started) {
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        unsigned int *p = (unsigned int *)arg->Val->Pointer;
                        if (p) { *p = (unsigned int)val; store_ok = 1; }
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 'o': {
            int c = read_input_char();
            long val = 0;
            int started = 0;
            while (c != EOF && c >= '0' && c <= '7') {
                val = val * 8 + (c - '0');
                started = 1;
                c = read_input_char();
                if (width > 0 && (--width == 0)) break;
            }
            if (c != EOF) unread_input_char(c);
            if (started) {
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        int *p = (int *)arg->Val->Pointer;
                        if (p) { *p = (int)val; store_ok = 1; }
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 'x': case 'X': {
            int c = read_input_char();
            long val = 0;
            int started = 0;
            while (c != EOF && isxdigit(c)) {
                int d = (c >= 'a') ? (c - 'a' + 10) : (c >= 'A') ? (c - 'A' + 10) : (c - '0');
                val = val * 16 + d;
                started = 1;
                c = read_input_char();
                if (width > 0 && (--width == 0)) break;
            }
            if (c != EOF) unread_input_char(c);
            if (started) {
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        int *p = (int *)arg->Val->Pointer;
                        if (p) { *p = (int)val; store_ok = 1; }
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 'f': case 'g': case 'e': case 'E': case 'G': case 'F': {
            int c = read_input_char();
            int started = 0;
            double val = 0.0;
            int sign = 1;
            if (c == '-') { sign = -1; c = read_input_char(); }
            else if (c == '+') { c = read_input_char(); }
            if (c == 'n' || c == 'N') {
                int c2 = read_input_char();
                if (c2 == 'a' || c2 == 'A') { int c3 = read_input_char();
                    if (c3 == 'n' || c3 == 'N') { val = NAN; started = 1; c = EOF; }
                    else { if (c3 != EOF) unread_input_char(c3); unread_input_char(c2); } }
                else { unread_input_char(c2); }
            }
            if (!started && c == 'i' || c == 'I') {
                int c2 = read_input_char();
                if (c2 == 'n' || c2 == 'N') { int c3 = read_input_char();
                    if (c3 == 'f' || c3 == 'F') { val = INFINITY * sign; started = 1; c = EOF; }
                    else { if (c3 != EOF) unread_input_char(c3); unread_input_char(c2); } }
                else { unread_input_char(c2); }
            }
            if (!started && c != EOF && (c == '.' || isdigit(c))) {
                double int_part = 0;
                while (c != EOF && isdigit(c)) {
                    int_part = int_part * 10.0 + (c - '0');
                    c = read_input_char();
                    if (width > 0 && (--width == 0)) break;
                }
                double frac_part = 0;
                double frac_div = 1;
                if (c == '.') {
                    c = read_input_char();
                    while (c != EOF && isdigit(c)) {
                        frac_part = frac_part * 10.0 + (c - '0');
                        frac_div *= 10.0;
                        c = read_input_char();
                        if (width > 0 && (--width == 0)) break;
                    }
                }
                val = int_part + frac_part / frac_div;
                if (c == 'e' || c == 'E') {
                    c = read_input_char();
                    int exp_sign = 1;
                    if (c == '-') { exp_sign = -1; c = read_input_char(); }
                    else if (c == '+') { c = read_input_char(); }
                    int exp = 0;
                    while (c != EOF && isdigit(c)) {
                        exp = exp * 10 + (c - '0');
                        c = read_input_char();
                        if (width > 0 && (--width == 0)) break;
                    }
                    val *= pow(10.0, exp_sign * exp);
                }
                started = 1;
            }
            if (c != EOF) unread_input_char(c);
            if (started) {
                val *= sign;
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        double *p = (double *)arg->Val->Pointer;
                        if (p) { *p = val; store_ok = 1; }
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 'c': {
            int c = read_input_char();
            if (c != EOF) {
                if (!suppress && arg_idx < NumArgs) {
                    struct Value *arg = Param[arg_idx];
                    if (arg->Typ->Base == TypePointer) {
                        char *p = (char *)arg->Val->Pointer;
                        if (p) { *p = (char)c; store_ok = 1; }
                    } else if (arg->Typ->Base == TypeArray && arg->Typ->FromType->Base == TypeChar) {
                        char *p = (char *)&arg->Val->ArrayMem[0];
                        *p = (char)c; store_ok = 1;
                    }
                }
                if (!suppress) { if (store_ok) arg_idx++; matched++; }
            }
            break;
        }
        case 's': {
            int c = read_input_char();
            while (c != EOF && isspace(c)) c = read_input_char();
            if (c == EOF) break;
            char buf[4096];
            int pos = 0;
            while (c != EOF && !isspace(c)) {
                buf[pos++] = (char)c;
                if (pos >= (int)sizeof(buf) - 1) break;
                c = read_input_char();
                if (width > 0 && (--width == 0)) break;
            }
            if (c != EOF) unread_input_char(c);
            buf[pos] = '\0';
            if (!suppress && arg_idx < NumArgs) {
                struct Value *arg = Param[arg_idx];
                if (arg->Typ->Base == TypePointer) {
                    char *p = (char *)arg->Val->Pointer;
                    if (p) { strcpy(p, buf); store_ok = 1; }
                } else if (arg->Typ->Base == TypeArray && arg->Typ->FromType->Base == TypeChar) {
                    char *p = (char *)&arg->Val->ArrayMem[0];
                    strcpy(p, buf); store_ok = 1;
                }
            }
            if (!suppress) { if (store_ok) arg_idx++; matched++; }
            break;
        }
        case '%': {
            int c = read_input_char();
            if (c != '%') { if (c != EOF) unread_input_char(c); break; }
            break;
        }
        default:
            break;
        }
        if (!store_ok && !suppress) break;
    }

    ReturnValue->Val->Integer = matched;
}

/* ─── abs / rand / srand (stdlib.h — not in CLibrary) ──────────────────── */
static void FlowCodeAbsFunc(struct ParseState *Parser, struct Value *ReturnValue,
                             struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    int n = Param[0]->Val->Integer;
    ReturnValue->Val->Integer = (n < 0) ? -n : n;
}
static void FlowCodeRandFunc(struct ParseState *Parser, struct Value *ReturnValue,
                              struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    ReturnValue->Val->Integer = rand();
}
static void FlowCodeSrandFunc(struct ParseState *Parser, struct Value *ReturnValue,
                               struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs; (void)ReturnValue;
    srand((unsigned int)Param[0]->Val->Integer);
}

/* ─── Function tables for each header ────────────────────────────────────
 *
 * Only functions that the CLibrary (clibrary.c) does NOT already provide.
 * CLibrary already provides: printf, getchar, exit, math, string functions.
 * We only add: scanf, putchar, puts, abs, rand, srand.
 */
struct LibraryFunction FlowCodeStdioFunctions[] = {
    { FlowCodeScanfFunc,    "int scanf(char *, ...);" },
    { FlowCodePutcharFunc,  "int putchar(int);" },
    { FlowCodePutsFunc,     "int puts(char *);" },
    { NULL, NULL }
};

struct LibraryFunction FlowCodeStdlibFunctions[] = {
    { FlowCodeAbsFunc,   "int abs(int);" },
    { FlowCodeRandFunc,  "int rand();" },
    { FlowCodeSrandFunc, "void srand(unsigned int);" },
    { NULL, NULL }
};

/* ─── Header setup functions ────────────────────────────────────────────── */

/* stdio.h: define FILE type, stdin/stdout/stderr, EOF */
static int   FlowCode_EOF_val   = -1;
static void *FlowCode_null_ptr  = NULL;
static void FlowCodeStdioSetup(Picoc *pc) {
    struct ValueType *StructFileType = TypeCreateOpaqueStruct(pc, NULL,
        TableStrRegister(pc, "__FILEStruct"), sizeof(void *));
    struct ValueType *FilePtrType = TypeGetMatching(pc, NULL, StructFileType,
        TypePointer, 0, pc->StrEmpty, TRUE);
    VariableDefinePlatformVar(pc, NULL, "stdin",  FilePtrType,
        (union AnyValue *)&FlowCode_null_ptr, FALSE);
    VariableDefinePlatformVar(pc, NULL, "stdout", FilePtrType,
        (union AnyValue *)&FlowCode_null_ptr, FALSE);
    VariableDefinePlatformVar(pc, NULL, "stderr", FilePtrType,
        (union AnyValue *)&FlowCode_null_ptr, FALSE);
    if (!VariableDefined(pc, TableStrRegister(pc, "EOF")))
        VariableDefinePlatformVar(pc, NULL, "EOF", &pc->IntType,
            (union AnyValue *)&FlowCode_EOF_val, FALSE);
}

static const char FlowCodeStdioDefs[] =
    "typedef struct __va_listStruct va_list; "
    "typedef struct __FILEStruct FILE;";

/* stdlib.h */
static int FlowCode_zero          = 0;
static int FlowCode_exit_success  = 0;
static int FlowCode_exit_failure  = 1;
void FlowCodeStdlibSetup(Picoc *pc) {
    if (!VariableDefined(pc, TableStrRegister(pc, "NULL")))
        VariableDefinePlatformVar(pc, NULL, "NULL", &pc->IntType,
            (union AnyValue *)&FlowCode_zero, FALSE);
    VariableDefinePlatformVar(pc, NULL, "EXIT_SUCCESS", &pc->IntType,
        (union AnyValue *)&FlowCode_exit_success, FALSE);
    VariableDefinePlatformVar(pc, NULL, "EXIT_FAILURE", &pc->IntType,
        (union AnyValue *)&FlowCode_exit_failure, FALSE);
}
/* math.h */
struct LibraryFunction FlowCodeMathFunctions[] = {
    { NULL, NULL }
};

/* string.h */
struct LibraryFunction FlowCodeStringFunctions[] = {
    { NULL, NULL }
};

/* stdbool.h */
static int FlowCode_true_val  = 1;
static int FlowCode_false_val = 0;
static int FlowCode_bool_defined_val = 1;
void FlowCodeStdboolSetup(Picoc *pc) {
    VariableDefinePlatformVar(pc, NULL, "true",  &pc->IntType,
        (union AnyValue *)&FlowCode_true_val, FALSE);
    VariableDefinePlatformVar(pc, NULL, "false", &pc->IntType,
        (union AnyValue *)&FlowCode_false_val, FALSE);
    VariableDefinePlatformVar(pc, NULL, "__bool_true_false_are_defined", &pc->IntType,
        (union AnyValue *)&FlowCode_bool_defined_val, FALSE);
}
static const char FlowCodeStdboolDefs[] = "typedef int bool;";

/* ─── Public registration entry point ────────────────────────────────────
 * Called from flowcode_runner.c after PicocInitialise().
 * Registers headers so that #include <stdio.h> etc. resolve to built-in
 * definitions instead of trying to read files from the filesystem.
 *
 * Only registers headers; the CLibrary functions (printf, getchar, strcpy,
 * etc.) are already available from PicocInitialise() -> CLibraryAdd().
 * We also register our own FlowCodeStdioFunctions (scanf, putchar, puts).
 */
void FlowCodeRegisterHeaders(Picoc *pc) {
    IncludeRegister(pc, "stdio.h",  FlowCodeStdioSetup,
                    FlowCodeStdioFunctions, FlowCodeStdioDefs);
    IncludeRegister(pc, "stdlib.h", FlowCodeStdlibSetup,
                    FlowCodeStdlibFunctions, NULL);
    IncludeRegister(pc, "math.h",   NULL,
                    FlowCodeMathFunctions, NULL);
    IncludeRegister(pc, "string.h", NULL,
                    FlowCodeStringFunctions, NULL);
    IncludeRegister(pc, "stdbool.h", FlowCodeStdboolSetup,
                    NULL, FlowCodeStdboolDefs);
    LOGD("Android stdlib headers registered (BUILTIN_MINI_STDLIB)");
}

#endif /* BUILTIN_MINI_STDLIB */
