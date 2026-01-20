# 📘 Documentación de Metadata Keys para Nodos de Diagrama

## 🎯 Propósito

Este documento define las claves de metadata estándar utilizadas en `DiagramNode` para identificar y procesar estructuras de control de programación en el transpilador fuente-a-fuente.

---

## 🔑 Metadata Keys Estándar

### Claves Comunes (Todas las Estructuras)

| Key | Tipo | Descripción | Valores Posibles |
|-----|------|-------------|------------------|
| `structureType` | `String` | Tipo de estructura de control | `'loop'`, `'switch'`, `'conditional'` |
| `role` | `String` | Rol del nodo dentro de la estructura | Ver tabla específica por estructura |

---

## 🔄 Estructura: Loop (For/While)

### Keys de Metadata

| Key | Tipo | Descripción | Valores Posibles | Ejemplo |
|-----|------|-------------|------------------|---------|
| `structureType` | `String` | Identifica como bucle | `'loop'` | `'loop'` |
| `loopType` | `String` | Tipo específico de bucle | `'for'`, `'while'`, `'do-while'` | `'for'` |
| `role` | `String` | Rol del nodo en el bucle | `'loop-init'`, `'loop-condition'`, `'loop-body'`, `'loop-increment'` | `'loop-condition'` |

### Roles Definidos

#### `'loop-condition'` (NodeType.decision)
- **Propósito:** Nodo de decisión que evalúa la condición del bucle
- **Usado en:** For, While, Do-While
- **Ejemplo de texto:** `"i < 10"`, `"contador < limite"`

#### `'loop-body'` (NodeType.process)
- **Propósito:** Nodo de proceso que contiene el cuerpo del bucle
- **Usado en:** For, While, Do-While
- **Ejemplo de texto:** `"// Cuerpo del for\ni++"`, `"printf(\"%d\", i);"`

#### `'loop-init'` (NodeType.preparation) [Futuro]
- **Propósito:** Nodo de inicialización del bucle (hexágono)
- **Usado en:** For, While
- **Ejemplo de texto:** `"i = 0; i < 10; i++"`, `"contador = 0"`

#### `'loop-increment'` (NodeType.process) [Futuro]
- **Propósito:** Nodo de incremento separado
- **Usado en:** For (opcionalmente)
- **Ejemplo de texto:** `"i++"`, `"contador += 2"`

### Ejemplos de Uso

#### For Loop (Implementación Actual)
```dart
// Nodo de condición
DiagramNode(
  type: NodeType.decision,
  text: 'i < 10',
  metadata: {
    'structureType': 'loop',
    'loopType': 'for',
    'role': 'loop-condition',
  },
)

// Nodo de cuerpo
DiagramNode(
  type: NodeType.process,
  text: '// Cuerpo del for\ni++',
  metadata: {
    'structureType': 'loop',
    'loopType': 'for',
    'role': 'loop-body',
  },
)
```

#### While Loop (Implementación Actual)
```dart
// Nodo de condición
DiagramNode(
  type: NodeType.decision,
  text: 'condicion',
  metadata: {
    'structureType': 'loop',
    'loopType': 'while',
    'role': 'loop-condition',
  },
)

// Nodo de cuerpo
DiagramNode(
  type: NodeType.process,
  text: '// Cuerpo del while',
  metadata: {
    'structureType': 'loop',
    'loopType': 'while',
    'role': 'loop-body',
  },
)
```

---

## 🔀 Estructura: Switch

### Keys de Metadata

| Key | Tipo | Descripción | Valores Posibles | Ejemplo |
|-----|------|-------------|------------------|---------|
| `structureType` | `String` | Identifica como switch | `'switch'` | `'switch'` |
| `role` | `String` | Rol del nodo en el switch | `'switch-header'`, `'switch-case'`, `'switch-case-body'`, `'switch-default'` | `'switch-header'` |
| `variable` | `String` | Variable evaluada en switch | Nombre de variable | `'opcion'`, `'color'` |
| `caseValue` | `String` | Valor del caso (solo en cases) | Valor constante | `'1'`, `'2'`, `'n'`, `'RED'` |
| `parentSwitch` | `String` | Variable del switch padre | Nombre de variable | `'opcion'` |

### Roles Definidos

#### `'switch-header'` (NodeType.process)
- **Propósito:** Nodo de proceso que declara el switch
- **Keys adicionales:** `variable`
- **Ejemplo de texto:** `"switch(opcion)"`
- **Ejemplo:**
```dart
DiagramNode(
  type: NodeType.process,
  text: 'switch(opcion)',
  metadata: {
    'structureType': 'switch',
    'role': 'switch-header',
    'variable': 'opcion',
  },
)
```

#### `'switch-case'` (NodeType.decision)
- **Propósito:** Nodo de decisión que evalúa un caso
- **Keys adicionales:** `caseValue`, `parentSwitch`
- **Ejemplo de texto:** `"opcion == 1"`, `"color == RED"`
- **Ejemplo:**
```dart
DiagramNode(
  type: NodeType.decision,
  text: 'opcion == 1',
  metadata: {
    'structureType': 'switch',
    'role': 'switch-case',
    'caseValue': '1',
    'parentSwitch': 'opcion',
  },
)
```

