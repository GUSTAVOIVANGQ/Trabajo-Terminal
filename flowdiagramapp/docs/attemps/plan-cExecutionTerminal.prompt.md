# FlowCode — C Execution Engine (PicoC + NDK)
## Instrucciones

---

## Contexto del proyecto

FlowCode es una aplicación Android nativa construida en **Flutter/Dart** que funciona como transpilador fuente-a-fuente: convierte diagramas de flujo ISO 5807 a código C99. El código C generado se muestra actualmente en la pestaña "Código" del widget `CompilerResultsDialog`.

El objetivo de esta tarea es agregar una **pestaña "Ejecutar"** (pestaña 7) al `CompilerResultsDialog` existente que permita ejecutar ese código C real, localmente, sin internet, sin root, en el dispositivo Android físico (Samsung Galaxy A26 5G, arm64-v8a).

---

## Restricción técnica crítica — leer antes de cualquier implementación

Android impone la política **W^X (Write XOR Execute)**: una región de memoria no puede ser escribible y ejecutable al mismo tiempo. Esto prohíbe cualquier enfoque que genere código máquina en tiempo de ejecución (JIT), incluyendo TCC/libtcc en modo JIT.

**La única arquitectura válida es:**

> Compilar un **intérprete de C puro** como biblioteca nativa `.so` con el NDK de Android, empaquetarlo dentro del APK en tiempo de compilación, y cargarlo con `System.loadLibrary()`. El intérprete ejecuta el árbol sintáctico del programa C directamente, sin generar código máquina en runtime.

La biblioteca elegida es **PicoC** — un intérprete de C escrito en C puro ANSI (~6,000 líneas, sin dependencias externas, sin JIT, sin generación de código máquina). PicoC soporta el subconjunto exacto que genera FlowCode.

No uses TCC, LLVM, Clang, GCC embebido, ni ningún enfoque que compile a código máquina en tiempo de ejecución. No uses `Process.run`, `Runtime.exec`, ni subprocesos para ejecutar binarios generados en tiempo de ejecución.

---

## Subconjunto de C que debe soportar el intérprete

El intérprete debe ejecutar correctamente todo el código que el generador de FlowCode puede producir. El generador está basado en el estándar C99 e ISO 5807. El subconjunto es:

### Totalmente soportado (obligatorio)

**Tipos de datos:**
- `int`, `float`, `double`, `char`
- `bool` (mediante `<stdbool.h>` o representación int 0/1)
- Arrays unidimensionales de los tipos anteriores (`int arr[10]`)

**Declaraciones y asignaciones:**
- Declaración con y sin inicialización: `int x;`, `int x = 5;`
- Asignación simple: `x = expr;`
- Operadores de asignación compuesta: `+=`, `-=`, `*=`, `/=`, `%=`
- Operadores de incremento/decremento: `x++`, `x--`, `++x`, `--x`

**Expresiones:**
- Aritméticas: `+`, `-`, `*`, `/`, `%`
- Relacionales: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Lógicas: `&&`, `||`, `!`
- Agrupación con paréntesis
- Expresiones compuestas: `resultado = (a + b) * c / 2`

**Estructuras de control:**
- `if (cond) { }`, `if (cond) { } else { }`
- `if / else if / else` anidados
- `while (cond) { }`
- `for (init; cond; update) { }`
- `do { } while (cond);`
- `break`, `continue` dentro de bucles
- `switch (expr) { case N: ... break; default: ... }`

**Funciones:**
- Función `main()` obligatoria como punto de entrada
- Funciones definidas por el usuario con y sin parámetros
- Funciones con retorno (`return expr;`) y sin retorno (`void`)
- Llamadas a funciones anidadas
- Recursión (con límite de profundidad de pila: máximo 500 niveles)

**E/S estándar:**
- `printf(formato, ...)` con especificadores `%d`, `%f`, `%lf`, `%c`, `%s`, `%i`, `%u`, `%o`, `%x`
- `scanf(formato, ...)` con los mismos especificadores más `&variable`
- Secuencias de escape en strings: `\n`, `\t`, `\\`, `\"`, `\0`

**Bibliotecas estándar mínimas (subset):**
- `<stdio.h>`: `printf`, `scanf`, `putchar`, `getchar`, `puts`
- `<stdlib.h>`: `abs`, `rand`, `srand`, `exit`
- `<math.h>`: `sqrt`, `pow`, `fabs`, `ceil`, `floor`, `sin`, `cos`, `tan`
- `<string.h>`: `strlen`, `strcpy`, `strcmp`, `strcat`

**Preprocesador básico:**
- `#include <header.h>` (las cabeceras anteriores)
- `#define CONSTANTE valor`

### Soportado con limitaciones documentadas (implementar con restricciones)

**Punteros (soporte básico limitado):**
- Puntero a variable escalar: `int *p = &x;`
- Desreferenciación: `*p = 5;`, `y = *p;`
- Paso de punteros a funciones: `void incrementar(int *n) { (*n)++; }`
- **Limitación explícita:** No se soporta aritmética de punteros (`p + 2`, `p++`), punteros a punteros (`int **pp`), ni punteros a funciones. Si el código usa estas construcciones, el intérprete debe emitir un mensaje claro de error de runtime (no crash silencioso).

**Strings como arrays de char:**
- `char nombre[20];`, `char saludo[] = "Hola";`
- Acceso por índice: `nombre[i]`
- **Limitación explícita:** Sin asignación directa de string a variable `char*` sin array (`char *p = "literal"` es read-only).

### Fuera de alcance (no implementar — emitir error claro si el código los contiene)

