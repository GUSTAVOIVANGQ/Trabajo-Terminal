# FlowCode: Aplicación Android para traducción automática de Diagramas de Flujo a Código C estructurado con validación integrada

![Icono de FlowCode](docs/AppIcons/banner_1.png)

Una aplicación móvil Android Flutter que permite a los usuarios diseñar algoritmos mediante diagramas de flujo y traducirlos automáticamente a código en lenguaje C.

---

## 🎉 **Nuevas Características (Enero 2026) - Sistema de Metadata Inteligente**

### ✨ **Generación Correcta de Estructuras de Control**

FlowCode ahora genera código C correcto para estructuras avanzadas:

#### ✅ **Switch Statement**

- **Antes**: Generaba múltiples `if-else` anidados ❌
- **Ahora**: Genera código `switch() { case: break; }` correcto ✅
- **Uso**: Menú "Conceptos" → "Switch"

**Ejemplo:**

```c
// Código generado por FlowCode
switch (opcion) {
    case 1:
        printf("Opción 1");
        break;
    case 2:
        printf("Opción 2");
        break;
    default:
        printf("Opción inválida");
        break;
}
```

#### ✅ **Bucle For**

- **Antes**: Indistinguible de `while`, generaba código genérico ❌
- **Ahora**: Genera bucles `for(init; cond; incr)` específicos ✅
- **Uso**: Menú "Conceptos" → "For"

**Ejemplo:**

```c
// Código generado por FlowCode
for (int i = 0; i < 10; i++) {
    printf("Iteración %d\n", i);
}
```

#### ✅ **Bucle While**

- **Antes**: Mezclado con for, sin diferenciación ❌
- **Ahora**: Genera bucles `while(cond)` diferenciados ✅
- **Uso**: Menú "Conceptos" → "While"

**Ejemplo:**

```c
// Código generado por FlowCode
while (contador < 100) {
    contador++;
}
```

### 🔍 **Sistema de Detección Inteligente**

**Doble prioridad de detección:**

1. **Metadata explícito** (100% precisión) - Insertado automáticamente desde "Conceptos"
2. **Análisis de patrón de texto** (fallback) - Para diagramas legacy o creados manualmente

**Resultados de pruebas:**

- ✅ 7/7 pruebas pasadas (100% éxito)
- ✅ Backward compatibility con diagramas existentes
- ✅ 0 errores de compilación

### 📚 **Documentación Completa**

- **[Guía de Usuario](GUIA_ESTRUCTURAS_CONTROL.md)** - Cómo usar las nuevas estructuras
- **[Documentación Técnica](DOCUMENTACION_TECNICA_METADATA.md)** - Arquitectura e implementación
- **[Claves de Metadata](METADATA_KEYS_DOCUMENTATION.md)** - Referencia de metadata
- **[Resultados de Pruebas](FASE_4_PRUEBAS_COMPLETADAS.md)** - Validación completa

---

## 📖 **Descripción General**

El producto principal es implementar un compilador fuente a fuente (Diagramas de flujo a codigo en c). Esta aplicacion debe conviertir los diagramas de flujo a codigo en lenguaje c funcional mediante las fases de un compilador. El compilador esta terminado y listo para pruebas.

**Análisis estructural del diagrama de flujo:**

- **Validación sintáctica básica** (estructura del diagrama).
- **Generación de código directo** (traducción 1:1 de nodos a C).

### 🏗️ Arquitectura del Compilador

| Fase             | Actividad              | Módulo Responsable         |
| :--------------- | :--------------------- | :-------------------------- |
| **FASE 1** | Análisis de Diagrama  | ✅`CompilerPipeline`      |
| **FASE 2** | Construcción de AST   | ✅`ASTBuilder`            |
| **FASE 3** | Análisis Semántico   | ✅`SemanticAnalyzer`      |
| **FASE 4** | Optimización AST      | ✅`ASTOptimizer`          |
| **FASE 5** | Generación de Código | ✅`AdvancedCodeGenerator` |

**Entregables:**

- ✅ Sistema completo integrado
- ✅ Documentación técnica del compilador
- ✅ Casos de prueba automatizados
- ✅ Métricas de rendimiento

---

## 📋 **Condiciones Adicionales Importantes:**

### **🔧 Aspectos Técnicos que Agregar:**

1. **Manejo de Errores Robusto:**

   - Sistema de recuperación de errores
   - Mensajes de error descriptivos
   - Sugerencias de corrección automática
