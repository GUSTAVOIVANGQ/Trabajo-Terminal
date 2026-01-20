import 'package:flutter/material.dart';
import 'package:test_flowcode/symbols/data_symbols.dart';
import 'package:test_flowcode/symbols/process_symbols.dart';
import 'package:test_flowcode/symbols/line_symbols.dart';
import 'package:test_flowcode/symbols/special_symbols.dart';

void main() {
  runApp(const FlowchartApp());
}

class FlowchartApp extends StatelessWidget {
  const FlowchartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISO 5807 Symbols',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SymbolsPage(),
    );
  }
}

class SymbolDef {
  final String name;
  final String description; // Símbolo usado
  final FlowchartPainter painter;

  SymbolDef(this.name, this.description, this.painter);
}

class SymbolCategory {
  final String title;
  final Color color;
  final List<SymbolDef> symbols;

  SymbolCategory(this.title, this.color, this.symbols);
}

class SymbolsPage extends StatelessWidget {
  const SymbolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data definition
    final categories = [
      SymbolCategory('Data symbols (Símbolos de datos)', Colors.blue.shade100, [
        SymbolDef('Data', 'Paralelogramo', DataSymbolPainter()),
        SymbolDef(
          'Stored data',
          'Rectángulo con base curva',
          StoredDataSymbolPainter(),
        ),
        SymbolDef(
          'Internal storage',
          'Rectángulo con lados cóncavos',
          InternalStorageSymbolPainter(),
        ),
        SymbolDef(
          'Sequential access storage',
          'Cinta (rectángulo con borde ondulado)',
          SequentialAccessStorageSymbolPainter(),
        ),
        SymbolDef(
          'Direct access storage',
          'Cilindro',
          DirectAccessStorageSymbolPainter(),
        ),
        SymbolDef(
          'Document',
          'Rectángulo con borde inferior ondulado',
          DocumentSymbolPainter(),
        ),
        SymbolDef(
          'Manual input',
          'Paralelogramo inclinado',
          ManualInputSymbolPainter(),
        ),
        SymbolDef(
          'Card',
          'Rectángulo con esquina cortada',
          CardSymbolPainter(),
        ),
        SymbolDef(
          'Punched tape',
          'Rectángulo ondulado',
          PunchedTapeSymbolPainter(),
        ),
        SymbolDef(
          'Display',
          'Rectángulo con lados inclinados',
          DisplaySymbolPainter(),
        ),
      ]),
      SymbolCategory(
        'Process symbols (Símbolos de proceso)',
        Colors.green.shade100,
        [
          SymbolDef('Process', 'Rectángulo', ProcessSymbolPainter()),
          SymbolDef(
            'Predefined process',
            'Rectángulo con doble borde',
            PredefinedProcessSymbolPainter(),
          ),
          SymbolDef(
            'Manual operation',
            'Trapecio',
            ManualOperationSymbolPainter(),
          ),
          SymbolDef('Preparation', 'Hexágono', PreparationSymbolPainter()),
          SymbolDef('Decision', 'Rombo', DecisionSymbolPainter()),
          SymbolDef(
            'Parallel mode',
            'Barra doble horizontal',
            ParallelModeSymbolPainter(),
          ),
          SymbolDef(
            'Loop limit',
            'Símbolo doble (inicio/fin de ciclo)',
            LoopLimitSymbolPainter(),
          ),
          SymbolDef(
            'Collate',
            'Círculo con cruz diagonal (X)',
            CollateSymbolPainter(),
          ),
          SymbolDef(
            'Summing junction',
            'Círculo con cruz vertical (+)',
            SummingJunctionSymbolPainter(),
          ),
        ],
      ),
      SymbolCategory(
        'Line symbols (Símbolos de línea)',
        Colors.amber.shade100,
        [
          SymbolDef('Line', 'Flecha', LineSymbolPainter()),
          SymbolDef(
            'Control transfer',
            'Flecha con etiqueta',
            ControlTransferSymbolPainter(),
          ),
          SymbolDef(
            'Communication link',
            'Línea con zigzag',
            CommunicationLinkSymbolPainter(),
          ),
          SymbolDef(
            'Dashed line',
            'Línea discontinua',
            DashedLineSymbolPainter(),
          ),
        ],
      ),
      SymbolCategory(
        'Special symbols (Símbolos especiales)',
        Colors.purple.shade100,
        [
          SymbolDef('Connector (on-page)', 'Círculo', ConnectorSymbolPainter()),
          SymbolDef(
            'Off-page connector',
            'Pentágono',
            OffPageConnectorSymbolPainter(),
          ),
          SymbolDef(
            'Annotation',
            'Llave / nota lateral',
            AnnotationSymbolPainter(),
          ),
          SymbolDef(
            'Comment / Annotation area',
            'Área delimitada con línea discontinua',
            CommentSymbolPainter(),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Símbolos ISO 5807')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ExpansionTile(
            collapsedBackgroundColor: category.color,
            backgroundColor: category.color.withOpacity(0.5),
            title: Text(
              category.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: index == 0, // Expand first by default
            children: category.symbols.map((symbol) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Drawing Area
                      Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: CustomPaint(painter: symbol.painter),
                      ),
                      const SizedBox(width: 20),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              symbol.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              symbol.description,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