- `struct`, `union`, `enum` definidos por usuario
- Memoria dinámica: `malloc`, `calloc`, `realloc`, `free`
- Arrays multidimensionales: `int matriz[3][3]`
- Punteros a funciones: `int (*fp)(int)`
- Aritmética de punteros: `p + n`, `p - n`, `p++`
- `goto`
- Archivos: `fopen`, `fclose`, `fprintf`, `fscanf`
- Threads, señales, cualquier API del sistema operativo

---

## Arquitectura de la implementación

```
flowcode/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               ├── cpp/
│               │   ├── CMakeLists.txt          ← build del .so
│               │   ├── picoc/                  ← fuentes de PicoC (sin modificar)
│               │   │   ├── picoc.h
│               │   │   ├── interpreter.h
│               │   │   ├── platform.h
│               │   │   ├── *.c                 ← fuentes originales de PicoC
│               │   │   └── cstdlib/            ← implementaciones de stdlib
│               │   ├── flowcode_runner.h        ← interfaz pública
│               │   ├── flowcode_runner.c        ← envoltura JNI + sandbox
│               │   └── picoc_platform_android.c ← overrides de I/O para Android
│               └── kotlin/
│                   └── ...MainActivity.kt
└── lib/
    ├── services/
    │   └── c_execution_service.dart    ← servicio Dart (FFI/MethodChannel)
    ├── models/
    │   └── execution_result.dart       ← modelos de datos de ejecución
    └── widgets/
        └── compiler_results_dialog.dart ← agregar pestaña 7 aquí
```

---

## Paso 1 — Obtener y preparar PicoC

```bash
# Desde la raíz del proyecto Flutter
cd android/app/src/main/cpp/
git clone https://github.com/jnz/picoc.git picoc
```

PicoC está bajo licencia BSD. Verificar que el repositorio incluya los archivos:
`picoc.h`, `interpreter.h`, `platform.h`, `picoc.c`, `parse.c`, `expression.c`,
`lex.c`, `type.c`, `variable.c`, `clibrary.c` y el directorio `cstdlib/`.

No modificar los archivos de PicoC directamente. Todos los overrides van en archivos separados.

---

## Paso 2 — CMakeLists.txt

Crear `android/app/src/main/cpp/CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.22.1)
project(flowcode_runner)

# Arquitecturas objetivo: arm64-v8a y armeabi-v7a
# El build de Flutter ya filtra las arquitecturas correctas

# Fuentes de PicoC — incluir todos los .c del directorio picoc/
# excepto main.c (si existe, PicoC a veces incluye un main de ejemplo)
file(GLOB PICOC_SOURCES
    "picoc/*.c"
    "picoc/cstdlib/*.c"
)
list(FILTER PICOC_SOURCES EXCLUDE REGEX ".*main\\.c$")
list(FILTER PICOC_SOURCES EXCLUDE REGEX ".*platform_unix\\.c$")
list(FILTER PICOC_SOURCES EXCLUDE REGEX ".*platform_msvc\\.c$")

add_library(
    flowcode_runner
    SHARED
    ${PICOC_SOURCES}
    flowcode_runner.c
    picoc_platform_android.c
)

target_include_directories(flowcode_runner PRIVATE
    picoc/
)

# Definiciones requeridas por PicoC para compilar en Android/Bionic
target_compile_definitions(flowcode_runner PRIVATE
    PICOC_MATH_LIBRARY           # habilitar <math.h>
    UNIX_HOST                    # PicoC usa esto para seleccionar plataforma
    VER="FlowCode-1.0"           # versión del intérprete
    NO_DEBUGGER                  # deshabilitar debugger interactivo de PicoC
    STACK_SIZE=65536             # 64KB de pila para el intérprete
)

target_compile_options(flowcode_runner PRIVATE
    -Wall
    -O2
    -fstack-protector-strong
)

# Bibliotecas del sistema Android necesarias
target_link_libraries(flowcode_runner
    android
    log
    m        # libmath para funciones matemáticas
)
```

Registrar el CMakeLists en `android/app/build.gradle`:

```gradle
android {
    ...
    defaultConfig {
        ...
        externalNativeBuild {
            cmake {
                cppFlags ""
                arguments "-DANDROID_STL=none"
            }
        }
        ndk {
            abiFilters "arm64-v8a", "armeabi-v7a"
        }
    }
    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
            version "3.22.1"
        }
    }
}
```

---

## Paso 3 — Platform override de I/O para Android

Crear `android/app/src/main/cpp/picoc_platform_android.c`.

Este archivo implementa las funciones de plataforma que PicoC llama para I/O, reemplazando stdin/stdout/stderr del sistema por callbacks controlados desde Dart.

