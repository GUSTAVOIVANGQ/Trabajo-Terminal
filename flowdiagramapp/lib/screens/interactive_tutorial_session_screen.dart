import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../interactive_tutorials/interactive_tutorials.dart';
import '../models/saved_diagram.dart';
import '../services/tutorial_event_service.dart';
import 'editor_screen.dart';

class InteractiveTutorialSessionScreen extends StatefulWidget {
  const InteractiveTutorialSessionScreen({
    super.key,
    required this.provider,
    required this.initialDiagram,
  });

  final InteractiveTutorialProvider provider;
  final SavedDiagram initialDiagram;

  @override
  State<InteractiveTutorialSessionScreen> createState() =>
      _InteractiveTutorialSessionScreenState();
}

class _InteractiveTutorialSessionScreenState
    extends State<InteractiveTutorialSessionScreen> {
  StreamSubscription<TutorialEditorSignal>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _eventSubscription = TutorialEventService().events.listen(_onEditorEvent);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onEditorEvent(TutorialEditorSignal signal) async {
    final provider = widget.provider;
    final advanced = await provider.tryAdvanceForSignal(signal);
    if (!advanced || !mounted) {
      return;
    }

    final currentStep = provider.currentStep;
    if (currentStep == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paso completado: ${currentStep.title}'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InteractiveTutorialProvider>.value(
      value: widget.provider,
      child: Scaffold(
        body: Stack(
          children: [
            EditorScreen(initialDiagram: widget.initialDiagram),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x22000000),
                        Color(0x09000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: _InteractiveTutorialHeader(),
              ),
            ),
            const SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _InteractiveTutorialMissionPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveTutorialHeader extends StatelessWidget {
  const _InteractiveTutorialHeader();

  @override
  Widget build(BuildContext context) {
    return Consumer<InteractiveTutorialProvider>(
      builder: (context, provider, _) {
        final tutorial = provider.activeTutorial;
        final step = provider.currentStep;

        if (tutorial == null || step == null) {
          return const SizedBox.shrink();
        }

        final progress =
            ((provider.currentStepIndex + 1) / tutorial.steps.length)
                .clamp(0, 1)
                .toDouble();

        return Container(
          width: 680,
          margin: const EdgeInsets.all(12),
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 34,
                        height: 34,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                            ),
                            const Center(
                              child: Icon(Icons.play_lesson, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tutorial.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        '${provider.currentStepIndex + 1}/${tutorial.steps.length}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progreso ${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 240.ms)
            .slideY(begin: -0.12, end: 0, duration: 240.ms);
      },
    );
  }
}

class _InteractiveTutorialMissionPanel extends StatelessWidget {
  const _InteractiveTutorialMissionPanel();

  IconData _iconForStepType(InteractiveTutorialStepType type) {
    switch (type) {
      case InteractiveTutorialStepType.info:
        return Icons.info_outline;
      case InteractiveTutorialStepType.highlight:
        return Icons.center_focus_strong;
      case InteractiveTutorialStepType.action:
        return Icons.touch_app;
      case InteractiveTutorialStepType.validation:
        return Icons.verified_outlined;
      case InteractiveTutorialStepType.completion:
        return Icons.task_alt;
    }
  }

  String _stepTypeLabel(InteractiveTutorialStepType type) {
    switch (type) {
      case InteractiveTutorialStepType.info:
        return 'Informacion tecnica';
      case InteractiveTutorialStepType.highlight:
        return 'Foco de inspeccion';
      case InteractiveTutorialStepType.action:
        return 'Ejecucion requerida';
      case InteractiveTutorialStepType.validation:
        return 'Validacion estructural';
      case InteractiveTutorialStepType.completion:
        return 'Cierre de sesion';
    }
  }

  String _hintForStep(InteractiveTutorialStep step) {
    switch (step.requiredAction) {
      case InteractiveTutorialActionType.editNode:
        return 'Selecciona un nodo y usa el boton Editar en la barra superior.';
      case InteractiveTutorialActionType.runValidation:
        return 'Ejecuta Validar diagrama en la barra superior para revisar consistencia.';
      case InteractiveTutorialActionType.viewGeneratedCode:
        return 'Abre el menu Codigo y ejecuta el generador para inspeccionar salida C.';
      case InteractiveTutorialActionType.saveDiagram:
        return 'Usa Guardar diagrama y confirma nombre y descripcion.';
      case InteractiveTutorialActionType.inspectNode:
        return 'Toca el nodo objetivo para revisar su configuracion activa.';
      case InteractiveTutorialActionType.connectNodes:
        return 'Activa modo conexion y enlaza origen y destino en orden.';
      case InteractiveTutorialActionType.openTemplate:
      case null:
        return 'Continua con el flujo guiado y revisa el estado del paso.';
    }
  }

  String _requiredActionLabel(InteractiveTutorialActionType? action) {
    switch (action) {
      case InteractiveTutorialActionType.inspectNode:
        return 'Inspeccionar nodo objetivo';
      case InteractiveTutorialActionType.editNode:
        return 'Editar nodo seleccionado';
      case InteractiveTutorialActionType.connectNodes:
        return 'Conectar nodos';
      case InteractiveTutorialActionType.runValidation:
        return 'Ejecutar validacion';
      case InteractiveTutorialActionType.viewGeneratedCode:
        return 'Generar y revisar C';
      case InteractiveTutorialActionType.saveDiagram:
        return 'Guardar diagrama';
      case InteractiveTutorialActionType.openTemplate:
      case null:
        return 'Navegacion guiada';
    }
  }

  Widget _buildStepTrack(
    BuildContext context,
    InteractiveTutorialDefinition tutorial,
    int currentStepIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(tutorial.steps.length, (index) {
        final isCurrent = index == currentStepIndex;
        final isCompleted = index < currentStepIndex;

        final backgroundColor = isCurrent
            ? colorScheme.primaryContainer
            : isCompleted
                ? colorScheme.secondaryContainer
                : colorScheme.surfaceContainerHighest;

        final foregroundColor = isCurrent
            ? colorScheme.onPrimaryContainer
            : isCompleted
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant;

        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, size: 16, color: foregroundColor)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InteractiveTutorialProvider>(
      builder: (context, provider, _) {
        final tutorial = provider.activeTutorial;
        final step = provider.currentStep;

        if (tutorial == null || step == null) {
          return const SizedBox.shrink();
        }

        final waitingEvent = provider.isCurrentStepEventDriven;
        final strictControl = provider.isCurrentStepStrictControl;
        final isLastStep =
            provider.currentStepIndex == tutorial.steps.length - 1;
        final actionLabel = _requiredActionLabel(step.requiredAction);

        return Container(
          width: 760,
          margin: const EdgeInsets.all(12),
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_iconForStepType(step.type)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        child: Text(
                          _stepTypeLabel(step.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.instruction,
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  _buildStepTrack(
                    context,
                    tutorial,
                    provider.currentStepIndex,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.55),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Accion esperada: $actionLabel',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: waitingEvent
                          ? Colors.amber.withValues(alpha: 0.16)
                          : Colors.green.withValues(alpha: 0.14),
                    ),
                    child: Text(
                      waitingEvent
                          ? 'Estado: esperando accion en el editor.'
                          : 'Estado: paso listo para avance manual.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (strictControl)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.44),
                        ),
                        child: Text(
                          'Control estricto activo: solo la accion requerida habilita el avance.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: provider.currentStepIndex > 0
                            ? () {
                                provider.previousStep();
                              }
                            : null,
                        child: const Text('Anterior'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pista tecnica'),
                              content: Text(_hintForStep(step)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.lightbulb_outline),
                        label: const Text('Pista'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: waitingEvent
                            ? null
                            : () {
                                provider.nextStep();
                              },
                        child: Text(
                          isLastStep ? 'Finalizar' : 'Siguiente',
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cerrar sesion'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 260.ms)
            .slideY(begin: 0.2, end: 0, duration: 260.ms);
      },
    );
  }
}