2. **Optimizaciones Específicas para Diagramas:**

   - Detección de bucles infinitos
   - Validación de rutas no alcanzables
   - Optimización de saltos condicionales
3. **Extensibilidad:**

   - Soporte para nuevos tipos de nodos
   - Plugin system para validaciones personalizadas
   - API para exportar a otros lenguajes

### **📊 Métricas de Validación:**

```dart
// Crear: lib/compiler/compiler_metrics.dart
class CompilerMetrics {
  double lexicalAccuracy;    // % tokens correctos
  double syntaxValidation;   // % sintaxis válida
  double semanticPrecision;  // % errores semánticos detectados
  double optimizationGain;   // % mejora en código generado
}
```

## 📋 Descripción

FlowCode (ante llamada FlowDiagram App) es un editor visual intuitivo que permite crear diagramas de flujo de forma sencilla y generar código C funcional automáticamente. La aplicación incluye plantillas predefinidas, validación de estructura lógica y un sistema de almacenamiento local para guardar y cargar diagramas.

## ✨ Funcionalidades Implementadas

### 🎨 Editor Visual

- **Paleta de nodos**: Incluye todos los tipos de nodos esenciales conforme a **ISO 5807**:

  - Nodo de inicio (óvalo verde)
  - Nodo de fin (óvalo rojo)
  - Nodo de proceso (rectángulo azul) - Incluye operaciones aritméticas y declaraciones de variables
  - Nodo de decisión (rombo amarillo)
  - Nodo de dato (paralelogramo púrpura) - Unifica entrada/salida de datos
  - Nodo de bucle (hexagonal naranja)
  - Nodo de subproceso (rectángulo con doble línea morado)
- **Interacciones avanzadas**:

  - Arrastrar y soltar nodos en el canvas
  - Zoom y desplazamiento (pan) del área de trabajo
  - Conexión visual entre nodos mediante líneas con flechas
  - Selección y edición de nodos con diálogos especializados y dropdowns
  - Etiquetado de conexiones entre nodos
  - Grid de alineación opcional
- **Diálogos mejorados para usuarios no programadores**:

  - **Nodo de Dato**: Dropdown con 10 tipos de operaciones predefinidas (lectura de entero, flotante, cadena, carácter, línea completa + escritura con las mismas variantes)
  - **Nodo de Proceso**: 8 tipos de operaciones (asignación, operaciones aritméticas, incremento/decremento, declaración, inicialización, constantes, arreglos)
  - Vista previa de código generado en tiempo real
  - Interpretación inteligente de texto existente

### 🔗 Sistema de Conexiones

- Conexión intuitiva entre nodos
- Puntos de conexión automáticos (arriba, abajo, izquierda, derecha)
- Validación de conexiones lógicas
- Etiquetas personalizables en las conexiones
- Detección de colisiones mejorada

### ✅ Validación de Diagramas

- **Validaciones estructurales**:

  - Verificación de nodo de inicio único
  - Verificación de al menos un nodo de fin
  - Validación de conexiones lógicas
  - Detección de nodos desconectados
  - Validación específica para nodos de decisión (múltiples salidas)
- **Retroalimentación visual**:

  - Diálogo de resultados de validación
  - Clasificación entre errores y advertencias
  - Mensajes descriptivos para cada problema detectado

### 🔧 Generación de Código C

- **Generador automático** que produce código C funcional
- **Características del código generado**:

  - Inclusión automática de librerías estándar (`stdio.h`, `stdlib.h`, `stdbool.h`)
  - Declaración automática de variables utilizadas
  - Función main() completa
  - Comentarios con fecha de generación
  - Formateo adecuado del código
- **Soporte para estructuras**:

  - Secuencias lineales
  - Estructuras condicionales (if/else)
  - Entrada y salida de datos
  - Procesamiento de variables

### 💾 Sistema de Almacenamiento

- **Base de datos SQLite local** para persistencia
- **Funcionalidades de guardado**:

  - Guardar diagramas con nombre y descripción
  - Actualizar diagramas existentes
  - Cargar diagramas guardados
  - Eliminar diagramas
- **Sistema de plantillas**:

  - **20 plantillas educativas** basadas en el temario de Fundamentos de Programación (ESCOM ISC 2020)
  - **UNIDAD I - Básico**: Hola Mundo, Tipos de Datos, Calculadora, Conversión Temperatura
  - **UNIDAD I - Decisiones**: Par/Impar, Mayor de 3, Calculadora Menú, Triángulos
  - **UNIDAD I - Bucles**: While, Do-While, For, Factorial Iterativo
  - **UNIDAD I - Arreglos**: Suma, Búsqueda Secuencial, Bubble Sort, Selection Sort
  - **UNIDAD II - Funciones**: Función Suma, Función Factorial, Swap, Apuntadores
  - Cada plantilla incluye nodo de comentario explicativo
  - Ver [PLANTILLAS_SIMBOLOS.md](PLANTILLAS_SIMBOLOS.md) para documentación completa

