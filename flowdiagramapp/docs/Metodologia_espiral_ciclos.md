La selección del modelo en espiral para el desarrollo de FlowCode se basa en factores específicos del contexto de un Trabajo Terminal individual:

- Desarrollo  individual: Permite  ajustar el  alcance  y  prioridades  sin  coordinación con equipo externo
- Recursos limitados: Facilita la gestión eficiente del tiempo disponible (dos semestres académico)
- Aprendizaje progresivo: Permite adquirir conocimientos técnicos específicos conforme se necesiten
- Validación incremental: Cada ciclo produce un resultado tangible que valida decisiones técnicas
- Gestión de riesgos personal: Identifica tempranamente problemas técnicos que podrían comprometer el proyecto

8\.2  Ciclos Planificados

El desarrollo de FlowCode se estructurará en siete ciclos principales, cada uno con objetivos específicos y entregables realistas para un desarrollador individual. La planificación considera las limitaciones de tiempo y recursos de un Trabajo Terminal.

Ciclo 1: Definición y Viabilidad (Agosto - Septiembre 2025)

Este ciclo inicial establece las bases del proyecto mediante investigación y definición clara del alcance técnico viable.

Objetivos del Ciclo 1:

- Completar investigación bibliográfica enfocada en lo esencial
- Definir requisitos funcionales principales (sin exhaustividad)
- Establecer arquitectura simple y práctica del sistema
- Seleccionar tecnología de desarrollo definitiva
- Identificar riesgos críticos del proyecto
- Crear documentación base mínima necesaria

Entregables del Ciclo 1:

- Investigación bibliográfica con 15-20 fuentes relevantes
- Lista de requisitos funcionales prioritarios (10-15 requisitos clave)
- Diagrama de arquitectura simple con 3-4 componentes principales
- Decisión técnica justificada (Flutter vs React Native)
- Lista de 5-7 riesgos principales con mitigaciones básicas

Ciclo 2: Diseño de Interfaz (Septiembre - Octubre 2025)

El segundo ciclo se concentra en diseñar la interfaz básica necesaria para que la aplicación sea usable.

Objetivos del Ciclo 2:

- Crear sketches y wireframes básicos de pantallas principales
- Implementar la estructura de navegación de la aplicación
- Configurar el entorno de desarrollo completo
- Desarrollar la pantalla principal y menús básicos
- Establecer el sistema de colores y tipografía

Entregables del Ciclo 2:

- Wireframes de 4-5 pantallas principales
- Aplicación con navegación básica funcional
- Entorno de desarrollo configurado y operativo
- Paleta de colores y guía de estilo básica

Ciclo 3: Editor de Diagramas (Octubre - Diciembre 2025)

Este ciclo desarrolla el núcleo funcional de la aplicación: el editor visual completo y el primer componente del convertidor de diagramas (análisis estructural del grafo).

Objetivos del Ciclo 3:

- Implementar canvas de renderizado para dibujo de diagramas  
- Crear funcionalidad para agregar símbolos ISO 5807 (inicio/fin, proceso, decisión, E/S, bucles, conectores)  
- Implementar sistema de conexiones entre nodos con routing inteligente  
- Desarrollar gestos táctiles: zoom, pan, selección múltiple, undo/redo  
- Implementar sistema de guardado y carga de diagramas con serialización JSON  

Desarrollar Fase 1 del transpilador: Análisis Estructural del Grafo

- Implementar algoritmos BFS para análisis de alcanzabilidad desde nodo INICIO  
- Implementar algoritmos DFS para detección de ciclos en estructuras de bucle  
- Desarrollar 14 validaciones estructurales (E-SYN-01 a E-SYN-14)  
- Integrar sistema de reporte de errores visuales en tiempo real

Entregables del Ciclo 3:

- Editor visual de diagramas de flujo completamente funcional con interfaz táctil optimizada  
- Biblioteca de símbolos ISO 5807: 7 tipos de símbolos (inicio, fin, proceso, decisión, E/S, bucles, conectores)  
- Sistema de conexiones con routing automático e inteligente entre nodos  
- Gestos táctiles implementados: zoom  con pinch,  pan con arrastre, selección múltiple, undo/redo  
- Sistema de persistencia local con serialización/deserialización JSON de diagramas  
- Exportación de diagramas en formato PNG e imagen

