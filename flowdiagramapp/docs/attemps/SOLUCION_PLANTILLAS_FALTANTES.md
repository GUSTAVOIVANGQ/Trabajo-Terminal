# Solución: Plantillas Faltantes en la Aplicación

## 🐛 Problema Identificado

**Síntoma**: Al abrir la aplicación y navegar a "Plantillas", solo aparecen 3 plantillas en lugar de las 6 esperadas.

**Causa raíz**: Las plantillas 4, 5 y 6 se agregaron al código, pero no se cargaron automáticamente en la base de datos SQLite existente. SQLite solo ejecuta el método `onCreate` cuando la base de datos es creada por primera vez, por lo que las bases de datos existentes no recibieron las nuevas plantillas.

---

## ✅ Solución Implementada

Se modificó el servicio `DatabaseService` para implementar una **verificación automática de plantillas** cada vez que se abre la base de datos.

### Cambios Realizados

#### 1. Nuevo método `_ensureTemplatesExist()`

Este método:
- Se ejecuta cada vez que se abre la base de datos (callback `onOpen`)
- Verifica qué plantillas ya existen
- Carga automáticamente solo las plantillas que faltan
- No duplica plantillas existentes

```dart
Future<void> _ensureTemplatesExist(Database db) async {
  // Lista de plantillas esperadas
  final expectedTemplates = [
    'Suma de dos números',
    'Verificación par/impar',
    'Contador con bucle while',
    'Menú de opciones con conectores',      // NUEVA
    'Promedio con comentarios',             // NUEVA
    'Factorial con subprocesos',            // NUEVA
  ];

  // Verificar qué plantillas ya existen
  final existingTemplates = await db.query(
    'diagrams',
    where: 'is_template = ?',
    whereArgs: [1],
    columns: ['name'],
  );

  // Cargar solo las plantillas faltantes
  // ...
}
```

#### 2. Modificación de `_initDatabase()`

Se agregó el callback `onOpen` para ejecutar la verificación:

```dart
Future<Database> _initDatabase() async {
  // ...
  final db = await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
    onOpen: (db) async {
      // Verificar y cargar plantillas cada vez que se abre la BD
      await _ensureTemplatesExist(db);
    },
  );
  return db;
}
```

---

## 🚀 Cómo Probar la Solución

### Opción 1: Reiniciar la Aplicación (Recomendado)

1. **Detener la aplicación** completamente (si está corriendo)
   ```powershell
   # En la terminal de VS Code
   Ctrl + C
   ```

2. **Ejecutar la aplicación nuevamente**
   ```powershell
   flutter run
   ```

3. **Verificar las plantillas**:
   - Abrir la aplicación
   - Ir a "Cargar Diagrama"
   - Seleccionar la pestaña "Plantillas"
   - **Deberías ver las 6 plantillas**:
     1. ✅ Suma de dos números
     2. ✅ Verificación par/impar
     3. ✅ Contador con bucle while
     4. ✅ Menú de opciones con conectores (NUEVA)
     5. ✅ Promedio con comentarios (NUEVA)
     6. ✅ Factorial con subprocesos (NUEVA)

### Opción 2: Hot Restart (Más Rápido)

Si la aplicación ya está corriendo:

1. **Hacer Hot Restart** en la terminal:
   ```
   Presiona R (mayúscula) en la terminal de Flutter
   ```
   O usar el botón de "Restart" en VS Code

2. **Verificar las plantillas** (mismo proceso que la Opción 1)

### Opción 3: Eliminar Base de Datos (Si las opciones anteriores no funcionan)

Esta opción elimina y recrea la base de datos desde cero:

⚠️ **ADVERTENCIA**: Esto eliminará todos tus diagramas guardados localmente. Solo usa esta opción si estás dispuesto a perder tus diagramas o si no tienes diagramas importantes.

1. **Detener la aplicación**

2. **Limpiar los datos de la aplicación**:
   ```powershell
   flutter clean
   ```

3. **Desinstalar la aplicación del dispositivo/emulador**:
   - Android: Desinstalar manualmente desde el dispositivo/emulador
   - O usar comando:
   ```powershell
   adb uninstall com.example.flowdiagramapp
   ```

4. **Instalar y ejecutar nuevamente**:
   ```powershell
   flutter run
   ```

5. **Verificar las plantillas** - Ahora deberías ver todas las 6 plantillas

---

## 🔍 Verificación de la Solución

### En la Consola de Debug

Cuando la aplicación se inicie, deberías ver en la consola mensajes como:

```
Cargando plantilla faltante: Menú de opciones con conectores
Cargando plantilla faltante: Promedio con comentarios
Cargando plantilla faltante: Factorial con subprocesos
```

