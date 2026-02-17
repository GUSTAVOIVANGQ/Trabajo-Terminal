# Tema 21: Generación de Código C

## Ubicación en el Proyecto

El generador de código se implementa en [lib/compiler/code_generator_advanced.dart](../lib/compiler/code_generator_advanced.dart). Esta es la fase final del compilador fuente-a-fuente que produce código C ejecutable a partir del árbol de sintaxis abstracta optimizado.

---

## 21.1 Fundamentos de la Generación de Código

La generación de código constituye la quinta y última fase del compilador FlowCode, donde el árbol de sintaxis abstracta optimizado se transforma en código fuente C textual. A diferencia de compiladores tradicionales que producen código máquina o bytecode, FlowCode implementa un compilador source-to-source (transpilador) que traduce representaciones visuales a texto legible por humanos.

Esta decisión arquitectónica responde directamente al propósito educativo de la herramienta. Los estudiantes pueden examinar el código C generado línea por línea, compilarlo con GCC o Clang en su entorno de desarrollo, ejecutarlo para verificar su comportamiento, y depurarlo usando herramientas estándar como GDB. Este ciclo completo de diseñar-generar-compilar-ejecutar refuerza la conexión entre el pensamiento algorítmico visual y la programación textual.

El código generado sigue las convenciones del estándar C99, elegido por ser un estándar maduro, ampliamente soportado en entornos académicos, y suficientemente expresivo para los conceptos de programación fundamental que FlowCode enseña. El generador opera sobre dos estructuras de datos principales: el AST optimizado que describe la lógica del programa, y la tabla de símbolos que contiene información de tipos y declaraciones de las variables.

---

## 21.2 Opciones de Generación

El generador ofrece opciones configurables que permiten adaptar el código producido a diferentes contextos de uso pedagógico.

La opción de **incluir comentarios** controla si el código generado contiene anotaciones explicativas que referencian los nodos del diagrama original. Estos comentarios facilitan enormemente la correspondencia visual entre cada símbolo del diagrama y su traducción a C, pero pueden desactivarse cuando se desea código más compacto para análisis o entrega.

La opción de **marca de tiempo** añade un comentario en el encabezado indicando cuándo se generó el código. Esto es útil para mantener registro de versiones cuando un estudiante itera sobre el diseño de su diagrama.

La **indentación** predeterminada usa cuatro espacios siguiendo las convenciones más comunes en C, aunque puede ajustarse según las preferencias del instructor o los estándares de estilo de un curso particular.

El **modo debug** incrementa la verbosidad de los comentarios e incluye información adicional sobre el proceso de generación, útil principalmente durante el desarrollo y pruebas del propio compilador.

---

## 21.3 Estructura del Código Generado

Todo programa C generado por FlowCode sigue una estructura consistente diseñada para producir código completo y funcional que compile sin modificaciones. El código resultante incluye seis componentes organizados en orden específico.

El **encabezado** contiene un bloque de comentarios con metadatos descriptivos: el nombre de la herramienta que generó el código, la fecha de generación si está habilitada, y opcionalmente información sobre el diagrama fuente.

Las **directivas de inclusión** se determinan dinámicamente analizando las operaciones presentes en el programa. Si existen operaciones de entrada/salida, se incluye `stdio.h`. Si hay operaciones con cadenas de texto, se incluye `string.h`. Si se detectan funciones matemáticas, se incluye `math.h`. Este análisis evita incluir bibliotecas innecesarias.

Las **declaraciones globales** aparecen cuando el diagrama define variables fuera de cualquier estructura de control. En la práctica, la mayoría de los diagramas de FlowCode definen variables locales dentro de main.

La **función principal** se genera siempre con la firma `int main(void)`, siguiendo las mejores prácticas de C99. El parámetro void explícito indica que main no acepta argumentos de línea de comandos.

El **cuerpo del programa** contiene la traducción de todos los nodos del diagrama siguiendo el orden de ejecución definido por las conexiones.

El **cierre** incluye siempre un `return 0;` indicando terminación exitosa, seguido de la llave de cierre de main.

---

## 21.4 Orden de Ejecución

Los diagramas de flujo definen el orden de ejecución mediante las conexiones entre nodos, no mediante su posición espacial en el canvas. Un nodo ubicado arriba de otro no necesariamente se ejecuta primero; lo que importa es cómo están conectados.

El generador implementa un recorrido en anchura (BFS - Breadth-First Search) desde el nodo de inicio para determinar la secuencia correcta de traducción. El algoritmo primero identifica el nodo terminal marcado como inicio, típicamente reconocible por contener el texto "Inicio" o "Start". Desde ese punto inicial, sigue las conexiones salientes visitando cada nodo exactamente una vez.

