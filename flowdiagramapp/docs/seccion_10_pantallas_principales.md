# 10 Pantallas principales

Esta sección describe las pantallas y vistas modales implementadas en la aplicación FlowCode. La interfaz se organiza en dos grupos: pantallas de navegación principal, accesibles a través del flujo de la aplicación, y vistas modales, invocadas desde el editor para presentar resultados o capturar datos del usuario.

---

## 10.1 Pantalla de inicio de sesión

**Propósito y función**

La pantalla de inicio de sesión constituye el punto de entrada a la aplicación. Permitió al usuario autenticarse mediante correo electrónico y contraseña, o continuar sin cuenta en modo invitado. Cuando el acceso remoto no estuvo disponible, la pantalla presentó un indicador de modo sin conexión. Desde esta pantalla también se accedió a la pantalla de registro de cuenta.

**Funciones implementadas:**

- Formulario de acceso con correo electrónico y contraseña.
- Indicador de modo sin conexión cuando el acceso remoto no estuvo disponible.
- Acceso a la pantalla de registro de cuenta.
- Opción para continuar como invitado.

Figura 1. Pantalla de inicio de sesión.

---

## 10.2 Pantalla de registro de cuenta

**Propósito y función**

La pantalla de registro permitió crear una cuenta de usuario con datos básicos. Al finalizar el proceso, la navegación regresó a la pantalla de inicio de sesión.

**Funciones implementadas:**

- Formulario de creación de cuenta: nombre completo, correo electrónico y contraseña.
- Validaciones de campos con mensajes de error en línea.
- Navegación de regreso a la pantalla de inicio de sesión al finalizar o cancelar.

Figura 2. Pantalla de registro de cuenta.

---

## 10.3 Recorrido inicial (primera ejecución)

**Propósito y función**

En la primera ejecución de la aplicación se presentó un recorrido de introducción de varias páginas. Al completarlo o saltarlo, el estado de primera ejecución quedó registrado de forma persistente para no mostrarse en ejecuciones posteriores.

**Funciones implementadas:**

- Navegación por páginas con controles de avance y retroceso.
- Opción para saltar el recorrido y finalizar inmediatamente.
- Persistencia del estado de primera ejecución mediante el servicio correspondiente.

Figura 3. Recorrido inicial de la aplicación.

---

## 10.4 Pantalla de gestión de diagramas y plantillas

**Propósito y función**

Esta pantalla centralizó la gestión de diagramas del usuario. Presentó dos pestañas: "Mis diagramas" y "Plantillas", permitiendo abrir diagramas existentes o plantillas predefinidas en el editor, eliminar diagramas del usuario y crear nuevos diagramas. Desde esta pantalla también se accedió al perfil del usuario, a la configuración y al módulo de guías internas.

**Funciones implementadas:**

- Pestañas para separar "Mis diagramas" y "Plantillas".
- Apertura de un diagrama o plantilla en el editor.
- Eliminación de diagramas del usuario.
- Creación de un nuevo diagrama.
- Acceso al perfil y configuración del usuario.
- Acceso al módulo de guías internas mediante botón flotante.

Figura 4. Pantalla de gestión de diagramas y plantillas.

---

## 10.5 Pantalla del editor de diagramas

**Propósito y función**

La pantalla del editor de diagramas constituyó el componente central de la aplicación. En ella se construyeron y editaron diagramas de flujo sobre un canvas interactivo. Desde esta pantalla se invocaron las principales funciones de validación, guardado, exportación y generación de código, cuyos resultados se presentaron en vistas modales especializadas.

**Funciones implementadas:**

- Canvas interactivo para construcción del diagrama mediante nodos y conexiones.
- Validación estructural del diagrama con reporte en vista modal.
- Guardado del diagrama (nuevo o actualización existente) con indicador de cambios pendientes.
- Carga de diagramas mediante navegación a la pantalla de gestión.
- Exportación del diagrama a imagen.
- Generación de código en dos modalidades: generación directa y compilación por pipeline, con resultados en vistas modales.
- Edición de propiedades de nodos mediante diálogos especializados por tipo de nodo.

