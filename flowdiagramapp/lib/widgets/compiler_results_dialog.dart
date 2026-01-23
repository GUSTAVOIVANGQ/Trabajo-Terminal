import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../compiler/compiler.dart';

/// Dialog that displays comprehensive compiler results with tabs for each phase
class CompilerResultsDialog extends StatefulWidget {
  final CompilationResult result;
  final String? legacyCode;

  const CompilerResultsDialog({
    super.key,
    required this.result,
    this.legacyCode,
  });

  @override
  State<CompilerResultsDialog> createState() => _CompilerResultsDialogState();
}

class _CompilerResultsDialogState extends State<CompilerResultsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
        ),
        child: Column(
          children: [
            // Header with status
            _buildHeader(theme, isDark),

            // Tab bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: theme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: theme.primaryColor,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.dashboard, size: 20),
                    text: 'General',
                  ),
                  Tab(
                    icon: Icon(Icons.text_fields, size: 20),
                    text: 'Léxico',
                  ),
                  Tab(
                    icon: Icon(Icons.account_tree, size: 20),
                    text: 'Sintáctico',
                  ),
                  Tab(
                    icon: Icon(Icons.psychology, size: 20),
                    text: 'Semántico',
                  ),
                  Tab(
                    icon: Icon(Icons.speed, size: 20),
                    text: 'Optimización',
                  ),
                  Tab(
                    icon: Icon(Icons.code, size: 20),
                    text: 'Código',
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(theme, isDark),
                  _buildLexicalTab(theme, isDark),
                  _buildSyntacticTab(theme, isDark),
                  _buildSemanticTab(theme, isDark),
                  _buildOptimizationTab(theme, isDark),
                  _buildCodeTab(theme, isDark),
                ],
              ),
            ),

            // Footer with actions
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final success = widget.result.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  success ? 'Compilación Exitosa' : 'Compilación con Errores',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                Text(
                  'Tiempo total: ${widget.result.metrics.compilationTimeMs}ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, bool isDark) {
    final metrics = widget.result.metrics;
    final errors = widget.result.errors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics cards
          _buildSectionTitle('📊 Métricas de Compilación', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                'Nodos',
                '${metrics.nodesProcessed}',
                Icons.widgets,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Tokens',
                '${metrics.tokensGenerated}',
                Icons.text_fields,
                Colors.purple,
                isDark,
              ),
              _buildMetricCard(
                'Símbolos',
                '${metrics.symbolsInTable}',
                Icons.table_chart,
                Colors.teal,
                isDark,
              ),
              _buildMetricCard(
                'Errores',
                '${metrics.errorCount}',
                Icons.error_outline,
                metrics.errorCount > 0 ? Colors.red : Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Advertencias',
                '${metrics.warningCount}',
                Icons.warning_amber,
                metrics.warningCount > 0 ? Colors.orange : Colors.green,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Timing breakdown
          _buildSectionTitle('⏱️ Tiempos por Fase', theme),
          const SizedBox(height: 12),
          _buildTimingBar(metrics, isDark),

          const SizedBox(height: 24),

          // Messages log
          _buildSectionTitle('📋 Log de Compilación', theme),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.result.messages.map((msg) {
                IconData icon = Icons.info_outline;
                Color color = Colors.grey;

                if (msg.contains('Error') || msg.contains('error')) {
                  icon = Icons.error_outline;
                  color = Colors.red;
                } else if (msg.contains('Advertencia') ||
                    msg.contains('warning')) {
                  icon = Icons.warning_amber;
                  color = Colors.orange;
                } else if (msg.contains('✓') || msg.contains('completada')) {
                  icon = Icons.check_circle_outline;
                  color = Colors.green;
                } else if (msg.startsWith('Fase')) {
                  icon = Icons.play_circle_outline;
                  color = Colors.blue;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          msg,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Errors section
          if (errors.hasErrors) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('❌ Errores', theme),
            const SizedBox(height: 12),
            ...errors
                .getBySeverity(CompilerSeverity.error)
                .map((e) => _buildErrorCard(e, isDark)),
          ],

          // Warnings section
          if (errors.warningCount > 0) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('⚠️ Advertencias', theme),
            const SizedBox(height: 12),
            ...errors
                .getBySeverity(CompilerSeverity.warning)
                .map((w) => _buildErrorCard(w, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildLexicalTab(ThemeData theme, bool isDark) {
    final lexicalResult = widget.result.lexicalResult;

    if (lexicalResult == null) {
      return _buildEmptyState(
        'No hay resultados de análisis léxico',
        Icons.text_fields,
        isDark,
      );
    }

    // Count token types
    final identifierCount = lexicalResult.allTokens
        .where((t) => t.type == TokenType.identifier)
        .length;
    final literalCount = lexicalResult.allTokens
        .where((t) =>
            t.type == TokenType.integerLiteral ||
            t.type == TokenType.floatLiteral ||
            t.type == TokenType.stringLiteral)
        .length;
    final operatorCount = lexicalResult.allTokens
        .where((t) => t.type.name.startsWith('op'))
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSectionTitle('📊 Resumen del Análisis Léxico', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                'Tokens',
                '${lexicalResult.tokenCount}',
                Icons.text_fields,
                Colors.purple,
                isDark,
              ),
              _buildMetricCard(
                'Identificadores',
                '$identifierCount',
                Icons.label,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Literales',
                '$literalCount',
                Icons.format_quote,
                Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Operadores',
                '$operatorCount',
                Icons.calculate,
                Colors.orange,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Token stream
          _buildSectionTitle('🔤 Flujo de Tokens', theme),
          const SizedBox(height: 12),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: lexicalResult.allTokens.length,
              itemBuilder: (context, index) {
                final token = lexicalResult.allTokens[index];
                return _buildTokenRow(token, index, isDark);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Node results
          _buildSectionTitle('📦 Tokens por Nodo', theme),
          const SizedBox(height: 12),
          ...lexicalResult.nodeResults.map((nodeResult) {
            return ExpansionTile(
              title: Text(
                'Nodo: ${nodeResult.nodeType.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${nodeResult.tokens.length} tokens • ${nodeResult.originalText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              children: nodeResult.tokens
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _buildTokenRow(e.value, e.key, isDark),
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSyntacticTab(ThemeData theme, bool isDark) {
    final syntaxResult = widget.result.syntaxResult;
    final ast = widget.result.ast;

    if (syntaxResult == null) {
      return _buildEmptyState(
        'No hay resultados de análisis sintáctico',
        Icons.account_tree,
        isDark,
      );
    }

    final totalNodes = syntaxResult.nodeResults.length;
    final expressionCount = syntaxResult.totalStatements;
    final statementCount = syntaxResult.totalStatements;
    final errorCount = syntaxResult.getErrorCount(CompilerSeverity.error);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildSectionTitle('📊 Resumen del Análisis Sintáctico', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                'Nodos AST',
                '$totalNodes',
                Icons.account_tree,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Expresiones',
                '$expressionCount',
                Icons.functions,
                Colors.purple,
                isDark,
              ),
              _buildMetricCard(
                'Sentencias',
                '$statementCount',
                Icons.code,
                Colors.teal,
                isDark,
              ),
              _buildMetricCard(
                'Errores',
                '$errorCount',
                Icons.error,
                errorCount > 0 ? Colors.red : Colors.green,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // AST visualization
          _buildSectionTitle('🌳 Árbol de Sintaxis Abstracta (AST)', theme),
          const SizedBox(height: 12),
          if (ast != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  ast.toTreeString(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: isDark ? Colors.green[300] : Colors.green[800],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Node analysis results
          _buildSectionTitle('📋 Análisis por Nodo', theme),
          const SizedBox(height: 12),
          ...syntaxResult.nodeResults.map((nodeResult) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  nodeResult.isValid ? Icons.check_circle : Icons.error_outline,
                  color: nodeResult.isValid ? Colors.green : Colors.red,
                ),
                title: Text('Nodo: ${nodeResult.nodeType}'),
                subtitle: Text(
                  nodeResult.isValid
                      ? 'Sintaxis válida - ${nodeResult.statements.length} sentencias'
                      : nodeResult.errors.map((e) => e.message).join(', '),
                ),
                trailing: nodeResult.statements.isNotEmpty
                    ? const Chip(label: Text('AST'))
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemanticTab(ThemeData theme, bool isDark) {
    final semanticResult = widget.result.semanticResult;
    final symbolTable = widget.result.symbolTable;

    if (semanticResult == null) {
      return _buildEmptyState(
        'No hay resultados de análisis semántico',
        Icons.psychology,
        isDark,
      );
    }

    // Count variables
    final variableCount = symbolTable?.allSymbols
            .where((s) => s.category == SymbolCategory.variable)
            .length ??
        0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildSectionTitle('📊 Resumen del Análisis Semántico', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                'Símbolos',
                '${symbolTable?.symbolCount ?? 0}',
                Icons.table_chart,
                Colors.teal,
                isDark,
              ),
              _buildMetricCard(
                'Variables',
                '$variableCount',
                Icons.data_object,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Errores',
                '${semanticResult.errorCount}',
                Icons.error,
                semanticResult.errorCount > 0 ? Colors.red : Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Advertencias',
                '${semanticResult.warningCount}',
                Icons.warning,
                semanticResult.warningCount > 0 ? Colors.orange : Colors.green,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Symbol table
          if (symbolTable != null && symbolTable.allSymbols.isNotEmpty) ...[
            _buildSectionTitle('📋 Tabla de Símbolos', theme),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? Colors.grey[850] : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Categoría')),
                    DataColumn(label: Text('Inicializado')),
                    DataColumn(label: Text('Usado')),
                    DataColumn(label: Text('Scope')),
                  ],
                  rows: symbolTable.allSymbols.map((symbol) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          symbol.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(
                          symbol.dataType.cRepresentation,
                          style: TextStyle(
                            color: _getTypeColor(symbol.dataType),
                          ),
                        )),
                        DataCell(Text(symbol.category.name)),
                        DataCell(Icon(
                          symbol.isInitialized
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color:
                              symbol.isInitialized ? Colors.green : Colors.grey,
                        )),
                        DataCell(Icon(
                          symbol.isUsed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: symbol.isUsed ? Colors.green : Colors.orange,
                        )),
                        DataCell(Text(
                          symbol.scopeLevel == 0 ? 'Global' : 'Local',
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Semantic errors
          if (semanticResult.errors.isNotEmpty) ...[
            _buildSectionTitle('❌ Errores Semánticos', theme),
            const SizedBox(height: 12),
            ...semanticResult.errors.map((e) => _buildErrorCard(e, isDark)),
          ],

          // Warnings
          if (semanticResult.warnings.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('⚠️ Advertencias', theme),
            const SizedBox(height: 12),
            ...semanticResult.warnings.map((w) => _buildErrorCard(w, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationTab(ThemeData theme, bool isDark) {
    final optimizationResult = widget.result.optimizationResult;

    if (optimizationResult == null) {
      return _buildEmptyState(
        'Optimización no ejecutada\n(nivel de optimización = 0)',
        Icons.speed,
        isDark,
      );
    }

    final metrics = optimizationResult.metrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildSectionTitle('📊 Resumen de Optimización', theme),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildMetricCard(
                'Total',
                '${optimizationResult.totalOptimizations}',
                Icons.auto_fix_high,
                Colors.purple,
                isDark,
              ),
              _buildMetricCard(
                'Const. Plegadas',
                '${metrics.constantsFolded}',
                Icons.compress,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Cód. Muerto',
                '${metrics.deadCodeRemoved}',
                Icons.delete_sweep,
                Colors.red,
                isDark,
              ),
              _buildMetricCard(
                'Simplificadas',
                '${metrics.expressionsSimplified}',
                Icons.straighten,
                Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Flujo Ctrl.',
                '${metrics.controlFlowOptimized}',
                Icons.alt_route,
                Colors.orange,
                isDark,
              ),
              _buildMetricCard(
                'Reducción',
                '${metrics.sizeReductionPercent.toStringAsFixed(1)}%',
                Icons.trending_down,
                metrics.sizeReductionPercent > 0 ? Colors.green : Colors.grey,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Optimization passes
          _buildSectionTitle('🔄 Pasadas de Optimización', theme),
          const SizedBox(height: 12),
          ...optimizationResult.passResults.map((pass) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: pass.optimizationsApplied > 0
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  child: Text(
                    '${pass.optimizationsApplied}',
                    style: TextStyle(
                      color: pass.optimizationsApplied > 0
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(pass.passName),
                subtitle: Text('${pass.timeMs}ms'),
                trailing: pass.optimizationsApplied > 0
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.remove_circle_outline,
                        color: Colors.grey),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Changes log
          if (optimizationResult.passResults
              .any((p) => p.changes.isNotEmpty)) ...[
            _buildSectionTitle('📋 Cambios Aplicados', theme),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: optimizationResult.passResults
                    .expand((p) => p.changes)
                    .map((change) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chevron_right,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            change,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeTab(ThemeData theme, bool isDark) {
    // Mostrar código legacy si está disponible
    final code = widget.legacyCode ?? 'Generación de código pendiente (Fase 5)';

    return Column(
      children: [
        // Code header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.code, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Código C Generado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código copiado al portapapeles'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar'),
              ),
            ],
          ),
        ),

        // Code content
        Expanded(
          child: Container(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey[300] : Colors.grey[900],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingBar(CompilationMetrics metrics, bool isDark) {
    final total = metrics.compilationTimeMs.toDouble();
    if (total == 0) return const SizedBox.shrink();

    final phases = [
      ('Léxico', metrics.lexicalTimeMs, Colors.purple),
      ('Sintáctico', metrics.syntacticTimeMs, Colors.blue),
      ('Semántico', metrics.semanticTimeMs, Colors.teal),
      ('Optimización', metrics.optimizationTimeMs, Colors.orange),
    ];

    return Column(
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          child: Row(
            children: phases.map((phase) {
              final width = (phase.$2 / total).clamp(0.0, 1.0);
              if (width == 0) return const SizedBox.shrink();
              return Flexible(
                flex: (width * 100).round().clamp(1, 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: phase.$3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: phases.map((phase) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: phase.$3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${phase.$1}: ${phase.$2}ms',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTokenRow(Token token, int index, bool isDark) {
    Color typeColor = Colors.grey;

    // Color based on token type
    if (token.type == TokenType.identifier) {
      typeColor = Colors.blue;
    } else if (token.type == TokenType.integerLiteral ||
        token.type == TokenType.floatLiteral) {
      typeColor = Colors.green;
    } else if (token.type == TokenType.stringLiteral) {
      typeColor = Colors.orange;
    } else if (token.type.name.startsWith('kw')) {
      typeColor = Colors.purple;
    } else if (token.type.name.startsWith('op')) {
      typeColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[850]?.withValues(alpha: 0.5)
            : Colors.grey[100]?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              token.type.name,
              style: TextStyle(
                fontSize: 10,
                color: typeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"${token.lexeme}"',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(CompilerError error, bool isDark) {
    Color color;
    IconData icon;

    switch (error.severity) {
      case CompilerSeverity.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case CompilerSeverity.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case CompilerSeverity.info:
        color = Colors.blue;
        icon = Icons.info;
        break;
      case CompilerSeverity.fatal:
        color = Colors.red[900]!;
        icon = Icons.dangerous;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          error.message,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        subtitle: error.location != null
            ? Text(
                'Nodo: ${error.location!.nodeId ?? '-'} | Línea: ${error.location!.line}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(DataType type) {
    switch (type) {
      case DataType.integer:
        return Colors.blue;
      case DataType.float:
        return Colors.green;
      case DataType.char:
        return Colors.purple;
      case DataType.string:
        return Colors.orange;
      case DataType.boolean:
        return Colors.teal;
      case DataType.void_:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // Copy full report
              final report = widget.result.generateReport();
              Clipboard.setData(ClipboardData(text: report));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte copiado al portapapeles'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.description),
            label: const Text('Copiar Reporte'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