Cuando el recorrido encuentra un nodo de decisión, el algoritmo respeta la semántica de bifurcación: la rama etiquetada como "Sí" o "Verdadero" se procesa primero, seguida de la rama "No" o "Falso". Para los nodos de bucle, el recorrido identifica el cuerpo del bucle siguiendo las conexiones no marcadas como retorno, y reconoce los arcos de retroceso que indican la repetición.

Este enfoque de recorrido por grafo garantiza que el código generado preserve fielmente la semántica del diagrama independientemente de cómo el estudiante haya posicionado visualmente los nodos en el editor.

---

## 21.5 Mapeo de Símbolos ISO 5807 a Código C

Cada tipo de símbolo del estándar ISO 5807 implementado en FlowCode tiene una traducción específica a construcciones de C. La siguiente tabla resume este mapeo fundamental:

| Símbolo ISO 5807 | Tipo de Nodo | Construcción C Generada |
|------------------|--------------|-------------------------|
| Terminal (Inicio) | `terminal` | Declaración `int main(void) {` |
| Terminal (Fin) | `terminal` | Sentencia `return 0;` y cierre `}` |
| Proceso | `process` | Declaraciones, asignaciones, expresiones |
| Datos E/S | `data` | Llamadas a `printf()` o `scanf()` |
| Decisión | `decision` | Estructuras `if-else` o `switch` |
| Preparación | `preparation` | Bucles `for`, `while`, `do-while` |
| Proceso Predefinido | `predefinedProcess` | Llamadas a funciones |

Esta correspondencia directa permite que los estudiantes desarrollen un modelo mental claro de cómo cada elemento visual se traduce a código textual.

---

## 21.6 Generación de Nodos de Proceso

Los nodos de proceso son los más versátiles del diagrama, pudiendo contener declaraciones de variables, asignaciones y expresiones generales. El generador analiza el texto del nodo para determinar qué tipo de operación representa.

Para **declaraciones con inicialización**, el generador reconoce patrones como `int x = 5` o `float promedio = 0.0`. Extrae el tipo de dato, el nombre de la variable y el valor inicial, produciendo la sentencia C correspondiente con el punto y coma de terminación.

Para **declaraciones múltiples**, el generador soporta que el estudiante escriba `int a, b, c` en un solo nodo. Esto se traduce directamente a una declaración múltiple en C con el formato apropiado.

Para **asignaciones**, el generador detecta la presencia del operador `=` (distinguiéndolo del operador de comparación `==`) y produce una sentencia de asignación. La expresión del lado derecho se copia tal cual, asumiendo que el análisis semántico previo ya validó su corrección.

---

## 21.7 Generación de Nodos de Datos (Entrada/Salida)

Los nodos de datos representan operaciones de entrada y salida, el mecanismo fundamental de comunicación entre el programa y el usuario. El generador determina la dirección del flujo de datos basándose en el texto del nodo y sus metadatos.

Un nodo se interpreta como **entrada** cuando contiene palabras clave como "Leer", "Read" o "Entrada", o cuando sus metadatos indican explícitamente que es una operación de input. Para estas operaciones, el generador produce llamadas a `scanf()` con el especificador de formato apropiado según el tipo de la variable y el operador de dirección `&` necesario para pasar la dirección de memoria.

Un nodo se interpreta como **salida** cuando contiene palabras clave como "Escribir", "Imprimir", "Print" o "Mostrar". El generador produce llamadas a `printf()` que pueden imprimir valores de variables con su especificador de formato correspondiente, o cadenas literales entre comillas. Automáticamente añade `\n` al final para producir saltos de línea.

---

## 21.8 Especificadores de Formato

La generación correcta de especificadores de formato es crítica para que las funciones `printf()` y `scanf()` operen correctamente. El generador consulta la tabla de símbolos para determinar el tipo de cada variable y seleccionar el especificador apropiado.

| Tipo de Dato | Especificador | Uso en printf | Uso en scanf |
|--------------|---------------|---------------|--------------|
| `int`, `entero` | `%d` | `printf("%d", x)` | `scanf("%d", &x)` |
| `float`, `real` | `%f` | `printf("%f", x)` | `scanf("%f", &x)` |
| `double` | `%lf` | `printf("%lf", x)` | `scanf("%lf", &x)` |
| `char`, `caracter` | `%c` | `printf("%c", x)` | `scanf(" %c", &x)` |
| `string`, `cadena` | `%s` | `printf("%s", x)` | `scanf("%s", x)` |
| `bool`, `booleano` | `%d` | `printf("%d", x)` | `scanf("%d", &x)` |

