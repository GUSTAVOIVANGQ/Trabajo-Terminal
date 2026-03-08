# FlowCode: Aplicación para la conversión de diagramas de flujo a código C estructurado para dispositivos móviles Android

---

## Ciclo 4: Motor de Análisis

**(Enero – Febrero 2026)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Diseñar e implementar el pipeline de compilación con fases secuenciales y un orquestador central.
- Desarrollar el análisis léxico: tokenización del contenido de cada nodo del diagrama, reconociendo identificadores, literales, palabras reservadas y operadores.
- Implementar el análisis sintáctico mediante un parser de descenso recursivo que construya el Árbol de Sintaxis Abstracta (AST).
- Implementar el análisis semántico con verificación de tipos, análisis de alcance y detección de variables no declaradas.
- Construir la tabla de símbolos con atributos de nombre, tipo, categoría, estado e inicialización.
- Establecer el sistema de clasificación de errores por fase (léxica, sintáctica y semántica) y por nivel de severidad.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Complejidad del análisis semántico | Implementación incremental, comenzando con validaciones básicas antes de la implementación completa |
| Falsos positivos en la detección de errores | Pruebas exhaustivas con casos límite positivos y negativos por cada regla |
| Rendimiento del análisis en dispositivos móviles | Pruebas de rendimiento tempranas y optimización de estructuras de datos |
| Integración con el editor visual | Definir interfaces claras entre módulos desde el inicio del ciclo |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Analizador léxico funcional con sistema de tokens completo.
- Analizador sintáctico con parser de descenso recursivo y generación del AST.
- Analizador semántico con verificación de tipos y análisis de alcance.
- Tabla de símbolos con soporte para ámbitos y resolución de nombres.
- Sistema de errores estructurado con clasificación por tipo, severidad y fase de compilación.
- Suite de pruebas unitarias para cada componente del analizador.
- Integración del motor de análisis con el editor visual para retroalimentación en tiempo real.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 4: documentación de la arquitectura del compilador y decisiones de diseño.
- Plan detallado para el Ciclo 5: Generador de Código.

---

## Ciclo 5: Generador de Código

**(Febrero – Abril 2026)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Implementar la jerarquía completa de nodos del Árbol de Sintaxis Abstracta (AST) con el patrón Visitor.
- Desarrollar el optimizador del AST con múltiples niveles de optimización (plegado de constantes, eliminación de código muerto, simplificación algebraica).
- Implementar el generador de código C con mapeo completo de símbolos ISO 5807 a construcciones del lenguaje C.
- Asegurar que el código generado sea compatible con el estándar C99 y compile sin errores en GCC/Clang.
- Integrar un visor de código con resaltado de sintaxis dentro del editor de la aplicación.
- Generar automáticamente especificadores de formato correctos para operaciones de entrada/salida.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Código generado con errores de compilación | Pruebas automáticas de compilación cruzada con GCC tras cada caso de prueba |
| Código generado poco legible | Implementación de formateador automático con indentación y comentarios consistentes |
| Cobertura incompleta de estructuras de control | Definir y validar el mapeo de cada símbolo ISO 5807 antes de la implementación |
| Regresiones en el motor de análisis del Ciclo 4 | Mantener y ejecutar la suite de pruebas del ciclo anterior durante el desarrollo |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Jerarquía completa de nodos AST con patrón Visitor para recorrido y procesamiento.
- Optimizador del AST con cuatro niveles de optimización configurables.
- Generador de código C funcional con mapeo completo de los símbolos del estándar ISO 5807.
- Formateador automático de código con indentación y estilo consistentes.
- Generación correcta de especificadores de formato según el tipo de variable.
- Visor de código integrado en el editor con resaltado de sintaxis.
- Suite de pruebas del generador de código con validación de compilabilidad en GCC.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 5: documentación de la arquitectura del AST, optimizador y generador de código.
- Plan detallado para el Ciclo 6: Integración.

---

## Ciclo 6: Integración

