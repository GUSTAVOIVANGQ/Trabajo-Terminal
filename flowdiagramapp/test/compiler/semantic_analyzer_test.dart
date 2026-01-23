import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flowdiagramapp/compiler/compiler_pipeline.dart';
import 'package:flowdiagramapp/compiler/semantic_analyzer.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';

void main() {
  group('DiagramSemanticAnalyzer - Basic Tests', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Create analyzer instance', () {
      expect(analyzer, isNotNull);
    });
  });

  group('DiagramSemanticAnalyzer - Undeclared Variables', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Detect undeclared variable in process node', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = y + 5', // 'y' is not declared
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // Should have error for undeclared 'y'
      expect(
          result.errors.any((e) =>
              e.code == CompilerErrorCode.undeclaredVariable &&
              e.message.contains('y')),
          true);
    });

    test('No error for declared variable', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 0',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = x + 5',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // Should have no errors for undeclared variables related to 'x'
      expect(
          result.errors
              .where((e) =>
                  e.code == CompilerErrorCode.undeclaredVariable &&
                  e.message.contains('x'))
              .length,
          0);
    });

    test('Detect undeclared variable in decision node', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'dec',
          type: NodeType.decision,
          position: const Offset(100, 150),
          text: 'unknown > 10', // 'unknown' is not declared
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) =>
              e.code == CompilerErrorCode.undeclaredVariable &&
              e.message.contains('unknown')),
          true);
    });
  });

  group('DiagramSemanticAnalyzer - Duplicate Declarations', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Detect duplicate declaration', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl1',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 0',
        ),
        DiagramNode(
          id: 'decl2',
          type: NodeType.preparation,
          position: const Offset(100, 150),
          text: 'int x = 5', // Duplicate declaration
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors
              .any((e) => e.code == CompilerErrorCode.duplicateDeclaration),
          true);
    });
  });

  group('DiagramSemanticAnalyzer - Type Checking', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Type inference for integer literal', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 42',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(result.typeEnvironment.variableTypes['x'], DataType.integer);
    });

    test('Type inference for float literal', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'float pi = 3.14',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(result.typeEnvironment.variableTypes['pi'], DataType.float);
    });

    test('Type mismatch warning for incompatible assignment', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 0',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = "hello"', // Assigning string to int
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // Should have type mismatch warning
      expect(
          result.warnings.any((e) => e.code == CompilerErrorCode.typeMismatch),
          true);
    });
  });

  group('DiagramSemanticAnalyzer - Division by Zero', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Detect division by zero', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 10',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = x / 0', // Division by zero
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) => e.code == CompilerErrorCode.divisionByZero),
          true);
    });

    test('Detect modulo by zero', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 10',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text:
              'x = x%(0)', // Modulo by zero (without space to avoid lexer issue)
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) => e.code == CompilerErrorCode.divisionByZero),
          true);
    });
  });

  group('DiagramSemanticAnalyzer - Unused Variables', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Warn about unused variable', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int unused = 0', // Declared but never used
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.warnings.any((e) =>
              e.code == CompilerErrorCode.unusedVariable &&
              e.message.contains('unused')),
          true);
    });

    test('No warning for used variable', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int counter = 0',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'counter = counter + 1',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.warnings
              .where((e) =>
                  e.code == CompilerErrorCode.unusedVariable &&
                  e.message.contains('counter'))
              .length,
          0);
    });
  });

  group('DiagramSemanticAnalyzer - Data Nodes (I/O)', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Detect undeclared variable in input', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'input',
          type: NodeType.data,
          position: const Offset(100, 100),
          text: 'Leer(undeclared)',
          metadata: {'dataDirection': 'input'},
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) =>
              e.code == CompilerErrorCode.undeclaredVariable &&
              e.message.contains('undeclared')),
          true);
    });

    test('Detect undeclared variable in output', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'output',
          type: NodeType.data,
          position: const Offset(100, 100),
          text: 'Mostrar(missing)',
          metadata: {'dataDirection': 'output'},
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) =>
              e.code == CompilerErrorCode.undeclaredVariable &&
              e.message.contains('missing')),
          true);
    });

    test('Valid input/output with declared variable', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int valor = 0',
        ),
        DiagramNode(
          id: 'input',
          type: NodeType.data,
          position: const Offset(100, 150),
          text: 'Leer(valor)',
          metadata: {'dataDirection': 'input'},
        ),
        DiagramNode(
          id: 'output',
          type: NodeType.data,
          position: const Offset(100, 200),
          text: 'Mostrar(valor)',
          metadata: {'dataDirection': 'output'},
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // No undeclared variable errors for 'valor'
      expect(
          result.errors
              .where((e) =>
                  e.code == CompilerErrorCode.undeclaredVariable &&
                  e.message.contains('valor'))
              .length,
          0);
    });
  });

  group('DiagramSemanticAnalyzer - Loop Nodes', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Analyze loop condition with declared variable', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int i = 0',
        ),
        DiagramNode(
          id: 'loop',
          type: NodeType.loopLimit,
          position: const Offset(100, 150),
          text: 'i < 10',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // No errors for undeclared 'i'
      expect(
          result.errors
              .where((e) =>
                  e.code == CompilerErrorCode.undeclaredVariable &&
                  e.message.contains('i'))
              .length,
          0);
    });

    test('Detect undeclared variable in loop', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'loop',
          type: NodeType.loopLimit,
          position: const Offset(100, 100),
          text: 'missing < 100',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(
          result.errors.any((e) =>
              e.code == CompilerErrorCode.undeclaredVariable &&
              e.message.contains('missing')),
          true);
    });
  });

  group('SemanticAnalysisResult Tests', () {
    test('Result properties', () {
      final result = SemanticAnalysisResult(
        isValid: true,
        errors: [],
        warnings: [],
        nodeResults: {},
        symbolTable: SymbolTable(),
        typeEnvironment: const TypeEnvironment(),
        scopeAnalysis: const ScopeAnalysisResult(),
      );

      expect(result.isValid, true);
      expect(result.errorCount, 0);
      expect(result.warningCount, 0);
      expect(result.hasUndeclaredVariables, false);
      expect(result.hasTypeMismatches, false);
    });

    test('Result with errors', () {
      final errors = [
        CompilerError.semantic(
          code: CompilerErrorCode.undeclaredVariable,
          message: 'Variable x no declarada',
        ),
      ];

      final result = SemanticAnalysisResult(
        isValid: false,
        errors: errors,
        warnings: [],
        nodeResults: {},
        symbolTable: SymbolTable(),
        typeEnvironment: const TypeEnvironment(),
        scopeAnalysis: const ScopeAnalysisResult(),
      );

      expect(result.isValid, false);
      expect(result.errorCount, 1);
      expect(result.hasUndeclaredVariables, true);
    });
  });

  group('TypeEnvironment Tests', () {
    test('Create type environment', () {
      const env = TypeEnvironment(
        variableTypes: {'x': DataType.integer, 'y': DataType.float},
        expressionTypes: {},
        functionReturnTypes: {},
        arrayElementTypes: {},
      );

      expect(env.variableTypes['x'], DataType.integer);
      expect(env.variableTypes['y'], DataType.float);
    });

    test('Copy with modifications', () {
      const env = TypeEnvironment(
        variableTypes: {'x': DataType.integer},
      );

      final modified = env.copyWith(
        variableTypes: {'x': DataType.integer, 'z': DataType.string},
      );

      expect(modified.variableTypes['z'], DataType.string);
      expect(env.variableTypes.containsKey('z'), false);
    });
  });

  group('SemanticError Factory Tests', () {
    test('Create undeclared variable error', () {
      final error = SemanticError.undeclaredVariable('myVar');

      expect(error.code, CompilerErrorCode.undeclaredVariable);
      expect(error.message, contains('myVar'));
      expect(error.phase, CompilerPhase.semantic);
    });

    test('Create duplicate declaration error', () {
      final error = SemanticError.duplicateDeclaration('x');

      expect(error.code, CompilerErrorCode.duplicateDeclaration);
      expect(error.message, contains('x'));
    });

    test('Create type mismatch error', () {
      final error = SemanticError.typeMismatch(
        expected: DataType.integer,
        actual: DataType.string,
      );

      expect(error.code, CompilerErrorCode.typeMismatch);
      expect(error.message, contains('int'));
      expect(error.message, contains('char*'));
    });

    test('Create division by zero error', () {
      final error = SemanticError.divisionByZero();

      expect(error.code, CompilerErrorCode.divisionByZero);
    });

    test('Create unused variable warning', () {
      final error = SemanticError.unusedVariable('temp');

      expect(error.code, CompilerErrorCode.unusedVariable);
      expect(error.severity, CompilerSeverity.warning);
      expect(error.message, contains('temp'));
    });

    test('Create uninitialized variable warning', () {
      final error = SemanticError.uninitializedVariable('count');

      expect(error.code, CompilerErrorCode.uninitializedVariable);
      expect(error.severity, CompilerSeverity.warning);
      expect(error.message, contains('count'));
    });
  });

  group('Report Generation', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Generate report for valid diagram', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 10',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = x + 1',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);
      final report = analyzer.generateReport(result);

      expect(report, contains('REPORTE'));
      expect(report, contains('SEMÁNTICO'));
      expect(report, contains('TABLA DE SÍMBOLOS'));
    });

    test('Generate report with errors', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = undeclared',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);
      final report = analyzer.generateReport(result);

      expect(report, contains('ERRORES'));
    });
  });

  group('Compiler Pipeline Integration', () {
    test('Pipeline runs semantic analysis', () {
      final pipeline = DiagramCompilerPipeline();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int x = 5',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = x + 1',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      expect(result.semanticResult, isNotNull);
      expect(result.semanticResult!.symbolTable, isNotNull);
    });

    test('Pipeline fails on semantic errors', () {
      final pipeline = DiagramCompilerPipeline();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'x = unknown + 5', // 'unknown' not declared
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      // Should have semantic errors
      expect(result.errors.all.any((e) => e.phase == CompilerPhase.semantic),
          true);
    });

    test('Pipeline runSemanticAnalysis utility', () {
      final pipeline = DiagramCompilerPipeline();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int count = 0',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = pipeline.runSemanticAnalysis(nodes, []);

      expect(result, isNotNull);
      expect(result.symbolTable.symbolCount, greaterThan(0));
    });
  });

  group('Extension Methods', () {
    test('List<DiagramNode>.analyzeSemantically', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'int valor = 42',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = nodes.analyzeSemantically([]);

      expect(result, isNotNull);
      expect(result.typeEnvironment.variableTypes['valor'], DataType.integer);
    });
  });

  group('NodeSemanticResult Tests', () {
    test('Create node result', () {
      const result = NodeSemanticResult(
        nodeId: 'test-node',
        isValid: true,
        errors: [],
        warnings: [],
        variablesUsed: {'x', 'y'},
        variablesDeclared: {'z'},
        variablesModified: {'x'},
      );

      expect(result.nodeId, 'test-node');
      expect(result.isValid, true);
      expect(result.variablesUsed.contains('x'), true);
      expect(result.variablesUsed.contains('y'), true);
      expect(result.variablesDeclared.contains('z'), true);
      expect(result.variablesModified.contains('x'), true);
    });
  });

  group('Spanish Keywords Support', () {
    late DiagramSemanticAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSemanticAnalyzer();
    });

    test('Support Spanish type keywords', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'decl',
          type: NodeType.preparation,
          position: const Offset(100, 100),
          text: 'entero contador = 0',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'contador = contador + 1',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 200),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      // Should recognize 'entero' as integer type
      expect(
          result.typeEnvironment.variableTypes['contador'], DataType.integer);
    });
  });
}
