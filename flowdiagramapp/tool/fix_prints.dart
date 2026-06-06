import 'dart:io';

void main() {
  final file = File('test/criteria/technical_validation_criteria_test.dart');
  var code = file.readAsStringSync();
  
  // Replace the table with section printing
  final oldTearDown = r'''
  tearDownAll(() {
    final buffer = StringBuffer();
    buffer.writeln('\n' + '=' * 125);
    buffer.writeln(' RESULTADOS DE CRITERIOS DE VALIDACIÓN TÉCNICA');
    buffer.writeln('=' * 125);
    
    final groups = {
      'CF': 'Criterios de Corrección Funcional',
      'CG': 'Criterios de Calidad de Código Generado',
      'CR': 'Criterios de Rendimiento',
      'RB': 'Criterios de Robustez'
    };
    
    for (var group in groups.entries) {
      buffer.writeln('\n' + '-' * 125);
      buffer.writeln(' ${group.key} - ${group.value}');
      buffer.writeln('-' * 125);
      buffer.writeln('| ${"CÓDIGO".padRight(7)} | ${"RESULTADO".padRight(9)} | ${"EVIDENCIA OBTENIDA (MÉTRICA REAL)".padRight(60)} |');
      buffer.writeln('|---------|-----------|--------------------------------------------------------------|');
      
      final keys = _evidenceMap.keys.where((k) => k.startsWith(group.key)).toList()..sort();
      for (var key in keys) {
        final ev = _evidenceMap[key]!;
        buffer.writeln('| ${key.padRight(7)} | ${"ÉXITO".padRight(9)} | ${ev.padRight(60)} |');
      }
    }
    buffer.writeln('=' * 125 + '\n');
    
    File('EVIDENCIA_VALIDACION_TECNICA.md').writeAsStringSync(buffer.toString());
  });''';
  
  final newTearDown = r'''
  tearDownAll(() {
    final groups = {
      'CF': 'Criterios de Corrección Funcional',
      'CG': 'Criterios de Calidad de Código Generado',
      'CR': 'Criterios de Rendimiento',
      'RB': 'Criterios de Robustez'
    };
    
    for (var group in groups.entries) {
      Zone.root.print('\n=== ${group.key} - ${group.value} ===');
      
      final keys = _evidenceMap.keys.where((k) => k.startsWith(group.key)).toList()..sort();
      for (var key in keys) {
        Zone.root.print('\n[$key]');
        Zone.root.print(_evidenceMap[key]);
      }
    }
    Zone.root.print('\n');
  });''';

  code = code.replaceFirst("import 'dart:io';", "import 'dart:io';\nimport 'dart:async';");
  
  code = code.replaceFirst(oldTearDown, newTearDown);
  
  // Also we need to fix the _evidenceMap assignments.
  // Instead of lines generated, we want the generated code.
  code = code.replaceAll(
    '''_evidenceMap['\$currentTest'] = '\${(result.generatedCode ?? "").split("\\n").length} líneas de C generadas';''',
    '''_evidenceMap['\$currentTest'] = result.generatedCode ?? 'Sin código generado';'''
  );
  
  // But wait, the script patch_tests2.dart literally inserted literal assignments:
  // _evidenceMap['CF-01'] = '${(result.generatedCode ?? "").split("\\n").length} líneas de C generadas';
  
  code = code.replaceAll(
    '''\${(result.generatedCode ?? "").split("\\n").length} líneas de C generadas''',
    '''\${result.generatedCode ?? "Sin código generado"}'''
  );
  
  code = code.replaceAll(
    '''\${result.errors.all.length} error/es atrapado/s (\${result.errors.all.isNotEmpty ? result.errors.all.first.code.toString().split(".").last : "ninguno"})''',
    '''\${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}'''
  );
  
  file.writeAsStringSync(code);
}
