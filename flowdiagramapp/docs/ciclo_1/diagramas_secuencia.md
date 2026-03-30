# Diagramas de Secuencia — Flujo Principal

---

## DS-CU01: Crear Nuevo Diagrama

Describe la interacción entre el usuario y los componentes del sistema al crear un nuevo proyecto de diagrama de flujo.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant WS as WelcomeScreen
    participant ES as EditorScreen
    participant SD as SaveDiagramDialog
    participant DB as DatabaseService
    participant SQLite as SQLite

    Usuario->>WS: Selecciona "Nuevo diagrama"
    WS->>ES: Navega a EditorScreen(initialDiagram: null)
    ES->>ES: Inicializa canvas vacío (nodes=[], connections=[])
    ES->>ES: Configura panOffset, scale, paleta de nodos
    ES-->>Usuario: Presenta editor visual con área de trabajo vacía

    Note over Usuario,ES: El usuario construye el diagrama

    Usuario->>ES: Presiona botón "Guardar"
    ES->>SD: Muestra SaveDiagramDialog
    SD-->>Usuario: Solicita nombre y descripción del proyecto
    Usuario->>SD: Ingresa nombre y descripción
    SD->>SD: Valida campos (nombre no vacío)

    alt Nombre válido
        SD->>ES: Retorna datos del proyecto
        ES->>ES: Serializa nodos y conexiones a JSON
        ES->>DB: saveDiagram(name, description, nodesJSON, connectionsJSON)
        DB->>SQLite: INSERT INTO diagrams (name, description, nodes_data, connections_data, ...)
        SQLite-->>DB: id del registro insertado
        DB-->>ES: SavedDiagram con id asignado
        ES->>ES: Actualiza currentDiagram con referencia al proyecto guardado
        ES-->>Usuario: Muestra confirmación "Diagrama guardado correctamente"
    else Nombre vacío o duplicado
        SD-->>Usuario: Muestra error de validación en el campo
    end
```

---

## DS-CU02: Agregar y Conectar Elementos

Describe el proceso de agregar nodos al diagrama y establecer conexiones entre ellos para construir la lógica del algoritmo.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant NP as NodePalette
    participant ES as EditorScreen
    participant Canvas as FlowDiagramCanvas
    participant DN as DiagramNode
    participant CG as CodeGenerator

    Note over Usuario,CG: Agregar un nodo al diagrama

    Usuario->>NP: Selecciona tipo de nodo desde la paleta
    NP->>ES: onNodeSelected(NodeType)
    ES->>DN: Crea DiagramNode(type, position, metadata)
    ES->>ES: Agrega nodo a lista nodes[]
    ES->>Canvas: setState() → repinta canvas
    Canvas-->>Usuario: Renderiza el nuevo nodo en el área de trabajo

    Note over Usuario,CG: Configurar propiedades del nodo

    Usuario->>Canvas: Doble tap sobre el nodo
    Canvas->>ES: onNodeDoubleTap(node)
    ES->>ES: Abre diálogo de edición según tipo (ProcessNodeDialog, DecisionNodeDialog, etc.)
    ES-->>Usuario: Presenta formulario de propiedades
    Usuario->>ES: Ingresa expresión/contenido y confirma
    ES->>DN: Actualiza node.metadata con nuevas propiedades
    ES->>CG: generateCode(nodes, connections)
    CG-->>ES: Código C actualizado
    ES->>ES: Actualiza panel lateral con código generado
    ES-->>Usuario: Muestra código C en tiempo real

    Note over Usuario,CG: Establecer una conexión entre dos nodos

    Usuario->>Canvas: Toca nodo origen (activa modo conexión)
    Canvas->>ES: onConnectionStart(sourceNode)
    ES->>ES: isConnecting = true, connectionStart = sourceNode
    Canvas-->>Usuario: Feedback visual: nodo origen resaltado

    Usuario->>Canvas: Toca nodo destino
    Canvas->>ES: onConnectionEnd(targetNode)
    ES->>ES: Valida conexión (reglas ISO 5807)

    alt Conexión válida
        ES->>ES: Crea Connection(source, target) y agrega a connections[]
        ES->>Canvas: setState() → repinta conexión con flecha
        ES->>CG: generateCode(nodes, connections)
        CG-->>ES: Código C actualizado
        Canvas-->>Usuario: Renderiza línea con flecha entre nodos
    else Conexión inválida
        ES-->>Usuario: Muestra mensaje de error con motivo del rechazo
        ES->>ES: isConnecting = false (cancela operación)
    end
```