```c
#include "picoc/picoc.h"
#include "flowcode_runner.h"
#include <android/log.h>
#include <string.h>
#include <stdio.h>

#define LOG_TAG "FlowCodeRunner"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

// ─── Estado global del runner (una ejecución a la vez) ──────────────────────

static FlowCodeRunnerState* g_runner_state = NULL;

void flowcode_set_runner_state(FlowCodeRunnerState* state) {
    g_runner_state = state;
}

// ─── Interceptar printf / puts / putchar ────────────────────────────────────
//
// PicoC llama a estas funciones de la plataforma para output.
// Las redirigimos al buffer de salida del runner, que Dart lee.

void PlatformPrintf(Picoc *pc, const char *Format, ...) {
    char buffer[4096];
    va_list args;
    va_start(args, Format);
    vsnprintf(buffer, sizeof(buffer), Format, args);
    va_end(args);

    if (g_runner_state != NULL && g_runner_state->on_stdout != NULL) {
        g_runner_state->on_stdout(buffer, g_runner_state->callback_user_data);
    }
}

// ─── Interceptar scanf / getchar ────────────────────────────────────────────
//
// PicoC llama a esta función cuando el programa hace scanf().
// Bloqueamos hasta que Dart envíe una línea por la cola de stdin.

int PlatformGetChar(Picoc *pc) {
    if (g_runner_state == NULL || g_runner_state->on_stdin_request == NULL) {
        return EOF;
    }

    // Si el buffer de stdin tiene datos, consumir un carácter
    if (g_runner_state->stdin_buffer_pos < g_runner_state->stdin_buffer_len) {
        return (unsigned char)g_runner_state->stdin_buffer[g_runner_state->stdin_buffer_pos++];
    }

    // Buffer vacío: solicitar nueva línea a Dart (bloqueante)
    // on_stdin_request llena stdin_buffer y actualiza stdin_buffer_len
    int result = g_runner_state->on_stdin_request(
        g_runner_state->stdin_buffer,
        sizeof(g_runner_state->stdin_buffer),
        g_runner_state->callback_user_data
    );

    if (result <= 0) {
        return EOF;
    }

    g_runner_state->stdin_buffer_len = result;
    g_runner_state->stdin_buffer_pos = 0;
    return (unsigned char)g_runner_state->stdin_buffer[g_runner_state->stdin_buffer_pos++];
}

// ─── Control de instrucciones (sandbox anti-bucle-infinito) ─────────────────
//
// PicoC llama a esta función antes de ejecutar cada sentencia (si se configura).
// Aquí incrementamos el contador y abortamos si se excede el límite.

void PlatformInstructionTick(Picoc *pc) {
    if (g_runner_state == NULL) return;

    g_runner_state->instruction_count++;

    if (g_runner_state->cancelled) {
        PicocExitValue(pc, -2);  // código de salida especial: cancelado por usuario
    }

    if (g_runner_state->instruction_count > g_runner_state->max_instructions) {
        // Notificar a Dart que el límite fue alcanzado
        if (g_runner_state->on_stdout != NULL) {
            g_runner_state->on_stdout(
                "\n[FlowCode] Límite de instrucciones alcanzado (posible bucle infinito). Ejecución detenida.\n",
                g_runner_state->callback_user_data
            );
        }
        PicocExitValue(pc, -1);  // código de salida especial: timeout por instrucciones
    }
}
```

---

## Paso 4 — Interfaz JNI pública

Crear `android/app/src/main/cpp/flowcode_runner.h`:

```c
#ifndef FLOWCODE_RUNNER_H
#define FLOWCODE_RUNNER_H

#include <stddef.h>
#include <stdbool.h>
#include <jni.h>

// ─── Callbacks de I/O ───────────────────────────────────────────────────────

// Llamado cuando el programa produce output (stdout/stderr)
typedef void (*OnStdoutCallback)(const char* text, void* user_data);

// Llamado cuando el programa necesita input (scanf)
// Debe llenar `buffer` con la línea del usuario y retornar el número de bytes escritos.
// Retorna 0 o negativo si no hay más input disponible (EOF).
typedef int (*OnStdinRequestCallback)(char* buffer, int buffer_size, void* user_data);

// ─── Estado de una ejecución ────────────────────────────────────────────────

typedef struct {
    // Callbacks
    OnStdoutCallback   on_stdout;
    OnStdinRequestCallback on_stdin_request;
    void*              callback_user_data;

    // Control del sandbox
    long               instruction_count;
    long               max_instructions;    // recomendado: 500000
    bool               cancelled;           // Dart puede escribir true para cancelar

    // Buffer interno para stdin
    char               stdin_buffer[4096];
    int                stdin_buffer_len;
    int                stdin_buffer_pos;

    // Resultado
    int                exit_code;
    long               elapsed_ms;
} FlowCodeRunnerState;

// ─── Funciones JNI exportadas ────────────────────────────────────────────────

#ifdef __cplusplus
extern "C" {
#endif

// Ejecuta código C. Retorna exit_code del programa (0 = éxito).
// Esta función es bloqueante; llamarla desde un hilo separado.
JNIEXPORT jint JNICALL
Java_com_flowcode_app_CRunner_nativeRunC(
    JNIEnv* env,
    jobject thiz,
    jstring c_code,         // código C a ejecutar
    jstring stdin_lines,    // líneas de stdin pre-cargadas, separadas por '\n'
    jint    max_instructions,
    jobject callback_obj    // objeto Java/Kotlin que implementa los callbacks
);

// Cancela la ejecución en curso (safe to call desde cualquier hilo)
JNIEXPORT void JNICALL
Java_com_flowcode_app_CRunner_nativeCancelExecution(
    JNIEnv* env,
    jobject thiz
);

// Retorna la versión del intérprete
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeGetVersion(
    JNIEnv* env,
    jobject thiz
);

// Valida si el código C es syntácticamente válido sin ejecutarlo
// Retorna null si es válido, o un string con el error si no lo es
JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeValidateC(
    JNIEnv* env,
    jobject thiz,
    jstring c_code
);

#ifdef __cplusplus
}
#endif

#endif // FLOWCODE_RUNNER_H
```

---

## Paso 5 — Implementación JNI

Crear `android/app/src/main/cpp/flowcode_runner.c`:

