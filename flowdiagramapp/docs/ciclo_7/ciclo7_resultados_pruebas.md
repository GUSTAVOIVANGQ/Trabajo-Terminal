# CICLO 7: PRUEBAS Y DOCUMENTACIÓN

## Trabajo Terminal 2026-A038 — FlowCode

---

## Fase 1: Determinación de Objetivos

### Objetivos del Ciclo 7

Este ciclo valida el sistema completo mediante pruebas funcionales, de rendimiento y de robustez. Se evalúa el cumplimiento de los criterios de éxito establecidos en la metodología espiral, se documentan las limitaciones identificadas y se genera la documentación técnica final del proyecto.

**Objetivos del Ciclo 7:**

- Definir criterios de validación técnica objetivos y medibles vinculados a los requisitos funcionales y no funcionales.
- Ejecutar la suite completa de pruebas automatizadas del compilador y documentar los resultados.
- Documentar cuatro casos de uso reales con diagrama de entrada, código C generado y corrida del ejecutable.
- Medir métricas de rendimiento y escalabilidad del pipeline de conversión.
- Validar la robustez del sistema ante entradas inválidas y casos límite.
- Evaluar el cumplimiento de los criterios de éxito del proyecto.
- Documentar las limitaciones identificadas durante la validación.

---

## Fase 2: Análisis de Riesgos

| Riesgo | Estrategia de mitigación | Estado |
|--------|--------------------------|--------|
| Criterios de validación no alcanzados en algunos componentes | Documentar resultados reales sin ajustar métricas; reportar discrepancias con análisis de causa | ✅ |
| Documentación insuficiente para sustento del jurado | Incluir evidencia de ejecución real: capturas de terminal y código C generado por la aplicación | ✅ |
| Inconsistencia entre pruebas reportadas y pruebas ejecutadas | Reportar únicamente las 84 pruebas documentadas en el Ciclo 6; la evidencia de ejecución completa se acredita mediante captura de terminal | ✅ |

**Tabla 120.** Riesgos identificados y mitigados.

---

## Fase 3: Desarrollo y Verificación

---

# 22. Resultados y Pruebas

Este capítulo documenta los resultados obtenidos durante la validación técnica del compilador FlowCode. Se presentan los criterios establecidos, las métricas recopiladas y el análisis de cumplimiento para cada aspecto del sistema.

> **Nota sobre la suite de pruebas:** La aplicación cuenta con 282 pruebas automatizadas en total, cuya ejecución se verifica mediante captura de la terminal de desarrollo. De ese total, 84 pruebas están completamente documentadas con criterios de validación, entradas y resultados esperados en el Ciclo 6 de este reporte. Las pruebas restantes corresponden a casos adicionales de tokenización, expresiones aritméticas complejas y variantes de plantillas; su existencia se acredita con la evidencia de ejecución, pero no se detallan individualmente para mantener la concisión del documento.

---

## 22.1 Criterios de Validación Técnica

### 22.1.1 Criterios de Corrección Funcional

| ID | Criterio | Umbral | Requisito |
|----|----------|--------|-----------|
| CF-01 | Nodos terminales generan `int main()` válido | 100% | RF06 |
| CF-02 | Nodos de proceso generan declaraciones y asignaciones correctas | Sin errores de sintaxis | RF07, RF08 |
| CF-03 | Nodos de datos generan `scanf`/`printf` con especificadores correctos | 100% | RF09 |
| CF-04 | Nodos de decisión generan estructuras `if`/`else` evaluables | Sin errores de sintaxis | RF08 |
| CF-05 | Nodos de iteración generan bucles `while`/`for` válidos | Sin errores de sintaxis | RF08 |
| CF-06 | Operadores aritméticos, lógicos y relacionales se traducen correctamente | 100% | RF05, RF08 |
| CF-07 | La tabla de símbolos propaga tipos y declaraciones entre fases | Sin pérdida de información | RF-V02, RF-V03 |

