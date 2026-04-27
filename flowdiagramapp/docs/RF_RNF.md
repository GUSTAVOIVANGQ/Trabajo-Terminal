# Requisitos Funcionales (RF) y No Funcionales (RNF)

Este documento detalla los requisitos funcionales y no funcionales para el proyecto FlowCode.

## 4.2 Requisitos Funcionales

### 4.2.1 Requisitos del Editor Visual (RF-Editor)

| ID | Descripción breve | Criterios de aceptación |
| :--- | :--- | :--- |
| **RF01** | Creación de diagramas mediante interfaz táctil. | - Toque simple = seleccionar elementos.<br>- Toque prolongado = abrir menús contextuales.<br>- Arrastre = mover componentes. |
| **RF02** | Biblioteca de símbolos básicos (inicio/fin, proceso, decisión, entrada/salida). | - Símbolos disponibles en la barra lateral.<br>- Etiquetas claras.<br>- Iconos consistentes. |
| **RF03** | Sistema de conexiones entre elementos. | - Conexiones arrastrando desde puntos de anclaje.<br>- Validación de reglas lógicas.<br>- Ajuste automático de líneas al mover elementos.<br>- Retroalimentación visual de conexiones válidas. |
| **RF04** | Navegación y zoom en el diagrama. | - Zoom táctil por pellizco.<br>- Desplazamiento con dos dedos.<br>- Botones de zoom predefinidos. |
| **RF05** | Edición de propiedades de elementos. | - Campos contextuales según el tipo de elemento.<br>- Interfaz adaptada a condiciones, variables y operaciones. |

**Tabla 30** Requisitos del Editor Visual (RF-Editor)

### 4.2.2 Requisitos del Analizador y Validador (RF-Validador)

| ID | Descripción | Criterios de aceptación |
| :--- | :--- | :--- |
| **RF-V01** | Validar estructura básica del diagrama | - Existe exactamente un nodo Inicio y al menos un nodo Fin.<br>- Existe al menos un camino completo desde inicio hasta fin. |
| **RF-V02** | Verificar declaración y uso de variables | - Detecta variables no declaradas y declaraciones duplicadas.<br>- Emite advertencia para variables no utilizadas. |
| **RF-V03** | Validar compatibilidad de tipos | - Emite advertencia ante tipos incompatibles y división/módulo por cero.<br>- No bloquea la generación ante advertencias. |
| **RF-V04** | Detectar código inalcanzable | - Identifica nodos no alcanzables desde el nodo Inicio (BFS).<br>- Resalta visualmente los elementos inalcanzables. |
| **RF-V05** | Verificar caminos de ejecución completos | - Todo camino de ejecución termina en un nodo Fin.<br>- Detecta ramas de decisión sin salida definida. |
| **RF-V06** | Generar representación intermedia | - Produce estructura interna (AST/grafo) que refleja fielmente el diagrama validado. |
| **RF-V07** | Mostrar errores con retroalimentación visual | - Errores clasificados por severidad.<br>- Elementos con error resaltados en el editor con mensaje descriptivo. |

**Tabla 31** Tabla de Requisitos del Validador (RF-Validador)

### 4.2.3 Requisitos del Generador de Código (RF-Generador)

| ID | Descripción breve | Criterios de aceptación |
| :--- | :--- | :--- |
| **RF06** | Generación de código C válido. | - Incluir automáticamente `#include <stdio.h>`<br>- Generar la función `main()` correctamente<br>- Código que compile en GCC sin errores |
| **RF07** | Manejo de variables básicas. | - Declaración automática de variables enteras y decimales según uso en el diagrama<br>- Inicialización simple si es necesario |
| **RF08** | Conversión de estructuras de control. | - Bloques de decisión<br>- Bucle<br>- Secuencia de operaciones |
| **RF09** | Soporte de entrada/salida estándar. | - Generar impresión para mostrar resultados<br>- Generar lector para leer valores del usuario |
| **RF10** | Visualización del código generado. | - Ventana/panel en la aplicación para mostrar el código<br>- Código actualizado cada vez que se edite el diagrama |

**Tabla 32** Requisitos del Generador de Código (RF-Generador)

### 4.2.4 Requisitos de Gestión de Proyectos (RF-Gestión)

| ID | Descripción breve | Criterios de aceptación |
| :--- | :--- | :--- |
| **RF11** | Guardado y carga de diagramas. | - Guardado local en dispositivo<br>- Archivos en formato JSON y SQLite |
| **RF12** | Exportación del código generado. | - Guardar en archivo `.c` |
| **RF13** | Correspondencia visual entre diagrama y código. | - Al seleccionar un bloque, resaltar el código relacionado |
| **RF14** | Plantillas básicas e información de uso de la aplicación. | - Incluir pantallas de información acerca del uso de la aplicación<br>- Al menos 3 plantillas: secuencia, decisión, bucle simple |
| **RF15** | Crear cuenta opcional con correo/contraseña | - Validación de formato RFC 5322<br>- Contraseña mayor a 6 caracteres<br>- Aceptación de Aviso de Privacidad |
| **RF16** | Operar en modo invitado sin registro | - Funcionalidad completa offline<br>- No solicitar datos personales |
| **RF17** | Sincronizar proyectos a Firebase | - Subida de proyectos JSON comprimidos<br>- Marcar proyectos como "Sincronizado ✓"<br>- Manejo de conflictos de versión (el más reciente sobrescribe) |
| **RF18** | Eliminar cuenta y datos asociados | - Borrado completo en 30 días<br>- Confirmación de usuario requerida |

**Tabla 33** Requisitos de Gestión de Proyectos (RF-Gestión)

---

## 4.3 Requisitos No Funcionales

Esta tabla resume los requisitos no funcionales identificados para el proyecto FlowCode, agrupados por categoría.

| Categoría | ID | Requisito (Descripción Breve) | Resumen del Criterio / Meta Principal |
| :--- | :--- | :--- | :--- |
| **Usabilidad** | **RNF01** | Consistencia Visual y Funcional | Mantener consistencia en patrones, colores, tipografía e iconos estándar en toda la aplicación. |
| **Usabilidad** | **RNF02** | Accesibilidad | Cumplir con pautas de accesibilidad de Android (lectores de pantalla, contraste, tamaño de texto). |
| **Rendimiento** | **RNF03** | Tiempo de Respuesta de la Interfaz | Interacciones básicas menor a 200 milisegundos. Operaciones complejas menor a 2 segundos (sin bloquear la UI). |
| **Rendimiento** | **RNF04** | Eficiencia de Memoria | Operar eficientemente en dispositivos con 2GB de RAM. |
| **Rendimiento** | **RNF05** | Optimización de Batería | Minimizar el impacto en la batería, evitando procesamiento innecesario en segundo plano. |
| **Confiabilidad** | **RNF06** | Autoguardado y Recuperación | Autoguardado automático cada 2 minutos durante la edición. |
| **Confiabilidad** | **RNF07** | Integridad de Datos | Implementar copias de seguridad automáticas de todos los proyectos. |
| **Confiabilidad** | **RNF08** | Tasa de Error en Generación de Código | Tasa de error menor a 1% para diagramas que pasen todas las validaciones estructurales. |
| **Compatibilidad** | **RNF09** | Compatibilidad de Plataforma | Compatible con Android 7.0 (API 24) o superior. Soportar múltiples tamaños de pantalla. |
| **Compatibilidad** | **RNF10** | Compatibilidad de Hardware | Especificaciones mínimas: 2GB RAM, 4 núcleos a 1.4GHz, 16GB almacenamiento. |
