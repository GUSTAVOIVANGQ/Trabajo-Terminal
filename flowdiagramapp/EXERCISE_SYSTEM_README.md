# Sistema de Ejercicios de Comprensión - FlowDiagram App

## 📋 Descripción General

El Sistema de Ejercicios de Comprensión es una funcionalidad educativa diseñada para evaluar la **comprensión** de los conceptos básicos de programación mediante símbolos de diagramas de flujo. Basado en el **Nivel 2 de la Taxonomía de Bloom**, los ejercicios se centran en que los usuarios puedan:

- ✓ **Identificar** símbolos y su función
- ✓ **Distinguir** entre diferentes operaciones
- ✓ **Comparar** soluciones algorítmicas
- ✓ **Explicar** el flujo de ejecución

## 🎯 Objetivos Educativos

### Nivel 2 de la Taxonomía de Bloom: Comprensión

El sistema evalúa si el usuario puede:

1. **Interpretar**: Convertir información de una forma de representación a otra
2. **Ejemplificar**: Encontrar ejemplos específicos de un concepto
3. **Clasificar**: Determinar que algo pertenece a una categoría
4. **Resumir**: Abstraer un tema general de información específica
5. **Inferir**: Llegar a una conclusión lógica basada en información
6. **Comparar**: Detectar correspondencias entre ideas, objetos y similares
7. **Explicar**: Construir un modelo de causa y efecto de un sistema

## 📚 Categorías de Ejercicios

### 1. Símbolos Básicos 🟦
**Color:** Azul  
**Ícono:** `Icons.category`  
**Descripción:** Aprende los símbolos fundamentales

**Ejercicios incluidos:**
- Identificar símbolo de inicio
- Distinguir proceso de decisión
- Relacionar símbolos con funciones
- Verdadero o falso sobre reglas básicas

**Habilidades evaluadas:**
- Identificar formas geométricas y su función
- Distinguir entre símbolos similares
- Relacionar símbolos con operaciones

### 2. Estructuras de Control 🟪
**Color:** Púrpura  
**Ícono:** `Icons.account_tree`  
**Descripción:** Decisiones y bucles

**Ejercicios incluidos:**
- Identificar símbolo de decisión
- Comparar decisión vs bucle
- Ordenar pasos de un algoritmo con bucle

**Habilidades evaluadas:**
- Comparar diferentes estructuras de control
- Ordenar secuencias lógicas
- Explicar el flujo de control

### 3. Flujo de Datos 🟧
**Color:** Naranja  
**Ícono:** `Icons.data_usage`  
**Descripción:** Entrada, salida y variables

**Ejercicios incluidos:**
- Identificar entrada vs salida
- Distinguir variable de proceso
- Verdadero o falso sobre entrada/salida

**Habilidades evaluadas:**
- Distinguir entre tipos de datos
- Identificar operaciones de E/S
- Clasificar declaraciones de variables

### 4. Conexiones 🟩
**Color:** Teal  
**Ícono:** `Icons.share`  
**Descripción:** Flujo lógico del diagrama

**Ejercicios incluidos:**
- Identificar dirección del flujo
- Entender salidas de decisión
- Validar conexiones correctas

**Habilidades evaluadas:**
- Explicar el flujo lógico
- Comparar conexiones válidas e inválidas
- Interpretar la dirección del flujo

### 5. Avanzado 🟣
**Color:** Púrpura oscuro  
**Ícono:** `Icons.auto_awesome`  
**Descripción:** Conectores y subprocesos

**Ejercicios incluidos:**
- Identificar símbolo de conector
- Identificar símbolo de comentario
- Identificar símbolo de subproceso

**Habilidades evaluadas:**
- Identificar símbolos especializados
- Explicar el propósito de conectores
- Distinguir entre proceso y subproceso

## 🎮 Tipos de Ejercicios

### 1. Selección Múltiple (Multiple Choice)
**Tipo:** `ExerciseType.multipleChoice`  
**Descripción:** Presenta una pregunta con 3-4 opciones donde el usuario debe seleccionar la respuesta correcta.