---

## DS-CU03: Editar Propiedades de Elementos

Describe el proceso de edición de las propiedades de un elemento del diagrama, incluyendo la selección del nodo, la apertura del diálogo especializado según el tipo de nodo, la validación de la entrada y la actualización del código generado.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant Canvas as FlowDiagramCanvas
    participant ES as EditorScreen
    participant NED as NodeEditorDialog
    participant SD as SpecializedDialog
    participant DN as DiagramNode
    participant CG as CodeGenerator

    Usuario->>Canvas: Doble tap sobre un nodo existente
    Canvas->>ES: onNodeDoubleTap(selectedNode)
    ES->>ES: selectedNode = node

    ES->>NED: showDialog(NodeEditorDialog(node: selectedNode))
    NED->>NED: Evalúa node.type

    alt NodeType.process
        NED->>SD: Delega a ProcessNodeDialog(node)
        Note right of SD: Opciones: asignación simple,<br/>operación aritmética, incremento,<br/>decremento, declaración de variable,<br/>inicialización, constante, arreglo
        SD-->>Usuario: Presenta formulario con campos según operación
    else NodeType.decision
        NED->>SD: Delega a DecisionNodeDialog(node)
        Note right of SD: Opciones: comparación simple,<br/>condición compuesta, bucle (for/while),<br/>switch-case
        SD-->>Usuario: Presenta formulario de condición
    else NodeType.data
        NED->>SD: Delega a DataNodeDialog(node)
        Note right of SD: Opciones: scanf (entrada),<br/>printf (salida), formato de cadena
        SD-->>Usuario: Presenta formulario de entrada/salida
    else NodeType.preparation
        NED->>SD: Delega a PreparationNodeDialog(node)
        SD-->>Usuario: Presenta formulario de inicialización
    else NodeType.predefinedProcess
        NED->>SD: Delega a SubprocessNodeDialog(node)
        SD-->>Usuario: Presenta formulario de subproceso
    else Otros tipos (connector, comment, terminal)
        NED-->>Usuario: Presenta campo de texto genérico
    end

    Note over Usuario,SD: El usuario completa el formulario

    Usuario->>SD: Ingresa expresión/contenido y presiona "Aceptar"
    SD->>SD: Valida sintaxis de la expresión

    alt Validación exitosa
        SD->>SD: Construye NodeDialogResult o String

        alt Resultado es NodeDialogResult
            SD-->>ES: Retorna NodeDialogResult(text, loopStructure?, switchStructure?)
            ES->>DN: selectedNode.text = result.text

            opt generateLoopStructure == true
                ES->>ES: _generateLoopStructure(node, variable, limit, condition)
                ES->>ES: Crea nodos auxiliares para el ciclo (condición, cuerpo, incremento)
            end

            opt generateSwitchStructure == true
                ES->>ES: _generateSwitchStructure(node, variable, cases, hasDefault)
                ES->>ES: Crea nodos auxiliares para cada caso del switch
            end

        else Resultado es String
            SD-->>ES: Retorna texto actualizado
            ES->>DN: selectedNode.text = result
        end

        ES->>CG: generateCode(nodes, connections)
        CG-->>ES: Código C actualizado
        ES->>ES: Actualiza panel lateral con código generado
        ES->>Canvas: setState() → repinta el nodo con nueva etiqueta
        Canvas-->>Usuario: Renderiza nodo actualizado y código C en tiempo real

    else Validación falla
        SD-->>Usuario: Muestra indicadores de error en campos inválidos
        Note right of SD: El diálogo permanece abierto<br/>para que el usuario corrija
    end
