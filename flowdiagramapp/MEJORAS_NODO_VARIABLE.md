# Mejoras al Diálogo del Nodo de Variable

## 📋 Descripción

Se ha implementado un nuevo diálogo especializado para la edición de nodos de variable, diseñado específicamente para **usuarios no programadores**. Este diálogo sigue los estándares **ANSI/ISO 5807** para símbolos de diagramas de flujo y facilita la declaración e inicialización de variables en lenguaje C.

## ✨ Características Principales

### 🎯 Interfaz Amigable para No Programadores

El nuevo diálogo incluye las siguientes opciones predefinidas:

#### 1. **Declarar Variable**
- **Uso**: Declarar una variable sin valor inicial
- **Formato visual**: `Tipo Variable`
- **Ejemplo**: `int contador`
- **Campos**:
  - Tipo de dato (int, float, double, char, bool, string)
  - Nombre de la variable

#### 2. **Declarar e Inicializar**
- **Uso**: Declarar una variable y asignarle un valor inicial
- **Formato visual**: `Tipo Variable = Valor`
- **Ejemplo**: `int edad = 25`
- **Campos**:
  - Tipo de dato
  - Nombre de la variable
  - Valor inicial

#### 3. **Declarar Constante**
- **Uso**: Declarar una constante que no puede cambiar
- **Formato visual**: `const Tipo Variable = Valor`
- **Ejemplo**: `const float PI = 3.14159`
- **Campos**:
  - Tipo de dato
  - Nombre de la constante
  - Valor de la constante

#### 4. **Declarar Arreglo**
- **Uso**: Declarar un arreglo de elementos del mismo tipo
- **Formato visual**: `Tipo Variable[Tamaño]`
- **Ejemplo**: `int numeros[10]` o `char nombre[100]`
- **Campos**:
  - Tipo de dato (incluye string para char[])
  - Nombre del arreglo
  - Tamaño del arreglo

#### 5. **Escribir Manualmente**
- **Uso**: Para usuarios avanzados que prefieren escribir código directamente
- **Formato**: Texto libre
- **Ejemplo**: `int matriz[10][10]` o `struct Persona persona`

### 🔍 Tipos de Datos Soportados

El diálogo incluye los tipos de datos más comunes en C:

- **int**: Números enteros (ej: 5, -10, 0)
- **float**: Números decimales de precisión simple (ej: 3.14, -2.5)
- **double**: Números decimales de doble precisión (ej: 3.141592653)
- **char**: Caracteres individuales (ej: 'a', 'X', '1')
- **bool**: Valores booleanos (true, false)
- **string**: Cadenas de texto (representadas como char[])

### 🔍 Vista Previa en Tiempo Real

- **Previsualización instantánea**: El diálogo muestra cómo quedará el código C generado
- **Actualización en tiempo real**: La vista previa se actualiza automáticamente al cambiar los campos
- **Formato de código**: Utiliza tipografía monospace para simular código

### 🧠 Interpretación Inteligente

El diálogo puede **interpretar automáticamente** el texto existente en el nodo:

- **Declaraciones simples**: Detecta patrones como `int contador`
- **Declaraciones con inicialización**: Reconoce patrones como `float precio = 19.99`
- **Constantes**: Identifica patrones como `const int MAX = 100`
- **Arreglos**: Detecta patrones como `char nombre[50]` o `int datos[100]`
- **Cadenas de texto**: Reconoce declaraciones como `char texto[100]`
- **Fallback inteligente**: Si no reconoce el patrón, utiliza el modo "Escribir Manualmente"

### 📚 Ayuda Contextual

- **Mensajes informativos**: Cada tipo de declaración incluye una explicación clara
- **Sugerencias de valores**: Proporciona ejemplos apropiados para cada tipo de dato
- **Consejos de buenas prácticas**: Explica cuándo usar cada tipo de declaración

### 📐 Cumplimiento de Estándares ANSI/ISO 5807

- **Símbolo**: Rectángulo (forma correcta según estándar)
- **Uso**: Declaración e inicialización de variables
- **Propósito**: Representar la definición de datos y almacenamiento

## 🛠️ Implementación Técnica

### Archivos Creados

1. **`/lib/widgets/variable_node_dialog.dart`** (NUEVO)
   - Diálogo especializado para nodos de variable
   - Parseo inteligente de texto existente
   - Generación automática de código C válido
   - Validación de tipos de datos y sintaxis

