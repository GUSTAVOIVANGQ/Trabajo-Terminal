# Mejoras al Diálogo de Nodos de Decisión y Preparación/Inicialización

## 📋 Descripción

Se han implementado mejoras significativas en los diálogos de edición para **nodos de decisión** y se ha creado un nuevo diálogo especializado para **nodos de preparación/inicialización** (anteriormente llamados "loop"), diseñados específicamente para **usuarios no programadores** siguiendo los estándares **ANSI/ISO 5807**.

## ✨ Características Principales - Nodo de Decisión

### 🎯 Nuevas Opciones de Condiciones

El diálogo mejorado del nodo de decisión ahora incluye opciones específicas para bucles:

#### 1. **Condición de Bucle**
- **Uso**: Para controlar la iteración de bucles
- **Formato**: `¿variable [operador] valor?`
- **Ejemplo**: `¿contador < 10?`
- **Campos**:
  - Variable de Control (ej: contador, i, índice)
  - Operador (menor que, mayor que, etc.)
  - Valor Límite (ej: 10, límite, máximo)

#### 2. **Par o Impar**
- **Uso**: Verificar si un número es divisible por 2
- **Formato**: `¿variable % 2 == 0?`
- **Ejemplo**: `¿numero % 2 == 0?`
- **Campos**:
  - Variable a Verificar

#### 3. **Positivo o Negativo**
- **Uso**: Verificar el signo de un número
- **Formato**: `¿variable > 0?`
- **Ejemplo**: `¿saldo > 0?`
- **Campos**:
  - Variable a Verificar

### 🔍 Características Existentes Mejoradas
- **Comparar Dos Valores**: Para comparaciones generales
- **Verificar Rango**: Para valores dentro de un intervalo
- **Verificar Igualdad**: Para comparaciones exactas
- **Verificar Existencia**: Para verificar si algo existe
- **Condición Lógica**: Para condiciones complejas con && y ||

## ✨ Nuevo Diálogo - Nodo de Preparación/Inicialización

### 🔶 Cumplimiento de Estándares ANSI/ISO 5807

- **Símbolo**: Hexágono
- **Uso**: Inicializar contadores, configurar bucles, preparar variables
- **Propósito**: Preparación antes de procesos iterativos

### 🎯 Tipos de Preparación Disponibles

#### 1. **Inicializar Contador**
- **Uso**: Configurar una variable para contar iteraciones
- **Formato**: `variable = valor_inicial`
- **Ejemplo**: `contador = 0`
- **Campos**:
  - Nombre del Contador
  - Valor Inicial

#### 2. **Bucle FOR (Número Conocido)**
- **Uso**: Configurar bucles con número predeterminado de iteraciones
- **Formato**: `for (variable = inicio; variable < fin; variable++)`
- **Ejemplo**: `for (i = 0; i < 10; i++)`
- **Campos**:
  - Variable de Control
  - Valor de Inicio
  - Valor de Fin
  - Paso (incremento)

#### 3. **Configurar WHILE**
- **Uso**: Inicializar variables necesarias para bucles while
- **Formato**: `variable = valor_inicial`
- **Ejemplo**: `continuar = true`
- **Campos**:
  - Variable de Condición
  - Valor Inicial

#### 4. **Inicializar Variable**
- **Uso**: Asignar valor inicial a cualquier variable
- **Formato**: `variable = valor`
- **Ejemplo**: `suma = 0`
- **Campos**:
  - Nombre de la Variable
  - Valor Inicial

#### 5. **Configurar Arreglo**
- **Uso**: Declarar arreglos con su tamaño
- **Formato**: `int variable[tamaño]`
- **Ejemplo**: `int numeros[10]`
- **Campos**:
  - Nombre del Arreglo
  - Tamaño del Arreglo

#### 6. **Inicializar Acumulador**
- **Uso**: Variables para acumular valores (suma, producto, etc.)
- **Formato**: `variable = 0`
- **Ejemplo**: `total = 0`
- **Campos**:
  - Nombre del Acumulador (se inicializa automáticamente en 0)

