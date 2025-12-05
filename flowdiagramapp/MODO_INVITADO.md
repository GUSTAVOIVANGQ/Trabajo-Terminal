# Modo Invitado - FlowDiagram App

## 📋 Descripción

El **Modo Invitado** permite a los usuarios acceder a todas las funcionalidades de FlowDiagram App sin necesidad de crear una cuenta o iniciar sesión. Este modo es ideal para:

- 🚀 Probar rápidamente la aplicación
- 📱 Uso completamente offline sin conexión a internet
- 🔒 Privacidad total (sin compartir datos personales)
- 🎓 Uso en entornos educativos donde no se requiere autenticación

## ✨ Características

### Acceso Completo

Como invitado, tienes acceso a:

- ✅ Editor visual de diagramas de flujo
- ✅ Todos los tipos de nodos (inicio, fin, proceso, decisión, etc.)
- ✅ Validación de diagramas
- ✅ Generación de código C
- ✅ Guardar y cargar diagramas (localmente)
- ✅ Sistema de plantillas
- ✅ Exportación de diagramas (PNG/JPG)
- ✅ Ejercicios de comprensión
- ✅ Tutoriales integrados
- ✅ Métricas personales locales
- ✅ Modo oscuro/claro

### Limitaciones

Como invitado, **NO** tienes acceso a:

- ❌ Sincronización en la nube
- ❌ Acceso desde múltiples dispositivos
- ❌ Métricas globales o comparativas
- ❌ Compartir diagramas con otros usuarios
- ❌ Respaldo automático en Firebase

## 🚀 Cómo Usar el Modo Invitado

### 1. Acceder como Invitado

1. Abre la aplicación FlowDiagram App
2. En la pantalla de inicio de sesión, busca el botón **"Continuar como Invitado"**
3. Haz clic en el botón
4. ¡Listo! Ya puedes usar la aplicación

### 2. Almacenamiento de Datos

- Todos tus diagramas se guardan **localmente** en tu dispositivo
- Los datos se almacenan en una base de datos SQLite local
- Tus ejercicios y métricas también se guardan en el dispositivo
- **Importante**: Si desinstalas la app, perderás todos los datos

### 3. Migrar a una Cuenta Registrada

Si decides crear una cuenta más adelante:

1. Ve al perfil o configuración
2. Selecciona "Crear cuenta"
3. Completa el registro con email y contraseña
4. **Nota**: Los datos del modo invitado NO se migrarán automáticamente

## 🔧 Implementación Técnica

### Cambios Realizados

#### 1. UserModel (`user_model.dart`)

- Agregado campo `isGuest` para identificar usuarios invitados
- Nuevo rol `UserRole.guest` en el enum
- Constructor factory `UserModel.guest()` para crear usuarios invitados
- UID único generado con timestamp: `guest_${timestamp}`

```dart
factory UserModel.guest() {
  final now = DateTime.now();
  return UserModel(
    uid: 'guest_${now.millisecondsSinceEpoch}',
    email: 'invitado@local.app',
    displayName: 'Invitado',
    role: UserRole.guest,
    createdAt: now,
    lastLogin: now,
    metrics: {},
    isGuest: true,
  );
}
```

#### 2. AuthService (`auth_service.dart`)

- **Autenticación automática deshabilitada**: El método `initialize()` ya no carga automáticamente la sesión
- Nuevo método `signInAsGuest()`: Crea un usuario invitado y lo guarda en caché local
- Getter `isGuestUser`: Verifica si el usuario actual es invitado

```dart
Future<UserModel> signInAsGuest() async {
  _currentUser = UserModel.guest();
  await _saveUserToCache(_currentUser!);
  return _currentUser!;
}

bool get isGuestUser => _currentUser?.isGuest ?? false;
```

#### 3. AuthGuard (`auth_guard.dart`)

- **Verificación automática comentada**: Ya no verifica automáticamente si hay una sesión activa
- Ahora siempre muestra la pantalla de login/invitado
- El usuario debe elegir manualmente entre iniciar sesión o continuar como invitado

