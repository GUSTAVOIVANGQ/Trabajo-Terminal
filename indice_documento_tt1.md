# ÍNDICE DEL DOCUMENTO - TRABAJO TERMINAL I
## FlowCode: Compilador de Diagramas de Flujo a Código C para Dispositivos Móviles

---

## **ELEMENTOS PRELIMINARES**

### **Portada**
- Logos institucionales (IPN, ESCOM)
- Título completo del proyecto
- Nombre del alumno: García Quiroz Gustavo Iván
- Director: Ing. José Antonio Ortiz Ramírez
- Trabajo Terminal No. 2026-A038
- Período académico
- Fecha de entrega

### **Índice General**
- Numeración de páginas
- Lista de figuras y tablas
- Estructura completa del documento

### **Resumen Ejecutivo**
- Síntesis del proyecto (200-300 palabras)
- Objetivos principales
- Metodología empleada
- Resultados esperados del Ciclo 1
- Palabras clave

---

## **1. INTRODUCCIÓN GENERAL**

### **1.1 Contexto del Proyecto**
- Importancia de la programación visual en educación
- Problemática actual en la enseñanza de algoritmos
- Evolución de herramientas de programación educativa
- Relevancia del desarrollo móvil en educación

### **1.2 Planteamiento del Problema**
- Análisis detallado de la problemática identificada
- Limitaciones de herramientas existentes
- Necesidades no cubiertas en el mercado actual
- Impacto en estudiantes y docentes

### **1.3 Justificación del Proyecto**
- Relevancia académica y profesional
- Impacto educativo esperado
- Originalidad e innovación
- Factibilidad técnica y económica

### **1.4 Objetivos**
- **Objetivo General**: Desarrollo completo del sistema FlowCode
- **Objetivos Específicos**: Desglose por componentes y funcionalidades
- **Objetivos del Ciclo 1**: Metas específicas para esta fase

### **1.5 Alcance y Limitaciones**
- Definición clara del alcance del proyecto
- Limitaciones técnicas identificadas
- Restricciones de tiempo y recursos
- Supuestos del proyecto

---

## **2. MARCO TEÓRICO**

### **2.1 Fundamentos de Compiladores**
- Teoría básica de compiladores
- Fases de compilación (análisis léxico, sintáctico, semántico)
- Generación de código intermedio y final
- Optimización de código

### **2.2 Programación Visual**
- Conceptos fundamentales de programación visual
- Ventajas y desventajas frente a programación textual
- Paradigmas de programación visual
- Aplicaciones educativas

### **2.3 Diagramas de Flujo**
- Historia y evolución de los diagramas de flujo
- Estándares internacionales (ISO 5807:1985)
- Elementos básicos y simbología
- Aplicaciones en ingeniería de software

### **2.4 Desarrollo de Aplicaciones Móviles**
- Plataformas móviles (Android, iOS)
- Frameworks de desarrollo multiplataforma
- Principios de diseño de interfaces táctiles
- Consideraciones de performance en móviles

### **2.5 Lenguaje C**
- Características principales del lenguaje C
- Estándares del lenguaje (C89, C99, C11, C18)
- Aplicaciones educativas y profesionales
- Compiladores de referencia (GCC, Clang)

---

## **3. ESTADO DEL ARTE**

### **3.1 Investigación Bibliográfica**
- Metodología de búsqueda empleada
- Bases de datos consultadas
- Criterios de selección de fuentes
- Período de investigación cubierto

### **3.2 Herramientas Existentes**
- **Flowgorithm**
  - Características principales
  - Fortalezas y limitaciones
  - Análisis comparativo
- **RAPTOR**
  - Funcionalidades principales
  - Limitaciones identificadas
  - Aplicabilidad educativa
- **PSeInt**
  - Enfoque pedagógico
  - Limitaciones técnicas
  - Diferenciadores
- **Draw.io y Lucidchart**
  - Capacidades generales de diagramación
  - Limitaciones para programación
  - Análisis de mercado

