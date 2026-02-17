# Índice del Documento Técnico - FlowCode
## Trabajo Terminal 2026-A038

---

## Índice

## 1. Introducción (Pág. 18)
- 1.1 Contexto y Antecedentes (Pág. 18)
- 1.2 Planteamiento del Problema (Pág. 18)
- 1.3 Propuesta de Solución (Pág. 19)
- 1.4 Objetivo (Pág. 22)
  - 1.4.1 Objetivos específicos (Pág. 22)
- 1.5 Justificación (Pág. 22)
  - 1.5.1 Relevancia Académica y Profesional (Pág. 23)
  - 1.5.2 Fundamento técnico del transpilador (Pág. 23)
  - 1.5.3 Originalidad e Innovación (Pág. 23)
- 1.6 Estado del arte (Pág. 23)

---

## CICLO 1: DEFINICIÓN Y VIABILIDAD ✅ (Pág. 26)

### 2. Marco teórico (Pág. 28)
- 2.1 Compiladores (Pág. 28)
  - 2.1.1 Fases de compilación (análisis léxico, sintáctico, semántico) (Pág. 29)
  - 2.1.2 Manejo de Errores en Compiladores (Pág. 30)
- 2.2 Transpiladores y DSLs Visuales (Pág. 30)
  - 2.2.1 Transpilador (Pág. 30)
  - 2.2.2 Lenguajes Específicos de Dominio Visuales (Visual DSL) (Pág. 30)
- 2.3 Diagramas de Flujo (Pág. 32)
  - 2.3.1 Estándar ISO 5807 y Simbología Implementada (Pág. 32)
  - 2.3.2 Propiedades de los diagramas de flujo como medio de representación (Pág. 35)
  - 2.3.3 Limitaciones y consideraciones especiales (Pág. 36)
- 2.4 Desarrollo de aplicaciones móviles (Pág. 36)
  - 2.4.1 Paradigmas de Desarrollo Móvil (Pág. 36)
- 2.5 Lenguaje C (Pág. 37)
- 2.6 Aplicación de los Fundamentos al Proyecto FlowCode (Pág. 38)
  - 2.6.1 Pipeline de Compilación en FlowCode (Pág. 38)
  - 2.6.2 Tabla de Símbolos y Análisis Semántico (Pág. 40)
  - 2.6.3 Algoritmos de Análisis Aplicados (Pág. 41)
  - 2.6.4 Manejo de Errores Multi-Nivel (Pág. 42)
  - 2.6.5 Clasificación como Compilador (Pág. 42)
  - 2.6.6 Sistema de Validación de FlowCode (Pág. 43)
- 2.7 Conceptos de Programación y Diseño de Algoritmos Cubiertos (Pág. 48)
  - 2.7.1 Alcance Educativo del Proyecto (Pág. 48)
  - 2.7.2 Conceptos Fundamentales Cubiertos (Núcleo del Proyecto) (Pág. 48)
  - 2.7.3 Conceptos con Representación Limitada (Pág. 48)
  - 2.7.4 Conceptos NO Cubiertos (Fuera de Alcance) (Pág. 49)
- 2.8 Investigación Bibliográfica (Pág. 50)

### 3. Estudio de factibilidad (Pág. 52)
- 3.1.1 Factibilidad Técnica (Pág. 52)
- 3.1.2 Factibilidad Operativa (Pág. 54)
- 3.1.3 Factibilidad Económica (Pág. 55)
- 3.1.4 Factibilidad Legal (Pág. 56)
- 3.1.5 Factibilidad Ambiental (Pág. 60)
- 3.1.6 Gestión de Adquisiciones - Activo Fijo (Hardware y Mobiliario) (Pág. 61)
- 3.1.7 Retorno de Inversión (ROI) para el Inversionista (Pág. 66)
- 3.1.8 Modelo de Negocio (Pág. 67)

### 4. Análisis de requisitos (Pág. 75)
- 4.1 Requisitos Previos del Usuario (Pág. 75)
  - 4.1.1 Conocimientos Técnicos Requeridos (Pág. 75)
  - 4.1.2 Perfil de Usuario Objetivo (Pág. 75)
  - 4.1.3 Stakeholders (Pág. 76)
- 4.2 Requisitos Funcionales Detallados (Pág. 76)
  - 4.2.1 Requisitos del Editor Visual (RF-Editor) (Pág. 76)
  - 4.2.2 Requisitos del Analizador y Validador (RF-Validador) (Pág. 77)
  - 4.2.3 Requisitos del Generador de Código (RF-Generador) (Pág. 78)
  - 4.2.4 Requisitos de Gestión de Proyectos (RF-Gestión) (Pág. 78)
