# Tema 23: Pruebas de Integración

# CICLO 6: INTEGRACIÓN

---

## Fase 1: Determinación de Objetivos

### Objetivos del Ciclo 6

Este ciclo integra todas las fases del conversor en un flujo completo y funcional, conectando el conversor fuente a fuente con el editor visual e implementando el recorrido de extremo a extremo desde la creación del diagrama hasta la obtención del código C válido y funcional. La integración abarca el mapeo de los seis tipos de símbolos ISO 5807 soportados, la visualización interactiva de resultados y el desarrollo de la suite de pruebas que verifica el correcto funcionamiento del sistema completo [1], [3].

**Objetivos del Ciclo 6:**

- Implementar el mapeo completo de los seis símbolos del estándar ISO 5807 a construcciones del lenguaje C, coordinado a través de la clase orquestadora del flujo de conversión.
- Integrar el flujo de conversión con el editor visual mediante la barra de herramientas flotante, exponiendo la conversión como una acción accesible al usuario.
- Desarrollar el diálogo de resultados del conversor con pestañas diferenciadas para cada fase del análisis: léxico, árbol sintáctico abstracto, semántico, optimización y código generado.
- Implementar el sistema de visualización de errores con codificación por color según severidad (fatal, error, advertencia, información).
- Construir la suite completa de pruebas que valide cada fase del conversor de forma independiente y el flujo de extremo a extremo en conjunto.
- Verificar que el código C producido convierte sin errores en GCC con el estándar C99.

---

## Fase 2: Análisis de Riesgos

### Riesgos identificados y mitigados

| Riesgo | Estrategia de Mitigación | Observaciones |
|--------|--------------------------|---------------|
| Incompatibilidades entre módulos al integrar las cinco fases del conversor | Ejecución continua de la suite de pruebas del ciclo anterior durante el desarrollo de la integración | |
| Degradación del rendimiento al conectar todos los componentes en un solo flujo | Medición de tiempos por fase mediante métricas de conversión; optimización puntual con los resultados obtenidos | |
| Pérdida de información semántica entre la fase de análisis y la generación de código | Propagación explícita de la tabla de símbolos a través de todas las fases del flujo de conversión | |
| Discrepancias entre el código generado y la sintaxis esperada por GCC | Validación de compilabilidad como criterio de aceptación en cada caso de prueba de integración | |

**Tabla 103.** Riesgos identificados y mitigados.

---

## Fase 3: Desarrollo y Verificación

### Productos generados

- Flujo de conversión (`DiagramCompilerPipeline`) completamente integrado y funcional, que orquesta las cinco fases secuenciales del conversor.
- Integración entre la interfaz de usuario y el conversor mediante la barra de herramientas flotante con botón de conversión.
- Diálogo de resultados del conversor con seis pestañas: resumen de métricas, tokens léxicos, árbol sintáctico abstracto, análisis semántico, transformaciones de optimización y código C generado con resaltado de sintaxis.
- Sistema de visualización de errores con colores según severidad: rojo oscuro (fatal, detiene la conversión), rojo (error, impide la generación de código), naranja (advertencia, código generado con observaciones) y azul (información adicional).
- Mapeo completo de los seis tipos de símbolos ISO 5807 implementado y verificado con casos de prueba específicos.
- Suite de pruebas con 290 casos automatizados organizados en pruebas unitarias por fase del conversor y pruebas de integración de extremo a extremo.

---

## Fase 4: Planificación

### Entregables

- Informe del Ciclo 6: documentación de la integración, pruebas y métricas de cobertura.
- Plan detallado para el Ciclo 7: Pruebas y Documentación.

---

---

# 21. Pruebas de Integración

Las pruebas de FlowCode se organizan en dos niveles: pruebas unitarias, que verifican cada fase del conversor fuente a fuente de forma independiente, y pruebas de integración, que validan el flujo completo desde el diagrama hasta el código C. Se empleó el marco de pruebas automatizadas incluido en el SDK de Flutter para construir una suite de 290 casos organizados por fase del conversor y por caso de uso del sistema [16]. Los resultados de cada prueba se comparan contra resultados esperados predefinidos, lo que permite verificar tanto la corrección funcional como la estabilidad ante entradas problemáticas. Las pruebas de autenticación y sincronización en la nube (Firebase) se ejecutan de forma separada por requerir configuración de servicios externos [22].