**Características:**
- Incluye descripciones adicionales para cada opción
- Puede mostrar vista previa visual de símbolos de diagramas
- Retroalimentación inmediata al seleccionar

**Ejemplo:**
```
¿Qué símbolo representa el INICIO de un algoritmo?
○ Óvalo (Forma ovalada para inicio y fin) ✓
○ Rectángulo (Rectángulo para procesos)
○ Rombo (Rombo para decisiones)
○ Paralelogramo (Paralelogramo para entrada)
```

### 2. Verdadero o Falso (True or False)
**Tipo:** `ExerciseType.trueOrFalse`  
**Descripción:** Presenta una afirmación que el usuario debe clasificar como verdadera o falsa.

**Características:**
- Interfaz con botones grandes e íconos descriptivos
- Verde para Verdadero (✓), Rojo para Falso (✗)
- Explicación de por qué la afirmación es verdadera o falsa

**Ejemplo:**
```
VERDADERO o FALSO: Un diagrama de flujo puede tener múltiples nodos de INICIO
□ Verdadero
☑ Falso (Correcto: Un diagrama debe tener UN SOLO nodo de inicio)
```

### 3. Relacionar (Matching)
**Tipo:** `ExerciseType.matching`  
**Descripción:** Conecta elementos de una columna con elementos de otra.

**Características:**
- Muestra símbolos visuales junto con descripciones
- Verifica que todas las relaciones sean correctas
- Permite selección múltiple

**Ejemplo:**
```
Relaciona cada símbolo con su función correcta:
☑ Óvalo → Inicio/Fin
☑ Rectángulo → Proceso
☑ Rombo → Decisión
☑ Paralelogramo → Entrada/Salida
```

### 4. Ordenamiento (Ordering)
**Tipo:** `ExerciseType.ordering`  
**Descripción:** Organiza pasos o elementos en el orden correcto.

**Características:**
- Interfaz de arrastrar y soltar (drag & drop)
- Números de paso visibles
- Verifica el orden exacto

**Ejemplo:**
```
Ordena los pasos para crear un algoritmo que sume números hasta 10:
1. Inicio
2. Inicializar contador = 0
3. Inicializar suma = 0
4. ¿contador < 10?
5. suma = suma + contador
6. Incrementar contador
...
```

### 5. Arrastrar y Soltar (Drag and Drop)
**Tipo:** `ExerciseType.dragAndDrop`  
**Descripción:** Arrastra elementos a zonas específicas.

**Características:**
- Zonas de destino claramente marcadas
- Retroalimentación visual al arrastrar
- Validación de ubicación correcta

## 💯 Sistema de Puntuación

### Puntos por Dificultad

| Dificultad | Puntos | Características |
|------------|--------|-----------------|
| **Fácil** 😊 | 10 pts | 3-4 opciones, conceptos básicos |
| **Medio** 😐 | 15-20 pts | 5-6 opciones, requiere distinción |
| **Difícil** 😓 | 20-25 pts | 6+ opciones, requiere comparación y análisis |

### Cálculo de Precisión

```dart
accuracy = (respuestas_correctas / total_respuestas) * 100
```

### Seguimiento de Progreso

Para cada categoría se rastrea:
- **Total de ejercicios:** Número total de ejercicios en la categoría
- **Ejercicios completados:** Número de ejercicios finalizados
- **Puntos totales:** Puntos máximos disponibles
- **Puntos obtenidos:** Puntos ganados por el usuario
- **Precisión promedio:** Promedio de precisión en todos los ejercicios
- **Tiempo total:** Suma de tiempo empleado en todos los ejercicios

## 🎨 Características de la Interfaz

### Pantalla Principal de Ejercicios

**Elementos visuales:**
1. **Header con estadísticas generales:**
   - Gradiente atractivo (primary → secondary)
   - Trofeo animado 🏆
   - 3 métricas principales: Completados, Total, Puntos

2. **Tarjetas de categorías:**
   - Color distintivo por categoría
   - Ícono representativo
   - Barra de progreso animada
   - Badge de puntos
   - Indicador de completitud ✅

