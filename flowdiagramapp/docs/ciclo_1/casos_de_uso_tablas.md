# Tablas - Casos de Uso

## Tabla 32 Actores del Sistema

| Actor   | Descripción                                                                                          | Rol Principal                          |
|---------|------------------------------------------------------------------------------------------------------|----------------------------------------|
| Usuario | Usuario (desarrollador) principal que utiliza la aplicación para diseñar algoritmos y generar código C | Crear y editar diagramas, generar código |

---

## Tabla 33 CU01 - Crear Nuevo Diagrama

| Elemento        | Descripción                                                          |
|-----------------|----------------------------------------------------------------------|
| ID              | CU01                                                                 |
| Nombre          | Crear Nuevo Diagrama                                                 |
| Actor Principal | Usuario                                                              |
| Objetivo        | Iniciar un nuevo proyecto de diagrama de flujo                       |
| Precondiciones  | Aplicación instalada y ejecutándose · Permisos de escritura en almacenamiento local |
| Postcondiciones | Nuevo archivo de proyecto creado · Editor listo para recibir elementos · Proyecto en lista de recientes |

---

## Tabla 34 Flujos alternativos - CU01

| Escenario                  | Condición                               | Acción del Sistema                                            |
|----------------------------|-----------------------------------------|---------------------------------------------------------------|
| FA1: Cancelar creación     | Usuario cancela durante configuración   | Retorna a pantalla principal sin crear archivos               |
| FA2: Error de almacenamiento | Espacio insuficiente detectado       | Muestra mensaje de error y sugiere liberar espacio            |
| FA3: Nombre duplicado      | Nombre de proyecto ya existe            | Solicita nombre alternativo o confirmación de sobrescritura   |

---

## Tabla 35 CU02 - Agregar y Conectar Elementos

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU02                                                                         |
| Nombre          | Agregar y Conectar Elementos                                                 |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Construir la lógica del algoritmo mediante símbolos y conexiones              |
| Precondiciones  | Diagrama abierto en el editor · Área de trabajo visible y accesible          |
| Postcondiciones | Elementos integrados en el diagrama · Conexiones establecidas · Código generado actualizado |

---

## Tabla 36 Flujos alternativos - CU02

| Escenario                  | Condición                                | Acción del Sistema                            |
|----------------------------|------------------------------------------|-----------------------------------------------|
| FA1: Conexión inválida     | Usuario intenta conexión no permitida    | Feedback visual negativo y mensaje explicativo |
| FA2: Espacio insuficiente  | Área de trabajo llena                    | Ajusta zoom o desplaza vista automáticamente   |
| FA3: Posición ocupada      | Elemento en posición conflictiva         | Sugiere posiciones alternativas cercanas       |

---

## Tabla 37 CU03 - Editar Propiedades de Elementos

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU03                                                                         |
| Nombre          | Editar Propiedades de Elementos                                              |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Definir la lógica detallada de cada elemento del diagrama                    |
| Precondiciones  | Al menos un elemento en el diagrama · Elemento seleccionable                 |
| Postcondiciones | Propiedades actualizadas · Validación semántica ejecutada · Código generado actualizado |

---

## Tabla 38 Flujos alternativos - CU03

| Escenario                    | Condición                                | Acción del Sistema                                              |
|------------------------------|------------------------------------------|-----------------------------------------------------------------|
| FA1: Sintaxis incorrecta     | Usuario ingresa expresión inválida       | Previene confirmación, mantiene diálogo abierto con indicadores de error |
| FA2: Cancelar edición        | Usuario cancela el diálogo               | Restaura propiedades originales sin cambios                     |
| FA3: Variable no definida    | Usuario referencia variable inexistente  | Marca error y sugiere variables disponibles                     |

---

## Tabla 39 CU04 - Validar Estructura del Diagrama

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU04                                                                         |
| Nombre          | Validar Estructura del Diagrama                                              |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Validar que la estructura del diagrama sea correcta antes de generar código   |
| Precondiciones  | Diagrama con al menos un elemento · Motor de validación inicializado         |
| Postcondiciones | Estado de validación actualizado · Elementos problemáticos identificados · Generador de código informado |

---

## Tabla 40a Flujos Alternativos - CU04

| Escenario                        | Condición                                      | Acción del Sistema                                                |
|----------------------------------|-------------------------------------------------|-------------------------------------------------------------------|
| FA1: Sin nodo de inicio          | Diagrama no contiene símbolo de inicio          | Muestra error indicando la ausencia de nodo de inicio             |
| FA2: Sin nodo de fin             | Diagrama no contiene símbolo de fin             | Muestra error indicando la ausencia de nodo de fin                |
| FA3: Nodos desconectados         | Existen elementos sin conexión al flujo principal | Resalta nodos desconectados y sugiere conectarlos o eliminarlos |
| FA4: Ciclo infinito detectado    | Validación detecta un ciclo sin condición de salida | Muestra advertencia indicando posible ciclo infinito           |