```c
#include "flowcode_runner.h"
#include "picoc/picoc.h"
#include "picoc_platform_android.h"
#include <android/log.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

#define LOG_TAG "FlowCodeRunner"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Estado global — solo una ejecución simultánea
static FlowCodeRunnerState g_state;
static volatile bool g_execution_active = false;

// ─── Contexto para el hilo de ejecución ─────────────────────────────────────

typedef struct {
    char*  c_code;
    Picoc  picoc;
    int    exit_code;
} ExecThreadArgs;

static void* exec_thread_func(void* arg) {
    ExecThreadArgs* args = (ExecThreadArgs*)arg;

    // Inicializar PicoC
    PicocInitialise(&args->picoc, g_state.max_instructions > 0
        ? (int)g_state.max_instructions
        : 500000);

    // Registrar el hook de instrucción para el sandbox
    // (requiere que PicoC esté compilado con soporte para InstructionHook)
    args->picoc.InstructionHook = PlatformInstructionTick;

    int exit_val = 0;

    if (PicocSetupException(&args->picoc)) {
        // Error de parseo o runtime — PicoC ya llamó a PlatformPrintf con el error
        exit_val = 1;
    } else {
        // Parsear e interpretar el código
        PicocParse(&args->picoc, "program.c", args->c_code,
                   strlen(args->c_code), true, false);

        // Llamar a main()
        exit_val = PicocCallMain(&args->picoc, 0, NULL);
    }

    PicocCleanup(&args->picoc);
    args->exit_code = exit_val;
    return NULL;
}

// ─── nativeRunC ─────────────────────────────────────────────────────────────

JNIEXPORT jint JNICALL
Java_com_flowcode_app_CRunner_nativeRunC(
    JNIEnv* env,
    jobject thiz,
    jstring j_code,
    jstring j_stdin,
    jint    max_instructions,
    jobject callback_obj)
{
    if (g_execution_active) {
        LOGE("Ya hay una ejecución activa");
        return -99;
    }
    g_execution_active = true;

    // Convertir strings Java → C
    const char* c_code_ptr = (*env)->GetStringUTFChars(env, j_code, NULL);
    const char* stdin_ptr  = (*env)->GetStringUTFChars(env, j_stdin, NULL);

    char* c_code = strdup(c_code_ptr);

    // Preparar buffer de stdin con las líneas pre-cargadas
    size_t stdin_len = strlen(stdin_ptr);
    strncpy(g_state.stdin_buffer, stdin_ptr, sizeof(g_state.stdin_buffer) - 1);
    g_state.stdin_buffer[sizeof(g_state.stdin_buffer) - 1] = '\0';
    g_state.stdin_buffer_len = (int)strlen(g_state.stdin_buffer);
    g_state.stdin_buffer_pos = 0;

    (*env)->ReleaseStringUTFChars(env, j_code, c_code_ptr);
    (*env)->ReleaseStringUTFChars(env, j_stdin, stdin_ptr);

    // Configurar estado
    g_state.instruction_count = 0;
    g_state.max_instructions  = max_instructions > 0 ? max_instructions : 500000;
    g_state.cancelled         = false;
    g_state.exit_code         = 0;

    // Configurar callbacks hacia Java usando JNI
    // El callback_obj debe implementar la interfaz CRunnerCallback en Kotlin
    jclass cb_class = (*env)->GetObjectClass(env, callback_obj);
    jmethodID on_stdout_id = (*env)->GetMethodID(env, cb_class, "onStdout", "(Ljava/lang/String;)V");
    jmethodID on_stdin_id  = (*env)->GetMethodID(env, cb_class, "onStdinRequest", "()Ljava/lang/String;");

    // Almacenar referencias globales para usar desde callbacks
    // (implementación completa con GlobalRef omitida por brevedad — ver nota abajo)

    // Configurar el platform override con las referencias JNI
    flowcode_set_runner_state(&g_state);

    // Medir tiempo
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    // Ejecutar en hilo separado para poder aplicar timeout
    ExecThreadArgs exec_args = { .c_code = c_code, .exit_code = 0 };
    pthread_t exec_thread;
    pthread_create(&exec_thread, NULL, exec_thread_func, &exec_args);

    // Timeout de 10 segundos (wall-clock)
    struct timespec timeout;
    clock_gettime(CLOCK_REALTIME, &timeout);
    timeout.tv_sec += 10;

    int join_result = pthread_timedjoin_np(exec_thread, NULL, &timeout);
    if (join_result != 0) {
        // Timeout — forzar cancelación
        g_state.cancelled = true;
        pthread_cancel(exec_thread);
        pthread_join(exec_thread, NULL);

        // Notificar a Dart
        // (llamada al callback on_stdout con mensaje de timeout)
        LOGE("Ejecución cancelada por timeout (10s)");
        exec_args.exit_code = -3;
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    g_state.elapsed_ms = (end.tv_sec - start.tv_sec) * 1000
                       + (end.tv_nsec - start.tv_nsec) / 1000000;

    free(c_code);
    g_execution_active = false;
    flowcode_set_runner_state(NULL);

    return exec_args.exit_code;
}

// ─── nativeCancelExecution ───────────────────────────────────────────────────

JNIEXPORT void JNICALL
Java_com_flowcode_app_CRunner_nativeCancelExecution(
    JNIEnv* env, jobject thiz)
{
    g_state.cancelled = true;
    LOGI("Ejecución cancelada por el usuario");
}

// ─── nativeGetVersion ────────────────────────────────────────────────────────

JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeGetVersion(
    JNIEnv* env, jobject thiz)
{
    return (*env)->NewStringUTF(env, "PicoC-FlowCode 1.0 (arm64/arm)");
}

// ─── nativeValidateC ─────────────────────────────────────────────────────────

JNIEXPORT jstring JNICALL
Java_com_flowcode_app_CRunner_nativeValidateC(
    JNIEnv* env, jobject thiz, jstring j_code)
{
    const char* code = (*env)->GetStringUTFChars(env, j_code, NULL);

    Picoc pc;
    PicocInitialise(&pc, 0);
    char error_msg[512] = {0};
    bool has_error = false;

    if (PicocSetupException(&pc)) {
        strncpy(error_msg, pc.PicocExitBuf, sizeof(error_msg) - 1);
        has_error = true;
    } else {
        PicocParse(&pc, "validate.c", code, strlen(code), true, true); // dry-run
    }

    PicocCleanup(&pc);
    (*env)->ReleaseStringUTFChars(env, j_code, code);

    if (has_error) {
        return (*env)->NewStringUTF(env, error_msg);
    }
    return NULL; // null = válido
}
```

