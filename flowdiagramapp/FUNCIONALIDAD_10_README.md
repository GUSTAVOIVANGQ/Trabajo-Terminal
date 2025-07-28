# Funcionalidad 10: Exportación de Diagramas de Flujo

## Descripción
Esta funcionalidad permite a los usuarios exportar sus diagramas de flujo como imágenes PNG o JPG y guardarlas directamente en la carpeta de Descargas del dispositivo.

## Características Implementadas

### 🖼️ Formatos de Exportación
- **PNG**: Alta calidad, soporte para transparencia
- **JPG**: Menor tamaño de archivo, fondo blanco automático

### 📁 Almacenamiento
- Los archivos se guardan automáticamente en la carpeta de **Descargas**
- Nombres de archivo únicos con timestamp: `nombre_diagrama_20250630_143025.png`
- Manejo inteligente de permisos de almacenamiento

### 🎨 Calidad de Imagen
- **Resolución alta**: 3x pixel ratio para imágenes nítidas
- **Captura completa**: Todo el contenido visible del canvas
- **Colores precisos**: Respeta los temas claro/oscuro

## Cómo Usar

### Desde el Editor de Diagramas

1. **Crear o cargar un diagrama** con al menos un nodo
2. **Buscar el botón de exportación** (📥) en la barra de herramientas superior
3. **Seleccionar el formato**:
   - `Exportar como PNG` - Para máxima calidad
   - `Exportar como JPG` - Para menor tamaño de archivo
4. **Esperar la confirmación** - La app mostrará la ubicación del archivo guardado

### Ubicación de los Archivos

#### Android
- **Ruta principal**: `/storage/emulated/0/Download/`
- **Ruta alternativa**: En la carpeta de documentos de la app si no hay permisos

#### Otras Plataformas
- **Carpeta de Descargas del sistema** o carpeta de documentos de la app

## Implementación Técnica

### Archivos Modificados/Creados

1. **`lib/services/diagram_export_service.dart`** (NUEVO)
   - Servicio principal de exportación
   - Manejo de permisos de almacenamiento
   - Conversión entre formatos PNG/JPG

2. **`lib/widgets/flow_diagram_canvas_final.dart`** (MODIFICADO)
   - Agregado soporte para `RepaintBoundary`
   - Nuevo parámetro `canvasKey` para captura de imagen

3. **`lib/screens/editor_screen.dart`** (MODIFICADO)
   - Agregado botón de exportación en la barra de herramientas
   - Métodos `_exportDiagramAsPNG()` y `_exportDiagramAsJPG()`
   - Interfaz de usuario para selección de formato

### Dependencias Utilizadas

```yaml
# Estas dependencias ya estaban en el proyecto
permission_handler: ^11.3.0  # Manejo de permisos
image: ^4.1.7                # Procesamiento de imágenes
path_provider: ^2.1.1        # Acceso a directorios del sistema
```

### Flujo de Exportación

1. **Verificación**: Comprobar que hay nodos para exportar
2. **Permisos**: Solicitar permisos de almacenamiento si es necesario
3. **Captura**: Usar `RepaintBoundary` para capturar el canvas como imagen
4. **Conversión**: Convertir a PNG o JPG según la selección
5. **Guardado**: Escribir el archivo en la carpeta de Descargas
6. **Confirmación**: Mostrar diálogo con la ruta del archivo guardado

## Características Especiales

### 🔒 Manejo de Permisos
- **Android 11+**: Uso de APIs modernas sin permisos especiales
- **Android <11**: Solicita permisos de almacenamiento tradicionales
- **Fallback**: Si no hay permisos, guarda en la carpeta de la app

### 🎨 Optimización de Imágenes
- **PNG**: Mantiene transparencia para fondos personalizados
- **JPG**: Agrega fondo blanco automáticamente (JPG no soporta transparencia)
- **Alta resolución**: 3x pixel ratio para pantallas de alta densidad

### 📱 Experiencia de Usuario
- **Feedback visual**: Diálogos de progreso durante la exportación
- **Validación**: Verifica que hay contenido antes de exportar
- **Mensajes claros**: Información detallada sobre errores y éxitos

## Ejemplos de Uso

### Exportar Diagrama Simple
```dart
// El usuario hace tap en el botón de exportación PNG
await DiagramExportService.exportDiagramToPNG(
  canvasKey: _canvasKey,
  diagramName: 'mi_algoritmo',
);
// Resultado: mi_algoritmo_20250630_143025.png en Descargas
```

### Verificar Ubicación de Exportación
```dart
final String location = await DiagramExportService.getExportLocation();
print('Los archivos se guardan en: $location');
```

## Resolución de Problemas

### ❌ "No hay nodos para exportar"
- **Solución**: Agregar al menos un nodo al diagrama antes de exportar

### ❌ "Permisos de almacenamiento denegados"
- **Solución**: 
  1. Ir a Configuración → Aplicaciones → FlowDiagram App → Permisos
  2. Activar "Almacenamiento" o "Archivos y multimedia"

### ❌ "Error al exportar"
- **Causas posibles**:
  - Espacio insuficiente en el dispositivo
  - Problema con el canvas (pantalla muy pequeña)
  - Error temporal del sistema
- **Solución**: Reintentar después de verificar el espacio disponible

## Futuras Mejoras

- 🔄 **Exportación en lote**: Exportar múltiples diagramas a la vez
- 📐 **Tamaño personalizable**: Permitir al usuario seleccionar dimensiones
- 🎨 **Opciones de formato**: Agregar soporte para PDF vectorial
- ☁️ **Exportación a la nube**: Integración con servicios de almacenamiento en línea

---

> ✅ **Estado**: Completamente implementado y funcional  
> 🧪 **Testeo**: Verificado en Android  
> 📱 **Compatibilidad**: Android 5.0+ (API 21+)
