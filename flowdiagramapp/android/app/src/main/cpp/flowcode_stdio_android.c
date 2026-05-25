/*
 * flowcode_stdio_android.c
 * Android-safe stdio replacement for PicoC.
 *
 * This replaces picoc/cstdlib/stdio.c to route printf/scanf/putchar/puts/getchar
 * through PlatformPutc/PlatformGetCharacter so Flutter can capture output.
 */

#include "picoc/picoc.h"
#include "picoc/interpreter.h"
#include "picoc/platform.h"
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

/* --- Output helpers --- */
static void write_output_char(unsigned char c) {
    PlatformPutc(c, NULL);
}

static void write_output_str(const char *s) {
    if (s == NULL) return;
    while (*s) {
        write_output_char((unsigned char)*s++);
    }
}

/* --- Basic IO init (called from PicocInitialise) --- */
void BasicIOInit(Picoc *pc) {
    pc->CStdOut = stdout;
}

/* --- Minimal printing used by error reporting --- */
void PrintCh(char OutCh, FILE *Stream) {
    (void)Stream;
    write_output_char((unsigned char)OutCh);
}

void PrintSimpleInt(long Num, FILE *Stream) {
    (void)Stream;
    char buf[32];
    snprintf(buf, sizeof(buf), "%ld", Num);
    write_output_str(buf);
}

void PrintStr(const char *Str, FILE *Stream) {
    (void)Stream;
    write_output_str(Str);
}

void PrintFP(double Num, FILE *Stream) {
    (void)Stream;
    char buf[64];
    snprintf(buf, sizeof(buf), "%f", Num);
    write_output_str(buf);
}

/* --- Simple scanf support --- */
static int s_pushback = EOF;

static int read_input_char(void) {
    if (s_pushback != EOF) {
        int c = s_pushback;
        s_pushback = EOF;
        return c;
    }
    return PlatformGetCharacter();
}

static void unread_input_char(int c) {
    if (c != EOF) s_pushback = c;
}

static void skip_whitespace(void) {
    int c;
    while ((c = read_input_char()) != EOF && isspace(c)) {
    }
    if (c != EOF) unread_input_char(c);
}

