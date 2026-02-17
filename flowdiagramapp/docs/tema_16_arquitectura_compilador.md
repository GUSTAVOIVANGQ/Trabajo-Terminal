# 16. Arquitectura del Conversor de Diagramas de Flujo a Código C

El conversor de FlowCode implementa la traducción de diagramas de flujo a código en lenguaje C mediante un pipeline de cinco fases secuenciales. A diferencia de un compilador tradicional que genera código objeto o ejecutable, este conversor produce código fuente legible y compilable en C estándar (C99) a partir del reconocimiento de lexemas visuales (nodos del diagrama de flujo).

## 16.1 Pipeline de Conversión

El proceso de conversión sigue una arquitectura de pipeline donde cada fase recibe como entrada el resultado de la fase anterior, enriqueciendo progresivamente la información hasta generar el código final.

### 16.1.1 Diagrama de fases del conversor

El conversor ejecuta cinco fases en secuencia estricta. Si alguna fase detecta errores críticos, el pipeline se detiene y reporta los problemas encontrados sin continuar a las fases posteriores.

**[INSERTAR FIGURA: Diagrama de flujo de las 5 fases del pipeline mostrando: Diagrama → Fase 1 (Léxico) → Fase 2 (Sintáctico) → Fase 3 (Semántico) → Fase 4 (Optimización) → Fase 5 (Generación) → Código C]**

La entrada del conversor consiste en dos estructuras de datos: la lista de nodos del diagrama (`List<DiagramNode>`) y la lista de conexiones entre ellos (`List<Connection>`). Cada nodo contiene su tipo según el estándar ISO 5807, el texto que el usuario ingresó, su posición visual y metadatos adicionales que permiten distinguir entre estructuras de control específicas (por ejemplo, diferenciar un bucle `for` de un bucle `while`).

### 16.1.2 Clase DiagramCompilerPipeline (Pipeline de Conversión)

La clase `DiagramCompilerPipeline` actúa como orquestador central del proceso de conversión. Esta clase instancia y coordina los analizadores de cada fase, gestiona el flujo de datos entre ellos y recopila los resultados y errores de todo el proceso.

El método principal `compile()` ejecuta las cinco fases secuencialmente y retorna un objeto `CompilationResult` que contiene el resultado de la conversión:

- El código C generado (si la conversión fue exitosa)
- La tabla de símbolos construida durante el análisis
- El árbol de sintaxis abstracta (AST) resultante
- La colección de errores y advertencias de todas las fases
- Métricas de conversión (tiempos por fase, nodos procesados, tokens generados)

El pipeline está diseñado para detenerse tan pronto como se detecten errores fatales. Esto evita que las fases posteriores procesen información inconsistente y permite que los mensajes de error sean más precisos y útiles para el usuario.

### 16.1.3 Opciones de conversión (CompilerOptions)

El conversor soporta configuración mediante la clase `CompilerOptions`, que permite ajustar el comportamiento de la conversión según las necesidades del usuario. Los parámetros configurables incluyen:

| Parámetro | Tipo | Valor por defecto | Función |
|-----------|------|-------------------|---------|
| `optimizationLevel` | int (0-3) | 1 | Nivel de optimización del AST |
| `generateComments` | bool | true | Incluir comentarios en el código generado |
| `strictTypeChecking` | bool | false | Verificación estricta de tipos |
| `showWarnings` | bool | true | Mostrar advertencias además de errores |
| `targetCStandard` | String | "c99" | Estándar C objetivo (c99, c11, c17) |
| `language` | String | "es" | Idioma de mensajes de error |

El sistema proporciona tres configuraciones predefinidas para casos de uso comunes:

- **defaults**: Configuración balanceada para uso general
- **debug**: Verificaciones exhaustivas y código con información de depuración
- **release**: Optimizaciones habilitadas y salida compacta sin comentarios

---

## 16.2 Fase 1: Análisis Léxico

La primera fase del conversor es el análisis léxico, implementado en la clase `DiagramLexicalAnalyzer`. Su función principal es extraer los tokens del contenido textual de cada nodo del diagrama.

### 16.2.1 DiagramLexicalAnalyzer

El analizador léxico procesa cada nodo del diagrama de forma independiente, extrayendo los tokens del texto que contiene. A diferencia de un analizador léxico convencional que procesa un flujo continuo de caracteres de un archivo fuente, este analizador trabaja con fragmentos discretos de texto provenientes de cada nodo del diagrama.

El proceso de tokenización recorre el texto carácter por carácter, identificando patrones que corresponden a tokens válidos. El analizador mantiene un seguimiento de la posición actual (línea y columna) para reportar la ubicación exacta de cualquier error encontrado.

Durante el análisis léxico también se construye la versión inicial de la tabla de símbolos. Cuando el analizador encuentra una declaración de variable, registra el nombre y el tipo inferido en la tabla. Esta información será refinada y validada en fases posteriores.

### 16.2.2 Sistema de tokens (TokenType)

El sistema de tokens de FlowCode reconoce aproximadamente 80 tipos diferentes de tokens, organizados en las siguientes categorías:

