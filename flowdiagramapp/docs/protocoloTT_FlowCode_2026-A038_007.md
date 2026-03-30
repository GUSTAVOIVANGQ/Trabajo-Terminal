**FlowCode: Aplicación para la conversión de diagramas de flujo a código C estructurado para dispositivos móviles Android** 

***Trabajo Terminal No.**  \
Alumnos: García Quiroz Gustavo Iván Directores:*  

*Ing. José Antonio Ortiz Ramírez Ing. Gabriel Hurtado Avilés* 

*e-mail: ggarciaq1800@alumno.ipn.mx* 

**Resumen –** El presente trabajo terminal propone el desarrollo de una aplicación móvil que permita a los usuarios diseñar algoritmos mediante diagramas de flujo en base a plantillas y traducirlos automáticamente a código en lenguaje C mediante un convertidor de código fuente a fuente. La herramienta está orientada a programadores, proporcionando una solución técnica que automatiza la transición entre el diseño algorítmico visual y la implementación en código. El sistema contará con un editor visual intuitivo para la creación de diagramas, un analizador para validar la estructura lógica, y un generador de código que producirá programas funcionales en C. Este proyecto busca cerrar la brecha entre la representación visual de algoritmos y su implementación  práctica,  sirviendo  como  herramienta  de  productividad  para  desarrollo  de  algoritmos  en plataformas móviles. 

**Palabras Clave –** Convertidor, Diagramas de Flujo, Aplicación Móvil, Lenguaje C, Programación Visual, Análisis Sintáctico, Análisis Semántico, Generación de Código. 

**1  Introducción**  

1. **Contexto y Antecedentes** 

La programación es una habilidad fundamental en la formación de ingenieros en sistemas computacionales. Tradicionalmente,  el  proceso  de  desarrollo  de  software  inicia  con  el  diseño  de  algoritmos  mediante representaciones visuales como los diagramas de flujo, para posteriormente implementarlos en un lenguaje de programación específico. Esta transición del diseño a la implementación representa un desafío significativo para estudiantes y programadores novatos, quienes deben dominar tanto los conceptos algorítmicos como la sintaxis específica del lenguaje de programación. 

Los diagramas de flujo han sido utilizados durante décadas como herramientas de especificación algorítmica que permiten representar visualmente la secuencia de operaciones de un algoritmo de manera independiente de un lenguaje de programación específico. Sin embargo, la conversión manual de estos diagramas a código fuente es propensa a errores y consume tiempo considerable, especialmente para algoritmos complejos. 

Esta  situación  motiva  el  desarrollo  de  herramientas  automatizadas  que  eliminen  el  proceso  manual, garantizando corrección en la traducción y reduciendo significativamente el tiempo de conversión. 

2. **Planteamiento del Problema** 

Aunque existen algunas herramientas que permiten crear diagramas de flujo en dispositivos móviles, estas presentan limitaciones significativas que impiden su uso efectivo como herramientas de conversión automática a código funcional. Las herramientas actuales disponibles para móviles como Draw.io y Lucidchart están diseñadas para diagramas generales y carecen de funcionalidades específicas para traducción automática a 

código, como la validación estructural de algoritmos o la generación de código ejecutable. Por otro lado, las herramientas especializadas en conversión de diagramas a código como Flowgorithm y Raptor están limitadas a entornos de escritorio, lo que restringe su accesibilidad para usuarios que dependen principalmente de dispositivos móviles. 

El problema técnico identificado es la ausencia de una aplicación móvil nativa que combine: 

- Editor visual táctil optimizado para dispositivos móviles 
- Sistema de validación automática de la estructura y semántica de diagramas de flujo 
- Motor de traducción que genere código C funcional y compatible 
- Operación sin necesidad de conexión a internet completa sin dependencia de servicios en la nube 

Esta  situación  limita  la  productividad  de  desarrolladores  y  estudiantes  de  programación  que  requieren herramientas portables para diseñar algoritmos visualmente y obtener su implementación en código C de manera automática y confiable, especialmente en contextos con conectividad limitada o durante sesiones de estudio/trabajo fuera de laboratorios. 

3. **Propuesta de Solución** 