```

---

## DS-CU04: Validar Estructura del Diagrama

Describe el proceso de validación estructural del diagrama antes de que pueda ser compilado o exportado.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant ES as EditorScreen
    participant DV as DiagramValidator
    participant ISO as ISO5807ConnectionRules
    participant VRD as ValidationResultDialog

    Usuario->>ES: Presiona botón "Validar diagrama"
    ES->>DV: validateDiagram(nodes, connections)

    DV->>DV: Verifica diagrama no vacío

    alt Diagrama vacío
        DV-->>ES: ValidationResult(isValid: false, error: "Diagrama vacío")
    else Diagrama con nodos
        DV->>DV: _validateStartNode(nodes)
        Note right of DV: Busca nodos tipo terminal<br/>con metadata "Inicio"

        alt Sin nodo de inicio
            DV->>DV: Agrega error "Falta nodo de inicio"
        end

        DV->>DV: _validateEndNode(nodes)
        Note right of DV: Busca nodos tipo terminal<br/>con metadata "Fin"

        alt Sin nodo de fin
            DV->>DV: Agrega error "Falta nodo de fin"
        end

        DV->>DV: _validateConnections(nodes, connections)
        Note right of DV: Verifica integridad referencial<br/>de sourceId y targetId

        DV->>DV: _validateNoDisconnectedNodes(nodes, connections)
        Note right of DV: Identifica nodos sin<br/>conexiones de entrada o salida

        DV->>ISO: _validateISO5807Symbols(nodes, connections)
        ISO->>ISO: Verifica minInputs/minOutputs por tipo de nodo
        ISO->>ISO: Valida nodos de decisión tengan 2+ salidas
        ISO-->>DV: Errores y advertencias de conformidad ISO 5807

        DV->>DV: Combina todos los resultados parciales (merge)
        DV-->>ES: ValidationResult(isValid, errors[], warnings[])
    end

    ES->>VRD: Muestra ValidationResultDialog(result)

    alt Diagrama válido
        VRD-->>Usuario: Indicador verde "Diagrama válido" con resumen
    else Diagrama con errores
        VRD-->>Usuario: Lista de errores con descripción y nodos afectados
    end
```

---

## DS-CU05: Realizar Análisis Semántico

Describe la fase de análisis semántico del compilador fuente-a-fuente, que valida la consistencia de variables y tipos.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant ES as EditorScreen
    participant CP as CompilerPipeline
    participant LA as LexicalAnalyzer
    participant SA as SyntaxAnalyzer
    participant SemA as SemanticAnalyzer
    participant ST as SymbolTable
    participant CRD as CompilerResultsDialog

    Usuario->>ES: Presiona botón "Compilar"
    ES->>CP: compile(nodes, connections)

    Note over CP,LA: Fase 1 — Análisis Léxico (prerrequisito)
    CP->>LA: analyzeDiagram(nodes, connections)
    LA->>LA: Tokeniza contenido de cada nodo
    LA->>ST: Registra variables encontradas en tabla de símbolos
    LA-->>CP: DiagramLexicalResult(tokens, symbolTable, errors)

    Note over CP,SA: Fase 2 — Análisis Sintáctico (prerrequisito)
    CP->>SA: analyzeDiagram(nodes, connections)
    SA->>SA: Parsea tokens y construye AST (ProgramNode)
    SA-->>CP: SyntaxAnalysisResult(ast, errors)

    Note over CP,SemA: Fase 3 — Análisis Semántico
    CP->>SemA: analyzeDiagram(nodes, connections, symbolTable, ast)

    SemA->>ST: Consulta tabla de símbolos existente
    SemA->>SemA: Verifica declaración de variables antes de uso
    SemA->>SemA: Valida compatibilidad de tipos en asignaciones
    SemA->>SemA: Verifica condiciones en nodos de decisión (tipo booleano)
    SemA->>SemA: Detecta variables declaradas pero no utilizadas
    SemA->>ST: Actualiza tabla con tipos inferidos y scopes

    alt Sin errores semánticos
        SemA-->>CP: SemanticAnalysisResult(symbolTable, warnings[])
        CP->>CP: Continúa a Fase 4 (Optimización)
    else Con errores semánticos
        SemA-->>CP: SemanticAnalysisResult(errors[], symbolTable)
        CP-->>ES: CompilationResult(success: false, errors)
    end

    ES->>CRD: Muestra CompilerResultsDialog(result)
    CRD-->>Usuario: Presenta tabla de símbolos, errores/advertencias y fase alcanzada
