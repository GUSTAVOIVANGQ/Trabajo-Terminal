# CICLO 4: MOTOR DE ANÁLISIS

## Fase 1: Determinación de Objetivos

### Objetivos del Ciclo 4

- Diseñar e implementar el canal de conversión (*pipeline*) con fases secuenciales y un orquestador central.
- Desarrollar el análisis léxico: tokenización del contenido textual de cada nodo del diagrama, reconociendo identificadores, literales, palabras reservadas y operadores.
- Implementar el análisis sintáctico mediante un analizador de descenso recursivo que construya el Árbol de Sintaxis Abstracta (AST).
- Implementar el análisis semántico con verificación de tipos, detección de variables no declaradas y validaciones de uso (inicialización y variables no utilizadas).
- Construir la tabla de símbolos con atributos de nombre, tipo, categoría, estado e inicialización.
- Establecer el sistema de clasificación de errores por fase (léxica, sintáctica y semántica) y por nivel de severidad.

---

## Fase 2: Análisis de Riesgos

**Tabla 95. Riesgos identificados y mitigados**

| Riesgo | Estrategia de mitigación |
|---|---|
| Complejidad del análisis semántico | Implementación incremental, comenzando con validaciones básicas antes de la implementación completa |
| Falsos positivos en la detección de errores | Pruebas exhaustivas con casos límite positivos y negativos por cada regla |
| Integración con el editor visual | Definición de interfaces claras entre módulos desde el inicio del ciclo |

---

## Fase 3: Desarrollo y Verificación

### Productos generados

- Analizador léxico funcional con sistema de *tokens*.
- Analizador sintáctico con descenso recursivo y generación del AST.
- Analizador semántico con verificación de tipos y validaciones de uso (declaración, inicialización y variables no utilizadas).
- Tabla de símbolos con soporte para ámbitos y resolución de nombres.
- Sistema de errores estructurado con clasificación por tipo, severidad y fase de conversión.

---

## Fase 4: Planificación

### Entregables

- Informe del Ciclo 4: documentación de la arquitectura del conversor y decisiones de diseño.
- Plan detallado para el Ciclo 5: Generador de Código.

---

# 16. Implementación del Analizador

El motor de análisis constituye la fase central del conversor de FlowCode. Corresponde al *front-end* del canal de conversión descrito en la arquitectura del sistema (véase sección 5) e implementa tres fases secuenciales: análisis léxico, análisis sintáctico y análisis semántico [1]. Cada fase produce una representación intermedia que alimenta a la siguiente, culminando en el Árbol de Sintaxis Abstracta (AST) anotado con información semántica.

## 16.1 Análisis Léxico

La primera fase del conversor extrae los *tokens* del contenido textual de cada nodo del diagrama. A diferencia de un analizador léxico convencional que procesa un flujo continuo de caracteres, este analizador trabaja con fragmentos discretos de texto asociados a cada nodo, ya que la estructura del diagrama —su topología como grafo dirigido— se procesa en una fase anterior (validación estructural, sección 14.4.5).

El proceso de tokenización recorre el texto carácter por carácter, identificando patrones que corresponden a *tokens* válidos y registrando la posición exacta (línea y columna) de cada uno para el reporte preciso de errores. Durante esta fase se construye también la versión inicial de la tabla de símbolos: cuando se detecta una declaración de variable, se registra su nombre y tipo inferido. Esta información se refina y valida en las fases posteriores.

### 16.1.1 Sistema de *tokens*

El sistema reconoce 91 tipos de *tokens* (enumerado `TokenType`), organizados en las siguientes categorías:

- **Identificadores y literales:** nombres de variables, constantes numéricas enteras y de punto flotante, cadenas de texto, caracteres individuales y valores booleanos.
- **Palabras reservadas de C:** `int`, `float`, `double`, `char`, `bool`, `void`, `const`, `if`, `else`, `while`, `for`, `do`, `switch`, `case`, `default`, `break`, `continue`, `return`, `printf` y `scanf`.
- **Palabras reservadas en español:** el analizador reconoce equivalentes como `entero`, `real`, `caracter`, `cadena`, `booleano`, `si`, `sino`, `mientras`, `para`, `hacer`, `hasta`, `retornar`, `leer`, `mostrar`, `escribir`, `imprimir` e `ingresar`. Estas palabras se interpretan como equivalentes semánticos durante el análisis (por ejemplo, `entero` → `int`), de modo que el contenido textual del diagrama puede escribirse en español manteniendo consistencia en el AST y en las validaciones.
- **Operadores:** aritméticos (`+`, `-`, `*`, `/`, `%`), relacionales (`==`, `!=`, `<`, `>`, `<=`, `>=`), lógicos (`&&`, `||`, `!`), bit a bit (`&`, `|`, `^`, `~`, `<<`, `>>`), de asignación (`=`, `+=`, `-=`, `*=`, `/=`, `%=`) e incremento/decremento (`++`, `--`). También se incluyen los símbolos del operador ternario (`?`, `:`).
- **Delimitadores:** paréntesis, llaves, corchetes, punto y coma, coma, dos puntos, punto (`.`) y flecha (`->`).
- **Tokens especiales:** especificadores de formato (por ejemplo, `%d`, `%f`), fin de entrada (`endOfInput`) y *token* desconocido (`unknown`). Los espacios en blanco y comentarios se omiten del conjunto de tokens significativos.

### 16.1.2 Tokenización del contenido de nodos

El algoritmo de tokenización examina el carácter actual y aplica las siguientes reglas, en orden:

1. **Espacios en blanco:** se registran y se descarta su posición; sirven como separadores entre *tokens*.
2. **Dígitos:** inician el reconocimiento de un literal numérico. Si se encuentra un punto decimal durante el recorrido, el *token* se clasifica como número de punto flotante.
3. **Letras o guión bajo:** inician el reconocimiento de un identificador. Al completar la lectura de caracteres alfanuméricos, se verifica si la cadena coincide con alguna palabra reservada.
4. **Comillas:** inician un literal de cadena (comillas dobles) o de carácter (comilla simple).
5. **Pares de operadores:** se verifica si el carácter actual y el siguiente forman un operador de dos caracteres (por ejemplo, `==`, `!=`, `<=`, `>=`, `&&`, `||`, `++`, `--`, `+=`, `<<`, `->`).
6. **Caracteres especiales:** se mapean directamente a su tipo de *token* correspondiente.

El resultado de esta fase es un objeto que contiene los *tokens* de cada nodo, la tabla de símbolos parcialmente construida y cualquier error léxico detectado, como cadenas sin cerrar o caracteres no reconocidos.

---

## 16.2 Análisis Sintáctico

La segunda fase verifica que la secuencia de *tokens* de cada nodo forme construcciones sintácticamente válidas y construye el Árbol de Sintaxis Abstracta (AST) [1][3].

### 16.2.1 Adaptación al tipo de nodo

El análisis se adapta al tipo de nodo del diagrama que se está procesando. Un nodo de tipo *proceso* espera declaraciones de variables o expresiones de asignación; un nodo de tipo *datos* espera operaciones de entrada (`scanf`) o salida (`printf`); un nodo de tipo *decisión* espera una expresión booleana o de comparación. Esta diferenciación permite aplicar las reglas gramaticales apropiadas para cada contexto.

Ante errores sintácticos, el analizador aplica recuperación por sincronización: avanza en la secuencia de *tokens* hasta encontrar un punto seguro (como un punto y coma o el final del contenido del nodo) y continúa el análisis, permitiendo reportar múltiples errores en una sola pasada.

### 16.2.2 Analizador de descenso recursivo

Se implementó la técnica de descenso recursivo predictivo, en la que cada categoría gramatical se representa como una función que puede invocar a otras funciones según las reglas de la gramática [1]. La precedencia de operadores se establece mediante una jerarquía de funciones, donde las de menor precedencia invocan a las de mayor:

