import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';

class DiagramCase {
  final List<DiagramNode> nodes;
  final List<Connection> connections;

  DiagramCase(this.nodes, this.connections);
}

final Map<String, String> _evidenceMap = {};
void main() {
  group('CF-01 a CF-07: criterios de correccion funcional', () {
    test('CF-01: nodos terminales generan int main() valido', () {
      final nodes = [
        _terminalNode('cf01_start', 'Inicio', 50),
        _terminalNode('cf01_end', 'Fin', 150),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CF-01'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      expect(result.generatedCode, isNotNull);
      expect(result.generatedCode!.contains('int main('), isTrue);
      expect(result.generatedCode!.contains('return 0;'), isTrue);
    });

    test(
        'CF-02: proceso genera declaraciones y asignaciones sin error sintactico',
        () {
      final nodes = [
        _terminalNode('cf02_start', 'Inicio', 50),
        _processNode('cf02_decl', 'int a = 1', 150),
        _processNode('cf02_assign', 'a = a + 2', 250),
        _terminalNode('cf02_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      expect(result.success, isTrue);
      expect(result.syntaxResult, isNotNull);
      expect(result.syntaxResult!.isValid, isTrue);
      expect(result.errors.hasErrors, isFalse);
      expect(result.generatedCode!.contains('a = a + 2'), isTrue);
    });

    test('CF-03: data nodes generan scanf/printf con especificadores correctos',
        () {
      final nodes = [
        _terminalNode('cf03_start', 'Inicio', 50),
        _processNode('cf03_int', 'int x = 1', 150),
        _processNode('cf03_float', 'float y = 2.5', 250),
        _processNode('cf03_char', "char z = 'A'", 350),
        _processNode('cf03_string', 'cadena nombre', 450),
        _dataNode('cf03_in', 'Leer x, y, z, nombre', 550),
        _dataNode('cf03_out', 'Escribir x, y, z, nombre', 650,
            metadata: {'isOutput': true}),
        _terminalNode('cf03_end', 'Fin', 750),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CF-03'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';

      expect(code.contains('scanf("%d", &x);'), isTrue);
      expect(code.contains('scanf("%f", &y);'), isTrue);
      expect(code.contains('scanf("%c", &z);'), isTrue);
      expect(code.contains('scanf("%s", nombre);'), isTrue);

      final printfLine = _findLine(code, (line) {
        return line.contains('printf(') &&
            line.contains('x') &&
            line.contains('y') &&
            line.contains('z') &&
            line.contains('nombre');
      });
      expect(printfLine, isNotEmpty);
      expect(printfLine.contains('%d'), isTrue);
      expect(printfLine.contains('%f'), isTrue);
      expect(printfLine.contains('%c'), isTrue);
      expect(printfLine.contains('%s'), isTrue);
    });

    test('CF-04: decision genera if/else evaluable', () {
      final decisionNode = _decisionNode('cf04_dec', 'a > 0', 250);
      final yesNode = _processNode('cf04_yes', 'a = a + 1', 350);
      final noNode = _processNode('cf04_no', 'a = a - 1', 450);

      final nodes = [
        _terminalNode('cf04_start', 'Inicio', 50),
        _processNode('cf04_decl', 'int a = 5', 150),
        decisionNode,
        yesNode,
        noNode,
        _terminalNode('cf04_end', 'Fin', 550),
      ];

      final connections = [
        Connection(source: nodes[0], target: nodes[1]),
        Connection(source: nodes[1], target: decisionNode),
        Connection(source: decisionNode, target: yesNode, label: 'si'),
        Connection(source: decisionNode, target: noNode, label: 'no'),
        Connection(source: yesNode, target: nodes[5]),
        Connection(source: noNode, target: nodes[5]),
      ];

      final result = nodes.compile(connections);

      _evidenceMap['CF-04'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';
      expect(code.contains('if (a > 0) {'), isTrue);
      expect(code.contains('else {'), isTrue);
    });

    test('CF-05: iteracion genera while y for validos', () {
      final forNode = _preparationNode(
        'cf05_for',
        'for (int i = 0; i < 3; i++)',
        250,
        metadata: {'loopType': 'for'},
      );
      final forBody = _processNode('cf05_for_body', 'x = x + 1', 350);

      final whileDecision = _decisionNode(
        'cf05_while',
        'x < 5',
        550,
        metadata: {
          'structureType': 'loop',
          'loopType': 'while',
        },
      );
      final whileBody = _processNode('cf05_while_body', 'x = x + 1', 650);

      final nodes = [
        _terminalNode('cf05_start', 'Inicio', 50),
        _processNode('cf05_decl', 'int x = 0', 150),
        forNode,
        forBody,
        whileDecision,
        whileBody,
        _terminalNode('cf05_end', 'Fin', 750),
      ];

      final connections = [
        Connection(source: nodes[0], target: nodes[1]),
        Connection(source: nodes[1], target: forNode),
        Connection(source: forNode, target: forBody, label: 'si'),
        Connection(source: forNode, target: whileDecision, label: 'no'),
        Connection(source: forBody, target: forNode, isLoopBack: true),
        Connection(source: whileDecision, target: whileBody, label: 'si'),
        Connection(source: whileDecision, target: nodes[6], label: 'no'),
        Connection(source: whileBody, target: whileDecision, isLoopBack: true),
      ];

      final result = nodes.compile(connections);

      _evidenceMap['CF-05'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';
      expect(code.contains('for (int i = 0; i < 3; i++) {'), isTrue);
      expect(code.contains('while (x < 5) {'), isTrue);
    });

    test('CF-06: operadores aritmeticos, logicos y relacionales traducidos',
        () {
      final nodes = [
        _terminalNode('cf06_start', 'Inicio', 50),
        _processNode('cf06_decl', 'int a = 1 + 2 * 3', 150),
        _decisionNode('cf06_dec', 'a > 0 && a < 10', 250),
        _processNode('cf06_yes', 'a = a - 1', 350),
        _terminalNode('cf06_end', 'Fin', 450),
      ];

      final connections = [
        Connection(source: nodes[0], target: nodes[1]),
        Connection(source: nodes[1], target: nodes[2]),
        Connection(source: nodes[2], target: nodes[3], label: 'si'),
        Connection(source: nodes[3], target: nodes[4]),
      ];

      final result = nodes.compile(connections);

      _evidenceMap['CF-06'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';
      expect(code.contains('1 + 2 * 3'), isTrue);
      expect(code.contains('a > 0 && a < 10'), isTrue);
    });

    test('CF-07: tabla de simbolos se propaga entre fases', () {
      final nodes = [
        _terminalNode('cf07_start', 'Inicio', 50),
        _processNode('cf07_decl', 'int contador = 0', 150),
        _processNode('cf07_assign', 'contador = contador + 1', 250),
        _terminalNode('cf07_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CF-07'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      expect(result.lexicalResult, isNotNull);
      expect(result.semanticResult, isNotNull);

      final lexicalSymbol =
          result.lexicalResult!.symbolTable.lookup('contador');
      final semanticSymbol =
          result.semanticResult!.symbolTable.lookup('contador');

      expect(lexicalSymbol, isNotNull);
      expect(semanticSymbol, isNotNull);
      expect(lexicalSymbol!.dataType, semanticSymbol!.dataType);
    });
  });

  group('CG-01 a CG-05: criterios de calidad de codigo', () {
    test('CG-01: codigo generado sin errores del compilador interno', () {
      final nodes = [
        _terminalNode('cg01_start', 'Inicio', 50),
        _processNode('cg01_decl', 'int x = 10', 150),
        _dataNode('cg01_out', 'Escribir x', 250, metadata: {'isOutput': true}),
        _terminalNode('cg01_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CG-01'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      expect(result.errors.hasErrors, isFalse);
    });

    test('CG-02: indentacion consistente de 2 espacios por nivel', () {
      final nodes = [
        _terminalNode('cg02_start', 'Inicio', 50),
        _processNode('cg02_decl', 'int x = 1', 150),
        _terminalNode('cg02_end', 'Fin', 250),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(
        connections,
        options: const CompilerOptions(generateComments: false),
      );
      _evidenceMap['CG-02'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);

      final code = result.generatedCode ?? '';
      final bodyLines = _mainBodyLines(code);

      final firstLine = bodyLines.firstWhere(
        (line) => line.trim().isNotEmpty && line.trim() != '}',
        orElse: () => '',
      );
      expect(firstLine.isNotEmpty, isTrue);

      final firstIndent = _leadingSpaces(firstLine);
      expect(firstIndent, 2,
          reason: 'Expected 2 spaces, got $firstIndent in: $firstLine');

      for (final line in bodyLines) {
        if (line.trim().isEmpty) continue;
        final indentSize = _leadingSpaces(line);
        expect(indentSize % 2, 0,
            reason: 'Indentation should be multiple of 2: $line');
      }
    });

    test('CG-03: directivas include presentes', () {
      final nodes = [
        _terminalNode('cg03_start', 'Inicio', 50),
        _terminalNode('cg03_end', 'Fin', 150),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CG-03'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      expect(result.generatedCode!.contains('#include <stdio.h>'), isTrue);
    });

    test('CG-04: funcion main con return 0', () {
      final nodes = [
        _terminalNode('cg04_start', 'Inicio', 50),
        _terminalNode('cg04_end', 'Fin', 150),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CG-04'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';
      expect(code.contains('int main('), isTrue);
      expect(code.contains('return 0;'), isTrue);
    });

    test('CG-05: especificadores de formato segun tipo de dato', () {
      final nodes = [
        _terminalNode('cg05_start', 'Inicio', 50),
        _processNode('cg05_int', 'int x = 1', 150),
        _processNode('cg05_float', 'float y = 2.5', 250),
        _processNode('cg05_char', "char z = 'A'", 350),
        _processNode('cg05_string', 'cadena nombre', 450),
        _dataNode('cg05_out', 'Escribir x, y, z, nombre', 550,
            metadata: {'isOutput': true}),
        _terminalNode('cg05_end', 'Fin', 650),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['CG-05'] = result.generatedCode ?? 'Sin código generado';
      expect(result.success, isTrue);
      final code = result.generatedCode ?? '';

      final printfLine = _findLine(code, (line) {
        return line.contains('printf(') &&
            line.contains('x') &&
            line.contains('y') &&
            line.contains('z') &&
            line.contains('nombre');
      });

      expect(printfLine, isNotEmpty);
      expect(printfLine.contains('%d'), isTrue);
      expect(printfLine.contains('%f'), isTrue);
      expect(printfLine.contains('%c'), isTrue);
      expect(printfLine.contains('%s'), isTrue);
    });
  });

  group('CR-01 a CR-04: criterios de rendimiento', () {
    test('CR-01: diagramas simples (<=10 nodos) < 1000 ms', () {
      final diagram = _linearDiagram(10);
      final avgMs = _averageCompileMs(diagram, iterations: 3);

      _evidenceMap['CR-01'] = '${avgMs.toStringAsFixed(2)} ms prom.';
      expect(avgMs, lessThan(1000));
    });

    test('CR-02: diagramas medios (<=50 nodos) < 5000 ms', () {
      final diagram = _linearDiagram(50);
      final avgMs = _averageCompileMs(diagram, iterations: 3);

      _evidenceMap['CR-02'] = '${avgMs.toStringAsFixed(2)} ms prom.';
      expect(avgMs, lessThan(5000));
    });

    test('CR-03: diagramas complejos (<=100 nodos) < 10000 ms', () {
      final diagram = _linearDiagram(100);
      final avgMs = _averageCompileMs(diagram, iterations: 3);

      _evidenceMap['CR-03'] = '${avgMs.toStringAsFixed(2)} ms prom.';
      expect(avgMs, lessThan(10000));
    });

    test('CR-04: escalabilidad O(n) o mejor', () {
      final time10 = _averageCompileMs(_linearDiagram(10), iterations: 3);
      final time50 = _averageCompileMs(_linearDiagram(50), iterations: 3);
      final time100 = _averageCompileMs(_linearDiagram(100), iterations: 3);

      final base10 = time10 > 0 ? time10 : 1;
      final base50 = time50 > 0 ? time50 : 1;

      final ratio50 = time50 / base10;
      final ratio100 = time100 / base50;

      final expected50 = (50 / 10) * 1.5;
      final expected100 = (100 / 50) * 1.5;

      _evidenceMap['CR-04'] = '${ratio100.toStringAsFixed(2)}x (O(n) mantenido)';
      expect(ratio50, lessThanOrEqualTo(expected50));
      expect(ratio100, lessThanOrEqualTo(expected100));
    });
  });

  group('RB-01 a RB-07: criterios de robustez', () {
    test('RB-01: expresion lexicamente invalida reporta error', () {
      final nodes = [
        _terminalNode('rb01_start', 'Inicio', 50),
        _processNode('rb01_bad', 'int x = 5 @ 2', 150),
        _terminalNode('rb01_end', 'Fin', 250),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-01'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
          result.errors
              .getByPhase(CompilerPhase.lexical)
              .any((e) => e.code == CompilerErrorCode.unexpectedCharacter),
          isTrue);
    });

    test('RB-02: expresion sintacticamente malformada reporta error', () {
      final nodes = [
        _terminalNode('rb02_start', 'Inicio', 50),
        _processNode('rb02_decl', 'int x = 1', 150),
        _decisionNode('rb02_dec', 'x >', 250),
        _terminalNode('rb02_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      final syntacticErrors = result.errors.getByPhase(CompilerPhase.syntactic);
      _evidenceMap['RB-02'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(syntacticErrors.isNotEmpty, isTrue);
    });

    test('RB-03: variable usada sin declaracion previa', () {
      final nodes = [
        _terminalNode('rb03_start', 'Inicio', 50),
        _processNode('rb03_decl', 'int x = 1', 150),
        _processNode('rb03_use', 'x = y + 1', 250),
        _terminalNode('rb03_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-03'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
        result.errors.all.any((e) =>
            e.code == CompilerErrorCode.undeclaredVariable &&
            e.phase == CompilerPhase.semantic),
        isTrue,
      );
    });

    test('RB-04: declaracion duplicada reporta error', () {
      final nodes = [
        _terminalNode('rb04_start', 'Inicio', 50),
        _processNode('rb04_decl1', 'int x = 1', 150),
        _processNode('rb04_decl2', 'int x = 2', 250),
        _terminalNode('rb04_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-04'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
        result.errors.all.any((e) =>
            e.code == CompilerErrorCode.duplicateDeclaration &&
            e.phase == CompilerPhase.semantic),
        isTrue,
      );
    });

    test('RB-05: division por cero literal detectada en fase semantica', () {
      final nodes = [
        _terminalNode('rb05_start', 'Inicio', 50),
        _processNode('rb05_decl', 'int x = 10', 150),
        _processNode('rb05_div', 'x = x / 0', 250),
        _terminalNode('rb05_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-05'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
        result.errors.all.any((e) =>
            e.code == CompilerErrorCode.divisionByZero &&
            e.phase == CompilerPhase.semantic),
        isTrue,
      );
    });

    test('RB-06: tipos incompatibles generan advertencia', () {
      final nodes = [
        _terminalNode('rb06_start', 'Inicio', 50),
        _processNode('rb06_decl', 'int x = 0', 150),
        _processNode('rb06_assign', 'x = "hola"', 250),
        _terminalNode('rb06_end', 'Fin', 350),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-06'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
        result.errors.all.any((e) =>
            e.code == CompilerErrorCode.typeMismatch &&
            e.severity == CompilerSeverity.warning &&
            e.phase == CompilerPhase.semantic),
        isTrue,
      );
    });

    test('RB-07: variable declarada pero no usada genera advertencia', () {
      final nodes = [
        _terminalNode('rb07_start', 'Inicio', 50),
        _processNode('rb07_decl', 'int x = 0', 150),
        _terminalNode('rb07_end', 'Fin', 250),
      ];
      final connections = _connectLinear(nodes);

      final result = nodes.compile(connections);

      _evidenceMap['RB-07'] = '${result.errors.all.isNotEmpty ? result.errors.all.first.message : "Ningún error reportado"}';
      expect(
        result.errors.all.any((e) =>
            e.code == CompilerErrorCode.unusedVariable &&
            e.severity == CompilerSeverity.warning &&
            e.phase == CompilerPhase.semantic),
        isTrue,
      );
    });
  });
  tearDownAll(() {
    final groups = {
      'CF': 'Criterios de Corrección Funcional',
      'CG': 'Criterios de Calidad de Código Generado',
      'CR': 'Criterios de Rendimiento',
      'RB': 'Criterios de Robustez'
    };
    
    // Si flutter test oculta los prints en success, usamos stderr o throw al final si es necesario.
    // Usaremos un string final y stderr.writeln para asegurar que salga en la consola.
    final buffer = StringBuffer();
    buffer.writeln('\n======================================================');
    buffer.writeln(' RESULTADOS DE CRITERIOS DE VALIDACIÓN TÉCNICA');
    buffer.writeln('======================================================');
    
    for (var group in groups.entries) {
      buffer.writeln('\n--- ${group.key} - ${group.value} ---');
      
      final keys = _evidenceMap.keys.where((k) => k.startsWith(group.key)).toList()..sort();
      for (var key in keys) {
        buffer.writeln('\n[$key]:');
        buffer.writeln(_evidenceMap[key]);
      }
    }
    
    // Forzamos la impresión usando stderr para saltar el silenciador de flutter test
    stderr.writeln(buffer.toString());
  });
}

DiagramNode _terminalNode(String id, String text, double y) {
  return DiagramNode(
    id: id,
    type: NodeType.terminal,
    position: Offset(200, y),
    text: text,
  );
}

DiagramNode _processNode(String id, String text, double y) {
  return DiagramNode(
    id: id,
    type: NodeType.process,
    position: Offset(200, y),
    text: text,
  );
}

DiagramNode _decisionNode(String id, String text, double y,
    {Map<String, dynamic>? metadata}) {
  return DiagramNode(
    id: id,
    type: NodeType.decision,
    position: Offset(200, y),
    text: text,
    metadata: metadata,
  );
}

DiagramNode _preparationNode(String id, String text, double y,
    {Map<String, dynamic>? metadata}) {
  return DiagramNode(
    id: id,
    type: NodeType.preparation,
    position: Offset(200, y),
    text: text,
    metadata: metadata,
  );
}

DiagramNode _dataNode(String id, String text, double y,
    {Map<String, dynamic>? metadata}) {
  return DiagramNode(
    id: id,
    type: NodeType.data,
    position: Offset(200, y),
    text: text,
    metadata: metadata,
  );
}

List<Connection> _connectLinear(List<DiagramNode> nodes) {
  final connections = <Connection>[];
  for (var i = 0; i < nodes.length - 1; i++) {
    connections.add(Connection(source: nodes[i], target: nodes[i + 1]));
  }
  return connections;
}

DiagramCase _linearDiagram(int nodeCount) {
  if (nodeCount < 2) {
    throw ArgumentError('nodeCount must be >= 2');
  }

  final nodes = <DiagramNode>[];
  nodes.add(_terminalNode('perf_start_$nodeCount', 'Inicio', 50));

  if (nodeCount > 2) {
    nodes.add(_processNode('perf_decl_$nodeCount', 'int x = 0', 150));
    for (var i = 0; i < nodeCount - 3; i++) {
      nodes.add(
          _processNode('perf_step_${nodeCount}_$i', 'x = x + 1', 230 + i * 60));
    }
  }

  nodes.add(_terminalNode('perf_end_$nodeCount', 'Fin', 250 + nodeCount * 60));

  final connections = _connectLinear(nodes);
  return DiagramCase(nodes, connections);
}

double _averageCompileMs(DiagramCase diagram, {int iterations = 3}) {
  final times = <int>[];
  for (var i = 0; i < iterations; i++) {
    final result = diagram.nodes.compile(diagram.connections);
    expect(result.success, isTrue);
    times.add(result.metrics.compilationTimeMs);
  }

  final total = times.fold<int>(0, (sum, value) => sum + value);
  return total / times.length;
}

List<String> _mainBodyLines(String code) {
  final lines = code.split('\n');
  final mainIndex = lines.indexWhere((line) => line.contains('int main('));
  if (mainIndex == -1) return [];

  var endIndex = lines.lastIndexWhere((line) => line.trim() == '}');
  if (endIndex == -1 || endIndex <= mainIndex) {
    endIndex = lines.length;
  }

  return lines.sublist(mainIndex + 1, endIndex);
}

int _leadingSpaces(String line) {
  var count = 0;
  for (var i = 0; i < line.length; i++) {
    if (line[i] == ' ') {
      count++;
    } else {
      break;
    }
  }
  return count;
}

String _findLine(String code, bool Function(String) predicate) {
  for (final line in code.split('\n')) {
    if (predicate(line)) {
      return line;
    }
  }
  return '';
}