- 4.3 Requisitos No Funcionales (Pág. 79)
- 4.4 Casos de Uso (Pág. 80)
  - 4.4.1 Actores del Sistema (Pág. 80)
  - 4.4.2 Diagrama General de Casos de Uso (Pág. 81)
  - 4.4.3 Casos de Uso del Editor de Diagramas (Pág. 81)
  - 4.4.4 CU01 - Crear Nuevo Diagrama (Pág. 81)
  - 4.4.5 CU02 - Agregar y Conectar Elementos (Pág. 87)
  - 4.4.6 CU03 - Editar Propiedades de Elementos (Pág. 94)
  - 4.4.7 CU04 - Validar Estructura del Diagrama (Pág. 100)
  - 4.4.8 CU05 - Realizar Análisis Semántico (Pág. 102)
  - 4.4.9 CU06 - Generar Código C (Pág. 104)
  - 4.4.10 CU07 - Exportar Proyecto Completo (Pág. 109)
  - 4.4.11 CU08 - Organizar Proyectos en Carpetas (Pág. 113)
  - 4.4.12 CU09 - Registrar Cuenta de Usuario (Pág. 116)
  - 4.4.13 CU10 - Sincronizar Proyectos a la Nube (Pág. 119)

### 5. Arquitectura del Sistema (Pág. 123)
- 5.1 Arquitectura General (Pág. 123)
  - 5.1.1 Justificación de la Elección (Pág. 124)
- 5.2 Arquitectura en Capas (Pág. 124)
  - 5.2.1 Tecnologías Base de la Arquitectura (Pág. 125)

### 6. Selección de tecnologías (Pág. 126)
- 6.1 Flutter (Pág. 126)
- 6.2 Librerías de Gráficos y Visualización (Pág. 126)
  - 6.2.1 Flutter CustomPainter (Pág. 127)
  - 6.2.2 Canvas y Widgets Especializados (Pág. 127)
- 6.3 Tecnologías de Persistencia (Pág. 127)
  - 6.3.1 Base de Datos Local: SQLite (Pág. 127)
  - 6.3.2 Backend en la Nube: Firebase (Pág. 127)
- 6.4 Herramientas de Desarrollo (Pág. 127)
  - 6.4.1 Entorno de Desarrollo Integrado (Pág. 127)
  - 6.4.2 Dispositivos de Prueba (Pág. 128)
  - 6.4.3 Plataforma de Desarrollo (Pág. 128)
- 6.5 Infraestructura de Desarrollo (Pág. 128)
  - 6.5.1 Control de Versiones: GitHub (Pág. 128)
  - 6.5.2 Gestión de Proyecto: ClickUp (Pág. 128)

### 7. Análisis de riesgos (Pág. 129)
- 7.1 Identificación de Riesgos (Pág. 129)
  - 7.1.1 Riesgos Técnicos (Pág. 130)
  - 7.1.2 Riesgos de Cronograma (Pág. 131)
  - 7.1.3 Riesgos de Recursos (Pág. 131)
  - 7.1.4 Riesgos Externos (Pág. 132)
- 7.2 Evaluación de Riesgos (Pág. 132)
  - 7.2.1 Matriz de Probabilidad e Impacto (Pág. 133)
  - 7.2.2 Análisis Cuantitativo de Impacto (Pág. 134)
  - 7.2.3 Priorización de Riesgos (Pág. 134)
- 7.3 Estrategias de Mitigación (Pág. 135)
  - 7.3.1 Mitigación de Riesgos Técnicos (Pág. 136)
- 7.4 Plan de Monitoreo (Pág. 145)
  - 7.4.1 Estructura de Revisiones (Pág. 145)
  - 7.4.2 Señales de Alarma (Pág. 146)
  - 7.4.3 Protocolo de Respuesta a Problemas (Pág. 146)
  - 7.4.4 Herramientas de Monitoreo (Pág. 147)

### 8. Metodología (Pág. 148)
- 8.1 Modelo en Espiral (Pág. 148)
- 8.2 Ciclos Planificados (Pág. 149)
- 8.3 Gestión de Proyecto Individual (Pág. 158)
- 8.4 Estrategia de Testing (Pág. 159)
  - 8.4.1 Tipos de Pruebas Implementadas (Pág. 159)
  - 8.4.2 Testing por Ciclo de Desarrollo (Pág. 159)
  - 8.4.3 Conjunto de Pruebas de Aceptación (Pág. 160)
  - 8.4.4 Criterios de Paso (Pág. 160)