```
Expresión     → Asignación
Asignación    → OrLógico ('=' Asignación)?
OrLógico      → YLógico ('||' YLógico)*
YLógico       → Igualdad ('&&' Igualdad)*
Igualdad      → Comparación (('=='|'!=') Comparación)*
Comparación   → Término (('<'|'>'|'<='|'>=') Término)*
Término       → Factor (('+'|'-') Factor)*
Factor        → Unario (('*'|'/'|'%') Unario)*
Unario        → ('!'|'-'|'+')? Primario
Primario      → Literal | Identificador | '(' Expresión ')' | LlamadaFunción
```

Esta estructura garantiza que los operadores con mayor precedencia (como la multiplicación) se evalúen antes que los de menor precedencia (como la suma), y que las expresiones entre paréntesis se evalúen primero.

Para fines de reporte se presenta una gramática simplificada; la implementación incluye operadores adicionales (bit a bit, desplazamientos, ternario), acceso a arreglos y llamadas a función.

### 16.2.3 Árbol de Sintaxis Abstracta (AST)

El resultado principal del análisis sintáctico es el AST, una representación jerárquica del programa que captura su estructura sin los detalles sintácticos superficiales, como paréntesis redundantes o estilo de formato [1]. El nodo raíz contiene la lista de nodos del diagrama con sus sentencias analizadas y las declaraciones de variables globales que se extraen para ubicarse al inicio de la función `main()`.

Cada tipo de sentencia tiene su clase de nodo AST correspondiente: declaraciones de variables, expresiones de asignación, estructuras condicionales (`if`/`else`), bucles (`while`, `for`), y operaciones de entrada y salida.

**Figura 59. Ejemplo de AST generado (plantilla “05. Par o Impar”).**

```text
Program
	GlobalDeclarations:
		Declaration(int numero)

	Nodes:
		DiagramNode(comment, id=comment_1774838164830_0)
		DiagramNode(terminal, id=start_1774838164830_1)
		DiagramNode(process, id=process_1774838164830_2)
			Declaration(int numero)
		DiagramNode(data, id=input_1774838164830_3)
			InputStmt(numero)
		DiagramNode(decision, id=decision_1774838164830_4)
			ExpressionStmt
				BinaryExpr(==)
					BinaryExpr(%)
						Identifier(numero)
						IntegerLiteral(2)
					IntegerLiteral(0)
		DiagramNode(data, id=output_1774838164830_5)
			OutputStmt
				StringLiteral("El número es par")
		DiagramNode(data, id=output_1774838164830_6)
			OutputStmt
				StringLiteral("El número es impar")
		DiagramNode(terminal, id=end_1774838164830_7)
```

Nota: los identificadores de nodos incluyen un sufijo basado en tiempo, por lo que cambian entre ejecuciones.

El AST resultante sirve como representación intermedia que utilizan las fases posteriores para el análisis semántico, la optimización y la generación de código.

---

## 16.3 Análisis Semántico

La tercera fase verifica que el programa tenga coherencia semántica más allá de su corrección sintáctica [1][3]. El analizador semántico trabaja sobre la tabla de símbolos construida en la fase léxica y, cuando está disponible, sobre el AST generado en la fase sintáctica.

En la implementación actual, el análisis se organiza en dos pasadas: (1) recolección de declaraciones (variables y parámetros) y (2) validaciones por nodo (uso de identificadores, inicialización, compatibilidad de tipos, operaciones inválidas y división por cero). El parámetro `connections` se mantiene por consistencia con el *pipeline*, pero el recorrido semántico no depende aún de la topología del grafo.

### 16.3.1 Verificación de tipos

El sistema de tipos de FlowCode reconoce los tipos primitivos del lenguaje C. En expresiones aritméticas se verifica que los operandos sean numéricos; en expresiones de comparación, la compatibilidad entre los tipos comparados; en asignaciones, que el tipo del valor asignado sea compatible con el tipo de la variable destino.

Se implementa conversión implícita en casos seguros (por ejemplo, asignar un `int` a un `float`), pero se genera una advertencia cuando existe pérdida potencial de precisión (por ejemplo, asignar un `float` a un `int`).