### **3.3 Investigaciones Académicas Relevantes**
- Trabajos de investigación sobre compilación visual
- Estudios sobre efectividad de programación visual en educación
- Investigaciones en desarrollo móvil educativo
- Papers sobre generación automática de código

### **3.4 Análisis Comparativo**
- Matriz de comparación de herramientas
- Identificación de gaps en el mercado
- Oportunidades de innovación
- Ventajas competitivas de FlowCode

### **3.5 Tecnologías Candidatas**
- **Frameworks de Desarrollo Móvil**
  - Flutter/Dart: ventajas y desventajas
  - React Native: análisis técnico
  - Xamarin: consideraciones
  - Desarrollo nativo: pros y contras
- **Bases de Datos Móviles**
  - SQLite: características y aplicabilidad
  - Realm: alternativas modernas
  - Soluciones en la nube
- **Librerías de Gráficos**
  - Canvas APIs
  - Librerías de diagramación
  - Herramientas de visualización

---

## **4. ANÁLISIS DE REQUISITOS**

### **4.1 Identificación de Stakeholders**
- Estudiantes de programación (usuarios primarios)
- Docentes de programación (usuarios secundarios)
- Administradores institucionales
- Desarrolladores de contenido educativo

### **4.2 Requisitos Funcionales Detallados**
- **RF-Editor**: Requisitos del editor visual
  - Creación y edición de diagramas
  - Biblioteca de símbolos estándar
  - Conexión de elementos
  - Navegación y zoom
- **RF-Validador**: Requisitos de validación
  - Validación estructural
  - Análisis semántico
  - Detección de errores
  - Retroalimentación visual
- **RF-Generador**: Requisitos de generación de código
  - Traducción a código C
  - Formato y documentación
  - Manejo de variables
  - Estructuras de control
- **RF-Gestión**: Requisitos de manejo de proyectos
  - Guardado y carga
  - Exportación
  - Organización
  - Compartir

### **4.3 Requisitos No Funcionales Detallados**
- **Usabilidad**: Métricas y estándares
- **Rendimiento**: Especificaciones técnicas
- **Confiabilidad**: Niveles de disponibilidad
- **Seguridad**: Protección de datos
- **Compatibilidad**: Versiones soportadas
- **Escalabilidad**: Capacidades futuras

### **4.4 Casos de Uso**
- Diagramas de casos de uso por módulo
- Especificación detallada de casos principales
- Flujos alternativos y de excepción
- Precondiciones y postcondiciones

### **4.5 Historias de Usuario**
- Historias principales organizadas por épica
- Criterios de aceptación detallados
- Priorización basada en valor de negocio
- Estimación de esfuerzo

---

## **5. ARQUITECTURA DEL SISTEMA**

### **5.1 Arquitectura General**
- Patrón arquitectónico seleccionado
- Justificación de la elección
- Diagrama de arquitectura de alto nivel
- Principios de diseño aplicados

### **5.2 Arquitectura en Capas**
- **Capa de Presentación**
  - Componentes de interfaz de usuario
  - Manejo de eventos táctiles
  - Controladores de vista
- **Capa de Lógica de Negocio**
  - Servicios de aplicación
  - Reglas de negocio
  - Validaciones
- **Capa de Persistencia**
  - Acceso a datos
  - Modelos de datos
  - Gestión de archivos

### **5.3 Componentes Principales**
- **Editor de Diagramas**: Arquitectura interna
- **Motor de Análisis**: Diseño de algoritmos
- **Generador de Código**: Patrones de diseño
- **Gestor de Persistencia**: Estrategias de almacenamiento

### **5.4 Interfaces y APIs**
- Interfaces entre componentes
- Definición de contratos
- Protocolos de comunicación
- Manejo de errores

### **5.5 Consideraciones de Diseño**
- Patrones de diseño aplicados
- Principios SOLID
- Separación de responsabilidades
- Extensibilidad y mantenibilidad