### 9. Cronograma (Pág. 162)
- 9.1 Cronograma General (Pág. 162)

---

## CICLO 2: DISEÑO DE INTERFAZ ✅ (Pág. 163)

### 10. Pantallas principales (Pág. 165)
- 10.1 Pantalla de Inicio de sesión (Pág. 165)
  - 10.1.1 Propósito y Función (Pág. 165)
- 10.2 Pantalla del Editor de Diagramas (Pág. 166)
  - 10.2.1 Propósito y Función (Pág. 166)
- 10.3 Pantalla del Validador Semántico (Pág. 167)
  - 10.3.1 Propósito y Función (Pág. 167)
- 10.4 Pantalla del Código Generado (Pág. 168)
  - 10.4.1 Propósito y Función (Pág. 168)
- 10.5 Pantalla de Gestión de Proyectos (Pág. 169)
  - 10.5.1 Propósito y Función (Pág. 169)

### 11. Especificación de componentes de interfaz (Pág. 170)
- 11.1 Componentes de Diagramación (Pág. 170)
  - 11.1.1 Propiedades Interactivas de Símbolos (Pág. 171)
- 11.2 Componentes de Diálogo (Pág. 171)

### 12. Especificación visual y paleta de colores (Pág. 172)
- 12.1 Paleta de Colores de Símbolos de Diagramas (Pág. 172)
- 12.2 Colores de Validación y Estados del Compilador (Pág. 172)
- 12.3 Paleta de Colores de Interfaz General (Pág. 173)

### 13. Pruebas de usabilidad (Pág. 173)

---

## CICLO 3: EDITOR DE DIAGRAMAS ✅ (Pág. 179)

### 14. Implementación del Editor Visual (Pág. 181)
- 14.1 Arquitectura del Componente Editor (Pág. 181)
  - 14.1.1 Biblioteca de renderizado seleccionada (Pág. 181)
  - 14.1.2 Modelo de datos para representación de diagramas (Pág. 181)
  - 14.1.3 Sistema de coordenadas y viewport (Pág. 181)
- 14.2 Renderizado de Símbolos (Pág. 181)
  - 14.2.1 Implementación de formas geométricas estándar (Pág. 182)
  - 14.2.2 Sistema de renderizado de texto (Pág. 182)
- 14.3 Sistema de Interacción Táctil (Pág. 182)
  - 14.3.1 Gestos Implementados (Pág. 182)
- 14.4 Sistema de Conexiones (Aristas) (Pág. 183)
  - 14.4.1 Algoritmo de Routing de Conexiones (Pág. 183)
  - 14.4.2 Cálculo de puntos de anclaje (Pág. 183)
  - 14.4.3 Detección de colisiones y enrutamiento (Pág. 183)
  - 14.4.4 Validación de Conexiones (Pág. 184)
- 14.5 Funcionalidades de Edición Avanzadas (Pág. 184)
  - 14.5.1 Sistema Undo/Redo (Pág. 184)
- 14.6 Operaciones sobre Elementos (Pág. 185)
  - 14.6.1 Copiar, cortar y pegar símbolos (Pág. 185)
  - 14.6.2 Duplicación y eliminación (Pág. 185)
  - 14.6.3 Alineación y distribución automática (Pág. 185)

### 15. Sistema de Persistencia de Diagramas (Pág. 185)
- 15.1 Esquema de Base de Datos SQLite (Pág. 185)
  - 15.1.1 Tablas para proyectos, diagramas y elementos (Pág. 185)
  - 15.1.2 Serialización de estructura de grafos (Pág. 186)
- 15.2 Operaciones CRUD (Pág. 187)
  - 15.2.1 Guardado automático y manual (Pág. 187)
  - 15.2.2 Carga de proyectos existentes (Pág. 188)
  - 15.2.3 Gestión de versiones locales (Pág. 188)
- 15.3 Exportación de Diagramas (Pág. 189)
  - 15.3.1 Generación de imágenes PNG/SVG (Pág. 189)
  - 15.3.2 Exportación de estructura JSON (Pág. 189)