### 16.3.2 Análisis de alcance

La tabla de símbolos incluye una estructura de ámbitos (`Scope`) y el analizador semántico define un contenedor de resultados de alcance (nivel por nodo y conjunto de variables accesibles). Sin embargo, en la versión actual estos datos no se calculan automáticamente a partir del diagrama: las declaraciones se registran en el ámbito global y las búsquedas se realizan sobre ese conjunto.

Como consecuencia, las validaciones semánticas priorizan existencia del identificador, estado de inicialización/uso y compatibilidad de tipos. El diagnóstico de “fuera de alcance” (`3010`) se mantiene definido en el catálogo para cuando se habilite la asignación de ámbitos por bloque.

### 16.3.3 Detección de variables no declaradas e inutilizadas

Cuando se encuentra un identificador en una expresión, el analizador busca su entrada en la tabla de símbolos. Si la variable no se encuentra, se genera un error semántico que indica el nombre de la variable y su ubicación en el diagrama.

El analizador también detecta variables que se usan antes de ser inicializadas: aunque la variable esté declarada, si no se le ha asignado un valor antes de leerla, se genera una advertencia que indica que el valor de la variable es indeterminado.

Adicionalmente, al finalizar el recorrido se revisa la tabla de símbolos para emitir advertencias de variables declaradas pero no utilizadas.

El resultado de esta fase es un objeto que incluye la tabla de símbolos actualizada, el entorno de tipos, el contenedor de resultados de alcance (no inferido automáticamente en esta versión) y las listas de errores y advertencias semánticas.

---

# 17. Tabla de Símbolos

La tabla de símbolos constituye la estructura de datos central del conversor, encargada de almacenar y gestionar toda la información relacionada con los identificadores declarados durante la conversión [1]. Esta estructura actúa como el repositorio de metadatos sobre variables y constantes, permitiendo al analizador semántico realizar verificaciones de tipo, detectar variables no declaradas y apoyar la gestión de ámbitos de los identificadores.

## 17.1 Estructura de la tabla de símbolos

El diseño sigue un enfoque orientado a objetos con tres clases principales que trabajan en conjunto: la clase que representa la unidad de información de un símbolo individual, la clase que representa un ámbito de alcance, y la clase que gestiona el conjunto completo de símbolos y alcances.

### 17.1.1 Atributos de un símbolo

Cada símbolo en la tabla encapsula los metadatos necesarios sobre un identificador declarado. Los atributos principales son: el nombre del identificador, su tipo de dato, la categoría del símbolo (variable, constante o parámetro), y la información de ubicación (nodo del diagrama, línea y columna dentro del contenido textual del nodo). Adicionalmente, se mantienen dos banderas de estado: `isInitialized`, que indica si la variable ha recibido un valor, e `isUsed`, que indica si fue referenciada al menos una vez tras su declaración. Estas banderas habilitan la detección de las advertencias de variable no inicializada y variable declarada pero no utilizada.

La categoría del símbolo distingue entre variables regulares, constantes y parámetros de función. Esta clasificación permite aplicar reglas semánticas específicas, como prohibir la asignación a constantes.

**Figura 60. Diagrama de clases de la tabla de símbolos (implementación).**

Implementación: `lib/compiler/symbol_table.dart`.

**Clase `SymbolInfo` (símbolo).**

