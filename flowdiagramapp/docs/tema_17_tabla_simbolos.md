# 17. Tabla de Símbolos

La tabla de símbolos constituye una estructura de datos fundamental en el conversor de FlowCode, encargada de almacenar y gestionar toda la información relacionada con los identificadores declarados durante la conversión. Esta estructura actúa como el repositorio central de metadatos sobre variables, constantes y funciones, permitiendo al analizador semántico realizar verificaciones de tipo, detectar variables no declaradas y controlar el alcance de los identificadores.

## 17.1 Estructura de SymbolTable

La implementación de la tabla de símbolos en FlowCode se encuentra en el archivo `symbol_table.dart` y comprende aproximadamente 640 líneas de código Dart. El diseño sigue un enfoque orientado a objetos con tres clases principales que trabajan en conjunto para proporcionar una gestión completa de símbolos.

### 17.1.1 Clase Symbol y atributos

La clase `SymbolInfo` representa la unidad fundamental de información en la tabla de símbolos. Cada instancia encapsula todos los metadatos necesarios sobre un identificador declarado en el programa.

**[Imagen sugerida: Diagrama UML de la clase SymbolInfo mostrando sus atributos y métodos principales]**

Los atributos principales de `SymbolInfo` incluyen el nombre del identificador, su tipo de dato, la categoría del símbolo (variable, constante, parámetro o función), y la información de ubicación que comprende el nivel de alcance, el identificador del nodo del diagrama donde fue declarado, y las coordenadas de línea y columna dentro del contenido textual del nodo. Adicionalmente, la clase mantiene banderas de estado como `isInitialized` e `isUsed`, que permiten detectar advertencias sobre variables no inicializadas o no utilizadas durante el análisis semántico.

Para arreglos, el atributo `arrayDimensions` almacena una lista de enteros representando las dimensiones declaradas. Para funciones, `parameterTypes` contiene los tipos de los parámetros y `returnType` el tipo de retorno. Un mapa de metadatos adicional permite extender la información almacenada sin modificar la estructura base de la clase.

La categoría del símbolo se define mediante la enumeración `SymbolCategory`, que distingue entre variables regulares, constantes, parámetros de función, nombres de función, arreglos, etiquetas para saltos y definiciones de tipo. Esta clasificación permite al conversor aplicar reglas semánticas específicas según el tipo de símbolo, como prohibir la asignación a constantes o validar el número de argumentos en llamadas a función.

### 17.1.2 Tipos de datos soportados (DataType)

El sistema de tipos de FlowCode se implementa mediante la enumeración `DataType`, que define once categorías de tipos compatibles con el lenguaje C objetivo. Los tipos primitivos incluyen `integer` (int), `float`, `double_` (con guion bajo porque "double" es palabra reservada en Dart), `char`, `string` (representado como char* en C) y `boolean` (bool). Adicionalmente, se soportan tipos compuestos como `array`, `pointer` y `function_`, junto con los tipos especiales `void_` y `unknown` para casos donde el tipo aún no ha sido determinado.

| Tipo FlowCode | Representación C | Especificador printf | Especificador scanf | Valor por defecto |
|---------------|------------------|---------------------|---------------------|-------------------|
| integer       | int              | %d                  | %d                  | 0                 |
| float         | float            | %f                  | %f                  | 0.0f              |
| double_       | double           | %lf                 | %lf                 | 0.0               |
| char          | char             | %c                  | %c (con espacio)    | '\0'              |
| string        | char*            | %s                  | %s                  | NULL              |
| boolean       | bool             | %d                  | %d                  | false             |

La extensión `DataTypeExtension` proporciona métodos auxiliares que facilitan la generación de código C. El método `cRepresentation` retorna la cadena exacta que debe aparecer en las declaraciones C. Los métodos `formatSpecifier` y `scanfSpecifier` devuelven los especificadores de formato apropiados para las funciones printf y scanf respectivamente, tomando en cuenta particularidades como el espacio previo al %c en scanf para ignorar espacios en blanco residuales. El método `defaultValue` proporciona el valor de inicialización por defecto según el estándar C99.

La extensión también incluye propiedades de consulta como `isNumeric`, que retorna verdadero para integer, float y double, e `isArithmetic`, que además incluye char ya que en C los caracteres pueden participar en operaciones aritméticas. El método `sizeInBytes` proporciona el tamaño típico en memoria, lo cual puede ser útil para optimizaciones futuras o para informar al usuario sobre el uso de memoria de su programa.

## 17.2 Gestión de Alcances

El manejo de alcances en FlowCode sigue el modelo de alcance léxico característico del lenguaje C, donde las variables declaradas en un bloque solo son visibles dentro de ese bloque y sus bloques anidados. Esta funcionalidad es esencial para soportar correctamente las estructuras de control como bucles y condicionales.

### 17.2.1 Ámbitos global y local