---

## **6. SELECCIÓN DE TECNOLOGÍAS**

### **6.1 Metodología de Evaluación**
- Criterios de evaluación definidos
- Matriz de decisión
- Proceso de selección
- Validación con stakeholders

### **6.2 Framework de Desarrollo Móvil**
- **Análisis de Flutter**
  - Ventajas técnicas
  - Ecosistema y comunidad
  - Curva de aprendizaje
  - Performance en dispositivos objetivo
- **Análisis de React Native**
  - Comparativa con Flutter
  - Consideraciones específicas del proyecto
- **Decisión Final**: Justificación técnica

### **6.3 Tecnologías Complementarias**
- **Base de Datos**: SQLite vs alternativas
- **Librerías Gráficas**: Evaluación y selección
- **Herramientas de Testing**: Framework seleccionado
- **Control de Versiones**: Git y estrategia de branching

### **6.4 Herramientas de Desarrollo**
- IDE y editores de código
- Emuladores y dispositivos de prueba
- Herramientas de debugging
- Sistemas de build y deployment

### **6.5 Infraestructura de Desarrollo**
- Entorno de desarrollo local
- Repositorio de código
- Sistema de integración continua
- Herramientas de gestión de proyecto

---

## **7. ANÁLISIS DE RIESGOS**

### **7.1 Identificación de Riesgos**
- Riesgos técnicos
- Riesgos de cronograma
- Riesgos de recursos
- Riesgos externos

### **7.2 Evaluación de Riesgos**
- Matriz de probabilidad e impacto
- Clasificación por severidad
- Análisis cuantitativo cuando aplique
- Priorización de riesgos

### **7.3 Estrategias de Mitigación**
- Plan de mitigación por riesgo identificado
- Estrategias preventivas
- Planes de contingencia
- Responsables de seguimiento

### **7.4 Plan de Monitoreo**
- Indicadores de riesgo
- Frecuencia de revisión
- Criterios de escalación
- Procedimientos de respuesta

---

## **8. METODOLOGÍA DE DESARROLLO**

### **8.1 Modelo en Espiral - Fundamentos**
- Descripción del modelo de Boehm
- Justificación para el proyecto
- Adaptaciones específicas
- Ventajas para proyectos educativos

### **8.2 Ciclos Planificados**
- **Ciclo 1**: Definición y Viabilidad
- **Ciclo 2**: Diseño de Interfaz
- **Ciclo 3**: Editor de Diagramas
- **Ciclo 4**: Motor de Análisis
- **Ciclo 5**: Generador de Código
- **Ciclo 6**: Integración
- **Ciclo 7**: Pruebas y Documentación

### **8.3 Gestión de Proyecto**
- Herramientas de seguimiento (ClickUp)
- Métricas de progreso
- Ceremonias de revisión
- Control de cambios

### **8.4 Estrategia de Testing**
- Niveles de testing planificados
- Tipos de pruebas por ciclo
- Herramientas de testing
- Criterios de aceptación

---

## **9. CRONOGRAMA DETALLADO**

### **9.1 Cronograma General**
- Vista macro de los dos semestres
- Hitos principales
- Dependencias entre actividades
- Recursos asignados

### **9.2 Cronograma del Ciclo 1 (Detallado)**
- Desglose semanal de actividades
- Entregables específicos
- Criterios de completitud
- Riesgos asociados por actividad

### **9.3 Plan de Entregas**
- Entregables por ciclo
- Fechas de revisión
- Criterios de calidad
- Proceso de aprobación

---

## **10. RESULTADOS DEL CICLO 1**

### **10.1 Investigación Bibliográfica Completada**
- Síntesis de fuentes consultadas
- Bibliografía clasificada por temas
- Identificación de trabajos más relevantes
- Lecciones aprendidas

### **10.2 Análisis de Requisitos Finalizado**
- Requisitos validados con stakeholders
- Casos de uso refinados
- Historias de usuario priorizadas
- Criterios de aceptación definidos

