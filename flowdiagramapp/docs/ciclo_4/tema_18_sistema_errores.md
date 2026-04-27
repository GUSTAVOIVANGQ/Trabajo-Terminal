# 18. Sistema de Errores del Conversor

El sistema de errores de FlowCode representa un componente crítico que proporciona retroalimentación significativa al usuario durante el proceso de conversión. Implementado en el archivo `compiler_errors.dart` con aproximadamente 837 líneas de código, este sistema adopta un enfoque estructurado que clasifica los errores por tipo, severidad y fase de conversión, permitiendo mensajes precisos y sugerencias de corrección contextuales.

## 18.1 Clasificación de Errores (CompilerErrorCode)

La enumeración `CompilerErrorCode` define un catálogo exhaustivo de errores organizados por la fase de conversión donde pueden ocurrir. Cada código de error posee un identificador numérico único que facilita la documentación, búsqueda y referencia en reportes de problemas.

### 18.1.1 Errores léxicos

Los errores léxicos (códigos 1001-1010) se detectan durante la primera fase de conversión cuando el analizador léxico procesa el contenido textual de los nodos del diagrama para producir tokens. Estos errores indican problemas a nivel de caracteres y formación de unidades léxicas básicas.

El error `unexpectedCharacter` (1001) se genera cuando el analizador encuentra un carácter que no corresponde a ningún token válido del lenguaje, como símbolos especiales no soportados o caracteres de control inesperados. El error `unterminatedString` (1002) ocurre cuando una cadena de texto comienza con comillas pero no tiene las comillas de cierre correspondientes. Similarmente, `unterminatedComment` (1003) indica un comentario que nunca fue cerrado, aplicable cuando se implementen comentarios multilínea.

Los errores `invalidNumber` (1004) e `invalidIdentifier` (1005) señalan secuencias de caracteres que no conforman números o identificadores válidos respectivamente. Por ejemplo, un número con múltiples puntos decimales o un identificador que comienza con un dígito. El error `invalidEscapeSequence` (1006) detecta secuencias de escape no reconocidas dentro de cadenas o caracteres literales, como `\z` que no tiene significado en C.

Para literales numéricos, `numberOverflow` (1007) indica que el valor excede el rango representable del tipo. Los errores `emptyCharLiteral` (1008) y `multiCharacterLiteral` (1009) tratan casos específicos de literales de carácter malformados. Finalmente, `invalidFormatSpecifier` (1010) detecta especificadores de formato incorrectos en cadenas de printf/scanf.

### 18.1.2 Errores sintácticos

Los errores sintácticos (códigos 2001-2010) emergen durante el análisis sintáctico cuando la secuencia de tokens no conforma una estructura gramatical válida. Estos errores son los más comunes durante el aprendizaje de programación.

El error `unexpectedToken` (2001) es el más frecuente y se genera cuando el parser encuentra un token en una posición donde no es gramaticalmente válido. El mensaje incluye tanto el token encontrado como el token esperado cuando es posible determinarlo. El error complementario `missingToken` (2002) indica la ausencia de un token requerido por la gramática.

Los errores de balanceo (`unbalancedParentheses` 2003, `unbalancedBraces` 2004, `unbalancedBrackets` 2005) detectan desbalances en los delimitadores pareados. El parser mantiene una pila para rastrear los delimitadores abiertos y genera estos errores cuando encuentra un delimitador de cierre sin su correspondiente apertura, o cuando al finalizar el análisis quedan delimitadores sin cerrar.

**[Imagen sugerida: Ejemplo visual de expresión con paréntesis desbalanceados y su mensaje de error]**

El error `invalidExpression` (2006) cubre casos generales de expresiones malformadas que no encajan en categorías más específicas. `MissingSemicolon` (2007) detecta la ausencia del punto y coma que termina las sentencias, un error extremadamente común entre principiantes. Los errores `invalidAssignment` (2008), `invalidDeclaration` (2009) e `invalidStatement` (2010) cubren malformaciones en asignaciones, declaraciones de variables y sentencias generales respectivamente.

### 18.1.3 Errores semánticos

Los errores semánticos (códigos 3001-3011) se detectan durante el análisis semántico cuando el código es sintácticamente correcto pero viola reglas de significado del lenguaje. Estos errores requieren información de contexto como la tabla de símbolos.

El error `undeclaredVariable` (3001) ocurre cuando se intenta usar una variable que no ha sido declarada previamente, uno de los errores más comunes entre estudiantes. El error opuesto, `duplicateDeclaration` (3002), se genera cuando se intenta declarar una variable que ya existe en el mismo alcance.

El error `typeMismatch` (3003) indica incompatibilidad de tipos en una operación, como intentar asignar una cadena a una variable entera. El error relacionado `invalidOperation` (3004) señala operaciones no soportadas para los tipos involucrados, como aplicar el operador módulo a números de punto flotante.

Los errores `uninitializedVariable` (3005) y `unusedVariable` (3006) son advertencias que ayudan a detectar errores lógicos. El primero indica uso de una variable que podría no tener valor asignado, mientras el segundo detecta variables declaradas que nunca se utilizan, posible indicador de código muerto o errores de nombre.

El error `invalidTypeConversion` (3007) detecta conversiones de tipo que perderían información o no son posibles. El error `divisionByZero` (3008) puede detectarse en tiempo de conversión cuando el divisor es una constante cero. El error `invalidArrayIndex` (3009) señala índices de arreglo que no son enteros. Finalmente, `outOfScope` (3010) indica acceso a una variable fuera de su alcance válido, y `unknownFunction` (3011) una llamada a función no reconocida.

