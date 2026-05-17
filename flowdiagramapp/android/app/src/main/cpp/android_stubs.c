/*
 * android_stubs.c
 * Provides stub implementations for POSIX library functions that
 * include.c references but whose source files are excluded from the
 * Android build due to Bionic incompatibilities.
 *
 * Stubs provided:
 *   - StdErrnoSetupFunc  (from errno.c  — excluded)
 *   - UnistdSetupFunc    (from unistd.c — excluded)
 *   - UnistdFunctions[]  (from unistd.c — excluded)
 *   - UnistdDefs         (from unistd.c — excluded)
 *   - PicocPlatformScanFile (from platform_unix.c — excluded)
 */

#include "picoc/picoc.h"
#include "picoc/interpreter.h"
#include <android/log.h>

#define LOG_TAG "FlowCodeStubs"

/* ── errno.h stub ───────────────────────────────────────────────────────── */
/* errno.c registers global errno constants into PicoC's variable table.
 * We skip this entirely — user C programs that include <errno.h> will not
 * get errno constants pre-defined, but FlowCode does not generate code
 * that uses errno, so this is safe. */
void StdErrnoSetupFunc(Picoc *pc)
{
    (void)pc;
    /* intentionally empty */
}

/* ── unistd.h stub ──────────────────────────────────────────────────────── */
/* unistd.c provides POSIX syscall wrappers not available on Android Bionic.
 * We register an empty function table so that <unistd.h> can be included
 * in C programs without error, but none of the POSIX syscalls will work
 * (FlowCode does not generate calls to them). */

const char UnistdDefs[] = "";   /* no type definitions needed */

struct LibraryFunction UnistdFunctions[] =
{
    { NULL, NULL }              /* empty function table */
};

void UnistdSetupFunc(Picoc *pc)
{
    (void)pc;
    /* intentionally empty */
}

/* ── PicocPlatformScanFile stub ─────────────────────────────────────────── */
/* platform_unix.c provides this, but we don't include it.
 * FlowCode passes the entire C source as a string to PicocParse() —
 * it never tries to open a real file — so this stub is never called.
 * If it somehow is called, log a warning and return gracefully. */
void PicocPlatformScanFile(Picoc *pc, const char *FileName)
{
    __android_log_print(ANDROID_LOG_WARN, LOG_TAG,
        "PicocPlatformScanFile called for '%s' — file I/O not supported on Android",
        FileName ? FileName : "(null)");
    (void)pc;
}
