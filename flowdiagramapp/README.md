# FlowDiagram App

Una aplicación móvil Flutter que permite a los usuarios diseñar algoritmos mediante diagramas de flujo y traducirlos automáticamente a código en lenguaje C.

## 📋 Descripción

FlowDiagram App es un editor visual intuitivo que permite crear diagramas de flujo de forma sencilla y generar código C funcional automáticamente. La aplicación incluye plantillas predefinidas, validación de estructura lógica y un sistema de almacenamiento local para guardar y cargar diagramas.

## ✨ Funcionalidades Implementadas

### 🎨 Editor Visual
- **Paleta de nodos**: Incluye todos los tipos de nodos esenciales:
  - Nodo de inicio (círculo verde)
  - Nodo de fin (círculo rojo)
  - Nodo de proceso (rectángulo azul)
  - Nodo de decisión (rombo amarillo)
  - Nodo de entrada (paralelogramo púrpura)
  - Nodo de salida (paralelogramo índigo)
  - Nodo de variable (rectángulo verde azulado)

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

### 🔄 En Desarrollo
- [ ] Inicio de sesión y funcionamiento offline
- [ ] Métricas de Evaluación
- [ ] Optimización del rendimiento del canvas
- [ ] Más plantillas de algoritmos comunes
- [ ] Exportación de código a archivos
- [ ] Modo oscuro

### 🎯 Próximas Funcionalidades
- [ ] Soporte para ciclos (for, while)
- [ ] Generación de código en otros lenguajes (Python, Java)
- [ ] Compartir diagramas
- [ ] Importar/exportar diagramas

## 📄 Licencia

Este proyecto es parte de un proyecto final académico para el desarrollo de aplicaciones móviles nativas.

## 🤝 Contribuciones

Este es un proyecto académico. Para sugerencias o mejoras, por favor crea un issue en el repositorio.

---

*Desarrollado con ❤️ usando Flutter*

## Contenido Extra
Aquí tienes algunas sugerencias de funcionalidades y mejoras que podrías agregar a tu aplicación para hacerla más completa y atractiva:

---

### 🚀 Funcionalidades Avanzadas Sugeridas

- **Exportación a otros lenguajes**  
  Permitir la generación de código en otros lenguajes populares como Python, Java, JavaScript o pseudocódigo.

- **Simulación y ejecución paso a paso**  
  Implementar una función para simular la ejecución del diagrama, mostrando el flujo y los valores de las variables en tiempo real.

- **Compartir diagramas**  
  Permitir exportar diagramas como imágenes (PNG, SVG) o archivos de proyecto para compartir con otros usuarios.

- **Colaboración en tiempo real**  
  Integrar funcionalidades para que varios usuarios puedan editar un diagrama simultáneamente (requiere backend).

- **Historial de cambios y deshacer/rehacer**  
  Añadir soporte para deshacer y rehacer acciones, así como ver el historial de cambios del diagrama.

- **Comentarios y anotaciones**  
  Permitir agregar notas o comentarios a los nodos y conexiones para documentación o colaboración.

- **Validaciones semánticas avanzadas**  
  Detectar bucles infinitos, variables no inicializadas, o caminos no alcanzables en el diagrama.

- **Soporte para subdiagramas o funciones**  
  Permitir crear subdiagramas o funciones reutilizables dentro de un diagrama principal.

- **Personalización de estilos**  
  Permitir cambiar colores, formas y estilos de los nodos y conexiones para una mejor visualización.

- **Modo oscuro y temas personalizados**  
  Añadir soporte para modo oscuro y selección de temas de color.

- **Integración con la nube**  
  Sincronizar diagramas con servicios en la nube (Google Drive, Dropbox, etc.) para respaldo y acceso multiplataforma.

- **Tutoriales interactivos y ayuda contextual**  
  Incluir tutoriales paso a paso y ayuda contextual para nuevos usuarios.

- **Soporte para dispositivos de escritorio y web**  
  Adaptar la aplicación para funcionar también en Flutter Web y Desktop.

---

Estas mejoras pueden hacer que tu aplicación sea más útil, educativa y atractiva para una mayor variedad de usuarios.

---

Explica caracteristicas de este proyecto cual es la arquitectura del sistema, herramientas usadas, librerias, porque se usaron esas librerias, limitacioes y base de datos.

---

Este proyecto es una aplicación móvil para Android desarrollada con Flutter, orientada a la COMPRENSIÓN de algoritmos y programación. Permite a los usuarios diseñar algoritmos mediante diagramas de flujo, utilizando plantillas o crearlos, y traducirlos automáticamente a código en lenguaje C. El sistema integrará un editor visual intuitivo, un analizador para validar la estructura lógica de los diagramas y un generador de código que produce programas funcionales en C.

--- 