Este trabajo terminal propone desarrollar "FlowCode", una aplicación móvil que permita a los usuarios crear diagramas de flujo mediante una interfaz táctil intuitiva y generar automáticamente código en lenguaje C a partir de estos diagramas. La herramienta incluirá funcionalidades de validación para detectar errores  de sintaxis,  una  representación  intermedia  para  garantizar  la  correcta  traducción,  y  un generador  de  código optimizado para producir programas funcionales y legibles. 

La solución propuesta busca facilitar el proceso de documentación y desarrollo de software, sirviendo como puente entre el diseño conceptual y la implementación práctica en un entorno móvil accesible. 

A continuación, se presentan herramientas similares: 



|**Nombre** |**Plataforma** |**Características principales** |**Limitaciones** |**Diferenciadores  de FlowCode** |
| - | - | :- | - | :- |
|**Flowgorithm** |Escritorio |Generación de código en varios  lenguajes, simulación paso a paso |No  disponible  en móviles,  interfaz  no optimizada para táctil |Movilidad,  interfaz táctil  nativa, optimización para C |
|**Raptor** |Escritorio |Editor  visual  simple, ejecución de diagramas |Solo  disponible  para Windows,  no  genera código en C |Multiplataforma móvil, generación  específica para C |
|**PSeInt** |Escritorio |Conversión  de pseudocódigo  a diagrama,  múltiples idiomas |No tiene editor visual directo,  no  es  para móviles |Editor  visual  táctil, enfoque  directo  en diagramas |
|**Draw.io** |Web/Móvil |Creación  de  diagramas generales |No genera código, no valida  lógica algorítmica |Validación  lógica, generación  de  código funcional |
|**Lucidchart** |Web/Móvil |Diagramas colaborativos en la nube |Generación de código limitada,  enfoque general |Enfoque  específico  en programación,  análisis semántico |

**Tabla 1**. Resumen de productos similares. 

La aplicación propuesta busca llenar este vacío ofreciendo una solución nativa para Android que combine la potencia de la creación de diagramas basada en código con una interfaz optimizada para dispositivos móviles, permitiendo a los usuarios crear, editar y compartir diagramas técnicos de manera eficiente y sin necesidad de conexión a internet. 

**2  Objetivo**  

Desarrollar una aplicación móvil nativa para Android que permita crear diagramas de flujo conforme al estándar ISO 5807 y traducirlos automáticamente a código C estructurado básico (variables, E/S, estructuras de control) funcional y compatible con GCC/Clang. 

**2.1  Objetivos específicos** 

- Diseñar e implementar una interfaz de usuario táctil que facilite la creación y edición de diagramas de flujo en dispositivos móviles. 
- Desarrollar un sistema de validación que verifique la estructura sintáctica y semántica de los diagramas creados, identificando errores y ambigüedades. 
- Implementar un motor de análisis que traduzca los diagramas a una representación intermedia que preserve su semántica. 
- Crear un generador de código que transforme la representación intermedia en código C funcional, correctamente estructurado y documentado. 
- Integrar funcionalidades de guardado, carga y exportación de diagramas y código generado. 
- Generar manuales de usuario, documentación técnica de la arquitectura y un informe detallado del proceso de creación, que sirvan como referencia para facilitar el mantenimiento de la aplicación. 

**3  Justificación** 

1. **Justificación**  

Este trabajo terminal presenta una solución innovadora que integra conceptos fundamentales de ingeniería de software, compiladores, interfaces hombre-máquina y programación móvil. La implementación requiere aplicar conocimientos  avanzados  de  estructuras  de  datos,  análisis  sintáctico,  generación  de  código  y  diseño  de interfaces, demostrando así la capacidad para resolver problemas complejos de ingeniería. 

FlowCode se fundamenta en principios establecidos de construcción de compiladores y transpiladores [1], implementando las fases clásicas de traducción de lenguajes:  

- Análisis léxico: Tokenización de símbolos visuales ISO 5807 [13]  
- Análisis sintáctico: Validación de grafos mediante BFS [3]  
- Análisis semántico: Tabla de símbolos + reglas de validación [1]  
- Generación de código: Traducción RI a C con preservación de semántica [1]  

Este enfoque garantiza que todo diagrama válido genere código C compatible sin errores en GCC/Clang. 

