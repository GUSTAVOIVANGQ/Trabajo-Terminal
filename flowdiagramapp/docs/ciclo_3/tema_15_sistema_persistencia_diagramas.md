# 15. Sistema de Persistencia de Diagramas

El sistema de persistencia permitió conservar diagramas y plantillas entre sesiones, habilitar operación sin conexión y respaldar funcionalidades complementarias como exportación de resultados y sincronización por cuenta. La unidad de almacenamiento se definió como una **instantánea completa del diagrama** (nodos y conexiones), lo que aseguró consistencia al guardar y reconstruir el estado.

## 15.1 Persistencia local (SQLite)

Los diagramas se almacenaron en una base SQLite (`flowdiagram.db`) dentro del almacenamiento privado de la aplicación, garantizando disponibilidad aun sin conectividad. Para el acceso a la base se utilizó `sqflite` [14] y para la resolución de rutas `path_provider`.

### 15.1.1 Estructura general

Cada diagrama se representó como un registro en la tabla `diagrams` con metadatos y dos campos de datos serializados (nodos y conexiones). Este enfoque priorizó un guardado/recuperación coherente del estado sobre una normalización relacional de nodos y aristas.

**Figura 48. Esquema lógico de la tabla `diagrams` y sus campos (SQLite).**

| Campo | Tipo (SQLite) | Restricciones | Descripción |
| --- | --- | --- | --- |
| `id` | INTEGER | PK, AUTOINCREMENT | Identificador interno del diagrama. |
| `name` | TEXT | NOT NULL | Nombre del diagrama. |
| `description` | TEXT | — | Descripción opcional. |
| `created_at` | TEXT | NOT NULL | Fecha/hora de creación en formato ISO 8601. |
| `updated_at` | TEXT | NOT NULL | Fecha/hora de última actualización en formato ISO 8601. |
| `nodes_data` | TEXT | NOT NULL | JSON serializado con la lista de nodos. |
| `connections_data` | TEXT | NOT NULL | JSON serializado con la lista de conexiones. |
| `is_template` | INTEGER | NOT NULL, DEFAULT 0 | Bandera: `0` diagrama de usuario, `1` plantilla. |
| `user_id` | TEXT | — | Identificador de usuario (puede ser nulo en registros históricos). |

Notas:

- `created_at` y `updated_at` se almacenan como texto ISO 8601.
- `nodes_data` y `connections_data` almacenan JSON serializado.

### 15.1.2 Información persistida

- Identificación y metadatos: `id`, `name`, `description`.
- Trazabilidad temporal: `created_at`, `updated_at` (formato ISO 8601).
- Estructura del diagrama: `nodes_data`, `connections_data` (instantánea serializada en JSON).
- Clasificación: `is_template` (separación entre plantillas y diagramas de usuario).
- Propiedad: `user_id` (aislamiento por cuenta/sesión y compatibilidad con registros históricos con `user_id` nulo).

Como decisión de alcance, algunos atributos visuales avanzados de conexiones se reconstruyeron al cargar (valores por defecto), manteniendo como prioridad la topología y el contenido del diagrama.

**Figura 49. Ejemplo de JSON persistido para nodos y conexiones (plantilla “05. Par o Impar”).**

Plantilla del diagrama (captura): *(Insertar aquí la captura de la plantilla “05. Par o Impar” desde la aplicación.)*

**`nodes_data`**

```json
[
	{
		"id": "comment_1770000000000_0",
		"type": "comment",
		"x": 500.0,
		"y": 50.0,
		"text": "/* Determina si un número es par o impar.\nConcepto: if-else, operador módulo (%) */",
		"metadata": {}
	},
	{
		"id": "start_1770000000000_1",
		"type": "terminal",
		"x": 250.0,
		"y": 50.0,
		"text": "Inicio",
		"metadata": {}
	},
	{
		"id": "process_1770000000000_2",
		"type": "process",
		"x": 250.0,
		"y": 150.0,
		"text": "int numero",
		"metadata": {
			"processType": "declaration",
			"varType": "int",
			"varName": "numero"
		}
	},
	{
		"id": "input_1770000000000_3",
		"type": "data",
		"x": 250.0,
		"y": 250.0,
		"text": "Leer numero",
		"metadata": {
			"isOutput": false,
			"inputType": "int",
			"varName": "numero"
		}
	},
	{
		"id": "decision_1770000000000_4",
		"type": "decision",
		"x": 250.0,
		"y": 370.0,
		"text": "numero % 2 == 0",
		"metadata": {}
	},
	{
		"id": "output_1770000000000_5",
		"type": "data",
		"x": 420.0,
		"y": 500.0,
		"text": "Escribir \"El número es par\"",
		"metadata": {
			"isOutput": true,
			"outputType": "string"
		}
	},
	{
		"id": "output_1770000000000_6",
		"type": "data",
		"x": 80.0,
		"y": 500.0,
		"text": "Escribir \"El número es impar\"",
		"metadata": {
			"isOutput": true,
			"outputType": "string"
		}
	},
	{
		"id": "end_1770000000000_7",
		"type": "terminal",
		"x": 250.0,
		"y": 630.0,
		"text": "Fin",
		"metadata": {}
	}
]
```