3. **Animaciones:**
   - Fade in al cargar
   - Slide up desde abajo
   - Scale al aparecer cada tarjeta
   - Efecto ripple al tocar

### Pantalla de Preguntas

**Elementos visuales:**
1. **Barra de progreso:**
   - Progreso lineal animado
   - Contador de preguntas (1/5)
   - Nombre de categoría

2. **Badge de dificultad:**
   - Verde (Fácil) 😊
   - Naranja (Medio) 😐
   - Rojo (Difícil) 😓

3. **Tarjeta de pregunta:**
   - Ícono de ayuda
   - Texto de la pregunta en negrita
   - Fondo con elevación

4. **Tarjeta de explicación:**
   - Fondo azul claro
   - Ícono de bombilla 💡
   - Texto de ayuda contextual

5. **Opciones de respuesta:**
   - Vista previa visual de símbolos
   - Efecto hover al seleccionar
   - Borde destacado para selección
   - Icono de check ✓

6. **Botones de acción:**
   - Botón "Anterior" (si aplica)
   - Botón "Verificar" / "Finalizar"
   - Deshabilitado si no hay selección

### Diálogo de Resultados

**Elementos visuales:**
1. **Header animado:**
   - Fondo verde (correcto) o naranja (incorrecto)
   - Ícono grande animado con escala y rotación
   - Título motivacional
   - Badge de puntos ganados

2. **Confeti (respuestas correctas):**
   - Animación explosiva desde arriba
   - 5 colores diferentes
   - 30 partículas
   - Duración: 3 segundos

3. **Tarjeta de estadísticas:**
   - 3 métricas: Tiempo, Precisión, Puntos
   - Íconos y colores distintivos
   - Layout horizontal

4. **Retroalimentación:**
   - Color según resultado
   - Ícono de check o info
   - Mensaje personalizado del ejercicio

5. **Comparación de respuestas (si es incorrecta):**
   - Sección roja: Tu respuesta ✗
   - Sección verde: Respuesta correcta ✓
   - Lista de opciones

6. **Explicación adicional:**
   - Fondo azul claro
   - Ícono de escuela 🎓
   - Texto educativo

## 📊 Integración con Métricas

### Datos Almacenados

El sistema guarda los siguientes datos en `SharedPreferences`:

```dart
class ExerciseResult {
  String exerciseId;           // ID único del ejercicio
  List<String> userAnswers;    // Respuestas del usuario
  List<String> correctAnswers; // Respuestas correctas
  bool isCorrect;              // Si la respuesta fue correcta
  int pointsEarned;            // Puntos ganados
  DateTime completedAt;        // Fecha y hora de completitud
  int timeSpentSeconds;        // Tiempo empleado en segundos
}
```

### Métricas Calculadas

1. **Tasa de éxito:**
   ```dart
   tasa_exito = (ejercicios_correctos / ejercicios_completados) * 100
   ```

2. **Tiempo promedio:**
   ```dart
   tiempo_promedio = suma_tiempos / ejercicios_completados
   ```

3. **Precisión promedio:**
   ```dart
   precision_promedio = suma_precisiones / ejercicios_completados
   ```

### Visualización en Métricas

Los datos de ejercicios se pueden visualizar en la pantalla de métricas del usuario:

- **Gráfico de barras:** Comparación de precisión por categoría
- **Gráfico circular:** Distribución de ejercicios completados
- **Timeline:** Progreso histórico
- **Tabla:** Detalles por ejercicio individual

## 🛠️ Arquitectura Técnica

### Modelos de Datos

**Archivos principales:**
- `lib/models/exercise_model.dart`: Define Exercise, ExerciseOption, ExerciseResult, ExerciseProgress

### Servicios

**Archivos principales:**
- `lib/services/exercise_service.dart`: Gestiona ejercicios, resultados y progreso

