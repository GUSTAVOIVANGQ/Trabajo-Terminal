# Tema 21: Generación de código C

La generación de código constituye la fase final del canal de conversión. Se emite un programa C completo con `main()` y directivas de inclusión estándar, traduciendo el subconjunto de símbolos ISO 5807 empleado por la aplicación.

---

## 21.1 Insumos de generación

La emisión se basa en:

- el conjunto de nodos del diagrama y sus conexiones (topología del grafo),
- la tabla de símbolos producida por el análisis semántico (tipos y declaraciones),
- un AST opcional, utilizado como entrada de diagnóstico y para extensiones futuras.

En la versión actual, la emisión de C se realiza principalmente a partir del grafo del diagrama y de la tabla de símbolos. El AST optimizado puede formar parte del resultado de conversión, pero no se utiliza todavía como fuente directa de emisión.

---

## 21.2 Opciones de generación

Se contemplan opciones para:

- incluir o suprimir comentarios en el código emitido,
- insertar marca de tiempo en el encabezado,
- configurar la cadena de indentación.

Otras opciones permanecen definidas como parte de la configuración general del conversor, pero no alteran el texto emitido en esta versión.

---

## 21.3 Estructura fija del programa emitido

El código emitido sigue una estructura uniforme:

1. Encabezado en forma de comentarios.
2. Directivas `#include` fijas: `stdio.h`, `stdlib.h`, `stdbool.h`.
3. Función principal con firma `int main() {`.
4. Cuerpo del programa (sentencias generadas por nodo).
5. Sentencia `return 0;` y cierre de `main`.

No se generan, en esta etapa, declaraciones globales separadas del cuerpo de `main`.

---

## 21.4 Orden de emisión de nodos

Los diagramas de flujo definen el orden de ejecución mediante conexiones entre nodos, no por su posición visual. El orden se determina por un recorrido en profundidad desde el nodo terminal de inicio. El algoritmo:

- mantiene un conjunto de nodos visitados para evitar duplicidad,
- ignora conexiones marcadas como retorno de bucle (`isLoopBack`) durante el cálculo del orden,
- en decisiones prioriza la rama afirmativa (`sí/si/yes/true`) antes que la negativa (`no/false`),
- en bucles procesa primero el cuerpo (conexiones `verdadero/true` o sin etiqueta) y después la salida (`falso/false`),
- omite los nodos terminales de fin en la lista de emisión.

*[Figura N. Pseudocódigo del recorrido en profundidad para el orden de emisión.]*

---

## 21.5 Mapeo del subconjunto ISO 5807

| Símbolo ISO 5807 | Tipo de nodo | Traducción a C |
|---|---|---|
| Terminal (Inicio/Fin) | `terminal` | No emite sentencias; puede emitir comentarios si se habilita esta opción |
| Proceso | `process` | Declaraciones, asignaciones y sentencias de expresión |
| Datos (E/S) | `data` | `printf(...)` y `scanf(...)` según el contenido |
| Decisión | `decision` | `if ... else ...` o `switch ... case ...` |
| Preparación | `preparation` | `for`, `while` o `do ... while` |
| Proceso predefinido | `predefinedProcess` | Llamada a función `nombre(...)` |
| Comentario | `comment` | Comentario `//` o `/* ... */` |
| Conectores | `connector`, `offPageConnector` | No emiten código |

Cuando se encuentran símbolos ISO 5807 no contemplados en el subconjunto anterior, puede emitirse una anotación de “nodo no soportado” si se habilitan comentarios.

---

## 21.6 Nodos de proceso

El texto del nodo de proceso se analiza por patrones para emitir una sentencia C terminada en `;`. Se contemplan, en orden:

- declaraciones con tipo C (`int`, `float`, `double`, `char`, `bool`), incluyendo declaraciones múltiples separadas por comas,
- declaración con inicialización (`tipo nombre = expresión`),
- asignación simple (`nombre = expresión`),
- incremento/decremento (`x++`, `x--`),
- caso general: la línea se transcribe como sentencia de expresión.

---

## 21.7 Nodos de datos (entrada y salida)

Un nodo se interpreta como salida cuando inicia con palabras clave de salida (`escribir`, `mostrar`, `imprimir`, `print`) o contiene la palabra “salida”, o bien cuando sus metadatos lo marcan como salida. En caso contrario se interpreta como entrada.

En salida se generan llamadas a `printf` con `\n` al final. Se contemplan:

- literal de cadena `"..."` (con o sin variables adicionales),
- múltiples variables separadas por comas,
- una variable única.

En entrada se generan llamadas a `scanf` por variable y se emite un mensaje de solicitud previo (`printf("Ingrese <var>: ");`). Para variables de tipo cadena (`%s`) no se aplica el operador de dirección `&`; en otros tipos se utiliza `&variable`.

*[Figura N. Ejemplos de salida con múltiples variables y entrada iterativa por variable.]*

---

## 21.8 Especificadores de formato

El especificador de formato se determina consultando la tabla de símbolos. Cuando no existe información para un identificador, se aplica una inferencia conservadora basada en convenciones de nombre; en ausencia de coincidencia se utiliza `%d` como valor predeterminado.

---

## 21.9 Decisiones y normalización de condiciones

Las decisiones se emiten como `if (...) { ... } else { ... }` y las ramas se determinan por etiquetas de conexión:

- afirmativa: `sí`, `si`, `yes`, `true`
- negativa: `no`, `false`

Para facilitar condiciones escritas con notación no estrictamente C, se aplica normalización de operadores:

| Escritura en el diagrama | Traducción a C |
|---|:---:|
| `Y`, `y`, `AND` | `&&` |
| `O`, `o`, `OR` | `\|\|` |
| `=` con espacios alrededor | `==` |
| `<>`, `≠` | `!=` |
| `≤` | `<=` |
| `≥` | `>=` |
| `¿...?` | se eliminan los signos |

Cuando el nodo de decisión corresponde a una estructura `switch`, se emite `switch (variable) { case ...: ... break; ... default: ... break; }`, obteniendo los valores de `case` a partir de las etiquetas de conexión o de metadatos del nodo destino.

---

## 21.10 Bucles

Los bucles se emiten a partir de nodos de preparación. El tipo se determina por metadatos o por el contenido textual:

- `for (...) { ... }`
- `while (...) { ... }`
- `do { ... } while (...);`

Durante la generación del cuerpo se evitan ciclos infinitos ignorando conexiones de retorno de bucle y registrando nodos visitados dentro del cuerpo del bucle. Para `do ... while` se contemplan metadatos que distinguen el nodo cuerpo y el nodo de condición.

---

## 21.11 Subprocesos

Los nodos de proceso predefinido se traducen a llamadas a función. Si el texto ya contiene paréntesis, se conserva; en caso contrario se añade una invocación sin argumentos (`nombreFuncion()`).

---

## 21.12 Métricas y resultado

La generación reporta métricas básicas: líneas de código emitidas, número de funciones emitidas (una función principal), número de variables registradas en la tabla de símbolos y tiempo de generación.

El código emitido está listo para compilarse en un entorno compatible con C99, siempre que el contenido textual de los nodos se mantenga dentro del subconjunto soportado.
