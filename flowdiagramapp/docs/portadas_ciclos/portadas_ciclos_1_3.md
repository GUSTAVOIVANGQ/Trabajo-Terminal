# FlowCode: Aplicación para la conversión de diagramas de flujo a código C estructurado para dispositivos móviles Android

---

## Ciclo 1: Definición y Viabilidad

**(Agosto – Septiembre 2025)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Realizar una investigación bibliográfica enfocada en los fundamentos técnicos del proyecto: compiladores, transpiladores, diagramas de flujo y desarrollo móvil.
- Definir los requisitos funcionales principales del sistema, delimitando el alcance técnico viable para el Trabajo Terminal.
- Establecer la arquitectura general del sistema, identificando los componentes principales y sus responsabilidades.
- Seleccionar y justificar la tecnología de desarrollo definitiva para la plataforma móvil.
- Identificar los riesgos críticos del proyecto y definir estrategias de mitigación para cada uno.
- Generar la documentación base del proyecto: protocolo, justificación técnica y cronograma general.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Alcance técnico demasiado amplio para el tiempo disponible | Delimitar el alcance desde el inicio, priorizando las funcionalidades esenciales del transpilador |
| Tecnología de desarrollo inadecuada para los requerimientos del proyecto | Evaluar y comparar alternativas con prototipos mínimos antes de tomar la decisión definitiva |
| Requisitos incompletos o ambiguos que generen rediseños posteriores | Revisar y validar los requisitos con los directores del TT antes de avanzar al siguiente ciclo |
| Desconocimiento técnico en áreas clave (compiladores, grafos) | Dedicar tiempo de investigación bibliográfica focalizada al inicio del ciclo |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Investigación bibliográfica con fuentes relevantes sobre compiladores, transpiladores y desarrollo móvil.
- Lista de requisitos funcionales prioritarios del sistema.
- Diagrama de arquitectura general del sistema con sus componentes principales.
- Decisión técnica justificada sobre el framework de desarrollo móvil a utilizar.
- Identificación de riesgos críticos con sus estrategias de mitigación.
- Documentación base del proyecto: protocolo formal y cronograma general.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 1: investigación, arquitectura propuesta, decisiones técnicas y análisis de riesgos.
- Protocolo del Trabajo Terminal registrado y validado por los directores.
- Plan detallado para el Ciclo 2: Diseño de Interfaz.

---

## Ciclo 2: Diseño de Interfaz

**(Septiembre – Octubre 2025)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Diseñar las pantallas principales de la aplicación mediante wireframes y prototipos de baja fidelidad.
- Definir la estructura de navegación de la aplicación y el flujo de interacción entre pantallas.
- Configurar el entorno de desarrollo completo: SDK, herramientas, repositorio y gestión del proyecto.
- Implementar la pantalla principal y los menús básicos como primera versión funcional de la interfaz.
- Establecer el sistema visual de la aplicación: paleta de colores, tipografía y guía de estilo.
- Realizar pruebas de usabilidad con usuarios representativos del perfil objetivo.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Usabilidad deficiente en pantallas de diferentes tamaños | Diseñar con layouts responsivos y probar en dispositivos de distintas resoluciones desde el inicio |
| Complejidad de gestos táctiles en el editor de diagramas | Validar los gestos con prototipos interactivos antes de la implementación definitiva |
| Guía de estilo inconsistente entre pantallas | Definir y documentar los componentes visuales reutilizables antes de comenzar la implementación |
| Retroalimentación tardía de usuarios que requiera rediseños costosos | Realizar pruebas de usabilidad en etapas tempranas con wireframes, no con la versión final |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Wireframes de las pantallas principales: editor, validador, visualizador de código y gestor de proyectos.
- Prototipo interactivo de navegación con flujos de usuario definidos.
- Entorno de desarrollo completamente configurado y operativo.
- Implementación básica de la interfaz con navegación funcional entre pantallas.
- Paleta de colores, tipografía y guía de estilo visual documentadas.
- Resultados y conclusiones de las pruebas de usabilidad realizadas.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 2: diseños de interfaz, guía de estilo y resultados de pruebas de usabilidad.
- Prototipo funcional con navegación básica entre pantallas principales.
- Plan detallado para el Ciclo 3: Editor de Diagramas.

---

## Ciclo 3: Editor de Diagramas

**(Octubre – Diciembre 2025)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Implementar el canvas de renderizado interactivo para la creación y edición de diagramas de flujo.
- Desarrollar la biblioteca completa de símbolos ISO 5807 con sus representaciones visuales estándar.
- Implementar el sistema de conexiones entre nodos con enrutamiento automático e inteligente.
- Desarrollar los gestos táctiles esenciales del editor: zoom, desplazamiento, selección y operaciones de edición.
- Implementar el sistema de persistencia local para guardar, cargar y exportar diagramas.
- Desarrollar la primera fase del transpilador: análisis estructural del grafo con validaciones de conectividad y alcanzabilidad.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Alta complejidad técnica del renderizado y la interacción táctil | Uso de bibliotecas especializadas de renderizado y desarrollo incremental por funcionalidad |
| Rendimiento insuficiente en dispositivos de gama baja | Optimización continua de estructuras de datos y pruebas en hardware representativo |
| Curva de aprendizaje pronunciada en las bibliotecas de renderizado | Desarrollo de prototipos de validación tempranos para familiarizarse con las herramientas |
| Pérdida de datos del diagrama por fallos inesperados | Implementación de autoguardado periódico y manejo robusto de errores de persistencia |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Editor visual de diagramas de flujo completamente funcional con interfaz táctil optimizada.
- Biblioteca de símbolos ISO 5807 con 7 tipos de elementos disponibles para el usuario.
- Sistema de conexiones entre nodos con enrutamiento automático y puntos de anclaje definidos.
- Gestos táctiles implementados: zoom, desplazamiento, selección múltiple, deshacer y rehacer.
- Sistema de persistencia local con guardado automático y exportación de diagramas.
- Primera fase del transpilador: análisis estructural del grafo con 14 validaciones de estructura implementadas.
- Sistema de visualización de errores estructurales integrado al editor en tiempo real.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 3: documentación del editor visual y de la primera fase del transpilador.
- Editor de diagramas funcional entregado como avance del primer semestre.
- Presentación de avance semestral ante los directores del Trabajo Terminal.
- Plan detallado para el Ciclo 4: Motor de Análisis (segundo semestre).