**Métodos principales:**
```dart
// Obtener ejercicios
List<Exercise> getAllExercises()
List<Exercise> getExercisesByCategory(ExerciseCategory category)
Exercise? getExerciseById(String id)

// Gestionar resultados
Future<void> saveExerciseResult(ExerciseResult result)
Future<List<ExerciseResult>> getExerciseResults()
Future<bool> isExerciseCompleted(String exerciseId)

// Progreso
Future<ExerciseProgress> getCategoryProgress(ExerciseCategory category, String userId)
Future<void> resetProgress()
```

### Pantallas

**Archivos principales:**
- `lib/screens/exercises_screen.dart`: Pantalla principal con categorías
- `lib/screens/exercise_question_screen.dart`: Pantalla de preguntas interactivas

### Widgets

**Archivos principales:**
- `lib/widgets/exercise_result_dialog.dart`: Diálogo de resultados con animaciones

## 📝 Ejercicios Incluidos

### Total de Ejercicios: 15

| Categoría | Cantidad | IDs |
|-----------|----------|-----|
| Símbolos Básicos | 4 | basic_001 - basic_004 |
| Estructuras de Control | 3 | control_001 - control_003 |
| Flujo de Datos | 3 | data_001 - data_003 |
| Conexiones | 2 | conn_001 - conn_002 |
| Avanzado | 3 | adv_001 - adv_003 |

### Expandibilidad

Para agregar nuevos ejercicios, editar `exercise_service.dart`:

```dart
// Ejemplo de nuevo ejercicio
Exercise(
  id: 'basic_005',
  type: ExerciseType.multipleChoice,
  category: ExerciseCategory.basicSymbols,
  difficulty: ExerciseDifficulty.easy,
  question: '¿Tu pregunta aquí?',
  explanation: 'Explicación opcional',
  options: [
    ExerciseOption(id: 'opt_1', text: 'Opción 1'),
    ExerciseOption(id: 'opt_2', text: 'Opción 2'),
  ],
  correctAnswers: ['opt_1'],
  feedback: '¡Mensaje de retroalimentación!',
  points: 10,
  relatedNodeType: NodeType.start,
),
```

## 🚀 Cómo Usar

### Para el Usuario

1. **Acceder a los ejercicios:**
   - Desde la pantalla principal, tocar el botón flotante "Ejercicios"

2. **Seleccionar una categoría:**
   - Revisar el progreso actual
   - Tocar una tarjeta de categoría

3. **Completar ejercicios:**
   - Leer la pregunta y explicación
   - Seleccionar respuesta(s)
   - Tocar "Verificar"

4. **Ver resultados:**
   - Revisar puntos ganados
   - Leer retroalimentación
   - Estudiar la explicación
   - Tocar "Continuar"

5. **Seguir el progreso:**
   - Ver estadísticas en la pantalla principal
   - Completar todas las categorías

### Para el Desarrollador

**Agregar una nueva categoría:**

1. Agregar al enum en `exercise_model.dart`:
   ```dart
   enum ExerciseCategory {
     basicSymbols,
     controlFlow,
     dataFlow,
     connections,
     advanced,
     myNewCategory, // Nueva categoría
   }
   ```

2. Crear método en `exercise_service.dart`:
   ```dart
   List<Exercise> _getMyNewCategoryExercises() {
     return [/* ejercicios */];
   }
   ```

3. Agregar al método `getAllExercises()`:
   ```dart
   List<Exercise> getAllExercises() {
     return [
       ..._getBasicSymbolsExercises(),
       // ... otros
       ..._getMyNewCategoryExercises(),
     ];
   }
   ```

4. Agregar info de categoría en `exercises_screen.dart`:
   ```dart
   case ExerciseCategory.myNewCategory:
     return CategoryInfo(
       title: 'Mi Categoría',
       description: 'Descripción',
       icon: Icons.icon_name,
       color: Colors.blue,
     );
   ```

## 📈 Métricas Educativas Evaluadas

El sistema de ejercicios contribuye directamente a las métricas educativas del proyecto:

### 1. Tasa de Éxito en Ejercicios
**Meta:** ≥80% de usuarios completan ejercicios sin ayuda

**Medición:**
```dart
tasa_exito = (ejercicios_correctos_primer_intento / total_ejercicios) * 100
```