**`connections_data`**

```json
[
	{
		"source_id": "start_1770000000000_1",
		"target_id": "process_1770000000000_2",
		"label": ""
	},
	{
		"source_id": "process_1770000000000_2",
		"target_id": "input_1770000000000_3",
		"label": ""
	},
	{
		"source_id": "input_1770000000000_3",
		"target_id": "decision_1770000000000_4",
		"label": ""
	},
	{
		"source_id": "decision_1770000000000_4",
		"target_id": "output_1770000000000_5",
		"label": "Sí"
	},
	{
		"source_id": "decision_1770000000000_4",
		"target_id": "output_1770000000000_6",
		"label": "No"
	},
	{
		"source_id": "output_1770000000000_5",
		"target_id": "end_1770000000000_7",
		"label": ""
	},
	{
		"source_id": "output_1770000000000_6",
		"target_id": "end_1770000000000_7",
		"label": ""
	}
]
```

Nota: el valor numérico usado en los `id` proviene de `DateTime.now().millisecondsSinceEpoch` (se muestra un valor de ejemplo), por lo que cambia entre ejecuciones.

## 15.2 Operaciones de guardado, carga y eliminación

Las operaciones se realizaron sobre instantáneas completas del diagrama:

- **Guardado explícito** por acción del usuario, actualizando `updated_at`.
- **Creación/actualización** según la presencia de `id` (nuevo registro o actualización del existente).
- **Carga** separando plantillas (`is_template=1`) y diagramas del usuario (`is_template=0` y filtro por `user_id`).
- **Eliminación** por `id` y limpieza por `user_id` (remoción de diagramas no-plantilla asociados a una cuenta).

Para reducir el riesgo de pérdida de cambios, el editor mantuvo un indicador de modificaciones pendientes y solicitó confirmación al cambiar de diagrama o salir.

## 15.3 Exportación de diagramas (imagen)

La aplicación soportó exportación del lienzo a imagen de alta resolución para compartir y documentar resultados. Se contemplaron dos formatos principales:

- **PNG** (con transparencia).
- **JPG** (composición sobre fondo sólido para preservar legibilidad, dado que el formato no incluye canal alfa).

La salida se guardó en ubicaciones compatibles con Android (galería/MediaStore) y se contemplaron rutas de respaldo cuando el guardado directo no estuvo disponible.

## 15.4 Sincronización en la nube (Firebase)

En sesiones autenticadas, los diagramas se sincronizaron por cuenta mediante Firestore (`cloud_firestore`) [22], manteniendo la persistencia local como base de operación.

### 15.4.1 Organización de datos

Cada usuario contó con una colección dedicada (`users/{userId}/diagrams`). Cada documento representó una instantánea del diagrama, junto con metadatos y marcas temporales de sincronización.

**Figura 51. Estructura de colecciones y documentos de diagramas por usuario (Firestore).**

| Nivel | Tipo | Nombre/ID | Ruta |
| ---: | --- | --- | --- |
| 1 | Colección | `users` | `users` |
| 2 | Documento | `{userId}` | `users/{userId}` |
| 3 | Subcolección | `diagrams` | `users/{userId}/diagrams` |
| 4 | Documento | `{diagramId}` | `users/{userId}/diagrams/{diagramId}` |

Campos del documento `users/{userId}/diagrams/{diagramId}`:

