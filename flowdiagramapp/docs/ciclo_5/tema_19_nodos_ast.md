# Tema 19: Representación intermedia (AST)

El Árbol de Sintaxis Abstracta (AST) es la representación intermedia producida por el análisis sintáctico. En el Ciclo 5 se utiliza como insumo de optimización y como soporte de trazabilidad y diagnóstico.

La jerarquía completa de nodos del AST se detalla en la documentación del motor de análisis. En este tema se presenta únicamente lo necesario para describir la trazabilidad y el recorrido del árbol durante la optimización.

---

## 19.1 Estructura base y trazabilidad

Todos los nodos del AST derivan de una clase base `ASTNode`, que mantiene:

- `position`: ubicación (línea y columna) del constructo dentro del texto analizado.
- `nodeId`: identificador opcional del nodo de diagrama del cual proviene el fragmento.
- `accept<T>(...)`: punto de entrada al patrón Visitante.
- `children`: colección de subnodos para recorridos genéricos.
- `toTreeString(...)`: representación textual del subárbol para inspección.

El nodo raíz `ProgramNode` agrupa:

- `diagramNodes`: lista de contenedores `DiagramASTNode`, cada uno asociado a un nodo del diagrama.
- `globalDeclarations`: declaraciones globales detectadas durante el análisis.

La clase `DiagramASTNode` preserva la relación diagrama↔AST, permitiendo asociar diagnósticos a una posición textual y a un símbolo del diagrama.

![Figura N. Relación entre diagrama, `ProgramNode` y `DiagramASTNode`.](figuras/figura_n_relacion_diagrama_programnode_diagramastnode.svg)

*[Figura N. Relación entre diagrama, `ProgramNode` y `DiagramASTNode`.]*

---

## 19.2 Recorrido (patrón Visitante)

El AST se recorre mediante una interfaz `ASTVisitor<T>` con métodos `visit...` por tipo de nodo. Para recorridos genéricos se emplean visitantes base y utilidades como `NodeCollector` para recolectar nodos por tipo.

La representación textual provista por `toTreeString()` facilita la inspección de subárboles durante la verificación del conversor.

*[Figura N. Ejemplo de salida de `toTreeString()` para un fragmento sencillo.]*
