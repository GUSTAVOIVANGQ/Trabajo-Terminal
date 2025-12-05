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
  - Nodo de preparación/inicialización (hexagonal naranja)
  - Nodo de conector fuera de página (círculo índigo)
  - Nodo de comentario/nota (rectángulo con esquina doblada amarillo)
  - Nodo de subproceso/función (rectángulo con doble línea morado)

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
  - **6 plantillas predefinidas** que cubren todos los símbolos
  - **Plantilla 1**: Suma de dos números (símbolos básicos)
  - **Plantilla 2**: Verificación par/impar (decisiones)
  - **Plantilla 3**: Contador con bucle while (bucles y variables)
  - **Plantilla 4**: Menú de opciones con conectores (organización de flujos complejos)
  - **Plantilla 5**: Promedio con comentarios (documentación de diagramas)
  - **Plantilla 6**: Factorial con subprocesos (modularización)
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

## Funcionalidades en Desarrollo

### 🎓 Sistema de Ejercicios de Comprensión

- **Ejercicios interactivos** diseñados según el **Nivel 2 de la Taxonomía de Bloom (Comprensión)**
- **5 categorías de ejercicios**:
  - Símbolos Básicos: Aprende los símbolos fundamentales
  - Estructuras de Control: Decisiones y bucles
  - Flujo de Datos: Entrada, salida y variables
  - Conexiones: Flujo lógico del diagrama
  - Avanzado: Conectores y subprocesos

- **Tipos de ejercicios variados**:
  - Selección múltiple: Identificar símbolos y conceptos
  - Verdadero o Falso: Distinguir afirmaciones correctas
  - Relacionar: Comparar símbolos con sus funciones
  - Ordenamiento: Organizar pasos de algoritmos

- **Características del sistema**:
  - Interfaz atractiva con animaciones y transiciones suaves
  - Sistema de puntuación y progreso por categoría
  - Retroalimentación inmediata con explicaciones detalladas
  - Animaciones de celebración para respuestas correctas (confeti)
  - Seguimiento de tiempo de resolución y precisión
  - Vista previa visual de símbolos de diagramas de flujo

- **Habilidades de comprensión evaluadas**:
  - ✓ Identificar símbolos y su función
  - ✓ Distinguir entre diferentes operaciones
  - ✓ Comparar soluciones algorítmicas
  - ✓ Explicar el flujo de ejecución

- **Integración con métricas**: Los resultados se almacenan localmente para evaluar:
  - Tasa de éxito en ejercicios (% de ejercicios completados correctamente)
  - Tiempo promedio de resolución por categoría
  - Precisión en las respuestas

- **Acceso**: Botón dedicado "Ejercicios" en la pantalla principal junto a "Crear nuevo diagrama"

### 📚 Sistema de Tutoriales Integrado

- **Tutoriales interactivos** con animaciones y diseño atractivo para cada tipo de nodo
- **Pantalla de bienvenida** para usuarios nuevos con introducción animada
- **16 tutoriales completos** organizados por categorías:
  - Bienvenida y conceptos básicos
  - Tutoriales específicos para cada símbolo de diagrama de flujo
  - Conexiones, validación y generación de código
- **Nivel de Comprensión (Taxonomía de Bloom)**: Los tutoriales están diseñados para que los usuarios puedan:
  - Identificar símbolos y su función
  - Distinguir entre diferentes operaciones
  - Comparar soluciones algorítmicas
  - Explicar el flujo de ejecución
- **Seguimiento de progreso**: SharedPreferences para guardar tutoriales completados
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
- [x] Generar los simbolos basicos de un ciclo while al presionar el nodo "Desicion".
- [x] **Implementación del Símbolo 6: Comentario/Nota**
  - Diálogo especializado con 4 tipos de comentarios (simple, bloque, sección, nota)
  - Forma característica de rectángulo con esquina doblada
  - Vista previa en tiempo real
  - Interpretación inteligente del texto existente
  - No requiere conexiones (opcional para documentación)
  - Genera comentarios válidos en código C (// y /* */)
  - Color amarillo distintivo para fácil identificación
- [x] **Implementación del Símbolo: Subproceso/Función**
  - Diálogo especializado con 5 tipos de llamadas (simple, con parámetros, con retorno, predefinidas, personalizado)
  - Forma característica de rectángulo con doble línea de borde
  - Catálogo de 8 funciones matemáticas predefinidas (calcularPromedio, factorial, potencia, etc.)
  - Vista previa en tiempo real con formato de función
  - Interpretación inteligente del texto existente
  - Genera llamadas a función válidas en código C
  - Color morado/violeta distintivo
  - Cumplimiento de estándares ANSI/ISO 5807 (símbolo de subrutina predefinida)

### 🔄 En Desarrollo

- [ ] Tutorial integrado para cada tipo de nodo
- [ ] Validación semántica entre nodos de preparación y decisión
- [ ] Plantillas de bucles comunes (contador, suma, búsqueda)
- [ ] Más plantillas de algoritmos comunes
- [ ] Generación de código C funcional mejorada

### 🎯 Próximas Funcionalidades

- [ ] Compartir diagramas
- [ ] Exportación de código a archivos

## 📄 Licencia

Este proyecto es parte de un proyecto final académico para el desarrollo de aplicaciones móviles nativas.

## 🤝 Contribuciones

Este es un proyecto académico. Para sugerencias o mejoras, por favor crea un issue en el repositorio.

---

*Desarrollado con ❤️ usando Flutter*