---

## 21.1 Estrategia de Pruebas

Las pruebas unitarias verifican el comportamiento correcto de cada fase del conversor de forma aislada: el analizador léxico, el sintáctico, el semántico, el optimizador del AST y el generador de código. Las pruebas de integración verifican que las cinco fases operan de forma coordinada al procesar diagramas de flujo completos conformes al estándar ISO 5807:1985 [19], y establecen trazabilidad con los casos de uso CU01–CU07 del sistema. La funcionalidad de almacenamiento local (CU08) y la integración con Firebase (CU09, CU10) se verifican mediante pruebas funcionales ejecutadas manualmente sobre el dispositivo físico Samsung Galaxy A26 5G, dado que estas funciones dependen de servicios externos y de la capa de presentación de la aplicación.

| Componente | Tipo | Pruebas | Líneas de código de prueba | Casos de uso cubiertos |
|------------|------|--------:|---------------------------:|------------------------|
| Análisis léxico | Unitaria | 47 | 628 | CU04 |
| Análisis sintáctico | Unitaria | 84 | 1 273 | CU04 |
| Análisis semántico | Unitaria | 43 | 1 508 | CU05 |
| Optimización del AST | Unitaria | 53 | 1 085 | CU06 |
| Generación de código (avanzada) | Unitaria | 5 | 446 | CU06 |
| Generación de código (estructuras de control) | Unitaria | 8 | 556 | CU06 |
| Integración extremo a extremo | Integración | 33 | 1 137 | CU01–CU07 |
| Pruebas de rendimiento | Rendimiento | 17 | 1 047 | — |
| **Total suite base** | | **290** | **7 680** | **CU01–CU07** |

**Tabla 104.** Tabla general de archivos de prueba.

> *[Figura X. Captura de pantalla de la terminal mostrando la ejecución de la suite completa con el resultado «290 tests passed».]*

La tabla siguiente establece la trazabilidad entre cada caso de uso y los artefactos de prueba que lo validan.

| ID | Caso de Uso | Tipo de prueba | Estado | Observaciones |
|----|-------------|----------------|--------|---------------|
| CU01 | Crear Nuevo Diagrama | Automatizada | ✅ | Verificado mediante pruebas de integración extremo a extremo |
| CU02 | Agregar y Conectar Elementos | Automatizada | ✅ | Cubre los seis símbolos ISO 5807 y estructuras de control |
| CU03 | Editar Propiedades de Elementos | Manual + automatizada parcial | ⚠️ | Los diálogos de edición se verificaron manualmente; la validación de expresiones subyacente está cubierta por las pruebas unitarias semánticas |
| CU04 | Validar Estructura del Diagrama | Automatizada | ✅ | Validaciones E-SYN verificadas en pruebas unitarias sintácticas y en integración |
| CU05 | Realizar Análisis Semántico | Automatizada | ✅ | |
| CU06 | Generar Código C | Automatizada | ✅ | Incluye optimización y generación |
| CU07 | Exportar Proyecto Completo | Automatizada | ✅ | Verificación del artefacto de salida y las métricas; la corrección del código se cubre en CU06 |
| CU08 | Organizar Proyectos en Carpetas | Prueba funcional manual | ⚠️ | Se verificó manualmente en el dispositivo Samsung Galaxy A26 5G |
| CU09 | Registrar Cuenta de Usuario | Automatizada (requiere Firebase) | ⚠️ | Requiere inicialización del servicio de autenticación; se ejecuta por separado |
| CU10 | Sincronizar Proyectos a la Nube | Verificación manual | ⚠️ | No forma parte de la suite automatizada base |

**Tabla 105.** Cobertura de pruebas por caso de uso.

---

## 21.2 Pruebas Unitarias

Las pruebas unitarias validan el comportamiento de cada fase del conversor de forma independiente. Cada archivo de prueba instancia únicamente el componente bajo análisis y verifica su salida contra resultados predefinidos.