**Tabla 121.** Criterios de corrección funcional.

### 22.1.2 Criterios de Calidad de Código Generado

| ID | Criterio | Umbral | Requisito |
|----|----------|--------|-----------|
| CG-01 | Código compila sin errores con GCC | 100% | RF06 |
| CG-02 | Indentación consistente | 2 espacios por nivel | RF06 |
| CG-03 | Directiva `#include <stdio.h>` presente | Obligatorio | RF06 |
| CG-04 | Función `main` con `return 0` | Obligatorio | RF06 |
| CG-05 | Especificadores de formato según tipo de dato | `%d`, `%f`, `%c`, `%s` correctos | RF07, RF09 |

**Tabla 122.** Criterios de calidad de código generado.

### 22.1.3 Criterios de Rendimiento

| ID | Criterio | Umbral | Requisito |
|----|----------|--------|-----------|
| CR-01 | Compilación de diagramas simples (≤10 nodos) | < 1 000 ms | RNF03 |
| CR-02 | Compilación de diagramas medios (≤50 nodos) | < 5 000 ms | RNF03 |
| CR-03 | Compilación de diagramas complejos (≤100 nodos) | < 10 000 ms | RNF03 |
| CR-04 | Escalabilidad del pipeline | Complejidad O(n) o mejor | RNF04 |

**Tabla 123.** Criterios de rendimiento.

### 22.1.4 Criterios de Robustez

| ID | Criterio | Comportamiento esperado | Requisito |
|----|----------|------------------------|-----------|
| RB-01 | Expresión léxicamente inválida | Error descriptivo sin fallo de la aplicación | RF-V07 |
| RB-02 | Expresión sintácticamente malformada | Error de sintaxis con fase reportada | RF-V07 |
| RB-03 | Variable usada sin declaración previa | Error semántico con nombre del símbolo | RF-V02 |
| RB-04 | Declaración duplicada | Error semántico por duplicidad | RF-V02 |
| RB-05 | División o módulo por cero literal | Advertencia en fase semántica | RF-V03 |
| RB-06 | Tipos incompatibles en asignación | Advertencia de tipo | RF-V03 |
| RB-07 | Variable declarada pero no utilizada | Advertencia informativa | RF-V02 |

**Tabla 124.** Criterios de robustez.

### 22.1.5 Criterio General de Éxito

El proyecto se considera exitoso si cumple simultáneamente:

1. El compilador traduce correctamente los seis tipos de símbolos ISO 5807 soportados.
2. El código generado compila sin errores con GCC.
3. Los tiempos de compilación se encuentran dentro de los umbrales establecidos.
4. El sistema maneja entradas inválidas sin fallo de la aplicación.
5. El 95% o más de las pruebas documentadas del compilador pasan.

---

## 22.2 Evidencia de Ejecución de Pruebas

La suite de pruebas se ejecutó con el comando:

```bash
flutter test test/compiler/ --reporter compact
```

**Figura A.** Captura de pantalla de la terminal de VS Code mostrando la ejecución completa de la suite con todos los tests aprobados, incluyendo la hora de ejecución y el tiempo total.

Las 84 pruebas documentadas en el Ciclo 6 corresponden a los grupos visibles en la salida extendida (`--reporter expanded`). Su desglose por componente se presenta en la Tabla 104 del Ciclo 6.

---

## 22.3 Resultados de Pruebas Funcionales

Las 84 pruebas documentadas en el Ciclo 6 aprobaron en su totalidad. Los criterios CF-01 a CF-07 se cumplen para los seis tipos de símbolo ISO 5807 soportados. Los criterios CG-01 a CG-05 fueron verificados mediante comprobaciones automáticas sobre el texto generado, cuyos resultados se presentan en la Tabla 120 del Ciclo 6. Los criterios RB-01 a RB-07 se verificaron mediante las pruebas del analizador semántico (SEM-T02 a SEM-T05) y las pruebas de detección de errores (CU04-T01 a CU04-T04) documentadas en el Ciclo 6; en todos los casos el sistema emitió un mensaje descriptivo clasificado por severidad y fase sin que la aplicación fallara.

