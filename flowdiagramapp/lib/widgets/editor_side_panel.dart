import 'package:flutter/material.dart';
import 'node_palette.dart';
import 'programming_concepts_palette.dart';
import '../models/diagram_node.dart';

class EditorSidePanel extends StatefulWidget {
  final Function(NodeType) onNodeSelected;
  final Function(ProgrammingConceptType) onConceptSelected;

  const EditorSidePanel({
    super.key,
    required this.onNodeSelected,
    required this.onConceptSelected,
  });

  @override
  State<EditorSidePanel> createState() => _EditorSidePanelState();
}

class _EditorSidePanelState extends State<EditorSidePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Custom Tab Bar for space efficiency
          SizedBox(
            height: 40,
            child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(
                    icon: Icon(Icons.category, size: 20),
                    iconMargin: EdgeInsets.zero), // Symbols
                Tab(
                    icon: Icon(Icons.integration_instructions, size: 20),
                    iconMargin: EdgeInsets.zero), // Concepts
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable swipe to avoid conflict with canvas
              children: [
                NodePalette(onNodeSelected: widget.onNodeSelected),
                ProgrammingConceptsPalette(
                    onConceptSelected: widget.onConceptSelected),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