static void StdioScanf(struct ParseState *Parser, struct Value *ReturnValue,
                       struct Value **Param, int NumArgs) {
    (void)Parser;
    int matched = 0;
    const char *fmt = Param[0]->Val->Pointer;
    if (fmt == NULL) {
        ReturnValue->Val->Integer = 0;
        return;
    }

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
        {
            int c = read_input_char();
            if (c == EOF) break;
            unread_input_char(c);
        }

        char spec = *fmt++;
        int store_ok = 0;

        switch (spec) {
            case 'd':
            case 'i': {
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
                    } else {
                        base = 10;
                        if (c != EOF) unread_input_char(c);
                    }
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
            case 'x':
            case 'X': {
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
            case 'f':
            case 'g':
            case 'e':
            case 'E':
            case 'G':
            case 'F': {
                int c = read_input_char();
                int started = 0;
                double val = 0.0;
                int sign = 1;
                if (c == '-') { sign = -1; c = read_input_char(); }
                else if (c == '+') { c = read_input_char(); }

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

/* --- Simple printf support --- */
static void StdioPrintf(struct ParseState *Parser, struct Value *ReturnValue,
                        struct Value **Param, int NumArgs) {
    (void)Parser;
    const char *fmt = Param[0]->Val->Pointer;
    if (fmt == NULL) {
        ReturnValue->Val->Integer = 0;
        return;
    }

    int argIndex = 1;
    int written = 0;

    for (const char *p = fmt; *p; ) {
        if (*p != '%') {
            write_output_char((unsigned char)*p++);
            written++;
            continue;
        }
        p++;
        if (*p == '%') {
            write_output_char('%');
            p++;
            written++;
            continue;
        }

        char fmtBuf[32];
        int fmtLen = 0;
        fmtBuf[fmtLen++] = '%';
        while (*p && !strchr("diuoxXfFeEgGcs", *p)) {
            if (fmtLen < (int)sizeof(fmtBuf) - 2) {
                fmtBuf[fmtLen++] = *p;
            }
            p++;
        }
        if (!*p) break;
        char spec = *p++;
        fmtBuf[fmtLen++] = spec;
        fmtBuf[fmtLen] = '\0';

        if (argIndex >= NumArgs) continue;
        struct Value *arg = Param[argIndex++];

        char out[128];
        out[0] = '\0';

        switch (spec) {
            case 'd':
            case 'i': {
                long v = ExpressionCoerceInteger(arg);
                snprintf(out, sizeof(out), fmtBuf, v);
                break;
            }
            case 'u':
            case 'o':
            case 'x':
            case 'X': {
                unsigned long v = ExpressionCoerceUnsignedInteger(arg);
                snprintf(out, sizeof(out), fmtBuf, v);
                break;
            }
            case 'f':
            case 'F':
            case 'e':
            case 'E':
            case 'g':
            case 'G': {
                double v = ExpressionCoerceFP(arg);
                snprintf(out, sizeof(out), fmtBuf, v);
                break;
            }
            case 'c': {
                int v = (int)ExpressionCoerceUnsignedInteger(arg);
                snprintf(out, sizeof(out), fmtBuf, v);
                break;
            }
            case 's': {
                const char *s = NULL;
                if (arg->Typ->Base == TypePointer) {
                    s = (const char *)arg->Val->Pointer;
                } else if (arg->Typ->Base == TypeArray &&
                           arg->Typ->FromType->Base == TypeChar) {
                    s = (const char *)&arg->Val->ArrayMem[0];
                }
                if (s == NULL) s = "(null)";
                snprintf(out, sizeof(out), fmtBuf, s);
                break;
            }
            default:
                break;
        }

        if (out[0] != '\0') {
            write_output_str(out);
            written += (int)strlen(out);
        }
    }

    ReturnValue->Val->Integer = written;
}

static void StdioPutchar(struct ParseState *Parser, struct Value *ReturnValue,
                         struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    int ch = Param[0]->Val->Integer;
    write_output_char((unsigned char)ch);
    ReturnValue->Val->Integer = ch;
}

static void StdioPuts(struct ParseState *Parser, struct Value *ReturnValue,
                      struct Value **Param, int NumArgs) {
    (void)Parser; (void)NumArgs;
    const char *s = (const char *)Param[0]->Val->Pointer;
    if (s) write_output_str(s);
    write_output_char('\n');
    ReturnValue->Val->Integer = 1;
}

static void StdioGetchar(struct ParseState *Parser, struct Value *ReturnValue,
                         struct Value **Param, int NumArgs) {
    (void)Parser; (void)Param; (void)NumArgs;
    ReturnValue->Val->Integer = PlatformGetCharacter();
}

/* --- stdio.h registration --- */
static int s_stdio_eof = -1;
static void *s_null_ptr = NULL;

void StdioSetupFunc(Picoc *pc) {
    struct ValueType *StructFileType = TypeCreateOpaqueStruct(pc, NULL,
        TableStrRegister(pc, "__FILEStruct"), sizeof(void *));
    struct ValueType *FilePtrType = TypeGetMatching(pc, NULL, StructFileType,
        TypePointer, 0, pc->StrEmpty, TRUE);
    VariableDefinePlatformVar(pc, NULL, "stdin",  FilePtrType,
        (union AnyValue *)&s_null_ptr, FALSE);
    VariableDefinePlatformVar(pc, NULL, "stdout", FilePtrType,
        (union AnyValue *)&s_null_ptr, FALSE);
    VariableDefinePlatformVar(pc, NULL, "stderr", FilePtrType,
        (union AnyValue *)&s_null_ptr, FALSE);
    if (!VariableDefined(pc, TableStrRegister(pc, "EOF"))) {
        VariableDefinePlatformVar(pc, NULL, "EOF", &pc->IntType,
            (union AnyValue *)&s_stdio_eof, FALSE);
    }
}

const char StdioDefs[] =
    "typedef struct __va_listStruct va_list; "
    "typedef struct __FILEStruct FILE;";

struct LibraryFunction StdioFunctions[] = {
    { StdioPrintf,  "int printf(char *, ...);" },
    { StdioScanf,   "int scanf(char *, ...);" },
    { StdioPutchar, "int putchar(int);" },
    { StdioGetchar, "int getchar();" },
    { StdioPuts,    "int puts(char *);" },
    { NULL, NULL }
};