| Atributo | Tipo | Descripción |
| --- | --- | --- |
| `name` | `String` | Identificador del símbolo. |
| `dataType` | `DataType` | Tipo del símbolo (con representación equivalente en C). |
| `category` | `SymbolCategory` | Categoría (variable, constante, parámetro, etc.). |
| `scopeLevel` | `int` | Nivel del ámbito donde se declaró (0 = global). |
| `scopeId` | `int` | Identificador del ámbito donde se declaró. |
| `declaringNodeId` | `String?` | ID del nodo del diagrama donde se declaró. |
| `declarationLine` | `int` | Línea (base 1) dentro del texto del nodo. |
| `declarationColumn` | `int` | Columna (base 1) dentro del texto del nodo. |
| `isInitialized` | `bool` | Marca si el símbolo recibió un valor antes de usarse. |
| `isUsed` | `bool` | Marca si el símbolo fue referenciado al menos una vez. |
| `initialValue` | `dynamic` | Valor inicial (si existe). |
| `arrayDimensions` | `List<int>?` | Dimensiones del arreglo (si aplica). |
| `parameterTypes` | `List<DataType>?` | Tipos de parámetros (si el símbolo representa una función). |
| `returnType` | `DataType?` | Tipo de retorno (si el símbolo representa una función). |
| `metadata` | `Map<String, dynamic>` | Metadatos adicionales (extensible). |

**Clase `Scope` (ámbito).**

| Atributo | Tipo | Descripción |
| --- | --- | --- |
| `id` | `int` | Identificador único del ámbito. |
| `level` | `int` | Profundidad del ámbito (0 = global). |
| `parent` | `Scope?` | Ámbito padre (nulo para el ámbito global). |
| `symbols` | `Map<String, SymbolInfo>` | Tabla local: nombre → símbolo declarado en el ámbito. |
| `children` | `List<Scope>` | Lista de ámbitos hijos. |
| `nodeId` | `String?` | ID del nodo donde se creó el ámbito. |
| `description` | `String` | Descripción del ámbito (p. ej., `if-then`, `while-body`). |

**Clase `SymbolTable` (gestor).**

| Atributo interno | Tipo | Descripción |
| --- | --- | --- |
| `_scopes` | `List<Scope>` | Registro de todos los ámbitos creados. |
| `_currentScope` | `Scope?` | Ámbito activo durante el análisis. |
| `_scopeIdCounter` | `int` | Contador para IDs únicos de ámbitos. |
| `_globalSymbols` | `Map<String, SymbolInfo>` | Acceso directo a símbolos declarados en nivel global. |
| `_allSymbols` | `List<SymbolInfo>` | Lista total de símbolos declarados (iteración y reportes). |
| `_errors` | `List<String>` | Errores generados por operaciones de la tabla de símbolos. |
| `_warnings` | `List<String>` | Advertencias generadas por operaciones de la tabla de símbolos. |

Relaciones principales:

| Relación | Multiplicidad | Implementación |
| --- | --- | --- |
| `SymbolTable` → `Scope` | 1 a N | `_scopes: List<Scope>` y `_currentScope: Scope?`. |
| `Scope` → `Scope` (jerarquía) | 0..1 (padre), 0..N (hijos) | `parent: Scope?` y `children: List<Scope>`. |
| `Scope` → `SymbolInfo` | 0..N | `symbols: Map<String, SymbolInfo>`. |
| `SymbolInfo` → `Scope` (referencia por ID) | 1 | `scopeLevel` y `scopeId`. |

Nota: el enumerado `DataType` incluye valores internos adicionales (p. ej., `void_`, `array`, `pointer`, `function_`, `unknown`) para cubrir casos del análisis; la Tabla 95a detalla el subconjunto de tipos primitivos con mapeo directo a C.

### 17.1.2 Tipos de datos soportados

El sistema de tipos define las categorías de tipos primitivos compatibles con el lenguaje C objetivo [8]. La Tabla 95a resume la correspondencia entre el tipo interno del conversor, su representación en C, los especificadores de formato para las funciones de entrada/salida estándar y el valor de inicialización por omisión según el estándar C99.

**Tabla 95a. Tipos de datos soportados por el conversor y su correspondencia en C [8]**

| Tipo FlowCode | Representación C | Especificador `printf` | Especificador `scanf` | Valor por omisión |
|---|---|---|---|---|
| `integer` | `int` | `%d` | `%d` | `0` |
| `float` | `float` | `%f` | `%f` | `0.0f` |
| `double_` | `double` | `%lf` | `%lf` | `0.0` |
| `char` | `char` | `%c` | `" %c"` | `'\0'` |
| `string` | `char*` | `%s` | `%s` | `NULL` |
| `boolean` | `bool` | `%d` | `%d` | `false` |