### 21.2.1 Analizador Léxico

El analizador léxico se validó con 47 casos de prueba que cubren la tokenización de literales, operadores, palabras reservadas del lenguaje C, palabras clave en español («Escribir», «Leer») y el manejo de errores. La detección de identificadores, el reconocimiento de los tipos de datos soportados (`int`, `float`, `char`) y la inferencia de especificadores de formato para las operaciones de entrada/salida fueron verificados de forma independiente [1].

| Grupo de pruebas | Pruebas |
|-----------------|--------:|
| Tokenización de expresiones | 11 |
| Tokenización básica de literales | 7 |
| Tabla de símbolos | 6 |
| Operadores | 5 |
| Tipos de datos | 3 |
| Especificadores de formato | 3 |
| Análisis de nodos del diagrama | 3 |
| Propiedades de los tipos de token | 3 |
| Análisis del diagrama completo | 2 |
| Manejo de errores léxicos | 2 |
| Validación de identificadores | 2 |
| **Total** | **47** |

**Tabla 115.** Pruebas del analizador léxico por grupo.

### 21.2.2 Analizador Sintáctico

El analizador sintáctico se validó con 84 casos de prueba que cubren la construcción del árbol de sintaxis abstracta (AST) y el reconocimiento de las distintas construcciones del lenguaje C soportadas por FlowCode [1], [3]. El analizador implementa el método de descenso recursivo, lo que permite tratar expresiones aritméticas, lógicas y relacionales con la precedencia correcta.

| Grupo de pruebas | Pruebas | Observaciones |
|-----------------|--------:|---------------|
| Análisis de expresiones | 27 | Cubre expresiones aritméticas, lógicas y relacionales |
| Análisis de nodos del diagrama | 9 | |
| Validaciones estructurales | 7 | |
| Nodos del AST | 6 | |
| Inicializadores de arreglos | 5 | |
| Nodos de sentencia | 5 | |
| Errores sintácticos | 4 | |
| Integración con el flujo de conversión | 3 | |
| Análisis del diagrama completo | 3 | |
| Patrón Visitante del AST | 2 | |
| Extensiones de operadores binarios | 2 | |
| Extensiones de operadores unarios | 2 | |
| Sentencias de retorno | 1 | |
| **Total** | **84** | |

**Tabla 116.** Pruebas del analizador sintáctico por grupo.

### 21.2.3 Analizador Semántico

El analizador semántico se validó con 43 casos de prueba que verifican la detección de errores semánticos, la verificación de tipos, el análisis de alcance y la propagación de la tabla de símbolos a lo largo del flujo de conversión [1], [3].

| Grupo de pruebas | Pruebas |
|-----------------|--------:|
| Parámetros semánticos y tipos de error | 6 |
| Integración con el flujo de conversión | 3 |
| Nodos de datos (entrada/salida) | 3 |
| Verificación de tipos | 3 |
| Variables no declaradas | 3 |
| División y módulo por cero | 2 |
| Nodos de bucle | 2 |
| Variables no utilizadas | 2 |
| Generación de reportes | 2 |
| Resultado del análisis semántico | 2 |
| Entorno de tipos | 2 |
| Prueba básica de instanciación | 1 |
| Declaraciones duplicadas | 1 |
| Métodos de extensión | 1 |
| Resultado por nodo semántico | 1 |
| Palabras clave en español | 1 |
| **Total** | **43** |

**Tabla 117.** Pruebas del analizador semántico por grupo.

### 21.2.4 Optimizador del AST y Generador de Código

El optimizador del AST se validó con 53 casos que cubren las cuatro técnicas implementadas: plegado de constantes, eliminación de código muerto, simplificación algebraica y propagación de variables. El generador de código se validó con 13 casos distribuidos en dos archivos: 5 para la generación de expresiones y declaraciones, y 8 para la generación de estructuras de control (`if/else`, `while`, `for`, `switch`).