**Identificadores y literales**: Nombres de variables, constantes numéricas enteras y de punto flotante, cadenas de texto, caracteres individuales y valores booleanos.

**Palabras reservadas de C**: El analizador reconoce las palabras clave del lenguaje C estándar incluyendo `int`, `float`, `char`, `if`, `else`, `while`, `for`, `switch`, `case`, `break`, `continue`, `return`, `printf` y `scanf`.

**Palabras reservadas en español**: Para facilitar el uso de la aplicación por estudiantes hispanohablantes, el analizador también reconoce equivalentes en español como `entero`, `real`, `caracter`, `si`, `sino`, `mientras`, `para`, `leer`, `mostrar` y `escribir`. Internamente, estas palabras se mapean a sus equivalentes semánticos en C durante las fases posteriores.

**Operadores**: El sistema reconoce operadores aritméticos (`+`, `-`, `*`, `/`, `%`), operadores de comparación (`==`, `!=`, `<`, `>`, `<=`, `>=`), operadores lógicos (`&&`, `||`, `!`), operadores de asignación (`=`, `+=`, `-=`, `*=`, `/=`) y operadores de incremento/decremento (`++`, `--`).

**Delimitadores**: Paréntesis, llaves, corchetes, punto y coma, coma, dos puntos y otros caracteres especiales que estructuran las expresiones.

### 16.2.3 Tokenización de contenido de nodos

El proceso de tokenización sigue un algoritmo que examina el carácter actual y toma decisiones basadas en su valor:

1. **Espacios en blanco**: Se registran como tokens de tipo `whitespace` (posteriormente filtrados) y se avanza la posición.

2. **Dígitos**: Inicia el reconocimiento de un literal numérico. El analizador continúa consumiendo dígitos y, si encuentra un punto decimal, continúa como número de punto flotante.

3. **Letras o guión bajo**: Inicia el reconocimiento de un identificador o palabra reservada. El analizador consume caracteres alfanuméricos hasta encontrar un delimitador, luego verifica si la cadena coincide con alguna palabra reservada.

4. **Comillas**: Inicia el reconocimiento de un literal de cadena (comillas dobles) o carácter (comilla simple).

5. **Operadores de dos caracteres**: Verifica si el carácter actual junto con el siguiente forman un operador de dos caracteres (`==`, `!=`, `<=`, `>=`, `&&`, `||`, `++`, `--`).

6. **Caracteres especiales**: Se mapean directamente a su tipo de token correspondiente.

El resultado de esta fase es un objeto `DiagramLexicalResult` que contiene los tokens de cada nodo, la tabla de símbolos parcialmente construida y cualquier error léxico encontrado (como cadenas sin cerrar o caracteres no reconocidos).

---

## 16.3 Fase 2: Análisis Sintáctico

La segunda fase implementa el análisis sintáctico mediante la clase `DiagramSyntaxAnalyzer`. Su objetivo es verificar que la secuencia de tokens de cada nodo forme construcciones sintácticamente válidas y construir el Árbol de Sintaxis Abstracta (AST).

### 16.3.1 DiagramSyntaxAnalyzer

El analizador sintáctico recibe como entrada la lista de nodos del diagrama y utiliza el analizador léxico internamente para obtener los tokens de cada nodo antes de procesarlo.

El análisis se adapta al tipo de nodo que se está procesando. Un nodo de tipo `process` espera declaraciones de variables o expresiones de asignación. Un nodo de tipo `data` espera operaciones de entrada (`scanf`) o salida (`printf`). Un nodo de tipo `decision` espera una expresión booleana o de comparación. Esta diferenciación por tipo permite al parser aplicar las reglas gramaticales apropiadas para cada contexto.

Si se encuentran errores sintácticos, el analizador intenta recuperarse mediante sincronización: avanza en los tokens hasta encontrar un punto de recuperación (como un punto y coma o el final del contenido) para continuar analizando el resto del nodo y reportar todos los errores posibles en una sola pasada.

### 16.3.2 Parser de descenso recursivo

El parser implementa la técnica de descenso recursivo predictivo, donde cada categoría gramatical se representa como una función que puede llamar a otras funciones según las reglas de la gramática.

Para expresiones, el parser implementa precedencia de operadores mediante una jerarquía de funciones. La expresión de más baja precedencia (asignación) se analiza primero, y cada función puede invocar a la siguiente de mayor precedencia:

```
Expresión → Asignación
Asignación → OrLógico ('=' Asignación)?
OrLógico → AndLógico ('||' AndLógico)*
AndLógico → Igualdad ('&&' Igualdad)*
Igualdad → Comparación (('=='|'!=') Comparación)*
Comparación → Término (('<'|'>'|'<='|'>=') Término)*
Término → Factor (('+'|'-') Factor)*
Factor → Unario (('*'|'/'|'%') Unario)*
Unario → ('!'|'-'|'+')? Primario
Primario → Literal | Identificador | '(' Expresión ')' | LlamadaFunción
```

Esta estructura garantiza que operadores con mayor precedencia (como multiplicación) se evalúen antes que los de menor precedencia (como suma), y que las expresiones entre paréntesis se evalúen primero.

