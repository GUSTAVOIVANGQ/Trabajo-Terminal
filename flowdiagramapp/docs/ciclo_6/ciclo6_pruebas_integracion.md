# CICLO 6: INTEGRACIÓN

---

## Fase 1: Determinación de Objetivos

### Objetivos del Ciclo 6

Este ciclo integra todas las fases del conversor en un flujo completo y funcional, conectando el conversor fuente a fuente con el editor visual e implementando el recorrido de extremo a extremo desde la creación del diagrama hasta la obtención del código C válido y funcional. La integración abarca el mapeo de los seis tipos de símbolos ISO 5807 soportados, la visualización interactiva de resultados y el desarrollo del conjunto de pruebas que verifica el correcto funcionamiento del sistema completo [1], [3].

**Objetivos del Ciclo 6:**

- Implementar el mapeo completo de los seis símbolos del estándar ISO 5807 a construcciones del lenguaje C, coordinado por el componente que orquesta el flujo de conversión.
- Integrar el flujo de conversión con el editor visual mediante la barra de herramientas flotante, exponiendo la conversión como una acción accesible al usuario.
- Desarrollar el diálogo de resultados del conversor con pestañas diferenciadas para cada fase del análisis: léxico, árbol sintáctico abstracto, semántico, optimización y código generado.
- Implementar el sistema de visualización de errores con codificación por color según severidad (fatal, error, advertencia, información).
- Construir el conjunto de pruebas que valide cada fase del conversor de forma independiente y el flujo de extremo a extremo en conjunto.
- Verificar que el código C producido es válido y funcional bajo GCC con el estándar C99 (verificación externa complementaria a las pruebas automatizadas).

---

## Fase 2: Análisis de Riesgos

### Riesgos identificados y mitigados

| Riesgo | Estrategia de Mitigación | Estado |
|--------|--------------------------|--------|
| Incompatibilidades entre módulos al integrar las cinco fases del conversor | Ejecución de pruebas unitarias del ciclo anterior durante el desarrollo de la integración | ✅ |
| Degradación del rendimiento al conectar todos los componentes en un solo flujo | Medición de tiempos por fase mediante métricas de conversión; optimización puntual con los resultados obtenidos | ✅ |
| Pérdida de información semántica entre la fase de análisis y la generación de código | Propagación explícita de la tabla de símbolos a través de todas las fases del flujo de conversión | ✅ |
| Discrepancias entre el código generado y la sintaxis esperada por GCC | Validación estructural del código C generado (estructura, llaves, terminadores) en pruebas automatizadas; conversión en GCC como verificación complementaria | ✅ |

**Tabla 103.** Riesgos identificados y mitigados.

---

## Fase 3: Desarrollo y Verificación

### Productos generados

- Flujo de conversión del conversor completamente integrado y funcional, que orquesta las cinco fases secuenciales del conversor.
- Integración entre la interfaz de usuario y el conversor mediante la barra de herramientas flotante con botón de conversión.
- Diálogo de resultados del conversor con seis pestañas: resumen de métricas, unidades léxicas, árbol sintáctico abstracto, análisis semántico, transformaciones de optimización y código C generado con resaltado de sintaxis.
- Sistema de visualización de errores con colores según severidad: rojo oscuro (fatal, detiene la conversión), rojo (error, impide la generación de código), naranja (advertencia, código generado con observaciones) y azul (información adicional).
- Mapeo completo de los seis tipos de símbolos ISO 5807 implementado y verificado con casos de prueba específicos.

---

## Fase 4: Planificación

### Entregables

- Informe del Ciclo 6: documentación de la integración, pruebas y métricas de cobertura.
- Plan detallado para el Ciclo 7: Pruebas y Documentación.

---

---

# 21. Pruebas de Integración

Las pruebas de FlowCode se organizan en dos niveles: pruebas unitarias, que verifican cada fase del conversor fuente a fuente de forma independiente, y pruebas de integración, que validan el flujo completo desde el diagrama hasta el código C. Se empleó el marco de pruebas automatizadas de Flutter. Los resultados de cada prueba se comparan contra resultados esperados predefinidos, verificando tanto la corrección funcional como la estabilidad ante entradas problemáticas. Las pruebas de autenticación y sincronización en la nube (Firebase) se ejecutan de forma separada por requerir configuración de servicios externos [22].

