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

El  cuarto  ciclo  implementa  las  Fases  2  y  3  del  transpilador,  enfocándose  en  el  parsing  de expresiones C contenidas dentro de los símbolos del diagrama y la validación semántica mediante tabla de símbolos. A diferencia de un compilador tradicional, FlowCode omite el análisis léxico ya que los símbolos ISO 5807 son tokens visuales directos.

Objetivos del Ciclo 4:

Fase 2: Implementar análisis sintáctico de expresiones C

- Desarrollar parser para expresiones aritméticas (+, -, \*, /, %)  
- Implementar parser para expresiones lógicas (&&, ||, !)  
- Implementar parser para expresiones relacionales (<, >, <=, >=, ==, !=)  
- Desarrollar 7 validaciones sintácticas de expresiones (E-EXP-01 a E-EXP-07)  
- Integrar parser con editor visual para validación en tiempo de edición  

Fase 3: Implementar análisis semántico

- Construir tabla de símbolos para rastrear variables declaradas y sus tipos  
- Desarrollar análisis de flujo de datos (reaching definitions) para detectar variables no iializadas  
- Implementar 10 reglas semánticas (S01-S10) para validación de tipos y alcances  
- Desarrollar sistema de detección de errores semánticos con mensajes descriptivos  
- Crear suite de 50 casos de prueba de validación semántica

Entregables del Ciclo 4:

- Parser de expresiones C funcional para expresiones aritméticas, lógicas y relacionales  
- 7  validaciones  sintácticas  E-EXP  implementadas  (paréntesis  balanceados,  operadores válidos, identificadores correctos)  
- Tabla de símbolos implementada con soporte para alcances locales  
- Algoritmo de reaching definitions para análisis de flujo de datos  
- reglas semánticas S01-S10 implementadas:  
  - S01: Variables declaradas antes de uso
  - S02: No redeclaración de variables en mismo alcance
  - S03: Compatibilidad de tipos en asignaciones
  - S04: Compatibilidad de tipos en expresiones aritméticas
  - S05: Expresiones booleanas en condiciones
  - S06-S10: Validaciones adicionales de inicialización y alcance
- Sistema de detección de variables no inicializadas antes de lectura  
- Integración completa con editor visual para feedback en tiempo real  
- Suite  de  50  casos  de  prueba  de  validación  semántica  (variables  no  declaradas,  tipos incompatibles, no inicializadas)  
- Informe técnico del Ciclo 4 documentando el diseño del parser y la tabla de símbolos

Ciclo 5: Generador de Código (Febrero - Abril 2025)

Este ciclo implementa las Fases 4 y 5 del transpilador, desarrollando la representación intermedia del diagrama validado y el generador que produce código C funcional y compilable. El código generado debe ser compatible con GCC/Clang y cumplir con el estándar C89/C99 básico.

Objetivos del Ciclo 5:

` `Fase 4: Desarrollar representación intermedia (RI)

- Diseñar esquema JSON para representar el grafo anotado con información semántica  
- Implementar  traductor  de  diagrama  validado  a  RI  preservando  toda  la  información necesaria  
- Validar serialización y deserialización de la RI  

Fase 5: Implementar generador de código C

- Desarrollar generador de declaraciones de variables (int, float, char)  
- Implementar generación de estructuras de control (if/else, anidamiento)  
- Implementar generación de bucles (while, for, do-while)  
- Desarrollar generación de entrada/salida estándar (scanf, printf con formatos correctos)  
- Crear formateador automático de código con indentación apropiada  
- Implementar visor de código con syntax highlighting  
- Validar código generado mediante compilación automática con GCC/Clang  
- Crear suite de 15 casos de prueba con diagramas de complejidad creciente

Entregables del Ciclo 5:

- Esquema de representación intermedia basado en JSON documentado completamente  
- Traductor de diagrama a RI que preserva información estructural, sintáctica y semántica  
- Generador de código C funcional que produce programas compilables  
- Generador de declaraciones de variables con tipos int, float, char  
- Generador de estructuras de control if/else con soporte para anidamiento  
- Generador de bucles while, for y do-while  
- Generador de operaciones de E/S estándar: scanf con formatos correctos (%d, %f, %c) y printf  
- Formateador automático que produce código con indentación estándar de 4 espacios  
- Visor de código integrado al editor con syntax highlighting para C  
- Suite de 15 casos de prueba validados con compilación automática en GCC/Clang:  
  - 5 algoritmos básicos secuenciales
  - 5 algoritmos con condicionales
  - 5 algoritmos con bucles
- Documentación del mapeo Diagrama → RI → Código C  
- Informe técnico del Ciclo 5 documentando el proceso de generación de código

Alcance del lenguaje objetivo:

- Soportado: Tipos primitivos (int, float, char), E/S estándar (scanf/printf), estructuras de control (if/else, while, for), variables locales, expresiones aritméticas/lógicas/relacionales
- Excluido del alcance: Punteros, estructuras (struct), memoria dinámica (malloc/free), funciones múltiples, recursión, arrays multidimensionales (estos conceptos exceden las capacidades  de  representación  del  estándar  ISO  5807  y  la  complejidad  de  análisis semántico factible en el plazo del trabajo terminal)

Ciclo 6: Integración (Abril - Mayo 2025)