Esta integración con la tabla de símbolos es fundamental para la corrección del código. Un error en el especificador de formato puede causar comportamiento indefinido en C, incluyendo la lectura o escritura de memoria incorrecta, valores basura, o incluso crashes del programa.

---

## 21.9 Generación de Estructuras de Decisión

Los nodos de decisión (símbolo de rombo) se traducen principalmente a estructuras `if-else` en C. El generador procesa la condición del nodo, genera la rama verdadera siguiendo las conexiones etiquetadas como "Sí" o "Verdadero", y opcionalmente genera la rama falsa si existen conexiones etiquetadas como "No" o "Falso".

Una característica importante del generador es la **normalización de operadores**. Dado que FlowCode tiene un propósito educativo y muchos estudiantes están más familiarizados con español, el generador transforma automáticamente operadores escritos en lenguaje natural a su sintaxis C equivalente:

| Escritura en Diagrama | Traducción a C |
|----------------------|----------------|
| `Y`, `y`, `AND` | `&&` |
| `O`, `o`, `OR` | `\|\|` |
| `=` (en contexto de comparación) | `==` |
| `<>`, `≠` | `!=` |
| `≤` | `<=` |
| `≥` | `>=` |
| `¿...?` | Se eliminan los signos |

Esta normalización permite que los estudiantes expresen condiciones de forma más natural durante el aprendizaje inicial, mientras el generador produce código C sintácticamente correcto.

Cuando el diagrama utiliza metadatos que indican un `switch`, el generador produce esa estructura alternativa en lugar de if-else encadenados, generando las cláusulas `case` y `break` apropiadas.

---

## 21.10 Generación de Bucles

Los nodos de preparación (símbolo hexagonal) representan estructuras de repetición. FlowCode soporta los tres tipos de bucles de C: `for`, `while` y `do-while`. El generador determina qué tipo de bucle generar basándose en los metadatos del nodo o analizando el contenido textual.

Para **bucles for**, el generador espera encontrar las tres partes del bucle (inicialización, condición, incremento) en el texto del nodo o en metadatos estructurados. Produce una estructura `for(init; cond; incr)` completa.

Para **bucles while**, el generador toma la condición del texto del nodo y produce una estructura `while(condición)` seguida del cuerpo encerrado en llaves.

Para **bucles do-while**, identificados por metadatos específicos, el generador produce la estructura `do { cuerpo } while(condición);` que garantiza al menos una ejecución del cuerpo.

La generación del cuerpo del bucle requiere cuidado especial. El generador mantiene un conjunto de nodos visitados dentro del cuerpo para evitar procesarlos múltiples veces cuando existen caminos convergentes. Además, identifica las conexiones marcadas como "arcos de retroceso" (loopback) que indican el retorno al inicio del bucle y no las sigue durante la generación del cuerpo.

---

## 21.11 Generación de Subprocesos

Los nodos de proceso predefinido (símbolo de rectángulo con líneas dobles) representan llamadas a subrutinas o funciones auxiliares. El generador produce llamadas de función simples, añadiendo paréntesis vacíos si el texto del nodo no los incluye.

Esta implementación asume que las funciones referenciadas están definidas externamente, ya sea en bibliotecas estándar de C o en archivos que el estudiante proporcionará. En el contexto educativo de FlowCode, esto permite que los estudiantes practiquen el concepto de modularización y reutilización de código sin la complejidad adicional de definir funciones dentro del diagrama.

---

## 21.12 Métricas y Resultado de la Generación

El generador recopila estadísticas durante el proceso de traducción que proporcionan retroalimentación útil tanto para diagnóstico técnico como para propósitos educativos.

Las métricas incluyen el número de nodos procesados del diagrama original, las líneas de código C generadas, la cantidad de comentarios incluidos si están habilitados, y el tiempo que tomó la generación. También se registran advertencias sobre situaciones que, aunque no impiden la generación, podrían indicar problemas en el diseño del diagrama.

El resultado completo de la generación empaqueta el código C producido junto con todas las métricas y cualquier mensaje de error o advertencia. Este resultado estructurado permite que la interfaz de usuario de FlowCode presente al estudiante no solo el código generado, sino también información contextual sobre su calidad y características, completando el ciclo educativo entre el diseño visual y la implementación funcional.

El código generado está listo para compilarse directamente con cualquier compilador C compatible con C99 sin necesidad de modificaciones manuales, permitiendo que el estudiante inmediatamente pruebe y ejecute su algoritmo.
