# Resumen del Símbolo: Subproceso/Función

## 📋 Información General

**Símbolo**: Subproceso/Función  
**Forma**: Rectángulo con doble línea de borde  
**Color**: Morado/Violeta (#8B5CF6 en modo claro, #A78BFA en modo oscuro)  
**Icono en paleta**: `Icons.account_tree_outlined`  
**Propósito**: Representar llamadas a subprocesos, funciones o procedimientos que encapsulan lógica modular.

---

## 🎨 Características Visuales

### Forma del Nodo
- **Geometría**: Rectángulo con **doble línea de borde**
- **Tamaño**: 160x80 píxeles
- **Renderizado**: Se dibuja un rectángulo exterior y uno interior con 4 píxeles de margen

```dart
case NodeType.subprocess:
  final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
  final innerRect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
  path.addRect(outerRect);
  path.addRect(innerRect);
```

### Colores del Tema

- Modo claro: `Color(0xFF8B5CF6)` (Morado/Violeta)
- Modo oscuro: `Color(0xFFA78BFA)` (Violeta claro)

---

## 💬 Diálogo Especializado

El nodo de subproceso cuenta con un diálogo especializado (`subprocess_node_dialog.dart`) que facilita la creación de llamadas a funciones sin necesidad de conocer sintaxis de programación.

### 5 Tipos de Subproceso

#### 1. **Llamada Simple**
- **Uso**: Llamar a una función sin parámetros
- **Formato**: `nombreFuncion()`
- **Ejemplo**: `inicializarSistema()`

#### 2. **Llamada con Parámetros**
- **Uso**: Llamar a una función con argumentos
- **Formato**: `nombreFuncion(param1, param2, ...)`
- **Ejemplo**: `calcularArea(base, altura)`

#### 3. **Llamada con Retorno**
- **Uso**: Asignar el valor de retorno de una función a una variable
- **Formato**: `resultado = nombreFuncion(parametros)`
- **Ejemplo**: `promedio = calcularPromedio(datos, n)`

#### 4. **Función Predefinida**
- **Uso**: Seleccionar de un catálogo de funciones matemáticas comunes
- **Funciones disponibles**:
  - `calcularPromedio(datos, n)`
  - `encontrarMaximo(arreglo, tamaño)`
  - `encontrarMinimo(arreglo, tamaño)`
  - `ordenarArreglo(arreglo, tamaño)`
  - `factorial(n)`
  - `potencia(base, exponente)`
  - `raizCuadrada(numero)`
  - `calcularMCD(a, b)`

#### 5. **Personalizado**
- **Uso**: Para casos avanzados donde se requiere control total
- **Formato**: Texto libre

---

## 🔧 Integración en el Sistema

### 1. Modelo de Datos (`diagram_node.dart`)
```dart
enum NodeType {
  // ... otros tipos
  subprocess,
}

Size get size {
  // ...
  case NodeType.subprocess:
    return const Size(160, 80);
}
```

### 2. Paleta de Nodos (`node_palette.dart`)
```dart
_NodePaletteItem(
  type: NodeType.subprocess,
  icon: Icons.account_tree_outlined,
  label: 'Subproceso',
),
```

### 3. Editor de Nodos (`node_editor_dialog.dart`)
```dart
case NodeType.subprocess:
  return const SubprocessNodeDialog();
```

### 4. Renderizado en Canvas (`flow_diagram_canvas_final.dart`)
```dart
case NodeType.subprocess:
  return nodeColors['subprocess']!;
```

---

## 🔄 Generación de Código C

El generador de código traduce los nodos de subproceso a llamadas de función válidas en C:

```dart
case NodeType.subprocess:
  code.writeln("${indent}// Llamada a subproceso/función");
  code.writeln("${indent}${_formatSubprocessCall(node.text)};");
  _processNextNodes(node, allNodes, connections, code, indent, processedNodes);
  break;
```

### Método Helper: `_formatSubprocessCall`
```dart
static String _formatSubprocessCall(String text) {
  // Si ya tiene el formato correcto de llamada a función, devolverlo tal cual
  if (text.contains('(') && text.contains(')')) {
    if (text.startsWith('resultado = ')) {
      return text;
    }
    return text;
  }
  
  // Si no tiene formato de función, agregarlo
  return "$text()";
}
```

### Ejemplos de Salida en C

**Entrada en diagrama**: `calcularArea(base, altura)`  
**Salida en C**:
```c
// Llamada a subproceso/función
calcularArea(base, altura);
```

**Entrada en diagrama**: `suma = sumar(a, b)`  
**Salida en C**:
```c
// Llamada a subproceso/función
suma = sumar(a, b);
```

---

## ✅ Validación

El validador de diagramas trata los nodos de subproceso como nodos de acción regulares:

- **Debe tener conexión entrante**: Sí
- **Debe tener conexión saliente**: Sí
- **Puede tener múltiples salidas**: No
- **Validación de texto**: El texto debe tener formato de función válido

---

## 📊 Casos de Uso

1. **Modularidad**: Dividir algoritmos complejos en funciones reutilizables
2. **Abstracción**: Ocultar detalles de implementación detrás de una interfaz simple
3. **Reutilización**: Llamar a la misma función desde múltiples puntos del diagrama
4. **Organización**: Mejorar la legibilidad separando lógica en bloques funcionales

---

## 🎯 Beneficios para Usuarios No Programadores

- **Catálogo de funciones predefinidas**: No necesitan memorizar nombres de funciones
- **Formato guiado**: El diálogo construye la sintaxis automáticamente
- **Validación visual**: El rectángulo con doble línea es fácilmente reconocible
- **Ejemplos contextuales**: Cada tipo de llamada incluye ejemplos prácticos

---

## 📝 Ejemplo Completo

### Diagrama Visual
```
[Inicio]
   ↓
[datos = obtenerDatos()]  ← Subproceso con retorno
   ↓
[procesarDatos(datos)]    ← Subproceso con parámetros
   ↓
[Fin]
```

### Código C Generado
```c
#include <stdio.h>

int main() {
    // Llamada a subproceso/función
    datos = obtenerDatos();
    
    // Llamada a subproceso/función
    procesarDatos(datos);
    
    return 0;
}
```

---

## 🔗 Archivos Relacionados

- `lib/models/diagram_node.dart` - Definición del tipo y forma
- `lib/widgets/subprocess_node_dialog.dart` - Diálogo especializado (450+ líneas)
- `lib/widgets/node_editor_dialog.dart` - Integración del diálogo
- `lib/models/code_generator.dart` - Generación de código C
- `lib/models/diagram_validator.dart` - Validación de conectividad
- `lib/themes/app_themes.dart` - Definición de colores
- `lib/widgets/node_palette.dart` - Icono en paleta
- `lib/widgets/flow_diagram_canvas_final.dart` - Renderizado en canvas

---

**Fecha de implementación**: 2025  
**Estándar**: ANSI/ISO 5807 (Símbolo de subrutina/función predefinida)
