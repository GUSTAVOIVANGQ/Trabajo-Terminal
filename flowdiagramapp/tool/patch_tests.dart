import 'dart:io';

void main() {
  final file = File('test/criteria/technical_validation_criteria_test.dart');
  final lines = file.readAsLinesSync();
  
  final newLines = <String>[];
  String currentTest = '';
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    final testMatch = RegExp(r"test\('([A-Z]{2}-\d{2}):").firstMatch(line);
    if (testMatch != null) {
      currentTest = testMatch.group(1)!;
    }
    
    if (line.trim().startsWith('expect(') && currentTest.isNotEmpty) {
      if (currentTest.startsWith('CF-') || currentTest.startsWith('CG-')) {
        newLines.add("      print('EVIDENCE|Generado con éxito (\${(result.generatedCode ?? \"\").split(\"\\\\n\").length} líneas de C)');");
      } else if (currentTest == 'CR-04') {
        newLines.add("      print('EVIDENCE|O(n) mantenido (Ratio 100/50: \${ratio100.toStringAsFixed(2)}x)');");
      } else if (currentTest.startsWith('CR-')) {
        newLines.add("      print('EVIDENCE|Tiempo prom: \${avgMs.toStringAsFixed(2)} ms');");
      } else if (currentTest.startsWith('RB-')) {
        newLines.add("      print('EVIDENCE|Atrapó \${result.errors.all.length} error/es (\${result.errors.all.isNotEmpty ? result.errors.all.first.code.toString().split(\".\").last : \"ninguno\"})');");
      }
      currentTest = ''; // solo una vez por test
    }
    
    newLines.add(line);
  }
  
  file.writeAsStringSync(newLines.join('\n'));
  print('Tests parcheados!');
}
