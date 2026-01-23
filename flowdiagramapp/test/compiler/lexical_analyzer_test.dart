/// Tests for the FlowCode Lexical Analyzer
/// Run with: flutter test test/compiler/lexical_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/token.dart';
import 'package:flowdiagramapp/compiler/symbol_table.dart';
import 'package:flowdiagramapp/compiler/lexical_analyzer.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';

void main() {
  group('Token Tests', () {
    test('Token creation', () {
      final token = Token(
        type: TokenType.identifier,
        lexeme: 'variable',
        line: 1,
        column: 1,
      );

      expect(token.type, TokenType.identifier);
      expect(token.lexeme, 'variable');
      expect(token.isSignificant, true);
      expect(token.isError, false);
    });

    test('TokenType precedence', () {
      expect(
          TokenType.opMultiply.precedence > TokenType.opPlus.precedence, true);
      expect(TokenType.opAssign.precedence, 1);
      expect(TokenType.opAnd.precedence > TokenType.opOr.precedence, true);
    });

    test('TokenType properties', () {
      expect(TokenType.opPlus.isOperator, true);
      expect(TokenType.kwInt.isKeyword, true);
      expect(TokenType.integerLiteral.isLiteral, true);
      expect(TokenType.leftParen.isDelimiter, true);
    });
  });

  group('DiagramLexicalAnalyzer - Basic Tokenization', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Tokenize integer literal', () {
      final tokens = analyzer.tokenize('42');

      expect(tokens.length, 2); // Number + EOF
      expect(tokens[0].type, TokenType.integerLiteral);
      expect(tokens[0].lexeme, '42');
      expect(tokens[0].value, 42);
    });

    test('Tokenize float literal', () {
      final tokens = analyzer.tokenize('3.14');

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.floatLiteral);
      expect(tokens[0].value, 3.14);
    });

    test('Tokenize string literal', () {
      final tokens = analyzer.tokenize('"Hello World"');

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.stringLiteral);
      expect(tokens[0].value, 'Hello World');
    });

    test('Tokenize char literal', () {
      final tokens = analyzer.tokenize("'a'");

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.charLiteral);
      expect(tokens[0].value, 'a');
    });

    test('Tokenize identifier', () {
      final tokens = analyzer.tokenize('myVariable');

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.identifier);
      expect(tokens[0].lexeme, 'myVariable');
    });

    test('Tokenize C keyword', () {
      final tokens = analyzer.tokenize('int');

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.kwInt);
    });

    test('Tokenize Spanish keyword', () {
      final tokens = analyzer.tokenize('Leer');

      expect(tokens.length, 2);
      expect(tokens[0].type, TokenType.kwLeer);
    });
  });

  group('DiagramLexicalAnalyzer - Operators', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Tokenize arithmetic operators', () {
      final tokens = analyzer.tokenize('+ - * / %');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.opPlus,
        TokenType.opMinus,
        TokenType.opMultiply,
        TokenType.opDivide,
        TokenType.opModulo,
      ]);
    });

    test('Tokenize comparison operators', () {
      final tokens = analyzer.tokenize('== != < <= > >=');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.opEqual,
        TokenType.opNotEqual,
        TokenType.opLess,
        TokenType.opLessEqual,
        TokenType.opGreater,
        TokenType.opGreaterEqual,
      ]);
    });

    test('Tokenize logical operators', () {
      final tokens = analyzer.tokenize('&& || !');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.opAnd,
        TokenType.opOr,
        TokenType.opNot,
      ]);
    });

    test('Tokenize increment/decrement operators', () {
      final tokens = analyzer.tokenize('++ --');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.opIncrement,
        TokenType.opDecrement,
      ]);
    });

    test('Tokenize compound assignment operators', () {
      final tokens = analyzer.tokenize('+= -= *= /= %=');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.opPlusAssign,
        TokenType.opMinusAssign,
        TokenType.opMultiplyAssign,
        TokenType.opDivideAssign,
        TokenType.opModuloAssign,
      ]);
    });
  });

  group('DiagramLexicalAnalyzer - Expressions', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Tokenize simple assignment', () {
      final tokens = analyzer.tokenize('x = 5');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.identifier,
        TokenType.opAssign,
        TokenType.integerLiteral,
      ]);
    });

    test('Tokenize arithmetic expression', () {
      final tokens = analyzer.tokenize('a + b * 2');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.identifier,
        TokenType.opPlus,
        TokenType.identifier,
        TokenType.opMultiply,
        TokenType.integerLiteral,
      ]);
    });

    test('Tokenize declaration with initialization', () {
      final tokens = analyzer.tokenize('int contador = 0');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.kwInt,
        TokenType.identifier,
        TokenType.opAssign,
        TokenType.integerLiteral,
      ]);
    });

    test('Tokenize conditional expression', () {
      final tokens = analyzer.tokenize('x > 0 && x < 10');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.identifier,
        TokenType.opGreater,
        TokenType.integerLiteral,
        TokenType.opAnd,
        TokenType.identifier,
        TokenType.opLess,
        TokenType.integerLiteral,
      ]);
    });

    test('Tokenize function call pattern', () {
      final tokens = analyzer.tokenize('printf("%d", x)');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.kwPrintf,
        TokenType.leftParen,
        TokenType.stringLiteral,
        TokenType.comma,
        TokenType.identifier,
        TokenType.rightParen,
      ]);
    });

    test('Tokenize Spanish input statement', () {
      final tokens = analyzer.tokenize('Leer numero');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.kwLeer,
        TokenType.identifier,
      ]);
    });

    test('Tokenize Spanish output statement', () {
      final tokens = analyzer.tokenize('Mostrar resultado');

      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, [
        TokenType.kwMostrar,
        TokenType.identifier,
      ]);
    });
  });

  group('DiagramLexicalAnalyzer - Format Specifiers', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Tokenize %d format specifier', () {
      final tokens = analyzer.tokenize('%d');

      expect(tokens[0].type, TokenType.formatSpecifier);
      expect(tokens[0].lexeme, '%d');
    });

    test('Tokenize %f format specifier', () {
      final tokens = analyzer.tokenize('%f');

      expect(tokens[0].type, TokenType.formatSpecifier);
    });

    test('Tokenize %s format specifier', () {
      final tokens = analyzer.tokenize('%s');

      expect(tokens[0].type, TokenType.formatSpecifier);
    });
  });

  group('SymbolTable Tests', () {
    late SymbolTable symbolTable;

    setUp(() {
      symbolTable = SymbolTable();
    });

    test('Declare and lookup symbol', () {
      symbolTable.declareSymbol(
        name: 'x',
        dataType: DataType.integer,
      );

      final symbol = symbolTable.lookup('x');
      expect(symbol, isNotNull);
      expect(symbol!.name, 'x');
      expect(symbol.dataType, DataType.integer);
    });

    test('Symbol not found returns null', () {
      final symbol = symbolTable.lookup('nonexistent');
      expect(symbol, isNull);
    });

    test('Duplicate declaration creates error', () {
      symbolTable.declareSymbol(name: 'x', dataType: DataType.integer);
      final success =
          symbolTable.declareSymbol(name: 'x', dataType: DataType.float);

      expect(success, false);
      expect(symbolTable.errors.isNotEmpty, true);
    });

    test('Scope management', () {
      symbolTable.declareSymbol(name: 'global', dataType: DataType.integer);

      symbolTable.enterScope(description: 'if-block');
      symbolTable.declareSymbol(name: 'local', dataType: DataType.float);

      expect(symbolTable.lookup('global'), isNotNull);
      expect(symbolTable.lookup('local'), isNotNull);

      symbolTable.exitScope();

      expect(symbolTable.lookup('global'), isNotNull);
      // Local should still be in all symbols but not accessible in current scope
    });

    test('Mark symbol as used', () {
      symbolTable.declareSymbol(name: 'x', dataType: DataType.integer);
      symbolTable.markAsUsed('x');

      final symbol = symbolTable.lookup('x');
      expect(symbol!.isUsed, true);
    });

    test('Generate C declarations', () {
      symbolTable.declareSymbol(
        name: 'count',
        dataType: DataType.integer,
        isInitialized: true,
        initialValue: 0,
      );
      symbolTable.declareSymbol(
        name: 'total',
        dataType: DataType.float,
      );

      final declarations = symbolTable.generateCDeclarations();
      expect(declarations.contains('int'), true);
      expect(declarations.contains('float'), true);
    });
  });

  group('DiagramLexicalAnalyzer - Node Analysis', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Analyze process node', () {
      final node = DiagramNode(
        id: 'node1',
        type: NodeType.process,
        text: 'x = x + 1',
        position: Offset.zero,
      );

      final result = analyzer.analyzeNode(node);

      expect(result.nodeId, 'node1');
      expect(result.nodeType, NodeType.process);
      expect(result.isSuccess, true);
      expect(result.significantTokens.length, greaterThan(0));
    });

    test('Analyze data node with input', () {
      final node = DiagramNode(
        id: 'node2',
        type: NodeType.data,
        text: 'Leer numero',
        position: Offset.zero,
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isSuccess, true);
      expect(result.tokens.any((t) => t.type == TokenType.kwLeer), true);
    });

    test('Analyze decision node', () {
      final node = DiagramNode(
        id: 'node3',
        type: NodeType.decision,
        text: 'x > 0',
        position: Offset.zero,
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isSuccess, true);
      expect(result.tokens.any((t) => t.type == TokenType.opGreater), true);
    });
  });

  group('DiagramLexicalAnalyzer - Diagram Analysis', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Analyze simple diagram', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          text: 'Inicio',
          position: Offset.zero,
        ),
        DiagramNode(
          id: 'process1',
          type: NodeType.process,
          text: 'int x = 5',
          position: const Offset(0, 100),
        ),
        DiagramNode(
          id: 'output',
          type: NodeType.data,
          text: 'Mostrar x',
          position: const Offset(0, 200),
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          text: 'Fin',
          position: const Offset(0, 300),
        ),
      ];

      final connections = <Connection>[
        Connection(source: nodes[0], target: nodes[1], label: ''),
        Connection(source: nodes[1], target: nodes[2], label: ''),
        Connection(source: nodes[2], target: nodes[3], label: ''),
      ];

      final result = analyzer.analyzeDiagram(nodes, connections);

      expect(result.nodeResults.length, 4);
      expect(result.isSuccess, true);
      expect(result.symbolTable.symbolCount, greaterThan(0));
    });

    test('Generate lexical analysis report', () {
      final nodes = [
        DiagramNode(
          id: 'p1',
          type: NodeType.process,
          text: 'int contador = 0',
          position: Offset.zero,
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);
      final report = result.generateReport();

      expect(report.contains('REPORTE DE ANÁLISIS LÉXICO'), true);
      expect(report.contains('contador'), true);
    });
  });

  group('DiagramLexicalAnalyzer - Identifier Validation', () {
    test('Valid C identifiers', () {
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('x'), true);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('_var'), true);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('myVariable'), true);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('var123'), true);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('_underscore_'), true);
    });

    test('Invalid C identifiers', () {
      expect(DiagramLexicalAnalyzer.isValidCIdentifier(''), false);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('123var'), false);
      expect(DiagramLexicalAnalyzer.isValidCIdentifier('my-var'), false);
      expect(
          DiagramLexicalAnalyzer.isValidCIdentifier('int'), false); // keyword
      expect(
          DiagramLexicalAnalyzer.isValidCIdentifier('for'), false); // keyword
    });
  });

  group('DiagramLexicalAnalyzer - Error Handling', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    test('Handle unknown character', () {
      final tokens = analyzer.tokenize('@');

      expect(tokens.any((t) => t.type == TokenType.unknown), true);
    });

    test('Handle unterminated string', () {
      final node = DiagramNode(
        id: 'test',
        type: NodeType.data,
        text: '"unterminated',
        position: Offset.zero,
      );

      final result = analyzer.analyzeNode(node);

      // Should have error but still produce tokens
      expect(result.errors.isNotEmpty, true);
    });
  });

  group('DataType Tests', () {
    test('C representation', () {
      expect(DataType.integer.cRepresentation, 'int');
      expect(DataType.float.cRepresentation, 'float');
      expect(DataType.string.cRepresentation, 'char*');
    });

    test('Format specifiers', () {
      expect(DataType.integer.formatSpecifier, '%d');
      expect(DataType.float.formatSpecifier, '%f');
      expect(DataType.string.formatSpecifier, '%s');
      expect(DataType.char.formatSpecifier, '%c');
    });

    test('Type properties', () {
      expect(DataType.integer.isNumeric, true);
      expect(DataType.float.isNumeric, true);
      expect(DataType.string.isNumeric, false);
      expect(DataType.char.isArithmetic, true);
    });
  });
}
