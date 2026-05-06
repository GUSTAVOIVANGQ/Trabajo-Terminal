// auto_tutorial_controller.dart
// Orquestador del tutorial automático con tutorial_coach_mark.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'auto_tutorial_models.dart';

typedef OnAddNodeCallback = Future<void> Function({
  required AutoTutorialNodeType type,
  required String nodeId,
  required Offset position,
  String? content,
});

typedef OnConnectNodesCallback = Future<void> Function({
  required String sourceId,
  required String targetId,
});

typedef OnRunValidationCallback = Future<void> Function();
typedef OnViewGeneratedCodeCallback = Future<void> Function();
typedef OnSaveDiagramCallback = Future<void> Function();
typedef OnEditNodeContentCallback = Future<void> Function({
  required String nodeId,
  required String content,
});

class AutoTutorialController extends ChangeNotifier {
  AutoTutorialController({
    required this.onAddNode,
    required this.onConnectNodes,
    required this.onRunValidation,
    required this.onViewGeneratedCode,
    required this.onSaveDiagram,
    this.onEditNodeContent,
  });

  final OnAddNodeCallback onAddNode;
  final OnConnectNodesCallback onConnectNodes;
  final OnRunValidationCallback onRunValidation;
  final OnViewGeneratedCodeCallback onViewGeneratedCode;
  final OnSaveDiagramCallback onSaveDiagram;
  final OnEditNodeContentCallback? onEditNodeContent;

  AutoTutorialState _state = const AutoTutorialState();
  AutoTutorialState get state => _state;

  TutorialCoachMark? _coachMark;
  Timer? _actionTimer;
  Timer? _autoAdvanceTimer;
  bool _disposed = false;

  /// Tracks the current step index internally for auto-advance logic.
  int _currentInternalStep = 0;

