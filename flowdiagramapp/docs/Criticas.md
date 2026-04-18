## Evaluación — Ciclo 3: Secciones 14 y 15

**Calificación global: 6.5 / 10**

---

### Lo que está bien

El contenido cubre la estructura general del editor y la persistencia de forma concisa y sin repetición innecesaria. Los archivos fuente están referenciados con rutas concretas, lo que da trazabilidad técnica. La descripción del modelo de datos (DiagramNode, Connection, NodeType) es correcta y el esquema de base de datos es claro.

---

### Problemas identificados y su severidad

**Severidad alta — directamente relacionados con la crítica del sinodal**

**1. No se explica el formato del grafo ni cómo se recorre.**
El texto menciona que los nodos y conexiones se serializan en JSON, pero nunca describe la estructura de ese JSON: qué campos tiene un nodo serializado, cómo se representan las aristas, qué propiedades porta `metadata`. Tampoco se explica que el grafo se recorre mediante BFS/DFS antes de pasarlo al pipeline. El lector no sabe cómo se transita del editor a la fase de análisis.

**2. Los algoritmos no se describen en la sección donde se usan.**
El routing ortogonal de conexiones, el hit-testing punto-segmento, la transformación viewport→mundo y el sistema de snapshots para undo/redo son algoritmos con lógica no trivial. El reporte los menciona por nombre pero no explica su funcionamiento. El sinodal no puede evaluar si se implementaron correctamente.

**3. Cero referencias bibliográficas en todo el Ciclo 3.**
Sección 14 y 15 no citan ninguna fuente. El algoritmo de transformación de coordenadas, el routing ortogonal y la serialización JSON son temas con respaldo en literatura técnica (Flutter docs, Cormen para BFS/DFS, etc.). Esto debilitó la presentación en TT I.

**Severidad media**

**4. La validación estructural del grafo está descrita en 14.4.4 pero sin detalle.**
Se menciona `diagram_validator.dart` con las validaciones, pero no se explica la lógica de ninguna. Para el sinodal esto es la parte más técnica del ciclo: cómo BFS detecta nodos inalcanzables, cómo DFS detecta ciclos. El protocolo prometió estas implementaciones explícitamente.

**5. La sección 15.7 (Crashlytics) afirma que no está implementada.**
Esto es coherente con la realidad, pero en el índice aparece como sección con subsecciones. Si no está implementado, debe eliminarse del índice o reemplazarse con una nota de una línea. Mantenerlo como sección vacía genera preguntas innecesarias.

**6. Lenguaje de aprendizaje.**
En `Application_FlowCode_38-48.md` aparece la frase "herramienta educativa poderosa" y "guiando al usuario en la corrección de problemas desde lo estructural hasta lo semántico". Si alguna de estas frases migró al reporte, deben eliminarse. El reporte técnico debe describir funcionalidad, no propósito pedagógico.

**Severidad baja**

**7. Las subsecciones 14.6.1 y 14.6.2** no explican como se implementa copiar/pegar y duplicación .

### Respuesta a tu pregunta sobre pseudocódigo y figuras de algoritmos

**Sí, debes incluirlos, al menos para los tres algoritmos centrales del Ciclo 3. para ello revisa los codigos del proyecto.**

La razón es exactamente la crítica del sinodal: sin pseudocódigo o diagrama, el evaluador no puede distinguir si implementaste los algoritmos  correctamente o si simplemente copiaste una librería. algunas sugerencias son:

- **BFS de alcanzabilidad**: pseudocódigo de líneas con referencia a Cormen [7].
- **Detección de ciclos con DFS** (bucles): pseudocódigo con marcado de colores (blanco/gris/negro), referencia a Cormen [7] o Tarjan [6].
- **Routing ortogonal de conexiones**: un diagrama que muestre los 4 casos de combinación de caras de salida/entrada, no necesariamente pseudocódigo pero sí una figura explicativa.
- **Transformación viewport↔mundo**: una ecuación de dos líneas es suficiente.

No necesitas código Dart completo. El pseudocódigo o la ecuación demuestra que entiendes el algoritmo y lo implementaste intencionalmente.

---

### Correcciones concretas que debes hacer antes de entregar

1. **Agregar un subapartado 14.1.4 "Estructura del grafo en memoria y su serialización JSON"** que muestre un fragmento de ejemplo del JSON de un nodo y una arista, y explique los campos relevantes.
2. **Agregar pseudocódigo de BFS y DFS en 14.4.4** con sus respectivas referencias a Cormen [7] y al protocolo (el protocolo menciona BFS/DFS explícitamente).
3. **Agregar referencias en cada subsección** donde corresponda: Flutter CustomPainter en 14.1.1, ISO 5807 en 14.2.1, sqflite en 15.1, Firebase docs en 15.4.
4. **Revisar que no aparezca ninguna referencia a aprendizaje, comprensión o propósito educativo** en estas secciones.
