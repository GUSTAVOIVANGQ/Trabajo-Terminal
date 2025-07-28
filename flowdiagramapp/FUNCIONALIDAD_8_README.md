# Funcionalidad 8: Sistema de Temas (Modo Claro y Oscuro)

## 📋 Descripción General

La Funcionalidad 8 implementa un sistema completo de temas para la aplicación FlowDiagram App, ofreciendo tres opciones de tema: **Modo Claro**, **Modo Oscuro** y **Seguir Sistema**. El sistema adapta automáticamente todos los elementos visuales de la aplicación, incluyendo colores de nodos de diagramas, gráficos de métricas y elementos de interfaz.

## ✨ Características Implementadas

### 🎨 Temas Disponibles

1. **Modo Claro**
   - Interfaz clara y brillante
   - Colores vibrantes para nodos de diagramas
   - Fondo blanco con texto oscuro
   - Óptimo para ambientes bien iluminados

2. **Modo Oscuro**
   - Interfaz oscura y elegante
   - Colores ajustados para mejor contraste
   - Fondo oscuro con texto claro
   - Ideal para ambientes con poca luz

3. **Seguir Sistema**
   - Cambia automáticamente según la configuración del dispositivo
   - Se adapta a los cambios del sistema operativo
   - Proporciona consistencia con otras aplicaciones

### 🔧 Componentes del Sistema

#### `ThemeService`
**Ubicación**: `lib/services/theme_service.dart`
- Gestiona el estado del tema actual
- Persiste la configuración usando SharedPreferences
- Notifica cambios a la aplicación mediante ChangeNotifier
- Proporciona métodos para alternar entre temas

#### `AppThemes`
**Ubicación**: `lib/themes/app_themes.dart`
- Define los esquemas de colores para modo claro y oscuro
- Especifica colores personalizados para nodos de diagramas
- Proporciona paletas de colores para gráficos y métricas
- Utiliza Material Design 3 para consistencia visual

#### Widgets de Configuración

##### `ThemeSelectorWidget`
**Ubicación**: `lib/widgets/theme_selector_widget.dart`
- Widget principal para selección de temas
- Interfaz intuitiva con opciones visuales
- Retroalimentación inmediata de cambios

##### `ThemeToggleButton`
- Botón compacto para alternar temas rápidamente
- Disponible en AppBars y menús
- Animación suave entre estados

##### `ThemeStatusTile`
- Tile para mostrar el tema actual en listas
- Navegación a configuración completa

### 📱 Pantallas Implementadas

#### `ThemeSettingsScreen`
**Ubicación**: `lib/screens/theme_settings_screen.dart`

**Características**:
- Información detallada sobre los temas
- Selector interactivo de temas
- Vista previa del tema actual
- Consejos y recomendaciones
- Muestra de colores y elementos UI

**Navegación**:
- Desde el perfil del usuario
- Desde configuraciones de la aplicación

## 🎯 Integración con Componentes Existentes

### Canvas de Diagramas
- Los nodos utilizan colores específicos según el tema
- Fondo del canvas se adapta al tema actual
- Bordes y conexiones usan colores del tema

### Gráficos de Métricas
- Paleta de colores dinámica según el tema
- Fondos y textos adaptados automáticamente
- Tooltips y elementos interactivos temáticos

### Pantallas Principales
- AppBars con colores del tema
- Botón de alternado rápido en pantalla principal
- Configuración completa en perfil de usuario

## 🔧 Implementación Técnica

### Inicialización
```dart
// En main.dart
await ThemeService().initialize();

MaterialApp(
  theme: AppThemes.lightTheme,
  darkTheme: AppThemes.darkTheme,
  themeMode: ThemeService().themeMode,
  // ...
)
```

### Uso de Colores Dinámicos
```dart
// Para nodos de diagramas
final nodeColors = AppThemes.getNodeColors(isDarkMode);

// Para gráficos
final chartColors = AppThemes.getChartColors(isDarkMode);
```

### Persistencia
- La configuración se guarda automáticamente en SharedPreferences
- Se restaura al iniciar la aplicación
- Cambios se aplican inmediatamente

## 📋 Estructura de Archivos