  Future<void> startTutorial(
    AutoTutorialDefinition definition,
    BuildContext context,
  ) async {
    _cancelPendingTimers();
    _currentInternalStep = 0;
    _state = AutoTutorialState(
      activeTutorial: definition,
      currentStepIndex: 0,
      playState: AutoTutorialPlayState.playing,
    );
    notifyListeners();

    final targets = _buildTargets(definition, context);

    _coachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF1A1A2E),
      opacityShadow: 0.72,
      textSkip: 'Saltar tutorial',
      paddingFocus: 10,
      focusAnimationDuration: const Duration(milliseconds: 350),
      unFocusAnimationDuration: const Duration(milliseconds: 250),
      onFinish: _onFinish,
      onSkip: () {
        _onSkip();
        return true;
      },
      onClickTarget: (target) => _onUserInteraction(),
      onClickOverlay: (target) => _onUserInteraction(),
    )..show(context: context);

    // Schedule the action for the first step after the coach mark shows
    _scheduleStepAction(0);
  }

  void pause() {
    if (_state.playState != AutoTutorialPlayState.playing) return;
    _cancelPendingTimers();
    _state = _state.copyWith(playState: AutoTutorialPlayState.paused);
    notifyListeners();
  }

  void resume() {
    if (_state.playState != AutoTutorialPlayState.paused) return;
    _state = _state.copyWith(playState: AutoTutorialPlayState.playing);
    notifyListeners();
    _scheduleStepAction(_currentInternalStep);
  }

  void skipToNext() {
    _cancelPendingTimers();
    _advanceToNextStep();
  }

  void close() {
    _cancelPendingTimers();
    _coachMark?.skip();
    _resetState();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelPendingTimers();
    super.dispose();
  }

  List<TargetFocus> _buildTargets(
    AutoTutorialDefinition definition,
    BuildContext context,
  ) {
    final targets = <TargetFocus>[];
    for (var i = 0; i < definition.steps.length; i++) {
      final step = definition.steps[i];
      final target = TargetFocus(
        identify: step.id,
        keyTarget: step.spotlightTarget,
        targetPosition: step.spotlightTarget == null
            ? TargetPosition(
                const Size(1, 1),
                _targetOffset(context, step),
              )
            : null,
        shape: ShapeLightFocus.Circle,
        radius: step.spotlightRadius,
        enableOverlayTab: true,
        enableTargetTab: true,
        contents: [
          TargetContent(
            align: _mapTooltipAlign(step.tooltipPosition),
            builder: (context, controller) {
              return _StepTooltip(
                title: step.title,
                description: step.description,
                stepIndex: i,
                totalSteps: definition.steps.length,
                onNext: () => skipToNext(),
                onPause: () {
                  if (_state.isPaused) {
                    resume();
                  } else {
                    pause();
                  }
                },
                isPaused: _state.isPaused,
              );
            },
          ),
        ],
      );
      targets.add(target);
    }
    return targets;
  }

  ContentAlign _mapTooltipAlign(AutoTooltipPosition position) {
    switch (position) {
      case AutoTooltipPosition.top:
        return ContentAlign.top;
      case AutoTooltipPosition.bottom:
        return ContentAlign.bottom;
      case AutoTooltipPosition.left:
        return ContentAlign.left;
      case AutoTooltipPosition.right:
        return ContentAlign.right;
    }
  }

  Offset _targetOffset(BuildContext context, AutoTutorialStep step) {
    final size = MediaQuery.of(context).size;
    return Offset(
      size.width * step.targetFractionX,
      size.height * step.targetFractionY,
    );
  }

  Offset _centerOfScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Offset(size.width / 2, size.height / 2);
  }

  /// Called when user taps on the target or overlay.
  /// Cancels any pending auto-advance and manually advances.
  void _onUserInteraction() {
    _cancelPendingTimers();
    _advanceToNextStep();
  }

  /// Advances to the next step: moves the coach mark and schedules the
  /// action for the new step.
  void _advanceToNextStep() {
    final tutorial = _state.activeTutorial;
    if (tutorial == null) return;

    final nextIndex = _currentInternalStep + 1;
    if (nextIndex >= tutorial.steps.length) {
      // We're at the last step, let coach mark finish naturally
      _coachMark?.next();
      return;
    }

    _currentInternalStep = nextIndex;
    _state = _state.copyWith(
      currentStepIndex: nextIndex,
      playState: AutoTutorialPlayState.playing,
    );
    notifyListeners();

    _coachMark?.next();

    // Schedule the action for the new step
    _scheduleStepAction(nextIndex);
  }

  /// Schedules the auto-action for the step at [stepIndex].
  /// After the action completes, schedules auto-advance to the next step.
  void _scheduleStepAction(int stepIndex) {
    final tutorial = _state.activeTutorial;
    if (tutorial == null || stepIndex >= tutorial.steps.length) return;
    if (_state.isPaused) return;

    final step = tutorial.steps[stepIndex];

    if (step.autoAction == AutoTutorialAutoAction.none) {
      // No action for this step — auto-advance after a brief viewing delay
      _autoAdvanceTimer = Timer(
        Duration(milliseconds: step.autoActionDelayMs + 1500),
        () {
          if (!_disposed && !_state.isPaused) {
            _advanceToNextStep();
          }
        },
      );
      return;
    }

    // Schedule the action after the specified delay
    _actionTimer = Timer(
      Duration(milliseconds: step.autoActionDelayMs),
      () async {
        if (_disposed || _state.isPaused) return;
        await _executeAction(step);

        // After executing the action, auto-advance to next step
        if (!_disposed && !_state.isPaused) {
          _autoAdvanceTimer = Timer(
            const Duration(milliseconds: 1200),
            () {
              if (!_disposed && !_state.isPaused) {
                _advanceToNextStep();
              }
            },
          );
        }
      },
    );
  }

  void _onFinish() {
    _state = _state.copyWith(playState: AutoTutorialPlayState.completed);
    notifyListeners();
    _resetState();
  }

  void _onSkip() {
    _cancelPendingTimers();
    _resetState();
  }

  // Kept for API compatibility but no longer needed as the primary trigger.
  void onStepShown(int stepIndex) {
    if (_disposed) return;
    _cancelPendingTimers();
    final tutorial = _state.activeTutorial;
    if (tutorial == null || stepIndex >= tutorial.steps.length) return;
    _currentInternalStep = stepIndex;
    _state = _state.copyWith(
      currentStepIndex: stepIndex,
      playState: AutoTutorialPlayState.playing,
    );
    notifyListeners();
    _scheduleStepAction(stepIndex);
  }

  Future<void> _executeAction(AutoTutorialStep step) async {
    if (_disposed || _state.isPaused) return;
    try {
      switch (step.autoAction) {
        case AutoTutorialAutoAction.none:
          break;
        case AutoTutorialAutoAction.addNode:
          if (step.nodeType != null &&
              step.nodeId != null &&
              step.nodePosition != null) {
            await onAddNode(
              type: step.nodeType!,
              nodeId: step.nodeId!,
              position: step.nodePosition!,
              content: step.nodeContent,
            );
          }
          break;
        case AutoTutorialAutoAction.connectNodes:
          if (step.sourceNodeId != null && step.targetNodeId != null) {
            await onConnectNodes(
              sourceId: step.sourceNodeId!,
              targetId: step.targetNodeId!,
            );
          }
          break;
        case AutoTutorialAutoAction.editNodeContent:
          if (step.nodeId != null && step.nodeContent != null) {
            await onEditNodeContent?.call(
              nodeId: step.nodeId!,
              content: step.nodeContent!,
            );
          }
          break;
        case AutoTutorialAutoAction.runValidation:
          await onRunValidation();
          break;
        case AutoTutorialAutoAction.viewGeneratedCode:
          await onViewGeneratedCode();
          break;
        case AutoTutorialAutoAction.saveDiagram:
          await onSaveDiagram();
          break;
      }
    } catch (_) {
      // La acción falló silenciosamente; el tutorial continúa.
    }
  }

  void _cancelPendingTimers() {
    _actionTimer?.cancel();
    _actionTimer = null;
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  void _resetState() {
    _state = const AutoTutorialState();
    _currentInternalStep = 0;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Widget tooltip del paso — ahora respeta el tema del sistema
// ---------------------------------------------------------------------------

class _StepTooltip extends StatelessWidget {
  const _StepTooltip({
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPause,
    required this.isPaused,
  });

  final String title;
  final String description;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPause;
  final bool isPaused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final borderColor = theme.colorScheme.primary.withOpacity(0.6);
    final shadowColor = theme.colorScheme.primary.withOpacity(0.25);
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final descColor = isDark
        ? Colors.white.withOpacity(0.75)
        : const Color(0xFF4B5563);
    final stepCountColor = isDark
        ? Colors.white.withOpacity(0.45)
        : const Color(0xFF9CA3AF);
    final accentColor = theme.colorScheme.primary;

    final progressFraction =
        totalSteps > 1 ? (stepIndex + 1) / totalSteps : 1.0;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 3,
              backgroundColor: isDark ? Colors.white12 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: descColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stepIndex + 1} / $totalSteps',
                style: TextStyle(
                  color: stepCountColor,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  _ControlButton(
                    icon: isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    onTap: onPause,
                    tooltip: isPaused ? 'Reanudar' : 'Pausar',
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
                    onTap: onNext,
                    tooltip: 'Siguiente',
                    highlighted: true,
                    accentColor: accentColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.highlighted = false,
    required this.accentColor,
    required this.isDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool highlighted;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = highlighted
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF374151));

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: highlighted
                ? accentColor
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra flotante de control durante el tutorial
// ---------------------------------------------------------------------------

class AutoTutorialControlBar extends StatelessWidget {
  const AutoTutorialControlBar({
    super.key,
    required this.controller,
  });

  final AutoTutorialController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (!state.isActive) return const SizedBox.shrink();

        final bgColor = isDark
            ? const Color(0xFF1E293B).withOpacity(0.95)
            : Colors.white.withOpacity(0.95);
        final borderColor = theme.colorScheme.primary.withOpacity(0.4);
        final textColor = isDark ? Colors.white70 : const Color(0xFF6B7280);
        final iconColor = isDark ? Colors.white : const Color(0xFF374151);
        final closeColor = isDark
            ? Colors.white.withOpacity(0.6)
            : const Color(0xFF9CA3AF);

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tutorial ${state.currentStepIndex + 1}/${state.totalSteps}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap:
                      state.isPaused ? controller.resume : controller.pause,
                  child: Icon(
                    state.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.skipToNext,
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.close,
                  child: Icon(
                    Icons.close_rounded,
                    color: closeColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