```

---

## DS-CU06: Generar Código C

Describe el flujo completo del pipeline de compilación fuente-a-fuente, desde el diagrama de flujo hasta la generación de código funcional en lenguaje C.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant ES as EditorScreen
    participant CP as CompilerPipeline
    participant LA as LexicalAnalyzer
    participant SA as SyntaxAnalyzer
    participant SemA as SemanticAnalyzer
    participant Optimizer as CodeOptimizer
    participant Gen as AdvancedCodeGenerator
    participant CRD as CompilerResultsDialog

    Usuario->>ES: Presiona botón "Compilar"
    ES->>CP: compile(nodes, connections)
    CP->>CP: Inicializa errores y métricas

    Note over CP,LA: FASE 1 — Análisis Léxico
    CP->>LA: analyzeDiagram(nodes, connections)
    LA->>LA: Recorre nodos y extrae tokens
    LA-->>CP: DiagramLexicalResult(tokens, symbolTable)

    alt Errores fatales en Fase 1
        CP-->>ES: CompilationResult(success: false)
    end

    Note over CP,SA: FASE 2 — Análisis Sintáctico
    CP->>SA: analyzeDiagram(nodes, connections)
    SA->>SA: Construye AST (ProgramNode) a partir de tokens
    SA-->>CP: SyntaxAnalysisResult(ast, statements)

    alt Errores fatales en Fase 2
        CP-->>ES: CompilationResult(success: false)
    end

    Note over CP,SemA: FASE 3 — Análisis Semántico
    CP->>SemA: analyzeDiagram(nodes, connections, symbolTable, ast)
    SemA->>SemA: Valida tipos, variables y consistencia
    SemA-->>CP: SemanticAnalysisResult(symbolTable, errors/warnings)

    alt Errores semánticos
        CP-->>ES: CompilationResult(success: false)
    end

    Note over CP,Optimizer: FASE 4 — Optimización del AST
    CP->>Optimizer: optimize(ast, symbolTable)
    Optimizer->>Optimizer: Plegado de constantes
    Optimizer->>Optimizer: Eliminación de código muerto
    Optimizer->>Optimizer: Simplificación de expresiones
    Optimizer-->>CP: OptimizationResult(optimizedAST, metrics)

    Note over CP,Gen: FASE 5 — Generación de Código C
    CP->>Gen: generate(nodes, connections, symbolTable, optimizedAST)
    Gen->>Gen: Emite directivas #include
    Gen->>Gen: Genera declaraciones de variables globales
    Gen->>Gen: Genera función main()
    Gen->>Gen: Traduce cada nodo del AST a sentencias C
    Gen->>Gen: Genera estructuras de control (if/else, while, for)
    Gen-->>CP: CodeGenerationResult(code, metrics)

    CP->>CP: Calcula métricas finales de compilación
    CP-->>ES: CompilationResult(success: true, generatedCode, symbolTable, metrics)

    ES->>ES: Actualiza panel lateral con código C generado
    ES->>CRD: Muestra CompilerResultsDialog(result)
    CRD-->>Usuario: Presenta código C, métricas, tabla de símbolos y reporte
```

---

## DS-CU07: Exportar Proyecto Completo

Describe el flujo de exportación del diagrama como imagen (PNG/JPG), incluyendo la solicitud de permisos de almacenamiento, la captura del canvas y el guardado del archivo.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant ES as EditorScreen
    participant PM as PopupMenuButton
    participant DES as DiagramExportService
    participant PH as PermissionHandler
    participant Canvas as RenderRepaintBoundary
    participant SG as SaverGallery
    participant FS as FileSystem

    Usuario->>ES: Presiona icono de exportación en AppBar
    ES->>PM: Despliega menú de opciones de exportación
    PM-->>Usuario: Muestra opciones: "Exportar como PNG", "Exportar como JPG"

    Usuario->>PM: Selecciona formato de exportación
    PM->>ES: onSelected(formato)

    ES->>ES: Verifica que nodes[] no esté vacío

    alt Diagrama vacío
        ES-->>Usuario: Muestra SnackBar "No hay nodos para exportar"
    else Diagrama con contenido
        ES->>ES: Muestra diálogo de progreso (CircularProgressIndicator)

        ES->>DES: exportDiagramToPNG(canvasKey, diagramName)
        Note right of DES: O exportDiagramToJPG según selección

        DES->>PH: _requestStoragePermission()
        PH->>PH: Verifica versión de Android SDK

        alt SDK >= 33 (Android 13+)
            PH->>PH: Solicita Permission.photos
        else SDK < 33
            PH->>PH: Solicita Permission.storage
        end

        alt Permisos denegados
            PH-->>DES: hasPermission = false
            DES-->>ES: Lanza excepción "Permisos denegados"
            ES->>ES: Cierra diálogo de progreso
            ES-->>Usuario: Muestra SnackBar con error de permisos
        else Permisos concedidos
            PH-->>DES: hasPermission = true

            DES->>Canvas: canvasKey.currentContext.findRenderObject()
            Canvas->>Canvas: boundary.toImage(pixelRatio: 3.0)
            Canvas-->>DES: ui.Image

            DES->>DES: image.toByteData(format: png)
            DES->>DES: Genera nombre de archivo: {nombre}_{timestamp}.{ext}

            alt Formato PNG
                DES->>DES: pngBytes = byteData.buffer.asUint8List()
            else Formato JPG
                DES->>DES: Convierte PNG a JPG con calidad configurable
            end

            DES->>SG: SaverGallery.saveImage(bytes, fileName, androidRelativePath)
            Note right of SG: Guarda en Pictures/FlowDiagramApp/

            alt Guardado exitoso
                SG-->>DES: result.isSuccess = true
                DES-->>ES: filePath (ruta del archivo guardado)
            else Error en galería
                SG-->>DES: result.isSuccess = false
                DES->>FS: _saveToAppDirectory(bytes, fileName)
                Note right of FS: Fallback: directorio interno de la app
                FS-->>DES: filePath alternativo
                DES-->>ES: filePath
            end

            ES->>ES: Cierra diálogo de progreso
            ES-->>Usuario: Muestra diálogo de éxito con ruta del archivo exportado
        end
    end