## 21.2 Estrategia de Pruebas

Las pruebas unitarias verifican el comportamiento correcto de cada fase del conversor de forma aislada. Las pruebas de integración verifican que las cinco fases operan de forma coordinada al procesar diagramas de flujo completos conformes al estándar ISO 5807:1985 [19], y establecen trazabilidad con los casos de uso CU01–CU07. La funcionalidad de almacenamiento local (CU08) y la integración con Firebase (CU09, CU10) se verifican mediante pruebas funcionales ejecutadas manualmente sobre el dispositivo físico Samsung Galaxy A26 5G.

### Criterio de validación

Cada prueba automatizada define un resultado esperado concreto y evalúa la salida del componente bajo prueba contra ese resultado. Una prueba se considera aprobada únicamente si se cumple la condición exacta especificada: reconocimiento de unidades léxicas, estructura del árbol sintáctico abstracto, detección de errores por fase o validez estructural del código C producido. Las pruebas negativas documentan entradas inválidas (léxicas/sintácticas/semánticas) y se incluyen para evidenciar que el conversor detecta y reporta fallos de forma controlada. Las pruebas manuales se validan mediante verificación visual del comportamiento esperado en el dispositivo físico con escenarios predefinidos.

| Componente | Tipo | Casos documentados en este reporte | Casos de uso cubiertos | Estado |
|------------|------|-----------------------------------:|------------------------|--------|
| Análisis léxico | Unitaria | 6 | CU04 | ✅ |
| Análisis sintáctico | Unitaria | 6 | CU04 | ✅ |
| Análisis semántico | Unitaria | 6 | CU05 | ✅ |
| Optimización y generación de código | Unitaria | 8 | CU06 | ✅ |
| Integración extremo a extremo | Integración | 33 | CU01–CU07 | ✅ |
| Verificación de estructura del código generado | Automática complementaria | 6 | CU06 | ✅ |
| Almacenamiento local y nube | Manual | 10 | CU03, CU08–CU10 | ✅ |

**Tabla 104.** Resumen de pruebas por componente.

> *[Figura X. Captura de pantalla de la terminal mostrando la ejecución del conjunto automatizado con todos los casos aprobados.]*

La tabla siguiente establece la trazabilidad entre cada caso de uso y los artefactos de prueba que lo validan.

| ID | Caso de Uso | Tipo de prueba | Estado |
|----|-------------|----------------|--------|
| CU01 | Crear Nuevo Diagrama | Automatizada (integración) | ✅ |
| CU02 | Agregar y Conectar Elementos | Automatizada (integración) | ✅ |
| CU03 | Editar Propiedades de Elementos | Manual + unitaria | ✅ |
| CU04 | Validar Estructura del Diagrama | Automatizada (unitaria + integración) | ✅ |
| CU05 | Realizar Análisis Semántico | Automatizada (unitaria + integración) | ✅ |
| CU06 | Generar Código C | Automatizada (unitaria + integración) | ✅ |
| CU07 | Exportar Proyecto Completo | Automatizada (integración) | ✅ |
| CU08 | Organizar Proyectos en Carpetas | Manual (dispositivo físico) | ✅ |
| CU09 | Registrar Cuenta de Usuario | Manual (requiere Firebase) | ✅ |
| CU10 | Sincronizar Proyectos a la Nube | Manual (requiere conexión) | ✅ |

**Tabla 105.** Cobertura de pruebas por caso de uso.

> **Nota sobre CU03, CU08, CU09 y CU10:** Estos casos de uso dependen de la capa de presentación de la aplicación o de servicios externos (Firebase, almacenamiento local), por lo que no son susceptibles de prueba con el marco automatizado de Flutter sin configuración adicional de entorno. Se verificaron manualmente con escenarios predefinidos sobre el dispositivo físico.

---

## 21.3 Pruebas Unitarias

