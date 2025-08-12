# Mejoras al Diálogo de los Nodos de Entrada y Salida

## 📋 Descripción

Se han implementado nuevos diálogos especializados para la edición de nodos de entrada y salida, diseñados específicamente para **usuarios no programadores**. Estos diálogos siguen los estándares **ANSI/ISO 5807** para símbolos de diagramas de flujo.

## ✨ Características Principales

### 🎯 Nodo de Entrada (InputNodeDialog)

El nuevo diálogo de entrada incluye las siguientes opciones predefinidas:

#### 1. **Leer Variable Simple**
- **Uso**: Entrada básica de una variable
- **Formato visual**: `Leer variable`
- **Ejemplo**: `Leer edad`
- **Campos**:
  - Variable (nombre de la variable)
  - Tipo de dato (int, float, char, string)

#### 2. **Leer con Mensaje**
- **Uso**: Mostrar un mensaje antes de solicitar la entrada
- **Formato visual**: `Mostrar "mensaje" y leer variable`
- **Ejemplo**: `Mostrar "Ingrese su edad" y leer edad`
- **Campos**:
  - Mensaje para el usuario
  - Variable donde guardar
  - Tipo de dato

#### 3. **Leer Múltiples Variables**
- **Uso**: Entrada de varias variables en una sola operación
- **Formato visual**: `Leer variable1, variable2, variable3`
- **Ejemplo**: `Leer nombre, edad, ciudad`
- **Campos**:
  - Variables (separadas por comas)

#### 4. **Leer desde Archivo**
- **Uso**: Entrada de datos desde un archivo
- **Formato visual**: `Leer variable desde archivo`
- **Ejemplo**: `Leer datos desde archivo`
- **Campos**:
  - Variable donde guardar

#### 5. **Escribir Manualmente**
- **Uso**: Para usuarios avanzados que prefieren escribir código directamente
- **Formato**: Texto libre
- **Ejemplo**: `scanf("%d", &variable)`

### 🎯 Nodo de Salida (OutputNodeDialog)

El nuevo diálogo de salida incluye las siguientes opciones predefinidas:

#### 1. **Mostrar Variable**
- **Uso**: Mostrar el valor de una variable
- **Formato visual**: `Mostrar variable`
- **Ejemplo**: `Mostrar resultado`
- **Campos**:
  - Variable a mostrar
  - Formato de salida

#### 2. **Mostrar Mensaje**
- **Uso**: Mostrar un mensaje fijo al usuario
- **Formato visual**: `Mostrar "mensaje"`
- **Ejemplo**: `Mostrar "Bienvenido al programa"`
- **Campos**:
  - Mensaje a mostrar

#### 3. **Mostrar con Formato**
- **Uso**: Mostrar variables con formato específico
- **Formato visual**: `Mostrar variable con formato: especificación`
- **Ejemplo**: `Mostrar precio con formato: %.2f`
- **Campos**:
  - Variable a mostrar
  - Formato de salida (%d, %.2f, etc.)

#### 4. **Mostrar Múltiples Variables**
- **Uso**: Mostrar varias variables en una sola operación
- **Formato visual**: `Mostrar variable1, variable2, variable3`
- **Ejemplo**: `Mostrar nombre, edad, promedio`
- **Campos**:
  - Variables (separadas por comas)

#### 5. **Guardar en Archivo**
- **Uso**: Guardar datos en un archivo
- **Formato visual**: `Guardar variable en archivo`
- **Ejemplo**: `Guardar resultados en archivo`
- **Campos**:
  - Variable a guardar

#### 6. **Escribir Manualmente**
- **Uso**: Para usuarios avanzados que prefieren escribir código directamente
- **Formato**: Texto libre
- **Ejemplo**: `printf("El resultado es: %d\\n", resultado)`

### 🔍 Vista Previa en Tiempo Real

Ambos diálogos incluyen:
- **Previsualización instantánea**: Los diálogos muestran cómo quedará el texto generado
- **Actualización en tiempo real**: La vista previa se actualiza automáticamente al cambiar los campos
- **Formato de código**: Utiliza tipografía monospace para simular código

