import '../models/interactive_tutorial_models.dart';

class InteractiveTutorialCatalog {
  const InteractiveTutorialCatalog();

  List<InteractiveTutorialDefinition> getAllTutorials() {
    return const [
      InteractiveTutorialDefinition(
        id: 'interactive_01_hola_mundo',
        title: 'Ruta Guiada: Diagrama Hola Mundo',
        summary:
            'Sesion operativa controlada para inspeccionar nodos, ejecutar validacion, generar C y persistir el diagrama.',
        templateName: '01. Hola Mundo',
        level: InteractiveTutorialLevel.basic,
        estimatedMinutes: 6,
        steps: [
          InteractiveTutorialStep(
            id: 'intro',
            title: 'Preparacion de entorno',
            instruction:
                'La plantilla 01. Hola Mundo ya fue cargada en el editor. Verifica nodos y conexiones iniciales.',
            type: InteractiveTutorialStepType.info,
          ),
          InteractiveTutorialStep(
            id: 'inspect_start',
            title: 'Inspeccion de nodo Inicio',
            instruction:
                'Selecciona el nodo Inicio para revisar su configuracion base y su posicion en el flujo.',
            type: InteractiveTutorialStepType.highlight,
            requiredAction: InteractiveTutorialActionType.inspectNode,
            targetElementId: 'node_start',
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
            ],
            requireTargetMatch: true,
          ),
          InteractiveTutorialStep(
            id: 'inspect_end',
            title: 'Inspeccion de nodo Fin',
            instruction:
                'Selecciona el nodo Fin para completar la verificacion de nodos terminales del flujo.',
            type: InteractiveTutorialStepType.highlight,
            requiredAction: InteractiveTutorialActionType.inspectNode,
            targetElementId: 'node_end',
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
            ],
            requireTargetMatch: true,
          ),
          InteractiveTutorialStep(
            id: 'inspect_output',
            title: 'Edicion de nodo de salida',
            instruction:
                'Edita el nodo Dato y actualiza el texto de salida para confirmar el ciclo de edicion.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.editNode,
            targetElementId: 'node_data_output',
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
              InteractiveTutorialActionType.editNode,
            ],
            requireTargetMatch: true,
          ),
          InteractiveTutorialStep(
            id: 'run_validation',
            title: 'Validación estructural',
            instruction:
                'Ejecuta el validador para verificar consistencia estructural del diagrama.',
            type: InteractiveTutorialStepType.validation,
            requiredAction: InteractiveTutorialActionType.runValidation,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.runValidation,
            ],
          ),
          InteractiveTutorialStep(
            id: 'view_c_code',
            title: 'Inspeccion de salida en C',
            instruction:
                'Abre la vista de codigo y revisa la salida C generada por el compilador fuente-a-fuente.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.viewGeneratedCode,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.viewGeneratedCode,
            ],
          ),
          InteractiveTutorialStep(
            id: 'save_diagram',
            title: 'Persistencia local',
            instruction:
                'Guarda el diagrama para validar la persistencia local mediante SQLite.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.saveDiagram,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.saveDiagram,
            ],
          ),
          InteractiveTutorialStep(
            id: 'complete',
            title: 'Cierre de sesion guiada',
            instruction:
                'La ruta finalizo. Puedes reiniciar esta sesion o ejecutar otra ruta con mayor complejidad.',
            type: InteractiveTutorialStepType.completion,
            canSkip: true,
          ),
        ],
      ),
      InteractiveTutorialDefinition(
        id: 'interactive_02_par_impar',
        title: 'Ruta Guiada: Par o Impar',
        summary:
            'Sesion intermedia para revisar decision, ejecutar una conexion de rama y validar salida condicional.',
        templateName: '05. Par o Impar',
        level: InteractiveTutorialLevel.intermediate,
        estimatedMinutes: 9,
        steps: [
          InteractiveTutorialStep(
            id: 'intro',
            title: 'Preparacion de escenario',
            instruction:
                'La plantilla Par o Impar ya esta cargada. Revisa su flujo general y localiza el nodo de decision.',
            type: InteractiveTutorialStepType.info,
          ),
          InteractiveTutorialStep(
            id: 'inspect_start',
            title: 'Inspeccion de nodo Inicio',
            instruction:
                'Selecciona el nodo Inicio para verificar el punto de entrada del flujo.',
            type: InteractiveTutorialStepType.highlight,
            requiredAction: InteractiveTutorialActionType.inspectNode,
            targetElementId: 'node_start',
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
            ],
            requireTargetMatch: true,
          ),
          InteractiveTutorialStep(
            id: 'edit_decision',
            title: 'Ajuste de condicion',
            instruction:
                'Edita el nodo de decision para revisar la condicion modulo aplicada al valor de entrada.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.editNode,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
              InteractiveTutorialActionType.editNode,
            ],
          ),
          InteractiveTutorialStep(
            id: 'connect_branch',
            title: 'Conexion de rama',
            instruction:
                'Activa el modo conexion y completa una conexion valida entre nodos para confirmar estructura de rama.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.connectNodes,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.connectNodes,
            ],
          ),
          InteractiveTutorialStep(
            id: 'run_validation',
            title: 'Validación estructural',
            instruction:
                'Ejecuta validacion para revisar consistencia de nodos y conexiones.',
            type: InteractiveTutorialStepType.validation,
            requiredAction: InteractiveTutorialActionType.runValidation,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.runValidation,
            ],
          ),
          InteractiveTutorialStep(
            id: 'view_c_code',
            title: 'Inspeccion de salida en C',
            instruction:
                'Genera y revisa el codigo C para confirmar la traduccion de la decision.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.viewGeneratedCode,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.viewGeneratedCode,
            ],
          ),
          InteractiveTutorialStep(
            id: 'save_diagram',
            title: 'Persistencia local',
            instruction:
                'Guarda la variante del diagrama para conservar los ajustes de la sesion.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.saveDiagram,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.saveDiagram,
            ],
          ),
          InteractiveTutorialStep(
            id: 'complete',
            title: 'Cierre de sesion guiada',
            instruction:
                'Ruta intermedia completada. Puedes avanzar a una ruta avanzada de estructuras iterativas.',
            type: InteractiveTutorialStepType.completion,
            canSkip: true,
          ),
        ],
      ),
      InteractiveTutorialDefinition(
        id: 'interactive_03_burbuja',
        title: 'Ruta Guiada: Ordenamiento Burbuja',
        summary:
            'Sesion avanzada para verificar un flujo iterativo con multiples procesos y validacion final del resultado.',
        templateName: '15. Ordenamiento Burbuja',
        level: InteractiveTutorialLevel.advanced,
        estimatedMinutes: 12,
        steps: [
          InteractiveTutorialStep(
            id: 'intro',
            title: 'Preparacion de escenario',
            instruction:
                'La plantilla de ordenamiento burbuja ya esta cargada. Identifica el flujo de iteraciones y salida final.',
            type: InteractiveTutorialStepType.info,
          ),
          InteractiveTutorialStep(
            id: 'inspect_start',
            title: 'Inspeccion de nodo Inicio',
            instruction:
                'Selecciona el nodo Inicio para confirmar la entrada del algoritmo.',
            type: InteractiveTutorialStepType.highlight,
            requiredAction: InteractiveTutorialActionType.inspectNode,
            targetElementId: 'node_start',
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
            ],
            requireTargetMatch: true,
          ),
          InteractiveTutorialStep(
            id: 'edit_process',
            title: 'Revision de proceso iterativo',
            instruction:
                'Edita un nodo de proceso para revisar una operacion del ordenamiento.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.editNode,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.inspectNode,
              InteractiveTutorialActionType.editNode,
            ],
          ),
          InteractiveTutorialStep(
            id: 'connect_nodes',
            title: 'Refuerzo de conexion',
            instruction:
                'Crea una conexion valida para reforzar la estructura de control del flujo.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.connectNodes,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.connectNodes,
            ],
          ),
          InteractiveTutorialStep(
            id: 'run_validation',
            title: 'Validación estructural',
            instruction:
                'Ejecuta validacion para revisar consistencia antes de generar salida.',
            type: InteractiveTutorialStepType.validation,
            requiredAction: InteractiveTutorialActionType.runValidation,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.runValidation,
            ],
          ),
          InteractiveTutorialStep(
            id: 'view_c_code',
            title: 'Inspeccion de salida en C',
            instruction:
                'Genera codigo C y revisa la representacion final del algoritmo de ordenamiento.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.viewGeneratedCode,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.viewGeneratedCode,
            ],
          ),
          InteractiveTutorialStep(
            id: 'save_diagram',
            title: 'Persistencia local',
            instruction:
                'Guarda el diagrama para conservar esta sesion avanzada.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.saveDiagram,
            lockPolicy: InteractiveTutorialLockPolicy.strict,
            allowedActions: [
              InteractiveTutorialActionType.saveDiagram,
            ],
          ),
          InteractiveTutorialStep(
            id: 'complete',
            title: 'Cierre de sesion guiada',
            instruction:
                'Ruta avanzada completada. El flujo ya cubre inspeccion, ajuste, validacion y persistencia.',
            type: InteractiveTutorialStepType.completion,
            canSkip: true,
          ),
        ],
      ),
    ];
  }
}