### Archivos Modificados

1. **`/lib/widgets/node_editor_dialog.dart`**
   - Agregada importación del nuevo diálogo
   - Agregada condición para usar VariableNodeDialog cuando el tipo sea NodeType.variable

## 📋 Casos de Uso Cubiertos

### ✅ Declaraciones Básicas
- **Variables simples**: `int contador`, `float precio`
- **Inicialización**: `int edad = 25`, `bool activo = true`
- **Constantes**: `const float PI = 3.14159`

### ✅ Arreglos
- **Arreglos de números**: `int datos[100]`, `float valores[50]`
- **Cadenas de texto**: `char nombre[100]`, `char mensaje[256]`
- **Arreglos multidimensionales** (modo manual): `int matriz[10][10]`

### ✅ Tipos de Datos Especializados
- **Caracteres**: `char letra = 'A'`
- **Booleanos**: `bool encontrado = false`
- **Decimales**: `double precision = 0.0000001`

## 🎯 Beneficios para Usuarios No Programadores

1. **Eliminación de errores de sintaxis**: Las opciones predefinidas evitan errores comunes
2. **Aprendizaje progresivo**: Los usuarios ven cómo se estructura el código C
3. **Retroalimentación inmediata**: La vista previa muestra el resultado instantáneamente
4. **Guía educativa**: Las explicaciones ayudan a entender los conceptos
5. **Flexibilidad**: Opción manual disponible para casos avanzados

## 🔄 Integración con el Sistema

### Generación de Código C
- El código generado es totalmente compatible con el generador de código existente
- Las declaraciones se colocan automáticamente en la sección correcta del programa C
- Soporte completo para todos los tipos de datos implementados

### Validación de Diagramas
- Las declaraciones de variables se validan automáticamente
- Se verifica la sintaxis correcta de las declaraciones
- Compatible con el sistema de validación existente

### Persistencia de Datos
- Las configuraciones se guardan correctamente en la base de datos
- Compatible con el sistema de carga y guardado existente
- Preserva la configuración al editar nodos existentes

## 🧪 Ejemplos de Uso

### Ejemplo 1: Variable Simple
```
Entrada del usuario:
- Tipo: "Declarar Variable"
- Tipo de dato: "int"
- Nombre: "contador"

Código generado: int contador
```

### Ejemplo 2: Variable con Inicialización
```
Entrada del usuario:
- Tipo: "Declarar e Inicializar"
- Tipo de dato: "float"
- Nombre: "precio"
- Valor: "19.99"

Código generado: float precio = 19.99
```

### Ejemplo 3: Arreglo de Caracteres (String)
```
Entrada del usuario:
- Tipo: "Declarar Arreglo"
- Tipo de dato: "string"
- Nombre: "mensaje"
- Tamaño: "100"

Código generado: char mensaje[100]
```

### Ejemplo 4: Constante
```
Entrada del usuario:
- Tipo: "Declarar Constante"
- Tipo de dato: "double"
- Nombre: "PI"
- Valor: "3.141592653"

Código generado: const double PI = 3.141592653
```

## 🎯 Estado de Implementación

### ✅ Completado
- [x] Diálogo especializado con interfaz amigable
- [x] Soporte para todos los tipos básicos de C
- [x] Vista previa en tiempo real
- [x] Interpretación inteligente de texto existente
- [x] Ayuda contextual para cada opción
- [x] Validación de entrada
- [x] Integración con node_editor_dialog.dart
- [x] Generación de código C válido
- [x] Soporte para arreglos y constantes
- [x] Manejo especial de strings (char[])

### 🎯 Próximas Mejoras Posibles
- [ ] Soporte para estructuras (struct)
- [ ] Soporte para punteros
- [ ] Validación de nombres de variables (palabras reservadas)
- [ ] Sugerencias automáticas de nombres de variables

## 📖 Documentación de Usuario

El nuevo diálogo incluye:
- **Tooltips informativos** en cada campo
- **Ejemplos contextuales** según el tipo de dato seleccionado
- **Mensajes de ayuda** que explican cuándo usar cada opción
- **Vista previa** que permite verificar el código antes de guardar

*Desarrollado siguiendo los estándares ANSI/ISO 5807 y mejores prácticas de UX para usuarios no programadores*