#### `'switch-case-body'` (NodeType.process)
- **Propósito:** Nodo de proceso con el código del caso
- **Keys adicionales:** `caseValue`
- **Ejemplo de texto:** `"// Caso 1"`, `"printf(\"Opción 1\");"`
- **Ejemplo:**
```dart
DiagramNode(
  type: NodeType.process,
  text: '// Caso 1',
  metadata: {
    'structureType': 'switch',
    'role': 'switch-case-body',
    'caseValue': '1',
  },
)
```

#### `'switch-default'` (NodeType.process)
- **Propósito:** Nodo de proceso para el caso default
- **Keys adicionales:** `parentSwitch`
- **Ejemplo de texto:** `"// Default"`, `"printf(\"Opción inválida\");"`
- **Ejemplo:**
```dart
DiagramNode(
  type: NodeType.process,
  text: '// Default',
  metadata: {
    'structureType': 'switch',
    'role': 'switch-default',
    'parentSwitch': 'opcion',
  },
)
```

### Ejemplo Completo: Estructura Switch

```dart
void _addSwitchConcept(Offset position) {
  final nodes = [
    // Header
    DiagramNode(
      type: NodeType.process,
      text: 'switch(opcion)',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-header',
        'variable': 'opcion',
      },
    ),
    
    // Case 1
    DiagramNode(
      type: NodeType.decision,
      text: 'opcion == 1',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case',
        'caseValue': '1',
        'parentSwitch': 'opcion',
      },
    ),
    DiagramNode(
      type: NodeType.process,
      text: '// Caso 1',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-case-body',
        'caseValue': '1',
      },
    ),
    
    // Default
    DiagramNode(
      type: NodeType.process,
      text: '// Default',
      metadata: {
        'structureType': 'switch',
        'role': 'switch-default',
        'parentSwitch': 'opcion',
      },
    ),
  ];
}
```

---

## 🎯 Estructura: If-Else (Futuro)

### Keys de Metadata Propuestos

| Key | Tipo | Descripción | Valores Posibles |
|-----|------|-------------|------------------|
| `structureType` | `String` | Identifica como condicional | `'conditional'` |
| `role` | `String` | Rol del nodo | `'if-condition'`, `'if-true-body'`, `'if-false-body'` |

---

## 🔍 Uso en el Generador de Código

### Detección de Estructuras

El generador de código utiliza metadata para:

1. **Prioridad 1: Detección por metadata**
```dart
if (node.metadata['structureType'] == 'switch' &&
    node.metadata['role'] == 'switch-header') {
  // Generar código switch
}
```

2. **Prioridad 2: Detección por patrón de texto (fallback)**
```dart
if (node.text.trim().toLowerCase().startsWith('switch(')) {
  // Generar código switch
}
```

### Ejemplo de Generación de Switch

```dart
void _generateSwitchCode(DiagramNode switchNode, ...) {
  // Extraer variable del metadata
  final variable = switchNode.metadata['variable'] ?? 
                   _extractSwitchVariable(switchNode.text);
  
  buffer.writeln('switch($variable) {');
  
  // Buscar casos usando metadata
  final cases = nodes.where((n) => 
    n.metadata['structureType'] == 'switch' &&
    n.metadata['role'] == 'switch-case' &&
    n.metadata['parentSwitch'] == variable
  );
  
  for (var caseNode in cases) {
    final caseValue = caseNode.metadata['caseValue'];
    buffer.writeln('    case $caseValue:');
    // Generar cuerpo...
    buffer.writeln('        break;');
  }
  
  buffer.writeln('}');
}
```

---

## ✅ Beneficios del Sistema de Metadata

### 🎯 Robustez
- No depende del formato exacto del texto
- Funciona con diferentes idiomas/sintaxis
- Resiste cambios en el texto del nodo

### 🚀 Escalabilidad
- Fácil agregar nuevas estructuras
- Facilita análisis semántico avanzado
- Preparado para optimizaciones

### 🔒 Precisión
- Identificación explícita de intención
- Reduce ambigüedad en el análisis
- Mejora la calidad del código generado

### 🔄 Compatibilidad
- Funciona con diagramas antiguos (sin metadata)
- Sistema de fallback por patrón de texto
- No rompe código existente

---

## 📋 Checklist de Implementación

### ✅ FASE 1: Modelo de Datos
- [x] Agregar campo `metadata` a `DiagramNode`
- [x] Hacer metadata no-nullable con valor por defecto
- [x] Actualizar serialización en `SavedDiagram`
- [x] Agregar métodos auxiliares (`copyWith`, `getMetadata`, etc.)

### ✅ FASE 2: Plantillas con Metadata
- [x] Actualizar `_addForLoopConcept()` con metadata
- [x] Actualizar `_addWhileLoopConcept()` con metadata
- [x] Actualizar `_addSwitchConcept()` con metadata
- [x] Documentar keys de metadata estándar

### 🔄 FASE 3: Detección Inteligente (Siguiente)
- [ ] Implementar `_detectLoopType()` en `code_generator.dart`
- [ ] Implementar `_isSwitchStatement()` en `code_generator.dart`
- [ ] Implementar `_generateSwitchCode()` en `code_generator.dart`
- [ ] Implementar `_generateForLoopCode()` actualizado
- [ ] Implementar `_generateWhileLoopCode()` actualizado

---

## 📚 Recursos Adicionales

- [Documentación ISO 5807](https://www.iso.org/standard/11955.html)
- [ARCHITECTURE_DOCUMENTATION.md](./ARCHITECTURE_DOCUMENTATION.md)
- [README.md](./README.md)

---

**Última actualización:** 2026-01-19  
**Versión del sistema:** 1.0  
**Autor:** FlowCode Team