### 🧠 Interpretación Inteligente

Los diálogos pueden **interpretar automáticamente** el texto existente en el nodo:

#### Para nodos de entrada:
- **Entrada con mensaje**: Detecta patrones como `leer "mensaje" en variable`
- **Entrada simple**: Reconoce patrones como `leer variable`
- **Múltiples variables**: Identifica patrones con comas
- **Fallback inteligente**: Si no reconoce el patrón, utiliza el modo "Escribir Manualmente"

#### Para nodos de salida:
- **Salida con formato**: Detecta patrones como `mostrar variable formato especificación`
- **Mensaje simple**: Reconoce patrones como `mostrar "mensaje"`
- **Salida simple**: Identifica patrones como `mostrar variable`
- **Múltiples variables**: Detecta patrones con comas
- **Salida a archivo**: Reconoce patrones con "archivo" o "guardar"

### 📐 Cumplimiento de Estándares ANSI/ISO 5807

- **Símbolo**: Paralelogramo (forma correcta según estándar)
- **Uso Entrada**: Recepción de datos del usuario
- **Uso Salida**: Presentación de información al usuario
- **Propósito**: Representar operaciones de entrada/salida de datos

## 🛠️ Implementación Técnica

### Archivos Creados

1. **`/lib/widgets/input_node_dialog.dart`** (NUEVO)
   - Diálogo especializado para nodos de entrada
   - Parseo inteligente de texto existente
   - Opciones predefinidas para usuarios no programadores
   - Vista previa en tiempo real

2. **`/lib/widgets/output_node_dialog.dart`** (NUEVO)
   - Diálogo especializado para nodos de salida
   - Interpretación automática de patrones de salida
   - Opciones guiadas para diferentes tipos de salida
   - Soporte para formatos específicos

### Archivos Modificados

1. **`/lib/widgets/node_editor_dialog.dart`**
   - Importación de los nuevos diálogos
   - Integración automática para nodos de entrada y salida
   - Mantenimiento de compatibilidad con nodos existentes

## 🎨 Interfaz de Usuario

### Diseño Consistente
- **Material Design 3**: Estilo consistente con el resto de la aplicación
- **Iconografía clara**: Iconos representativos para cada tipo de operación
- **Colores temáticos**: Respeta el tema claro/oscuro de la aplicación

### Experiencia de Usuario
- **Flujo guiado**: Los usuarios son guiados paso a paso
- **Reducción de errores**: Validación automática de campos
- **Retroalimentación visual**: Vista previa inmediata del resultado

## 📝 Beneficios para Usuarios No Programadores

### 1. **Simplicidad de Uso**
- No requiere conocimiento de sintaxis de programación
- Opciones predefinidas cubren casos de uso comunes
- Interfaz visual intuitiva

### 2. **Reducción de Errores**
- Validación automática de campos
- Formatos predefinidos evitan errores de sintaxis
- Vista previa previene malentendidos

### 3. **Aprendizaje Progresivo**
- Los usuarios pueden ver el código generado
- Transición gradual hacia el modo manual
- Comprensión de conceptos a través de ejemplos

### 4. **Flexibilidad**
- Opción de texto libre para usuarios avanzados
- Interpretación inteligente de texto existente
- Compatibilidad con diagramas legacy

## 🔄 Compatibilidad

### Retrocompatibilidad
- Los diagramas existentes seguirán funcionando
- La interpretación inteligente convierte automáticamente el texto anterior
- No se requiere migración de datos

### Integración
- Se integra perfectamente con el sistema de validación existente
- Compatible con el generador de código C
- Funciona con el sistema de guardado/carga

## 🎯 Próximos Pasos

1. **Pruebas de usuario**: Realizar pruebas con usuarios no programadores
2. **Refinamiento**: Ajustar basado en retroalimentación
3. **Documentación**: Crear guías de usuario específicas
4. **Extensión**: Aplicar el mismo patrón a otros tipos de nodos (variable, etc.)

---

*Esta implementación representa un paso significativo hacia hacer la programación más accesible para usuarios sin experiencia técnica, manteniendo la potencia y flexibilidad para usuarios avanzados.*