Desarrollar Fase 1 del transpilador: Análisis Estructural del Grafo

- Analizador estructural implementado con representación de grafo dirigido  
- Algoritmo BFS para validar alcanzabilidad de todos los nodos desde INICIO  
- Algoritmo DFS para detectar ciclos y validar estructuras de bucle  
- 14 validaciones estructurales E-SYN implementadas:  
  - E-SYN-01: Exactamente un nodo INICIO
  - E-SYN-02: Al menos un nodo FIN
  - E-SYN-03: Todos los nodos alcanzables desde INICIO
  - E-SYN-04: Todos los caminos terminan en FIN
  - E-SYN-05: Detección de nodos desconectados
  - E-SYN-06: Nodos de decisión con exactamente 2 salidas
  - E-SYN-07 a E-SYN-14: Validaciones de bucles, conectores y continuidad de flujo
- Sistema de visualización de errores integrado al editor

Ciclo 4: Motor de Análisis (Enero - Febrero 2025)

El cuarto ciclo implementa las primeras tres fases del transpilador fuente-a-fuente: análisis léxico, análisis sintáctico y análisis semántico. El pipeline de compilación se coordina mediante la clase DiagramCompilerPipeline, que orquesta las cinco fases secuenciales del conversor. Este ciclo también desarrolla la tabla de símbolos y el sistema de errores del compilador.

Objetivos del Ciclo 4:

Arquitectura del Compilador (Tema 16):

- Diseñar e implementar el pipeline de compilación con 5 fases secuenciales  
- Desarrollar la clase DiagramCompilerPipeline como orquestador central  
- Implementar opciones de compilación configurables (CompilerOptions)  

Fase 1: Implementar análisis léxico (DiagramLexicalAnalyzer)

- Desarrollar el sistema de tokens (TokenType) con aproximadamente 80 tipos diferentes  
- Implementar tokenización del contenido textual de cada nodo del diagrama  
- Reconocer identificadores, literales, palabras reservadas (C y español), operadores y delimitadores  
- Construir la versión inicial de la tabla de símbolos durante el análisis  

Fase 2: Implementar análisis sintáctico (DiagramSyntaxAnalyzer)

- Desarrollar parser de descenso recursivo para expresiones C  
- Implementar parser para expresiones aritméticas (+, -, \*, /, %)  
- Implementar parser para expresiones lógicas (&&, ||, !) y relacionales (<, >, <=, >=, ==, !=)  
- Construir el Árbol de Sintaxis Abstracta (AST) con ProgramNode como raíz  
- Integrar parser con editor visual para validación en tiempo de edición  

Fase 3: Implementar análisis semántico (DiagramSemanticAnalyzer)

- Implementar verificación de tipos (DataType) para operaciones y asignaciones  
- Desarrollar análisis de alcance (ScopeAnalysisResult) para variables  
- Implementar detección de variables no declaradas  
- Desarrollar análisis de flujo de datos para detectar variables no inicializadas  
- Crear sistema de detección de errores semánticos con mensajes descriptivos  

Tabla de Símbolos (Tema 17):

- Implementar la clase SymbolTable con estructura de datos para identificadores  
- Desarrollar la clase SymbolInfo con atributos (nombre, tipo, categoría, ubicación, estado)  
- Implementar tipos de datos soportados (DataType): integer, float, double, char, string, boolean  
- Desarrollar gestión de alcances con ámbitos global y local  
- Implementar métodos de búsqueda y resolución de símbolos (lookup, declareSymbol)  
- Agregar especificadores de formato para printf/scanf y valores por defecto en C  

Sistema de Errores (Tema 18):

- Implementar clasificación de errores (CompilerErrorCode) por fase  
- Definir errores léxicos (códigos 1001-1010): caracteres inesperados, cadenas sin cerrar, etc.  
- Definir errores sintácticos (códigos 2001-2010): tokens inesperados, paréntesis desbalanceados, etc.  
- Definir errores semánticos (códigos 3001-3011): variables no declaradas, tipos incompatibles, etc.  
- Implementar niveles de severidad (CompilerSeverity): info, warning, error, fatal  
- Desarrollar identificación de fases de compilación (CompilerPhase)  

Entregables del Ciclo 4:

- DiagramLexicalAnalyzer funcional con sistema de tokens completo  
- DiagramSyntaxAnalyzer con parser de descenso recursivo  
- DiagramSemanticAnalyzer con verificación de tipos y alcances  
- Tabla de símbolos (SymbolTable) con soporte para alcances anidados  
- Sistema de errores estructurado con clasificación por tipo, severidad y fase  
- Reportes de compilación (CompilationResult) con métricas de análisis  
- Suite de pruebas unitarias para cada analizador (léxico, sintáctico, semántico)  
- Integración completa con editor visual para feedback en tiempo real  
- Informe técnico del Ciclo 4 documentando la arquitectura del compilador

Ciclo 5: Generador de Código (Febrero - Abril 2025)

Este ciclo implementa las Fases 4 y 5 del transpilador: optimización del AST y generación de código C. El AST construido en el Ciclo 4 sirve como representación intermedia, la cual se optimiza antes de traducirse a código C funcional compatible con el estándar C99.

Objetivos del Ciclo 5:

Nodos del Árbol de Sintaxis Abstracta (Tema 19):

- Implementar la jerarquía completa de nodos AST con clase base ASTNode  
- Desarrollar nodos literales (IntegerLiteralNode, FloatLiteralNode, StringLiteralNode, CharLiteralNode, BooleanLiteralNode)  
- Implementar nodos de expresión (BinaryExpressionNode, UnaryExpressionNode, AssignmentExpressionNode, IdentifierNode, FunctionCallNode)  
- Desarrollar nodos de sentencia (DeclarationStatementNode, IfStatementNode, WhileStatementNode, ForStatementNode, BlockStatementNode, InputStatementNode, OutputStatementNode)  
- Implementar el patrón Visitor (ASTVisitor) para recorrido y procesamiento del AST  
- Desarrollar generación de representación textual del AST para depuración  

Fase 4: Optimización del AST (Tema 20):

- Implementar DiagramCodeOptimizer con cuatro niveles de optimización (none, basic, standard, aggressive)  
- Desarrollar configuración del optimizador (OptimizerConfig) con parámetros ajustables  
- Implementar plegado de constantes (Constant Folding) para evaluar expresiones literales  
- Implementar eliminación de código muerto (Dead Code Elimination) para ramas inalcanzables  
- Desarrollar simplificación de expresiones usando identidades algebraicas (x+0=x, x*1=x, x-x=0)  
- Implementar métricas de optimización (OptimizationMetrics) para reportar transformaciones aplicadas  

Fase 5: Generación de Código C (Tema 21):

- Implementar AdvancedCodeGenerator con opciones configurables (CodeGenOptions)  
- Desarrollar algoritmo de orden de ejecución basado en recorrido BFS del grafo  
- Implementar traducción de nodos terminales (Inicio → main(), Fin → return 0)  
- Desarrollar generación de nodos de proceso (declaraciones, asignaciones, expresiones)  
- Implementar generación de nodos de decisión (if/else, switch)  
- Desarrollar generación de nodos de preparación (for, while, do-while)  
- Implementar generación de nodos de datos (scanf/printf con especificadores de formato correctos)  
- Desarrollar generación de encabezados estándar (stdio.h, stdlib.h, string.h, math.h) según necesidad  
- Implementar formateador automático de código con indentación configurable  

Entregables del Ciclo 5:

- Jerarquía completa de nodos AST implementada en ast_nodes.dart (~1305 líneas)  
- Patrón Visitor (ASTVisitor, DefaultASTVisitor, TraversingASTVisitor) para procesamiento del AST  
- DiagramCodeOptimizer con 4 niveles de optimización y múltiples pasadas iterativas  
- Técnicas de optimización implementadas: constant folding, eliminación de código muerto, simplificación algebraica  
- AdvancedCodeGenerator funcional que produce código C99 compilable  
- Mapeo completo de símbolos ISO 5807 a construcciones C:  
  - Terminal (Inicio) → int main(void) {  
  - Terminal (Fin) → return 0; }  
  - Proceso → declaraciones, asignaciones  
  - Datos → scanf(), printf()  
  - Decisión → if-else, switch  
  - Preparación → for, while, do-while  
  - Proceso Predefinido → llamadas a función  
