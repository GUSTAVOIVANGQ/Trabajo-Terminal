# Tema 22: Integración del Pipeline Completo

## Trabajo Terminal 2026-A038 - FlowCode
### Ciclo 6: Integración

---

## 22.1 Flujo de conversión End-to-End

El pipeline de conversión de FlowCode transforma diagramas de flujo visuales en código C ejecutable a través de un proceso de 5 fases secuenciales. Esta sección documenta el flujo completo desde la entrada hasta la salida.

### 22.1.1 Entrada: Diagramas de Flujo (Nodos y Conexiones)

La entrada del conversor consiste en dos estructuras de datos fundamentales:

#### Estructura DiagramNode

```dart
/// Representación de un nodo del diagrama
class DiagramNode {
  final String id;                    // Identificador único
  final NodeType type;                // Tipo de símbolo ISO 5807
  final Offset position;              // Posición en el canvas
  final String text;                  // Contenido textual (código/etiqueta)
  final Map<String, dynamic> metadata; // Metadatos adicionales
  
  // Propiedades visuales
  final Size size;
  final Color color;
  // ...
}
```

#### Estructura Connection

```dart
/// Representación de una conexión entre nodos
class Connection {
  final DiagramNode source;    // Nodo origen
  final DiagramNode target;    // Nodo destino
  final String label;          // Etiqueta (Sí/No, Verdadero/Falso)
  final bool isLoopBack;       // Indica si es retorno de bucle
  // ...
}
```

#### Ejemplo de Entrada

```dart
// Diagrama: Inicio -> int x = 5 -> Escribir x -> Fin
final nodes = [
  DiagramNode(id: 'n1', type: NodeType.terminal, text: 'Inicio', ...),
  DiagramNode(id: 'n2', type: NodeType.process, text: 'int x = 5', ...),
  DiagramNode(id: 'n3', type: NodeType.data, text: 'Escribir x', ...),
  DiagramNode(id: 'n4', type: NodeType.terminal, text: 'Fin', ...),
];

final connections = [
  Connection(source: nodes[0], target: nodes[1]),
  Connection(source: nodes[1], target: nodes[2]),
  Connection(source: nodes[2], target: nodes[3]),
];
```

### 22.1.2 Salida: Código C válido y funcional

El conversor genera código C ANSI estándar que puede ser convertido directamente con GCC u otro conversor C compatible.

#### Estructura del Código Generado

```c
/* ═══════════════════════════════════════════════════════════════════
 * Código generado por FlowCode
 * Trabajo Terminal 2026-A038 - Conversor de Diagramas de Flujo
 * 
 * Fecha: 2026-02-12
 * Nodos procesados: 4
 * Símbolos en tabla: 1
 * ═══════════════════════════════════════════════════════════════════ */

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    // === Declaraciones de variables ===
    int x = 5;
    
    // === Cuerpo del programa ===
    printf("%d\n", x);
    
    return 0;
}
```

#### Características del Código Generado

| Característica | Descripción |
|----------------|-------------|
| **Estándar** | ANSI C89/C99 |
| **Includes** | `<stdio.h>`, `<stdlib.h>` según necesidad |
| **Función principal** | `int main(void)` con `return 0` |
| **Comentarios** | Opcionales, configurables en `CompilerOptions` |
| **Indentación** | 4 espacios (configurable) |
| **Format specifiers** | Automáticos según tipo de dato |

---

## 22.2 Integración con el Editor Visual

### 22.2.1 Invocación del Conversor desde la UI

La integración entre el editor visual y el conversor se realiza a través del método `_compileWithFullPipeline()` en `editor_screen.dart`:

#### Flujo de Invocación

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Botón convertir │───>│ _compileWith    │───>│ DiagramCompiler │
│  (FloatingBtn)  │    │ FullPipeline()  │    │ Pipeline        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                      │
                                v                      v
                       ┌─────────────────┐    ┌─────────────────┐
                       │ CompilerResults │<───│ CompilationResult│
                       │ Dialog          │    │ (5 fases)        │
                       └─────────────────┘    └─────────────────┘