> **Nota para Claude Code:** Los callbacks JNI hacia Kotlin requieren manejar `GlobalRef` correctamente para evitar referencias colgantes. Implementar `(*env)->NewGlobalRef(env, callback_obj)` al inicio de `nativeRunC` y `(*env)->DeleteGlobalRef(env, global_cb)` al finalizar. El patrón completo se muestra en el archivo Kotlin de la sección siguiente.

---

## Paso 6 — Wrapper Kotlin

Crear `android/app/src/main/kotlin/com/flowcode/app/CRunner.kt`:

```kotlin
package com.flowcode.app

import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*

// Interfaz de callbacks llamada desde JNI (C)
interface CRunnerCallback {
    fun onStdout(text: String)
    fun onStdinRequest(): String  // bloqueante — llamada desde hilo nativo
}

// Eventos que emite el runner hacia Flutter
sealed class ExecutionEvent {
    data class Output(val text: String, val isError: Boolean = false) : ExecutionEvent()
    data class StdinPrompt(val promptText: String) : ExecutionEvent()  // cuando el programa hace scanf
    data class Completed(val exitCode: Int, val elapsedMs: Long) : ExecutionEvent()
    data class RuntimeError(val message: String) : ExecutionEvent()
    data class Cancelled(val reason: String) : ExecutionEvent()
}

object CRunner {

    init {
        System.loadLibrary("flowcode_runner")
    }

    // ─── JNI nativas ──────────────────────────────────────────────────────
    private external fun nativeRunC(
        cCode: String,
        stdinLines: String,
        maxInstructions: Int,
        callback: CRunnerCallback
    ): Int

    private external fun nativeCancelExecution()
    external fun nativeGetVersion(): String
    external fun nativeValidateC(cCode: String): String?

    // ─── API pública ───────────────────────────────────────────────────────

    /**
     * Ejecuta código C y retorna un Flow de eventos.
     *
     * @param cCode         Código C generado por FlowCode
     * @param stdinLines    Líneas de stdin pre-cargadas (separadas por \n).
     *                      Si está vacío, el runner solicitará input interactivo.
     * @param maxInstructions Límite de instrucciones (default: 500_000)
     */
    fun execute(
        cCode: String,
        stdinLines: String = "",
        maxInstructions: Int = 500_000
    ): Flow<ExecutionEvent> = channelFlow {

        val stdinChannel = Channel<String>(Channel.UNLIMITED)

        // Pre-cargar líneas de stdin si se proporcionaron
        if (stdinLines.isNotBlank()) {
            stdinLines.lines().forEach { line ->
                stdinChannel.trySend(line + "\n")
            }
        }

        val startTime = System.currentTimeMillis()

        val callback = object : CRunnerCallback {
            override fun onStdout(text: String) {
                trySend(ExecutionEvent.Output(text))
            }

            override fun onStdinRequest(): String {
                // Bloqueante desde el hilo nativo
                // Si hay líneas pre-cargadas, usarlas; si no, notificar a Flutter
                return runBlocking {
                    val line = stdinChannel.tryReceive().getOrNull()
                    if (line != null) {
                        line
                    } else {
                        // Notificar a la UI que necesita input del usuario
                        send(ExecutionEvent.StdinPrompt(""))
                        // Esperar la respuesta
                        stdinChannel.receive()
                    }
                }
            }
        }

        // Ejecutar en Dispatchers.IO para no bloquear el hilo principal
        val exitCode = withContext(Dispatchers.IO) {
            try {
                nativeRunC(cCode, "", maxInstructions, callback)
            } catch (e: Exception) {
                send(ExecutionEvent.RuntimeError(e.message ?: "Error desconocido"))
                -1
            }
        }

        val elapsed = System.currentTimeMillis() - startTime

        when (exitCode) {
            0        -> send(ExecutionEvent.Completed(0, elapsed))
            -1       -> send(ExecutionEvent.Cancelled("Límite de instrucciones alcanzado"))
            -2       -> send(ExecutionEvent.Cancelled("Cancelado por el usuario"))
            -3       -> send(ExecutionEvent.Cancelled("Timeout (10 segundos)"))
            else     -> send(ExecutionEvent.Completed(exitCode, elapsed))
        }
    }

    /** Envía una línea de input al programa en ejecución (para modo interactivo) */
    fun provideStdinLine(line: String) {
        // Implementar con el Channel de stdin
        // (la referencia al Channel debe mantenerse durante la ejecución)
    }

    /** Cancela la ejecución en curso */
    fun cancel() {
        nativeCancelExecution()
    }

    /** Valida el código C sin ejecutarlo. Retorna null si es válido, error string si no. */
    fun validate(cCode: String): String? = nativeValidateC(cCode)
}
```