### 📱 Interfaz de Usuario

- **Diseño Material 3** moderno
- **Navegación fluida** entre pantallas:

  - Pantalla de carga/selección de diagramas
  - Editor principal con canvas interactivo
  - Diálogos modales para edición
- **Controles intuitivos**:

  - Barra de herramientas con acciones principales
  - Paleta lateral de nodos
  - Menús contextuales para opciones avanzadas

### 📸 Exportación de Diagramas

- **Formatos de exportación**:
  - PNG con alta calidad y soporte para transparencia
  - JPG con compresión optimizada y fondo blanco
- **Almacenamiento automático**:
  - Guardado directo en la carpeta de Descargas
  - Nombres únicos con timestamp
  - Manejo inteligente de permisos Android
- **Calidad optimizada**:
  - Resolución 3x para pantallas de alta densidad
  - Captura completa del canvas visible
  - Respeto por temas claro/oscuro

### 🎓 Sistema de Ejercicios de Comprensión

- **5 categorías de ejercicios**:

  - Símbolos Básicos: Aprende los símbolos fundamentales
  - Estructuras de Control: Decisiones y bucles
  - Flujo de Datos: Entrada, salida y variables
  - Conexiones: Flujo lógico del diagrama
  - Avanzado: Conectores y subprocesos
- **Acceso**: Botón dedicado "Ejercicios" en la pantalla principal junto a "Crear nuevo diagrama"

### 📚 Sistema de Tutoriales Integrado

- **Acceso desde múltiples pantallas**: Botón de tutoriales en login y pantalla principal
- Ver documentación completa en [TUTORIAL_SYSTEM_README.md](TUTORIAL_SYSTEM_README.md)

### 🔒 Inicio de sesión y funcionamiento offline

- **Sistema de autenticación flexible** con Firebase Authentication y modo invitado
- **Tres modos de acceso**:
  - **Inicio de sesión con cuenta**: Requiere conexión a internet la primera vez
  - **Modo offline**: Acceso con credenciales previamente guardadas
  - **Modo invitado**: Acceso completo sin conexión ni registro
- **Características del modo invitado**:
  - Sin necesidad de correo electrónico ni contraseña
  - Acceso completo a todas las funciones de la aplicación
  - Datos almacenados localmente en el dispositivo
  - Ideal para pruebas rápidas o uso sin conexión
- Tras el primer login exitoso con cuenta, la app permite acceder sin conexión utilizando la sesión almacenada
- Los nuevos registros de usuario requieren internet
- En modo offline o invitado, el usuario puede acceder a todas sus funciones y métricas personales locales
- La sincronización y acceso a métricas globales solo estarán disponibles al reconectar con una cuenta registrada

### 📊 Métricas de Evaluación

### 1. Métricas Técnicas

- **Precisión del compilador:**Porcentaje de diagramas válidos que generan código C sintácticamente correcto._Meta: 100% para diagramas estructuralmente válidos._
- **Detección de errores:**
  Capacidad del validador para identificar errores estructurales (implementado) y semánticos (en desarrollo).
  _Meta: detectar el 100% de errores estructurales y semánticos comunes._

---

Estas métricas permitirán evaluar la calidad técnica del compilador fuente a fuente. La aplicacion no se compromete a evaluar la calidad educativa o la comprensión de los conceptos de programación por parte de los usuarios.

## 🚀 Funcionalidad sin conexión

FlowDiagram App puede ser utilizada completamente **sin internet** para:

- Crear y editar diagramas de flujo.
- Generar código en lenguaje C.
- Validar y guardar diagramas en el dispositivo.
- Consultar tus métricas personales y progreso educativo.

## 🌐 Funcionalidad con internet

Una conexión a internet es requerida únicamente para:

- Sincronizar tus diagramas y respaldos en la nube.
- Compartir diagramas o código con otros usuarios.
- Consultar métricas globales o comparativas (opcional).
- Descargar nuevas plantillas, tutoriales o actualizaciones.