```

---

## DS-CU08: Organizar Proyectos en Carpetas

Describe el flujo de organización de proyectos guardados mediante la interfaz de gestión de diagramas, incluyendo la visualización categorizada por pestañas, la carga, eliminación y navegación entre proyectos.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant LDS as LoadDiagramScreen
    participant TC as TabController
    participant DB as DatabaseService
    participant SQLite as SQLite
    participant ES as EditorScreen

    Usuario->>LDS: Navega a pantalla de proyectos
    LDS->>LDS: initState(): inicializa TabController(tabs: 2)
    LDS->>DB: getAllDiagrams(userId: currentUserId)
    DB->>SQLite: SELECT * FROM diagrams WHERE is_template=0 AND user_id=?
    SQLite-->>DB: Lista de registros del usuario
    DB-->>LDS: List<SavedDiagram> diagramas

    LDS->>DB: getAllTemplates()
    DB->>SQLite: SELECT * FROM diagrams WHERE is_template=1
    SQLite-->>DB: Lista de plantillas predefinidas
    DB-->>LDS: List<SavedDiagram> plantillas

    LDS->>LDS: setState(diagrams, templates, isLoading: false)
    LDS-->>Usuario: Presenta interfaz con pestañas "Mis diagramas" y "Plantillas"

    Note over Usuario,LDS: Pestaña "Mis diagramas"

    alt Seleccionar diagrama existente
        Usuario->>LDS: Tap sobre diagrama en la lista
        LDS->>ES: Navigator.push(EditorScreen(initialDiagram: diagram))
        ES->>ES: Deserializa nodos y conexiones del diagrama
        ES-->>Usuario: Abre el editor con el diagrama cargado

    else Eliminar diagrama
        Usuario->>LDS: Presiona icono de eliminar en un diagrama
        LDS-->>Usuario: Muestra AlertDialog de confirmación
        Usuario->>LDS: Confirma eliminación
        LDS->>DB: deleteDiagram(diagram.id)
        DB->>SQLite: DELETE FROM diagrams WHERE id = ?
        SQLite-->>DB: Registros eliminados
        DB-->>LDS: Confirmación
        LDS->>LDS: setState(): remueve diagrama de la lista local
        LDS-->>Usuario: SnackBar "Diagrama eliminado"
    end

    Note over Usuario,LDS: Pestaña "Plantillas"

    Usuario->>TC: Cambia a pestaña "Plantillas"
    TC-->>LDS: Muestra vista de plantillas
    LDS-->>Usuario: Lista de plantillas predefinidas (solo lectura)

    Usuario->>LDS: Tap sobre plantilla
    LDS->>ES: Navigator.push(EditorScreen(initialDiagram: template))
    ES->>ES: Carga estructura de la plantilla como nuevo diagrama
    ES-->>Usuario: Abre el editor con la plantilla como base
```

---

## DS-CU09: Registrar Cuenta de Usuario

Describe el flujo de creación de una nueva cuenta de usuario mediante Firebase Authentication para habilitar la sincronización en la nube.