| Componente | Grupo | Pruebas |
|------------|-------|--------:|
| Optimizador | Plegado de constantes y simplificación algebraica | 53 |
| Generador (avanzado) | Expresiones, declaraciones y especificadores de formato | 5 |
| Generador (estructuras de control) | `if/else`, `while`, `for`, `switch/case` | 8 |
| **Total** | | **66** |

**Tabla 118.** Pruebas del optimizador y generador de código.

---

## 21.3 Pruebas de Integración

Las pruebas de integración validan el flujo completo del conversor fuente a fuente: desde la estructura del diagrama hasta el código C generado. Se emplearon 33 casos de prueba extremo a extremo que instancian el `DiagramCompilerPipeline` completo y verifican el resultado final contra oráculos predefinidos.

### 21.3.1 CU01 — Crear Nuevo Diagrama

Se valida la inicialización de un proyecto de diagrama y la ejecución completa del flujo de conversión a partir de la estructura mínima válida (nodo Inicio conectado a un nodo Fin).

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU01-T01 | Diagrama con únicamente nodos Inicio y Fin se convierte sin errores | conversión exitosa; código C generado |
| CU01-T02 | Los nodos terminales producen la función `main()` con retorno cero | Código contiene `int main()` y `return 0;` |
| CU01-T03 | Las variantes en español («Inicio/Fin») y en inglés («Start/End») son aceptadas | Ambas variantes se compilan correctamente |
| CU01-T04 | Las cinco fases del conversor se ejecutan en secuencia | Se registran métricas de tiempo para cada fase |

**Tabla 106.** Pruebas de CU01 — Crear Nuevo Diagrama.

### 21.3.2 CU02 — Agregar y Conectar Elementos

Se valida la construcción de algoritmos mediante los símbolos del estándar ISO 5807:1985 [19] y las conexiones entre nodos.

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU02-T01 | Nodo de proceso con declaración `int x = 10` | Variable declarada en el código C resultante |
| CU02-T02 | Nodo de proceso con asignación `x = x + 1` | Sentencia de asignación en el código C |
| CU02-T03 | Tres o más nodos secuenciales conectados | Código generado en el orden correcto |
| CU02-T04 | Nodo de decisión con condición `x > 5` | Se genera la estructura `if()` |
| CU02-T05 | Decisión con ramas «Sí» y «No» completas | Se genera `if/else` con ambos bloques |
| CU02-T06 | Nodo de datos con operación de lectura («Leer edad») | Se genera `scanf()` |
| CU02-T07 | Nodo de datos con operación de escritura («Escribir valor») | Se genera `printf()` |
| CU02-T08 | Especificadores de formato según tipo de dato | `%d` para entero, `%f` para flotante |
| CU02-T09 | Nodo de preparación (hexágono de inicialización) | Se procesa correctamente en el flujo |
| CU02-T10 | Nodo de subproceso (rectángulo con doble línea) | Se genera una llamada a función |
| CU02-T11 | Conexión Inicio → Proceso → Fin | El flujo de control se preserva en el código |
| CU02-T12 | Etiquetas «Sí»/«No» en las aristas de una decisión | Las ramas se asignan correctamente |
| CU02-T13 | Nodo de decisión usado como condición de bucle | Se genera la estructura de bucle correspondiente |
| CU02-T14 | Nodo de bucle `for` con metadatos de tipo | Se genera `for(;;)` con los límites correctos |
| CU02-T15 | Nodo de selección múltiple con casos definidos | Se genera `switch/case/break` |

**Tabla 107.** Pruebas de CU02 — Agregar y Conectar Elementos.

### 21.3.3 CU04 — Validar Estructura del Diagrama

Se valida que el analizador estructural detecta correctamente el incumplimiento de las reglas del estándar ISO 5807 definidas en las validaciones E-SYN del sistema [1], [19].

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU04-T01 | Diagrama con exactamente un nodo Inicio | Se supera la validación E-SYN-001 |
| CU04-T02 | Diagrama con dos nodos Inicio | Se reporta el error E-SYN-002 (Inicio no único) |
| CU04-T03 | Todos los nodos son alcanzables desde el nodo Inicio | La validación de alcanzabilidad (BFS) concluye sin errores |
| CU04-T04 | Nodo de proceso sin conexión de salida | Se reporta el error de nodo sin salida (E-SYN-013) |
| CU04-T05 | Nodo de decisión con una sola salida | Se reporta el error E-SYN-010 (decisión con ≠ 2 salidas) |