- 15.4 Integración con Firebase (Pág. 190)
- 15.5 Configuración de Firebase en Flutter (Pág. 190)
  - 15.5.1 Firebase Core y servicios utilizados (Pág. 190)
- 15.6 Analytics de Uso (Pág. 191)
  - 15.6.1 Eventos de interacción del usuario (Pág. 191)
  - 15.6.2 Métricas de rendimiento del editor (Pág. 192)
- 15.7 Crashlytics (Pág. 192)
  - 15.7.1 Reporte automático de errores (Pág. 192)
  - 15.7.2 Logs de debugging (Pág. 192)
- 15.8 Pruebas de funcionamiento (Pág. 193)
  - 15.8.1 Pruebas unitarias del Editor (Pág. 193)

---

## CICLO 4: MOTOR DE ANÁLISIS (Pág. 194)

### 16. Arquitectura del Compilador Fuente-a-Fuente (Pág. 194)
- 16.1 Pipeline de Compilación (Pág. 194)
  - 16.1.1 Diagrama de fases del transpilador (Pág. 194)
  - 16.1.2 Clase DiagramCompilerPipeline (Pág. 195)
  - 16.1.3 Opciones de compilación (CompilerOptions) (Pág. 195)
- 16.2 Fase 1: Análisis Léxico (Pág. 196)
  - 16.2.1 DiagramLexicalAnalyzer (Pág. 196)
  - 16.2.2 Sistema de tokens (TokenType) (Pág. 196)
  - 16.2.3 Tokenización de contenido de nodos (Pág. 197)
- 16.3 Fase 2: Análisis Sintáctico (Pág. 198)
  - 16.3.1 DiagramSyntaxAnalyzer (Pág. 198)
  - 16.3.2 Parser de descenso recursivo (Pág. 198)
  - 16.3.3 Construcción del AST (ProgramNode) (Pág. 199)
- 16.4 Fase 3: Análisis Semántico (Pág. 200)
  - 16.4.1 DiagramSemanticAnalyzer (Pág. 200)
  - 16.4.2 Verificación de tipos (DataType) (Pág. 200)
  - 16.4.3 Análisis de alcance (ScopeAnalysisResult) (Pág. 201)
  - 16.4.4 Detección de variables no declaradas (Pág. 201)

### 17. Tabla de Símbolos (Pág. 202)
- 17.1 Estructura de SymbolTable (Pág. 202)
  - 17.1.1 Clase Symbol y atributos (Pág. 202)
  - 17.1.2 Tipos de datos soportados (DataType) (Pág. 202)
- 17.2 Gestión de Alcances (Pág. 203)
  - 17.2.1 Ámbitos global y local (Pág. 203)
  - 17.2.2 Búsqueda y resolución de símbolos (Pág. 203)
- 17.3 Información de Tipos (Pág. 204)
  - 17.3.1 Especificadores de formato (printf/scanf) (Pág. 204)
  - 17.3.2 Valores por defecto en C (Pág. 204)

### 18. Sistema de Errores del Compilador (Pág. 205)
- 18.1 Clasificación de Errores (CompilerErrorCode) (Pág. 205)
  - 18.1.1 Errores léxicos (Pág. 205)
  - 18.1.2 Errores sintácticos (Pág. 205)
  - 18.1.3 Errores semánticos (Pág. 206)
- 18.2 Severidad y Fases (Pág. 206)
  - 18.2.1 Niveles de severidad (CompilerSeverity) (Pág. 206)
  - 18.2.2 Fases de compilación (CompilerPhase) (Pág. 206)
- 18.3 Reportes de Compilación (Pág. 207)
  - 18.3.1 CompilationResult y métricas (Pág. 207)

---

## CICLO 5: GENERADOR DE CÓDIGO (Pág. 208)

### 19. Nodos del Árbol de Sintaxis Abstracta (Pág. 208)
- 19.1 Jerarquía de Nodos AST (Pág. 208)
  - 19.1.1 Clase base ASTNode (Pág. 208)
  - 19.1.2 Nodos literales (IntegerLiteralNode, FloatLiteralNode, etc.) (Pág. 208)
  - 19.1.3 Nodos de expresión (BinaryExpressionNode, UnaryExpressionNode) (Pág. 209)
  - 19.1.4 Nodos de sentencia (DeclarationStatementNode, IfStatementNode, etc.) (Pág. 209)
- 19.2 Patrón Visitor (ASTVisitor) (Pág. 210)
  - 19.2.1 Recorrido del AST (Pág. 210)
  - 19.2.2 Generación de representación textual (Pág. 210)