```mermaid
%%{init: {'theme': 'neutral'}}%%
sequenceDiagram
    actor Usuario
    participant RS as RegisterScreen
    participant AS as AuthService
    participant FA as FirebaseAuth
    participant FS as Firestore
    participant SP as SharedPreferences

    Usuario->>RS: Navega a pantalla de registro
    RS-->>Usuario: Presenta formulario (nombre, email, contraseña, confirmar contraseña)

    Usuario->>RS: Completa campos y presiona "Registrarse"
    RS->>RS: _formKey.currentState.validate()

    alt Validación local falla
        RS-->>Usuario: Muestra errores en campos (email inválido, contraseña corta, no coinciden)
    else Validación local exitosa
        RS->>RS: setState(isLoading: true)
        RS->>AS: registerWithEmailPassword(email, password, displayName, role)

        AS->>AS: Verifica conexión a internet

        alt Sin conexión a internet
            AS-->>RS: Lanza excepción "Se requiere conexión a internet"
            RS-->>Usuario: Muestra error de conectividad
        else Con conexión
            AS->>AS: checkIfEmailExists(email)

            alt Email ya registrado
                AS-->>RS: Lanza excepción "Email ya registrado"
                RS-->>Usuario: Muestra diálogo "¿Deseas iniciar sesión?"
            else Email disponible
                AS->>FA: createUserWithEmailAndPassword(email, password)
                FA-->>AS: UserCredential(user)

                AS->>FA: user.updateDisplayName(displayName)
                FA-->>AS: Confirmación

                AS->>FS: collection('users').doc(uid).set(userModel.toMap())
                Note right of FS: Almacena: uid, email, displayName,<br/>role, createdAt, lastLogin
                FS-->>AS: Documento creado

                AS->>SP: setString('cached_user', userJSON)
                SP-->>AS: Cache local guardado

                AS-->>RS: UserModel(uid, email, displayName, role)

                RS->>RS: setState(isLoading: false)
                RS-->>Usuario: Muestra "¡Cuenta creada exitosamente!"
                RS->>RS: Navega a LoadDiagramScreen
            end
        end
    end
```

---

## DE-CU06: Diagrama de Estados — Generar Código C

Representa los estados y transiciones del sistema durante el ciclo de vida completo de la generación de código: desde el inicio de la aplicación, la construcción del diagrama, la ejecución del pipeline de compilación fuente-a-fuente con sus cinco fases, hasta la obtención del código C generado o la notificación de errores.

```mermaid
%%{init: {'theme': 'neutral'}}%%
stateDiagram-v2
    [*] --> Inactivo

    state "Aplicacion Inactiva" as Inactivo
    state "Editor Activo" as Editor
    state "Diagrama en Construccion" as Construccion
    state "Diagrama Listo" as Listo
    state "Validacion Estructural" as Validacion
    state "Pipeline de Compilacion" as Pipeline {
        state "Fase 1: Analisis Lexico" as F1
        state "Fase 2: Analisis Sintactico" as F2
        state "Fase 3: Analisis Semantico" as F3
        state "Fase 4: Optimizacion AST" as F4
        state "Fase 5: Generacion de Codigo" as F5
        state "Error de Compilacion" as ErrorComp

        [*] --> F1

        F1 --> F2 : Tokens extraidos,<br/>tabla de simbolos inicial
        F1 --> ErrorComp : Errores lexicos fatales

        F2 --> F3 : AST construido (ProgramNode)
        F2 --> ErrorComp : Errores sintacticos fatales<br/>o AST invalido

        F3 --> F4 : Analisis aprobado,<br/>tabla de simbolos actualizada
        F3 --> ErrorComp : Errores semanticos detectados

        F4 --> F5 : AST optimizado<br/>(constantes plegadas,<br/>codigo muerto eliminado)

        F5 --> [*] : Codigo C generado
        F5 --> ErrorComp : Error en generacion
    }
    state "Compilacion Exitosa" as Exito
    state "Compilacion Fallida" as Fallida
    state "Codigo C Disponible" as CodigoC

    Inactivo --> Editor : Usuario abre la aplicacion<br/>y selecciona Nuevo Diagrama
    Inactivo --> Editor : Usuario carga diagrama<br/>guardado desde SQLite

    Editor --> Construccion : Canvas inicializado<br/>(nodes=[], connections=[])

    Construccion --> Construccion : Agrega nodo desde paleta
    Construccion --> Construccion : Establece conexion entre nodos
    Construccion --> Construccion : Edita propiedades de nodo
    Construccion --> Construccion : Elimina nodo o conexion
    Construccion --> Listo : Diagrama contiene<br/>camino inicio a fin

    Listo --> Construccion : Usuario modifica<br/>el diagrama
    Listo --> Validacion : Usuario solicita<br/>compilacion

    Validacion --> Pipeline : Validacion estructural aprobada<br/>(nodo inicio, nodo fin,<br/>conexiones validas)
    Validacion --> Fallida : Validacion estructural falla<br/>(sin inicio/fin,<br/>nodos desconectados)

    Pipeline --> Exito : Las 5 fases completadas<br/>sin errores
    Pipeline --> Fallida : Error fatal en<br/>alguna fase

    Exito --> CodigoC : Compilacion exitosa

    CodigoC --> CodigoC : Visualiza codigo en<br/>panel lateral
    CodigoC --> CodigoC : Consulta tabla de simbolos<br/>y metricas
    CodigoC --> Construccion : Usuario modifica<br/>el diagrama
    CodigoC --> Inactivo : Usuario cierra el proyecto

    Fallida --> Fallida : Presenta reporte de errores<br/>con fase y descripcion
    Fallida --> Construccion : Usuario corrige<br/>el diagrama
    Fallida --> Inactivo : Usuario cierra el proyecto
```