---

## Paso 7 — Servicio Dart (MethodChannel)

Crear `lib/services/c_execution_service.dart`:

```dart
import 'dart:async';
import 'package:flutter/services.dart';

/// Eventos emitidos durante la ejecución
sealed class ExecutionEvent {}

class OutputEvent extends ExecutionEvent {
  final String text;
  final bool isError;
  OutputEvent(this.text, {this.isError = false});
}

class StdinPromptEvent extends ExecutionEvent {
  final String hint;
  StdinPromptEvent(this.hint);
}

class CompletedEvent extends ExecutionEvent {
  final int exitCode;
  final int elapsedMs;
  CompletedEvent(this.exitCode, this.elapsedMs);
}

class CancelledEvent extends ExecutionEvent {
  final String reason;
  CancelledEvent(this.reason);
}

class RuntimeErrorEvent extends ExecutionEvent {
  final String message;
  RuntimeErrorEvent(this.message);
}

/// Servicio de ejecución de código C
/// Comunica con el CRunner de Kotlin via MethodChannel
class CExecutionService {
  static const _channel = MethodChannel('com.flowcode.app/c_runner');
  static const _eventChannel = EventChannel('com.flowcode.app/c_runner_events');

  StreamSubscription? _eventSubscription;
  final StreamController<ExecutionEvent> _controller =
      StreamController<ExecutionEvent>.broadcast();

  /// Stream de eventos de ejecución
  Stream<ExecutionEvent> get events => _controller.stream;

  /// Inicia la ejecución del código C
  /// [cCode] — código C generado por FlowCode (ya compilado y validado)
  /// [preloadedStdin] — líneas de entrada pre-cargadas (modo batch)
  /// [maxInstructions] — límite del sandbox (default: 500,000)
  Future<void> execute({
    required String cCode,
    List<String> preloadedStdin = const [],
    int maxInstructions = 500000,
  }) async {
    _eventSubscription?.cancel();

    // Escuchar eventos desde Kotlin via EventChannel
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          _controller.add(_parseEvent(Map<String, dynamic>.from(event)));
        }
      },
      onError: (error) {
        _controller.add(RuntimeErrorEvent(error.toString()));
      },
    );

    await _channel.invokeMethod('execute', {
      'cCode': cCode,
      'stdinLines': preloadedStdin.join('\n'),
      'maxInstructions': maxInstructions,
    });
  }

  /// Envía una línea de input al programa cuando hace scanf()
  Future<void> provideInput(String line) async {
    await _channel.invokeMethod('provideInput', {'line': '$line\n'});
  }

  /// Cancela la ejecución en curso
  Future<void> cancel() async {
    await _channel.invokeMethod('cancel');
  }

  /// Valida el código C sin ejecutarlo
  Future<String?> validate(String cCode) async {
    return await _channel.invokeMethod<String>('validate', {'cCode': cCode});
  }

  /// Versión del intérprete
  Future<String> getVersion() async {
    return await _channel.invokeMethod<String>('getVersion') ?? 'desconocida';
  }

  ExecutionEvent _parseEvent(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'output':
        return OutputEvent(data['text'] as String,
            isError: data['isError'] as bool? ?? false);
      case 'stdin_prompt':
        return StdinPromptEvent(data['hint'] as String? ?? '');
      case 'completed':
        return CompletedEvent(
            data['exitCode'] as int, data['elapsedMs'] as int);
      case 'cancelled':
        return CancelledEvent(data['reason'] as String);
      case 'error':
        return RuntimeErrorEvent(data['message'] as String);
      default:
        return RuntimeErrorEvent('Evento desconocido: ${data['type']}');
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _controller.close();
  }
}
```

---

## Paso 8 — Pestaña "Ejecutar" en CompilerResultsDialog

Agregar la pestaña 7 al `CompilerResultsDialog` existente en
`lib/widgets/compiler_results_dialog.dart`.

### Especificación de la UI

```
┌──────────────────────────────────────────────────────────────┐
│  [Resumen][Léxico][AST][Semántico][Optimiz][Código][Ejecutar]│
├──────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐  │
│  │  Terminal                                    [🗑][⏹]   │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │                                                        │  │
│  │  $ Programa en ejecución...                            │  │
│  │                                                        │  │
│  │  Ingrese un número entero:                             │  │
│  │  > [campo de texto activo _____________] [Enviar ↵]   │  │
│  │                                                        │  │
│  │  Resultado: 42                             (verde)     │  │
│  │  Suma total: 420                           (verde)     │  │
│  │                                                        │  │
│  │  ✅ Proceso terminado con código 0 (0.18s)            │  │
│  └────────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────────┤
│  [▶ Ejecutar]          [⏹ Detener]       [🗑 Limpiar]       │
└──────────────────────────────────────────────────────────────┘
```

### Especificación de colores y comportamiento

| Tipo de línea | Color | Condición |
|---|---|---|
| Stdout normal | Verde claro (`#A5D6A7`) | Output del programa |
| Stderr / error | Rojo (`#EF9A9A`) | Errores de runtime |
| Input del usuario | Gris claro (`#B0BEC5`) | Lo que el usuario escribió |
| Prompt de stdin | Amarillo claro (`#FFF59D`) | "Ingrese un valor:" |
| Mensaje del sistema | Cian (`#80DEEA`) | Mensajes de FlowCode |
| Resultado final | Blanco | Línea de estado final |