La clase `Scope` representa un ámbito individual dentro del programa. Cada alcance posee un identificador único, un nivel de profundidad (donde 0 corresponde al alcance global), una referencia al alcance padre, y un diccionario de símbolos declarados en ese alcance específico. La estructura mantiene también una lista de alcances hijos y opcionalmente el identificador del nodo del diagrama donde se creó el alcance, junto con una descripción textual como "if-then", "while-body" o "function-main".

Al inicializar la tabla de símbolos, el constructor crea automáticamente el alcance global con nivel 0. Este alcance persiste durante todo el proceso de conversión y sirve como contenedor para variables globales y funciones. La clase `SymbolTable` mantiene también un diccionario separado `_globalSymbols` que permite acceso rápido a símbolos globales sin necesidad de recorrer la jerarquía de alcances.

El método `enterScope` crea un nuevo alcance hijo del alcance actual, incrementando el nivel de profundidad. Este método se invoca al entrar en estructuras de control como condicionales y bucles, así como al procesar nodos de decisión y preparación en el diagrama de flujo. El método `exitScope` retorna al alcance padre, efectivamente "cerrando" el alcance actual y haciendo inaccesibles las variables declaradas en él.

### 17.2.2 Búsqueda y resolución de símbolos

La resolución de símbolos implementa la regla de alcance léxico mediante una búsqueda ascendente en la jerarquía de alcances. El método `lookup` recibe un nombre de identificador y busca primero en el alcance actual; si no lo encuentra, continúa la búsqueda en el alcance padre, y así sucesivamente hasta llegar al alcance global. Esta semántica permite que variables locales "oculten" variables globales del mismo nombre, comportamiento consistente con el lenguaje C.

El método `lookupInCurrentScope` proporciona una búsqueda restringida que solo examina el alcance actual, útil para detectar declaraciones duplicadas dentro del mismo bloque. El método `symbolExists` ofrece una verificación rápida de existencia sin retornar la información completa del símbolo.

La declaración de nuevos símbolos mediante `declareSymbol` verifica primero que no exista un símbolo con el mismo nombre en el alcance actual (las declaraciones duplicadas en diferentes alcances son válidas). Si la verificación es exitosa, crea una instancia de `SymbolInfo` con todos los metadatos proporcionados y la agrega tanto al diccionario del alcance actual como a la lista global `_allSymbols` que facilita iteraciones posteriores.

## 17.3 Información de Tipos

La información de tipos almacenada en la tabla de símbolos es fundamental para la generación correcta de código C, particularmente para las operaciones de entrada/salida que requieren especificadores de formato específicos según el tipo de dato.

### 17.3.1 Especificadores de formato (printf/scanf)

La generación de llamadas a printf y scanf requiere seleccionar el especificador de formato correcto según el tipo de la variable. La extensión `DataTypeExtension` centraliza esta información, evitando código duplicado en el generador de código y garantizando consistencia.

Para printf, los especificadores siguen las convenciones estándar de C: %d para enteros y booleanos (que se representan como 0 o 1), %f para float, %lf para double, %c para caracteres individuales, %s para cadenas, y %p para punteros. Para scanf, los especificadores son similares con una excepción importante: el especificador para char incluye un espacio inicial (" %c") que instruye a scanf a ignorar cualquier espacio en blanco residual en el buffer de entrada, evitando un error común de principiantes donde el salto de línea de una entrada anterior es capturado como el carácter.

El generador de código utiliza estos especificadores al traducir nodos de datos (entrada/salida). Cuando el usuario escribe `leer(x)` en un nodo de datos, el conversor consulta el tipo de `x` en la tabla de símbolos y genera el código scanf apropiado. Similarmente, para `mostrar(resultado)`, el tipo determina si se genera `printf("%d", resultado)` o `printf("%f", resultado)`.

### 17.3.2 Valores por defecto en C

El método `defaultValue` de la extensión `DataTypeExtension` proporciona valores de inicialización seguros para cada tipo. Esta información es útil cuando el conversor genera declaraciones de variables que el usuario no inicializó explícitamente, siguiendo las buenas prácticas de programación defensiva.

Los valores por defecto siguen las convenciones de C99: 0 para enteros, 0.0f para float (con sufijo f para evitar promoción a double), 0.0 para double, '\0' (carácter nulo) para char, NULL para punteros y cadenas, y false para booleanos. Para arreglos, se utiliza la inicialización agregada vacía {}.

La tabla de símbolos también soporta exportación a formatos estructurados mediante el método `toJson`, que genera una representación en mapa del estado completo de la tabla incluyendo conteo de símbolos, conteo de alcances, nivel actual, y una lista detallada de cada símbolo con sus atributos. Esta funcionalidad facilita la depuración y permite implementar funciones de diagnóstico en la interfaz de usuario. El método `generateCDeclarations` produce directamente las declaraciones de variables en sintaxis C, agrupando variables del mismo tipo para generar código más legible como `int a, b, c;` en lugar de declaraciones separadas.
