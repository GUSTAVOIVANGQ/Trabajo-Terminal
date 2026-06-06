import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';
import 'package:flutter/material.dart';

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

void main() {
  test('CF-05', () {
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
    print("Success: " + result.success.toString());
    for (var err in result.errors.all) {
      print("Error: " + err.message + " at phase " + err.phase.toString());
    }
    print("Code: " + (result.generatedCode ?? ''));
  });
}
