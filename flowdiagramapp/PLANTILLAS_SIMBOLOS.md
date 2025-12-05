# Plantillas de Símbolos de Diagrama de Flujo

## 📋 Descripción

Este documento describe todas las plantillas disponibles en FlowDiagram App. Cada plantilla está diseñada para demostrar el uso correcto de cada símbolo según el estándar **ANSI/ISO 5807** de diagramas de flujo.

---

## 📚 Lista Completa de Plantillas

### ✅ Plantillas Existentes (Actualizadas)

#### 1. **Suma de dos números** 🔢
**Símbolos demostrados:** Inicio, Fin, Entrada, Proceso, Salida

**Objetivo:** Enseñar la estructura básica de un diagrama de flujo simple.

**Flujo:**
```
Inicio
  ↓
Entrada: número 1
  ↓
Entrada: número 2
  ↓
Proceso: resultado = a + b
  ↓
Salida: Mostrar resultado
  ↓
Fin
```

**Conceptos:**
- Flujo secuencial básico
- Entrada de datos
- Operación aritmética
- Salida de resultados

---

#### 2. **Verificación par/impar** ⚖️
**Símbolos demostrados:** Inicio, Fin, Entrada, Decisión, Salida

**Objetivo:** Demostrar estructuras condicionales simples.

**Flujo:**
```
Inicio
  ↓
Entrada: número
  ↓
Decisión: ¿numero % 2 == 0?
  ├─ Sí → Salida: "Es par"
  └─ No → Salida: "Es impar"
  ↓
Fin
```

**Conceptos:**
- Estructuras de decisión (if-else)
- Operador módulo (%)
- Bifurcación de flujo
- Etiquetas en conexiones (Sí/No)

---

#### 3. **Contador con bucle while** 🔁
**Símbolos demostrados:** Inicio, Fin, Variable, Entrada, Bucle, Proceso, Salida

**Objetivo:** Enseñar estructuras de repetición con condición.

**Flujo:**
```
Inicio
  ↓
Variable: int contador = 0
  ↓
Entrada: límite
  ↓
Bucle: ¿contador < limite?
  ├─ Verdadero → Salida: Mostrar contador
  │                ↓
  │              Proceso: contador++
  │                ↓
  └────────────────┘ (retorno al bucle)
  ↓
  Falso → Salida: "Bucle terminado"
  ↓
Fin
```

**Conceptos:**
- Declaración e inicialización de variables
- Bucles while
- Incremento de contador
- Retorno de flujo (loop back)
- Condición de salida del bucle

---

### 🆕 Plantillas Nuevas (Agregadas)

#### 4. **Menú de opciones con conectores** 🔗
**Símbolos demostrados:** Inicio, Fin, Entrada, Decisión, Conector, Salida

**Objetivo:** Demostrar el uso de conectores para organizar flujos complejos y evitar cruces de líneas.

**Flujo:**
```
Inicio
  ↓
Entrada: opción (1-3)
  ↓
Decisión: ¿opcion == 1?
  ├─ Sí → Conector [A] ───┐
  └─ No → ↓               │
          Decisión: ¿opcion == 2?  │
            ├─ Sí → Conector [B] ──┼─┐
            └─ No → Salida: "Opción inválida"
                      ↓             │ │
                  Conector [FIN] ←──┼─┤
                      ↓             │ │
                     Fin            │ │
                                    │ │
  [A] → Salida: "Procesando opción 1" │
          ↓                           │
      Conector [FIN] ←────────────────┘
                                      │
  [B] → Salida: "Procesando opción 2" │
          ↓                           │
      Conector [FIN] ←────────────────┘
```

**Conceptos:**
- Uso de conectores de salida (→ A, → B)
- Uso de conectores de entrada (← A, ← B)
- Conectores bidireccionales (⇄ FIN)
- Organización de diagramas complejos
- Evitar cruces de líneas
- Múltiples decisiones anidadas
- Convergencia de flujos

**Tipos de conectores:**
- `→ A`: Conector de salida (origen)
- `← A`: Conector de entrada (destino)
- `⇄ FIN`: Conector bidireccional (convergencia)

---

#### 5. **Promedio con comentarios** 📝
**Símbolos demostrados:** Inicio, Fin, Variable, Entrada, Proceso, Comentario, Salida

**Objetivo:** Demostrar el uso de comentarios para documentar y explicar diagramas de flujo.

**Flujo:**
```
Inicio
  ↓  [Comentario: Este algoritmo calcula el promedio de 3 números]
Variable: float suma = 0
  ↓  [Comentario: Acumulador para la suma]
Entrada: número 1
  ↓
Proceso: suma = suma + numero1
  ↓
Entrada: número 2
  ↓
Proceso: suma = suma + numero2
  ↓
Entrada: número 3
  ↓
Proceso: suma = suma + numero3
  ↓
Proceso: promedio = suma / 3
  ↓  [Comentario: Dividimos entre 3 porque tenemos 3 números]
Salida: Mostrar promedio
  ↓
Fin
```

**Conceptos:**
- Comentarios para documentación
- Explicación de variables
- Aclaración de cálculos
- Mejores prácticas de documentación
- Patrón acumulador
- Promedio aritmético

**Usos de comentarios:**
- Explicar el propósito del algoritmo
- Documentar variables importantes
- Aclarar operaciones complejas
- Notas para mantenimiento
- Advertencias o consideraciones

---

#### 6. **Factorial con subprocesos** 🔧
**Símbolos demostrados:** Inicio, Fin, Entrada, Decisión, Subproceso, Salida

**Objetivo:** Demostrar el uso de subprocesos para modularizar operaciones complejas.

