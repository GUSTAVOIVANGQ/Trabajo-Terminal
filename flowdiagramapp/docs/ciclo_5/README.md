# CICLO 5: GENERADOR DE CÓDIGO

## Fase 1: Determinación de Objetivos

### Objetivos del Ciclo 5

En este ciclo se implementan las etapas finales del canal de conversión: (i) optimización sobre el Árbol de Sintaxis Abstracta (AST) producido en el ciclo anterior, y (ii) emisión de código fuente C a partir de la topología del diagrama y de la información semántica acumulada. La salida se orienta al subconjunto de C conforme a C99 [8] y utiliza bibliotecas estándar.

- Consolidar la representación intermedia (AST) y su trazabilidad hacia los nodos del diagrama.
- Implementar un optimizador multi-pasada con cuatro niveles de configuración.
- Emitir un programa C con estructura fija (`#include`, `main`, `return`) a partir del subconjunto de símbolos ISO 5807 soportado [19].
- Seleccionar especificadores de formato para `printf`/`scanf` con base en la tabla de símbolos construida en el Ciclo 4.
- Integrar la visualización y el copiado del código generado en la interfaz de la aplicación.

---

## Fase 2: Análisis de Riesgos

**Tabla 97. Riesgos identificados y mitigados**

| Riesgo | Estrategia de mitigación |
|---|---|
| Emisión de C con errores sintácticos | Pruebas unitarias que verifican la estructura del código emitido para los casos representativos de control de flujo y E/S |
| Código emitido difícil de inspeccionar | Estructura de salida uniforme, indentación configurable y comentarios opcionales por nodo |
| Cobertura parcial de símbolos ISO 5807 | Delimitación explícita del subconjunto soportado; los nodos fuera del subconjunto se anotan con un comentario `TODO` cuando se habilitan comentarios |
| Regresiones en el motor de análisis | Las pruebas de los ciclos anteriores (léxico, sintáctico, semántico) se ejecutan de forma continua durante el desarrollo |

---

## Fase 3: Desarrollo y Verificación

### Productos generados

- Jerarquía de nodos AST con trazabilidad hacia el nodo de diagrama de origen.
- Optimizador del AST con cuatro niveles configurables, ejecución por pasadas y métricas de transformación.
- Generador de código C que emite `main()` con directivas de inclusión fijas y traducción de estructuras de control.
- Normalización de condiciones y selección automática de especificadores de formato para operaciones de E/S.
- Visualizador de código C integrado en la interfaz, con texto monoespaciado y opción de copia al portapapeles.
- Código del optimizador y del generador preparado para la ejecución de pruebas en el Ciclo 6.

---

## Fase 4: Planificación

### Entregables

- Informe del Ciclo 5: documentación de la representación intermedia, optimización y generación de código.
- Plan detallado para el Ciclo 6: Integración.

---

# 18. Representación Intermedia (AST)

El Árbol de Sintaxis Abstracta (AST) producido durante el análisis sintáctico (Ciclo 4, sección 16.2) constituye la representación intermedia del canal de conversión [1]. En este ciclo se emplea como insumo del optimizador y, una vez transformado, como soporte para la generación de código y trazabilidad de métricas.

## 18.1 Jerarquía de Nodos

Todos los nodos del AST derivan de una clase base común que mantiene la posición del constructo dentro del texto analizado (línea y columna), el identificador del nodo de diagrama del que proviene el fragmento, y la colección de subnodos hijos para recorridos genéricos.

La Tabla N describe los tipos de nodos implementados, organizados por categoría.

**Tabla N. Tipos de nodos del AST**

