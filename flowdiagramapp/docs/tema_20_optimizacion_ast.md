# Tema 20: Optimización del AST

## Ubicación en el Proyecto

El optimizador se implementa en [lib/compiler/code_optimizer.dart](../lib/compiler/code_optimizer.dart). Esta fase opera entre el análisis semántico y la generación de código, transformando el árbol de sintaxis abstracta para producir código C más limpio y eficiente.

---

## 20.1 Fundamentos de la Optimización

La optimización del AST representa la cuarta fase del compilador fuente-a-fuente de FlowCode. A diferencia de las fases anteriores que detectan errores en el diagrama, esta fase preserva la corrección semántica mientras mejora características no funcionales como el tamaño del código generado y su legibilidad.

El objetivo fundamental de la optimización es aplicar transformaciones matemáticamente equivalentes que simplifiquen el código sin alterar su comportamiento observable. Por ejemplo, la expresión `x + 0` puede reducirse a simplemente `x` porque ambas producen resultados idénticos para cualquier valor de x. De manera similar, una expresión como `2 + 3` puede evaluarse directamente como `5` durante la conversión, evitando que el programa C resultante realice un cálculo innecesario en tiempo de ejecución.

Estas transformaciones son especialmente valiosas en el contexto de FlowCode porque los estudiantes frecuentemente construyen expresiones redundantes al diseñar sus diagramas de flujo. Un usuario podría crear un nodo de proceso con `resultado = valor * 1` sin darse cuenta de que la multiplicación por uno es innecesaria. El optimizador detecta y elimina automáticamente estas redundancias.

El optimizador de FlowCode implementa un enfoque conservador que prioriza la legibilidad del código generado sobre la máxima eficiencia. Esta decisión de diseño reconoce el propósito educativo de la herramienta: los estudiantes necesitan comprender el código C resultante y relacionarlo con su diagrama original. Un código excesivamente optimizado podría oscurecer esta correspondencia visual-textual, dificultando el aprendizaje.

---

## 20.2 Niveles de Optimización

El sistema define cuatro niveles progresivos de optimización que controlan la agresividad de las transformaciones aplicadas. Esta graduación permite que el usuario elija el balance apropiado entre fidelidad al diagrama original y eficiencia del código generado.

El **nivel none** desactiva completamente el optimizador, permitiendo que el código se genere exactamente como el usuario lo diseñó en el diagrama. Este nivel es útil durante la depuración cuando se necesita una correspondencia directa entre cada nodo del diagrama y su representación en código C, sin ninguna simplificación automática.

El **nivel basic** aplica únicamente la técnica de constant folding, la transformación más segura que evalúa expresiones constantes en tiempo de conversión. Por ejemplo, si un nodo de proceso contiene `int x = 2 + 3`, el código generado será `int x = 5`. Esta optimización nunca cambia el comportamiento del programa y siempre reduce el tamaño del código.

El **nivel standard** añade la eliminación de código muerto, que remueve ramas de ejecución que nunca pueden alcanzarse. Por ejemplo, cuando el constant folding determina que una condición es siempre verdadera, este nivel elimina la rama else correspondiente porque nunca se ejecutará. Este nivel también incluye simplificación algebraica básica.

El **nivel aggressive** habilita todas las técnicas disponibles y ejecuta múltiples pasadas de optimización. Cada pasada puede revelar nuevas oportunidades de mejora; por ejemplo, el constant folding podría crear una condición constante que la eliminación de código muerto aprovechará en la siguiente pasada. Este nivel usa hasta tres pasadas iterativas.

La siguiente tabla resume las técnicas habilitadas en cada nivel:

| Nivel | Constant Folding | Código Muerto | Simplificación | Flujo Control | Pasadas |
|-------|------------------|---------------|----------------|---------------|---------|
| none | No | No | No | No | 0 |
| basic | Sí | Sí | No | No | 1 |
| standard | Sí | Sí | Sí | No | 2 |
| aggressive | Sí | Sí | Sí | Sí | 3 |

---

## 20.3 Configuración del Optimizador

La configuración del optimizador permite personalizar su comportamiento más allá de los niveles predefinidos. Cada técnica de optimización puede habilitarse o deshabilitarse individualmente, y el número máximo de pasadas es configurable.

El parámetro **maxPasses** determina cuántas iteraciones completas de optimización se ejecutan. El optimizador continúa hasta alcanzar este límite o hasta que una pasada no produzca ningún cambio, lo que indica un punto fijo donde no existen más optimizaciones disponibles. Para el nivel basic se usa una sola pasada, para standard se usan dos, y para aggressive se permiten hasta tres pasadas iterativas.

