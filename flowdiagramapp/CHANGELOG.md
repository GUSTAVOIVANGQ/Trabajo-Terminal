# Changelog - FlowCode

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [2.0.0] - 2026-01-19

### 🎉 Versión Mayor - Sistema de Metadata Inteligente

Esta versión introduce un cambio fundamental en cómo FlowCode genera código C para estructuras de control avanzadas.

### ✨ Agregado

#### Sistema de Metadata Inteligente
- **Metadata en DiagramNode**: Campo `metadata` obligatorio con default vacío (`Map<String, dynamic>`)
- **Detección de doble prioridad**:
  1. Metadata explícito (100% precisión)
  2. Análisis de patrón de texto (fallback para backward compatibility)
- **Métodos auxiliares en DiagramNode**:
  - `copyWith()` - Copia con metadata modificado
  - `updateMetadata()` - Actualiza clave específica
  - `getMetadata<T>()` - Lee valor con tipo
  - `hasMetadata()` - Verifica existencia de clave

#### Generación Correcta de Switch
- ✅ Switch genera código `switch() { case: break; }` correcto
- ✅ Soporte para múltiples cases
- ✅ Soporte para caso `default`
- ✅ Extracción automática de variable evaluada
- ✅ Detección por metadata: `structureType: 'switch'`
- ✅ Fallback por patrón de texto: `switch(variable)`

**Métodos agregados:**
- `_isSwitchStatement()` - Detecta switch statement
- `_generateSwitchCode()` - Genera código switch completo
- `_generateSwitchCaseBody()` - Genera cuerpo de cada case
- `_extractSwitchVariable()` - Extrae variable del texto
- `_extractCaseValue()` - Extrae valor del case
- `_isSwitchCase()` - Detecta nodos case

#### Diferenciación For vs While
- ✅ For genera bucles `for(init; cond; incr)` específicos
- ✅ While genera bucles `while(cond)` diferenciados
- ✅ Análisis de 3 componentes del for (initialization, condition, increment)
- ✅ Detección por metadata: `loopType: 'for'` o `'while'`
- ✅ Fallback por patrón de texto: `for(...)` vs `while(...)`

**Métodos agregados:**
- `_detectLoopType()` - Identifica tipo de bucle (for/while/do-while)
- `_generateForLoopCode()` - Genera bucles for correctos
- `_generateWhileLoopCode()` - Genera bucles while correctos
- `_generateDoWhileLoopCode()` - Genera bucles do-while
- `_extractForInitialization()` - Extrae inicialización del for
- `_extractForCondition()` - Extrae condición del for
- `_extractForIncrement()` - Extrae incremento del for
- `_isLoopNode()` - Verifica si es nodo de bucle

#### Templates con Metadata
- **Concepto Switch**: 1 nodo header + 3 nodos case con metadata automático
- **Concepto For**: 1 nodo for + 1 nodo body con metadata automático
- **Concepto While**: 1 nodo while + 1 nodo body con metadata automático

**Métodos en EditorScreen:**
- `_addSwitchConcept()` - Inserta plantilla switch completa
- `_addForLoopConcept()` - Inserta plantilla for completa
- `_addWhileLoopConcept()` - Inserta plantilla while completa

#### Serialización de Metadata
- ✅ Metadata incluido en serialización a SQLite
- ✅ Deserialización con fallback a mapa vacío
- ✅ Backward compatibility con diagramas sin metadata

**Cambios en SavedDiagram:**
- `_serializeNodes()` - Incluye campo `metadata`
- `fromMap()` - Deserializa metadata con fallback

#### Suite de Pruebas (FASE 4)
- ✅ 7 pruebas exhaustivas (100% pasadas)
- ✅ Test de switch con metadata
- ✅ Test de for con metadata
- ✅ Test de while con metadata
- ✅ Test de diferenciación for vs while
- ✅ Test de fallback sin metadata (switch)
- ✅ Test de fallback sin metadata (for)
- ✅ Test de estructuras anidadas

**Archivo:** `test/code_generator_phase4_test.dart` (~500 líneas)

#### Documentación Completa
- **[GUIA_ESTRUCTURAS_CONTROL.md](GUIA_ESTRUCTURAS_CONTROL.md)** - Guía de usuario completa
- **[DOCUMENTACION_TECNICA_METADATA.md](DOCUMENTACION_TECNICA_METADATA.md)** - Arquitectura técnica
- **[METADATA_KEYS_DOCUMENTATION.md](METADATA_KEYS_DOCUMENTATION.md)** - Referencia de claves
- **[FASE_3_DETECCION_INTELIGENTE.md](FASE_3_DETECCION_INTELIGENTE.md)** - Implementación fase 3
- **[FASE_4_PRUEBAS_COMPLETADAS.md](FASE_4_PRUEBAS_COMPLETADAS.md)** - Resultados de pruebas
- **[CHANGELOG.md](CHANGELOG.md)** - Este archivo

