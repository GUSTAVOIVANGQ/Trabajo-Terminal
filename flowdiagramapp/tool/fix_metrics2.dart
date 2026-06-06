import 'dart:io';

void main() {
  final file = File('test/criteria/technical_validation_criteria_test.dart');
  final lines = file.readAsLinesSync();
  final newLines = <String>[];
  String currentTest = '';

  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];

    final testMatch = RegExp(r"test\('([A-Z]{2}-\d{2}):").firstMatch(line);
    if (testMatch != null) {
      currentTest = testMatch.group(1)!;
    }

    if (line.contains("_evidenceMap['\$1']")) {
      line = line.replaceFirst("_evidenceMap['\$1']", "_evidenceMap['$currentTest']");
    }
    
    // Also fix any remaining literal assignments to use currentTest
    if (line.contains("_evidenceMap['\${currentTest}']")) {
       line = line.replaceFirst("_evidenceMap['\${currentTest}']", "_evidenceMap['$currentTest']");
    }

    newLines.add(line);
  }

  file.writeAsStringSync(newLines.join('\n'));
}
