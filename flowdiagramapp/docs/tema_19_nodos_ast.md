# 19. Nodos del Árbol de Sintaxis Abstracta

El Árbol de Sintaxis Abstracta (AST por sus siglas en inglés) constituye la representación intermedia central del conversor de FlowCode. Esta estructura de datos captura la semántica del programa descartando detalles sintácticos irrelevantes como paréntesis redundantes o espacios en blanco, permitiendo que las fases posteriores de análisis semántico, optimización y generación de código trabajen sobre una representación uniforme y bien estructurada. La implementación se encuentra en el archivo `ast_nodes.dart` con aproximadamente 1305 líneas de código Dart.

## 19.1 Jerarquía de Nodos AST

El diseño del AST en FlowCode sigue una jerarquía de clases que refleja las categorías gramaticales del lenguaje C objetivo. Esta organización facilita el procesamiento uniforme mediante el patrón Visitor y permite extensiones futuras sin modificar el código existente.

### 19.1.1 Clase base ASTNode

Todos los nodos del AST heredan de la clase abstracta `ASTNode`, que define la interfaz común para cualquier elemento del árbol. Esta clase base proporciona tres elementos fundamentales: información de posición en el código fuente, un identificador opcional del nodo del diagrama de origen, y los métodos requeridos para el recorrido del árbol.

El atributo `position` de tipo `SourcePosition` encapsula las coordenadas de línea y columna donde inicia el constructo representado por el nodo, así como opcionalmente las coordenadas de finalización. Esta información es esencial para generar mensajes de error que señalen la ubicación exacta de problemas detectados durante el análisis semántico o la generación de código.

El atributo opcional `nodeId` vincula cada nodo del AST con el nodo del diagrama de flujo que lo originó. Esta trazabilidad permite que los errores detectados en fases posteriores puedan asociarse visualmente con el símbolo correspondiente en el editor, mejorando significativamente la experiencia del usuario al depurar sus diagramas.

La clase define tres métodos abstractos que toda subclase debe implementar: `accept<T>(ASTVisitor<T> visitor)` para soportar el patrón Visitor, `children` que retorna la lista de nodos hijos para facilitar recorridos genéricos, y `toTreeString([int indent])` que genera una representación textual legible del subárbol para depuración.

**[Imagen sugerida: Diagrama de herencia mostrando ASTNode como raíz y las principales categorías de nodos derivados]**

### 19.1.2 Nodos literales (IntegerLiteralNode, FloatLiteralNode, etc.)

Los nodos literales representan valores constantes que aparecen directamente en el código fuente. FlowCode implementa cinco tipos de literales correspondientes a los tipos primitivos del lenguaje C.

`IntegerLiteralNode` almacena valores enteros como 42, -17 o 0. El atributo `value` es de tipo `int` de Dart, que puede representar enteros de precisión arbitraria aunque en la práctica los valores se limitan al rango de `int` de C (típicamente 32 bits con signo). `FloatLiteralNode` representa valores de punto flotante como 3.14 o -0.5, almacenando el valor como `double` de Dart.

`StringLiteralNode` contiene cadenas de texto delimitadas por comillas dobles. El valor almacenado no incluye las comillas delimitadoras pero preserva las secuencias de escape como `\n` o `\t`. `CharLiteralNode` representa literales de carácter delimitados por comillas simples, almacenando el carácter como un `String` de un solo elemento. `BooleanLiteralNode` representa los valores lógicos `true` y `false`, que en C se traducen típicamente a 1 y 0 respectivamente.

Todos los nodos literales son hojas del árbol (su propiedad `children` retorna lista vacía) ya que no contienen subnodos. Su método `toTreeString` produce representaciones como `IntegerLiteral(42)` o `StringLiteral("hello")` que facilitan la inspección visual del AST durante el desarrollo.

### 19.1.3 Nodos de expresión (BinaryExpressionNode, UnaryExpressionNode)

Las expresiones constituyen la categoría más rica de nodos, abarcando desde referencias simples a variables hasta expresiones compuestas con múltiples operadores.

`IdentifierNode` representa una referencia a una variable o función por su nombre. Este nodo es fundamental para el análisis semántico, que debe verificar que el identificador haya sido declarado previamente consultando la tabla de símbolos.

`BinaryExpressionNode` modela operaciones con dos operandos unidos por un operador binario. La enumeración `BinaryOperator` define 18 operadores organizados en categorías: aritméticos (add, subtract, multiply, divide, modulo), de comparación (equal, notEqual, less, lessEqual, greater, greaterEqual), lógicos (and, or) y de bits (bitAnd, bitOr, bitXor, shiftLeft, shiftRight). Cada operador tiene una extensión que proporciona su representación simbólica y un método para convertir desde `TokenType`.

| Categoría | Operadores | Símbolos |
|-----------|------------|----------|
| Aritméticos | add, subtract, multiply, divide, modulo | +, -, *, /, % |
| Comparación | equal, notEqual, less, lessEqual, greater, greaterEqual | ==, !=, <, <=, >, >= |
| Lógicos | and, or | &&, \|\| |
| Bits | bitAnd, bitOr, bitXor, shiftLeft, shiftRight | &, \|, ^, <<, >> |

`UnaryExpressionNode` representa operaciones con un solo operando. La enumeración `UnaryOperator` incluye negación aritmética (negate), negación lógica (not), complemento de bits (bitNot), incremento y decremento tanto prefijo como postfijo (preIncrement, postIncrement, preDecrement, postDecrement), y operadores de punteros (addressOf, dereference). La propiedad `isPrefix` distingue si el operador precede o sigue al operando.

