## Tareas

Este proyecto es una aplicación móvil para Android desarrollada con Flutter, orientada a la COMPRENSIÓN de algoritmos y programación. Permite a los usuarios diseñar algoritmos mediante diagramas de flujo, utilizando plantillas o crearlos, y traducirlos automáticamente a código en lenguaje C. El sistema integrará un editor visual intuitivo, un analizador para validar la estructura lógica de los diagramas y un generador de código que produce programas funcionales en C.

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

- Implementar almacenamiento local SQLite para persistir diagramas y su información.
- Permitir cargar y editar diagramas previamente guardados.

### 5. Inicio de sesión y gestión de usuarios

- **Implementar autenticación con Firebase:**  
  - Permitir el inicio de sesión para usuarios normales y administradores utilizando Firebase Authentication.
- **Roles de usuario:**  
  - El sistema distinguirá entre usuarios normales (acceso a sus propios diagramas y métricas personales) y administradores (acceso a métricas globales y de todos los usuarios).
- **Gestión de acceso:**  
  - El administrador podrá consultar y analizar las métricas técnicas y educativas de todos los usuarios desde la aplicación, mientras que el usuario normal solo podrá ver sus propios datos y progreso.

---

### 6. Secciones de métricas y visualización

- **Implementar secciones específicas dentro de la aplicación para visualizar métricas:**
  - Crear una interfaz para que los usuarios normales puedan consultar sus métricas educativas y técnicas personales (por ejemplo, precisión del compilador, tasa de éxito en ejercicios, tiempo promedio de resolución, autoevaluación, etc.).
  - Desarrollar una sección exclusiva para administradores donde puedan ver métricas globales, estadísticas agregadas de todos los usuarios y análisis comparativos.
  - Utilizar gráficos, tablas y resúmenes visuales para facilitar la interpretación de las métricas.
  - Permitir la actualización en tiempo real de las métricas cuando se realicen nuevas acciones en la aplicación.

---

### 5. Pruebas e iteración

- Realizar pruebas funcionales para verificar la estabilidad y usabilidad del editor y generador de código.
- Corregir errores identificados durante las pruebas.
- Refinar la interfaz de usuario para mejorar la experiencia y accesibilidad.

---

### 7. Siguientes pasos y funcionalidades futuras

- **Validación semántica avanzada:** Detección de errores lógicos, variables no declaradas, caminos sin salida, etc.
- **Soporte para estructuras de control adicionales:** Implementar ciclos (while, for) y otras estructuras algorítmicas.
- **Exportación e importación:** Permitir exportar diagramas como imágenes y el código generado como archivos .c o .txt.
- **Sincronización y respaldo en la nube:** Opcionalmente, permitir respaldos y sincronización de diagramas a través de internet.
- **Métricas educativas y técnicas:** Integrar un módulo para que los usuarios puedan consultar su progreso, tiempo de aprendizaje, tasa de éxito en ejercicios, autoevaluaciones, entre otros.
- **Documentación y tutoriales:** Agregar ayuda interactiva, tutoriales y documentación técnica para facilitar el aprendizaje y uso de la aplicación.
- **Modo oscuro y personalización visual.**
- **Capacidades colaborativas:** Compartir diagramas o proyectos entre usuarios.

---

Este plan está enfocado en entregar una primera versión estable, funcional y útil para la materia de "Desarrollo de aplicaciones móviles nativas", y deja sentadas las bases para futuras mejoras y extensiones en el trabajo terminal. La idea es  realizar la "primera versión estable" consiste en realizar el editor grafico y despues generar el codigo usando operaciones basicas(if, else, print). En el futuro se va a realizar el compilador de lenguaje c para poder realizar analizador lexico, sintactico, semantico, etc.
Este proyecto presenta avances de las funcionalidades 1,2,3,4,5.
¿Puedes ayudarme a con la funcionalidad 6?



## EXTRA
Sugerencias de funcionalidades y mejoras que podríamos agregar a tu aplicación para hacerla más completa y atractiva:

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

