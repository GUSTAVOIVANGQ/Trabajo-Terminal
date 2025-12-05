# Validación del Nodo Subproceso/Función

## 🎯 Propósito

Este documento describe las reglas de validación específicas para los nodos de tipo **Subproceso/Función** en el editor de diagramas de flujo. Los nodos de subproceso representan llamadas a funciones, procedimientos o módulos externos.

---

## ✅ Reglas de Validación Estructural

### 1. Conectividad Básica

#### ✓ Debe tener exactamente UNA conexión entrante
- Un subproceso debe ser invocado desde un punto específico del flujo
- **Error si**: El nodo no tiene ninguna conexión entrante
- **Mensaje**: "El subproceso '[nombre]' no tiene conexión entrante"

#### ✓ Debe tener exactamente UNA conexión saliente
- Después de ejecutar el subproceso, el flujo debe continuar
- **Error si**: El nodo no tiene conexión saliente
- **Mensaje**: "El subproceso '[nombre]' no tiene conexión saliente"

### 2. Validación de Contenido

#### ✓ El texto NO puede estar vacío
- Todo subproceso debe tener un nombre de función
- **Error si**: `node.text.trim().isEmpty`
- **Mensaje**: "El nodo de subproceso está vacío. Debe contener el nombre de una función"

#### ✓ Formato de llamada a función
- El texto debe tener formato válido de función con paréntesis
- **Formatos válidos**:
  - `nombreFuncion()`
  - `nombreFuncion(param1, param2)`
  - `resultado = nombreFuncion(parametros)`
- **Advertencia si**: No contiene paréntesis `(` y `)`
- **Mensaje**: "El texto '[texto]' no tiene formato de llamada a función. Considere agregar paréntesis ()"

---

## 📋 Tipos de Subproceso Soportados

### 1. Llamada Simple
```
nombreFuncion()
```
- **Descripción**: Función sin parámetros ni retorno explícito
- **Ejemplo**: `inicializarSistema()`
- **Código C generado**: `inicializarSistema();`

### 2. Llamada con Parámetros
```
nombreFuncion(param1, param2, ...)
```
- **Descripción**: Función que recibe argumentos
- **Ejemplo**: `calcularArea(base, altura)`
- **Código C generado**: `calcularArea(base, altura);`

### 3. Llamada con Retorno
```
resultado = nombreFuncion(parametros)
```
- **Descripción**: Función que devuelve un valor asignado a una variable
- **Ejemplo**: `promedio = calcularPromedio(datos, n)`
- **Código C generado**: `promedio = calcularPromedio(datos, n);`

---

## 🔧 Validación en el Código

### Implementación en `diagram_validator.dart`

```dart
// Los nodos de subproceso son tratados como nodos de acción normales
case NodeType.subprocess:
  if (node.text.trim().isEmpty) {
    errors.add(DiagramError(
      type: ErrorType.emptyNode,
      nodeId: node.id,
      message: 'El nodo de subproceso está vacío',
    ));
  }
  
  // Validar conectividad
  if (incomingConnections == 0) {
    errors.add(DiagramError(
      type: ErrorType.disconnected,
      nodeId: node.id,
      message: 'El subproceso "${node.text}" no tiene conexión entrante',
    ));
  }
  
  if (outgoingConnections == 0) {
    errors.add(DiagramError(
      type: ErrorType.disconnected,
      nodeId: node.id,
      message: 'El subproceso "${node.text}" no tiene conexión saliente',
    ));
  }
```

---

## 🎨 Validación en el Diálogo

El archivo `subprocess_node_dialog.dart` incluye validación en tiempo real:

### Validación de Nombre de Función
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre de la función no puede estar vacío';
  }
  if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value)) {
    return 'Nombre de función inválido. Use solo letras, números y guiones bajos';
  }
  return null;
}
```

### Validación de Parámetros
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ingrese al menos un parámetro';
  }
  // Validar formato de lista separada por comas
  if (!RegExp(r'^[a-zA-Z0-9_\s,]+$').hasMatch(value)) {
    return 'Parámetros inválidos. Use comas para separar';
  }
  return null;
}
```

