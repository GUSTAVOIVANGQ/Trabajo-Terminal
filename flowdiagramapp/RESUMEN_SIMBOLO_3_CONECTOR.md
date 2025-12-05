# Implementación Completa del Símbolo 3: Conector Fuera de Página

## 📋 Resumen Ejecutivo

Se ha implementado exitosamente el **Símbolo 3: Conector Fuera de Página (círculo)** para el editor de diagramas de flujo. Este símbolo cumple con el estándar **ANSI/ISO 5807** y permite dividir diagramas grandes en múltiples páginas o secciones, manteniendo la continuidad lógica del flujo.

## ✅ Funcionalidades Implementadas

### 1. ✅ Creación Correcta del Nodo

**Archivo modificado:** `lib/models/diagram_node.dart`

- **Enum actualizado:** Agregado `NodeType.connector` al enum NodeType
- **Tamaño definido:** 80x80 pixels (círculo perfecto)
- **Forma implementada:** Círculo usando `Path.addOval()` en el método `getPath()`
- **Puntos de conexión:** Funcionales en todas las direcciones (arriba, abajo, izquierda, derecha)

```dart
enum NodeType { start, end, process, decision, input, output, variable, loop, connector }

// Tamaño del conector
case NodeType.connector:
  return const Size(80, 80);

// Forma circular
case NodeType.connector:
  path.addOval(
    Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    ),
  );
```

**Colores definidos:** `lib/themes/app_themes.dart`
- Modo claro: `Color(0xFF6366F1)` (Índigo)
- Modo oscuro: `Color(0xFF818CF8)` (Índigo claro)

### 2. ✅ Validación Básica del Nuevo Símbolo

**Archivo modificado:** `lib/models/diagram_validator.dart`

Implementadas validaciones específicas para conectores:

1. **Validación de emparejamiento:** Verifica que cada etiqueta tenga al menos 2 conectores (entrada y salida)
2. **Validación de etiquetas:** Alerta cuando un conector no tiene etiqueta
3. **Validación de duplicados:** Advierte cuando hay más de 2 conectores con la misma etiqueta
4. **Validación de balance:** Verifica que existan conectores de entrada (←) y salida (→) para cada etiqueta

```dart
/// Validar conectores fuera de página
static ValidationResult _validateConnectors(List<DiagramNode> nodes) {
  // Obtener todos los nodos de tipo conector
  final connectorNodes = nodes.where((node) => node.type == NodeType.connector).toList();
  
  // Crear un mapa de etiquetas de conectores
  Map<String, List<DiagramNode>> connectorsByLabel = {};
  
  // Validaciones de etiquetas, emparejamiento y balance
  // ...
}
```

**Mensajes de validación descriptivos:**
- "El conector 'A' solo aparece una vez. Debería tener al menos un conector de entrada y uno de salida."
- "El conector 'B' aparece 3 veces. Se recomienda tener solo 2 (entrada y salida)."
- "El conector 'C' no tiene un punto de entrada (←) definido."

### 3. ✅ Generación de Código del Nuevo Símbolo

**Archivo modificado:** `lib/models/code_generator.dart`

El generador de código produce instrucciones `goto` y etiquetas en C para simular la continuación del flujo entre páginas:

```dart
case NodeType.connector:
  final label = _extractConnectorLabel(node.text);
  
  if (node.text.contains('←') || node.text.contains('DESDE')) {
    // Conector de entrada - generar una etiqueta
    code.writeln("${indent}// Conector de entrada: $label");
    code.writeln("${indent}connector_$label:");
  } else if (node.text.contains('→') || node.text.contains('HACIA')) {
    // Conector de salida - generar un goto
    code.writeln("${indent}// Conector de salida: $label");
    code.writeln("${indent}goto connector_$label;");
  }
```

**Ejemplo de código generado:**

Entrada:
```
Página 1: [Proceso A] → [Conector → B]
Página 2: [Conector ← B] → [Proceso C]
```