```

#### Implementación

```dart
/// editor_screen.dart - Invocación del conversor
void _compileWithFullPipeline() {
  // 1. Verificar que hay nodos
  if (nodes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El diagrama está vacío')),
    );
    return;
  }

  // 2. Crear el conversor con opciones
  final compiler = DiagramCompilerPipeline(
    options: const CompilerOptions(
      optimizationLevel: 2,      // Nivel estándar
      generateComments: true,    // Incluir comentarios
      strictTypeChecking: false, // Modo tolerante
    ),
  );

  // 3. convertir el diagrama
  final result = compiler.compile(nodes, connections);

  // 4. Registrar métricas
  _metricsService.trackUserAction(
    action: 'compilacion_completa',
    metadata: {
      'nodes_count': nodes.length,
      'success': result.success,
      'compilation_time_ms': result.metrics.compilationTimeMs,
    },
  );

  // 5. Mostrar resultados en diálogo
  showDialog(
    context: context,
    builder: (context) => CompilerResultsDialog(result: result),
  );
}
```

### 22.2.2 Visualización de Errores en Tiempo Real

El sistema proporciona retroalimentación visual inmediata a través del `CompilerResultsDialog`:

#### Estructura del Diálogo de Resultados

```dart
/// CompilerResultsDialog - Pestañas de visualización
class CompilerResultsDialog extends StatefulWidget {
  final CompilationResult result;
  
  // Pestañas disponibles:
  // 1. General     - Resumen y métricas
  // 2. Léxico      - Tokens generados
  // 3. Sintáctico  - Árbol AST
  // 4. Semántico   - Tabla de símbolos y errores
  // 5. Optimización - Mejoras aplicadas
  // 6. Código      - Código C generado
}
```

#### Visualización de Métricas

```
┌─────────────────────────────────────────────────────────────┐
│  📊 MÉTRICAS DE conversión                                 │
├─────────────────────────────────────────────────────────────┤
│  Nodos:     [12]    Tokens:    [45]    Símbolos: [5]       │
│  Errores:   [0 ✓]   Warnings:  [1 ⚠]  Tiempo:   [23ms]    │
├─────────────────────────────────────────────────────────────┤
│  ⏱️ TIEMPOS POR FASE                                        │
│  ▓▓▓▓░░░░░░ Léxico:      5ms  (22%)                        │
│  ▓▓▓▓▓▓░░░░ Sintáctico:  8ms  (35%)                        │
│  ▓▓▓░░░░░░░ Semántico:   4ms  (17%)                        │
│  ▓▓░░░░░░░░ Optimización: 2ms (9%)                         │
│  ▓▓▓▓░░░░░░ CodeGen:     4ms  (17%)                        │
└─────────────────────────────────────────────────────────────┘
```

#### Visualización de Errores

Los errores se muestran con código de colores según severidad:

| Severidad | Color | Icono | Descripción |
|-----------|-------|-------|-------------|
| **Fatal** | Rojo oscuro | ❌ | Error que detiene la conversión |
| **Error** | Rojo | ⛔ | Error que impide generar código |
| **Warning** | Naranja | ⚠️ | Advertencia, código generado |
| **Info** | Azul | ℹ️ | Información |
| **Hint** | Gris | 💡 | Sugerencia de mejora |

---

## 22.3 Símbolos ISO 5807 Soportados

### 22.3.1 Símbolos con Generación de Código

FlowCode implementa 6 símbolos ISO 5807 con capacidad de generación de código C:

| # | NodeType | Símbolo ISO 5807 | Forma | Genera Código |
|---|----------|------------------|-------|---------------|
| 1 | `terminal` | Terminal | Óvalo | ✅ `main()`, `return 0` |
| 2 | `process` | Proceso | Rectángulo | ✅ Declaraciones, asignaciones |
| 3 | `decision` | Decisión | Rombo | ✅ `if`, `else`, `switch` |
| 4 | `preparation` | Preparación | Hexágono | ✅ `for`, `while`, inicialización |
| 5 | `data` | Datos E/S | Paralelogramo | ✅ `printf()`, `scanf()` |
| 6 | `predefinedProcess` | Proceso Predefinido | Rectángulo doble | ✅ Llamadas a funciones |

#### Símbolos Adicionales (Sin Generación de Código)

FlowCode también soporta símbolos ISO 5807 adicionales para documentación visual:

```dart
// Símbolos de datos
NodeType.storedData        // Datos almacenados
NodeType.directStorage     // Almacenamiento directo (BD)
NodeType.document          // Documento
NodeType.display           // Pantalla