Las técnicas individuales configurables incluyen constant folding para evaluación de expresiones constantes, eliminación de código muerto para remover código inalcanzable, simplificación de expresiones para aplicar identidades algebraicas, y optimización de flujo de control para simplificar estructuras condicionales.

---

## 20.4 Técnica: Constant Folding

El constant folding es la técnica de optimización más fundamental y segura. Consiste en evaluar expresiones que involucran únicamente literales durante la conversión, produciendo un único valor constante en lugar de dejar el cálculo para tiempo de ejecución.

Esta técnica opera recursivamente sobre el AST, identificando nodos de expresión binaria donde ambos operandos son literales conocidos en tiempo de conversión. La implementación maneja los cuatro tipos de datos soportados por FlowCode: enteros, flotantes, booleanos y cadenas.

Para operaciones entre enteros, el optimizador evalúa todos los operadores aritméticos (suma, resta, multiplicación, división entera, módulo) y relacionales (menor, mayor, igual, diferente). Por ejemplo, la expresión `10 / 3` se evalúa como `3` usando división entera, y `10 > 5` se evalúa como el literal booleano `true`.

Para operaciones con flotantes, se soportan los mismos operadores aritméticos pero usando división real. Si uno de los operandos es entero y el otro flotante, el entero se promueve automáticamente a flotante antes de la operación, siguiendo las reglas de conversión implícita de C.

Un caso especial es la división por cero. Cuando el optimizador detecta una división donde el divisor es el literal cero, no realiza la evaluación sino que deja la expresión intacta. Esto permite que el error se manifieste en tiempo de ejecución del programa C, donde producirá el comportamiento apropiado del runtime.

La evaluación de operaciones unarias también se incluye en esta técnica. La negación aritmética de un literal entero produce directamente el literal negativo correspondiente: `-5` como expresión se convierte en el literal `-5`. De manera similar, la negación lógica de un literal booleano produce su complemento.

---

## 20.5 Técnica: Eliminación de Código Muerto

El código muerto es aquel que nunca puede ejecutarse porque las condiciones necesarias para alcanzarlo son imposibles de satisfacer. El optimizador identifica y elimina tres categorías principales de código muerto, lo que reduce el tamaño del código generado y mejora su claridad.

La primera categoría son las **ramas condicionales con condición constante**. Cuando una sentencia if tiene una condición que es un literal booleano (frecuentemente resultado del constant folding previo), el optimizador conoce con certeza qué rama se ejecutará. Si la condición es `true`, se preserva únicamente el bloque then y se elimina completamente el else. Si la condición es `false`, se preserva el else (si existe) o se elimina toda la estructura if.

La segunda categoría son los **bucles que nunca ejecutan**. Un bucle while con condición `false` o un bucle for con condición de continuación `false` tienen cuerpos que nunca se ejecutarán. El optimizador los elimina completamente. Sin embargo, el inicializador de un bucle for puede tener efectos secundarios como declaraciones de variables, por lo que este se preserva como una sentencia independiente cuando es necesario.

La tercera categoría es el **código posterior a terminadores**. Cualquier sentencia que aparezca después de un `return`, `break` o `continue` dentro del mismo bloque es inalcanzable porque el flujo de control salió del bloque antes de llegar a ella. El optimizador elimina estas sentencias posteriores, que típicamente indican errores lógicos en el diseño del diagrama.

---

## 20.6 Técnica: Simplificación de Expresiones

La simplificación algebraica aplica identidades matemáticas para reducir expresiones que no involucran literales completos. A diferencia del constant folding que requiere ambos operandos constantes, esta técnica puede simplificar expresiones con variables cuando reconoce patrones algebraicos conocidos.

Las **identidades aditivas** reconocen que sumar cero no modifica el valor. Las expresiones `x + 0` y `0 + x` se reducen a simplemente `x`. De manera similar, restar cero de una expresión la deja inalterada, por lo que `x - 0` se simplifica a `x`.

Las **identidades multiplicativas** reconocen que multiplicar por uno no modifica el valor. Las expresiones `x * 1` y `1 * x` se reducen a `x`. La propiedad absorbente de la multiplicación también se aplica: `x * 0` y `0 * x` se evalúan directamente como `0`, independientemente del valor de x.