---

## Tabla 40 CU05 - Realizar Análisis Semántico

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU05                                                                         |
| Nombre          | Realizar Análisis Semántico                                                  |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Validar la consistencia semántica de variables y tipos declarados en el diagrama |
| Precondiciones  | Validación estructural aprobada · Al menos un elemento con contenido semántico |
| Postcondiciones | Tabla de símbolos actualizada · Errores semánticos identificados · Información lista para generador de código |

---

## Tabla 41 Flujos Alternativos - CU05

| Escenario                     | Condición                                 | Acción del Sistema                                                  |
|-------------------------------|-------------------------------------------|---------------------------------------------------------------------|
| FA1: Expresión compleja       | Analizador no puede evaluar completamente | Presenta advertencia en lugar de error, permite continuar           |
| FA2: Inconsistencia interna   | Error en el algoritmo de análisis         | Solicita revisión manual, registra error para debugging             |
| FA3: Múltiples tipos posibles | Variable usada con tipos ambiguos         | Solicita aclaración al usuario o asume tipo más general             |

---

## Tabla 42 CU06 - Generar Código C

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU06                                                                         |
| Nombre          | Generar Código C                                                             |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Producir código C funcional a partir del diagrama validado                    |
| Precondiciones  | Validaciones aprobadas sin errores críticos · Al menos un camino completo inicio-fin |
| Postcondiciones | Código C sintácticamente correcto generado · Código disponible para visualización y exportación |

---

## Tabla 43 Flujos Alternativos - CU06

| Escenario                       | Condición                          | Acción del Sistema                                                    |
|---------------------------------|------------------------------------|-----------------------------------------------------------------------|
| FA1: Errores presentes          | Diagrama contiene errores          | Ofrece generar código parcial con comentarios indicando problemas     |
| FA2: Complejidad excepcional    | Diagrama muy complejo              | Puede requerir tiempo adicional, muestra indicador de progreso        |
| FA3: Estructuras no soportadas  | Elemento sin mapeo directo         | Genera comentario TODO para implementación manual                     |

---

## Tabla 44 CU07 - Exportar Proyecto Completo

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU07                                                                         |
| Nombre          | Exportar Proyecto Completo                                                   |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Exportar proyecto con diagrama (PNG/SVG), código C y metadatos               |
| Precondiciones  | Proyecto guardado con contenido válido · Permisos de escritura en ubicación de exportación |
| Postcondiciones | Paquete autocontenido creado · Todos los elementos exportados correctamente  |

---

## Tabla 45 Flujos alternativos - CU07

| Escenario                  | Condición                                  | Acción del Sistema                                          |
|----------------------------|--------------------------------------------|-------------------------------------------------------------|
| FA1: Espacio insuficiente  | Almacenamiento insuficiente                | Muestra mensaje de error en ubicación destino y sugiere otra ubicación |
| FA2: Permisos denegados    | Sin permisos de escritura en carpeta destino | Solicita permisos o ubicación alternativa                 |
| FA3: Archivo existente     | Nombre de archivo ya existe en destino     | Ofrece sobrescribir o cambiar nombre automático             |

---

## Tabla 46 CU08 - Organizar Proyectos en Carpetas

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU08                                                                         |
| Nombre          | Organizar Proyectos en Carpetas                                              |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Organizar los proyectos guardados mediante la creación y gestión de carpetas  |
| Precondiciones  | Al menos un proyecto guardado · Sistema de archivos permite directorios      |
| Postcondiciones | Proyectos organizados según estructura definida · Referencias mantenidas correctamente |

---

## Tabla 47 Flujos alternativos - CU08

| Escenario                  | Condición                                  | Acción del Sistema                                |
|----------------------------|--------------------------------------------|----------------------------------------------------|
| FA1: Estructura profunda   | Usuario intenta crear carpetas muy anidadas | Advierte sobre límite de niveles (máx. 5)         |
| FA2: Nombre conflictivo    | Nombre de carpeta ya existe                | Sugiere nombre alternativo con sufijo numérico     |
| FA3: Operación masiva      | Usuario mueve múltiples proyectos          | Solicita confirmación antes de proceder            |

---

## Tabla 48 CU09 - Registrar Cuenta de Usuario (Opcional)

| Elemento        | Descripción                                                                  |
|-----------------|------------------------------------------------------------------------------|
| ID              | CU09                                                                         |
| Nombre          | Registrar Cuenta de Usuario                                                  |
| Actor Principal | Usuario                                                                      |
| Objetivo        | Crear una cuenta para habilitar la funcionalidad de sincronización en la nube |
| Precondiciones  | App instalada en dispositivo Android · Conexión a internet activa · Usuario operando en modo invitado (sin cuenta registrada) |
| Postcondiciones | Cuenta creada exitosamente en Firebase · Usuario autenticado automáticamente · Acceso habilitado a funcionalidad de sincronización |

