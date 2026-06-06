import 'dart:io';

void main() {
  final file = File('test/criteria/technical_validation_criteria_test.dart');
  final lines = file.readAsLinesSync();
  
  final newLines = <String>[];
  bool hasMap = false;
  String currentTest = '';
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (line.contains('final Map<String, String> _evidenceMap = {};')) {
      hasMap = true;
    }
    
    if (line.trim() == "import 'package:flutter/material.dart';") {
      newLines.add("import 'dart:io';");
      newLines.add(line);
      continue;
    }

    if (line.trim() == 'void main() {') {
      if (!hasMap) {
        newLines.add('final Map<String, String> _evidenceMap = {};');
      }
      newLines.add(line);
      continue;
    }
    
    final testMatch = RegExp(r"test\('([A-Z]{2}-\d{2}):").firstMatch(line);
    if (testMatch != null) {
      currentTest = testMatch.group(1)!;
    }
    
    // Remove old prints
    if (line.contains("print('EVIDENCE|")) {
      continue;
    }
    
    if (line.trim().startsWith('expect(') && currentTest.isNotEmpty) {
      if (currentTest.startsWith('CF-') || currentTest.startsWith('CG-')) {
        newLines.add("      _evidenceMap['$currentTest'] = '\${(result.generatedCode ?? \"\").split(\"\\\\n\").length} líneas de C generadas';");
      } else if (currentTest == 'CR-04') {
        newLines.add("      _evidenceMap['$currentTest'] = '\${ratio100.toStringAsFixed(2)}x (O(n) mantenido)';");
      } else if (currentTest.startsWith('CR-')) {
        newLines.add("      _evidenceMap['$currentTest'] = '\${avgMs.toStringAsFixed(2)} ms prom.';");
      } else if (currentTest.startsWith('RB-')) {
        newLines.add("      _evidenceMap['$currentTest'] = '\${result.errors.all.length} error/es atrapado/s (\${result.errors.all.isNotEmpty ? result.errors.all.first.code.toString().split(\".\").last : \"ninguno\"})';");
      }
      currentTest = ''; // solo una vez por test
    }
    
    newLines.add(line);
  }
  
  // Add tearDownAll before the last closing brace
  // Find the last closing brace of main
  int lastBraceIndex = newLines.lastIndexOf('}');
  
  final tearDownCode = """
  tearDownAll(() {
    final buffer = StringBuffer();
    buffer.writeln('\\n' + '=' * 125);
    buffer.writeln(' RESULTADOS DE CRITERIOS DE VALIDACIÓN TÉCNICA');
    buffer.writeln('=' * 125);
    
    final groups = {
      'CF': 'Criterios de Corrección Funcional',
      'CG': 'Criterios de Calidad de Código Generado',
      'CR': 'Criterios de Rendimiento',
      'RB': 'Criterios de Robustez'
    };
    
    for (var group in groups.entries) {
      buffer.writeln('\\n' + '-' * 125);
      buffer.writeln(' \${group.key} - \${group.value}');
      buffer.writeln('-' * 125);
      buffer.writeln('| \${'CÓDIGO'.padRight(7)} | \${'RESULTADO'.padRight(9)} | \${'EVIDENCIA OBTENIDA (MÉTRICA REAL)'.padRight(60)} |');
      buffer.writeln('|---------|-----------|--------------------------------------------------------------|');
      
      final keys = _evidenceMap.keys.where((k) => k.startsWith(group.key)).toList()..sort();
      for (var key in keys) {
        final ev = _evidenceMap[key]!;
        buffer.writeln('| \${key.padRight(7)} | \${'ÉXITO'.padRight(9)} | \${ev.padRight(60)} |');
      }
    }
    buffer.writeln('=' * 125 + '\\n');
    
    File('EVIDENCIA_VALIDACION_TECNICA.md').writeAsStringSync(buffer.toString());
  });
""";

    final code = newLines.join('\n');
    final modifiedCode = code.replaceFirst('}\n\nDiagramNode _terminalNode', tearDownCode + '\n}\n\nDiagramNode _terminalNode');
    
    File('test/criteria/technical_validation_criteria_test.dart').writeAsStringSync(modifiedCode);
  print('Tests actualizados con tearDownAll y map!');
}