### 20. Optimización del AST (Pág. 211)
- 20.1 DiagramCodeOptimizer (Pág. 211)
  - 20.1.1 Niveles de optimización (OptimizationLevel) (Pág. 211)
  - 20.1.2 Configuración del optimizador (OptimizerConfig) (Pág. 211)
- 20.2 Técnicas de Optimización Implementadas (Pág. 212)
  - 20.2.1 Plegado de constantes (Constant Folding) (Pág. 212)
  - 20.2.2 Eliminación de código muerto (Dead Code Elimination) (Pág. 212)
  - 20.2.3 Simplificación de expresiones (Pág. 213)
- 20.3 Métricas de Optimización (OptimizationMetrics) (Pág. 213)

### 21. Generación de Código C (Pág. 214)
- 21.1 AdvancedCodeGenerator (Pág. 214)
  - 21.1.1 Opciones de generación (CodeGenOptions) (Pág. 214)
  - 21.1.2 Orden de ejecución de nodos (Pág. 214)
- 21.2 Traducción de Nodos a Código C (Pág. 215)
  - 21.2.1 Nodo terminal (Inicio/Fin) (Pág. 215)
  - 21.2.2 Nodo proceso (Asignaciones y expresiones) (Pág. 215)
  - 21.2.3 Nodo decisión (if/else, switch) (Pág. 216)
  - 21.2.4 Nodo preparación (for, while, do-while) (Pág. 216)
  - 21.2.5 Nodo datos (scanf/printf) (Pág. 217)
  - 21.2.6 Nodo proceso predefinido (Subrutinas) (Pág. 217)
- 21.3 Generación de Encabezados y Estructura (Pág. 218)
  - 21.3.1 Includes estándar (stdio.h, stdlib.h) (Pág. 218)
  - 21.3.2 Función main() (Pág. 218)

---

## CICLO 6: INTEGRACIÓN (Pág. 219)

### 22. Integración del Pipeline Completo (Pág. 219)
- 22.1 Flujo de Compilación End-to-End (Pág. 219)
  - 22.1.1 Entrada: Diagramas de flujo (Nodos y Conexiones) (Pág. 219)
  - 22.1.2 Salida: Código C compilable (Pág. 219)
- 22.2 Integración con el Editor Visual (Pág. 220)
  - 22.2.1 Invocación del compilador desde la UI (Pág. 220)
  - 22.2.2 Visualización de errores en tiempo real (Pág. 220)
- 22.3 Símbolos ISO 5807 Soportados (Pág. 221)
  - 22.3.1 Símbolos con generación de código (Pág. 221)
  - 22.3.2 Mapeo símbolo-código C (Pág. 221)

### 23. Pruebas de Integración (Pág. 222)
- 23.1 Casos de Prueba del Compilador (Pág. 222)
  - 23.1.1 Pruebas del analizador léxico (Pág. 222)
  - 23.1.2 Pruebas del analizador sintáctico (Pág. 222)
  - 23.1.3 Pruebas del analizador semántico (Pág. 223)
  - 23.1.4 Pruebas del generador de código (Pág. 223)
- 23.2 Validación de Código Generado (Pág. 224)
  - 23.2.1 Compilabilidad con GCC (Pág. 224)
  - 23.2.2 Correctitud funcional (Pág. 224)

---

## CICLO 7: PRUEBAS Y DOCUMENTACIÓN (Pág. 225)

### 24. Resultados y Pruebas (Pág. 225)
- 24.1 Criterios de Validación Técnica (Pág. 225)
  - 24.1.1 Criterios de Corrección Funcional (Pág. 225)
  - 24.1.2 Criterios de Calidad de Código Generado (Pág. 226)
  - 24.1.3 Criterios de Rendimiento (Pág. 226)
  - 24.1.4 Cobertura de Suite de Pruebas (Pág. 227)
  - 24.1.5 Criterios de Robustez (Pág. 227)
  - 24.1.6 Criterio General de Éxito del Proyecto (Pág. 228)
- 24.2 Resultados de Pruebas Funcionales (Pág. 228)
  - 24.2.1 Corrección Funcional (Pág. 228)
  - 24.2.2 Calidad de Código Generado (Pág. 229)
- 24.3 Resultados de Pruebas de Rendimiento (Pág. 229)
  - 24.3.1 Métricas de Rendimiento (Pág. 229)