El especificador de `scanf` para `char` incluye un espacio inicial (`" %c"`) para descartar cualquier carácter de espacio en blanco residual en el búfer de entrada, evitando un error frecuente en programas con múltiples lecturas consecutivas.

---

## 17.2 Gestión de Alcances

### 17.2.1 Ámbitos global y local

Cada ámbito posee un identificador único, un nivel de profundidad (donde 0 corresponde al alcance global), una referencia al ámbito padre y un diccionario de símbolos declarados en ese ámbito específico. Al inicializar la tabla de símbolos, se crea automáticamente el alcance global, que persiste durante todo el proceso de conversión.

Cuando se requiere modelar un bloque local (por ejemplo, al asociar una estructura de control a un ámbito propio), se crea un nuevo ámbito hijo con nivel de profundidad incrementado. Al salir de dicho bloque, se retorna al ámbito padre, haciendo inaccesibles los símbolos declarados en el ámbito cerrado.

En la versión actual del análisis semántico, estas transiciones de ámbito no se disparan automáticamente desde la topología del diagrama; en consecuencia, la mayoría de símbolos permanecen en nivel global.

### 17.2.2 Búsqueda y resolución de símbolos

Cuando existen ámbitos anidados, la resolución de símbolos implementa la regla de alcance léxico mediante una búsqueda ascendente en la jerarquía de ámbitos: se busca primero en el ámbito actual; si no se encuentra el identificador, se continúa en el ámbito padre, y así sucesivamente hasta el alcance global. Esta semántica permite que variables locales con el mismo nombre que variables globales tomen precedencia dentro de su bloque, comportamiento consistente con el lenguaje C [9].

Para detectar declaraciones duplicadas dentro del mismo bloque, se ofrece una búsqueda restringida que examina únicamente el ámbito actual. La declaración de nuevos símbolos verifica primero que no exista un símbolo con el mismo nombre en el ámbito actual; si la verificación es exitosa, se crea la entrada con todos sus metadatos.

---

## 17.3 Información de Tipos para Generación de Código

La información de tipos almacenada en la tabla de símbolos es fundamental para la generación correcta del código C, en particular para las operaciones de entrada/salida. Cuando se traduce un nodo de datos con la instrucción `leer(x)`, el conversor consulta el tipo de `x` en la tabla de símbolos y genera la llamada a `scanf` con el especificador de formato apropiado. Análogamente, para `mostrar(resultado)`, el tipo determina si se genera `printf("%d", resultado)` o `printf("%f", resultado)`.

La extensión de tipos también incluye el método `defaultValue`, que proporciona valores de inicialización seguros según el estándar C99 [8]: `0` para enteros, `0.0f` para `float`, `0.0` para `double`, `'\0'` para `char`, `NULL` para cadenas y `false` para booleanos. Estos valores se utilizan cuando el conversor genera declaraciones de variables que no fueron inicializadas explícitamente en el diagrama.

La tabla de símbolos soporta exportación a representación estructurada, lo que facilita su presentación en la interfaz de usuario (pestaña *Semántico* del diálogo de resultados del conversor, véase sección 10.9.3) y su uso en el reporte de conversión.

---

## 17.4 Sistema de Errores del Conversor

El sistema de errores proporciona retroalimentación precisa al usuario durante el proceso de conversión. Se adopta un enfoque estructurado que clasifica los mensajes por tipo, severidad y fase de conversión, lo que permite emitir sugerencias de corrección contextuales [3].

### 17.4.1 Clasificación de errores por fase

Los errores se organizan en tres categorías según la fase de conversión donde se detectan. Cada código de error posee un identificador numérico único que facilita su referencia en el reporte de conversión.

