# AGENT.md — FlowCode: Intérprete de AST en Dart

## Qué es esto

FlowCode ya tiene un compilador completo que convierte diagramas de flujo en un Árbol de Sintaxis Abstracta (AST) con objetos Dart. El compilador también genera código C, pero no lo ejecuta.

Esta tarea agrega la capacidad de **ejecutar el diagrama directamente**, sin compiladores externos, sin internet, sin NDK. El intérprete recorre el AST ya construido y ejecuta la lógica del programa paso a paso en Dart puro. Cuando el programa necesita leer una entrada del usuario, la app pausa y muestra un campo de texto para que el usuario escriba en ese momento — igual que una terminal real.

---

## Lo que ya existe y debes entender antes de empezar

El proyecto ya tiene un pipeline de compilación completo que, dado un diagrama, produce un AST con todos los nodos del programa representados como objetos Dart. Ese AST ya tiene un patrón Visitor implementado: una interfaz que permite crear "recorridos" del árbol sin modificar los nodos. Ya existen dos recorridos: uno que genera código C y otro que optimiza el árbol. Esta tarea agrega un tercero: uno que ejecuta.

También existe un diálogo de resultados del compilador con seis pestañas (Resumen, Léxico, AST, Semántico, Optimización, Código). Esta tarea agrega la pestaña siete: Ejecutar.

---

## Qué construir

### Pieza 1 — El intérprete

Crear un nuevo recorrido del AST (un Visitor) que en lugar de generar texto de código C, ejecute la lógica del programa. Para cada tipo de nodo del árbol, debe hacer lo que ese nodo significa:

- Un nodo de número entero o decimal devuelve ese valor
- Un nodo de variable devuelve el valor que tiene guardado en ese momento
- Un nodo de operación aritmética evalúa los dos lados y aplica el operador
- Un nodo de asignación evalúa el lado derecho y guarda el resultado en la variable
- Un nodo de declaración crea la variable con un valor inicial de cero
- Un nodo de decisión (if) evalúa la condición y ejecuta la rama que corresponde
- Un nodo de bucle while repite el cuerpo mientras la condición sea verdadera
- Un nodo de bucle for ejecuta la inicialización, luego repite condición y cuerpo
- Un nodo de salida (printf) produce una línea de texto visible en la UI
- Un nodo de entrada (scanf) pausa la ejecución y espera que el usuario escriba un valor

El intérprete debe mantener una tabla de variables en memoria (nombre → valor actual) y actualizarla conforme el programa avanza.

**Reglas de tipos:**
- Operaciones entre enteros producen entero
- Cualquier operación que involucre un decimal produce decimal
- Al leer un valor de teclado, convertirlo al tipo que la variable espera

**Seguridad — el intérprete debe detenerse solo ante:**
- División entre cero → error con mensaje descriptivo
- Uso de variable no declarada → error con mensaje descriptivo
- Más de 10,000 pasos de ejecución → advertencia de posible bucle infinito
- Más de 5 segundos de tiempo real → corte por timeout
- Solicitud de cancelación del usuario

---

### Pieza 2 — Comunicación interactiva con la UI

El intérprete corre en un hilo separado (Isolate de Dart) para no bloquear la interfaz. La comunicación entre el intérprete y la UI funciona con mensajes:

- Cuando el intérprete produce una línea de salida, envía un mensaje a la UI del tipo "nueva línea de output"
- Cuando el intérprete llega a un scanf, envía un mensaje a la UI del tipo "necesito un valor del usuario" y se queda esperando
- La UI recibe ese mensaje, muestra un campo de texto activo, y espera que el usuario escriba y presione enter
- La UI envía el valor escrito de regreso al intérprete
- El intérprete recibe el valor, lo asigna a la variable, y continúa desde donde pausó
- Cuando el intérprete termina (normal o por error), envía un mensaje final con el resultado

Este flujo se repite cada vez que hay un scanf, en orden. La UI nunca se bloquea durante la espera — el usuario puede cancelar en cualquier momento.

---

### Pieza 3 — Servicio de ejecución

Crear un servicio que maneje el ciclo de vida completo de la ejecución. El servicio debe:

- Verificar que el compilador terminó sin errores antes de intentar ejecutar
- Iniciar el intérprete en un hilo separado
- Recibir y redistribuir todos los eventos que el intérprete emite (líneas de output, solicitudes de input, errores, finalización)
- Enviar los valores de input del usuario al intérprete cuando este los pida
- Permitir cancelar la ejecución en cualquier momento y limpiar el hilo correctamente
- Exponer el estado actual a la UI: corriendo, esperando input, terminado, error