- 24.4 Resultados de Pruebas de Robustez (Pág. 230)
- 24.5 Análisis de Cumplimiento de Criterios de Éxito (Pág. 230)
  - 24.5.1 Evaluación de Criterios Agregados (Pág. 231)
- 24.6 Limitaciones Identificadas Durante Validación (Pág. 231)

---

## Conclusión (Pág. 232)

- 24.7 MAPEO COMPLETO: Temario vs. Capacidades de Diagramas de Flujo (Pág. 232)
  - 24.7.1 UNIDAD I: Programación Estructurada ✅ COBERTURA COMPLETA (Pág. 232)

---

## 25. Referencias (Pág. 235)

---

## 26. Anexos (Pág. 237)

### Anexo A: Alcance de símbolos/constructos en TT I (Pág. 237)

### Anexo B: Catálogo de errores y advertencias (Pág. 237)
- B.2 Clasificación de Mensajes por Severidad (Pág. 237)
- B.3 ERRORES SINTÁCTICOS O DE ESTRUCTURA DEL DIAGRAMA (E-SYN) (Pág. 238)
- B.4 ERRORES SEMÁNTICOS (E-SEM) (Pág. 239)
- B.5 ERRORES DE SINTAXIS DE EXPRESIONES (E-EXP) (Pág. 240)

### ANEXO G: CASOS DE PRUEBA ESPECÍFICOS (Pág. 242)

---

## Índice de Figuras

| # | Figura | Pág. |
|---|--------|------|
| 1 | Pipeline de traducción | 21 |
| 2 | Esquema general de un compilador tradicional mostrando el flujo desde programa fuente hasta programa objeto. | 28 |
| 3 | Diagrama que muestra la división análisis-síntesis con las sus fases correspondientes | 29 |
| 4 | Estructura Algorítmica: SECUENCIA | 34 |
| 5 | Estructura Algorítmica: SELECCIÓN (Condicional) | 35 |
| 6 | Estructura Algorítmica: ITERACIÓN (Bucle While) | 35 |
| 7 | Arquitectura Multi-Nivel del Compilador | 44 |
| 8 | Modelo Canvas de FlowCode | 67 |
| 9 | Diagrama general de casos de uso del sistema FlowCode | 81 |
| 10 | Diagrama de caso de uso - CU01 | 82 |
| 11 | Diagrama de Secuencia Principal - CU01 | 83 |
| 12 | Diagrama de Secuencia - Flujo Alternativo 1: Cancelación | 84 |
| 13 | Flujo Alternativo 2: Error de Almacenamiento | 85 |
| 14 | Diagrama de Secuencia - Flujo Alternativo 3: Nombre Duplicado | 86 |
| 15 | Diagrama de caso de uso CU02 | 88 |
| 16 | Diagrama de Secuencia: Agregar Elemento al Diagrama | 89 |
| 17 | Diagrama de Secuencia: Conectar Dos Elementos | 90 |
| 18 | Diagrama de Secuencia: Editar Propiedades Durante Creación | 91 |
| 19 | Diagrama de Secuencia: Flujo Alternativo - Conexión Inválida | 92 |
| 20 | Diagrama de Estados: Elemento del Diagrama | 93 |
| 21 | Diagrama de caso de uso CU03 | 94 |
| 22 | Diagrama de Secuencia Principal - CU03 | 95 |
| 23 | Diagrama de Secuencia - Edición de Elemento de Proceso | 96 |
| 24 | Diagrama de Secuencia - Edición de Elemento de Proceso | 97 |
| 25 | Diagrama de Secuencia - Flujo Alternativo: Cancelar Edición | 98 |
| 26 | Diagrama de Secuencia Principal - CU04 | 100 |
| 27 | Diagrama de Secuencia Principal - CU04 | 101 |
| 28 | Diagrama de caso de uso CU05 | 102 |
| 29 | Diagrama de Secuencia Principal | 103 |
| 30 | Diagrama de caso de uso - CU06 | 105 |
| 31 | Diagrama de secuencia principal - Generación de código C | 106 |
| 32 | Diagrama de secuencia - Proceso de validación previa | 107 |
| 33 | Diagrama de secuencia - Construcción del AST | 108 |
| 34 | Diagrama de caso de uso - CU07 | 109 |
| 35 | Flujos alternativos - CU07 | 109 |
| 36 | Diagrama de caso de uso - CU07 | 110 |
| 37 | Diagrama de Secuencia Principal - CU07 | 111 |
| 38 | Diagrama de caso de uso - CU08 | 113 |
| 39 | Diagrama de Secuencia: Renombrar Proyecto (CU08) | 114 |
| 40 | Diagrama de Secuencia: Eliminar Proyecto (CU08) | 115 |
| 41 | Diagrama de caso de uso - CU09 | 116 |
| 42 | Diagrama de caso de uso - CU09 | 117 |
| 43 | Diagrama de Secuencia: Renombrar Proyecto (CU09) | 118 |
| 44 | Diagrama de caso de uso - CU10 | 120 |
| 45 | Diagrama de Secuencia: Renombrar Proyecto (CU10) | 121 |
| 46 | Arquitectura en capas (Layered Architecture). | 123 |
| 47 | Diagrama del modelo en espiral de Boehm con las 4 fases principales | 147 |
| 48 | Pantalla de alta fidelidad del Dashboard con colores, tipografía, e iconografía reales | 159 |
| 49 | Pantalla del Editor mostrando un diagrama de ejemplo con varios elementos conectados | 160 |
| 50 | Pantalla del Validador mostrando ejemplos de errores formateados con iconos y sugerencias | 161 |
| 51 | Pantalla del visor de código mostrando ejemplo real con resaltado de sintaxis y comentarios | 162 |
| 52 | Mockup del Gestor en vista de cuadrícula con thumbnails de proyectos | 163 |
| 53 | Funciones para hacer y deshacer. | 178 |
| 54 | Guardado automático y manual | 182 |
| 55 | estructura completa del diagrama JSON | 184 |

