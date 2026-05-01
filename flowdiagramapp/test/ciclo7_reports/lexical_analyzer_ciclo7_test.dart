/// Pruebas Selectivas del Análisis Léxico - Ciclo 7
/// Subconjunto representativo de 8 casos de prueba
/// Ejecutar con: flutter test test/ciclo7_reports/lexical_analyzer_ciclo7_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/token.dart';
import 'package:flowdiagramapp/compiler/lexical_analyzer.dart';

void main() {
  group('Análisis Léxico - Ciclo 7', () {
    late DiagramLexicalAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramLexicalAnalyzer();
    });

    // Caso 1: Identificadores válidos
    test('LE-01: Tokenización de identificadores simples', () {
      final tokens = analyzer.tokenize('variable');
      expect(tokens, isNotEmpty);
      expect(tokens.first.type, TokenType.identifier);
      expect(tokens.first.lexeme, 'variable');
    });

    // Caso 2: Literales enteros
    test('LE-02: Tokenización de literales enteros', () {
      final tokens = analyzer.tokenize('42');
      expect(tokens, isNotEmpty);
      expect(tokens.first.type, TokenType.integerLiteral);
    });

    // Caso 3: Literales flotantes
    test('LE-03: Tokenización de literales flotantes', () {
      final tokens = analyzer.tokenize('3.14');
      expect(tokens, isNotEmpty);
      expect(tokens.first.type, TokenType.floatLiteral);
    });

    // Caso 4: Palabras clave
    test('LE-04: Tokenización de palabras clave (int)', () {
      final tokens = analyzer.tokenize('int');
      expect(tokens, isNotEmpty);
      expect(tokens.first.type, TokenType.kwInt);
    });

    // Caso 5: Operadores aritméticos
    test('LE-05: Tokenización de operadores aritméticos', () {
      final tokens = analyzer.tokenize('+ - * /');
      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, contains(TokenType.opPlus));
      expect(types, contains(TokenType.opMinus));
      expect(types, contains(TokenType.opMultiply));
      expect(types, contains(TokenType.opDivide));
    });

    // Caso 6: Operadores relacionales
    test('LE-06: Tokenización de operadores relacionales', () {
      final tokens = analyzer.tokenize('< > == !=');
      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, contains(TokenType.opLess));
      expect(types, contains(TokenType.opGreater));
      expect(types, contains(TokenType.opEqual));
      expect(types, contains(TokenType.opNotEqual));
    });

    // Caso 7: Delimitadores
    test('LE-07: Tokenización de delimitadores', () {
      final tokens = analyzer.tokenize('( ) { } ;');
      final types =
          tokens.where((t) => t.isSignificant).map((t) => t.type).toList();
      expect(types, contains(TokenType.leftParen));
      expect(types, contains(TokenType.rightParen));
      expect(types, contains(TokenType.leftBrace));
      expect(types, contains(TokenType.rightBrace));
      expect(types, contains(TokenType.semicolon));
    });

    // Caso 8: Expresión compleja con múltiples tokens
    test('LE-08: Tokenización de expresión compleja', () {
      final tokens = analyzer.tokenize('int x = 10 + 5');
      final significantTokens = tokens.where((t) => t.isSignificant).toList();
      expect(significantTokens, isNotEmpty);
      expect(significantTokens.first.type, TokenType.kwInt);
      expect(significantTokens.length, greaterThan(2));
    });
  });
}