Las pruebas unitarias validan el comportamiento de cada fase del conversor de forma independiente. En este reporte se incluyen casos representativos (no exhaustivos) seleccionados del conjunto automatizado: entradas válidas, entradas inválidas que deben producir errores controlados y ejemplos clave del alcance soportado (p. ej., entrada/salida, arreglos e indicios de soporte para apuntadores).

### 21.3.1 Analizador Léxico

El analizador léxico identifica unidades léxicas a partir del contenido textual de cada nodo del diagrama. Se verificó el reconocimiento de literales, operadores, palabras reservadas del lenguaje C, palabras clave en español («Escribir», «Leer») y la inferencia de formatos para entrada/salida [1].

**Criterio de validación:** La salida debe clasificar correctamente las unidades léxicas esperadas. En casos de error, el resultado debe reportar el incidente de forma controlada sin bloquear el flujo de conversión.

| ID | Descripción | Entrada | Resultado Esperado | Estado |
|----|-------------|---------|-------------------|--------|
| LEX-T01 | Reconocimiento de literal entero | Literal entero | Se identifica como literal numérico entero y se marca el fin de entrada | ✅ |
| LEX-T02 | Declaración con inicialización | Declaración de entero con inicialización | Se reconocen palabra reservada, identificador, asignación y literal | ✅ |
| LEX-T03 | Instrucción de lectura en español | Palabra clave de lectura | Se identifica como instrucción de entrada | ✅ |
| LEX-T04 | Operador módulo con espacios | Asignación con operador módulo | Se reconoce el operador módulo sin confundirse con formatos de entrada/salida | ✅ |
| LEX-T05 | Carácter no permitido | Carácter fuera del alfabeto soportado | Se reporta el incidente y el análisis continúa de forma controlada | ✅ |
| LEX-T06 | Cadena sin cierre | Texto con cadena sin cierre | Se reporta el error léxico y el análisis continúa de forma controlada | ✅ |

**Tabla 106.** Pruebas — Analizador léxico.

### 21.3.2 Analizador Sintáctico

El analizador sintáctico construye el árbol de sintaxis abstracta a partir de las unidades léxicas producidas por el analizador léxico, mediante el método de descenso recursivo [1], [3].

**Criterio de validación:** En entradas válidas, el árbol sintáctico debe reflejar la estructura esperada (asignación, expresión, acceso a arreglo, etc.). En entradas inválidas, el resultado debe reportar un error sintáctico con mensaje descriptivo.

| ID | Descripción | Entrada | Resultado Esperado | Estado |
|----|-------------|---------|-------------------|--------|
| SYN-T01 | Construcción de asignación | Asignación simple | El árbol sintáctico contiene una asignación entre identificador y valor | ✅ |
| SYN-T02 | Precedencia en expresión mixta | Suma y multiplicación en una expresión | La multiplicación se agrupa antes que la suma | ✅ |
| SYN-T03 | Acceso a arreglo | Acceso a elemento de arreglo por índice | El árbol sintáctico representa el acceso por índice | ✅ |
| SYN-T04 | Inicializador de arreglo | Lista de valores entre llaves | Se construye un inicializador de arreglo con varios elementos | ✅ |
| SYN-T05 | Paréntesis no balanceados | Expresión con paréntesis sin cierre | Se reporta un error sintáctico indicando el paréntesis pendiente | ✅ |
| SYN-T06 | Declaración de apuntador | Declaración de apuntador a entero | Se registra la declaración indicando que la variable es un apuntador | ✅ |

**Tabla 107.** Pruebas — Analizador sintáctico.

### 21.3.3 Analizador Semántico

El analizador semántico verifica la consistencia de variables y tipos de datos a lo largo del diagrama. Construye y consulta la tabla de símbolos para detectar variables no declaradas, declaraciones duplicadas, incompatibilidades de tipo y operaciones aritméticas inválidas [1], [3].

**Criterio de validación:** En entradas válidas, el análisis semántico no debe reportar errores que impidan generar código. En entradas inválidas, el resultado debe reportar el error indicando el símbolo y la causa.

