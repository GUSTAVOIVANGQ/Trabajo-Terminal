# Mejoras al Diálogo del Nodo de Decisión

## 📋 Descripción

Se ha implementado un nuevo diálogo especializado para la edición de nodos de decisión, diseñado específicamente para **usuarios no programadores**. Este diálogo sigue los estándares **ANSI/ISO 5807** para símbolos de diagramas de flujo.

## ✨ Características Principales

### 🎯 Interfaz Amigable para No Programadores

El nuevo diálogo incluye las siguientes opciones predefinidas:

#### 1. **Comparar Dos Valores**
- **Uso**: Comparar una variable con otra variable o valor
- **Formato visual**: `¿variable1 [operador] variable2?`
- **Ejemplo**: `¿edad > 18?`
- **Campos**:
  - Primera Variable (ej: edad)
  - Operador (>, <, >=, <=, ==, !=)
  - Segunda Variable (ej: 18)
- **Operadores disponibles**:
  - `>` - Mayor que
  - `<` - Menor que  
  - `>=` - Mayor o igual que
  - `<=` - Menor o igual que
  - `==` - Igual a
  - `!=` - Diferente de

#### 2. **Verificar Igualdad**
- **Uso**: Verificar si una variable es igual a un valor específico
- **Formato visual**: `¿variable == valor?`
- **Ejemplo**: `¿nombre == "admin"?`
- **Campos**:
  - Variable a Verificar (ej: nombre)
  - Valor a Comparar (ej: "admin")

#### 3. **Verificar Rango**
- **Uso**: Verificar si una variable está dentro de un rango
- **Formato visual**: `¿min < variable < max?`
- **Ejemplo**: `¿0 < nota < 100?`
- **Campos**:
  - Variable a Verificar (ej: nota)
  - Valor Mínimo (ej: 0)
  - Valor Máximo (ej: 100)

#### 4. **Verificar Existencia**
- **Uso**: Verificar si una variable existe o tiene valor
- **Formato visual**: `¿variable existe?`
- **Ejemplo**: `¿archivo existe?`
- **Campos**:
  - Variable a Verificar (ej: archivo)

#### 5. **Condición Lógica**
- **Uso**: Combinar dos condiciones con operadores lógicos
- **Formato visual**: `¿condición1 [operador] condición2?`
- **Ejemplo**: `¿edad > 18 && tiene_licencia == true?`
- **Campos**:
  - Primera Condición (ej: edad > 18)
  - Operador Lógico (&&, ||, !)
  - Segunda Condición (ej: tiene_licencia == true)
- **Operadores lógicos disponibles**:
  - `&&` - Y (ambas condiciones deben ser verdaderas)
  - `||` - O (al menos una condición debe ser verdadera)
  - `!` - NO (negación de la condición)

#### 6. **Escribir Manualmente**
- **Uso**: Para usuarios avanzados que prefieren escribir la condición directamente
- **Formato**: Texto libre
- **Ejemplo**: `¿(a > b) && (c != d) || (x == y)?`

### 🔍 Vista Previa en Tiempo Real

- **Previsualización instantánea**: El diálogo muestra cómo quedará la condición generada
- **Actualización en tiempo real**: La vista previa se actualiza automáticamente al cambiar los campos
- **Formato de pregunta**: Utiliza el formato estándar `¿condición?` para claridad

### 🧠 Interpretación Inteligente

El diálogo puede **interpretar automáticamente** el texto existente en el nodo:

- **Comparaciones simples**: Detecta patrones como `edad > 18`
- **Igualdades**: Reconoce patrones como `nombre == "admin"`
- **Rangos**: Identifica patrones como `0 < nota < 100`
- **Condiciones lógicas**: Detecta operadores `&&` y `||`
- **Limpieza automática**: Remueve signos de interrogación del análisis
- **Fallback inteligente**: Si no reconoce el patrón, utiliza el modo "Escribir Manualmente"

### 📐 Cumplimiento de Estándares ANSI/ISO 5807

- **Símbolo**: Rombo/Diamante (forma correcta según estándar)
- **Uso**: Preguntas, condiciones, comparaciones
- **Salidas**: Dos o más ramas (Sí/No, Verdadero/Falso)
- **Propósito**: Representar puntos de decisión en el algoritmo

## 🎨 Elementos Visuales

### Diseño del Diálogo
- **Icono identificativo**: Icono de interrogación naranja
- **Título descriptivo**: "Editar Nodo de Decisión"
- **Información contextual**: Caja informativa que explica el propósito del nodo
- **Campos organizados**: Interfaz limpia y organizada por tipo de condición

### Colores y Estética
- **Color principal**: Naranja (coherente con el nodo de decisión)
- **Información destacada**: Fondo naranja claro para información contextual
- **Vista previa**: Fondo gris claro con tipografía monospace

## 🛠️ Implementación Técnica

### Archivos Involucrados
```
lib/widgets/
├── decision_node_dialog.dart         # Nuevo diálogo especializado
├── node_editor_dialog.dart          # Modificado para usar el nuevo diálogo
└── process_node_dialog.dart         # Diálogo de referencia para el patrón
```

### Funcionalidades Técnicas
- **Parsing inteligente**: Análisis del texto existente con expresiones regulares
- **Generación dinámica**: Construcción automática del texto de condición
- **Validación en tiempo real**: Actualización inmediata de la vista previa
- **Gestión de estado**: Control eficiente de los diferentes tipos de condición

## 🎯 Beneficios para Usuarios No Programadores

1. **Reducción de errores de sintaxis**: Interfaz guiada que previene errores comunes
2. **Aprendizaje intuitivo**: Categorías claras que enseñan diferentes tipos de condiciones
3. **Feedback inmediato**: Vista previa que muestra el resultado final
4. **Flexibilidad**: Opciones desde básicas hasta avanzadas
5. **Estándares**: Cumplimiento con normas internacionales de diagramas de flujo

## 📝 Ejemplos de Uso

### Caso de Uso 1: Verificación de Edad
- **Tipo**: Comparar Dos Valores
- **Campo 1**: edad
- **Operador**: >=
- **Campo 2**: 18
- **Resultado**: `¿edad >= 18?`

### Caso de Uso 2: Autenticación
- **Tipo**: Verificar Igualdad
- **Variable**: usuario
- **Valor**: "admin"
- **Resultado**: `¿usuario == "admin"?`

### Caso de Uso 3: Validación de Nota
- **Tipo**: Verificar Rango
- **Variable**: nota
- **Mínimo**: 0
- **Máximo**: 100
- **Resultado**: `¿0 < nota < 100?`

### Caso de Uso 4: Condición Compleja
- **Tipo**: Condición Lógica
- **Condición 1**: edad >= 18
- **Operador**: &&
- **Condición 2**: tiene_licencia == true
- **Resultado**: `¿edad >= 18 && tiene_licencia == true?`

## 🚀 Impacto Educativo

Esta mejora facilita significativamente el aprendizaje de:
- **Lógica condicional**: Comprensión de diferentes tipos de comparaciones
- **Operadores lógicos**: Uso correcto de AND, OR y NOT
- **Estructuras de control**: Base para entender condicionales en programación
- **Pensamiento algorítmico**: Desarrollo de habilidades de resolución de problemas

---

*Desarrollado siguiendo los estándares ANSI/ISO 5807 para diagramas de flujo*