### Comportamiento del campo de input

- El campo de texto y el botón "Enviar" solo están activos cuando hay un `StdinPromptEvent` pendiente.
- Mientras no haya prompt activo, el campo está deshabilitado y muestra hint `"Esperando scanf..."`.
- Al recibir `StdinPromptEvent`, el campo se activa y toma el foco automáticamente.
- Al presionar "Enviar" o Enter, se llama a `CExecutionService.provideInput(text)` y el campo se limpia.
- La línea enviada se agrega al terminal con prefijo `"> "` en gris.

### Estado del botón "Ejecutar"

- **Habilitado** solo cuando: la compilación fue exitosa Y hay código C generado Y no hay ejecución en curso.
- **Deshabilitado con tooltip** si la compilación tiene errores: `"Corrige los errores de compilación antes de ejecutar"`.
- Durante la ejecución: el botón muestra spinner y texto `"Ejecutando..."`.

### Integración con el estado existente del diálogo

No romper las pestañas 1–6 existentes. La pestaña 7 es aditiva. El código C que se ejecuta es exactamente el mismo `generatedCode` que ya usa la pestaña "Código" (pestaña 6). No duplicar la generación de código.

---

## Paso 9 — Casos de prueba que debe pasar el intérprete

Implementar pruebas en `test/c_runner_test.dart`. El intérprete debe ejecutar correctamente todos estos casos:

```dart
// TC-01: Hello World básico
'''
#include <stdio.h>
int main() {
    printf("Hola FlowCode\\n");
    return 0;
}
'''
// Esperado stdout: "Hola FlowCode\n"

// TC-02: Variables y aritmética
'''
#include <stdio.h>
int main() {
    int a = 10, b = 3;
    printf("%d %d %d %d %d\\n", a+b, a-b, a*b, a/b, a%b);
    return 0;
}
'''
// Esperado: "13 7 30 3 1\n"

// TC-03: if/else
'''
#include <stdio.h>
int main() {
    int x = 7;
    if (x > 5) {
        printf("mayor\\n");
    } else {
        printf("menor\\n");
    }
    return 0;
}
'''
// Esperado: "mayor\n"

// TC-04: while con acumulador
'''
#include <stdio.h>
int main() {
    int suma = 0, i = 1;
    while (i <= 10) {
        suma += i;
        i++;
    }
    printf("%d\\n", suma);
    return 0;
}
'''
// Esperado: "55\n"

// TC-05: for con contador
'''
#include <stdio.h>
int main() {
    for (int i = 0; i < 5; i++) {
        printf("%d ", i);
    }
    printf("\\n");
    return 0;
}
'''
// Esperado: "0 1 2 3 4 \n"

// TC-06: Función definida por usuario
'''
#include <stdio.h>
int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
int main() {
    printf("%d\\n", factorial(5));
    return 0;
}
'''
// Esperado: "120\n"

// TC-07: scanf con valor pre-cargado
// stdin pre-cargado: "42\n"
'''
#include <stdio.h>
int main() {
    int n;
    scanf("%d", &n);
    printf("Doble: %d\\n", n * 2);
    return 0;
}
'''
// Esperado stdout: "Doble: 84\n"

// TC-08: do-while
'''
#include <stdio.h>
int main() {
    int i = 0;
    do {
        printf("%d\\n", i);
        i++;
    } while (i < 3);
    return 0;
}
'''
// Esperado: "0\n1\n2\n"

// TC-09: switch/case
'''
#include <stdio.h>
int main() {
    int opcion = 2;
    switch (opcion) {
        case 1: printf("uno\\n"); break;
        case 2: printf("dos\\n"); break;
        default: printf("otro\\n");
    }
    return 0;
}
'''
// Esperado: "dos\n"

// TC-10: Array unidimensional
'''
#include <stdio.h>
int main() {
    int arr[5] = {10, 20, 30, 40, 50};
    int suma = 0;
    for (int i = 0; i < 5; i++) suma += arr[i];
    printf("%d\\n", suma);
    return 0;
}
'''
// Esperado: "150\n"

// TC-11: Puntero básico (soportado con limitaciones)
'''
#include <stdio.h>
void incrementar(int *n) { (*n)++; }
int main() {
    int x = 5;
    incrementar(&x);
    printf("%d\\n", x);
    return 0;
}
'''
// Esperado: "6\n"

// TC-12: float y double
'''
#include <stdio.h>
#include <math.h>
int main() {
    double r = 3.0;
    printf("%.4f\\n", 3.14159265 * r * r);
    return 0;
}
'''
// Esperado: "28.2743\n" (con tolerancia de ±0.0001)

// TC-13: Sandbox — bucle infinito debe ser detenido
'''
#include <stdio.h>
int main() {
    while (1) { }
    return 0;
}
'''
// Esperado: CancelledEvent con reason "Límite de instrucciones alcanzado"
// Tiempo máximo: 5 segundos

// TC-14: break y continue
'''
#include <stdio.h>
int main() {
    for (int i = 0; i < 10; i++) {
        if (i == 3) continue;
        if (i == 6) break;
        printf("%d ", i);
    }
    printf("\\n");
    return 0;
}
'''
// Esperado: "0 1 2 4 5 \n"

// TC-15: String y strlen
'''
#include <stdio.h>
#include <string.h>
int main() {
    char msg[] = "FlowCode";
    printf("%lu\\n", strlen(msg));
    return 0;
}
'''
// Esperado: "8\n"
```

---

## Paso 10 — Configuración del MethodChannel en Kotlin (MainActivity)