| ID | Descripción | Entrada | Resultado Esperado | Estado |
|----|-------------|---------|-------------------|--------|
| SEM-T01 | Variable declarada y usada correctamente | Declaración y uso posterior | Sin errores semánticos; el símbolo queda registrado en tabla de símbolos | ✅ |
| SEM-T02 | Uso de variable no declarada | Uso de identificador sin declaración previa | Se reporta error indicando variable no declarada | ✅ |
| SEM-T03 | Declaración duplicada | Dos declaraciones del mismo identificador | Se reporta error por duplicidad de declaración | ✅ |
| SEM-T04 | Asignación con tipos incompatibles | Asignación con tipos no compatibles | Se reporta advertencia o error de incompatibilidad de tipos | ✅ |
| SEM-T05 | División por cero literal | Expresión con división entre cero literal | Se reporta error de operación inválida | ✅ |
| SEM-T06 | Parámetros de función como apuntadores | Función con parámetros por referencia (apuntadores) | Se registran parámetros correctamente sin confundir operadores con nombres | ✅ |

**Tabla 108.** Pruebas — Analizador semántico.

### 21.3.4 Optimizador y Generador de Código

El optimizador aplica cuatro técnicas sobre el árbol de sintaxis abstracta: plegado de constantes, eliminación de código inalcanzable, simplificación algebraica y propagación de variables. El generador de código recorre el árbol optimizado y produce el código C correspondiente a cada tipo de construcción. La generación de estructuras de control (ciclos y selección múltiple) se configura mediante metadatos del nodo del diagrama y se valida con pruebas automatizadas específicas [1], [3].

**Criterio de validación para el optimizador:** Cuando una expresión es evaluable en tiempo de conversión, se reemplaza por el valor constante equivalente. En casos no válidos (p. ej., división entre cero), no se realizan sustituciones que introduzcan resultados incorrectos.

**Criterio de validación para el generador:** El texto C generado debe reflejar la estructura esperada (programa completo, declaraciones, selección múltiple y ciclos) y mantenerse estable ante configuraciones incompletas.

| ID | Descripción | Entrada | Resultado Esperado | Estado |
|----|-------------|---------|-------------------|--------|
| OPT-T01 | Plegado de constantes — suma | Suma de constantes | La expresión se sustituye por el valor constante correcto | ✅ |
| OPT-T02 | Evitar sustitución inválida | División entre cero literal | No se reemplaza por una constante inválida; se reporta el incidente | ✅ |
| OPT-T03 | Eliminación de código inalcanzable | Bloque con retorno y sentencias posteriores | Se eliminan las sentencias posteriores al retorno | ✅ |
| GEN-T01 | Generación de programa base | Diagrama lineal (inicio → proceso → fin) | Se produce un programa C completo con función principal y cierre correcto | ✅ |
| GEN-T02 | Formato de salida según tipo | Salida de valor flotante | Se emplea el formato de salida correspondiente al tipo | ✅ |
| GEN-T03 | Declaración múltiple | Declaración de varias variables en una sola sentencia | Se genera una declaración múltiple válida en C | ✅ |
| GEN-T04 | Selección múltiple con metadatos | Selección múltiple con casos configurados | Se genera una selección múltiple con casos y cortes correspondientes | ✅ |
| GEN-T05 | Arreglos y ciclos con retroceso | Plantilla de ordenamiento (arreglo fijo y ciclos) | Se genera código de forma estable ante conexiones de retroceso | ✅ |

**Tabla 109.** Pruebas — Optimizador y generador de código.

> **Nota sobre GEN-T05:** La representación de ciclos en el diagrama utiliza conexiones de retroceso para indicar saltos de control, y la prueba verifica que la generación se mantiene estable ante este patrón.

---

## 21.4 Pruebas de Integración

Las pruebas de integración validan el flujo completo del conversor fuente a fuente: desde la estructura del diagrama hasta el código C generado. Se emplean casos de extremo a extremo que ejecutan todas las fases de forma coordinada y validan el resultado contra criterios definidos.

**Criterio de validación general:** En entradas válidas, la conversión concluye correctamente y produce código C. En entradas inválidas, se detecta el problema, se informa y el flujo se mantiene estable.