### 🔧 Cambiado

#### CodeGenerator
- **_generateCNodeCode()**: Detecta switch antes de generar if-else
- **_generateCNodeCode()**: Detecta tipo de bucle antes de generar código genérico
- **Integración**: Switch en `NodeType.decision` ahora verifica `_isSwitchStatement()`
- **Integración**: Preparation en `NodeType.preparation` ahora detecta tipo de bucle

#### DiagramNode
- **metadata**: Cambió de `Map<String, dynamic>?` (nullable) a `Map<String, dynamic>` (non-nullable)
- **constructor**: Parámetro `metadata` ahora tiene default `const {}`

### 🐛 Corregido

- ❌→✅ **Switch generando if-else**: Ahora genera código `switch() { case: }` correcto
- ❌→✅ **For y While idénticos**: Ahora generan código completamente diferenciado
- ❌→✅ **Detección frágil por texto**: Sistema robusto con metadata + fallback

### 📊 Métricas

- **Archivos modificados**: 4 archivos principales
- **Líneas de código agregadas**: ~330 líneas en code_generator.dart
- **Líneas de documentación**: ~2000+ líneas
- **Pruebas agregadas**: 7 tests (100% pasadas)
- **Tasa de éxito**: 100%
- **Errores de compilación**: 0
- **Warnings críticos**: 0

### 🔄 Compatibilidad

- ✅ **Backward compatible**: Diagramas legacy funcionan con sistema de fallback
- ✅ **Base de datos**: Actualización automática sin migración manual
- ✅ **API pública**: Sin cambios breaking en interfaces públicas

---

## [1.x.x] - Versiones Anteriores

### Funcionalidades Base (Pre-2.0)
- Generación de código C básico
- Validación estructural de diagramas
- Símbolos ISO 5807
- Exportación a PDF
- Sistema de plantillas
- Autenticación Firebase
- Persistencia SQLite
- Sistema de ejercicios
- Modo invitado
- Tutorial interactivo

---

## [Unreleased]

### Planificado para Futuras Versiones

#### v2.1.0 - Mejoras de Optimización
- [ ] Optimización de código generado
- [ ] Eliminación de código muerto
- [ ] Simplificación de expresiones constantes

#### v2.2.0 - Nuevas Estructuras
- [ ] Soporte para do-while loop
- [ ] Switch con fall-through
- [ ] Operador ternario

#### v3.0.0 - Análisis Semántico
- [ ] Verificación de tipos
- [ ] Detección de variables no declaradas
- [ ] Análisis de alcance (scope)
- [ ] Advertencias de uso antes de declaración

#### v3.1.0 - Múltiples Lenguajes
- [ ] Generación de código Python
- [ ] Generación de código JavaScript
- [ ] Generación de código Java

---

## Notas de Versiones

### Versión 2.0.0 - Desglose de Implementación

**FASE 1: Modelo de Datos** (Completada)
- Modificación de `DiagramNode` para metadata obligatorio
- Actualización de `SavedDiagram` para serialización
- Métodos auxiliares en DiagramNode

**FASE 2: Templates con Metadata** (Completada)
- Inserción automática de metadata en conceptos
- Switch concept con 3 cases default
- For concept con metadata de 3 componentes
- While concept con metadata de condición

**FASE 3: Detección Inteligente** (Completada)
- 4 métodos de detección (switch, loop type, case, loop node)
- 4 métodos de generación (switch, for, while, do-while)
- 6 métodos auxiliares de extracción
- Integración en _generateCNodeCode()

**FASE 4: Pruebas** (Completada)
- Suite de 7 pruebas exhaustivas
- Cobertura de todos los escenarios
- 100% de tests pasados
- 0 errores encontrados

**FASE 5: Documentación** (Completada)
- Guía de usuario completa
- Documentación técnica detallada
- Referencia de API de metadata
- Changelog y versionado

---

## Cómo Reportar Bugs

Si encuentras un bug, por favor abre un issue en GitHub con:
- Descripción clara del problema
- Pasos para reproducir
- Comportamiento esperado vs real
- Screenshots si es posible
- Versión de FlowCode

## Cómo Sugerir Mejoras

Las sugerencias son bienvenidas! Por favor:
- Describe claramente la funcionalidad
- Explica el caso de uso
- Proporciona ejemplos si es posible

---

**Última actualización:** 19 de enero de 2026  
**Versión actual:** 2.0.0  
**Estado:** Estable ✅