En `android/app/src/main/kotlin/com/flowcode/app/MainActivity.kt`, registrar los canales:

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.flowcode.app/c_runner"
    private val EVENT_CHANNEL  = "com.flowcode.app/c_runner_events"

    private var eventSink: EventChannel.EventSink? = null
    private var currentExecutionJob: kotlinx.coroutines.Job? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // EventChannel para streaming de eventos al Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                }
                override fun onCancel(args: Any?) {
                    eventSink = null
                }
            })

        // MethodChannel para llamadas desde Flutter
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "execute" -> {
                        val cCode = call.argument<String>("cCode") ?: ""
                        val stdinLines = call.argument<String>("stdinLines") ?: ""
                        val maxInstr = call.argument<Int>("maxInstructions") ?: 500000

                        // Lanzar ejecución en coroutine
                        currentExecutionJob = kotlinx.coroutines.MainScope().launch {
                            CRunner.execute(
                                cCode = cCode,
                                stdinLines = stdinLines,
                                maxInstructions = maxInstr
                            ).collect { event ->
                                eventSink?.success(event.toMap())
                            }
                        }
                        result.success(null)
                    }

                    "cancel" -> {
                        CRunner.cancel()
                        currentExecutionJob?.cancel()
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

// Extensión para serializar eventos a Map para Flutter
fun ExecutionEvent.toMap(): Map<String, Any?> = when (this) {
    is ExecutionEvent.Output    -> mapOf("type" to "output",   "text" to text, "isError" to isError)
    is ExecutionEvent.StdinPrompt -> mapOf("type" to "stdin_prompt", "hint" to hint)
    is ExecutionEvent.Completed -> mapOf("type" to "completed", "exitCode" to exitCode, "elapsedMs" to elapsedMs)
    is ExecutionEvent.Cancelled -> mapOf("type" to "cancelled", "reason" to reason)
    is ExecutionEvent.RuntimeError -> mapOf("type" to "error",  "message" to message)
}
```

---

## Límites del sandbox (valores de producción)

| Parámetro | Valor | Justificación |
|---|---|---|
| `max_instructions` | 500,000 | Suficiente para algoritmos complejos; detiene bucles infinitos en < 1s |
| `timeout_wall_clock` | 10 segundos | Permite scanf interactivo sin timeout prematuro |
| `max_recursion_depth` | 500 niveles | Evita stack overflow del proceso Flutter |
| `max_output_chars` | 100,000 chars | Evita que un printf en bucle llene la memoria |
| `stdin_buffer_size` | 4,096 bytes | Suficiente para una línea de entrada razonable |

Implementar el límite de output en `PlatformPrintf`: llevar un contador acumulado de caracteres enviados; si supera `max_output_chars`, llamar `PicocExitValue` con código -4 y emitir mensaje de error.

---

## Qué NO implementar

- No implementar ejecución remota ni llamadas a APIs externas.
- No implementar compilación a código máquina nativo (TCC, Clang, GCC en runtime).
- No implementar soporte para múltiples ejecuciones simultáneas.
- No implementar filesystem access desde el código C ejecutado (ni `fopen`, ni `system()`).
- No implementar punteros a funciones, aritmética de punteros, ni `void*` genérico.
- No modificar el pipeline de compilación de FlowCode (`DiagramCompilerPipeline`), ni las pestañas 1–6 del `CompilerResultsDialog`. Esta feature es completamente aditiva.

---

## Verificación de que todo funciona

```bash
# 1. Compilar el proyecto con las fuentes NDK
flutter build apk --target-platform android-arm64

# 2. Verificar que el .so fue incluido en el APK
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep libflowcode_runner

# 3. Instalar y probar en dispositivo físico
flutter install
flutter run

# 4. Ejecutar las pruebas unitarias del runner
flutter test test/c_runner_test.dart

# 5. Verificar que no hay crash en ejecución de bucle infinito (TC-13)
# La app debe mostrar el mensaje de límite de instrucciones y seguir funcionando
```

---

## Errores comunes y cómo resolverlos

**Error: `undefined symbol: PicocInitialise`**
→ PicoC no está incluido correctamente en `CMakeLists.txt`. Verificar que todos los `.c` de `picoc/` estén en el `file(GLOB ...)`.

**Error: `Permission denied` al ejecutar código**
→ Nunca intentar ejecutar un binario en filesystem. PicoC interpreta en memoria, no hay binarios.

**Error: `System.loadLibrary("flowcode_runner") failed`**
→ El nombre de la biblioteca en CMakeLists debe ser exactamente `flowcode_runner` (sin prefijo `lib`). Android agrega `lib` automáticamente.

**Error: `NoSuchMethodError` en la función JNI**
→ El nombre de la función C debe coincidir exactamente con el package + clase + método en Kotlin: `Java_com_flowcode_app_CRunner_nativeRunC`.

**PicoC no compila para Android (bionic libc)**
→ Agregar al `CMakeLists.txt`: `-DUSE_READLINE_LIBRARY=0` y `-DNO_HEADER_GUARD`. Bionic no tiene todas las funciones de glibc. Revisar los `#ifdef` en `platform.h` de PicoC y asegurarse de que `UNIX_HOST` esté definido.

**scanf nunca retorna**
→ El modelo de stdin pre-cargado evita este problema para el MVP. Si se implementa stdin interactivo, el `Channel<String>` en Kotlin debe tener un mecanismo de timeout propio de 30 segundos para evitar que el hilo nativo quede bloqueado indefinidamente.

---

*Documento generado para FlowCode TT 2026-A038 — Versión 1.0*
