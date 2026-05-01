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
          ),
          InteractiveTutorialStep(
            id: 'inspect_end',
            title: 'Inspeccion de nodo Fin',
            instruction:
                'Selecciona el nodo Fin para completar la verificacion de nodos terminales del flujo.',
            type: InteractiveTutorialStepType.highlight,
            requiredAction: InteractiveTutorialActionType.inspectNode,
            targetElementId: 'node_end',
          ),
          InteractiveTutorialStep(
            id: 'inspect_output',
            title: 'Edicion de nodo de salida',
            instruction:
                'Edita el nodo Dato y actualiza el texto de salida para confirmar el ciclo de edicion.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.editNode,
            targetElementId: 'node_data_output',
          ),
          InteractiveTutorialStep(
            id: 'run_validation',
            title: 'Validación estructural',
            instruction:
                'Ejecuta el validador para verificar consistencia estructural del diagrama.',
            type: InteractiveTutorialStepType.validation,
            requiredAction: InteractiveTutorialActionType.runValidation,
          ),
          InteractiveTutorialStep(
            id: 'view_c_code',
            title: 'Inspeccion de salida en C',
            instruction:
                'Abre la vista de codigo y revisa la salida C generada por el compilador fuente-a-fuente.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.viewGeneratedCode,
          ),
          InteractiveTutorialStep(
            id: 'save_diagram',
            title: 'Persistencia local',
            instruction:
                'Guarda el diagrama para validar la persistencia local mediante SQLite.',
            type: InteractiveTutorialStepType.action,
            requiredAction: InteractiveTutorialActionType.saveDiagram,
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
    ];
  }
}