### 21.4.1 CU01 — Crear Nuevo Diagrama

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU01-T01 | E2E-01.1 | Diagrama mínimo (Inicio → Fin) | La conversión concluye sin errores y se obtiene un programa C completo | ✅ |
| CU01-T02 | E2E-01.2 | Ejecución coordinada de fases | Se generan resultados por fase y métricas de ejecución sin valores negativos | ✅ |
| CU01-T03 | ISO-01.1 | Nodos terminales (Inicio/Fin) | Se genera una estructura base coherente del programa | ✅ |
| CU01-T04 | ISO-01.2 | Variantes en español e inglés | Se aceptan variantes de etiquetas y la conversión concluye correctamente | ✅ |

**Tabla 110.** Pruebas de CU01 — Crear Nuevo Diagrama.

### 21.4.2 CU02 — Agregar y Conectar Elementos

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU02-T01 | ISO-02.1 | Proceso: declaración de variable | La declaración se refleja en el código generado | ✅ |
| CU02-T02 | ISO-02.2 | Proceso: asignación | La asignación se refleja en el código generado | ✅ |
| CU02-T03 | ISO-02.3 | Proceso: declaración múltiple | Se genera una declaración múltiple válida | ✅ |
| CU02-T04 | ISO-02.4 | Secuencia de procesos | El flujo procesa nodos consecutivos sin fallar | ✅ |
| CU02-T05 | ISO-03.1 | Entrada/salida: salida estándar | Se genera una instrucción de salida estándar | ✅ |
| CU02-T06 | ISO-03.2 | Entrada/salida: entrada estándar | Se genera una instrucción de entrada estándar | ✅ |
| CU02-T07 | ISO-03.3 | Entrada/salida: formato según tipo | El formato de entrada/salida corresponde al tipo de dato | ✅ |
| CU02-T08 | ISO-04.1 | Decisión simple | Se genera una estructura condicional de una rama | ✅ |
| CU02-T09 | ISO-04.2 | Decisión de dos ramas | Se genera una estructura condicional con alternativa | ✅ |
| CU02-T10 | ISO-04.3 | Operadores lógicos en condiciones | Se procesan condiciones con operadores lógicos sin afectar la conversión | ✅ |
| CU02-T11 | ISO-05.1 | Preparación: inicialización | El símbolo se procesa y el flujo continúa sin fallar | ✅ |
| CU02-T12 | ISO-05.2 | Representación de ciclo | Las conexiones de retroceso se interpretan como ciclo y la conversión concluye correctamente | ✅ |
| CU02-T13 | ISO-06.1 | Subproceso | El símbolo de subproceso se procesa sin fallar | ✅ |
| CU02-T14 | ISO-07.1 | Diagrama sin comentarios | Un diagrama sin anotaciones convierte correctamente | ✅ |
| CU02-T15 | ISO-08.1 | Diagrama sin conectores | Un diagrama simple sin conectores convierte correctamente | ✅ |

**Tabla 111.** Pruebas de CU02 — Agregar y Conectar Elementos.

> **Nota:** En varios casos el objetivo principal es validar estabilidad del flujo completo y el procesamiento del símbolo (ejecución de fases y generación de fragmentos clave), más que comprobar exhaustivamente cada posible variante de plantilla.

### 21.4.3 CU04 — Validar Estructura del Diagrama

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU04-T01 | ERR-01.1 | Detección de error léxico | Se detecta y se reporta el problema de forma controlada | ✅ |
| CU04-T02 | ERR-01.2 | Detección de error sintáctico | Se detecta y se reporta el problema de forma controlada | ✅ |
| CU04-T03 | ERR-01.3 | Advertencias semánticas (variable no usada) | Se reportan advertencias cuando están habilitadas | ✅ |
| CU04-T04 | ERR-02.1 | Recuperación ante error no fatal | El flujo continúa y entrega un resultado estable | ✅ |

**Tabla 112.** Pruebas de CU04 — Validar Estructura del Diagrama.