### Validación de Variable de Resultado
```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'El nombre de la variable no puede estar vacío';
  }
  if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(value)) {
    return 'Nombre de variable inválido';
  }
  return null;
}
```

---

## 🔍 Casos de Error Comunes

### ❌ Error 1: Subproceso sin conexión entrante
```
[Proceso A]

[calcularTotal()] ← Sin conexión desde Proceso A
     ↓
[Proceso B]
```
**Solución**: Conectar el nodo anterior al subproceso

---

### ❌ Error 2: Subproceso sin conexión saliente
```
[Proceso A]
     ↓
[procesarDatos()] ← Sin conexión a siguiente nodo

[Proceso B]
```
**Solución**: Conectar el subproceso al siguiente nodo en el flujo

---

### ❌ Error 3: Texto vacío
```
[Proceso A]
     ↓
[(vacío)] ← Nodo sin texto
     ↓
[Proceso B]
```
**Solución**: Editar el nodo y agregar el nombre de la función

---

### ⚠️ Advertencia: Sin paréntesis
```
calcularArea
```
**Mejor práctica**: Usar `calcularArea()` o `calcularArea(base, altura)`

---

## 📊 Flujo de Validación

```
Inicio de Validación
         ↓
¿Nodo tiene texto? ─NO→ Error: "Nodo vacío"
         ↓ SÍ
¿Tiene formato de función? ─NO→ Advertencia: "Agregar paréntesis"
         ↓ SÍ
¿Tiene conexión entrante? ─NO→ Error: "Sin entrada"
         ↓ SÍ
¿Tiene conexión saliente? ─NO→ Error: "Sin salida"
         ↓ SÍ
    Validación OK
```

---

## 🎯 Mejores Prácticas

### ✅ Hacer:
1. **Usar nombres descriptivos**: `calcularPromedio()` en vez de `cp()`
2. **Incluir paréntesis siempre**: Aunque no haya parámetros
3. **Asignar retornos cuando corresponda**: `resultado = funcion()` en vez de solo `funcion()`
4. **Separar parámetros con comas**: `calcular(a, b, c)` no `calcular(a b c)`

### ❌ Evitar:
1. **Nombres genéricos**: `hacer()`, `proceso()`
2. **Omitir paréntesis**: `calcular` en vez de `calcular()`
3. **Espacios en nombres**: `calcular promedio()` en vez de `calcularPromedio()`
4. **Caracteres especiales**: `calcular@total()` no es válido

---

## 🔗 Integración con Generador de Código

El validador trabaja en conjunto con el generador de código (`code_generator.dart`):

```dart
// El método _formatSubprocessCall garantiza sintaxis correcta
static String _formatSubprocessCall(String text) {
  if (text.contains('(') && text.contains(')')) {
    return text; // Ya tiene formato correcto
  }
  return "$text()"; // Agregar paréntesis vacíos
}
```

**Resultado**: Incluso si el usuario olvida los paréntesis, el código generado será válido.

---

## 📝 Ejemplo de Validación Completa

### Diagrama Válido ✅
```
[Inicio]
   ↓
[n = solicitarNumero()]
   ↓
[resultado = factorial(n)]
   ↓
[mostrarResultado(resultado)]
   ↓
[Fin]
```

### Código C Generado
```c
#include <stdio.h>

int main() {
    // Llamada a subproceso/función
    n = solicitarNumero();
    
    // Llamada a subproceso/función
    resultado = factorial(n);
    
    // Llamada a subproceso/función
    mostrarResultado(resultado);
    
    return 0;
}
```

---

## 🔧 Archivos Relacionados

- `lib/models/diagram_validator.dart` - Lógica de validación estructural
- `lib/widgets/subprocess_node_dialog.dart` - Validación en tiempo real del diálogo
- `lib/models/code_generator.dart` - Validación sintáctica para generación de código
- `RESUMEN_SIMBOLO_SUBPROCESO.md` - Documentación completa del símbolo

---

**Versión**: 1.0  
**Fecha**: 2025  
**Estándar**: ANSI/ISO 5807