## 18.2 Severidad y Fases

El sistema distingue claramente entre diferentes niveles de gravedad y las fases donde pueden originarse los errores, permitiendo al usuario entender el impacto del problema y la etapa de conversión afectada.

### 18.2.1 Niveles de severidad (CompilerSeverity)

La enumeración `CompilerSeverity` define cuatro niveles de severidad que determinan cómo el conversor y la interfaz de usuario tratan cada mensaje:

| Severidad | Prefijo   | Emoji | Comportamiento del conversor |
|-----------|-----------|-------|-------------------------------|
| info      | INFO      | ℹ️    | Mensaje informativo, conversión continúa normalmente |
| warning   | WARNING   | ⚠️    | Advertencia, conversión continúa pero se recomienda revisión |
| error     | ERROR     | ❌    | Error que puede causar falla en la conversión |
| fatal     | FATAL     | 🛑    | Error crítico, conversión se detiene inmediatamente |

Los mensajes de nivel `info` proporcionan información útil que no indica problemas, como confirmar el uso de características específicas o sugerencias de mejora. Las advertencias (`warning`) señalan situaciones potencialmente problemáticas que no impiden la generación de código pero podrían indicar errores lógicos, como variables no utilizadas o conversiones de tipo implícitas.

Los errores (`error`) representan violaciones de las reglas del lenguaje que normalmente impedirían generar código correcto. Sin embargo, el conversor de FlowCode intenta recuperarse y continuar el análisis para detectar errores adicionales, proporcionando una lista más completa al usuario en lugar de detenerse en el primer problema. Los errores fatales (`fatal`) representan situaciones donde la conversión no puede continuar de ninguna manera, como la ausencia del nodo de inicio en el diagrama.

### 18.2.2 Fases de conversión (CompilerPhase)

La enumeración `CompilerPhase` identifica la etapa del proceso de conversión donde se originó un mensaje. Esta información ayuda al usuario a comprender el contexto del error y es útil para diagnóstico y depuración del propio conversor.

Las seis fases definidas son: validación estructural (`structural`), análisis léxico (`lexical`), análisis sintáctico (`syntactic`), análisis semántico (`semantic`), optimización (`optimization`) y generación de código (`codeGen`). La extensión `CompilerPhaseExtension` proporciona nombres legibles tanto en español (`displayName`) como en inglés (`englishName`) para cada fase.

La fase estructural corresponde a la validación del grafo del diagrama antes de analizar el contenido de los nodos (errores códigos 4xxx). Esta validación verifica propiedades topológicas como la existencia de exactamente un nodo de inicio y al menos un nodo de fin, la conectividad de todos los nodos, y la ausencia de ciclos infinitos sin condición de salida.

## 18.3 Reportes de Conversión

El sistema de errores proporciona estructuras de datos especializadas para crear reportes comprensivos que pueden presentarse al usuario a través de la interfaz gráfica.

### 18.3.1 CompilationResult y métricas

La clase `CompilerError` representa un error individual con toda su información asociada. Los atributos incluyen el código de error, severidad, fase, mensaje legible, ubicación en el código fuente (implementada mediante la clase `SourceLocation`), el texto problemático que causó el error, y una sugerencia de cómo corregirlo.

La clase `SourceLocation` encapsula la información de ubicación incluyendo línea, columna, offset desde el inicio del texto, y opcionalmente el identificador y nombre del nodo del diagrama. El método `toString` genera representaciones legibles como "nodo 'Cálculo', línea 3, columna 15" o simplemente "línea 3, columna 15" cuando no hay información del nodo.

**[Imagen sugerida: Captura de pantalla mostrando cómo se visualizan los errores en la interfaz de FlowCode]**

El sistema proporciona factory methods especializados para crear errores de cada fase. Las clases `LexicalError` y `SyntaxError` extienden `CompilerError` y proporcionan constructores de conveniencia para errores comunes con mensajes y sugerencias predefinidos. Por ejemplo, `LexicalError.unexpectedCharacter(char, location)` genera automáticamente el mensaje "Carácter inesperado: [char]" con la sugerencia "Verifica que el carácter sea válido en este contexto".

La clase `CompilerErrorCollection` actúa como contenedor para múltiples errores y proporciona métodos de consulta y filtrado. El método `getBySeverity` retorna errores de una severidad específica, mientras `getByPhase` filtra por fase de conversión. Las propiedades `hasErrors` y `hasFatalErrors` permiten verificar rápidamente si la conversión fue exitosa. Las propiedades `errorCount` y `warningCount` proporcionan conteos separados.

El método `summary` genera un resumen legible del estado de conversión, retornando "✅ Sin errores ni advertencias" cuando no hay problemas, o un conteo como "3 errores, 2 advertencias" cuando existen. Este resumen es ideal para mostrar en la interfaz de usuario como indicador rápido del resultado de la conversión.

Los errores pueden serializarse a formato JSON mediante el método `toJson`, facilitando el almacenamiento de reportes, la comunicación con sistemas externos, o la implementación de análisis de patrones de errores comunes entre usuarios. La serialización incluye todos los atributos del error en un formato estructurado que puede reconstruirse posteriormente.

El diseño del sistema de errores prioriza la experiencia educativa. Cada error incluye no solo la descripción del problema sino también una sugerencia constructiva de cómo resolverlo, ayudando a los estudiantes a aprender de sus errores en lugar de simplemente señalarlos. Los mensajes están redactados en español para facilitar la comprensión de usuarios hispanohablantes, con la posibilidad de extensión a otros idiomas mediante el sistema de extensiones de las enumeraciones.
