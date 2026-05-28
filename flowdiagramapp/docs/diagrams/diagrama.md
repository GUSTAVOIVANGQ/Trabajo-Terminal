Diagrama 1 — Agregar un nodo al diagrama

sequenceDiagram
    actor U as Usuario
    participant NP as NodePalette
    participant ES as EditorScreen
    participant FC as FlowDiagramCanvas
    participant DN as DiagramNode
    participant CG as CodeGenerator

    U->>NP: Selecciona tipo de nodo desde la paleta
    NP->>ES: onNodeSelected(NodeType)
    ES->>DN: Crea DiagramNode(type, position, metadata)
    ES->>FC: Agrega nodo a lista nodes[]
    FC->>FC: setState() → repinta canvas
    FC-->>U: Renderiza el nuevo nodo en el área de trabajo


Diagrama 2 — Configurar propiedades del nodo

sequenceDiagram
    actor U as Usuario
    participant NP as NodePalette
    participant ES as EditorScreen
    participant FC as FlowDiagramCanvas
    participant DN as DiagramNode
    participant CG as CodeGenerator

    U->>FC: Doble tap sobre el nodo
    FC->>ES: onNodeDoubleTap(node)
    ES->>ES: Abre diálogo según tipo (ProcessNodeDialog, DecisionNodeDialog, etc.)
    ES-->>U: Presenta formulario de propiedades
    U->>ES: Ingresa expresión/contenido y confirma
    ES->>DN: Actualiza node metadata con nuevas propiedades
    DN->>CG: generateCode(nodes, connections)
    CG-->>ES: Código C actualizado
    ES-->>U: Actualiza panel lateral con código generado


Diagrama 3 — Establecer una conexión entre dos nodos

sequenceDiagram
    actor U as Usuario
    participant NP as NodePalette
    participant ES as EditorScreen
    participant FC as FlowDiagramCanvas
    participant DN as DiagramNode
    participant CG as CodeGenerator

    U->>FC: Toca nodo origen (activa modo conexión)
    FC->>ES: onConnectionStart(sourceNode)
    ES->>ES: isConnecting = true, connectionStart = sourceNode
    ES-->>FC: Feedback visual: nodo origen resaltado
    U->>FC: Toca nodo destino
    FC->>ES: onConnectionEnd(targetNode)
    ES->>ES: Valida conexión (reglas ISO 5807)

    alt Conexión Válida
        ES->>FC: Crea Connection(source, target) y agrega a connections[]
        FC->>FC: setState() → repinta conexión con flecha
        FC->>CG: generateCode(nodes, connections)
        CG-->>ES: Código C actualizado
        ES-->>FC: Renderiza línea con flecha entre nodos
    else Conexión Inválida
        ES-->>U: Muestra mensaje de error con motivo del rechazo
        ES->>ES: isConnecting = false (cancela operación)
    end