### 21.4.4 CU05 — Realizar Análisis Semántico

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU05-T01 | E2E-01.3 | Propagación de información semántica | La información de símbolos y tipos se mantiene disponible a través de las fases | ✅ |
| CU05-T02 | GEN-02.2 (sin variables indefinidas) | Variables usadas con declaración previa | No se reportan variables usadas sin declaración previa en diagramas simples | ✅ |

**Tabla 113.** Pruebas de CU05 — Realizar Análisis Semántico.

### 21.4.5 CU06 — Generar Código C

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU06-T01 | GEN-01.1 | Estructura general del programa | Se genera un programa C con estructura coherente | ✅ |
| CU06-T02 | GEN-01.2 | Balance de llaves | El código generado mantiene balance entre aperturas y cierres | ✅ |
| CU06-T03 | GEN-01.3 | Terminación de sentencias | Las sentencias quedan correctamente terminadas | ✅ |
| CU06-T04 | GEN-02.1 | Comprobación de forma básica | Se cumplen comprobaciones automáticas de forma y estructura | ✅ |
| CU06-T05 | GEN-02.2 (entrada/salida) | Diagrama con entrada/salida | Se genera código válido para un flujo de entrada/salida | ✅ |
| CU06-T06 | E2E-01.4 | Efecto de la optimización | El resultado cambia cuando se habilita la optimización | ✅ |

**Tabla 114.** Pruebas de CU06 — Generar Código C.

> *[Figura X. Captura de pantalla del diálogo de resultados del conversor mostrando el código C generado con resaltado de sintaxis en la pestaña «Código».]*

### 21.4.6 CU07 — Exportar Proyecto Completo

| ID | Referencia en pruebas automatizadas | Descripción | Resultado Esperado | Estado |
|----|-------------------------------------|-------------|-------------------|--------|
| CU07-T01 | MET-01.1 | Recolección de métricas de conversión | Se registran métricas (nodos, unidades léxicas y tiempos) con valores no negativos | ✅ |
| CU07-T02 | MET-01.2 | Generación del reporte de conversión | Se produce un reporte no vacío con sección de métricas | ✅ |

**Tabla 115.** Pruebas de CU07 — Exportar Proyecto Completo.

---

## 21.5 Pruebas Funcionales Manuales

Las siguientes funciones se verificaron manualmente sobre el dispositivo físico Samsung Galaxy A26 5G con escenarios predefinidos.

**Criterio de validación:** Cada escenario se ejecutó al menos una vez con una entrada válida y una vez con una entrada inválida o caso borde. El resultado se registra como aprobado si la aplicación responde de acuerdo al comportamiento especificado en el caso de uso correspondiente.

### 21.5.1 CU03 — Editar Propiedades de Elementos

| ID | Descripción | Resultado Esperado | Estado |
|----|-------------|-------------------|--------|
| CU03-T01 | Edición de nodo de proceso con expresión válida (declaración e inicialización) | Propiedad guardada; sin indicadores de error | ✅ |
| CU03-T02 | Edición de nodo de decisión con expresión inválida | Diálogo permanece abierto con indicador visual de error | ✅ |
| CU03-T03 | Cancelación de edición sin guardar cambios | Propiedades originales del nodo se restauran | ✅ |

**Tabla 116.** Pruebas de CU03 — Editar Propiedades de Elementos.

### 21.5.2 CU08 — Organizar Proyectos en Carpetas

| ID | Descripción | Resultado Esperado | Estado |
|----|-------------|-------------------|--------|
| CU08-T01 | Creación de carpeta y asignación de proyecto | La estructura persiste en el almacenamiento local tras cerrar la aplicación | ✅ |
| CU08-T02 | Traslado de proyecto entre carpetas | Las referencias se actualizan correctamente en el almacenamiento local | ✅ |
| CU08-T03 | Recuperación de la jerarquía tras reinicio | La estructura se recupera correctamente del almacenamiento local | ✅ |

**Tabla 117.** Pruebas de CU08 — Organizar Proyectos en Carpetas.

### 21.5.3 CU09 — Registrar Cuenta de Usuario

