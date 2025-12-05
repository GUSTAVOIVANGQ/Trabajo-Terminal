# Sistema de Tutoriales Integrado - FlowDiagram App

## 📋 Resumen

Se ha implementado un sistema completo de tutoriales interactivos para la aplicación FlowDiagram App, diseñado específicamente para el **nivel de Comprensión** de la Taxonomía de Bloom. El sistema incluye:

1. ✅ Tutoriales interactivos con animaciones
2. ✅ Pantalla de bienvenida para usuarios nuevos
3. ✅ Tutoriales específicos para cada tipo de nodo
4. ✅ Integración en pantalla de login y pantalla principal
5. ✅ Seguimiento de progreso con SharedPreferences

---

## 🎯 Objetivos Educativos (Taxonomía de Bloom - Nivel 2: Comprensión)

El sistema de tutoriales está diseñado para que los usuarios puedan:

### Identificar
- Reconocer diferentes símbolos de diagramas de flujo
- Identificar el propósito de cada tipo de nodo
- Reconocer estructuras de control en diagramas

### Distinguir
- Diferenciar entre tipos de operaciones (entrada, proceso, salida)
- Distinguir operadores de asignación (=) de comparación (==)
- Diferenciar tipos de bucles (for, while, do-while)

### Comparar
- Comparar diferentes soluciones algorítmicas
- Comparar operadores lógicos (AND, OR, NOT)
- Analizar ventajas de diferentes enfoques

### Explicar
- Explicar el flujo de ejecución de un diagrama
- Describir el propósito de cada símbolo
- Interpretar la relación entre diagrama y código

---

## 📁 Archivos Creados

### 1. Modelos
- **`lib/models/tutorial_step.dart`**
  - Modelo `TutorialStep`: Representa un paso individual del tutorial
  - Modelo `TutorialPage`: Página completa con múltiples pasos
  - Enum `TutorialCategory`: Categorías de tutoriales (bienvenida, básicos, nodos, etc.)

### 2. Servicios
- **`lib/services/tutorial_service.dart`**
  - Gestión de estado y progreso del tutorial
  - Verificación de primera vez del usuario
  - Almacenamiento de tutoriales completados
  - Contenido completo de 16 tutoriales:
    1. Tutorial de bienvenida
    2. Conceptos básicos
    3-13. Tutoriales específicos por nodo
    14. Conexiones
    15. Validación
    16. Generación de código

### 3. Pantallas
- **`lib/screens/welcome_screen.dart`**
  - Pantalla de bienvenida animada para usuarios nuevos
  - 4 páginas de introducción con animaciones
  - Presentación de características principales

- **`lib/screens/tutorial_list_screen.dart`**
  - Lista organizada de todos los tutoriales disponibles
  - Agrupación por categorías
  - Indicadores de progreso y completitud
  - Estadísticas de tutoriales completados

### 4. Widgets
- **`lib/widgets/tutorial_widget.dart`**
  - Widget principal del tutorial con animaciones suaves
  - Sistema de navegación entre pasos
  - Vista previa de código
  - Puntos clave destacados
  - Indicadores de progreso
  - Iconos animados para cada tipo de nodo

---

## 🎨 Características Visuales

### Animaciones
- **Fade in/out**: Transiciones suaves entre pasos
- **Slide**: Deslizamiento de contenido al cambiar de paso
- **Elastic**: Animación de rebote para iconos de nodos
- **Scale**: Crecimiento suave de elementos destacados

### Diseño
- **Material Design 3**: Interfaz moderna y consistente
- **Gradientes**: Colores degradados en encabezados
- **Tarjetas elevadas**: Separación visual clara
- **Indicadores de progreso**: Puntos interactivos que muestran el avance
- **Iconos coloridos**: Cada tipo de nodo tiene su color característico

### Responsive
- Adaptación a diferentes tamaños de pantalla
- Scroll automático para contenido largo
- Diálogos y pantallas completas según el contexto

---

## 📚 Contenido de los Tutoriales

### Tutorial de Bienvenida (3 min)
- ¿Qué es un diagrama de flujo?
- ¿Qué puedes hacer en la app?
- Taxonomía de Bloom - Nivel Comprensión
- ¿Listo para empezar?

### Conceptos Básicos (5 min)
- Flujo de ejecución
- Tipos de operaciones
- Conexiones entre nodos

### Tutoriales de Nodos (2-5 min cada uno)

#### Nodo de Inicio (2 min)
- Identificación del símbolo (óvalo verde)
- Reglas del nodo de inicio
- Posición en el diagrama

#### Nodo de Fin (2 min)
- Identificación del símbolo (óvalo rojo)
- Reglas del nodo de fin
- Múltiples puntos de salida

#### Nodo de Proceso (4 min)
- Identificación del símbolo (rectángulo azul)
- Tipos de operaciones (asignación, cálculo, incremento)
- Distinción entre asignación y comparación

