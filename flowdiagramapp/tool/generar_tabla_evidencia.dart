import 'dart:convert';
import 'dart:io';

void main() async {
  print('Corriendo pruebas de validación técnica... Por favor espera.\n');

  final process = await Process.start(
    'flutter',
    ['test', '--machine', 'test/criteria/technical_validation_criteria_test.dart'],
    runInShell: true,
  );

  final Map<int, String> testNames = {};
  final Map<int, String> testResults = {};
  final Map<int, String> testEvidence = {};
  final Map<String, List<Map<String, String>>> groupedResults = {
    'CF': [],
    'CG': [],
    'CR': [],
    'RB': [],
  };

  process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.startsWith('[{') || line.startsWith('{')) {
      try {
        final dynamic data = jsonDecode(line);
        if (data is Map) {
          _processEvent(data, testNames, testResults, testEvidence);
        } else if (data is List) {
          for (var item in data) {
            _processEvent(item, testNames, testResults, testEvidence);
          }
        }
      } catch (e) {
        // Ignorar lineas que no sean JSON
      }
    }
  });

  await process.exitCode;

  // Organizar resultados
  for (var entry in testResults.entries) {
    final id = entry.key;
    final result = entry.value;
    final name = testNames[id] ?? 'Desconocido';
    final evidence = testEvidence[id] ?? 'Cumple el criterio';

    if (name.startsWith('loading') || name.contains('setUpAll') || name.contains('tearDownAll')) {
      continue;
    }

    String group = '';
    if (name.contains('CF-')) group = 'CF';
    else if (name.contains('CG-')) group = 'CG';
    else if (name.contains('CR-')) group = 'CR';
    else if (name.contains('RB-')) group = 'RB';
    else continue;

    String shortName = name;
    String code = group;
    
    final parts = name.split(': ');
    if (parts.length >= 2) {
      shortName = parts.last;
      final codeRegex = RegExp('($group-\\d{2})');
      final matches = codeRegex.allMatches(name);
      if (matches.isNotEmpty) {
        code = matches.last.group(1)!;
      }
    }

    groupedResults[group]?.add({
      'code': code,
      'name': shortName,
      'result': result == 'success' ? 'ÉXITO' : 'FALLA',
      'evidence': evidence,
    });
  }

  // Ordenar cada grupo por código
  for (var group in groupedResults.values) {
    group.sort((a, b) => a['code']!.compareTo(b['code']!));
  }

  // Imprimir tablas
  _printTable('CF - Criterios de Corrección Funcional', groupedResults['CF']!);
  _printTable('CG - Criterios de Calidad de Código Generado', groupedResults['CG']!);
  _printTable('CR - Criterios de Rendimiento', groupedResults['CR']!);
  _printTable('RB - Criterios de Robustez', groupedResults['RB']!);
  
  print('\n¡Todas las pruebas procesadas con éxito!');
}

void _processEvent(Map data, Map<int, String> testNames, Map<int, String> testResults, Map<int, String> testEvidence) {
  final type = data['type'];
  if (type == 'testStart') {
    final test = data['test'];
    testNames[test['id']] = test['name'];
  } else if (type == 'testDone') {
    if (data['hidden'] == true) return;
    testResults[data['testID']] = data['result'];
  } else if (type == 'print') {
    final message = data['message'] as String;
    if (message.startsWith('EVIDENCE|')) {
      testEvidence[data['testID']] = message.replaceFirst('EVIDENCE|', '');
    }
  }
}

void _printTable(String title, List<Map<String, String>> results) {
  if (results.isEmpty) return;
  
  print('\n' + '=' * 125);
  print(' $title');
  print('=' * 125);
  
  int maxNameLength = 10;
  int maxEvLength = 15;
  for (var r in results) {
    if (r['name']!.length > maxNameLength) maxNameLength = r['name']!.length;
    if (r['evidence']!.length > maxEvLength) maxEvLength = r['evidence']!.length;
  }
  
  if (maxNameLength > 45) maxNameLength = 45;
  if (maxEvLength > 45) maxEvLength = 45;
  
  final headerCode = 'CÓDIGO'.padRight(7);
  final headerName = 'DESCRIPCIÓN DE LA PRUEBA'.padRight(maxNameLength);
  final headerRes = 'RESULTADO';
  final headerEv = 'EVIDENCIA OBTENIDA'.padRight(maxEvLength);
  
  print('| $headerCode | $headerName | $headerRes | $headerEv |');
  print('|---------|-${'-' * maxNameLength}-|-----------|-${'-' * maxEvLength}-|');
  
  for (var r in results) {
    final code = r['code']!.padRight(7);
    String name = r['name']!;
    if (name.length > maxNameLength) name = name.substring(0, maxNameLength - 3) + '...';
    name = name.padRight(maxNameLength);
    final res = r['result']!;
    final paddedRes = res.padRight(9);
    
    String ev = r['evidence']!;
    if (ev.length > maxEvLength) ev = ev.substring(0, maxEvLength - 3) + '...';
    ev = ev.padRight(maxEvLength);
    
    print('| $code | $name | $paddedRes | $ev |');
  }
  print('-' * 125);
}