### Descripcion de los Estados

| Estado | Descripcion |
|---|---|
| **Aplicacion Inactiva** | Estado inicial. La aplicacion se encuentra en la pantalla de bienvenida o seleccion de proyectos. |
| **Editor Activo** | El `EditorScreen` se ha cargado con un canvas vacio o con un diagrama existente desde SQLite. |
| **Diagrama en Construccion** | El usuario esta agregando nodos, conexiones y configurando propiedades. Estado iterativo. |
| **Diagrama Listo** | El diagrama contiene al menos un camino completo de inicio a fin y puede ser compilado. |
| **Validacion Estructural** | `DiagramValidator` verifica la presencia de nodos inicio/fin, conexiones validas y conformidad ISO 5807. |
| **Fase 1: Analisis Lexico** | `LexicalAnalyzer` recorre cada nodo, extrae tokens y construye la tabla de simbolos inicial. |
| **Fase 2: Analisis Sintactico** | `SyntaxAnalyzer` parsea los tokens y construye el Arbol de Sintaxis Abstracta (`ProgramNode`). |
| **Fase 3: Analisis Semantico** | `SemanticAnalyzer` valida tipos de datos, declaracion/uso de variables y compatibilidad de expresiones. |
| **Fase 4: Optimizacion AST** | `CodeOptimizer` aplica plegado de constantes, eliminacion de codigo muerto y simplificacion de expresiones. |
| **Fase 5: Generacion de Codigo** | `AdvancedCodeGenerator` traduce el AST optimizado a codigo fuente en lenguaje C. |
| **Error de Compilacion** | Subestado dentro del pipeline. Se recopilan errores de la fase que fallo. |
| **Compilacion Exitosa** | `CompilationResult(success: true)`. El pipeline completo las 5 fases sin errores criticos. |
| **Compilacion Fallida** | `CompilationResult(success: false)`. Se presenta el reporte con los errores, la fase donde ocurrieron y las metricas parciales. |
| **Codigo C Disponible** | El codigo C generado esta disponible para visualizacion en el panel lateral, consulta de metricas y exportacion. |

### Transiciones Clave del Pipeline

| Transicion | Condicion de Guarda | Datos Producidos |
|---|---|---|
| F1 a F2 | `!errors.hasFatalErrors` | `DiagramLexicalResult`: tokens, `SymbolTable` inicial |
| F2 a F3 | `!errors.hasFatalErrors && syntaxResult.isValid` | `SyntaxAnalysisResult`: AST (`ProgramNode`), statements |
| F3 a F4 | `semanticResult.errors.isEmpty` | `SemanticAnalysisResult`: `SymbolTable` con tipos y scopes verificados |
| F4 a F5 | Siempre (optimizacion no bloquea) | `OptimizationResult`: AST optimizado, metricas de reduccion |
| F5 a Exito | `!errors.hasErrors && generatedCode != null` | `CodeGenerationResult`: codigo C, lineas de codigo, variables utilizadas |
| Cualquier fase a Error | Se detectan errores fatales | `CompilerErrorCollection` con fase, codigo y severidad |

---

## Notas sobre los Diagramas

### Componentes del Sistema Referenciados