// Símbolos especiales
NodeType.connector         // Conector en página
NodeType.offPageConnector  // Conector fuera de página
NodeType.comment           // Comentario/Anotación

// Símbolos de proceso adicionales
NodeType.manualOperation   // Operación manual
NodeType.parallelMode      // Modo paralelo
```

### 22.3.2 Mapeo Símbolo-Código C

#### Terminal (Inicio/Fin)

```
┌─────────────────┐          ┌─────────────────────────┐
│    ╭─────────╮  │          │ int main(void) {        │
│    │ Inicio  │  │    =>    │     // ...              │
│    ╰─────────╯  │          │ }                       │
└─────────────────┘          └─────────────────────────┘

┌─────────────────┐          ┌─────────────────────────┐
│    ╭─────────╮  │          │     return 0;           │
│    │   Fin   │  │    =>    │ }                       │
│    ╰─────────╯  │          │                         │
└─────────────────┘          └─────────────────────────┘
```

#### Proceso (Asignaciones)

```
┌─────────────────┐          ┌─────────────────────────┐
│ ┌─────────────┐ │          │ int contador = 0;       │
│ │int contador │ │    =>    │                         │
│ │   = 0      │ │          │                         │
│ └─────────────┘ │          │                         │
└─────────────────┘          └─────────────────────────┘

┌─────────────────┐          ┌─────────────────────────┐
│ ┌─────────────┐ │          │ contador = contador + 1;│
│ │ contador =  │ │    =>    │                         │
│ │contador + 1 │ │          │                         │
│ └─────────────┘ │          │                         │
└─────────────────┘          └─────────────────────────┘
```

#### Decisión (if/else)

```
┌─────────────────┐          ┌─────────────────────────┐
│      ◇         │          │ if (x > 0) {            │
│    x > 0       │    =>    │     // rama Sí          │
│   ↙    ↘      │          │ } else {                │
│  Sí     No     │          │     // rama No          │
└─────────────────┘          │ }                       │
                             └─────────────────────────┘
```

#### Preparación (Loops)

```
┌─────────────────┐          ┌─────────────────────────┐
│    ⬡           │          │ for (int i = 0;         │
│  for i = 0     │    =>    │      i < 10;            │
│   to 10        │          │      i++) {             │
│    ⬡           │          │     // cuerpo           │
└─────────────────┘          │ }                       │
                             └─────────────────────────┘
```

#### Datos E/S (printf/scanf)

```
┌─────────────────┐          ┌─────────────────────────┐
│  ╱─────────────╲│          │ printf("%d\n", valor);  │
│ │ Escribir     ││    =>    │                         │
│ │   valor      ││          │                         │
│  ╲─────────────╱│          │                         │
└─────────────────┘          └─────────────────────────┘

