# Pantallas implementadas (FlowDiagram App)

Este documento inventaría las pantallas y vistas modales implementadas en la aplicación Flutter, con base en los widgets presentes en `lib/screens/` y los diálogos invocados desde esas pantallas.

## Pantallas (navegación)

### 1) Inicio de sesión

**Widget:** `LoginScreen`

**Objetivo:** Permitir el acceso a la aplicación mediante autenticación por correo/contraseña o mediante modo invitado.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Formulario de acceso con correo y contraseña.
- Indicador de modo sin conexión cuando falla el acceso remoto.
- Acceso al registro de cuenta.
- Opción para continuar como invitado.

---

### 2) Registro de cuenta

**Widget:** `RegisterScreen`

**Objetivo:** Crear una cuenta de usuario con datos básicos y rol inicial.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Formulario de creación de cuenta: nombre, correo y contraseña.
- Selección de rol (usuario/administrador) según implementación actual.
- Validaciones de campos y mensajes de error.
- Regreso a la pantalla de inicio de sesión al finalizar.

---

### 3) Recorrido inicial (primera ejecución)

**Widget:** `WelcomeScreen`

**Objetivo:** Presentar un recorrido de varias páginas al primer uso y marcar el estado de “primera vez completada”.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Navegación por páginas (PageView) con controles de avanzar/retroceder.
- Opción “Saltar” para finalizar inmediatamente.
- Persistencia del estado de primera ejecución mediante servicio.

---

### 4) Gestión de diagramas y plantillas

**Widget:** `LoadDiagramScreen`

**Objetivo:** Centralizar la gestión de diagramas del usuario: listar, abrir, eliminar y crear diagramas; además de exponer plantillas disponibles.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Pestañas para separar “Mis diagramas” y “Plantillas”.
- Apertura de un diagrama o plantilla en el editor.
- Eliminación de diagramas del usuario.
- Creación de un nuevo diagrama.
- Accesos a: perfil, métricas y configuración administrativa (según controles visibles).
- Acceso a un módulo de guías internas mediante botón flotante.

---

### 5) Editor de diagramas

**Widget:** `EditorScreen`

**Objetivo:** Crear y editar diagramas de flujo en un canvas interactivo, con herramientas para validar, guardar, exportar y generar código.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Canvas para construcción del diagrama: nodos y conexiones.
- Validación estructural del diagrama con reporte en vista modal.
- Guardado del diagrama (nuevo/actualización) con indicador de cambios pendientes.
- Carga de diagramas mediante navegación a la pantalla de gestión.
- Exportación del diagrama a imagen (según opciones disponibles en el editor).
- Generación de código en dos modalidades: generación directa y conversión por pipeline, con resultados en vistas modales.
- Edición de propiedades de nodos mediante diálogos especializados.

---

### 6) Métricas

**Widget:** `MetricsScreen`

**Objetivo:** Visualizar métricas de uso y rendimiento; en rol administrador, exponer métricas globales y acceso al panel administrativo.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Carga y refresco de métricas.
- Visualización de resúmenes y secciones de actividad.
- Acceso a panel administrativo de métricas cuando el usuario tiene rol administrador.

---

### 7) Perfil

**Widget:** `ProfileScreen`

**Objetivo:** Gestionar información de la cuenta, accesos a configuración y operaciones de datos (sincronización, eliminación) según el tipo de usuario.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Visualización de datos del usuario (nombre, correo, rol).
- Acceso a métricas del usuario.
- Acceso a panel administrativo (cuando aplica).
- Acceso a configuración de tema.
- Opciones de sincronización con la nube (inteligente, subir todo, bajar todo).
- Eliminación de datos locales (modo invitado) o eliminación de cuenta y datos (cuenta autenticada).
- Cierre de sesión con confirmación.

---

### 8) Configuración de tema

**Widget:** `ThemeSettingsScreen`

**Objetivo:** Permitir la selección y vista previa del tema de la aplicación.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Selector de tema (mediante widget especializado).
- Vista previa/explicación de elementos que cambia el tema.
- Persistencia de la selección de tema mediante servicio.

---

### 9) Configuración administrativa

**Widget:** `AdminSetupScreen`

**Objetivo:** Operaciones administrativas de preparación, como creación/promoción de usuarios con rol administrador.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Visualización del estado actual del usuario (correo/rol).
- Creación de un usuario administrador por defecto (según implementación).
- Promoción de un usuario a administrador por correo.

---

### 10) Panel administrativo (métricas del sistema)

**Widget:** `AdminMetricsScreen`

**Objetivo:** Explorar métricas globales, métricas por usuario y análisis, con opciones de exportación.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Pestañas: Resumen / Usuarios / Análisis.
- Recarga de métricas globales y por usuario.
- Exportación de métricas a TXT/PNG/JPG.
- Visualización de listados y agregados del sistema.

---

### 11) Guías internas (catálogo)

**Widget:** `TutorialListScreen`

**Objetivo:** Proveer un catálogo categorizado de guías internas y abrir cada guía en una vista modal.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Listado por categorías.
- Estado de finalización por guía.
- Apertura de una guía en un diálogo (`TutorialWidget`).
- Diálogo informativo “Acerca de …” accesible desde el AppBar.

---

### 12) Cuestionarios (catálogo)

**Widget:** `ExercisesScreen`