Salida C:
```c
// Proceso: A
a = 10;

// Conector de salida: B
goto connector_B;

// Conector de entrada: B
connector_B:

// Proceso: C
c = a + 5;
```

### 4. ✅ Funcionalidad de Guardado y Carga

**Archivos verificados:** `lib/models/saved_diagram.dart`, `lib/services/database_service.dart`

✅ **Funcionamiento automático:** El sistema de persistencia utiliza `NodeType.values.byName()` que automáticamente soporta el nuevo tipo `connector` sin necesidad de cambios adicionales.

La serialización a JSON y deserialización funciona correctamente:
```dart
type: NodeType.values.byName(nodeData['type'])
```

El nuevo nodo se guarda y carga correctamente desde SQLite.

## 🎨 Diálogo Especializado

**Archivo nuevo:** `lib/widgets/connector_node_dialog.dart`

Se creó un diálogo especializado para facilitar la configuración de conectores:

### Características del Diálogo:

1. **Selector de tipo de conector:**
   - 🔵 Entrada (Origen) - `←` - Flujo que viene de otra página
   - 🔴 Salida (Destino) - `→` - Flujo que va hacia otra página
   - 🟣 Bidireccional - `⇄` - Puede ser origen o destino

2. **Campo de etiqueta:**
   - Límite: 3 caracteres máximo
   - Capitalización automática a MAYÚSCULAS
   - Validación en tiempo real
   - Hint text: "Ej: A, B, C, 1, 2..."

3. **Vista previa en tiempo real:**
   - Muestra cómo quedará el conector con el símbolo correspondiente
   - Actualización automática al cambiar tipo o etiqueta

4. **Interpretación inteligente:**
   - Detecta símbolos Unicode: ←, →, ⇄
   - Reconoce palabras clave: DESDE, HACIA, TO, FROM, CONECTOR
   - Extrae etiqueta automáticamente del texto existente

5. **Ayuda contextual:**
   - Texto explicativo según el tipo seleccionado
   - Icono de información visible
   - Colores temáticos según modo claro/oscuro

### Ejemplo de Uso:

```
Usuario selecciona: Entrada (Origen)
Usuario ingresa: "A"
Vista previa muestra: "← A"
Al guardar, el nodo tendrá texto: "← A"
```

## 📦 Archivos Modificados

### Archivos Principales (9 archivos)

1. ✅ **lib/models/diagram_node.dart**
   - Agregado `NodeType.connector`
   - Definido tamaño 80x80
   - Implementada forma circular

2. ✅ **lib/themes/app_themes.dart**
   - Agregados colores para modo claro y oscuro
   - Índigo como color distintivo

3. ✅ **lib/widgets/node_palette.dart**
   - Agregado botón en la paleta
   - Icono: `Icons.radio_button_unchecked`
   - Etiqueta: "Conector"

4. ✅ **lib/widgets/connector_node_dialog.dart** (NUEVO)
   - Diálogo especializado completo
   - Selector de tipo de conector
   - Campo de etiqueta con validación
   - Vista previa en tiempo real
   - Interpretación inteligente

5. ✅ **lib/widgets/node_editor_dialog.dart**
   - Importado ConnectorNodeDialog
   - Agregada delegación para NodeType.connector
   - Actualizado switch case

6. ✅ **lib/models/diagram_validator.dart**
   - Método `_validateConnectors()` implementado
   - Método `_extractConnectorLabel()` para limpiar etiquetas
   - Validaciones de emparejamiento y balance
   - Actualizado `_getNodeTypeName()`

7. ✅ **lib/models/code_generator.dart**
   - Caso `NodeType.connector` en switch
   - Generación de etiquetas goto
   - Método `_extractConnectorLabel()`
   - Control de flujo según tipo de conector

8. ✅ **lib/screens/editor_screen.dart**
   - Actualizado switch de nombres de nodos
   - Método `_getNodeTypeName()` incluye "Conector"
   - Soporte completo para crear y editar

