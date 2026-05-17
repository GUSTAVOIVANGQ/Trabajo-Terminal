cmake_minimum_required(VERSION 3.22.1)
project(flowcode_runner C)

# ── PicoC sources ─────────────────────────────────────────────────────────
# Gather all .c files from picoc/ (root level only) and picoc/cstdlib/
# Excludes:
#   • picoc/picoc.c      — standalone main() binary entry point
#   • picoc/cstdlib/unistd.c — uses POSIX functions unavailable in Android
#                              Bionic (confstr, ctermid, getdtablesize,
#                              gethostid, getlogin_r, getpass, lockf, ualarm)
# Note: picoc/platform/ is a subdirectory not matched by picoc/*.c glob,
#       so platform_unix.c is automatically excluded. We provide our own
#       Android platform overrides in picoc_platform_android.c.
file(GLOB PICOC_CORE_SOURCES "picoc/*.c")
file(GLOB PICOC_STDLIB_SOURCES "picoc/cstdlib/*.c")

# Remove the standalone binary entry point
list(FILTER PICOC_CORE_SOURCES EXCLUDE REGEX ".*[/\\\\]picoc\\.c$")

# Remove cstdlib files that use POSIX functions unavailable in Android Bionic:
#   unistd.c — confstr, ctermid, getdtablesize, gethostid, lockf, ualarm...
#   string.c — index(), rindex() (BSD aliases; not in Bionic)
#   errno.c  — references non-portable Linux errno constants
list(FILTER PICOC_STDLIB_SOURCES EXCLUDE REGEX ".*[/\\\\]unistd\\.c$")
list(FILTER PICOC_STDLIB_SOURCES EXCLUDE REGEX ".*[/\\\\]string\\.c$")
list(FILTER PICOC_STDLIB_SOURCES EXCLUDE REGEX ".*[/\\\\]errno\\.c$")

# ── Shared library ────────────────────────────────────────────────────────
add_library(
    flowcode_runner
    SHARED
    ${PICOC_CORE_SOURCES}
    ${PICOC_STDLIB_SOURCES}
    string_android.c          # Android-compatible replacement for string.c
    android_stubs.c           # Stubs for excluded POSIX symbols (errno, unistd, PicocPlatformScanFile)
    picoc_platform_android.c
    flowcode_runner.c
)

# PicoC needs its own directory on the include path
target_include_directories(flowcode_runner PRIVATE
    picoc/
)

# ── Compile definitions required by PicoC ─────────────────────────────────
#
# UNIX_HOST  — activates the setjmp-based exit-point path in platform.c.
#              It also auto-defines PICOC_MATH_LIBRARY and USE_READLINE
#              inside platform.h, so we must NOT pass those from here
#              (double definition causes -Wmacro-redefined warnings).
#
# USE_READLINE is auto-set by platform.h when UNIX_HOST is defined, but
# Android has no readline library, so we undefine it after the fact via a
# negative define trick — instead we override it with an empty macro using
# a cmake COMPILE_OPTIONS -U flag below.
#
# NO_DEBUGGER is intentionally OMITTED: platform.c calls DebugInit() and
# DebugCleanup() unconditionally; those symbols are inside
# #ifndef NO_DEBUGGER in debug.c, so omitting the flag avoids link errors.
target_compile_definitions(flowcode_runner PRIVATE
    UNIX_HOST           # main platform selector; enables setjmp exit + malloc heap
    STACK_SIZE=65536    # 64 KB interpreter stack (used in flowcode_runner.c)
)

target_compile_options(flowcode_runner PRIVATE
    # Undefine USE_READLINE which platform.h sets automatically with UNIX_HOST.
    # Android Bionic has no readline library, so we must disable it.
    -UUSE_READLINE

    -Wall
    -Wno-unused-parameter
    -Wno-macro-redefined      # silence the PICOC_MATH_LIBRARY redefinition
    -O2
    -fstack-protector-strong
)

# ── Android system libraries ───────────────────────────────────────────────
target_link_libraries(flowcode_runner
    android
    log
    m          # libm — needed by cstdlib/math.c
    # NOTE: sem_init/sem_timedwait/sem_post are in libc on Android (no -lrt)
)