---

### Pieza 4 — La pestaña "Ejecutar"

Agregar una séptima pestaña al diálogo de resultados del compilador. Esta pestaña tiene dos zonas:

**Zona de terminal (parte principal):**

La terminal muestra la conversación del programa con el usuario en orden cronológico. Cada línea tiene un estilo distinto según su origen:

- Las líneas de salida del programa (printf) aparecen en verde con fuente monoespacio
- Los valores que el usuario escribió (stdin) aparecen en gris con fuente monoespacio, precedidos de `>`
- Los mensajes de error aparecen en rojo con el mensaje descriptivo
- Cuando el programa solicita un valor, aparece un campo de texto activo debajo de la última línea, enfocado automáticamente. El usuario escribe el valor y presiona enter para enviarlo. Después de enviarlo, el campo desaparece y el valor digitado queda registrado en gris en la terminal
- La terminal hace scroll automático hacia abajo conforme llegan nuevas líneas
- Al terminar, aparece al final una línea de footer con: tiempo transcurrido, iteraciones usadas, y razón de parada (completado / error / límite / cancelado)

**Barra de acciones (parte inferior):**
- Botón "Ejecutar" — inicia la ejecución; se desactiva mientras el programa corre
- Botón "Cancelar" — solo activo mientras el programa corre o espera input; al presionarlo el programa se detiene limpiamente
- Botón "Limpiar" — borra toda la terminal y reinicia el estado a idle

**Estados visibles de la UI:**

| Estado | Qué muestra |
|---|---|
| Idle | Mensaje gris centrado: "Presiona Ejecutar para correr el diagrama" |
| Corriendo | Indicador de carga animado en la parte inferior de la terminal |
| Esperando input | Campo de texto activo y enfocado debajo de la última línea |
| Completado | Terminal completa + footer con métricas |
| Error | Mensaje rojo descriptivo; si se identifica qué nodo causó el error, mencionarlo |
| Límite de iteraciones | Advertencia amarilla: "El programa superó 10,000 pasos. Posible bucle infinito." |
| Timeout | Advertencia naranja: "El programa tardó más de 5 segundos y fue detenido." |

**Si el compilador tiene errores:** La pestaña muestra solo el mensaje "Corrige los errores del compilador antes de ejecutar" y no muestra el botón Ejecutar.

---

### Pieza 5 — Tests del intérprete

Crear tests unitarios que verifiquen el intérprete de forma aislada, usando el mismo pipeline de compilación que usan los tests existentes para construir los programas de prueba. Cubrir al menos:

- Programa mínimo que solo inicia y termina ejecuta sin error
- Declarar una variable y asignarle un valor produce el valor correcto
- Suma, resta, multiplicación y división producen resultados correctos
- División por cero produce un error con mensaje descriptivo
- Un if con condición verdadera ejecuta la rama correcta
- Un if con condición falsa ejecuta la otra rama
- Un while ejecuta el cuerpo el número correcto de veces
- Un for itera el número correcto de veces
- printf produce la línea de texto esperada en el output
- scanf con un valor de entrada asigna el valor a la variable correctamente
- Un bucle infinito se detiene solo al llegar al límite de 10,000 iteraciones
- Cancelar la ejecución la detiene aunque el programa no haya terminado

---

## Restricciones absolutas

- No usar NDK, JNI, FFI nativo ni MethodChannel
- No hacer llamadas HTTP ni usar internet
- No modificar ninguno de los archivos del compilador existente
- No agregar dependencias externas al proyecto
- El intérprete debe poder testearse sin levantar la app completa
- No introducir colores ni estilos nuevos que no existan ya en el proyecto

---

## Orden de implementación

Implementar en este orden exacto para poder verificar cada pieza antes de continuar:

1. El intérprete (sin UI, completamente testeable)
2. Los tests del intérprete (deben pasar al 100% antes de continuar)
3. El servicio de ejecución con comunicación por Isolate
4. La pestaña de UI
5. Integrar la pestaña al diálogo existente

---

## Criterio de éxito

- Todos los tests nuevos del intérprete pasan al 100%
- Ningún test existente del proyecto se rompe
- El diagrama "Par o Impar" ejecuta correctamente: cuando el programa pide el número, el usuario escribe 42 en la UI y el programa responde "42 es par"
- Un diagrama con bucle infinito se detiene solo sin colgar la app ni requerir reiniciarla
- La cancelación funciona aunque el programa esté en medio de un bucle o esperando input
- El campo de texto aparece automáticamente cuando el programa pide un valor y desaparece cuando el usuario lo envía