**Objetivo:** Mostrar un catálogo de cuestionarios por categorías con progreso y puntaje.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Listado de categorías con estadísticas generales.
- Visualización de progreso por categoría.
- Apertura de un cuestionario en la pantalla de ejecución.
- Diálogo de información del módulo.

---

### 13) Cuestionarios (ejecución)

**Widget:** `ExerciseQuestionScreen`

**Objetivo:** Ejecutar una secuencia de ítems de un cuestionario, registrar respuestas y mostrar resultados.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Presentación del ítem actual con barra de progreso.
- Manejo de distintos tipos de ítems (según modelos usados).
- Confirmación al intentar salir.
- Cálculo de puntaje y presentación de resultado en vista modal (`ExerciseResultDialog`).

---

### 14) Diagnóstico de autenticación

**Widget:** `DebugScreen`

**Objetivo:** Mostrar estado y acciones de diagnóstico relacionadas con autenticación.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Ejecución de diagnóstico y refresco de resultados.
- Cierre de sesión completo.
- Acciones auxiliares (según implementación de la pantalla).

**Nota:** En la navegación actual, el acceso a esta pantalla aparece comentado en el inicio de sesión.

---

### 15) Perfil (variante no integrada)

**Widget:** `ProfileScreenNew`

**Objetivo:** Variante de pantalla de perfil presente en el repositorio.

**Captura (a insertar):**

_(Inserte aquí la captura de la pantalla.)_

**Funciones:**
- Funcionalidad similar a `ProfileScreen` (según implementación).

**Nota:** No se encontró enlazada desde la navegación principal en el estado actual.

---

## Vistas modales (diálogos) relevantes

Estas vistas se presentan como diálogos desde distintas pantallas (principalmente desde el editor).

### A) Guardado de diagrama

**Widget:** `SaveDiagramDialog`

**Objetivo:** Capturar nombre y descripción para guardar o actualizar un diagrama.

**Funciones:**
- Validación de nombre.
- Retorno de datos al editor (nombre/descripcion).

---

### B) Resultados de validación estructural

**Widget:** `ValidationResultDialog`

**Objetivo:** Mostrar el resultado de la validación del diagrama (errores y advertencias).

**Funciones:**
- Listado de errores y advertencias.
- Mensajes de estado para continuar o corregir.

---

### C) Resultados del conversor (pipeline)

**Widget:** `CompilerResultsDialog`

**Objetivo:** Presentar un reporte de conversión por fases y el código generado.

**Funciones:**
- Pestañas por fase (incluye: general, léxico, sintáctico, semántico, optimización y código).
- Visualización de tokens, árbol sintáctico/AST, tabla de símbolos, métricas y errores.
- Copiado de código y copiado de reporte completo al portapapeles.

---

### D) Edición de nodos (propiedades)

**Widget principal:** `NodeEditorDialog`

**Objetivo:** Editar el contenido/propiedades del nodo seleccionado y, según el tipo, abrir un editor especializado.

**Funciones:**
- Enrutamiento a diálogos especializados por tipo de nodo: proceso, decisión, datos, preparación, subproceso, conector, comentario.
- Edición de texto y confirmación/cancelación.

**Nota:** En el repositorio existen otros diálogos de nodo (p. ej. entrada/salida o variable) que no se encontraron invocados desde la navegación actual.

---

### E) Resultado de cuestionario

**Widget:** `ExerciseResultDialog`

**Objetivo:** Mostrar el resultado de un ítem y el puntaje obtenido.

**Funciones:**
- Resumen de resultado y puntos.
- Comparación de respuesta esperada vs respuesta del usuario cuando aplica.

---

## Comparación con el índice de tesis (Ciclo 2 / Capítulo 10)

En [docs/indice_tt2.md](indice_tt2.md), el Capítulo 10 enumera cinco “pantallas principales”. Con base en la implementación actual:

- **10.1 Pantalla de Inicio de sesión:** corresponde a `LoginScreen`.
- **10.2 Pantalla del Editor de Diagramas:** corresponde a `EditorScreen`.
- **10.3 Pantalla del Validador Semántico:** en la app no existe como pantalla independiente; el resultado se presenta como vista modal de validación estructural (`ValidationResultDialog`) y/o como pestaña de fase semántica dentro de `CompilerResultsDialog` al ejecutar el pipeline.
- **10.4 Pantalla del Código Generado:** en la app no existe como pantalla independiente; el código se presenta como vista modal (generación directa) y/o dentro de `CompilerResultsDialog` (pestaña de código).
- **10.5 Pantalla de Gestión de Proyectos:** se alinea con `LoadDiagramScreen` (gestión de diagramas y plantillas) y el diálogo `SaveDiagramDialog` (guardado/actualización).

**Pantallas implementadas que no aparecen en el listado del Capítulo 10 (índice actual):**
- Registro (`RegisterScreen`).
- Recorrido inicial de primera ejecución (`WelcomeScreen`).
- Perfil y configuración de tema (`ProfileScreen`, `ThemeSettingsScreen`).
- Métricas y panel administrativo (`MetricsScreen`, `AdminSetupScreen`, `AdminMetricsScreen`).
- Catálogo de guías internas y módulo de cuestionarios (`TutorialListScreen`, `ExercisesScreen`, `ExerciseQuestionScreen`).

Si deseas, puedo proponerte un ajuste directo del Capítulo 10 (una lista revisada) para que quede alineado con la implementación real y con tu estructura de capítulos.