Figura 5. Pantalla del editor de diagramas.

---

## 10.6 Pantalla de perfil

**Propósito y función**

La pantalla de perfil permitió gestionar la información de la cuenta, acceder a la configuración de tema y realizar operaciones de datos según el tipo de usuario (autenticado o invitado).

**Funciones implementadas:**

- Visualización de datos del usuario: nombre, correo y rol.
- Acceso a la pantalla de configuración de tema.
- Opciones de sincronización con la nube: sincronización inteligente, subir todo y bajar todo.
- Eliminación de datos locales (modo invitado) o eliminación de cuenta y datos (usuario autenticado), con diálogo de confirmación.
- Cierre de sesión con confirmación.

Figura 6. Pantalla de perfil de usuario.

---

## 10.7 Pantalla de configuración de tema

**Propósito y función**

Esta pantalla permitió seleccionar el tema visual de la aplicación. La selección se persistió mediante el servicio de preferencias correspondiente.

**Funciones implementadas:**

- Selector de tema mediante widget especializado.
- Vista previa de los elementos visuales afectados por el tema.
- Persistencia de la selección de tema.

Figura 7. Pantalla de configuración de tema.

---

## 10.8 Pantalla de guías internas

**Propósito y función**

La pantalla de guías internas presentó un catálogo categorizado de guías sobre el uso de la aplicación. Cada guía se abrió en un diálogo modal. Desde el AppBar de esta pantalla se accedió a un diálogo informativo "Acerca de…".

**Funciones implementadas:**

- Listado de guías organizado por categorías.
- Registro y visualización del estado de finalización por guía.
- Apertura de cada guía en un diálogo modal.
- Diálogo informativo "Acerca de…" accesible desde el AppBar.

Figura 8. Pantalla de guías internas.

---

## 10.9 Vistas modales (diálogos)

Las siguientes vistas se presentaron como diálogos invocados principalmente desde el editor de diagramas.

### 10.9.1 Guardado de diagrama

Permitió capturar el nombre y la descripción del diagrama para guardarlo como nuevo o actualizar uno existente. Incluyó validación del campo nombre y retornó los datos al editor al confirmar.

Figura 9. Diálogo para guardar un diagrama.

---

### 10.9.2 Resultados de validación estructural

Presentó el resultado de la validación estructural del diagrama, mostrando el listado de errores y advertencias detectados, con mensajes de estado que indicaron si el diagrama estaba listo para generar código o requería correcciones.

Figura 10. Diálogo de resultados de validación estructural.

---

### 10.9.3 Resultados del compilador (pipeline)

Presentó el reporte completo de compilación organizado en seis pestañas: resumen general, análisis léxico, árbol sintáctico (AST), análisis semántico, optimizaciones aplicadas y código C generado. Desde esta vista fue posible copiar el código generado y el reporte completo al portapapeles.

Figura 11. Diálogo de resultados del compilador.

---

### 10.9.4 Edición de propiedades de nodos

El diálogo `NodeEditorDialog` centralizó la edición de propiedades del nodo seleccionado. Según el tipo de nodo, enrutó a un diálogo especializado: proceso, decisión, datos, preparación, subproceso, conector o comentario. Cada diálogo especializado permitió editar el contenido textual del nodo con confirmación o cancelación.

Figura 12. Diálogo de edición de propiedades de un nodo.

---

## 10.10 Logo y marca

El logotipo de FlowCode presenta un diseño geométrico y minimalista. Está compuesto por bloques sólidos en tono azul oscuro interconectados mediante líneas estructuradas, simbolizando el flujo de información, la lógica modular y la conectividad de los componentes del sistema. La configuración visual en forma de nodos refleja los conceptos de "flujo" (flow) y "código" (code) que dan nombre a la aplicación.

Figura 13. Logotipo de FlowCode.