**Tabla 108.** Pruebas de CU04 — Validar Estructura del Diagrama.

### 21.3.4 CU05 — Realizar Análisis Semántico

Se valida la consistencia de variables, tipos de datos y la lógica de flujo del programa. El analizador semántico aplica las reglas S01–S10 definidas en el Ciclo 4 [1], [3].

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU05-T01 | Instancia del analizador semántico | Objeto inicializado correctamente |
| CU05-T02 | Uso de variable no declarada en nodo de proceso (`x = y + 5`) | Error de variable no declarada para «y» |
| CU05-T03 | Uso de variable declarada previamente | Sin errores para la variable declarada |
| CU05-T04 | Condición con variable no declarada (`unknown > 10`) | Error de variable no declarada |
| CU05-T05 | Declaración duplicada de la misma variable | Error de declaración duplicada |
| CU05-T06 | Inferencia de tipo entero (`int x = 10`) | Tipo entero asignado en la tabla de símbolos |
| CU05-T07 | Inferencia de tipo flotante (`float y = 3.14`) | Tipo flotante asignado en la tabla de símbolos |
| CU05-T08 | Asignación de flotante a entero | Advertencia de incompatibilidad de tipos |
| CU05-T09 | División por cero literal (`x / 0`) | Error de división por cero |
| CU05-T10 | Módulo por cero literal (`x % 0`) | Error de módulo por cero |
| CU05-T11 | Variable declarada pero no utilizada | Advertencia de variable no utilizada |
| CU05-T12 | Variable declarada y utilizada | Sin advertencias |
| CU05-T13 | Variable no declarada en nodo de entrada («Leer no_declarada») | Error de variable no declarada |
| CU05-T14 | Variable no declarada en nodo de salida («Escribir desconocida») | Error de variable no declarada |
| CU05-T15 | Operación de entrada/salida con variable válida | Sin errores |
| CU05-T16 | Condición de bucle con variable declarada (`mientras i < 5`) | Sin errores |
| CU05-T17 | Condición de bucle con variable no declarada | Error de variable no declarada |
| CU05-T18 | Generación del reporte semántico para diagrama válido | Reporte con estadísticas generado |
| CU05-T19 | Ejecución del flujo de conversión con análisis semántico | Resultado semántico no nulo |
| CU05-T20 | Flujo de conversión con errores semánticos presentes | El resultado indica fallo |

**Tabla 109.** Pruebas de CU05 — Realizar Análisis Semántico.

### 21.3.5 CU06 — Generar Código C

Se valida la producción de código C funcional a partir del diagrama validado, incluyendo la corrección estructural y la compilabilidad del código resultante.

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU06-T01 | Código generado contiene directivas de inclusión, `main()` y sentencia de retorno | Elementos estructurales presentes |
| CU06-T02 | Llaves balanceadas en todo el código generado | Cantidades iguales de apertura y cierre |
| CU06-T03 | Todas las sentencias terminan con punto y coma | Sintaxis C válida |
| CU06-T04 | Código generado para diagrama simple es válido y funcional | El código es sintácticamente válido según GCC |
| CU06-T05 | Diagrama con operaciones de lectura y escritura produce `printf`/`scanf` | Funciones de entrada/salida generadas |
| CU06-T06 | Todas las variables utilizadas están declaradas antes de su uso | Sin errores semánticos en el código |
| CU06-T07 | Instrucción de escritura con múltiples variables | `printf` con múltiples especificadores de formato |
| CU06-T08 | Especificador de formato correcto según tipo de dato | `%d` entero, `%f` flotante, `%c` carácter |
| CU06-T09 | Flujo de conversión completo con plantilla de diagrama | Código C ejecutable producido |
| CU06-T10 | Declaración de múltiples variables en un nodo | Declaración correcta en el código C |
| CU06-T11 | Nodo de selección múltiple estructurado | Se genera `switch/case/break` |
| CU06-T12 | Nodo de bucle `for` con límites definidos | Se genera `for(;;)` correcto |
| CU06-T13 | Nodo de bucle `while` con condición | Se genera `while()` correcto |
| CU06-T14 | Diferenciación entre bucle `for` y bucle `while` | Se producen estructuras distintas según el tipo |
| CU06-T15 | Detección de selección múltiple por patrón textual | Se reconoce el patrón y se genera `switch` |