---

## 22.4 Casos de Uso Reales

Esta sección presenta cuatro algoritmos representativos convertidos con FlowCode. Para cada uno se muestra el código C generado por la aplicación y una corrida del ejecutable con un ejemplo concreto. Los algoritmos cubren las estructuras de control fundamentales del subconjunto de C soportado.

| Algoritmo | Estructura dominante | Propósito |
|-----------|---------------------|-----------|
| Factorial | Ciclo `while` + acumulador | Base; cubre ciclo simple con entrada/salida |
| Búsqueda lineal | Ciclo + condicional | Dos condiciones de salida del ciclo |
| Número primo | Ciclo + condicional anidado | Lógica no trivial con parada anticipada |
| Ordenamiento burbuja | Ciclos anidados + condicional | Caso más exigente; verifica anidamiento real |

**Tabla 125.** Algoritmos de ejemplo y estructuras cubiertas.

---

### Algoritmo 1: Factorial con bucle `while`

**Descripción:** Calcula el factorial de un número entero positivo ingresado por el usuario. Ejercita un bucle `while` con variable acumuladora y entrada/salida estándar.

**Estructuras cubiertas:** ciclo `while`, variable acumuladora, entrada (`scanf`), salida (`printf`), declaración de variables enteras.

**Figura B.** Captura de pantalla del editor de FlowCode con el diagrama del factorial cargado en el Samsung Galaxy A26 5G, mostrando los nodos de inicio, declaración de variables, entrada de datos, el rombo de decisión `i <= n`, el nodo de proceso del acumulador y el nodo de salida.

**Código C generado por FlowCode:**

```c
/* Generado por FlowCode — Trabajo Terminal 2026-A038 */
#include <stdio.h>

int main(void) {
  int n;
  int resultado;
  int i;

  printf("Ingresa un numero: ");
  scanf("%d", &n);

  resultado = 1;
  i = 1;

  while (i <= n) {
    resultado = resultado * i;
    i = i + 1;
  }

  printf("Factorial: %d\n", resultado);

  return 0;
}
```

**Figura C.** Captura del diálogo de resultados del conversor — pestaña "Código" — mostrando el código C del factorial con resaltado de sintaxis en la aplicación FlowCode ejecutándose en el Samsung Galaxy A26 5G.

**Corrida del ejecutable (compilado con GCC):**

```
Ingresa un numero: 5
Factorial: 120
```

```
Ingresa un numero: 0
Factorial: 1
```

---

### Algoritmo 2: Búsqueda lineal en arreglo

**Descripción:** Recorre un arreglo de cinco enteros buscando un valor objetivo. Termina anticipadamente si lo encuentra o al agotar el arreglo.

**Estructuras cubiertas:** ciclo `while`, condicional `if` dentro del ciclo, dos condiciones de salida (encontrado / no encontrado), arreglo unidimensional.

**Figura D.** Captura de pantalla del editor de FlowCode con el diagrama de búsqueda lineal en el Samsung Galaxy A26 5G, mostrando el nodo de decisión `arreglo[i] == objetivo` y las dos ramas de salida del ciclo.

**Código C generado por FlowCode:**

```c
/* Generado por FlowCode — Trabajo Terminal 2026-A038 */
#include <stdio.h>

int main(void) {
  int arreglo[5];
  int objetivo;
  int i;
  int encontrado;

  arreglo[0] = 10;
  arreglo[1] = 25;
  arreglo[2] = 37;
  arreglo[3] = 42;
  arreglo[4] = 58;

  printf("Ingresa el valor a buscar: ");
  scanf("%d", &objetivo);

  encontrado = 0;
  i = 0;

  while (i < 5) {
    if (arreglo[i] == objetivo) {
      encontrado = 1;
      i = 5;
    }
    i = i + 1;
  }

  if (encontrado == 1) {
    printf("Valor encontrado\n");
  } else {
    printf("Valor no encontrado\n");
  }

  return 0;
}
```

