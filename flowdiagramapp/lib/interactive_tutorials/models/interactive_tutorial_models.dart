enum InteractiveTutorialStepType {
  info,
  highlight,
  action,
  validation,
  completion,
}

enum InteractiveTutorialActionType {
  openTemplate,
  inspectNode,
  editNode,
  connectNodes,
  runValidation,
  viewGeneratedCode,
  saveDiagram,
}

enum InteractiveTutorialLockPolicy {
  none,
  strict,
}

enum InteractiveTutorialLevel {
  basic,
  intermediate,
  advanced,
}

class InteractiveTutorialStep {
  final String id;
  final String title;
  final String instruction;
  final InteractiveTutorialStepType type;
  final InteractiveTutorialActionType? requiredAction;
  final String? targetElementId;
  final bool canSkip;
  final InteractiveTutorialLockPolicy lockPolicy;
  final List<InteractiveTutorialActionType> allowedActions;
  final bool requireTargetMatch;

  const InteractiveTutorialStep({
    required this.id,
    required this.title,
    required this.instruction,
    required this.type,
    this.requiredAction,
    this.targetElementId,
    this.canSkip = false,
    this.lockPolicy = InteractiveTutorialLockPolicy.none,
    this.allowedActions = const [],
    this.requireTargetMatch = false,
  });
}

class InteractiveTutorialDefinition {
  final String id;
  final String title;
  final String summary;
  final String templateName;
  final InteractiveTutorialLevel level;
  final int estimatedMinutes;
  final bool enabled;
  final List<InteractiveTutorialStep> steps;

  const InteractiveTutorialDefinition({
    required this.id,
    required this.title,
    required this.summary,
    required this.templateName,
    required this.level,
    required this.estimatedMinutes,
    required this.steps,
    this.enabled = true,
  });
}

extension InteractiveTutorialLevelUi on InteractiveTutorialLevel {
  String get label {
    switch (this) {
      case InteractiveTutorialLevel.basic:
        return 'Basico';
      case InteractiveTutorialLevel.intermediate:
        return 'Intermedio';
      case InteractiveTutorialLevel.advanced:
        return 'Avanzado';
    }
  }
}

class InteractiveTutorialProgress {
  final String tutorialId;
  final int currentStepIndex;
  final bool completed;
  final DateTime updatedAt;

  const InteractiveTutorialProgress({
    required this.tutorialId,
    required this.currentStepIndex,
    required this.completed,
    required this.updatedAt,
  });

  InteractiveTutorialProgress copyWith({
    int? currentStepIndex,
    bool? completed,
    DateTime? updatedAt,
  }) {
    return InteractiveTutorialProgress(
      tutorialId: tutorialId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, String> toStorageMap() {
    return {
      'tutorialId': tutorialId,
      'currentStepIndex': currentStepIndex.toString(),
      'completed': completed.toString(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static InteractiveTutorialProgress fromStorageMap(
    Map<String, String> values,
  ) {
    final rawStep = int.tryParse(values['currentStepIndex'] ?? '0') ?? 0;
    final rawCompleted =
        (values['completed'] ?? 'false').toLowerCase() == 'true';
    final rawUpdatedAt =
        DateTime.tryParse(values['updatedAt'] ?? '') ?? DateTime.now();

    return InteractiveTutorialProgress(
      tutorialId: values['tutorialId'] ?? '',
      currentStepIndex: rawStep,
      completed: rawCompleted,
      updatedAt: rawUpdatedAt,
    );
  }
}