**(Abril – Mayo 2026)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Integrar todas las fases del transpilador en un pipeline de compilación completo y funcional.
- Conectar el motor del compilador con el editor visual para un flujo continuo desde la creación del diagrama hasta la generación de código.
- Implementar el mapeo completo de los símbolos ISO 5807 a código C en el pipeline integrado.
- Desarrollar la suite completa de pruebas de integración que valide el flujo end-to-end.
- Optimizar el rendimiento global del sistema y resolver incompatibilidades entre módulos.
- Implementar visualización estructurada de los resultados de compilación con indicadores de severidad.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Incompatibilidades entre módulos desarrollados en ciclos anteriores | Pruebas de integración continua y definición de interfaces contractuales entre componentes |
| Degradación de rendimiento al combinar todos los módulos | Perfilado del sistema y optimización dirigida a cuellos de botella identificados |
| Errores difíciles de reproducir en el flujo completo | Registro detallado de logs de compilación y cobertura de pruebas end-to-end |
| Problemas de usabilidad en la presentación de resultados | Revisión con usuarios objetivo y ajuste iterativo de la interfaz de resultados |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Pipeline de compilación completamente integrado y funcional.
- Integración UI–Compilador con control de compilación accesible desde el editor.
- Diálogo de resultados de compilación con visualización por fases (léxico, AST, semántico, optimización, código).
- Sistema de visualización de errores con colores según severidad (fatal, error, advertencia, información).
- Suite de pruebas de integración con cobertura de los casos de uso principales del sistema.
- Validación de código generado mediante compilación exitosa con GCC.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 6: documentación de la integración, pruebas realizadas y métricas de rendimiento.
- Plan detallado para el Ciclo 7: Pruebas y Documentación.

---

## Ciclo 7: Pruebas y Documentación

**(Mayo – Junio 2026)**

### Fase 1: Determinación de Objetivos

**Objetivos del ciclo:**

- Ejecutar la suite completa de pruebas funcionales, de rendimiento y de robustez del sistema.
- Validar el cumplimiento de los criterios de aceptación establecidos en la metodología (CA-01 a CA-04).
- Evaluar métricas de precisión en la detección de errores (falsos positivos y falsos negativos).
- Documentar las limitaciones identificadas y los casos fuera del alcance del proyecto.
- Elaborar el manual de usuario con guías de operación claras y ejemplos prácticos.
- Redactar la documentación técnica completa de la arquitectura, decisiones de diseño y resultados obtenidos.

### Fase 2: Análisis de Riesgos

**Riesgos identificados y estrategias de mitigación:**

| Riesgo | Estrategia de Mitigación |
|--------|--------------------------|
| Métricas de compilación no alcanzadas al momento de las pruebas | Optimización del motor de conversión y ajuste de reglas semánticas según resultados |
| Documentación insuficiente o de baja calidad | Revisión periódica por parte del director del TT y uso de plantillas estandarizadas |
| Tiempo insuficiente para cubrir todos los casos de prueba | Priorización de casos de prueba críticos y uso de la suite automatizada existente |
| Defectos encontrados tardíamente que requieren correcciones mayores | Estrategia de corrección mínima para no comprometer la estabilidad del sistema |

### Fase 3: Desarrollo y Verificación

**Productos generados:**

- Aplicación final validada con todas las pruebas aprobadas.
- Informe de pruebas funcionales, de rendimiento y de robustez con evidencias.
- Evaluación del cumplimiento de criterios de aceptación CA-01 a CA-04.
- Manual de usuario completo con guías paso a paso y ejemplos ilustrativos.
- Documentación técnica de la arquitectura del sistema, decisiones de diseño y resultados.
- Registro de limitaciones identificadas y trabajo futuro recomendado.

### Fase 4: Planificación

**Entregables:**

- Informe Ciclo 7 e Informe Final del Trabajo Terminal.
- Manual de usuario y documentación técnica completos.
- Presentación para la defensa del Trabajo Terminal.
- Entrega formal de la documentación ante los directores y el comité evaluador.