2. **Originalidad e Innovación** 

A diferencia de las herramientas existentes, FlowCode combina: 

- Un enfoque nativo para dispositivos móviles con interfaz táctil optimizada. 
- Generación específica hacia lenguaje C, ampliamente utilizado en los primeros semestres en ESCOM. 
- Validación semántica de los diagramas antes de la generación de código. 
- Potencial para exportar y compartir tanto diagramas como código resultante. 
3. **Factibilidad Técnica** 

El desarrollo de la aplicación es técnicamente viable considerando:  

- **Frameworks  multiplataforma**:  Flutter  con  soporte  nativo  para  Android  8.0+  (API  level  26+), garantizando renderizado a 60 FPS mediante CustomPaint y gestos táctiles optimizados [9].  
- **Algoritmos de análisis**: Implementación de BFS/DFS para validación de topología de grafos dirigidos [3], con complejidad O(V+E) aceptable para diagramas de hasta 100 nodos.  
- **Técnicas de compiladores**: Generación de código mediante traducción dirigida por sintaxis (Syntax- Directed Translation) con preservación de semántica [1].  
- **Capacidad de hardware**: Dispositivos Android actuales (2GB+ RAM) ejecutan análisis semántico y generación de código en <2 segundos para algoritmos de complejidad media (≤50 símbolos).  
- **Plataforma objetivo Android** [14]: La viabilidad económica y la penetración de mercado de 73% del mercado móvil mexicano [14]. El costo de publicación contemplado es único $25 USD (Google Play) 

  o de $99 USD/año (Apple App Store)  

**4  Productos o resultados esperados** 

Al concluir el trabajo terminal, se espera obtener los siguientes productos:** 

- **Aplicación móvil :** Aplicación móvil funcional para dispositivos Android que permita la creación, edición y traducción de diagramas de flujo a código C. 
- **Documentación técnica:** Documentación técnica completa que incluya la arquitectura del sistema, diagramas UML, especificación de requisitos y manuales de usuario. 
- **Manual de usuario:** Documentación del proceso de desarrollo, las decisiones de diseño, los desafíos encontrados y los resultados obtenidos. 

Las herramientas y tecnologías que vamos a usar son: 

- **Desarrollo móvil:** Flutter/Dart 
- **Gestión de datos:** SQLite  
- **Análisis de diagramas:** Implementación propia basada en teoría de grafos 
- **Generación de código:** Técnicas de compiladores adaptadas al contexto 
- **Control de versiones:** Git/GitHub 
- **Gestión del proyecto:** ClickUp 

**5  Arquitectura del Sistema** 

La  arquitectura  del  sistema  FlowCode  seguirá  un  patrón  de  diseño  en  capas  que  separa  claramente  las responsabilidades de cada componente. La siguiente figura muestra la arquitectura propuesta: 

![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.001.jpeg)

**Figura 1*** Arquitectura del sistema. **Fuente:** Elaboración propia.

La arquitectura del sistema se divide en tres capas principales: 

1. **Capa de Presentación:**  
- Interfaz de Usuario: Maneja todas las interacciones con el usuario. 
- Editor de Diagramas: Proporciona la interfaz gráfica para la creación y edición de diagramas de flujo. 
- Visualizador de Código Generado: Muestra el código C generado con formato adecuado. 
- Gestor de Proyectos: Permite administrar los diagramas y archivos de código. 
2. **Capa de Lógica de Negocio:**  
- Analizador de Diagramas: Procesa la estructura del diagrama de flujo. 
- Validador Semántico: Verifica la correctitud lógica y semántica del diagrama. 
- Representación Intermedia: Traduce el diagrama a una estructura interna que facilita la generación de código. 
- Generador de Código: Produce el código C a partir de la representación intermedia. 
3. **Capa de Persistencia:**  
- Almacenamiento de Proyectos: Gestiona la persistencia de los proyectos del usuario. 
- Almacenamiento de Diagramas: Almacena los diagramas de flujo en formato serializado. 
- Almacenamiento de Código: Gestiona el almacenamiento del código generado. 

**5.1  Pipeline del convertidor** 