Este proyecto es una aplicación móvil para Android desarrollada con Flutter, orientada a la enseñanza de algoritmos y programación. Permite a los usuarios diseñar algoritmos mediante diagramas de flujo, utilizando plantillas, y traducirlos automáticamente a código en lenguaje C. El sistema integrará un editor visual intuitivo, un analizador para validar la estructura lógica de los diagramas y un generador de código que produce programas funcionales en C.

A continuación, se describe el plan de desarrollo para la aplicación base:

### 1. Implementación del editor visual básico
- Crear nodos fundamentales: inicio, fin, declaración de variables, condicional, entrada y salida.
- Implementar la funcionalidad para conectar nodos mediante líneas con flechas.
- Agregar soporte para arrastrar y soltar nodos, así como zoom y desplazamiento en el área de trabajo.

### 2. Validación básica del diagrama
- Verificar que el diagrama incluya al menos un nodo de inicio y uno de fin.
- Validar que las conexiones entre nodos sigan reglas lógicas (por ejemplo: el nodo de inicio no debe tener entradas).
- Proveer retroalimentación visual de errores estructurales.

### 3. Generación de código para estructuras básicas
- Crear un modelo de representación intermedia para los diagramas de flujo.
- Desarrollar un generador de código que traduzca los nodos básicos a código en lenguaje C.
- Implementar la visualización en tiempo real del código generado conforme se edita el diagrama.

### 4. Funcionalidad de guardado y carga
- Implementar almacenamiento local (SQLite o Hive) para persistir diagramas y su información.
- Permitir cargar y editar diagramas previamente guardados.

### 5. Pruebas e iteración
- Realizar pruebas funcionales para verificar la estabilidad y usabilidad del editor y generador de código.
- Corregir errores identificados durante las pruebas.
- Refinar la interfaz de usuario para mejorar la experiencia y accesibilidad.

---

### 6. Inicio de sesión y gestión de usuarios

- **Implementar autenticación con Firebase:**  
  - Permitir el inicio de sesión para usuarios normales y administradores utilizando Firebase Authentication.
- **Roles de usuario:**  
  - El sistema distinguirá entre usuarios normales (acceso a sus propios diagramas y métricas personales) y administradores (acceso a métricas globales y de todos los usuarios).
- **Gestión de acceso:**  
  - El administrador podrá consultar y analizar las métricas técnicas y educativas de todos los usuarios desde la aplicación, mientras que el usuario normal solo podrá ver sus propios datos y progreso.

---

### 7. Secciones de métricas y visualización

- **Implementar secciones específicas dentro de la aplicación para visualizar métricas:**
  - Crear una interfaz para que los usuarios normales puedan consultar sus métricas educativas y técnicas personales (por ejemplo, precisión del compilador, tasa de éxito en ejercicios, tiempo promedio de resolución, autoevaluación, etc.).
  - Desarrollar una sección exclusiva para administradores donde puedan ver métricas globales, estadísticas agregadas de todos los usuarios y análisis comparativos.
  - Utilizar gráficos, tablas y resúmenes visuales para facilitar la interpretación de las métricas.
  - Permitir la actualización en tiempo real de las métricas cuando se realicen nuevas acciones en la aplicación.

---

### 8. Siguientes pasos y funcionalidades futuras

- **Validación semántica avanzada:** Detección de errores lógicos, variables no declaradas, caminos sin salida, etc.
- **Soporte para estructuras de control adicionales:** Implementar ciclos (while, for) y otras estructuras algorítmicas.
- **Exportación e importación:** Permitir exportar diagramas como imágenes y el código generado como archivos .c o .txt.
- **Sincronización y respaldo en la nube:** Opcionalmente, permitir respaldos y sincronización de diagramas a través de internet.
- **Métricas educativas y técnicas:** Integrar un módulo para que los usuarios puedan consultar su progreso, tiempo de aprendizaje, tasa de éxito en ejercicios, autoevaluaciones, entre otros.
- **Documentación y tutoriales:** Agregar ayuda interactiva, tutoriales y documentación técnica para facilitar el aprendizaje y uso de la aplicación.
- **Modo oscuro y personalización visual.**
- **Capacidades colaborativas:** Compartir diagramas o proyectos entre usuarios.

---

Este plan está enfocado en entregar una primera versión estable, funcional y útil para la materia de "Desarrollo de aplicaciones móviles nativas", y deja sentadas las bases para futuras mejoras y extensiones en el trabajo terminal. La idea es  realizar la "primera versión estable" consiste en realizar el editor grafico y despues generar el codigo usando operaciones basicas(if, else, print). En el futuro se va a realizar el compilador de lenguaje c para poder realizar analizador lexico, sintactico, semantico etc.)
Este proyecto presenta avances de las funcionalidades 1,2,3,4,5.
¿Puedes ayudarme a con la funcionalidad 6?