### 2. Tiempo Promedio de Resolución
**Meta:** ≤15 minutos por ejercicio

**Medición:**
```dart
tiempo_promedio = suma_tiempos_ejercicios / total_ejercicios_completados
```

### 3. Mejora en Pre/Post-Test
**Meta:** ≥20% de mejora

**Medición:**
- Realizar pre-test antes de los ejercicios
- Realizar post-test después de completar todas las categorías
- Calcular: `mejora = ((post_test - pre_test) / pre_test) * 100`

## 🎓 Referencias Pedagógicas

### Taxonomía de Bloom Revisada (2001)

**Nivel 2: Comprensión (Understanding)**

Los ejercicios están diseñados para verificar que el estudiante puede:
- Interpretar, ejemplificar, clasificar, resumir, inferir, comparar, explicar

**Diferencia con el Nivel 1 (Recordar):**
- Recordar: "¿Qué símbolo es esto?" (reconocimiento)
- Comprender: "¿Para qué se usa este símbolo?" (interpretación)

**Ejemplos en los ejercicios:**
- ✓ "Relaciona cada símbolo con su función" (Clasificar)
- ✓ "¿Cuál es la diferencia entre decisión y bucle?" (Comparar)
- ✓ "Ordena los pasos del algoritmo" (Explicar)

## 📱 Capturas de Pantalla

### Pantalla Principal
```
┌─────────────────────────────┐
│  🏆 Tu Progreso             │
│                             │
│  ✓ 8  Completados           │
│  📋 15 Total                │
│  ⭐ 120 Puntos              │
└─────────────────────────────┘

┌─────────────────────────────┐
│ 📦 Símbolos Básicos         │
│ Aprende los símbolos...     │
│ ▓▓▓▓▓▓▓▓▓░ 4/4  ⭐ 40 pts  │
│ ✅ ¡Categoría completada!   │
└─────────────────────────────┘

┌─────────────────────────────┐
│ 🌳 Estructuras de Control   │
│ Decisiones y bucles         │
│ ▓▓▓▓▓░░░░░ 2/3  ⭐ 35 pts  │
└─────────────────────────────┘
```

### Pantalla de Pregunta
```
┌─────────────────────────────┐
│ Símbolos Básicos       2/4  │
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░      │
└─────────────────────────────┘

┌─────────────────────────────┐
│ 😊 Fácil                    │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ❓ Pregunta                 │
│                             │
│ ¿Qué símbolo representa     │
│ el INICIO de un algoritmo?  │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ☑ [Óvalo] Óvalo             │
│   Forma ovalada para...     │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ☐ [Rect] Rectángulo         │
│   Rectángulo para procesos  │
└─────────────────────────────┘

┌─────────────────────────────┐
│ [Anterior]  [Verificar]     │
└─────────────────────────────┘
```

### Diálogo de Resultado
```
┌─────────────────────────────┐
│         ✅                  │
│                             │
│    ¡Excelente!              │
│                             │
│     ⭐ +10 puntos           │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ⏱ 15 seg  📊 100%  ⭐ 10   │
└─────────────────────────────┘

┌─────────────────────────────┐
│ ✅ ¡Correcto! El óvalo se   │
│ usa para INICIO y FIN del   │
│ algoritmo.                  │
└─────────────────────────────┘

┌─────────────────────────────┐
│         [Continuar]         │
└─────────────────────────────┘
```

## 🔮 Mejoras Futuras

### Fase 2
- [ ] Más ejercicios por categoría (20+ por categoría)
- [ ] Modo práctica sin puntuación
- [ ] Sistema de logros y badges
- [ ] Clasificación (leaderboard) entre usuarios
- [ ] Ejercicios adaptativos según desempeño

### Fase 3
- [ ] Ejercicios de código directo (escribir código C)
- [ ] Ejercicios de depuración de diagramas
- [ ] Desafíos cronometrados
- [ ] Modo multijugador
- [ ] Generación de certificados

---

**Desarrollado con ❤️ para FlowDiagram App**  
**Versión:** 1.0.0  
**Última actualización:** Noviembre 2025