El sistema implementa un sistema de conversión que procesa el diagrama de flujo a través de las siguientes fases: 

1. **Análisis Estructural del Grafo:** Validación de topología y conectividad (BFS/DFS) 
1. **Análisis Sintáctico de Expresiones:** Parsing de expresiones C dentro de símbolos 
1. **Análisis Semántico:** Construcción de tabla de símbolos y verificación de 10 reglas (S01-S10) 
1. **Representación Intermedia:** Transformación a estructura JSON independiente del lenguaje 
1. **Generación de Código C:** Traducción final con preservación de semántica y formato optimizado 

**Alcance del Lenguaje Objetivo** 

FlowCode genera código compatible con el subconjunto estructurado básico de C (C89/C99): 

**Soportado:** 

- Tipos de datos primitivos: int, float, char 
- Entrada/salida estándar: scanf, printf 
- Estructuras de control: if/else, while, for 
- Variables locales y expresiones aritméticas/lógicas 

**Excluido del alcance:** 

- Punteros y aritmética de punteros 
- Estructuras (struct) y uniones 
- Memoria dinámica (malloc, free) 
- Funciones múltiples y recursión 
- Arrays multidimensionales 

**Justificación:** Estos  conceptos  exceden  las  capacidades  de  representación  del  estándar  ISO  5807  y  la complejidad de análisis semántico factible en el plazo del trabajo terminal. 

El núcleo del sistema es el motor de conversión que implementa las fases clásicas de un compilador fuente a fuente adaptadas al contexto visual: 

![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.002.jpeg)

**Figura 2**. Pipeline del conversor de FlowCode. **Fuente**: Elaboración propia. 

**6  Metodología** 

Para el desarrollo de este trabajo terminal se utilizará el modelo de desarrollo en espiral propuesto por Barry Boehm, que es particularmente adecuado para proyectos de software con requisitos evolutivos y donde la gestión  de  riesgos  es  importante.  Este  modelo  combina  elementos  de  desarrollo  iterativo  con  aspectos sistemáticos del modelo de cascada tradicional. 

El modelo en espiral se estructura en ciclos o iteraciones, donde cada ciclo consta de cuatro fases principales: 

1. **Determinación de objetivos, alternativas y restricciones**: Establecer los objetivos específicos de la iteración, identificar alternativas de implementación y reconocer las restricciones existentes. 
1. **Análisis  de  riesgos**:  Evaluar  alternativas,  identificar  y  resolver  riesgos  a  través  de  prototipos, simulaciones o análisis detallados. 
1. **Desarrollo y verificación**: Implementar y verificar el producto para esa iteración, que puede incluir diseño, codificación, pruebas y documentación. 
1. **Planificación**: Revisar los resultados obtenidos y planificar la siguiente iteración. 

![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.003.jpeg)

**Figura 3** Etapas de la metodología de desarrollo en espiral. **Fuente:** Boehm, B. W. (1988). [2]. 

1. **Aplicación Específica de los Ciclos al Proyecto** 

**CICLO 1: Definición y Viabilidad** 

**Objetivos específicos:** 

- Definir los símbolos de diagramas de flujo soportados (inicio/fin, proceso, decisión, E/S) 
- Establecer la gramática para la traducción a código C 
- Evaluar frameworks de desarrollo móvil (Flutter vs React Native) 

**Análisis de riesgos:** 

- Riesgo: Complejidad del análisis semántico → Prototipo de validador básico 
- Riesgo: Limitaciones del hardware móvil → Pruebas de rendimiento preliminares 

**Productos:** 

- Especificación técnica detallada 
- Prototipo de arquitectura 
- Evaluación de tecnologías 

**CICLO 2: Diseño de Interfaz** 

**Objetivos específicos:** 

- Crear interfaz táctil optimizada para creación de diagramas 
- Implementar gestos para conexión de elementos 
- Diseñar visualización de errores en tiempo real 

**Análisis de riesgos:** 

- Riesgo: Usabilidad en pantallas pequeñas → Prototipos con diferentes tamaños de elementos 
- Riesgo: Gestión de gestos complejos → Pruebas de usabilidad con usuarios objetivo 

**Productos:** 

- Mockups interactivos 
- Prototipo funcional de UI 
- Resultados de pruebas de usabilidad 