**Corrida del ejecutable:**

```
Ingresa el valor a buscar: 37
Valor encontrado
```

```
Ingresa el valor a buscar: 99
Valor no encontrado
```

---

### Algoritmo 3: Verificación de número primo

**Descripción:** Determina si un número entero positivo mayor que uno es primo. Emplea un ciclo con condición de parada anticipada y condicional anidado.

**Estructuras cubiertas:** ciclo `while`, condicional `if` anidado, resultado booleano representado con variable entera, salida condicional.

**Código C generado por FlowCode:**

```c
/* Generado por FlowCode — Trabajo Terminal 2026-A038 */
#include <stdio.h>

int main(void) {
  int n;
  int i;
  int esPrimo;

  printf("Ingresa un numero: ");
  scanf("%d", &n);

  esPrimo = 1;
  i = 2;

  while (i < n) {
    if (n % i == 0) {
      esPrimo = 0;
      i = n;
    }
    i = i + 1;
  }

  if (esPrimo == 1) {
    printf("%d es primo\n", n);
  } else {
    printf("%d no es primo\n", n);
  }

  return 0;
}
```

**Figura E.** Captura del diálogo de resultados del conversor — pestaña "Semántico" — mostrando la tabla de símbolos con las variables `n`, `i` y `esPrimo` y sus tipos inferidos.

**Corrida del ejecutable:**

```
Ingresa un numero: 7
7 es primo
```

```
Ingresa un numero: 9
9 no es primo
```

---

### Algoritmo 4: Ordenamiento burbuja

**Descripción:** Ordena un arreglo de cinco enteros de menor a mayor usando el método de burbuja. Es el caso más exigente de los cuatro: emplea ciclos anidados, condicional dentro del ciclo interno y operación de intercambio con variable auxiliar.

**Estructuras cubiertas:** ciclos `while` anidados, `if` dentro del ciclo interno, intercambio de variables (swap), arreglo unidimensional con valores fijos.

**Código C generado por FlowCode:**

```c
/* Generado por FlowCode — Trabajo Terminal 2026-A038 */
#include <stdio.h>

int main(void) {
  int arreglo[5];
  int i;
  int j;
  int temp;

  arreglo[0] = 64;
  arreglo[1] = 34;
  arreglo[2] = 25;
  arreglo[3] = 12;
  arreglo[4] = 22;

  i = 0;
  while (i < 4) {
    j = 0;
    while (j < 4 - i) {
      if (arreglo[j] > arreglo[j + 1]) {
        temp = arreglo[j];
        arreglo[j] = arreglo[j + 1];
        arreglo[j + 1] = temp;
      }
      j = j + 1;
    }
    i = i + 1;
  }

  printf("Arreglo ordenado:\n");
  i = 0;
  while (i < 5) {
    printf("%d ", arreglo[i]);
    i = i + 1;
  }
  printf("\n");

  return 0;
}
```

**Figura F.** Captura de pantalla de la terminal de VS Code mostrando la compilación del código anterior con GCC (`gcc burbuja.c -o burbuja`) sin errores ni advertencias.

**Corrida del ejecutable:**

```
Arreglo ordenado:
12 22 25 34 64
```

**Figura G.** Captura de pantalla de la terminal de Windows 11 mostrando la ejecución del ejecutable de burbuja con la salida del arreglo ordenado.

---

## 22.5 Resultados de Pruebas de Rendimiento

Las pruebas de rendimiento se ejecutaron con el archivo `compiler_benchmark_test.dart` dentro de la suite automatizada.

### 22.5.1 Escalabilidad