El  sexto  ciclo  integra  todas  las  fases  del  transpilador  en  un  pipeline  completo  y  funcional, implementando el flujo de inicio a fin desde la creación del diagrama hasta la exportación de código compilable. Se realizan optimizaciones de rendimiento y se validan las métricas técnicas establecidas en el protocolo.

Objetivos del Ciclo 6:

- Integrar las 5 fases del transpilador en pipeline completo: Análisis Estructural → Análisis Sintáctico → Análisis Semántico → Representación Intermedia → Generación de Código  
- Implementar flujo completo: crear diagrama → validar → generar código → exportar  
- Optimizar rendimiento del motor de traducción para diagramas de 50+ nodos  
- Desarrollar sistema de exportación de código como archivos .c y .txt  
- Realizar pruebas de integración de inicio a fin con casos reales  
- Corregir errores críticos identificados durante la integración  
- Validar métricas técnicas establecidas en el protocolo:  
  - Precisión del transpilador: ≥95% de diagramas válidos generan código compilable
  - Sensibilidad de detección de errores: ≥90%
  - Tiempo de generación de código: <5 segundos para algoritmos de complejidad media

Entregables del Ciclo 6:

- Pipeline completo implementado y funcional con las 5 fases integradas  
- Sistema de exportación de código como archivos .c (código fuente) y .txt (texto plano)  
- Interfaz de usuario para controlar el proceso completo de traducción  
- Suite de pruebas de integración end-to-end con 20 casos reales de uso  
- Optimizaciones de rendimiento del motor:  
- Caché de resultados de validación
- Procesamiento incremental de cambios en el diagrama
- Optimización de estructuras de datos del grafo
- Validación de métricas técnicas con reporte detallado:  

  𝐷𝑖𝑎𝑔𝑟𝑎𝑚𝑎𝑠 𝑣á𝑙𝑖𝑑𝑜𝑠 𝑞𝑢𝑒 𝑔𝑒𝑛𝑒𝑟𝑎𝑛 𝑐ó𝑑𝑖𝑔𝑜 𝑐𝑜𝑚𝑝𝑖𝑙𝑎𝑏𝑙𝑒 𝑃𝑟𝑒𝑐𝑖𝑠𝑖ó𝑛  =      × 100

𝑇𝑜𝑡𝑎𝑙 𝑑𝑖𝑎𝑔𝑟𝑎𝑚𝑎𝑠 𝑣á𝑙𝑖𝑑𝑜𝑠

𝐸𝑟𝑟𝑜𝑟𝑒𝑠 𝑑𝑒𝑡𝑒𝑐𝑡𝑎𝑑𝑜𝑠 𝑐𝑜𝑟𝑟𝑒𝑐𝑡𝑎𝑚𝑒𝑛𝑡𝑒 𝑆𝑒𝑛𝑠𝑖𝑏𝑖𝑙𝑖𝑑𝑎𝑑  =      × 100

𝑇𝑜𝑡𝑎𝑙 𝑒𝑟𝑟𝑜𝑟𝑒𝑠 𝑟𝑒𝑎𝑙𝑒𝑠

- Corrección de errores críticos de integración  
- Aplicación FlowCode completamente funcional lista para pruebas finales  
- Informe técnico del Ciclo 6 documentando la integración y métricas alcanzadas

Ciclo 7: Pulimiento y Documentación (Mayo - Junio 2025)

El ciclo final valida exhaustivamente el sistema completo mediante un banco extenso de casos de prueba,  verifica  el  cumplimiento  de  todas  las  métricas  técnicas  y  genera  la  documentación completa del proyecto para la entrega final.

Objetivos del Ciclo 7:

- Corregir bugs menores identificados
- Mejorar interfaz de usuario para presentación final
- Crear manual de usuario básico
- Preparar documentación técnica del código
- Crear presentación y demo para defensa

Entregables del Ciclo 7:

- Banco de 100 diagramas de prueba categorizados:  
- 30 algoritmos básicos (secuenciales, E/S simple)
- 40 algoritmos con condicionales (if-else simple, anidados, casos múltiples)
- 30 algoritmos con bucles (while, for, do-while, anidados)
- Script de automatización que:  
  - Genera código C para cada diagrama del banco
  - Compila automáticamente con GCC
  - Registra éxito/fallo de compilación
  - Ejecuta código generado con entradas de prueba predefinidas
  - Genera reporte estadístico de métricas
- Reporte de validación de métricas técnicas:  
  - Precisión del transpilador calculada y documentada
  - Sensibilidad de detección de errores calculada y documentada
  - Análisis de casos fallidos y mejoras implementadas
- Manual de usuario con:  
  - Guía de inicio rápido
  - Tutorial paso a paso de creación de diagramas
  - Explicación de mensajes de error
  - Ejemplos de diagramas comunes (suma, factorial, fibonacci, búsqueda)
- Documentación técnica que incluye:  
- Arquitectura completa del sistema en capas
- Descripción detallada de cada fase del transpilador
- Diagramas UML: clases, secuencia, componentes, despliegue
- Especificación de la gramática soportada
- Especificación de las 14 validaciones E-SYN
“FlowCode: Aplicación para la conversión de diagramas de flujo a código C estructurado para dispositivos móviles Android”   157 ![](Aspose.Words.f30bd684-d796-49cd-b335-10e30d5b4e53.001.png)![](Aspose.Words.f30bd684-d796-49cd-b335-10e30d5b4e53.002.png)