---

## Índice de Tablas

| # | Tabla | Pág. |
|---|-------|------|
| 1 | Matriz comparativa de herramientas existentes. | 24 |
| 2 | Riesgos identificados y mitigados | 27 |
| 3 | Tabla de símbolos estándar ISO 5807 con sus respectivas funciones: inicio/fin (óvalos), proceso (rectángulos), decisión (rombos), entrada/salida (paralelogramos), conector (círculos), etc. | 33 |
| 4 | Mapeo de símbolos a código | 40 |
| 5 | Tabla de Símbolos | 41 |
| 6 | Validaciones de la estructura | 45 |
| 7 | Validaciones de conectividad | 45 |
| 8 | Validaciones de Expresiones (E-EXP) | 45 |
| 9 | Validaciones semánticas (E-SEM) | 46 |
| 10 | Tabla Detallada de Conceptos Cubiertos | 48 |
| 11 | Tabla de Conceptos con Limitaciones | 49 |
| 12 | Tabla de Conceptos Excluidos | 49 |
| 13 | Investigación Bibliográfica | 51 |
| 14 | Stack Tecnológico Seleccionado | 53 |
| 15 | Hardware y Mobiliario | 54 |
| 16 | Competencias del Desarrollador | 55 |
| 17 | Viabilidad del Cronograma (Modelo Espiral) | 55 |
| 18 | Gastos de constitución legal | 56 |
| 19 | Lugar de Trabajo | 62 |
| 20 | Materiales y Suministros | 62 |
| 21 | Gastos de Operación | 63 |
| 22 | Recursos Humanos | 63 |
| 23 | Gestión de los Costos del Proyecto | 64 |
| 24 | Flujo de Caja Proyectado | 65 |
| 25 | Fuentes de Financiamiento | 65 |
| 26 | Análisis de Sensibilidad de Costos | 66 |
| 27 | Requisitos del Editor Visual (RF-Editor) | 77 |
| 28 | Tabla de Requisitos del Validador | 78 |
| 29 | Requisitos del Generador de Código | 78 |
| 30 | Requisitos de Gestión de Proyectos | 79 |
| 31 | Requisitos No Funcionales | 80 |
| 32 | Actores del Sistema | 80 |
| 33 | CU01 - Crear Nuevo Diagrama | 82 |
| 34 | Flujos alternativos - CU01 | 82 |
| 35 | CU02 - Agregar y conectar elementos | 87 |
| 36 | Flujos alternativos - CU02 | 87 |
| 37 | CU03 - Editar Propiedades de Elementos | 93 |
| 38 | Flujos alternativos - CU03 | 94 |
| 39 | CU04 - Validar Estructura del Diagrama | 99 |
| 40 | CU05 - Realizar Análisis Semántico | 101 |
| 41 | Flujos Alternativos CU05 | 102 |
| 42 | Diagrama de caso de uso CU06 | 104 |
| 43 | Flujos Alternativos - CU06 | 104 |
| 44 | Diagrama de caso de uso - CU08 | 112 |
| 45 | Flujos alternativos - CU08 | 112 |
| 46 | Flujos alternativos - CU09 | 116 |
| 47 | Diagrama de caso de uso - CU10 | 119 |
| 48 | Flujos alternativos - CU10 | 119 |
| 49 | Categorías de Riesgos del Proyecto FlowCode | 129 |
| 50 | Detalle de Riesgos Técnicos. | 129 |
| 51 | Detalle de Riesgos de Cronograma. | 130 |
| 52 | Detalle de Riesgos de Recursos. | 131 |
| 53 | Detalle de Riesgos Externos. | 131 |
| 54 | Matriz de Probabilidad vs Impacto (gráfico de cuadrantes) con ubicación visual de los riesgos identificados por código | 132 |
| 55 | Matriz completa de evaluación de riesgos con código de colores. | 133 |
| 56 | Análisis de impacto multidimensional | 133 |
| 57 | Estrategias de Mitigación por Categoría de Riesgo | 135 |
| 58 | Plan de Contingencia de RT-01 | 135 |
| 59 | Plan de Contingencia de RT-02 | 136 |
| 60 | Plan de Contingencia de RT-03 | 136 |
| 61 | Plan de Contingencia de RT-04 | 137 |
| 62 | Plan de Contingencia de RT-05 | 137 |
| 63 | Plan de Contingencia de RC-01 | 138 |
| 64 | Plan de Contingencia de RC-02 | 138 |
| 65 | Plan de Contingencia de RC-03 | 139 |
| 66 | Plan de Contingencia de RC-04 | 140 |
| 67 | Plan de Contingencia de RR-01 | 140 |
| 68 | Plan de Contingencia de RR-02 | 141 |
| 69 | Plan de Contingencia de RR-03 | 141 |
| 70 | Tabla 32 Plan de Contingencia de RR-04 | 142 |
| 71 | Tabla 32 Plan de Contingencia de RE-01 | 142 |
| 72 | Plan de Contingencia de RE-02 | 143 |
| 73 | Plan de Contingencia de RE-03 | 143 |
| 74 | Plan de Contingencia de RE-04 | 144 |
| 75 | Estructura de revisiones del plan de monitoreo. | 145 |
| 76 | Señales de alarma y acciones de respuesta. | 145 |
| 77 | Protocolo de respuesta a problemas de dos pasos. | 146 |
| 78 | Herramientas de monitoreo utilizadas. | 146 |
| 79 | Screenshot de la configuración básica del proyecto en ClickUp | 153 |
| 80 | Estrategia de testing por ciclo de desarrollo | 154 |
| 81 | Riesgos identificados y mitigados | 157 |
| 82 | Símbolos de diagramas de flujo y su traducción a código C. | 165 |
| 83 | Gestos táctiles para manipulación de símbolos. | 165 |
| 84 | Estados visuales de componentes interactivos. | 165 |
| 85 | Paleta de colores para símbolos de diagramas de flujo. | 166 |
| 86 | Colores de estados de validación semántica. | 167 |
| 87 | Paleta de colores de interfaz general. | 167 |
| 88 | Preguntas | 168 |
| 89 | Riesgos identificados y mitigados | 173 |
| 90 | Tablas para proyectos | 180 |
| 91 | Eventos de interacción del usuario | 185 |
| 92 | Riesgos identificados y mitigados | 189 |
| 93 | Resultados de criterios de corrección funcional | 196 |
| 94 | Resultados de calidad de código C generado | 196 |
| 95 | Resultados de métricas de rendimiento | 197 |
| 96 | Resultados de pruebas de robustez | 197 |
| 97 | Evaluación final de criterios de éxito del proyecto | 198 |
| 98 | Clasificación de Mensajes por Severidad | 205 |

---

**Notas sobre el Índice:**

✅ **Ciclos Completados:**
- Ciclo 1: Definición y Viabilidad (100%)
- Ciclo 2: Diseño de Interfaz (100%)
- Ciclo 3: Editor de Diagramas (100%)

📅 **Ciclos Futuros (Trabajo Terminal II):**

- Ciclo 4: Motor de Análisis
- Ciclo 5: Generador de Código
- Ciclo 6: Integración
- Ciclo 7: Pruebas y Documentación
---

**Estado del Documento:** Versión actualizada al 12/02/2026
**Progreso general:** 100% (Ciclos 1-4)