#### Nodo de Decisión (5 min)
- Identificación del símbolo (rombo naranja)
- Tipos de condiciones (comparación, igualdad, rango, lógicas)
- Comparación de operadores lógicos

#### Nodo de Entrada (3 min)
- Identificación del símbolo (paralelogramo verde →)
- Tipos de entrada
- Distinción entre entrada y salida

#### Nodo de Salida (3 min)
- Identificación del símbolo (paralelogramo azul ←)
- Tipos de salida
- Mostrar mensajes y variables

#### Nodo de Variable (4 min)
- Identificación del símbolo (hexágono morado)
- Tipos de declaración
- Comparación de tipos de datos

#### Nodo de Bucle/Preparación (5 min)
- Identificación del símbolo (hexágono amarillo)
- Tipos de bucles (for, while, do-while)
- Distinción entre tipos de bucle

#### Nodo Conector (3 min)
- Identificación del símbolo (círculo índigo)
- Tipos de conectores (entrada, salida, bidireccional)
- Reglas de emparejamiento

#### Nodo de Comentario (2 min)
- Identificación del símbolo (rectángulo con esquina doblada)
- Tipos de comentarios
- Documentación del diagrama

#### Nodo de Subproceso (3 min)
- Identificación del símbolo (rectángulo con líneas dobles)
- Tipos de funciones
- Parámetros y retornos

### Tutorial de Conexiones (4 min)
- Crear conexiones entre nodos
- Etiquetas en conexiones
- Reglas de conexión

### Tutorial de Validación (4 min)
- ¿Qué es la validación?
- Errores comunes
- Identificar y corregir errores

### Tutorial de Generación de Código (4 min)
- ¿Cómo se genera el código?
- Del diagrama al código
- Comparación diagrama vs código

---

## 🔧 Integración en la App

### Pantalla de Login
```dart
// Botón de tutoriales en login_screen.dart
OutlinedButton.icon(
  onPressed: () {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const TutorialListScreen())
    );
  },
  icon: const Icon(Icons.school),
  label: const Text('Ver Tutoriales'),
)
```

### Pantalla Principal (LoadDiagramScreen)
```dart
// Verificación de primera vez
Future<void> _checkFirstTime() async {
  final isFirstTime = await _tutorialService.isFirstTime();
  if (isFirstTime && mounted && !_hasShownWelcome) {
    // Mostrar WelcomeScreen
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => WelcomeScreen(...))
    );
  }
}

// Botón de tutoriales en AppBar
IconButton(
  icon: const Icon(Icons.school),
  onPressed: () {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const TutorialListScreen())
    );
  },
  tooltip: 'Tutoriales',
)
```

---

## 💾 Persistencia de Datos

El sistema usa **SharedPreferences** para guardar:

### Claves de almacenamiento
- `tutorial_first_time`: Boolean que indica si es la primera vez del usuario
- `tutorial_completed_[id]`: Boolean por cada tutorial completado

### Métodos principales
```dart
// Verificar primera vez
Future<bool> isFirstTime()

// Marcar primera vez como completa
Future<void> markFirstTimeComplete()

// Verificar si un tutorial está completado
Future<bool> isTutorialCompleted(String tutorialId)

// Marcar tutorial como completado
Future<void> markTutorialComplete(String tutorialId)

// Reiniciar progreso (útil para testing)
Future<void> resetTutorialProgress()
```

---

## 🎯 Flujo de Usuario

### Usuario Nuevo
1. **Login/Registro** → Ve botón "Ver Tutoriales"
2. **Primera vez en LoadDiagramScreen** → Se muestra automáticamente WelcomeScreen
3. **WelcomeScreen** → 4 páginas de introducción con animaciones
4. **Finalizar bienvenida** → Marca como completado y cierra
5. **Acceso permanente** → Botón de tutoriales en AppBar

### Usuario Recurrente
1. **LoadDiagramScreen** → No se muestra WelcomeScreen (ya lo vio)
2. **Botón de tutoriales** → Acceso a TutorialListScreen en cualquier momento
3. **Progreso guardado** → Tutoriales completados marcados con ✓

---

## 📊 Métricas Educativas Cubiertas

### ✅ Usabilidad educativa
- Tutoriales con tiempo estimado (< 5 min cada uno)
- Lenguaje simple y directo
- Ejemplos visuales y prácticos

### ✅ Tiempo de comprensión
- Total: ~60 minutos para todos los tutoriales
- Tutoriales divididos en módulos pequeños
- Usuario puede aprender a su propio ritmo

### ✅ Tasa de uso de recursos de ayuda
- Métricas de tutoriales completados
- Seguimiento de progreso visible
- Indicadores visuales de completitud

### ✅ Autoevaluación de confianza
- Puntos clave destacados en cada tutorial
- Ejemplos prácticos
- Vista previa de código generado

---

## 🚀 Cómo Usar el Sistema de Tutoriales

