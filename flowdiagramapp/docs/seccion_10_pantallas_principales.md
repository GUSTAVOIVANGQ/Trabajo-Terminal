# 10. Pantallas principales

Esta sección describe las pantallas implementadas en FlowCode y las vistas modales invocadas desde ellas. Las pantallas corresponden a destinos de navegación independientes dentro de la aplicación; las vistas modales se presentan como diálogos superpuestos sobre la pantalla activa y no forman parte del flujo de navegación principal.

---

## 10.1 Inicio de sesión

**Propósito**

Pantalla de entrada a la aplicación. Gestiona la autenticación del usuario mediante credenciales de correo electrónico y contraseña, así como el acceso en modo invitado sin cuenta registrada.

**Funcionalidades**

- Formulario de autenticación con campos de correo electrónico y contraseña.
- Indicador de conectividad cuando el acceso remoto no está disponible.
- Acceso a la pantalla de registro de cuenta.
- Opción para continuar como usuario invitado sin autenticación.

_(Insertar captura de pantalla)_

---

## 10.2 Registro de cuenta

**Propósito**

Permite la creación de una cuenta de usuario con datos básicos. Al completar el registro, la sesión se inicia automáticamente y el usuario es redirigido al flujo principal.

**Funcionalidades**

- Formulario de creación de cuenta con campos de nombre completo, correo electrónico y contraseña.
- Validación de campos con mensajes de error en línea.
- Navegación de regreso a la pantalla de inicio de sesión.

_(Insertar captura de pantalla)_

---

## 10.3 Recorrido inicial

**Propósito**

Se presenta únicamente en la primera ejecución de la aplicación. Introduce al usuario las funcionalidades principales mediante una secuencia de páginas informativas.

**Funcionalidades**

- Navegación secuencial entre páginas mediante controles de avance y retroceso.
- Opción para omitir el recorrido y acceder directamente a la aplicación.
- Registro del estado de primera ejecución para suprimir el recorrido en usos posteriores.

_(Insertar captura de pantalla)_

---

## 10.4 Gestión de diagramas y plantillas

**Propósito**

Centraliza la administración de los diagramas del usuario. Expone los diagramas propios y las plantillas disponibles, y sirve como punto de acceso al editor y a otras secciones de la aplicación.

**Funcionalidades**

- Pestañas diferenciadas para "Mis diagramas" y "Plantillas".
- Apertura de un diagrama o plantilla en el editor.
- Eliminación de diagramas del usuario.
- Creación de un nuevo diagrama en blanco.
- Acceso al perfil del usuario y a la configuración de la aplicación.
- Acceso al catálogo de guías internas mediante botón flotante.

_(Insertar captura de pantalla)_

---

## 10.5 Editor de diagramas

**Propósito**

Pantalla principal de trabajo. Permite construir y editar diagramas de flujo mediante un canvas interactivo, y ejecutar el pipeline de conversión para obtener código C a partir del diagrama.

**Funcionalidades**

- Canvas interactivo para la construcción del diagrama mediante nodos y conexiones.
- Validación estructural del diagrama con presentación de resultados en vista modal.
- Guardado del diagrama (nuevo o actualización) con indicador de cambios pendientes.
- Carga de diagramas mediante navegación a la pantalla de gestión.
- Exportación del diagrama a imagen.
- Generación de código en dos modalidades: generación directa y compilación por pipeline completo, con resultados presentados en vista modal.
- Edición de propiedades de nodos mediante diálogos especializados por tipo.

_(Insertar captura de pantalla)_

---

## 10.6 Perfil

**Propósito**

Permite al usuario gestionar los datos de su cuenta, las opciones de sincronización con la nube y las operaciones de eliminación de datos, según el tipo de usuario —autenticado o invitado.

**Funcionalidades**

- Visualización de datos del usuario: nombre, correo electrónico y rol.
- Acceso a la configuración de tema de la interfaz.
- Opciones de sincronización con la nube: sincronización inteligente, subida total y descarga total.
- Eliminación de datos locales (usuario invitado) o eliminación de cuenta y datos asociados (usuario autenticado).
- Cierre de sesión con diálogo de confirmación.

_(Insertar captura de pantalla)_

---

## 10.7 Configuración de tema

**Propósito**

Permite seleccionar el tema visual de la aplicación y persiste la preferencia entre sesiones.

**Funcionalidades**

- Selector de tema mediante widget especializado.
- Vista previa de los elementos afectados por el tema seleccionado.
- Persistencia de la selección mediante servicio de preferencias.

_(Insertar captura de pantalla)_

---

## 10.8 Guías internas

**Propósito**

Provee un catálogo categorizado de guías de uso de la aplicación. Cada guía se abre en una vista modal desde esta pantalla.

**Funcionalidades**

- Listado de guías organizado por categorías.
- Indicador de estado de finalización por guía.
- Apertura de la guía seleccionada en un diálogo.
- Diálogo informativo "Acerca de" accesible desde la barra de navegación superior.

_(Insertar captura de pantalla)_

---

## 10.9 Vistas modales

Las siguientes vistas se presentan como diálogos desde distintas pantallas, principalmente desde el editor. No constituyen destinos de navegación independientes.

### 10.9.1 Guardado de diagrama

**Propósito**

Captura el nombre y la descripción del diagrama para registrar o actualizar su entrada en la base de datos local.

**Funcionalidades**

- Campo de nombre con validación de contenido no vacío.
- Campo opcional de descripción.
- Retorno de los datos capturados al editor para completar la operación de guardado.

---

### 10.9.2 Resultados de validación estructural

**Propósito**

Presenta el resultado de la validación estructural del diagrama activo, con los errores y advertencias detectados por el analizador.

**Funcionalidades**

- Listado de errores y advertencias clasificados por severidad.
- Mensaje de estado que indica si el diagrama está listo para la generación de código o requiere correcciones.

---

### 10.9.3 Resultados del compilador

**Propósito**

Presenta el reporte completo de compilación por fases y el código C generado a partir del diagrama.

**Funcionalidades**

- Organización por pestañas correspondientes a cada fase del pipeline: resumen general, análisis léxico, análisis sintáctico, análisis semántico, optimización y código generado.
- Visualización de tokens, árbol sintáctico (AST), tabla de símbolos, métricas de compilación y errores por fase.
- Copiado del código generado y del reporte completo al portapapeles.

---

### 10.9.4 Edición de propiedades de nodo

**Propósito**

Permite editar el contenido y las propiedades del nodo seleccionado en el editor, enrutando a un diálogo especializado según el tipo de nodo.

**Funcionalidades**

- Enrutamiento a editores especializados por tipo de nodo: proceso, decisión, datos, preparación, subproceso, conector y comentario.
- Confirmación o cancelación de la edición con restauración del estado previo en caso de cancelación.

---

## 10.10 Logo y marca

El logotipo de FlowCode presenta un diseño geométrico y minimalista que sintetiza la esencia funcional del proyecto. Compuesto por bloques sólidos en tono azul oscuro interconectados mediante líneas estructuradas, el emblema representa el flujo de información, la lógica modular y la conectividad de los sistemas algorítmicos. La configuración en forma de nodos hace referencia directa al concepto de flujo (*flow*) y programación (*code*).

_(Insertar figura: logotipo de FlowCode)_