### 16.3.3 Construcción del AST (ProgramNode)

El resultado principal del análisis sintáctico es el Árbol de Sintaxis Abstracta, una representación jerárquica del programa que captura su estructura sin los detalles sintácticos superficiales como paréntesis redundantes o estilo de formato.

El nodo raíz del AST es de tipo `ProgramNode` y contiene:

- **diagramNodes**: Lista de nodos `DiagramASTNode`, cada uno representando un nodo del diagrama original con sus sentencias parseadas
- **globalDeclarations**: Lista de declaraciones de variables que se extraen para colocarse al inicio de la función `main()`

Cada tipo de sentencia tiene su clase de nodo AST correspondiente:

- `DeclarationStatementNode`: Declaraciones de variables con tipo, nombre y valor inicial opcional
- `ExpressionStatementNode`: Expresiones que se evalúan por su efecto secundario (asignaciones)
- `IfStatementNode`: Estructuras condicionales con condición, bloque then y bloque else opcional
- `WhileStatementNode`: Bucles while con condición y cuerpo
- `ForStatementNode`: Bucles for con inicialización, condición, incremento y cuerpo
- `InputStatementNode`: Operaciones de lectura con variable destino y tipo
- `OutputStatementNode`: Operaciones de escritura con expresión y formato

**[INSERTAR FIGURA: Ejemplo de AST para un diagrama simple que declara una variable, lee un valor y lo imprime]**

El AST resultante sirve como representación intermedia del programa que será utilizada por las fases posteriores para análisis semántico, optimización y generación de código.

---

## 16.4 Fase 3: Análisis Semántico

La tercera fase realiza el análisis semántico mediante la clase `DiagramSemanticAnalyzer`. Esta fase verifica que el programa tenga sentido semántico más allá de su corrección sintáctica.

### 16.4.1 DiagramSemanticAnalyzer

El analizador semántico recibe como entrada los nodos del diagrama, las conexiones entre ellos, la tabla de símbolos construida en la fase léxica y el AST de la fase sintáctica. Procesa cada nodo del diagrama verificando las reglas semánticas correspondientes a su tipo.

El análisis semántico recorre el diagrama en orden de ejecución (desde el nodo de inicio siguiendo las conexiones) para verificar que las variables se utilicen correctamente según el flujo del programa. Esto permite detectar casos donde una variable se usa antes de ser declarada o inicializada.

### 16.4.2 Verificación de tipos (DataType)

El sistema de tipos de FlowCode reconoce los tipos primitivos de C:

| DataType | Representación C | Especificador printf | Especificador scanf |
|----------|------------------|---------------------|---------------------|
| `integer` | int | %d | %d |
| `float` | float | %f | %f |
| `double_` | double | %lf | %lf |
| `char` | char | %c | %c |
| `string` | char* | %s | %s |
| `boolean` | bool | %d | %d |

La verificación de tipos opera en varios niveles. En expresiones aritméticas, verifica que los operandos sean numéricos. En expresiones de comparación, verifica compatibilidad entre los tipos comparados. En asignaciones, verifica que el tipo del valor asignado sea compatible con el tipo de la variable destino.

El sistema implementa conversión implícita en casos seguros (por ejemplo, asignar un `int` a un `float`) pero genera advertencias cuando hay pérdida potencial de precisión (asignar un `float` a un `int`).

### 16.4.3 Análisis de alcance (ScopeAnalysisResult)

El análisis de alcance determina qué variables son visibles en cada punto del programa. FlowCode implementa un modelo simplificado de alcances adecuado para programas educativos:

El alcance global contiene todas las variables declaradas en nodos de proceso que no están dentro de estructuras de control. El alcance local se crea dentro de bloques de estructuras como `if`, `while` y `for`, donde las variables declaradas solo son visibles dentro de ese bloque.

El resultado del análisis de alcance incluye:

- `nodeScopeLevels`: Nivel de anidamiento de cada nodo en la estructura de alcances
- `accessibleVariables`: Conjunto de variables visibles en cada nodo del diagrama
- `scopeParents`: Jerarquía de alcances para resolución de nombres

### 16.4.4 Detección de variables no declaradas

Una de las verificaciones semánticas más importantes es detectar el uso de variables que no han sido declaradas. Cuando se encuentra un identificador en una expresión, el analizador busca su entrada en la tabla de símbolos considerando los alcances visibles desde ese punto.

Si la variable no se encuentra en ningún alcance accesible, se genera un error semántico con código `undeclaredVariable` que indica el nombre de la variable y su ubicación en el diagrama. Este error es particularmente útil para estudiantes, ya que es uno de los errores más comunes al aprender programación.

El analizador también detecta variables que se usan antes de ser inicializadas. Aunque la variable esté declarada, si no se le ha asignado un valor antes de leerla, se genera una advertencia indicando que el valor de la variable es indeterminado.

El resultado de esta fase es un objeto `SemanticAnalysisResult` que incluye la tabla de símbolos actualizada, el entorno de tipos, los resultados del análisis de alcance y las listas de errores y advertencias semánticas.