┌─────────────────┐          ┌─────────────────────────┐
│  ╱─────────────╲│          │ scanf("%d", &numero);   │
│ │ Leer numero  ││    =>    │                         │
│  ╲─────────────╱│          │                         │
└─────────────────┘          └─────────────────────────┘
```

#### Proceso Predefinido (Subrutinas)

```
┌─────────────────┐          ┌─────────────────────────┐
│ ║─────────────║ │          │ resultado =             │
│ ║ calcular(x) ║ │    =>    │     calcular(x);        │
│ ║─────────────║ │          │                         │
└─────────────────┘          └─────────────────────────┘
```

### Tabla de Mapeo Completa

| Símbolo | Texto del Nodo | Código C Generado |
|---------|----------------|-------------------|
| Terminal Inicio | `Inicio`, `Start` | `int main(void) {` |
| Terminal Fin | `Fin`, `End` | `return 0; }` |
| Proceso | `int x = 5` | `int x = 5;` |
| Proceso | `x = x + 1` | `x = x + 1;` |
| Decisión | `x > 0` | `if (x > 0) { }` |
| Datos (Salida) | `Escribir x` | `printf("%d\n", x);` |
| Datos (Salida) | `Escribir "Hola"` | `printf("Hola\n");` |
| Datos (Entrada) | `Leer x` | `scanf("%d", &x);` |
| Preparación | `for i = 0 to 10` | `for (int i = 0; i < 10; i++)` |
| Preparación | `while (x > 0)` | `while (x > 0) { }` |
| Predefinido | `calcular(a, b)` | `calcular(a, b);` |

---

## Diagrama de Arquitectura de Integración

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CAPA DE PRESENTACIÓN                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    EditorScreen                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │   │
│  │  │ DiagramCanvas│  │ SymbolPalette│  │ FloatingToolbar  │  │   │
│  │  │  (Viewport)  │  │  (Símbolos)  │  │  [⚙️] [📝] [▶️]  │  │   │
│  │  └──────────────┘  └──────────────┘  └───────┬──────────┘  │   │
│  └──────────────────────────────────────────────┼──────────────┘   │
└─────────────────────────────────────────────────┼───────────────────┘
                                                  │ 
                                                  ▼ onClick: convertir
┌─────────────────────────────────────────────────────────────────────┐
│                       CAPA DE conversión                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              DiagramCompilerPipeline                         │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ │   │
│  │  │ Lexical │→│ Syntax  │→│Semantic │→│Optimizer│→│CodeGen │ │   │
│  │  │Analyzer │ │Analyzer │ │Analyzer │ │         │ │        │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └────────┘ │   │
│  └──────────────────────────────┬──────────────────────────────┘   │
└─────────────────────────────────┼───────────────────────────────────┘
                                  │
                                  ▼ CompilationResult
┌─────────────────────────────────────────────────────────────────────┐
│                        CAPA DE RESULTADOS                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              CompilerResultsDialog                           │   │
│  │  ┌─────────┬─────────┬─────────┬─────────┬─────────┬──────┐ │   │
│  │  │ General │ Léxico  │ Sintax  │Semántico│Optimiz. │Código│ │   │
│  │  │ ✅ 23ms │ 45 tok  │ AST ✓   │ 5 sym   │ 3 opt   │ [C]  │ │   │
│  │  └─────────┴─────────┴─────────┴─────────┴─────────┴──────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Referencias del Código Fuente

| Componente | Archivo | Líneas |
|------------|---------|--------|
| `DiagramCompilerPipeline` | `lib/compiler/compiler_pipeline.dart` | 1-767 |
| `CompilerOptions` | `lib/compiler/compiler_pipeline.dart` | 33-75 |
| `CompilationResult` | `lib/compiler/compiler_pipeline.dart` | 680-767 |
| `_compileWithFullPipeline()` | `lib/screens/editor_screen.dart` | 1980-2040 |
| `CompilerResultsDialog` | `lib/widgets/compiler_results_dialog.dart` | 1-1251 |
| `NodeType` | `lib/models/diagram_node.dart` | 5-45 |

---

*Documentación generada para Trabajo Terminal 2026-A038 - FlowCode*
*Ciclo 6: Integración del Pipeline Completo*