**CICLO 3: Editor de Diagramas** 

**Objetivos específicos:** 

- Implementar manipulación visual de elementos 
- Desarrollar sistema de conexiones entre nodos 
- Crear sistema de serialización de diagramas 

**Análisis de riesgos:** 

- Riesgo: Rendimiento en diagramas complejos → Optimización de estructuras de datos 
- Riesgo: Pérdida de datos → Implementación de autoguardado 

**Productos:** 

- Editor visual funcional 
- Sistema de persistencia 
- Pruebas de rendimiento 

**CICLO 4: Motor de Análisis** 

**Objetivos específicos:** 

- Implementar algoritmos de validación de grafos dirigidos 
- Desarrollar análisis semántico de variables y tipos 
- Crear sistema de detección de errores lógicos 

**Análisis de riesgos:** 

- Riesgo: Complejidad algorítmica → Implementación incremental por tipos de validación 
- Riesgo: Falsos positivos en validación → Pruebas exhaustivas con casos límite 

**Productos:** 

- Analizador sintáctico completo 
- Validador semántico 
- Suite de pruebas de validación 

**CICLO 5: Generador de Código** 

**Objetivos específicos:** 

- Implementar traducción de estructuras de control (if, while, for) 
- Desarrollar generador de declaraciones de variables 
- Crear optimizador básico de código resultante 

**Análisis de riesgos:** 

- Riesgo: Código generado incorrecto → Pruebas de compilación automática 
- Riesgo: Código ilegible → Implementación de formateador 

**Productos:** 

- Generador de código C funcional 
- Formateador de código 
- Pruebas de compilación cruzada 

**CICLO 6: Integración** 

**Objetivos específicos:** 

- Integrar todos los componentes en flujo completo 
- Optimizar comunicación entre módulos 
- Implementar manejo global de errores 

**Análisis de riesgos:** 

- Riesgo: Incompatibilidades entre módulos → Pruebas de integración continua 
- Riesgo: Degradación de rendimiento → Profiling y optimización 

**Productos:** 

- Aplicación integrada completa 
- Suite de pruebas de integración 
- Documentación de API interna 

**CICLO 7: Pruebas y Documentación** 

**Objetivos específicos:** 

- Realizar pruebas exhaustivas de integración y sistema 
- Crear documentación técnica y de usuario 
- Validar métricas técnicas de precisión y rendimiento 

**Análisis de riesgos:** 

- Riesgo: Métricas técnicas no alcanzadas → Optimización del motor 
- Riesgo: Documentación insuficiente → Revisión por director de TT 

**Productos:** 

- Aplicación final validada 
- Documentación completa 
- Informe de pruebas de compilación (GCC/Clang) 
2. **Métricas de Evaluación por Ciclo** 

Cada ciclo incluirá métricas específicas: 

- **Ciclos 1-3**: Métricas de usabilidad y funcionalidad básica 
- **Ciclos 4-5**: Métricas de precisión y rendimiento técnico 

**7  Cronograma** 

Nombre del alumno: García Quiroz Gustavo Ivan 

Título del trabajo terminal: “FlowCode: Aplicación para la conversión de diagramas de flujo (ISO 5807) a código C estructurado para dispositivos móviles Android” 



