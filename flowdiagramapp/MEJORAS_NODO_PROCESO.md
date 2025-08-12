# Mejoras al Diálogo del Nodo de Proceso

## 📋 Descripción

Se ha implementado un nuevo diálogo especializado para la edición de nodos de proceso, diseñado específicamente para **usuarios no programadores**. Este diálogo sigue los estándares **ANSI/ISO 5807** para símbolos de diagramas de flujo.

## ✨ Características Principales

### 🎯 Interfaz Amigable para No Programadores

El nuevo diálogo incluye las siguientes opciones predefinidas:

#### 1. **Asignación Simple**
- **Uso**: Asignar un valor a una variable
- **Formato visual**: `Variable = Valor`
- **Ejemplo**: `edad = 25`
- **Campos**:
  - Variable (nombre de la variable)
  - Valor (número o nombre de otra variable)

#### 2. **Operación Matemática**
- **Uso**: Realizar cálculos entre dos variables
- **Formato visual**: `Resultado = Variable1 [Operador] Variable2`
- **Ejemplo**: `suma = a + b`
- **Campos**:
  - Resultado (variable donde guardar el resultado)
  - Variable 1 (primera variable)
  - Operador (selección entre +, -, ×, ÷, %)
  - Variable 2 (segunda variable)

#### 3. **Incrementar Variable**
- **Uso**: Sumar 1 a una variable
- **Formato visual**: `Variable = Variable + 1`
- **Ejemplo**: `contador = contador + 1`
- **Campos**:
  - Variable (nombre de la variable a incrementar)

#### 4. **Decrementar Variable**
- **Uso**: Restar 1 a una variable
- **Formato visual**: `Variable = Variable - 1`
- **Ejemplo**: `contador = contador - 1`
- **Campos**:
  - Variable (nombre de la variable a decrementar)

#### 5. **Escribir Manualmente**
- **Uso**: Para usuarios avanzados que prefieren escribir código directamente
- **Formato**: Texto libre
- **Ejemplo**: `resultado = (a + b) * c`

### 🔍 Vista Previa en Tiempo Real

- **Previsualización instantánea**: El diálogo muestra cómo quedará el código generado
- **Actualización en tiempo real**: La vista previa se actualiza automáticamente al cambiar los campos
- **Formato de código**: Utiliza tipografía monospace para simular código

### 🧠 Interpretación Inteligente

El diálogo puede **interpretar automáticamente** el texto existente en el nodo:

- **Operaciones aritméticas**: Detecta patrones como `suma = a + b`
- **Asignaciones simples**: Reconoce patrones como `edad = 25`
- **Incrementos/Decrementos**: Identifica patrones como `contador++` o `i = i + 1`
- **Fallback inteligente**: Si no reconoce el patrón, utiliza el modo "Escribir Manualmente"

### 📐 Cumplimiento de Estándares ANSI/ISO 5807

- **Símbolo**: Rectángulo (forma correcta según estándar)
- **Uso**: Operaciones, cálculos, asignaciones
- **Propósito**: Representar procesos de transformación de datos

## 🛠️ Implementación Técnica

### Archivos Modificados

1. **`/lib/widgets/process_node_dialog.dart`** (NUEVO)
   - Diálogo especializado para nodos de proceso
   - Interfaz amigable con opciones predefinidas
   - Vista previa en tiempo real
   - Parseo inteligente de texto existente

2. **`/lib/widgets/node_editor_dialog.dart`** (MODIFICADO)
   - Integración del nuevo diálogo para nodos de proceso
   - Mantiene compatibilidad con otros tipos de nodos

### Estructura del Código

```dart
class ProcessNodeDialog extends StatefulWidget {
  // Tipos de operaciones predefinidas
  final Map<String, String> operationTypes = {
    'assignment': 'Asignación Simple',
    'arithmetic': 'Operación Matemática',
    'increment': 'Incrementar Variable',
    'decrement': 'Decrementar Variable',
    'custom': 'Escribir Manualmente',
  };

  // Operadores matemáticos
  final Map<String, String> operators = {
    '+': 'Sumar (+)',
    '-': 'Restar (-)',
    '*': 'Multiplicar (×)',
    '/': 'Dividir (÷)',
    '%': 'Módulo (%)',
  };
}
```

## 🚀 Beneficios para Usuarios No Programadores

### ✅ Ventajas del Nuevo Diálogo

1. **Sin conocimiento de sintaxis**: Los usuarios no necesitan conocer la sintaxis de programación
2. **Opciones guiadas**: Selección de tipo de operación con explicaciones claras
3. **Prevención de errores**: Interfaz estructurada reduce errores de sintaxis
4. **Aprendizaje progresivo**: Los usuarios pueden ver cómo se traduce su selección a código
5. **Flexibilidad**: Opción de escritura manual para usuarios más avanzados

### 📈 Mejora en la Experiencia de Usuario

- **Reducción de la curva de aprendizaje**
- **Interfaz más intuitiva y visual**
- **Menor probabilidad de errores**
- **Mayor confianza para usuarios principiantes**

## 🔮 Próximos Pasos

Este enfoque puede extenderse a otros tipos de nodos:

1. **Nodo de Decisión**: Opciones predefinidas para comparaciones (mayor que, menor que, igual a)
2. **Nodo de Entrada**: Plantillas para diferentes tipos de entrada (texto, números)
3. **Nodo de Salida**: Formatos predefinidos para mostrar resultados
4. **Nodo de Variable**: Asistente para declaración de tipos de datos
5. **Nodo de Bucle**: Configurador visual para diferentes tipos de bucles

## 📸 Capturas de Pantalla

(Añadir capturas de pantalla del nuevo diálogo en acción)

---

**Desarrollado siguiendo los estándares ANSI/ISO 5807 y principios de diseño UX para usuarios no técnicos.**