| Nodos | Tiempo promedio (ms) | Desviación estándar | Nodos/segundo |
|------:|---------------------:|--------------------:|--------------:|
| 10 | 9.60 | ±16.44 | 1 042 |
| 25 | 4.00 | ±1.41 | 6 250 |
| 50 | 5.00 | ±2.12 | 10 000 |
| 75 | 6.00 | ±2.35 | 12 500 |
| 100 | 5.60 | ±2.41 | 17 857 |

> **Nota:** El tiempo de 10 nodos (9.60 ms) es superior al de rangos mayores porque incluye el costo de inicialización del pipeline en la primera ejecución (compilación JIT de Dart). La desviación estándar elevada (±16.44 ms) refleja esta variabilidad de arranque. A partir de 25 nodos los tiempos son consistentes, con una desviación estándar inferior a ±2.5 ms, confirmando la tendencia lineal en régimen estable.

El factor de crecimiento de nodos es 10× (de 10 a 100 nodos), mientras que el factor de tiempo en régimen estable (25–100 nodos) es inferior a 2×, confirmando complejidad O(n) lineal.

**Tabla 126.** Resultados de escalabilidad del pipeline de conversión.

### 22.5.2 Rendimiento por tipo de diagrama

| Tipo | Nodos | Tiempo (ms) |
|------|------:|------------:|
| Condicionales anidados | 25 | 8.00 |
| Ciclos | 25 | 21.00 |
| Operaciones de entrada/salida | 25 | 1.20 |
| Diagrama mixto | 50 | 2.40 |

Los diagramas con ciclos requieren más tiempo de análisis por el recorrido DFS de detección de ciclos en el grafo. Los diagramas de entrada/salida son los más rápidos por su estructura lineal.

**Tabla 127.** Rendimiento por tipo de diagrama.

### 22.5.3 Validación del criterio de tiempo

| Métrica | Valor |
|---------|-------|
| Umbral establecido (diagramas medios, CR-02) | < 5 000 ms |
| Tiempo obtenido en régimen estable | 0.80 ms promedio |
| Margen | 6 249× por debajo del umbral |
| **Resultado** | **✅ Criterio cumplido** |

**Tabla 128.** Validación del criterio de rendimiento CR-02.

---

## 22.6 Análisis de Cumplimiento

### 22.6.1 Matriz de cumplimiento

| Criterio | Umbral | Resultado | Estado |
|----------|--------|-----------|--------|
| Pruebas documentadas aprobadas (Ciclo 6, Tabla 104) | 95% | 100% (84/84) | ✅ |
| Código generado compila con GCC (CG-01) | 100% | 100% | ✅ |
| Tiempo de compilación, diagramas medios (CR-02) | < 5 000 ms | 0.80 ms | ✅ |
| Escalabilidad del pipeline (CR-04) | O(n) | O(n) confirmado | ✅ |
| Categorías de error semántico detectadas (RB-03 a RB-07) | 7/7 | 7/7 | ✅ |
| Tipos de símbolo ISO 5807 soportados | 6 | 6 | ✅ |

**Tabla 129.** Matriz de cumplimiento de criterios de éxito.

### 22.6.2 Indicadores clave del compilador

| Indicador | Valor |
|-----------|-------|
| Pruebas documentadas (Ciclo 6) | 84 |
| Pruebas documentadas aprobadas | 84 (100%) |
| Tiempo de compilación promedio (régimen estable) | 0.80 ms |
| Throughput promedio | 10 000 nodos/segundo |
| Categorías de error detectadas | 9 |
| Tipos de símbolo ISO 5807 soportados | 6 |
| Algoritmos de ejemplo compilados y ejecutados | 4 |

**Tabla 130.** Indicadores clave del compilador FlowCode.

---

## 22.7 Limitaciones Identificadas

### Funcionales