---

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo móvil
- **Dart** - Lenguaje de programación
- **SQLite** - Base de datos local (`sqflite`)
- **Provider** - Gestión de estado
- **Path Provider** - Acceso al sistema de archivos

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
  provider: ^6.1.1
  intl: ^0.18.1
  cupertino_icons: ^1.0.2
```

## 🚀 Instalación y Ejecución

1. **Clonar el repositorio**

```bash
git clone [url-del-repositorio]
cd flowdiagramapp
```

1. **Instalar dependencias**

```bash
flutter pub get
```

1. **Ejecutar la aplicación**

```bash
flutter run
```

## 🧪 Pruebas automatizadas (con reportes)

### Resumen (suite base)

- `test/compiler/` → 7 archivos → 282 pruebas
- `test/code_generator_phase4_test.dart` → 1 archivo → 8 pruebas
- **Total** → 8 archivos → 290 pruebas

**Detalle por archivo** (ejemplo; generado en `test_reports/resumen_conteo_tests_suite_base.txt`):

```text
TOTAL 290
  84  test/compiler/syntax_analyzer_test.dart
  53  test/compiler/code_optimizer_test.dart
  47  test/compiler/lexical_analyzer_test.dart
  43  test/compiler/semantic_analyzer_test.dart
  33  test/compiler/compiler_integration_test.dart
  17  test/compiler/compiler_benchmark_test.dart
   8  test/code_generator_phase4_test.dart
   5  test/compiler/code_generator_advanced_test.dart
```

### Script de reportes (recomendado)

```powershell
# Desde la raíz del proyecto (carpeta flowdiagramapp/)
powershell -ExecutionPolicy Bypass -File scripts/run_test_reports.ps1

# Opcional: cambiar carpeta de salida
powershell -ExecutionPolicy Bypass -File scripts/run_test_reports.ps1 -OutDir test_reports
```

**Archivos generados** (por defecto en `test_reports/`):

- `flutter_test_compiler.txt` / `flutter_test_compiler.jsonl`
- `flutter_test_phase4.txt` / `flutter_test_phase4.jsonl`
- `resumen_conteo_tests_compiler.txt` _(si `python` está disponible)_
- `resumen_conteo_tests_suite_base.txt` _(si `python` está disponible)_
- `resumen_benchmark.txt`

### Código (PowerShell) — equivalente al script

```powershell
New-Item -ItemType Directory -Force test_reports | Out-Null

flutter test test/compiler --reporter expanded 2>&1 |
  Tee-Object -FilePath test_reports/flutter_test_compiler.txt

flutter test test/compiler --reporter json 2>&1 |
  Out-File -Encoding utf8 test_reports/flutter_test_compiler.jsonl

flutter test test/code_generator_phase4_test.dart --reporter expanded 2>&1 |
  Tee-Object -FilePath test_reports/flutter_test_phase4.txt

flutter test test/code_generator_phase4_test.dart --reporter json 2>&1 |
  Out-File -Encoding utf8 test_reports/flutter_test_phase4.jsonl

flutter test test/compiler/compiler_benchmark_test.dart --reporter expanded 2>&1 |
  Select-String -Pattern 'BENCH-|BENCH-DEBUG|Todas exitosas|Todos exitosos|\[ERROR\]|\[FATAL\]|\[3001\]|Expected:|Actual:|Some tests failed|All tests passed|Large diagrams should compile' |
  ForEach-Object { $_.Line } |
  Out-File -Encoding utf8 test_reports/resumen_benchmark.txt
```

### Comandos rápidos

```bash
flutter test test/compiler
flutter test test/code_generator_phase4_test.dart
```

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── models/                            # Modelos de datos
│   ├── code_generator.dart           # Generador de código C
│   ├── diagram_node.dart             # Modelo de nodos y conexiones
│   ├── diagram_validator.dart        # Validador de diagramas
│   └── saved_diagram.dart            # Modelo para diagramas guardados
├── screens/                          # Pantallas principales
│   ├── editor_screen.dart            # Editor principal
│   └── load_diagram_screen.dart      # Pantalla de carga
├── services/                         # Servicios
│   └── database_service.dart         # Servicio de base de datos
└── widgets/                          # Widgets personalizados
    ├── flow_diagram_canvas_final.dart # Canvas principal del editor
    ├── node_editor_dialog.dart       # Diálogo de edición de nodos
    ├── node_palette.dart             # Paleta de nodos
    ├── save_diagram_dialog.dart      # Diálogo de guardado
    └── validation_result_dialog.dart  # Diálogo de resultados de validación
```

## 🎯 Estado del Desarrollo

### ✅ Completado