`AssignmentExpressionNode` modela asignaciones incluyendo operadores compuestos. La enumeración `AssignmentOperator` define: assign (=), addAssign (+=), subtractAssign (-=), multiplyAssign (*=), divideAssign (/=) y moduloAssign (%=). El nodo almacena el objetivo de la asignación (típicamente un identificador o acceso a arreglo), el operador y la expresión de valor.

`ConditionalExpressionNode` representa el operador ternario `condition ? trueExpr : falseExpr`, almacenando las tres subexpresiones como nodos hijos. `FunctionCallNode` modela llamadas a función con el nombre de la función y una lista de argumentos. `ArrayAccessNode` representa acceso a elementos de arreglo mediante índice, y `ArrayInitializerNode` representa inicializadores de arreglo como `{1, 2, 3}`.

### 19.1.4 Nodos de sentencia (DeclarationStatementNode, IfStatementNode, etc.)

Los nodos de sentencia representan instrucciones completas que el programa ejecuta. Todos heredan de `StatementNode`, que a su vez hereda de `ASTNode`.

`ExpressionStatementNode` envuelve una expresión para tratarla como sentencia, típicamente asignaciones o llamadas a función que se ejecutan por sus efectos secundarios. `DeclarationStatementNode` representa declaraciones de variables con atributos para el tipo de dato, nombre de variable, inicializador opcional, y banderas para indicar si es arreglo o puntero junto con el tamaño del arreglo cuando aplica.

`InputStatementNode` modela operaciones de entrada de datos, almacenando la lista de variables donde se leerán los valores y opcionalmente una cadena de formato para scanf. `OutputStatementNode` representa operaciones de salida con una lista de expresiones a imprimir y formato opcional.

`IfStatementNode` representa estructuras condicionales con atributos para la condición, la rama then (obligatoria) y la rama else (opcional). Esta estructura soporta tanto condicionales simples como cadenas if-else-if mediante anidamiento. `WhileStatementNode` modela bucles while con condición y cuerpo. `ForStatementNode` representa bucles for con componentes opcionales de inicialización, condición y actualización además del cuerpo. `DoWhileStatementNode` modela bucles do-while donde el cuerpo se ejecuta antes de evaluar la condición.

`BlockStatementNode` agrupa múltiples sentencias en un bloque delimitado por llaves, esencial para cuerpos de estructuras de control con más de una sentencia. `ReturnStatementNode` representa retorno de función con valor opcional. `BreakStatementNode` y `ContinueStatementNode` representan las sentencias de control de flujo break y continue respectivamente, ambos sin atributos adicionales ya que no requieren operandos.

## 19.2 Patrón Visitor (ASTVisitor)

El patrón Visitor implementado en FlowCode permite separar los algoritmos que procesan el AST de la estructura de datos del árbol. Este diseño posibilita agregar nuevas operaciones (como diferentes formatos de salida o análisis adicionales) sin modificar las clases de nodos existentes.

### 19.2.1 Recorrido del AST

La interfaz `ASTVisitor<T>` define un método `visit` por cada tipo concreto de nodo en el AST. El parámetro genérico `T` permite que diferentes visitantes retornen diferentes tipos de resultado: un visitante de generación de código podría retornar `String`, mientras uno de análisis de tipos retornaría `DataType`.

La invocación sigue el patrón de doble despacho: cuando se llama `node.accept(visitor)`, el nodo invoca el método específico del visitante que corresponde a su tipo concreto. Por ejemplo, `IntegerLiteralNode.accept` invoca `visitor.visitIntegerLiteral(this)`. Este mecanismo garantiza que se ejecute el código apropiado para cada tipo de nodo sin necesidad de verificaciones de tipo explícitas.

La clase `DefaultASTVisitor<T>` proporciona implementaciones vacías (retornando null) de todos los métodos visit, permitiendo que visitantes concretos solo sobrescriban los métodos relevantes para su propósito. `TraversingASTVisitor` extiende el visitante por defecto agregando lógica para recorrer automáticamente los nodos hijos, útil para operaciones que deben procesar el árbol completo.

### 19.2.2 Generación de representación textual

Cada nodo implementa el método `toTreeString` que genera una representación textual indentada del subárbol, invaluable para depuración durante el desarrollo del conversor. El parámetro `indent` controla el nivel de indentación, incrementándose en cada nivel de profundidad.

Para nodos simples como literales, la salida es una sola línea descriptiva: `IntegerLiteral(42)` o `Identifier(suma)`. Para nodos compuestos, la salida incluye el tipo de nodo seguido de sus hijos indentados. Por ejemplo, una expresión binaria produce:

```
BinaryExpr(+)
  Identifier(a)
  IntegerLiteral(5)
```

La utilidad `NodeCollector<T>` demuestra el poder del patrón Visitor: permite recolectar todos los nodos de un tipo específico en el árbol. Extendiendo `TraversingASTVisitor`, recorre automáticamente todo el árbol y agrega a una lista cada nodo que coincide con el tipo genérico T. Esta funcionalidad es útil para operaciones como contar el número de variables utilizadas o encontrar todas las llamadas a función en un programa.

La estructura del nodo raíz `ProgramNode` contiene dos listas: `globalDeclarations` para declaraciones de variables globales, y `diagramNodes` para los nodos AST correspondientes a cada nodo del diagrama de flujo. La clase `DiagramASTNode` actúa como contenedor intermedio que preserva la información del nodo de diagrama original (identificador, tipo, etiqueta) junto con las sentencias AST generadas a partir de su contenido textual. Esta organización mantiene la trazabilidad entre el diagrama visual y la representación intermedia, permitiendo que los mensajes de error señalen no solo la posición en el texto sino también el símbolo específico del diagrama donde se originó el problema.