- Generación automática de especificadores de formato según tipo de variable (%d, %f, %lf, %c, %s)  
- Visor de código integrado al editor con syntax highlighting para C  
- Suite de pruebas del generador de código (code_generator_advanced_test.dart)  
- Informe técnico del Ciclo 5 documentando la arquitectura del AST, optimizador y generador

Alcance del lenguaje objetivo:

- Soportado: Tipos primitivos (int, float, double, char, string, bool), E/S estándar (scanf/printf), estructuras de control (if/else, while, for, do-while), variables locales, expresiones aritméticas/lógicas/relacionales, operadores de asignación compuesta  
- Excluido del alcance: Punteros, estructuras (struct), memoria dinámica (malloc/free), funciones múltiples definidas por usuario, recursión, arrays multidimensionales

Ciclo 6: Integración (Abril - Mayo 2025)

El sexto ciclo integra todas las fases del transpilador en un pipeline completo y funcional, conectando el compilador con el editor visual e implementando el flujo de inicio a fin desde la creación del diagrama hasta la generación de código C compilable. También se desarrolla la suite completa de pruebas de integración.

Objetivos del Ciclo 6:

- Implementar mapeo completo de 6 símbolos ISO 5807 a código C:  
  - Terminal (Inicio) → int main(void) { ... }  
  - Terminal (Fin) → return 0; }  
  - Proceso → declaraciones, asignaciones, expresiones  
  - Decisión → if/else, switch/case  
  - Preparación → for, while, do-while  
  - Datos → printf(), scanf() con especificadores automáticos  
  - Proceso Predefinido → llamadas a funciones  
- Soportar símbolos adicionales para documentación visual (conectores, comentarios, documentos)  

Pruebas de Integración (Tema 23):

- Desarrollar suite completa de pruebas del compilador:  
  - lexical_analyzer_test.dart: 40+ tests para análisis léxico  
  - syntax_analyzer_test.dart: 84 tests para análisis sintáctico  
  - semantic_analyzer_test.dart: 43 tests para análisis semántico  
  - code_generator_advanced_test.dart: 25+ tests para generación de código  
  - compiler_integration_test.dart: 33 tests de integración end-to-end  
- Implementar validación de código generado:  
  - Verificar compilabilidad con GCC  
  - Validar correctitud funcional del código  
- Establecer trazabilidad entre casos de uso (CU01-CU10) y pruebas implementadas  

Entregables del Ciclo 6:

- Pipeline DiagramCompilerPipeline completamente integrado y funcional  
- Integración UI-Compilador mediante FloatingToolbar con botón de compilación  
- CompilerResultsDialog con 6 pestañas para visualización de resultados:  
  - Resumen: métricas generales (nodos, tokens, símbolos, errores, tiempo)  
  - Léxico: tokens extraídos por nodo  
  - AST: árbol de sintaxis abstracta generado  
  - Semántico: tabla de símbolos y errores semánticos  
  - Optimización: transformaciones aplicadas  
  - Código: código C generado con syntax highlighting  
- Sistema de visualización de errores con colores según severidad:  
  - Fatal (rojo oscuro): detiene compilación  
  - Error (rojo): impide generar código  
  - Warning (naranja): código generado con advertencias  
  - Info (azul): información adicional  
- Mapeo completo de símbolos ISO 5807 implementado con tabla de correspondencias  
- Suite de pruebas de integración: 8 archivos, ~4,648 líneas, 240+ tests  
- Cobertura de 10 casos de uso documentados con trazabilidad a pruebas  
- Validación de código generado con compilación GCC exitosa  
- Informe técnico del Ciclo 6 documentando la integración y pruebas

Ciclo 7: Pruebas y Documentación (Mayo - Junio 2025)

El último ciclo muestra la validación del sistema completo, documenta los resultados de pruebas funcionales, de rendimiento y robustez, evalúa el cumplimiento de los criterios de éxito establecidos en la metodología espiral, e identifica las limitaciones del sistema.

Objetivos del Ciclo 7:

- Definir criterios de validación técnica objetivos y medibles
- Ejecutar suite completa de pruebas funcionales del compilador
- Medir métricas de rendimiento y escalabilidad
- Validar robustez ante entradas problemáticas
- Evaluar cumplimiento de criterios de éxito del proyecto
- Documentar limitaciones identificadas durante la validación

Entregables del Ciclo 7:

- Manual de usuario
- Documentación técnica