**Tabla 110.** Pruebas de CU06 — Generar Código C.

> *[Figura X. Captura de pantalla del diálogo de resultados del conversor en FlowCode mostrando el código C generado con resaltado de sintaxis en la pestaña «Código».]*

### 21.3.6 CU07 — Exportar Proyecto Completo

Se valida la generación del código exportable, las métricas de conversión y el reporte completo del proceso. La corrección del código C producido se verifica en las pruebas de CU06; en este caso de uso se confirma únicamente que el artefacto de salida y las métricas están disponibles para su exportación.

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU07-T01 | conversión y obtención del código como cadena de texto | Código generado no nulo |
| CU07-T02 | Obtención de tiempos de ejecución por fase | Métricas con valores mayores a cero |
| CU07-T03 | Generación del reporte completo de conversión | Reporte que incluye fases, errores y código generado |

**Tabla 111.** Pruebas de CU07 — Exportar Proyecto Completo.

---

## 21.4 Pruebas Funcionales Manuales

Las siguientes funciones se verificaron mediante pruebas ejecutadas manualmente sobre el dispositivo físico Samsung Galaxy A26 5G, dado que dependen de la capa de presentación de la aplicación o de servicios externos. Para cada caso de uso se definieron escenarios predefinidos y se verificó visualmente el comportamiento esperado.

### 21.4.1 CU03 — Editar Propiedades de Elementos

Los diálogos de edición de nodo (proceso, decisión, datos, conector y comentario) se verificaron manualmente introduciendo expresiones válidas e inválidas y confirmando la retroalimentación visual de la aplicación. La validación de expresiones subyacente —detección de variables no declaradas, errores de sintaxis y tipos incompatibles— se encuentra cubierta por las pruebas unitarias del analizador semántico (sección 21.2.3).

> *[Figura X. Captura de pantalla del diálogo de edición de propiedades de un nodo de decisión en la aplicación FlowCode ejecutándose en el dispositivo físico.]*

### 21.4.2 CU08 — Organizar Proyectos en Carpetas

La gestión de proyectos en carpetas se verificó comprobando la creación de carpetas, el traslado de proyectos entre ellas y la persistencia de la estructura jerárquica tras el cierre y reapertura de la aplicación. El almacenamiento local se realiza mediante SQLite a través de la biblioteca `sqflite` [13], [14].

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU08-T01 | Creación de carpeta y asignación de proyecto | La estructura persiste en la base de datos local |
| CU08-T02 | Traslado de proyecto entre carpetas | Las referencias se actualizan correctamente |
| CU08-T03 | Persistencia de la estructura tras reinicio de la aplicación | La jerarquía se recupera correctamente de SQLite |

**Tabla 112.** Pruebas de CU08 — Organizar Proyectos en Carpetas.

### 21.4.3 CU09 — Registrar Cuenta de Usuario

Las pruebas de autenticación mediante Firebase Authentication [22] se ejecutan de forma independiente a la suite base, ya que requieren la inicialización del servicio de autenticación en entorno de prueba.

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU09-T01 | Registro con correo electrónico nuevo | Usuario creado; correo electrónico coincide |
| CU09-T02 | Verificación de correo electrónico ya registrado | La comprobación retorna verdadero |
| CU09-T03 | Intento de registro con correo duplicado | Se lanza la excepción correspondiente |

**Tabla 113.** Pruebas de CU09 — Registrar Cuenta de Usuario.

### 21.4.4 CU10 — Sincronizar Proyectos a la Nube

La sincronización con Firebase Firestore [22] se verificó mediante un script de verificación manual que consulta los servicios de autenticación y la disponibilidad de métricas de usuario. Esta validación no forma parte de la suite automatizada base, ya que depende de la disponibilidad de la conexión a internet y de las credenciales de Firebase.