| Componente | Archivo Fuente | Descripción |
|---|---|---|
| `EditorScreen` | `lib/screens/editor_screen.dart` | Pantalla principal del editor visual |
| `RegisterScreen` | `lib/screens/register_screen.dart` | Pantalla de registro de usuario |
| `WelcomeScreen` | `lib/screens/welcome_screen.dart` | Pantalla de bienvenida/inicio |
| `FlowDiagramCanvas` | `lib/widgets/flow_diagram_canvas_final.dart` | Canvas interactivo para dibujar diagramas |
| `NodePalette` | `lib/widgets/node_palette.dart` | Paleta de selección de nodos |
| `SaveDiagramDialog` | `lib/widgets/save_diagram_dialog.dart` | Diálogo para guardar proyectos |
| `ValidationResultDialog` | `lib/widgets/validation_result_dialog.dart` | Diálogo de resultados de validación |
| `CompilerResultsDialog` | `lib/widgets/compiler_results_dialog.dart` | Diálogo de resultados de compilación |
| `DiagramValidator` | `lib/models/diagram_validator.dart` | Motor de validación estructural |
| `ISO5807ConnectionRules` | `lib/models/diagram_validator.dart` | Reglas de conexión ISO 5807 |
| `DiagramNode` | `lib/models/diagram_node.dart` | Modelo de datos de un nodo |
| `CodeGenerator` | `lib/models/code_generator.dart` | Generador de código básico |
| `CompilerPipeline` | `lib/compiler/compiler_pipeline.dart` | Orquestador del pipeline de compilación |
| `LexicalAnalyzer` | `lib/compiler/lexical_analyzer.dart` | Fase 1: Análisis léxico |
| `SyntaxAnalyzer` | `lib/compiler/syntax_analyzer.dart` | Fase 2: Análisis sintáctico |
| `SemanticAnalyzer` | `lib/compiler/semantic_analyzer.dart` | Fase 3: Análisis semántico |
| `CodeOptimizer` | `lib/compiler/code_optimizer.dart` | Fase 4: Optimización del AST |
| `AdvancedCodeGenerator` | `lib/compiler/code_generator_advanced.dart` | Fase 5: Generación de código C |
| `SymbolTable` | `lib/compiler/symbol_table.dart` | Tabla de símbolos del compilador |
| `NodeEditorDialog` | `lib/widgets/node_editor_dialog.dart` | Router de diálogos de edición por tipo de nodo |
| `ProcessNodeDialog` | `lib/widgets/process_node_dialog.dart` | Diálogo de edición para nodos de proceso y variable |
| `DecisionNodeDialog` | `lib/widgets/decision_node_dialog.dart` | Diálogo de edición para nodos de decisión |
| `DataNodeDialog` | `lib/widgets/data_node_dialog.dart` | Diálogo de edición para nodos de entrada/salida |
| `PreparationNodeDialog` | `lib/widgets/preparation_node_dialog.dart` | Diálogo de edición para nodos de preparación |
| `SubprocessNodeDialog` | `lib/widgets/subprocess_node_dialog.dart` | Diálogo de edición para nodos de subproceso |
| `NodeDialogResult` | `lib/models/node_dialog_result.dart` | Resultado de edición con soporte para generación de estructuras |
| `DiagramExportService` | `lib/services/diagram_export_service.dart` | Servicio de exportación de diagramas a PNG/JPG |
| `LoadDiagramScreen` | `lib/screens/load_diagram_screen.dart` | Pantalla de gestión y organización de proyectos |
| `DatabaseService` | `lib/services/database_service.dart` | Servicio de persistencia SQLite |
| `AuthService` | `lib/services/auth_service.dart` | Servicio de autenticación Firebase |

### Convención de Renderizado

Estos diagramas utilizan la sintaxis **Mermaid** para renderizado automático. Para obtener imágenes en blanco y negro con aspecto profesional:

1. **Mermaid Live Editor** ([mermaid.live](https://mermaid.live)): Pegar cada bloque de código Mermaid, seleccionar tema `default` o `neutral`, y exportar a PNG/SVG.
2. **VS Code**: Instalar la extensión *Markdown Preview Mermaid Support* para previsualizar directamente en el editor.
3. **Exportación a PDF**: Utilizar Pandoc con filtro mermaid-filter o la extensión *Markdown PDF* de VS Code para generar documentos PDF con los diagramas renderizados.
4. **Tema recomendado para reporte formal**: Usar `%%{init: {'theme': 'neutral'}}%%` al inicio de cada bloque Mermaid para forzar escala de grises.