**Flujo:**
```
Inicio
  ↓
Entrada: número
  ↓
Decisión: ¿numero >= 0?
  ├─ No → Salida: "Error: número negativo"
  │         ↓
  │        Fin
  └─ Sí → Subproceso: ValidarEntrada(numero)
            ↓
          Subproceso: CalcularFactorial(numero)
            ↓
          Subproceso: FormatearResultado(resultado)
            ↓
          Salida: Mostrar resultado
            ↓
           Fin
```

**Conceptos:**
- Modularización de código
- Subprocesos como funciones
- Validación de entrada
- Separación de responsabilidades
- Reutilización de código
- Manejo de errores

**Subprocesos incluidos:**
1. **ValidarEntrada(numero)**: Verifica que el número sea válido
2. **CalcularFactorial(numero)**: Calcula el factorial recursiva o iterativamente
3. **FormatearResultado(resultado)**: Formatea el resultado para mostrar

**Ventajas de los subprocesos:**
- Simplifica diagramas complejos
- Permite reutilización
- Facilita mantenimiento
- Mejora la legibilidad
- Promueve buenas prácticas

---

## 🎯 Resumen de Símbolos por Plantilla

| Símbolo | Plantilla 1 | Plantilla 2 | Plantilla 3 | Plantilla 4 | Plantilla 5 | Plantilla 6 |
|---------|-------------|-------------|-------------|-------------|-------------|-------------|
| **Inicio** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Fin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Proceso** | ✅ | - | ✅ | - | ✅ | - |
| **Decisión** | - | ✅ | ✅ | ✅ | - | ✅ |
| **Entrada** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Salida** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Variable** | - | - | ✅ | - | ✅ | - |
| **Bucle** | - | - | ✅ | - | - | - |
| **Conector** | - | - | - | ✅ | - | - |
| **Comentario** | - | - | - | - | ✅ | - |
| **Subproceso** | - | - | - | - | - | ✅ |

---

## 📖 Guía de Uso

### Para Estudiantes

1. **Comienza con la plantilla 1** (Suma de dos números): Aprende el flujo básico
2. **Avanza a la plantilla 2** (Par/impar): Entiende las decisiones
3. **Practica con la plantilla 3** (Bucle while): Domina las repeticiones
4. **Explora la plantilla 4** (Conectores): Organiza diagramas complejos
5. **Usa la plantilla 5** (Comentarios): Aprende a documentar
6. **Domina la plantilla 6** (Subprocesos): Modulariza tu código

### Para Profesores

- Usa las plantillas como ejemplos en clase
- Modifica las plantillas para crear ejercicios
- Pide a los estudiantes que creen variaciones
- Combina conceptos de múltiples plantillas
- Evalúa la comprensión mediante modificaciones

### Para Desarrolladores

- Las plantillas se cargan automáticamente en la primera ejecución
- Están marcadas como `isTemplate: true` en la base de datos
- No se eliminan al borrar diagramas del usuario
- Se pueden usar como base para nuevos diagramas

---

## 🔧 Implementación Técnica

### Base de Datos

Las plantillas se almacenan en la tabla `diagrams` con el campo `is_template = 1`.

```sql
CREATE TABLE diagrams(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  nodes_json TEXT NOT NULL,
  connections_json TEXT NOT NULL,
  is_template INTEGER NOT NULL DEFAULT 0
);
```

### Carga de Plantillas

Las plantillas se cargan automáticamente en el método `_loadTemplates()` del `DatabaseService`:

```dart
Future<void> _loadTemplates(Database db) async {
  // Verificar si ya existen plantillas
  final List<Map<String, dynamic>> result = await db.query(
    'diagrams',
    where: 'is_template = ?',
    whereArgs: [1],
  );

  // Si ya hay plantillas, no cargar de nuevo
  if (result.isNotEmpty) return;

  // Cargar todas las plantillas...
}
```

### Métodos de Creación

Cada plantilla tiene su propio método privado:

- `_createSumTemplate()` - Plantilla 1
- `_createEvenOddTemplate()` - Plantilla 2
- `_createLoopTemplate()` - Plantilla 3
- `_createConnectorTemplate()` - Plantilla 4 (NUEVO)
- `_createCommentTemplate()` - Plantilla 5 (NUEVO)
- `_createSubprocessTemplate()` - Plantilla 6 (NUEVO)

---

## 📝 Notas de Desarrollo

### Versión: 1.1.0
**Fecha:** 25 de noviembre de 2025

**Cambios realizados:**
- ✅ Agregada plantilla 4: Menú de opciones con conectores
- ✅ Agregada plantilla 5: Promedio con comentarios
- ✅ Agregada plantilla 6: Factorial con subprocesos
- ✅ Ahora se cubre el 100% de los símbolos disponibles
- ✅ Documentación completa de todas las plantillas

**Próximas mejoras sugeridas:**
- [ ] Agregar plantillas para bucles for
- [ ] Agregar plantillas para bucles do-while
- [ ] Combinar múltiples símbolos en casos de uso reales
- [ ] Agregar plantillas de algoritmos clásicos (ordenamiento, búsqueda)
- [ ] Crear categorías de plantillas (básicas, intermedias, avanzadas)

---

## 🎓 Valor Educativo

Estas plantillas están diseñadas siguiendo principios pedagógicos:

1. **Progresión gradual**: De lo simple a lo complejo
2. **Ejemplos prácticos**: Casos de uso reales
3. **Cobertura completa**: Todos los símbolos del estándar
4. **Documentación clara**: Explicaciones detalladas
5. **Interactividad**: Los usuarios pueden modificar y experimentar

---

## 📚 Referencias

- **ANSI/ISO 5807**: Estándar de símbolos para diagramas de flujo
- **Taxonomía de Bloom**: Niveles de comprensión evaluados
- **Mejores prácticas**: Documentación y modularización

---

*Desarrollado con ❤️ para FlowDiagram App*