9. ✅ **lib/widgets/flow_diagram_canvas_final.dart**
   - Método `_getNodeColorByType()` incluye conector
   - Renderizado correcto con color índigo

### Archivos de Documentación (3 archivos)

10. ✅ **CONNECTOR_NODE_VALIDATION.md** (NUEVO)
    - Lista de verificación completa
    - Documentación de todas las funcionalidades
    - Ejemplos de casos de uso
    - Cumplimiento de estándares

11. ✅ **test/connector_node_dialog_test.dart** (NUEVO)
    - Script de prueba exhaustivo
    - Casos de interpretación de texto
    - Ejemplos de uso recomendados
    - Validación de características

12. ✅ **README.md**
    - Actualizada lista de nodos
    - Agregado "Nodo de conector fuera de página (círculo índigo)"

## 🎯 Casos de Uso Implementados

### Caso 1: Diagrama Grande Dividido en Páginas
```
Página 1: [Inicio] → [Proceso 1] → [Conector → A]
Página 2: [Conector ← A] → [Proceso 2] → [Fin]
```

### Caso 2: Múltiples Caminos Convergentes
```
[Decisión] → Si → [Conector → CONTINUAR]
          ↓ No → [Proceso] → [Conector → CONTINUAR]

[Conector ← CONTINUAR] → [Proceso Final] → [Fin]
```

### Caso 3: Organización Modular
```
[Inicio] → [Preparar] → [Conector → VALIDAR]
[Conector ← VALIDAR] → [Validación] → [Conector → PROCESAR]
[Conector ← PROCESAR] → [Procesamiento] → [Fin]
```

## 📊 Símbolos y Convenciones

### Símbolos Visuales
- **←** Entrada/Origen - Flujo que viene de otra página
- **→** Salida/Destino - Flujo que va hacia otra página
- **⇄** Bidireccional - Puede ser origen o destino

### Palabras Clave Reconocidas
- **Entrada:** DESDE:, FROM:, ←
- **Salida:** HACIA:, TO:, →
- **Genérico:** CONECTOR:, ⇄

### Etiquetas
- **Formato:** 1-3 caracteres en MAYÚSCULAS
- **Ejemplos válidos:** A, B, C, 1, 2, ABC, X1
- **Uso:** Identificador único para emparejar entrada/salida

## ✨ Estándares Cumplidos

### ANSI/ISO 5807
- ✅ **Símbolo:** Círculo para conector fuera de página
- ✅ **Propósito:** Conectar partes divididas en diferentes páginas
- ✅ **Etiquetas:** Identificadores únicos y claros
- ✅ **Emparejamiento:** Validación de conectores correspondientes

## 🚀 Estado Final

**✅ IMPLEMENTACIÓN 100% COMPLETA Y FUNCIONAL**

Todas las funcionalidades solicitadas han sido implementadas y verificadas:

1. ✅ **Creación correcta del nodo** - Forma circular, tamaño, colores
2. ✅ **Validación básica** - Emparejamiento, etiquetas, balance
3. ✅ **Generación de código** - Etiquetas y goto en C
4. ✅ **Guardado y carga** - Persistencia automática en SQLite
5. ✅ **Diálogo especializado** - Interfaz intuitiva con tipos y etiquetas
6. ✅ **Integración completa** - Editor, canvas, validador funcionando
7. ✅ **Documentación** - Guía completa y scripts de prueba

El símbolo de **Conector Fuera de Página** está completamente operativo y listo para ser usado en diagramas de flujo complejos que requieran división en múltiples páginas o secciones.

## 📝 Próximos Símbolos Pendientes

Del plan original, quedan por implementar:

1. ⏳ Símbolo de bucle while (decisión) - Para representar ciclos while
2. ⏳ Subproceso/función (rectángulo con doble línea) - Para modularidad
4. ⏳ Preparación/Inicialización (hexágono) - Para ciclo for y while (YA EXISTE como nodo "loop")
5. ⏳ Comentario/Nota (forma de nube o rectángulo punteado)

**Símbolo 3 (Conector): ✅ COMPLETADO**