| ID Prueba | Descripción | Resultado Esperado |
|-----------|-------------|-------------------|
| CU10-T01 | Servicio de autenticación disponible e inicializado | Servicio funcional |
| CU10-T02 | Métricas de usuarios recuperadas de Firebase | Datos disponibles y correctos |

**Tabla 114.** Pruebas de CU10 — Sincronizar Proyectos a la Nube.

> *[Figura X. Captura de pantalla de la pantalla de inicio de sesión y la pantalla principal de la aplicación ejecutándose en el Samsung Galaxy A26 5G.]*

---

## 21.5 Verificación del Código Generado

La corrección estructural del código C producido por el generador se verificó mediante comprobaciones programáticas sobre las cadenas de texto resultantes. Se confirma que todo código generado cumple con los cinco requisitos estructurales mínimos de un programa en C válido según el estándar ISO/IEC 9899:2018 [8].

| Verificación | Descripción | Estado |
|--------------|-------------|--------|
| Directivas de inclusión | La directiva `#include <stdio.h>` está presente | ✅ |
| Función principal | La función `int main(void)` está correctamente formada | ✅ |
| Sentencia de retorno | La sentencia `return 0;` cierra la función principal | ✅ |
| Llaves balanceadas | Las llaves de apertura y cierre son iguales en número | ✅ |
| Punto y coma en sentencias | Todas las sentencias terminan con `;` | ✅ |

**Tabla 119.** Verificación de la estructura del código C generado.

> *[Figura X. Ejemplo de código C generado por FlowCode a partir de la plantilla «05. Par o Impar», mostrando la función `main()`, las operaciones de entrada/salida y la estructura `if/else`.]*

---

## 21.6 Estadísticas de Cobertura

### Por tipo de prueba

| Tipo | Pruebas | Porcentaje |
|------|--------:|-----------:|
| Unitarias (fases del conversor) | 240 | 82.8 % |
| Integración extremo a extremo | 33 | 11.4 % |
| Rendimiento | 17 | 5.8 % |
| **Total** | **290** | **100 %** |

### Por fase del conversor

| Fase | Pruebas | Cobertura |
|------|--------:|-----------|
| Léxico | 47 | Alta |
| Sintáctico | 84 | Alta |
| Semántico | 43 | Alta |
| Optimización | 53 | Alta |
| Generación (avanzada) | 5 | Media |
| Generación (estructuras de control) | 8 | Media |
| Integración extremo a extremo | 33 | Alta |
| Rendimiento | 17 | — |

### Por tipo de nodo ISO 5807

| Tipo de nodo | Símbolo | Pruebas de integración | Estado |
|---|---|---:|---|
| Terminal | Óvalo | 2 | ✅ |
| Proceso | Rectángulo | 4 | ✅ |
| Datos (E/S) | Paralelogramo | 3 | ✅ |
| Decisión | Rombo | 3 | ✅ |
| Preparación | Hexágono | 2 | ✅ |
| Subproceso | Rectángulo doble línea | 1 | ✅ |
| Comentario | Corchete abierto | 1 | ✅ |
| Conector | Círculo | 1 | ✅ |

### Por categoría de error detectado

| Categoría | Estado |
|-----------|--------|
| Errores léxicos (caracteres inválidos en expresiones) | ✅ |
| Errores sintácticos (paréntesis no balanceados y construcciones inválidas) | ✅ |
| Errores semánticos (variables no declaradas, tipos incompatibles, división por cero) | ✅ |
| Recuperación de errores (el flujo continúa tras errores no fatales) | ✅ |

### Métricas generales

| Métrica | Valor |
|---------|------:|
| Total de pruebas automatizadas (suite base) | 290 |
| Pruebas aprobadas | 290 (100 %) |
| Pruebas de integración extremo a extremo | 33 |
| Fases del conversor cubiertas | 5 de 5 |
| Tipos de nodo ISO 5807 verificados | 6 directos + 2 indirectos |
| Categorías de error detectadas | 4 |

**Tabla 120.** Métricas de pruebas de integración.