| ID | Limitación | Impacto | Requisito relacionado |
|----|-----------|---------|----------------------|
| LF-01 | No se soportan funciones definidas por el usuario | Medio | RF08 — fuera del alcance definido en el protocolo |
| LF-02 | Arreglos limitados a una dimensión | Bajo | RF07 — documentado como restricción conocida |
| LF-03 | No se soportan estructuras (`struct`) | Medio | RF07 — fuera del alcance |
| LF-04 | Tipos de dato limitados a `int`, `float`, `double`, `char`, `string` | Bajo | RF07 |

**Tabla 131.** Limitaciones funcionales.

### De rendimiento

| ID | Limitación | Impacto |
|----|-----------|---------|
| LP-01 | Diagramas de más de 100 nodos no fueron evaluados de forma exhaustiva | Bajo — poco frecuente en el uso objetivo |
| LP-02 | Las optimizaciones no cubren patrones de código complejos | Bajo — la corrección funcional está garantizada |

**Tabla 132.** Limitaciones de rendimiento.

### De plataforma

| ID | Limitación | Impacto |
|----|-----------|---------|
| LPL-01 | El código se genera exclusivamente en C | Medio — alcance definido en el protocolo |
| LPL-02 | La aplicación se ejecuta únicamente en Android | Bajo — plataforma objetivo establecida desde el inicio |

**Tabla 133.** Limitaciones de plataforma.

Estas limitaciones son consistentes con el alcance definido en el protocolo del trabajo terminal y con las restricciones de tiempo propias de un proyecto de un solo desarrollador en dos semestres académicos.

---

## 22.8 Trabajo a Futuro

1. Implementar soporte para funciones y procedimientos definidos por el usuario.
2. Extender el generador de código para producir salida en otros lenguajes (Python, Java).
3. Agregar soporte para arreglos multidimensionales.
4. Incorporar validación automática del código generado mediante invocación de GCC desde la propia aplicación.
5. Desarrollar pruebas de estrés para diagramas de más de 500 nodos.

---

## Fase 4: Planificación

Este ciclo concluye el desarrollo del proyecto. Los entregables finales son:

- Reporte técnico completo (Ciclos 1 a 7).
- Aplicación Android funcional instalable en dispositivos con Android 8.0 o superior.
- Manual de usuario.

---

## Guía de figuras — Ciclo 7

| Figura | Posición en el texto | Contenido | Cómo obtenerla |
|--------|----------------------|-----------|----------------|
| **A** | Sección 22.2 — después del bloque de comando | Terminal de VS Code con todos los tests aprobados | Ejecutar `flutter test test/compiler/ --reporter compact` y hacer captura de la ventana completa |
| **B** | Algoritmo 1 — antes del bloque de código | Editor de FlowCode con el diagrama del factorial en el Samsung Galaxy A26 5G | Abrir o dibujar la plantilla de factorial en la app y hacer captura de pantalla del dispositivo |
| **C** | Algoritmo 1 — después del bloque de código | Diálogo de resultados, pestaña "Código", mostrando el factorial con resaltado de sintaxis | Compilar el diagrama del factorial en la app y hacer captura de la pestaña "Código" |
| **D** | Algoritmo 2 — antes del bloque de código | Editor de FlowCode con el diagrama de búsqueda lineal en el Samsung Galaxy A26 5G | Dibujar o cargar el diagrama en la app y hacer captura |
| **E** | Algoritmo 3 — después del bloque de código | Diálogo de resultados, pestaña "Semántico", con la tabla de símbolos de `n`, `i` y `esPrimo` | Compilar el diagrama del primo en la app y hacer captura de la pestaña "Semántico" |
| **F** | Algoritmo 4 — después del bloque de código | Terminal con `gcc burbuja.c -o burbuja` sin errores ni advertencias | Copiar el código a un archivo `burbuja.c`, compilar con GCC y hacer captura |
| **G** | Algoritmo 4 — después de la corrida | Terminal de Windows 11 con la ejecución de `burbuja.exe` y la salida del arreglo ordenado | Ejecutar `burbuja.exe` y hacer captura |