|**Diagrama de Gantt - Primer Semestre** ||||||||||||||||||||||||||
| - | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|**Actividad** |**Agosto** |**Septiembr e** |**Octubre** |**Noviembr e** |**Diciembr e** |||||||||||||||||||||
||1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 ||||||
|**CICLO 1: DEFINICIÓN Y VIABILIDAD** ||||||||||||||||||||||||||
|`  `Investigación bibliográfica ||||||||||||||||||||||||||
|`  `Análisis de requisitos  ||||||||||||||||||||||||||
|`  `Estudio de herramientas         ||||||||||||||||||||||||||
|`  `Definición de arquitectura         ||||||||||||||||||||||||||
|`  `Selección de tecnologías           ||||||||||||||||||||||||||
|`  `Evaluación de riesgos              ||||||||||||||||||||||||||
|`  `Informe Ciclo 1                        ||||||||||||||||||||||||||
|||||||||||||||||||||||||||
|**CICLO 2: DISEÑO DE INTERFAZ** ||||||||||||||||||||||||||
|`  `Diseño de wireframes                    ||||||||||||||||||||||||||
|`  `Prototipos de interfaz                  ||||||||||||||||||||||||||
|`  `Refinamiento de diseños                     ||||||||||||||||||||||||||
|`  `Implementación básica de UI                 ||||||||||||||||||||||||||
|`  `Pruebas de funcionamiento                          ||||||||||||||||||||||||||
|`  `Informe Ciclo 2                                  ||||||||||||||||||||||||||
|||||||||||||||||||||||||||
|**CICLO 3: EDITOR DE DIAGRAMAS** ||||||||||||||||||||||||||
|`  `Implementación del editor visual                  ||||||||||||||||||||||||||
|`  `Manipulación de elementos                          ||||||||||||||||||||||||||
|`  `Sistema de conexiones                                ||||||||||||||||||||||||||
|`  `Funcionalidades avanzadas                           ||||||||||||||||||||||||||
|`  `Sistema de guardado                                     ||||||||||||||||||||||||||
|`  `Pruebas de funcionamiento                           ||||||||||||||||||||||||||
|`  `Informe Ciclo 3                                             ||||||||||||||||||||||||||
|||||||||||||||||||||||||||
|**EVALUACIÓN SEMESTRAL** ||||||||||||||||||||||||||
|`  `Preparación de informe                                 ||||||||||||||||||||||||||
|`  `Presentación de avance                                 ||||||||||||||||||||||||||


|**Diagrama de Gantt - Segundo Semestre** |||||||||||||||||||||||||
| - | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|**Actividad** |**Enero**  |**Febrero** |**Marzo** |**Abril** |**Mayo** |**Junio** |||||||||||||||||||
||1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |1 |2 |3 |4 |
|**CICLO 4: MOTOR DE ANÁLISIS** |||||||||||||||||||||||||
|`  `Implementación analizador       |||||||||||||||||||||||||


|`  `Algoritmos de validación        ||||||||||||||||||||||||||||||||||||
| - | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|`  `Validación semántica              ||||||||||||||||||||||||||||||||||||
|`  `Detección de errores             ||||||||||||||||||||||||||||||||||||
|`  `Optimización del motor              ||||||||||||||||||||||||||||||||||||
|`  `Informe Ciclo 4                      ||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||
|**CICLO 5: GENERADOR DE CÓDIGO** ||||||||||||||||||||||||||||||||||||
|`  `Diseño representación interm.        ||||||||||||||||||||||||||||||||||||
|`  `Traducción básica a código C         ||||||||||||||||||||||||||||||||||||
|`  `Optimización código generado            ||||||||||||||||||||||||||||||||||||
|`  `Manejo de casos especiales              ||||||||||||||||||||||||||||||||||||
|`  `Pruebas del generador                     ||||||||||||||||||||||||||||||||||||
|`  `Informe Ciclo 5                             ||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||
|**CICLO 6: INTEGRACIÓN** ||||||||||||||||||||||||||||||||||||
|`  `Integración de componentes                  ||||||||||||||||||||||||||||||||||||
|`  `Optimización de rendimiento                   ||||||||||||||||||||||||||||||||||||
|`  `Pruebas de integración                          ||||||||||||||||||||||||||||||||||||
|`  `Corrección de errores                             ||||||||||||||||||||||||||||||||||||
|`  `Informe Ciclo 6                                     ||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||
|**CICLO 7: PRUEBAS Y DOCUMENTACIÓN** ||||||||||||||||||||||||||||||||||||
|`  `Pruebas exhaustivas                                  ||||||||||||||||||||||||||||||||||||
|`  `Documentación técnica                                  ||||||||||||||||||||||||||||||||||||
|`  `Documentación de usuario                                 ||||||||||||||||||||||||||||||||||||
|`  `Informe final                                                ||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||
|**ENTREGA Y DEFENSA** ||||||||||||||||||||||||||||||||||||
|`  `Preparación de presentación                                 ||||||||||||||||||||||||||||||||||||
|`  `Entrega de documentación                                    ||||||||||||||||||||||||||||||||||||
|`  `Defensa del trabajo terminal                                 ||||||||||||||||||||||||||||||||||||
**8  Referencias** 