**Errores léxicos (códigos 1001–1010).** El catálogo define errores para la fase léxica; en la implementación actual del tokenizador se reportan principalmente: carácter no reconocido por el lenguaje (`1001`), cadena de texto sin cerrar (`1002`) y literal numérico mal formado (`1004`). Los códigos restantes (por ejemplo `1003`, `1005–1010`) están definidos para extensiones futuras o validaciones más estrictas (comentarios sin cerrar, reglas adicionales de literales y verificación detallada de especificadores de formato).

**Errores sintácticos (códigos 2001–2010).** Emergen cuando la secuencia de *tokens* no conforma una estructura gramatical válida. En la implementación actual del parser se utilizan principalmente: *token* inesperado (`2001`), *token* faltante (`2002`), desbalances de delimitadores (`2003` para paréntesis y `2005` para corchetes), expresión inválida (`2006`) y declaración inválida (`2009`). Otros códigos (por ejemplo `2004`, `2007` y `2008`) quedan reservados para validaciones adicionales.

**Errores semánticos (códigos 3001–3011).** Se detectan cuando el código es sintácticamente correcto pero viola las reglas de significado del lenguaje. Requieren consultar la tabla de símbolos. Los principales son: variable no declarada (`3001`), declaración duplicada en el mismo ámbito (`3002`), incompatibilidad de tipos en una operación o asignación (`3003`), operación no válida para los tipos involucrados (`3004`), variable usada antes de ser inicializada (`3005`), variable declarada pero no utilizada (`3006`), conversión de tipo con pérdida de información (`3007`), división por cero cuando el divisor es una constante literal (`3008`), índice de arreglo no entero (`3009`), identificador fuera de alcance (`3010`, cuando se habilita el análisis por ámbitos) y función no reconocida (`3011`).

### 17.4.2 Niveles de severidad

La Tabla 96 presenta los cuatro niveles de severidad y su efecto sobre el proceso de conversión.

**Tabla 96. Niveles de severidad del sistema de errores**

| Severidad | Prefijo | Comportamiento del conversor |
|---|---|---|
| `info` | INFO | Mensaje informativo; la conversión continúa normalmente. |
| `warning` | WARNING | Advertencia; la conversión continúa pero se recomienda revisión. |
| `error` | ERROR | Violación de reglas; el conversor intenta recuperarse para reportar errores adicionales. |
| `fatal` | FATAL | Error crítico; la conversión se detiene de inmediato (por ejemplo, ausencia del nodo de inicio). |

Los errores de nivel `error` no detienen inmediatamente la conversión: el conversor intenta recuperarse para detectar problemas adicionales y proporcionar al usuario una lista más completa en una sola ejecución. Los errores `fatal` corresponden a condiciones estructurales que hacen imposible continuar, como la ausencia del nodo de inicio en el diagrama.

### 17.4.3 Fases de conversión

Cada mensaje de error indica la fase de conversión donde se originó: análisis léxico, análisis sintáctico, análisis semántico, optimización o generación de código. La validación estructural del grafo del diagrama se ejecuta como un paso previo (sección 14.4.5); aunque el catálogo define códigos `4xxx` para esta fase, en la versión actual dichos diagnósticos se reportan como mensajes del validador estructural.

---

## 17.5 Reportes de Conversión

Cada mensaje de error encapsula: el código de error, el nivel de severidad, la fase, el mensaje legible en español, la ubicación en el diagrama (nodo, línea y columna) y una sugerencia de corrección. Por ejemplo, ante un carácter inesperado se genera automáticamente el mensaje *"Carácter inesperado: [x]"* con la sugerencia *"Verifica que el carácter sea válido en este contexto"*.

La colección de errores ofrece métodos de filtrado por severidad y por fase, indicadores booleanos de si existen errores fatales o errores generales, y un resumen textual del resultado de la conversión. Este resumen se presenta al usuario en la interfaz como indicador inmediato del estado de la conversión (véase sección 10.9.3).

Los errores se serializan en formato JSON, lo que permite almacenarlos junto con el proyecto y presentarlos en el reporte de conversión detallado. Los mensajes se emiten en español para garantizar consistencia con la interfaz de la aplicación.