| Campo | Tipo (Firestore) | Notas |
| --- | --- | --- |
| `name` | string | Nombre del diagrama. |
| `description` | string | Descripción (puede omitirse si no aplica). |
| `created_at` | string | ISO 8601 (`toIso8601String`). |
| `updated_at` | string | ISO 8601 (`toIso8601String`). |
| `nodes_data` | string | JSON serializado (instantánea de nodos). |
| `connections_data` | string | JSON serializado (instantánea de conexiones). |
| `is_template` | bool | Bandera de plantilla/diagrama. |
| `user_id` | string | Identificador del propietario (cuenta). |
| `synced_at` | string | ISO 8601 (`toIso8601String`). |

Notas:

- `diagramId` se genera como: `local_<id_local_sqlite>`.
- Las fechas se guardan como texto (ISO 8601).

### 15.4.2 Manejo de conflictos

Para resolver discrepancias entre versiones locales y en nube, se aplicó una política determinista basada en la última modificación (`updated_at`): se conservó la versión más reciente y se reemplazó la otra. La sincronización operó a nivel de instantánea completa (sin fusión parcial por nodo o conexión).

### 15.4.3 Modos y restricciones

Se habilitaron modos bidireccionales y modos de sobrescritura (“subir todo” / “descargar todo”), con restricciones operativas:

- Requirió conectividad (verificada con `connectivity_plus`).
- No se sincronizaron sesiones invitadas.

## 15.5 Inicialización y continuidad de servicio

En el arranque se inicializó Firebase (`firebase_core`). Ante fallos de inicialización o ausencia de conectividad, la aplicación continuó operando en modo local, deshabilitando únicamente las funciones remotas para no bloquear el uso del editor.

Adicionalmente, se configuraron manejadores globales de errores del marco de trabajo y de la plataforma. Estos manejadores delegaron al subsistema de reporte únicamente cuando el consentimiento lo permitió.

## 15.6 Analítica de uso (opt-in)

El registro de eventos de interacción se implementó con `firebase_analytics` [22] y se controló por consentimiento explícito. Las preferencias se persistieron como claves de configuración por cuenta/sesión e incluyeron marcas temporales de actualización.

Para reducir riesgos de identificación, los eventos se enviaron sin asociar un identificador personal y los parámetros se normalizaron (longitudes y cantidades máximas).

**Figura 52. Matriz de consentimiento y servicios habilitados (opt-in).**

| Contexto de sesión | `telemetry_opt_in` (Analytics) | `crash_reports_opt_in` (Crash Report) | Firebase Analytics (colección) | Firebase Crashlytics (colección) |
|---|---:|---:|---|---|
| Invitado (`isGuest=true`) | N/A (no configurable) | N/A (no configurable) | Deshabilitada | Deshabilitada |
| Cuenta registrada | `false` | `false` | Deshabilitada | Deshabilitada |
| Cuenta registrada | `true` | `false` | Habilitada | Deshabilitada |
| Cuenta registrada | `false` | `true` | Deshabilitada | Habilitada |
| Cuenta registrada | `true` | `true` | Habilitada | Habilitada |

Notas de implementación:

- Al iniciar la aplicación, ambos servicios se inicializan deshabilitados y solo se activan tras consentimiento explícito.
- Analytics se mantiene anónimo (sin asociar correo/nombre) y utiliza propiedades como `telemetry_opt_in` y `auth_mode`.
- Al desactivar Crashlytics se eliminan reportes pendientes no enviados (`deleteUnsentReports`).
- Los cambios de consentimiento se almacenan como claves en `metrics` del usuario (p. ej., `telemetry_updated_at`, `crash_reports_updated_at`) y se aplican al servicio al actualizar el perfil.

## 15.7 Reporte automático de errores (opt-in)

El reporte remoto de fallos se implementó con `firebase_crashlytics` [22] y dependió de consentimiento explícito independiente. El sistema permitió activar o revocar la recolección y, al desactivarse, eliminó reportes pendientes para prevenir envíos posteriores.

Los reportes adjuntaron contexto técnico acotado (p. ej., modo de autenticación y estado de consentimientos) para facilitar el diagnóstico.

## 15.8 Pruebas de funcionamiento

La cobertura existente se enfocó en pruebas unitarias e integración de componentes de edición/configuración y en el flujo de generación/compilación. No se incluyeron pruebas automatizadas dedicadas a gestos del lienzo (arrastre, desplazamiento y escalado) mediante instrumentación de interfaz.