## 🧠 Interpretación Inteligente

### Nodo de Decisión
- **Detecta automáticamente** el tipo de condición basado en el texto existente
- **Patrones reconocidos**:
  - Comparaciones: `a > b`, `edad >= 18`
  - Igualdades: `nombre == "Juan"`
  - Rangos: `10 < edad < 65`
  - Condiciones lógicas: `a > 0 && b < 10`

### Nodo de Preparación/Inicialización
- **Parseo inteligente** del texto existente:
  - Bucles FOR: `for (i = 0; i < 10; i++)`
  - Inicializaciones: `contador = 0`
  - Palabras clave: "while", "for", "para", "mientras"

## 🔍 Vista Previa en Tiempo Real

Ambos diálogos incluyen:
- **Previsualización instantánea** del código generado
- **Actualización automática** al cambiar los campos
- **Formato de código** con tipografía monospace
- **Mensajes descriptivos** y ayuda contextual

## 🎨 Interfaz de Usuario Mejorada

### Características Visuales
- **Iconos distintivos** para cada tipo de operación
- **Colores temáticos** para identificar fácilmente cada categoría
- **Ayuda contextual** con descripciones de cada opción
- **Campos de ayuda** con ejemplos prácticos

### Experiencia de Usuario
- **Formularios guiados** que reducen errores de sintaxis
- **Validación automática** de campos requeridos
- **Mensajes de error claros** y descriptivos
- **Navegación intuitiva** entre opciones

## 🛠️ Implementación Técnica

### Archivos Modificados

1. **`/lib/widgets/decision_node_dialog.dart`** (MEJORADO)
   - Agregadas opciones para condiciones de bucle
   - Nuevos métodos para par/impar y positivo/negativo
   - Interfaz mejorada con iconos y colores

2. **`/lib/widgets/preparation_node_dialog.dart`** (NUEVO)
   - Diálogo especializado para nodo de preparación/inicialización
   - Múltiples tipos de preparación predefinidos
   - Parseo inteligente de texto existente

3. **`/lib/widgets/node_editor_dialog.dart`** (MODIFICADO)
   - Integración del nuevo diálogo de preparación
   - Redirección automática según el tipo de nodo

4. **`/lib/widgets/node_palette.dart`** (MODIFICADO)
   - Cambio de nombre: "Bucle" → "Preparación"
   - Nuevo icono: hexágono para reflejar la forma estándar

5. **`/lib/models/diagram_validator.dart`** (MODIFICADO)
   - Actualización del nombre del nodo en validaciones

## 🎯 Beneficios para Usuarios No Programadores

### Eliminación de Barreras Técnicas
- **Sin necesidad de sintaxis**: Los usuarios eligen opciones predefinidas
- **Prevención de errores**: Validación automática de campos
- **Guía visual**: Iconos y colores para identificar operaciones

### Cumplimiento de Estándares
- **ANSI/ISO 5807**: Formas y usos correctos de cada símbolo
- **Terminología estándar**: Nombres apropiados para cada tipo de nodo
- **Flujo lógico**: Separación clara entre preparación y decisión

### Aprendizaje Progresivo
- **Opción manual**: Usuarios avanzados pueden escribir código directamente
- **Ejemplos integrados**: Cada campo incluye ejemplos prácticos
- **Retroalimentación inmediata**: Vista previa del código generado

## 🔮 Próximas Mejoras

- **Validación semántica**: Verificar coherencia entre preparación y decisión
- **Plantillas de bucles**: Patrones comunes predefinidos (contador, suma, búsqueda)
- **Ayuda contextual**: Tutorial integrado para cada tipo de nodo
- **Exportación de patrones**: Guardar configuraciones frecuentes

---

*Estas mejoras fortalecen significativamente la usabilidad de la aplicación para usuarios no programadores, manteniendo el rigor técnico y cumpliendo con estándares internacionales de diagramas de flujo.*