1. V. Aho, M. S. Lam, R. Sethi, and J. D. Ullman, Compilers: Principles, Techniques, and Tools, 3rd ed. Upper Saddle River, NJ: Pearson, 2020.  
1. W. Boehm, "A spiral model of software development and enhancement," Computer, vol. 21, no. 5, pp. 61-72, May 1988.  
1. K. D. Cooper and L. Torczon, Engineering a Compiler, 2nd ed. San Francisco, CA: Morgan Kaufmann, 2011.  
1. E. Gamma, R. Helm, R. Johnson, and J. Vlissides, Design Patterns: Elements of Reusable Object- Oriented Software. Reading, MA: Addison-Wesley, 1994.  
1. E. Knuth, The Art of Computer Programming, Volume 1: Fundamental Algorithms, 3rd ed. Reading, MA: Addison-Wesley, 1997.  
1. R. C. Martin, Clean Architecture: A Craftsman's Guide to Software Structure and Design. Upper Saddle River, NJ: Prentice Hall, 2017.  
1. M. Fowler, Domain-Specific Languages. Upper Saddle River, NJ: Addison-Wesley, 2010.  
1. J. L. Hendrix Valdelamar and J. Palma Suárez, Compiladores: teoría e implementación.  México: Alfaomega, 2018.  
1. J. Nielsen, Mobile Usability, 2nd ed. Berkeley, CA: New Riders, 2019.  
1. T. Barr and M. Marron, "Code generation from visual flowcharts," Journal of Software Engineering, vol. 42, no. 3, pp. 210-225, 2018.  
1. C. González Morcillo and A. García Fernández, "Herramientas para la enseñanza de programación en educación superior: un enfoque visual," Revista Iberoamericana de Tecnologías del Aprendizaje, vol. 5, no. 2, pp. 112-119, 2017.  
1. Robins,  J.  Rountree,  and  N.  Rountree,  "Learning  and  teaching  programming:  A  review  and discussion," Computer Science Education, vol. 13, no. 2, pp. 137-172, 2003.  
1. International  Organization  for  Standardization,  ISO  5807:1985  Information  processing  — Documentation  symbols  and  conventions  for  data,  program  and  system  flowcharts.  Geneva, Switzerland: ISO, 1985.  
1. StatCounter  Global  Stats,  "Mobile  Operating  System  Market  Share  Mexico,"  2024.  [Online]. Available: https://gs.statcounter.com/os-market-share/mobile/mexico [Accessed: 15-Jan-2025] 

12 

**9  Alumnos y directores. ![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.004.png)**

García Quiroz Gustavo Ivan. - Alumno de la carrera de Ingeniería  en  Sistemas  Computacionales  en  ESCOM. Boleta:  2022630278.  Tel:5551803395.  Email: [garciaquirozgustavoivan@gmail.com ](mailto:garciaquirozgustavoivan@gmail.com)

Firma: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ ![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.005.png)

***Ing. José Antonio Ortiz Ramírez.*** 

Docente  de  tiempo  completo  en  la  carrera  de  Ing.  en Sistemas Computacionales de la ESCOM. Interesado en sistemas de información, desarrollo web y desarrollo de aplicaciones móviles. 

Datos  de  contacto:  Teléfono:  5557296000,  Ext.  52083. Email: jaortizr@gmail.com ![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.006.png)

Firma: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ 

***Ing. Gabriel Hurtado Avilés.*** 

Docente de la carrera de Ing. en Sistemas Computacionales de la ESCOM. Interesado en diversos temas relacionados al desarrollo de aplicaciones móviles. 

Datos de contacto: Ext. 52083. Email: ghurtadoa@ipn.mx 

Firma: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ ![](Aspose.Words.d4e1887e-54b5-40ec-8f0c-7302083c4cc8.007.png)

CARÁCTER: Confidencial FUNDAMENTO LEGAL: Artículo 11 Fracc. V y Artículos 108, 113 y 117 de la Ley Federal de Transparencia y Acceso a la Información Pública.  PARTES CONFIDENCIALES: Número de boleta y teléfono. 
13 