```
lib/
├── services/
│   └── theme_service.dart          # Servicio de gestión de temas
├── themes/
│   └── app_themes.dart             # Definiciones de temas
├── widgets/
│   └── theme_selector_widget.dart  # Widgets de selección de tema
├── screens/
│   ├── theme_settings_screen.dart  # Pantalla de configuración
│   ├── profile_screen.dart         # Integración en perfil
│   └── load_diagram_screen.dart    # Botón de alternado
└── main.dart                       # Aplicación del sistema
```

## 🎨 Paleta de Colores

### Modo Claro
- **Primario**: `#2563EB` (Azul)
- **Secundario**: `#059669` (Verde)
- **Superficie**: `#FFFFFF` (Blanco)
- **Fondo**: `#F9FAFB` (Gris muy claro)

### Modo Oscuro
- **Primario**: `#3B82F6` (Azul claro)
- **Secundario**: `#10B981` (Verde claro)
- **Superficie**: `#1E293B` (Gris oscuro)
- **Fondo**: `#0F172A` (Azul muy oscuro)

### Colores de Nodos
Cada tipo de nodo tiene colores específicos que se adaptan al tema:
- **Inicio**: Verde (claro/oscuro según tema)
- **Fin**: Rojo (claro/oscuro según tema)
- **Proceso**: Azul (claro/oscuro según tema)
- **Decisión**: Amarillo (claro/oscuro según tema)
- **Entrada**: Púrpura (claro/oscuro según tema)
- **Salida**: Verde oscuro (claro/oscuro según tema)
- **Variable**: Cian (claro/oscuro según tema)

## 🚀 Funcionalidades Clave

### Cambio Automático
- El modo "Seguir Sistema" detecta cambios en el tema del dispositivo
- Aplicación se actualiza automáticamente
- Sin necesidad de reinicio

### Persistencia de Configuración
- Preferencia del usuario se guarda localmente
- Se mantiene entre sesiones de la aplicación
- Configuración independiente del usuario

### Feedback Visual
- Cambios se aplican inmediatamente
- Animaciones suaves entre temas
- Retroalimentación clara de la selección actual

### Accesibilidad
- Contrastes apropiados para legibilidad
- Cumple con estándares de accesibilidad
- Colores diferenciables para usuarios con discapacidades visuales

## 📊 Integración con Métricas
- Los gráficos utilizan paletas específicas para cada tema
- Mejor legibilidad en ambas configuraciones
- Colores consistentes con el diseño general

## 🔄 Flujo de Usuario

1. **Configuración Inicial**: La aplicación detecta el tema del sistema por defecto
2. **Cambio Manual**: Usuario puede cambiar desde el perfil o botón rápido
3. **Persistencia**: La configuración se guarda automáticamente
4. **Aplicación**: Toda la interfaz se actualiza inmediatamente
5. **Sincronización**: Opción de seguir sistema mantiene sincronización

## 🎯 Beneficios

- **Experiencia Personalizada**: Adaptación a preferencias del usuario
- **Mejor Usabilidad**: Temas apropiados para diferentes condiciones de luz
- **Consistencia Visual**: Diseño coherente en toda la aplicación
- **Accesibilidad Mejorada**: Mejor contraste y legibilidad
- **Modernidad**: Cumple con expectativas actuales de UX/UI

## 📝 Notas de Desarrollo

- Utiliza Material Design 3 para consistencia
- Implementa ChangeNotifier para reactividad
- Usa SharedPreferences para persistencia
- Compatible con temas del sistema operativo
- Extensible para futuros temas personalizados

---

## 🔧 Configuración y Uso

### Para Desarrolladores

1. **Inicializar el servicio en main.dart**:
```dart
await ThemeService().initialize();
```

2. **Aplicar temas en MaterialApp**:
```dart
MaterialApp(
  theme: AppThemes.lightTheme,
  darkTheme: AppThemes.darkTheme,
  themeMode: ThemeService().themeMode,
)
```

3. **Usar colores dinámicos**:
```dart
final isDark = ThemeService().isDarkMode(context);
final nodeColors = AppThemes.getNodeColors(isDark);
```

### Para Usuarios

1. **Acceso desde perfil**: Ir a Perfil → Configuración → Tema
2. **Cambio rápido**: Usar botón en pantalla principal
3. **Configuración avanzada**: Pantalla dedicada de configuración de temas

La Funcionalidad 8 proporciona una experiencia visual completa y personalizable que mejora significativamente la usabilidad de la aplicación FlowDiagram App.