Las **identidades de auto-cancelación** reconocen operaciones que producen resultados triviales. La expresión `x - x` se evalúa como `0` para cualquier valor de x. De manera similar, `x / x` se evalúa como `1` (aunque esta optimización requiere cuidado con el caso donde x podría ser cero).

La simplificación también elimina **operaciones unarias redundantes**. La doble negación aritmética `--x` se reduce a `x`, ya que negar dos veces devuelve el valor original. De manera equivalente, la doble negación lógica `!!x` se reduce a `x` en contextos booleanos.

Estas simplificaciones son especialmente útiles cuando los estudiantes construyen expresiones incrementalmente en sus diagramas, añadiendo operaciones neutrales que posteriormente olvidan remover manualmente.

---

## 20.7 Métricas de Optimización

El optimizador recopila estadísticas detalladas sobre las transformaciones aplicadas, proporcionando retroalimentación cuantitativa sobre el proceso de optimización. Estas métricas tienen valor tanto técnico como educativo.

Cada técnica de optimización mantiene su propio contador: número de constantes plegadas, bloques de código muerto eliminados, expresiones simplificadas y optimizaciones de flujo de control aplicadas. La suma de estos contadores representa el total de transformaciones realizadas sobre el AST.

El campo de **porcentaje de reducción de tamaño** calcula la diferencia proporcional entre el número de nodos del AST original y el optimizado. Un valor alto indica que el diagrama contenía redundancias significativas que fueron eliminadas. Esta métrica proporciona retroalimentación útil al estudiante sobre la calidad de su diseño.

El resultado de la optimización también incluye un **registro de cambios** en formato legible. Cada transformación se documenta con una descripción como "Plegado: 2 + 3 → 5" o "Eliminado: if con condición constante true". Este registro permite que el usuario comprenda exactamente qué optimizaciones se aplicaron y por qué, facilitando el aprendizaje de buenas prácticas de programación.

---

## 20.8 Arquitectura Multi-Pasada

El optimizador ejecuta múltiples pasadas sobre el AST porque una optimización puede habilitar otras que no eran posibles inicialmente. Esta arquitectura iterativa maximiza las oportunidades de mejora sin requerir que cada técnica individual maneje todos los casos posibles.

Considere un diagrama que genera el siguiente código: una declaración `int temp = 2 + 3` seguida de un condicional `if (temp == 5)`. En la primera pasada, el constant folding transforma `2 + 3` en `5`. En la segunda pasada, el constant folding evalúa `temp == 5` como `true` si temp se inicializó con 5. En la tercera pasada, la eliminación de código muerto reconoce que la condición es siempre verdadera y elimina la estructura condicional, dejando únicamente el cuerpo del then.

El proceso iterativo continúa hasta que se alcanza un **punto fijo**, es decir, una pasada que no produce ningún cambio. Esto indica que el AST ya está completamente optimizado según las técnicas disponibles. Alternativamente, el proceso se detiene al alcanzar el límite máximo de pasadas configurado, previniendo bucles infinitos en casos patológicos.

El límite de tres pasadas para el nivel aggressive es suficiente para la gran mayoría de los diagramas que los estudiantes construyen en FlowCode, mientras mantiene tiempos de conversión imperceptibles para el usuario.

---

## 20.9 Integración con el Pipeline

El optimizador ocupa una posición estratégica en el pipeline de compilación: se ejecuta después del análisis semántico y antes de la generación de código. Esta ubicación no es arbitraria sino que responde a dependencias técnicas fundamentales.

Las optimizaciones dependen de la información de tipos proporcionada por el análisis semántico. Por ejemplo, el constant folding necesita saber si una división debe ser entera o real para producir el resultado correcto. Sin el análisis semántico previo, el optimizador no tendría esta información crucial.

La generación de código se beneficia enormemente de recibir un AST ya optimizado. Un árbol simplificado produce código C más limpio, más corto y más legible. Además, ciertas estructuras redundantes que serían difíciles de representar elegantemente en C simplemente no existen después de la optimización.

Si el nivel de optimización configurado es `none`, el AST pasa directamente a la generación de código sin ninguna modificación. El optimizador simplemente envuelve el árbol en un resultado con métricas en cero, manteniendo la interfaz consistente con el resto del pipeline.

El diseño conservador del optimizador garantiza que nunca modifica la semántica del programa. Cuando existe cualquier duda sobre la seguridad de una transformación, el optimizador la omite. Esta filosofía es especialmente importante en un contexto educativo: el código generado debe comportarse exactamente como el estudiante espera basándose en su diagrama de flujo.