| Categoría | Tipo de nodo | Descripción |
|---|---|---|
| Raíz | `ProgramNode` | Nodo raíz; agrupa los bloques de cada nodo del diagrama mediante contenedores `DiagramASTNode` |
| Literales | `IntegerLiteralNode` | Constante entera |
| | `FloatLiteralNode` | Constante de punto flotante |
| | `StringLiteralNode` | Literal de cadena |
| | `CharLiteralNode` | Literal de carácter |
| | `BooleanLiteralNode` | Constante booleana |
| Expresiones | `BinaryExpressionNode` | Operación binaria (aritmética, relacional o lógica) |
| | `UnaryExpressionNode` | Operación unaria (`!`, `-`, `++`, `--`) |
| | `AssignmentExpressionNode` | Asignación |
| | `IdentifierNode` | Referencia a variable o constante |
| | `FunctionCallNode` | Invocación de función |
| Sentencias | `DeclarationStatementNode` | Declaración de variable con tipo |
| | `IfStatementNode` | Estructura condicional |
| | `WhileStatementNode` | Bucle `while` |
| | `ForStatementNode` | Bucle `for` |
| | `BlockStatementNode` | Bloque de sentencias |
| | `InputStatementNode` | Operación de entrada (`scanf`) |
| | `OutputStatementNode` | Operación de salida (`printf`) |

El nodo raíz `ProgramNode` preserva la relación diagrama↔AST mediante contenedores `DiagramASTNode`, uno por cada nodo del diagrama procesado, lo que permite rastrear qué fragmento del AST corresponde a qué nodo visual.

## 18.2 Patrón Visitor (ASTVisitor)

El recorrido del AST se implementó mediante el patrón Visitor [1]: la clase `ASTVisitor` define un método de visita por cada tipo de nodo, de modo que cada nodo acepta al visitante e invoca el método correspondiente a su tipo. Esta separación permite añadir nuevas operaciones sobre el AST —como la optimización y la generación de representación textual para diagnóstico— sin modificar la jerarquía de nodos.

---

# 19. Optimización del AST

La fase de optimización aplica transformaciones semánticamente equivalentes sobre el AST para reducir redundancias y simplificar expresiones, preservando el comportamiento observable del programa [3]. El optimizador opera sobre el AST producido por el análisis semántico, que ya contiene información de tipos.

## 19.1 Niveles de Optimización

Se definen cuatro niveles de configuración; cada uno habilita un conjunto de técnicas y limita el número máximo de pasadas.

**Tabla N. Técnicas habilitadas por nivel de optimización**

| Nivel | Plegado de constantes | Eliminación de código muerto | Simplificación algebraica | Optimización de flujo de control | Máx. pasadas |
|---|:---:|:---:|:---:|:---:|:---:|
| `none` | No | No | No | No | 0 |
| `basic` | Sí | Sí | No | No | 1 |
| `standard` | Sí | Sí | Sí | No | 2 |
| `aggressive` | Sí | Sí | Sí | Sí | 3 |

## 19.2 Ejecución por Pasadas

La optimización se ejecuta de forma iterativa. En cada pasada se aplican, en orden, las técnicas habilitadas. El proceso se detiene cuando se alcanza el número máximo de pasadas configurado o cuando una pasada completa no produce ningún cambio (punto fijo), lo que garantiza la terminación [3].

## 19.3 Técnicas Implementadas

**Plegado de constantes.** Evalúa expresiones compuestas únicamente por literales y sustituye el subárbol por el literal resultante [1]. En operaciones de división y módulo se evita el plegado cuando el divisor es cero, manteniendo la expresión original para no alterar el comportamiento en tiempo de ejecución.

**Eliminación de código muerto.** Elimina ramas `if` cuya condición sea una constante booleana, bucles con condición de continuación siempre falsa, y sentencias inalcanzables tras `return`, `break` o `continue` [1].

**Simplificación algebraica.** Aplica identidades algebraicas como $x+0=x$, $x \times 1=x$, $x \times 0=0$ y $x-x=0$, y elimina dobles negaciones. Estas transformaciones reducen el número de operaciones en el código emitido.

**Optimización de flujo de control (nivel `aggressive`).** Simplifica estructuras de control cuando el análisis produce bloques vacíos o condiciones redundantes, manteniendo la equivalencia semántica [3].

