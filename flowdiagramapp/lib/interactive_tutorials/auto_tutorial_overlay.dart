// auto_tutorial_overlay.dart
// Pantalla del catálogo de tutoriales animados.
// Usa onStart callback para navegar al editor desde fuera.
// Respeta el tema claro/oscuro del sistema.

import 'package:flutter/material.dart';
import 'auto_tutorial_models.dart';
import 'auto_tutorial_script.dart';

// ---------------------------------------------------------------------------
// Pantalla del catálogo
// ---------------------------------------------------------------------------

class AutoTutorialCatalogPage extends StatelessWidget {
  const AutoTutorialCatalogPage({
    super.key,
    required this.onStart,
  });

  /// Callback invocado cuando el usuario selecciona un tutorial.
  /// El llamador (InteractiveTutorialsScreen) navega al EditorScreen.
  final void Function(AutoTutorialDefinition definition) onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tutorials = AutoTutorialScripts.all();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriales animados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2), Color(0xFF4CA1AF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Text(
              'Observa cómo FlowCode construye diagramas automáticamente y genera código C paso a paso.',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: tutorials.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return AutoTutorialCard(
                  definition: tutorials[index],
                  onStart: () => onStart(tutorials[index]),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta de tutorial individual
// ---------------------------------------------------------------------------

class AutoTutorialCard extends StatelessWidget {
  const AutoTutorialCard({
    super.key,
    required this.definition,
    required this.onStart,
  });

  final AutoTutorialDefinition definition;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = definition.level;
    final minutes = (definition.estimatedSeconds / 60).ceil();

    final cardBg = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final cardBorder = definition.enabled
        ? level.color.withOpacity(isDark ? 0.35 : 0.45)
        : (isDark ? Colors.white12 : Colors.black12);
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurface.withOpacity(0.55);
    final metaColor = theme.colorScheme.onSurface.withOpacity(0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: definition.enabled ? onStart : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cardBorder,
              width: 1.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: level.color.withOpacity(isDark ? 0.12 : 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(level.icon, color: level.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: level.color.withOpacity(isDark ? 0.15 : 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level.label,
                              style: TextStyle(
                                color: level.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.timer_outlined,
                              size: 13,
                              color: metaColor),
                          const SizedBox(width: 3),
                          Text(
                            '~$minutes min',
                            style: TextStyle(
                              color: metaColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        definition.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        definition.summary,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  definition.enabled
                      ? Icons.play_circle_outline_rounded
                      : Icons.lock_outline_rounded,
                  color: definition.enabled
                      ? level.color
                      : (isDark ? Colors.white24 : Colors.black26),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