#### 4. LoginScreen (`login_screen.dart`)

- Agregado botón **"Continuar como Invitado"** con ícono de persona
- Nuevo método `_continueAsGuest()`: Maneja el flujo de inicio de sesión como invitado
- Mensaje de bienvenida personalizado: "Bienvenido como invitado 👋"
- Texto informativo: "Como invitado podrás usar todas las funciones sin conexión"

## 🎨 Interfaz de Usuario

### Botón de Invitado

- **Estilo**: OutlinedButton con borde destacado
- **Ícono**: `Icons.person_outline`
- **Color**: Color primario del tema
- **Posición**: Justo debajo del botón de inicio de sesión

### Mensaje de Bienvenida

Cuando el usuario accede como invitado, se muestra:

```
✅ Bienvenido como invitado 👋
```

## 📊 Flujo de Autenticación

```
┌─────────────────────┐
│   App Iniciada      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Pantalla de Login  │
└──────┬──────────────┘
       │
       ├──────────────────────┐
       │                      │
       ▼                      ▼
┌─────────────┐    ┌────────────────────┐
│ Iniciar     │    │ Continuar como     │
│ Sesión      │    │ Invitado           │
└──────┬──────┘    └─────────┬──────────┘
       │                     │
       ▼                     ▼
┌─────────────────────────────────┐
│  LoadDiagramScreen              │
│  (Pantalla Principal)           │
└─────────────────────────────────┘
```

## 🔐 Seguridad y Privacidad

### Datos Locales

- Los datos del invitado se almacenan solo en el dispositivo
- No se envía ninguna información a Firebase
- El UID del invitado es único por sesión pero no se sincroniza

### Persistencia

- Los datos persisten entre sesiones de la app
- Se guardan en SharedPreferences y SQLite
- Se eliminan al cerrar sesión manualmente o desinstalar la app

## 🧪 Pruebas y Validación

### Escenarios de Prueba

1. ✅ Acceder como invitado sin conexión a internet
2. ✅ Crear, guardar y cargar diagramas como invitado
3. ✅ Completar ejercicios y ver métricas personales
4. ✅ Cambiar entre modo claro y oscuro
5. ✅ Exportar diagramas a PNG/JPG
6. ✅ Cerrar sesión y volver a acceder como invitado

### Casos Edge

- ⚠️ Intentar sincronizar con la nube (debe fallar o mostrar mensaje)
- ⚠️ Ver métricas globales (debe mostrar solo métricas locales)
- ⚠️ Compartir diagramas (debe indicar que requiere cuenta)

## 🔄 Migración y Actualización

### De Invitado a Usuario Registrado

Para implementar la migración de datos en el futuro:

1. Detectar si el usuario actual es invitado
2. Ofrecer opción de "Crear cuenta y guardar datos"
3. Al registrarse, migrar datos locales a Firebase
4. Actualizar el UID y metadata

### Sincronización Futura

Posibles mejoras:

- Exportar datos del invitado a JSON
- Importar datos al crear cuenta
- Opción de "Guardar trabajo antes de salir"

## 📝 Notas Adicionales

### Para Desarrolladores

- El campo `isGuest` está presente en todos los UserModel
- Verificar `authService.isGuestUser` antes de operaciones que requieran cuenta
- Los diagramas del invitado tienen el mismo formato que los de usuarios registrados
- La base de datos SQLite local es compartida entre todos los modos

### Para Usuarios Finales

- El modo invitado es completamente funcional y seguro
- Ideal para probar la app antes de crear una cuenta
- Perfecto para uso offline en cualquier momento
- Puedes crear una cuenta en cualquier momento sin perder el trabajo actual (guardando manualmente)

## 🎯 Próximas Mejoras

- [ ] Exportar datos del invitado a archivo
- [ ] Importar datos al crear cuenta
- [ ] Banner informativo sobre limitaciones del modo invitado
- [ ] Sugerencia periódica para crear cuenta
- [ ] Migración automática de datos al registrarse

---

**Fecha de implementación**: 24 de noviembre de 2025  
**Versión**: 1.0.0