## 19.4 Métricas de Optimización

El resultado de la optimización incluye conteos por técnica aplicada, el número de nodos del AST antes y después de la optimización con el porcentaje de reducción estimado, el tiempo total de la fase y un registro textual de las transformaciones realizadas. Estas métricas se presentan al usuario en la pestaña *Optimización* del diálogo de resultados (véase sección 10.9.3).

## 19.5 Relación con la Generación de Código

La optimización se ejecuta después del análisis semántico y produce el AST transformado que el generador de código recibe como entrada. Las transformaciones aplicadas —plegado de constantes, eliminación de ramas inalcanzables y simplificación algebraica— se reflejan directamente en el código C emitido.

---

# 20. Generación de Código C

La generación de código constituye la fase final del canal de conversión [1]. A partir de la topología del diagrama, la tabla de símbolos y el AST optimizado, se emite un programa C completo y válido y funcional conforme al estándar C99 [8]. El generador recibe los nodos del diagrama y sus conexiones para determinar el orden de emisión, consulta la tabla de símbolos para obtener el tipo de cada variable y seleccionar el especificador de formato correspondiente, y emplea el AST como soporte para expresiones y extensiones futuras.

## 20.2 Opciones de Generación

El generador admite configuración para incluir o suprimir comentarios en el código emitido, insertar una marca de tiempo en el encabezado y ajustar la cadena de indentación. Estas opciones no afectan la corrección del programa emitido, únicamente su presentación.

## 20.3 Estructura del Programa Emitido

El código emitido sigue siempre la siguiente estructura fija:

1. Encabezado en forma de comentarios (nombre del proyecto, fecha si está habilitada).
2. Directivas de inclusión fijas: `stdio.h`, `stdlib.h` y `stdbool.h` (necesaria para el tipo `bool` definido en la tabla de símbolos, véase sección 17.1.2).
3. Función principal con firma `int main()`.
4. Cuerpo del programa generado por nodo según el orden de emisión.
5. Sentencia `return 0;` y cierre de `main`.

No se generan declaraciones globales separadas del cuerpo de `main` en esta versión.

## 20.4 Orden de Emisión de Nodos

El orden se determina por un recorrido en profundidad (DFS) [7] desde el nodo terminal de inicio. El algoritmo:

- Mantiene un conjunto de nodos visitados para evitar emitir el mismo nodo más de una vez.
- Ignora las conexiones marcadas como retorno de bucle (`isLoopBack`) durante el cálculo del orden, para no procesar el cuerpo del bucle como código secuencial posterior.
- En nodos de decisión, prioriza la rama afirmativa antes que la negativa.
- En nodos de bucle (preparación), procesa primero el cuerpo y después la salida.
- Omite los nodos terminales de fin de la lista de emisión.

## 20.5 Mapeo del Subconjunto ISO 5807

La Tabla N describe la traducción de cada tipo de símbolo soportado [19]. Los símbolos ISO 5807 fuera de este subconjunto no generan código; si los comentarios están habilitados, se emite una anotación que identifica el nodo como no soportado.

**Tabla N. Subconjunto de símbolos ISO 5807 y su traducción a C**

| Símbolo ISO 5807 | Tipo de nodo | Traducción a C |
|---|---|---|
| Terminal (Inicio) | `terminal` | No emite sentencias; apertura de `main()` |
| Terminal (Fin) | `terminal` | No emite sentencias; `return 0;` al final |
| Proceso | `process` | Declaraciones, asignaciones y sentencias de expresión |
| Datos (E/S) | `data` | `printf(...)` o `scanf(...)` según el contenido |
| Decisión | `decision` | `if ... else ...` o `switch ... case ...` |
| Preparación | `preparation` | `for`, `while` o `do ... while` |
| Proceso predefinido | `predefinedProcess` | Llamada a función |
| Comentario | `comment` | Comentario `//` o `/* ... */` |
| Conectores | `connector`, `offPageConnector` | No emiten código |