| ID | Descripción | Resultado Esperado | Estado |
|----|-------------|-------------------|--------|
| CU09-T01 | Registro con correo electrónico nuevo | Usuario creado en Firebase; correo electrónico coincide | ✅ |
| CU09-T02 | Intento de registro con correo duplicado | El intento se rechaza de forma controlada; mensaje informativo mostrado | ✅ |

**Tabla 118.** Pruebas de CU09 — Registrar Cuenta de Usuario.

### 21.5.4 CU10 — Sincronizar Proyectos a la Nube

| ID | Descripción | Resultado Esperado | Estado |
|----|-------------|-------------------|--------|
| CU10-T01 | Sincronización de proyecto local a Firestore con conexión activa | Proyecto disponible en la consola de Firebase | ✅ |
| CU10-T02 | Intento de sincronización sin conexión a internet | Mensaje informativo mostrado; proyecto encolado para sincronización posterior | ✅ |

**Tabla 119.** Pruebas de CU10 — Sincronizar Proyectos a la Nube.

> *[Figura X. Captura de pantalla de la pantalla principal de la aplicación ejecutándose en el Samsung Galaxy A26 5G.]*

---

## 21.6 Verificación del Código Generado

La corrección estructural del código C producido se verificó mediante comprobaciones automáticas sobre el texto generado. Se confirma que el código generado dentro del alcance cumple requisitos estructurales mínimos de un programa C válido según el estándar ISO/IEC 9899:2018 [8].

| Verificación | Descripción | Estado |
|--------------|-------------|--------|
| Inclusiones requeridas | Se incluyen las cabeceras necesarias para entrada/salida estándar | ✅ |
| Función principal | Se genera la función principal del programa | ✅ |
| Cierre del programa | La función principal finaliza con una salida controlada | ✅ |
| Llaves balanceadas | Las llaves de apertura y cierre son iguales en número | ✅ |
| Terminación de sentencias | Las sentencias quedan correctamente terminadas | ✅ |
| Comprobación estructural | Se aplican comprobaciones automáticas de forma y estructura del programa | ✅ |

**Tabla 120.** Verificación de la estructura del código C generado.

> *[Figura X. Ejemplo de código C generado por FlowCode a partir de la plantilla «05. Par o Impar».]*

---

## 21.7 Resumen de Cobertura

### Por tipo de prueba (casos documentados en este reporte)

Los totales se obtienen contando los casos enumerados en las tablas de este documento (Secciones 21.3–21.6). Este conteo corresponde únicamente a los casos documentados aquí.

| Tipo | Total (casos) |
|------|--------------:|
| Unitarias automatizadas (casos representativos) | 26 |
| Integración extremo a extremo | 33 |
| Verificación del código generado | 6 |
| Manuales | 10 |
| **Total** | **75** |

### Por concepto del temario ISC-2020

En esta tabla, ✅ indica evidencia en pruebas automatizadas documentadas en este reporte; — indica que no se documentó evidencia en dichos casos (no implica soporte o no soporte funcional).

| Concepto | Cobertura en pruebas | Evidencia (ejemplos) |
|----------|----------------------|----------------------|
| Tipos primitivos (entero, flotante, carácter) | ✅ | LEX-T01, GEN-T02, CU02-T07 |
| Operadores aritméticos y relacionales | ✅ | LEX-T02, SYN-T02 |
| Entrada/salida estándar | ✅ | CU02-T05, CU02-T06, GEN-T02 |
| Estructura condicional (si / si-no) | ✅ | CU02-T08, CU02-T09 |
| Ciclos (para / mientras) | ✅ | CU02-T12, GEN-T05 |
| Selección múltiple | ✅ | GEN-T04 |
| Subproceso (proceso predefinido) | ✅ | CU02-T13 |
| Arreglos unidimensionales | ✅ | SYN-T03, SYN-T04, GEN-T05 |
| Apuntadores (declaración y parámetros) | ✅ | SYN-T06, SEM-T06 |
| Estructuras definidas por el usuario | — | — |
| Memoria dinámica (reserva/liberación) | — | — |
| Operaciones con archivos (lectura/escritura) | — | — |
| Recursión | — | — |

**Tabla 121.** Resumen de cobertura por concepto del temario ISC-2020.