### **10.3 Arquitectura Definida**
- Decisiones arquitectónicas documentadas
- Diagramas de arquitectura validados
- Patrones de diseño seleccionados
- Plan de implementación por componentes

### **10.4 Tecnologías Seleccionadas**
- Justificación de decisiones técnicas
- Configuración del entorno de desarrollo
- Pruebas de concepto realizadas
- Plan de capacitación técnica

### **10.5 Riesgos Evaluados y Mitigados**
- Registro de riesgos actualizado
- Estrategias de mitigación implementadas
- Plan de monitoreo establecido
- Lecciones aprendidas documentadas

---

## **11. CONCLUSIONES DEL CICLO 1**

### **11.1 Objetivos Alcanzados**
- Evaluación del cumplimiento de objetivos
- Métricas de éxito del ciclo
- Desviaciones identificadas
- Acciones correctivas tomadas

### **11.2 Viabilidad del Proyecto**
- Confirmación de viabilidad técnica
- Validación de viabilidad económica
- Análisis de riesgos residuales
- Recomendaciones para siguientes ciclos

### **11.3 Preparación para Ciclo 2**
- Plan detallado del siguiente ciclo
- Recursos necesarios identificados
- Dependencias críticas
- Criterios de éxito definidos

---

## **12. REFERENCIAS BIBLIOGRÁFICAS**

### **12.1 Literatura Académica**
- Libros de texto especializados
- Artículos de revistas indexadas
- Papers de conferencias
- Tesis y trabajos de investigación

### **12.2 Documentación Técnica**
- Documentación oficial de frameworks
- Especificaciones de estándares
- Guías de mejores prácticas
- Tutoriales técnicos especializados

### **12.3 Fuentes Web**
- Sitios oficiales de herramientas
- Blogs técnicos reconocidos
- Repositorios de código abierto
- Comunidades de desarrolladores

---

## **ANEXOS**

### **Anexo A: Encuestas y Entrevistas**
- Cuestionarios aplicados a estudiantes
- Entrevistas con docentes
- Análisis de resultados
- Validación de requisitos

### **Anexo B: Diagramas Técnicos**
- Diagramas UML completos
- Wireframes de interfaces
- Diagramas de flujo de procesos
- Modelos de datos

### **Anexo C: Código de Pruebas de Concepto**
- Prototipos desarrollados
- Código de validación técnica
- Resultados de performance
- Configuraciones de entorno

### **Anexo D: Matrices de Decisión**
- Evaluación de tecnologías
- Análisis comparativo de herramientas
- Justificaciones técnicas detalladas
- Cálculos de viabilidad

---

## **NOTAS PARA EL DESARROLLO DEL DOCUMENTO**

### **Extensión Estimada por Sección:**
- **Elementos Preliminares**: 3-4 páginas
- **Introducción General**: 8-10 páginas
- **Marco Teórico**: 15-20 páginas
- **Estado del Arte**: 20-25 páginas
- **Análisis de Requisitos**: 12-15 páginas
- **Arquitectura del Sistema**: 10-12 páginas
- **Selección de Tecnologías**: 8-10 páginas
- **Análisis de Riesgos**: 6-8 páginas
- **Metodología**: 6-8 páginas
- **Cronograma**: 4-5 páginas
- **Resultados del Ciclo 1**: 8-10 páginas
- **Conclusiones**: 4-5 páginas
- **Referencias y Anexos**: 15-20 páginas

**Total Estimado**: 120-150 páginas

### **Estándares de Formato:**
- Fuente: Times New Roman 12pt
- Interlineado: 1.5
- Márgenes: 2.5cm superior e izquierdo, 2cm inferior y derecho
- Numeración: Romanos para preliminares, arábigos para contenido
- Figuras y tablas numeradas consecutivamente
- Referencias en formato IEEE o APA según política ESCOM