- [X] Editor visual básico con todos los tipos de nodos
- [X] Sistema de conexiones entre nodos
- [X] Arrastrar y soltar, zoom y desplazamiento
- [X] Validación completa de diagramas
- [X] Generación de código C funcional
- [X] Sistema de guardado y carga con SQLite
- [X] Plantillas predefinidas
- [X] Interfaz de usuario moderna
- [X] Inicio de sesión y funcionamiento offline
- [X] Métricas de Evaluación
- [X] Modo oscuro
- [X] Importar/exportar diagramas a jpg.
- [X] Optimización del rendimiento del canvas
  - Implementación de arrastre fluido con feedback visual en tiempo real
  - Uso de AnimationController para suavizar movimientos de nodos
  - Optimización de repintado usando RepaintBoundary y AnimatedBuilder
  - Mejora en la detección de colisiones y gestión de eventos de toque
- [X] **Mejoras para usuarios no programadores (Nodo de Proceso)**
  - Diálogo especializado con opciones predefinidas (asignación, operaciones matemáticas, incremento/decremento)
  - Vista previa en tiempo real del código generado
  - Interpretación inteligente del texto existente
  - Interfaz guiada que reduce errores de sintaxis
  - Cumplimiento de estándares ANSI/ISO 5807
- [X] Mejorar la interfaz de usuario para usuario no programadores (Nodo de Proceso completado).
- [X] Mejorar la interfaz de usuario para usuario no programadores (Nodo de decisión).
- [X] Implementación del Símbolo: Subproceso/Función
- [X] **Simplificación de símbolos según ISO 5807**
  - Fusión de símbolos "Entrada" y "Salida" en un único símbolo "Dato" (paralelogramo)
  - Fusión de símbolo "Variable" con símbolo "Proceso" (rectángulo)
  - Diálogo de Dato con dropdown para 10 tipos de operaciones I/O
  - Diálogo de Proceso expandido con 8 tipos de operaciones (procesamiento + declaraciones)
  - Reducción de 11 a 9 símbolos esenciales conforme a estándar internacional
- [X] Programacion de las estructuras generadas por cada boton del panel "C concepts"
- [X] 20 plantillas implementadas usando de referencia el temario de Fundamentos de Programación (ESCOM ISC 2020)
- [X] Generación de código C y validacion estructural mejorada
- [X] Implementar las fases de un transpilador: análisis léxico, sintáctico, semántico, representación intermedia, tabla de símbolos y generación de código C funcional ✅
- [X] Tutorial integrado para cada tipo de nodo
- [X] La exportación de diagramas a JPG/PNG no se exporta correctamente en algunos dispositivos Android (problema de permisos).
- [X] Separación de diagramas por usuario - Cada usuario ahora ve solo sus propios diagramas
- [X] **Sincronización con Firebase y gestión de cuenta**
  - Sincronización inteligente de diagramas (los cambios más recientes ganan)
  - Opción para subir todos los diagramas a la nube
  - Opción para descargar todos los diagramas desde la nube
  - Eliminación de cuenta y todos los datos asociados
  - Eliminación de datos locales para usuarios invitados
  - Interfaz integrada en la pantalla "Mi Perfil"
- [X] **Zoom con punto focal preservado**
  - Al hacer zoom (pinch), la vista ahora se centra en el punto focal del gesto
  - Se mantiene la posición del diagrama visible durante el zoom
  - Experiencia de zoom más natural e intuitiva
- [X] Aceptación de Aviso de Privacidad
- [X] Agregar la opcion de exportación de código a archivos .c ademas de exportacion a imagen.
- [X] Implementar un sistema de tutoriales interactivos dentro de la aplicación

## 🔄 En Desarrollo

- [ ] Arreglar la sincronización de diagramas de flujo con Firebase Storage. Firebase console debe habilitar el almacenamiento en la nube.
- [ ] Agregar optimizaciones específicas para diagramas de flujo (detección de bucles)

### 🎯 Próximas Funcionalidades

- [ ] Implementar validación semántica avanzada (tipos de datos, uso de variables, rutas no alcanzables)
- [ ] Extender el sistema de plantillas con más ejemplos y categorías
- [ ] Agregar soporte para exportar a otros lenguajes (Python, Java)

## 📄 Licencia

Este proyecto es parte de un proyecto final para el Trabajo Terminal 2026-A038.

## 🤝 Contribuciones

Este es un proyecto académico. Para sugerencias o mejoras, por favor crea un issue en el repositorio.

---

_Desarrollado con ❤️ usando Flutter_
