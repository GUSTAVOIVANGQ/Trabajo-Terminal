# FlowDiagram App

Una aplicación móvil Flutter que permite a los usuarios diseñar algoritmos mediante diagramas de flujo y traducirlos automáticamente a código en lenguaje C.

## 📋 Descripción

FlowDiagram App es un editor visual intuitivo que permite crear diagramas de flujo de forma sencilla y generar código C funcional automáticamente. La aplicación incluye plantillas predefinidas, validación de estructura lógica y un sistema de almacenamiento local para guardar y cargar diagramas.

## ✨ Funcionalidades Implementadas

### 🎨 Editor Visual
- **Paleta de nodos**: Incluye todos los tipos de nodos esenciales:
  - Nodo de inicio (óvalo verde)
  - Nodo de fin (óvalo rojo)
  - Nodo de proceso (rectángulo azul)
  - Nodo de decisión (rombo amarillo)
  - Nodo de entrada (paralelogramo púrpura)
  - Nodo de salida (paralelogramo índigo)
  - Nodo de variable (rectángulo verde azulado)
  - Nodo de preparación/inicialización (hexagonal)

- **Interacciones avanzadas**:
  - Arrastrar y soltar nodos en el canvas
  - Zoom y desplazamiento (pan) del área de trabajo
  - Conexión visual entre nodos mediante líneas con flechas
  - Selección y edición de nodos con diálogo personalizado
  - Etiquetado de conexiones entre nodos
  - Grid de alineación opcional

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
  - Plantillas predefinidas incluidas
  - Plantilla de suma de dos números
  - Plantilla de verificación par/impar

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

## Funcionalidades en Desarrollo

### 🔒 Inicio de sesión y funcionamiento offline

- El inicio de sesión requiere conexión a internet la primera vez.
- Tras el primer login exitoso, la app permite acceder sin conexión utilizando la sesión almacenada en el dispositivo.
- Los nuevos registros de usuario requieren internet.
- En modo offline, el usuario puede acceder a todas sus funciones y métricas personales locales. La sincronización y acceso a métricas globales solo estarán disponibles al reconectar.

### 📊 Métricas de Evaluación

### 1. Métricas Técnicas

- **Precisión del compilador:**  
  Porcentaje de diagramas válidos que generan código C sintácticamente correcto.  
  _Meta: 100% para diagramas estructuralmente válidos._

- **Detección de errores:**  
  Capacidad del validador para identificar errores estructurales (implementado) y semánticos (en desarrollo).  
  _Meta: detectar el 100% de errores estructurales y semánticos comunes._

---

### 2. Métricas Educativas

- **Usabilidad educativa:**  
  Tiempo promedio de comprensión por usuarios novatos.  
  _Meta: menor a 30 minutos._  
  Se realizarán encuestas simples tras pruebas con usuarios.

- **Mejora en pre/post-test:**  
  % de mejora en test de conceptos antes/después de usar la app (por ejemplo, preguntas sobre estructuras de control y traducción de diagramas a código).  
  _Meta: ≥20% de mejora._

- **Tasa de éxito en ejercicios:**  
  % de usuarios que completan ejercicios prácticos (como crear un diagrama funcional o traducir un algoritmo) sin ayuda.  
  _Meta: ≥80%._

- **Tiempo promedio de resolución de ejercicios:**  
  Tiempo promedio en minutos para resolver ejercicios prácticos en la app.  
  _Meta: ≤15 minutos por ejercicio._

- **Tasa de identificación de errores:**  
  % de errores identificados y corregidos por los usuarios en ejercicios con fallos intencionales.  
  _Meta: ≥70%._

- **Autoevaluación de confianza:**  
  Calificación promedio (escala 1-5) post-uso sobre confianza en comprensión de algoritmos y conversión diagrama-código.  
  _Meta: ≥4._

- **Tasa de uso de recursos de ayuda:**  
  Número de consultas al tutorial o ayuda por sesión.  
  _Indicador: se espera que disminuya con el uso y la familiaridad con la app._

---

