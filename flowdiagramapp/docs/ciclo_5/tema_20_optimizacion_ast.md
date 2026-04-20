# Tema 20: Optimización del AST

La optimización del AST se ejecuta después del análisis semántico y antes de la generación de código. Esta fase aplica transformaciones equivalentes sobre la representación intermedia para reducir redundancias y simplificar expresiones, preservando el comportamiento observable del programa.

---

## 20.1 Fundamentos de la optimización

El objetivo de la optimización es mejorar el AST mediante transformaciones locales seguras. Como ejemplo, una expresión `2 + 3` puede evaluarse directamente como `5` antes de la emisión del programa, y una expresión `x + 0` puede reducirse a `x`.

El optimizador mantiene un enfoque conservador: cuando una transformación no puede justificarse con reglas explícitas, se omite.

---

## 20.2 Niveles de optimización

Se definen cuatro niveles progresivos. Cada nivel habilita un conjunto de técnicas y fija el número máximo de pasadas (`maxPasses`).

| Nivel | Plegado de constantes | Eliminación de código muerto | Simplificación de expresiones | Optimización de flujo de control | Pasadas |
|---|:---:|:---:|:---:|:---:|:---:|
| none | No | No | No | No | 0 |
| basic | Sí | Sí | No | No | 1 |
| standard | Sí | Sí | Sí | No | 2 |
| aggressive | Sí | Sí | Sí | Sí | 3 |

En los niveles con múltiples pasadas, el proceso se detiene al alcanzar `maxPasses` o cuando una pasada completa no produce cambios (punto fijo).

---

## 20.3 Técnicas implementadas

### 20.3.1 Plegado de constantes

El plegado de constantes evalúa expresiones cuando sus operandos son literales conocidos. Se contemplan:

- operaciones entre enteros (incluyendo aritmética, comparación y operadores bit a bit),
- operaciones entre reales (flotantes y combinaciones entero-real),
- operaciones lógicas entre booleanos,
- concatenación de cadenas cuando ambos operandos son literales y el operador es `+`,
- evaluación de expresiones unarias sobre literales (`-`, `~`, `!`),
- selección de rama en el operador ternario cuando la condición es booleana constante.

En división y módulo se evita el plegado cuando el divisor es cero.

### 20.3.2 Eliminación de código muerto

La eliminación de código muerto elimina sentencias inalcanzables, incluyendo:

- `if` con condición booleana constante (se conserva solo la rama ejecutable),
- bucles `while` y `for` con condición de continuación falsa,
- sentencias posteriores a `return`, `break` o `continue` dentro de un mismo bloque.

En el caso de `for` eliminado, el inicializador se conserva como sentencia si existe.

### 20.3.3 Simplificación de expresiones

La simplificación aplica identidades algebraicas y lógicas, por ejemplo:

- $x+0=x$, $x-0=x$, $0+x=x$,
- $x*1=x$, $x*0=0$,
- $x/1=x$,
- $x-x=0$ cuando ambos operandos son el mismo identificador,
- doble negación aritmética y lógica.

### 20.3.4 Optimización de flujo de control

En el nivel agresivo se aplican simplificaciones sobre estructuras de control, por ejemplo la eliminación de ramas `else` vacías.

---

## 20.4 Métricas y bitácora

El resultado de optimización incluye:

- conteos por técnica (`constantsFolded`, `deadCodeRemoved`, `expressionsSimplified`, `controlFlowOptimized`),
- tamaño del AST antes y después y porcentaje estimado de reducción,
- tiempo total de la fase,
- bitácora textual de transformaciones aplicadas.

---

## 20.5 Integración en el canal de conversión

La optimización requiere información semántica (tipos y declaraciones) y por ello se ejecuta después del análisis semántico.

En la versión actual, el AST optimizado se conserva en el resultado de compilación para métricas y diagnóstico. La emisión de código C se realiza principalmente a partir del grafo del diagrama y de la tabla de símbolos, por lo que el AST optimizado no se utiliza todavía como fuente directa de emisión.