### Para Desarrolladores

1. **Agregar nuevo tutorial**:
```dart
// En tutorial_service.dart
TutorialPage _getNuevoTutorial() {
  return TutorialPage(
    id: 'nuevo_tutorial',
    title: 'Título del Tutorial',
    subtitle: 'Subtítulo descriptivo',
    category: TutorialCategory.nodes,
    estimatedMinutes: 3,
    steps: [
      TutorialStep(
        title: 'Paso 1',
        description: 'Descripción del paso',
        keyPoints: ['Punto 1', 'Punto 2'],
        example: 'Código de ejemplo',
      ),
    ],
  );
}

// Agregar a getAllTutorials()
List<TutorialPage> getAllTutorials() {
  return [
    // ... tutoriales existentes
    _getNuevoTutorial(),
  ];
}
```

2. **Mostrar tutorial específico**:
```dart
final tutorial = tutorialService.getAllTutorials()
    .firstWhere((t) => t.id == 'node_process');

showDialog(
  context: context,
  builder: (context) => TutorialWidget(
    tutorial: tutorial,
    onComplete: () {
      // Acción al completar
    },
  ),
);
```

### Para Usuarios

1. **Primera vez**:
   - Al iniciar sesión, verás el botón "Ver Tutoriales"
   - Al entrar a la pantalla principal, se mostrará una bienvenida animada
   - Sigue los 4 pasos de bienvenida

2. **Acceso a tutoriales**:
   - Toca el ícono 📚 (school) en la barra superior
   - Explora las categorías de tutoriales
   - Toca cualquier tutorial para comenzar

3. **Completar tutoriales**:
   - Navega con los botones "Anterior" y "Siguiente"
   - Los tutoriales completados se marcan con ✓
   - Tu progreso se guarda automáticamente

---

## 🎨 Personalización

### Colores de Categorías
```dart
// En TutorialListScreen._buildCategorySection
_buildCategorySection('Título', TutorialCategory.nodes, Icons.icon, Colors.purple)
```

### Animaciones
```dart
// En TutorialWidget
_fadeController = AnimationController(
  duration: const Duration(milliseconds: 500), // Ajustar velocidad
  vsync: this,
);
```

### Tiempo Estimado
```dart
// En TutorialPage
TutorialPage(
  // ...
  estimatedMinutes: 5, // Ajustar tiempo
)
```

---

## 🔍 Testing

### Reiniciar progreso de tutoriales
```dart
final tutorialService = TutorialService();
await tutorialService.resetTutorialProgress();
```

### Verificar estado
```dart
final isFirstTime = await tutorialService.isFirstTime();
final isCompleted = await tutorialService.isTutorialCompleted('welcome');
print('Primera vez: $isFirstTime, Completado: $isCompleted');
```

---

## 📝 Notas Importantes

1. **Taxonomía de Bloom**: Todos los tutoriales están diseñados para el nivel de COMPRENSIÓN, no memorización ni aplicación avanzada.

2. **Lenguaje inclusivo**: Los tutoriales usan lenguaje simple, ejemplos prácticos y evitan terminología técnica innecesaria.

3. **Progresión gradual**: Los tutoriales van de lo simple a lo complejo, comenzando con conceptos básicos.

4. **Independencia**: Cada tutorial puede verse de forma independiente, no es necesario completarlos en orden.

5. **Persistencia local**: El progreso se guarda localmente con SharedPreferences, no requiere conexión a internet.

---

## 🎯 Próximos Pasos Sugeridos

1. **Métricas avanzadas**: Agregar seguimiento de tiempo por tutorial
2. **Búsqueda**: Implementar búsqueda de tutoriales por palabra clave
3. **Favoritos**: Permitir marcar tutoriales como favoritos
4. **Quiz**: Agregar preguntas de comprensión al final de cada tutorial
5. **Certificados**: Generar certificados al completar todos los tutoriales
6. **Videos**: Integrar videos cortos de demostración

---

## ✅ Checklist de Implementación

- [x] Modelo de datos para tutoriales
- [x] Servicio de gestión de tutoriales
- [x] Widget de tutorial con animaciones
- [x] Pantalla de bienvenida
- [x] Pantalla de lista de tutoriales
- [x] Integración en login screen
- [x] Integración en load diagram screen
- [x] Persistencia con SharedPreferences
- [x] Contenido completo de 16 tutoriales
- [x] Documentación completa

---

## 📧 Soporte

Para cualquier duda o sugerencia sobre el sistema de tutoriales, consulta este documento o revisa el código fuente en:
- `lib/services/tutorial_service.dart`
- `lib/widgets/tutorial_widget.dart`
- `lib/screens/tutorial_list_screen.dart`
- `lib/screens/welcome_screen.dart`

---

*Sistema de tutoriales implementado para FlowDiagram App*  
*Versión 1.0 - Noviembre 2024*