## 20.6 Nodos de Proceso

El texto del nodo de proceso se analiza por patrones para emitir una sentencia C terminada en `;`. Los patrones se aplican en el siguiente orden:

1. Declaración con tipo C (`int`, `float`, `double`, `char`, `bool`), incluyendo declaraciones múltiples separadas por coma.
2. Declaración con inicialización (`tipo nombre = expresión`).
3. Asignación simple (`nombre = expresión`).
4. Incremento o decremento (`x++`, `x--`).
5. Caso general: el texto se transcribe como sentencia de expresión.

## 20.7 Nodos de Datos (Entrada y Salida)

Un nodo de datos se interpreta como **salida** cuando su texto inicia con palabras clave de salida (`escribir`, `mostrar`, `imprimir`, `print`) o cuando sus metadatos lo marcan explícitamente como salida. En caso contrario se interpreta como **entrada**.

**Salida.** Se genera una llamada a `printf` con `\n` al final. Se contemplan tres variantes: literal de cadena con o sin variables adicionales, múltiples variables separadas por coma, y variable única.

**Entrada.** Por cada variable se emite un mensaje de solicitud previo (`printf("Ingrese <var>: ");`) seguido de la llamada a `scanf` correspondiente. Para variables de tipo cadena (`%s`) no se aplica el operador de dirección `&`; en los demás tipos se utiliza `&variable`.

## 20.8 Especificadores de Formato

El especificador de formato se determina consultando la tabla de símbolos por el nombre de la variable [8]. Cuando la variable no está registrada en la tabla de símbolos, se utiliza `%d` como especificador por omisión. La Tabla 95a de la sección 17.1.2 define la correspondencia completa entre tipo y especificador.

## 20.9 Decisiones y Normalización de Condiciones

Las decisiones se emiten como `if (...) { ... } else { ... }`. Las ramas se determinan por las etiquetas de las conexiones salientes del nodo de decisión: las etiquetas `sí`, `si`, `yes` o `true` corresponden a la rama afirmativa; las etiquetas `no` o `false` a la negativa.

Para condiciones escritas con notación no estrictamente C, se aplica la normalización de la Tabla N antes de emitir la condición.

**Tabla N. Normalización de operadores en condiciones**

| Escritura en el diagrama | Traducción a C |
|---|:---:|
| `Y`, `y`, `AND` | `&&` |
| `O`, `o`, `OR` | `\|\|` |
| `=` con espacios alrededor | `==` |
| `<>`, `≠` | `!=` |
| `≤` | `<=` |
| `≥` | `>=` |
| `¿...?` | Se eliminan los signos de interrogación |

Cuando el nodo de decisión corresponde a una estructura `switch`, se emite `switch (variable) { case ...: ... break; ... default: ... break; }`, obteniendo los valores de `case` a partir de las etiquetas de las conexiones salientes o de los metadatos del nodo destino.

## 20.10 Bucles

Los bucles se emiten a partir de nodos de preparación. El tipo de bucle se determina por los metadatos del nodo o por el contenido textual: `for`, `while` o `do ... while`. Durante la generación del cuerpo se registran los nodos visitados para evitar ciclos infinitos en el recorrido, ignorando las conexiones marcadas como retorno de bucle.

## 20.11 Subprocesos

Los nodos de proceso predefinido se traducen a llamadas a función [1]. Si el texto del nodo ya incluye paréntesis, se conserva tal cual; en caso contrario se emite la invocación sin argumentos.

## 20.12 Resultado de Generación

El resultado de conversión empaqueta el código C emitido junto con los mensajes de error y advertencias generados durante el proceso. El código producido es válido y funcional en un entorno compatible con C99 [8] siempre que el contenido textual de los nodos se mantenga dentro del subconjunto soportado. El módulo generador queda preparado para la ejecución de las pruebas de integración y validación documentadas en el Ciclo 6 (sección 21).