---

## Tabla 49 Flujos alternativos - CU09

| ID  | Condición                              | Acción del Sistema                                                                                                       |
|-----|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| FA1 | Formato de correo inválido             | Resalta campo con borde rojo · Muestra mensaje: "Ingresa un correo válido (ej: <usuario@ejemplo.com>)"                     |
| FA2 | Contraseña < 6 caracteres              | Resalta campo con borde rojo · Muestra mensaje: "La contraseña debe tener al menos 6 caracteres"                         |
| FA3 | Contraseñas no coinciden               | Resalta campo "Confirmar contraseña" con borde rojo · Muestra mensaje: "Las contraseñas no coinciden"                     |
| FA4 | Checkbox no marcado                    | Muestra diálogo: "Debes aceptar el Aviso de Privacidad para continuar" · Botones: "Leer Aviso", "Aceptar"                |
| FA5 | Correo ya registrado                   | Firebase retorna error "email-already-in-use" · Muestra: "Este correo ya está registrado. ¿Deseas iniciar sesión?" · Botones: "Iniciar sesión", "Intentar con otro correo" |
| FA6 | Sin conexión a internet                | Sistema detecta ausencia de red · Muestra: "Requiere conexión a internet para crear cuenta" · Botón: "Reintentar"        |
| FA7 | Error de Firebase (timeout, servidor)  | Muestra: "Error al crear cuenta. Intenta nuevamente en unos momentos" · Registra error en Crashlytics · Botón: "Reintentar" |
| FA8 | Usuario cancela                        | Sistema cierra pantalla de registro sin guardar datos · Retorna a pantalla anterior                                       |

---

## Tabla 50 CU10 - Sincronizar Proyectos a la Nube (Opcional)

| Elemento        | Descripción                                                                                                                                   |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| ID              | CU10                                                                                                                                          |
| Nombre          | Sincronizar Proyectos a la Nube                                                                                                               |
| Actor Principal | Usuario                                                                                                                                       |
| Objetivo        | Sincronizar los proyectos locales a Firebase Firestore para acceder a ellos desde otros dispositivos o como respaldo en la nube                |
| Precondiciones  | Usuario autenticado en Firebase · Conexión a internet activa · Al menos un proyecto guardado localmente                                        |
| Postcondiciones | Proyectos sincronizados en Firestore · Proyectos marcados como "Sincronizado ✓" · Timestamp de última sincronización actualizado              |

---

## Tabla 51 Flujos alternativos - CU10

| ID  | Condición                                              | Acción del Sistema                                                                                                              |
|-----|--------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| FA1 | Usuario no autenticado                                 | Muestra diálogo: "Debes crear una cuenta para sincronizar" · Botones: "Crear cuenta" (→CU09), "Cancelar"                        |
| FA2 | Sin proyectos locales                                  | Muestra mensaje: "No hay proyectos para sincronizar" · Ofrece crear nuevo proyecto                                               |
| FA3 | Sin conexión a internet                                | Sistema detecta ausencia de red · Muestra: "Sin conexión. Los proyectos se sincronizarán cuando haya internet" · Encola proyectos para sincronización automática posterior |
| FA4 | Cuota de Firestore excedida                            | Firebase retorna error "quota-exceeded" · Muestra: "Espacio de almacenamiento insuficiente. Elimina proyectos antiguos o actualiza plan" · Botón: "Ver proyectos en nube" |
| FA5 | Error de red durante sincronización                    | Sistema pausa sincronización · Muestra: "Error de conexión. X de Y proyectos sincronizados" · Botones: "Reintentar", "Cancelar" |
| FA6 | Conflicto de versión (proyecto modificado en otro dispositivo) | Muestra diálogo: "Este proyecto fue modificado en otro dispositivo" · Opciones: "Conservar versión local", "Descargar versión en nube", "Ver diferencias" |
| FA7 | Usuario cancela sincronización                         | Sistema detiene proceso · Proyectos ya sincronizados conservan estado                                                            |
| FA8 | Token JWT expirado                                     | Sistema refresca token automáticamente · Si falla: solicita reautenticación                                                      |

---

> **Nota:** Los casos de uso CU09 (Registrar Cuenta de Usuario) y CU10 (Sincronizar Proyectos a la Nube) representan funcionalidad **opcional** que complementa las capacidades principales de la aplicación. Estas funcionalidades no se encuentran contempladas dentro de los objetivos específicos definidos en el protocolo del trabajo terminal, sino que extienden la experiencia del usuario al ofrecer respaldo y acceso multidispositivo mediante servicios en la nube. La aplicación es completamente funcional sin estas características, operando de forma local.