Estas métricas permitirán evaluar tanto la calidad técnica del sistema como su impacto en el aprendizaje y comprensión de los conceptos de programación por parte de los usuarios.  

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

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
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
- [x] Editor visual básico con todos los tipos de nodos
- [x] Sistema de conexiones entre nodos
- [x] Arrastrar y soltar, zoom y desplazamiento
- [x] Validación completa de diagramas
- [x] Generación de código C funcional
- [x] Sistema de guardado y carga con SQLite
- [x] Plantillas predefinidas
- [x] Interfaz de usuario moderna
- [x] Inicio de sesión y funcionamiento offline
- [x] Métricas de Evaluación
- [x] Modo oscuro
- [x] Importar/exportar diagramas a jpg.
- [x] Optimización del rendimiento del canvas
  - Implementación de arrastre fluido con feedback visual en tiempo real
  - Uso de AnimationController para suavizar movimientos de nodos
  - Optimización de repintado usando RepaintBoundary y AnimatedBuilder
  - Mejora en la detección de colisiones y gestión de eventos de toque
- [x] **Mejoras para usuarios no programadores (Nodo de Proceso)**
  - Diálogo especializado con opciones predefinidas (asignación, operaciones matemáticas, incremento/decremento)
  - Vista previa en tiempo real del código generado
  - Interpretación inteligente del texto existente
  - Interfaz guiada que reduce errores de sintaxis
  - Cumplimiento de estándares ANSI/ISO 5807
- [x] Mejorar la interfaz de usuario para usuario no programadores (Nodo de Proceso completado).
- [x] Mejorar la interfaz de usuario para usuario no programadores (Nodo de decisión).
- [x] **Mejorar la interfaz de usuario para usuario no programadores (Nodos de Entrada/Salida)**
  - Diálogos especializados con opciones predefinidas (entrada simple, con mensaje, múltiples variables, desde archivo)
  - Vista previa en tiempo real del código generado
  - Interpretación inteligente del texto existente
  - Interfaz guiada que reduce errores de sintaxis
  - Soporte para diferentes tipos de datos y formatos de salida
  - Cumplimiento de estándares ANSI/ISO 5807
- [x] **Mejorar la interfaz de usuario para usuario no programadores (Nodo de Variable)**
  - Diálogo especializado con opciones predefinidas (declaración, inicialización, constantes, arreglos)
  - Vista previa en tiempo real del código generado
  - Interpretación inteligente del texto existente
  - Soporte completo para tipos de datos de C (int, float, double, char, bool, string)
  - Interfaz guiada que reduce errores de sintaxis
  - Ayuda contextual y ejemplos para cada tipo de declaración
  - Cumplimiento de estándares ANSI/ISO 5807
- [x] **Mejorar la interfaz de usuario para usuario no programadores (Nodos de Decisión y Preparación/Inicialización)**
  - **Nodo de Decisión mejorado**: Nuevas opciones específicas para bucles (condición de bucle, par/impar, positivo/negativo)
  - **Nuevo Nodo de Preparación/Inicialización**: Diálogo especializado para inicializar contadores, configurar bucles FOR/WHILE, declarar arreglos
  - Vista previa en tiempo real del código generado
  - Interpretación inteligente del texto existente
  - Cumplimiento de estándares ANSI/ISO 5807 (rombo para decisión, hexágono para preparación)
  - Interfaz guiada con iconos, colores y ayuda contextual
  - Soporte para ciclos predefinidos (for, while, do-while) y configuraciones de bucles

### 🔄 En Desarrollo

- [ ] Validación semántica entre nodos de preparación y decisión
- [ ] Plantillas de bucles comunes (contador, suma, búsqueda)
- [ ] Más plantillas de algoritmos comunes
- [ ] Generación de código C funcional mejorada

### 🎯 Próximas Funcionalidades
- [ ] Compartir diagramas
- [ ] Exportación de código a archivos
- [ ] Tutorial integrado para cada tipo de nodo

## 📄 Licencia

Este proyecto es parte de un proyecto final académico para el desarrollo de aplicaciones móviles nativas.

## 🤝 Contribuciones

Este es un proyecto académico. Para sugerencias o mejoras, por favor crea un issue en el repositorio.

---

*Desarrollado con ❤️ usando Flutter*