Esto indica que el sistema detectó y cargó las plantillas faltantes.

### En la Interfaz de Usuario

En la pantalla "Cargar Diagrama" → pestaña "Plantillas":

| # | Nombre | Descripción | Estado |
|---|--------|-------------|--------|
| 1 | Suma de dos números | Plantilla para sumar dos números | ✅ Existente |
| 2 | Verificación par/impar | Verificar si un número es par o impar | ✅ Existente |
| 3 | Contador con bucle while | Uso de un bucle while | ✅ Existente |
| 4 | Menú de opciones con conectores | Organizar flujos complejos | ✨ **NUEVA** |
| 5 | Promedio con comentarios | Documentar diagramas | ✨ **NUEVA** |
| 6 | Factorial con subprocesos | Modularizar operaciones | ✨ **NUEVA** |

---

## 📊 Ventajas de Esta Solución

### ✅ Ventajas

1. **Sin pérdida de datos**: Los diagramas existentes no se eliminan
2. **Automática**: No requiere intervención manual del usuario
3. **Idempotente**: Puede ejecutarse múltiples veces sin efectos secundarios
4. **Escalable**: Fácil agregar más plantillas en el futuro
5. **Retrocompatible**: Funciona con bases de datos antiguas y nuevas

### 🎯 Comportamiento

- **Primera ejecución (BD nueva)**: Carga las 6 plantillas
- **Actualización (BD existente)**: Detecta y carga solo las 3 faltantes
- **Ejecuciones posteriores**: No hace nada (todas las plantillas ya existen)

---

## 🛠️ Archivo Modificado

**Archivo**: `lib/services/database_service.dart`

**Líneas agregadas**: ~90 líneas

**Cambios**:
1. ✅ Agregado método `_ensureTemplatesExist()`
2. ✅ Modificado `_initDatabase()` para incluir callback `onOpen`
3. ✅ Sin cambios en la estructura de la base de datos
4. ✅ Sin errores de compilación

---

## 📝 Notas Técnicas

### ¿Por qué no usar `onUpgrade`?

`onUpgrade` requiere incrementar el número de versión de la base de datos, lo cual:
- Complica migraciones futuras
- Puede causar problemas si los usuarios tienen diferentes versiones
- No es necesario para este caso (no cambia la estructura, solo los datos)

### ¿Por qué `onOpen` es mejor?

- Se ejecuta cada vez que se abre la BD
- Verifica y corrige automáticamente
- No requiere cambio de versión
- Más robusto para este caso de uso

---

## 🐛 Solución de Problemas

### Problema: "Aún no veo las 6 plantillas"

**Solución**:
1. Asegúrate de haber hecho Hot Restart (R en la terminal)
2. Si no funciona, detén y vuelve a ejecutar la aplicación
3. Como último recurso, desinstala la app y vuélvela a instalar

### Problema: "Error al cargar plantillas"

**Solución**:
1. Verifica que no haya errores de compilación
2. Revisa la consola para mensajes de error
3. Asegúrate de que el archivo `database_service.dart` se guardó correctamente

### Problema: "Plantillas duplicadas"

**Solución**:
- Esto no debería ocurrir gracias a la verificación de nombres
- Si ocurre, elimina la base de datos y vuelve a crearla (Opción 3)

---

## ✅ Checklist de Verificación

Antes de reportar que no funciona, verifica:

- [ ] Guardaste todos los archivos modificados
- [ ] Ejecutaste Hot Restart o reiniciaste la aplicación
- [ ] No hay errores de compilación en la consola
- [ ] Estás viendo la pestaña "Plantillas" (no "Mis Diagramas")
- [ ] La aplicación se conectó correctamente al emulador/dispositivo

---

## 📚 Referencias

- Código modificado: `lib/services/database_service.dart`
- Documentación de plantillas: `PLANTILLAS_SIMBOLOS.md`
- Guía de uso: `GUIA_RAPIDA_PLANTILLAS.md`

---

## 🎉 Resultado Esperado

Después de aplicar esta solución, deberías ver:

```
┌─────────────────────────────────────────┐
│         PLANTILLAS DISPONIBLES          │
├─────────────────────────────────────────┤
│ 1. Suma de dos números                  │
│ 2. Verificación par/impar               │
│ 3. Contador con bucle while             │
│ 4. Menú de opciones con conectores ✨   │
│ 5. Promedio con comentarios ✨          │
│ 6. Factorial con subprocesos ✨         │
└─────────────────────────────────────────┘
```

---

**¡Ahora todas las plantillas estarán disponibles!** 🚀

Si sigues teniendo problemas, por favor verifica los mensajes en la consola de debug o revisa el archivo `database_service.dart` para asegurarte de que todos los cambios se guardaron correctamente.
