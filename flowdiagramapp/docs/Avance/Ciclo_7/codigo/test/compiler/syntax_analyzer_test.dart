import 'package:flutter_test/flutter_test.dart';
import 'package:flowdiagramapp/compiler/compiler.dart';
import 'package:flowdiagramapp/compiler/ast_nodes.dart';
import 'package:flowdiagramapp/compiler/syntax_analyzer.dart';
import 'package:flowdiagramapp/models/diagram_node.dart';

void main() {
  group('AST Node Tests', () {
    test('IntegerLiteralNode creation', () {
      final node = IntegerLiteralNode(
        value: 42,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.value, 42);
      expect(node.children, isEmpty);
      expect(node.toTreeString(), contains('IntegerLiteral(42)'));
    });

    test('FloatLiteralNode creation', () {
      final node = FloatLiteralNode(
        value: 3.14,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.value, 3.14);
      expect(node.toTreeString(), contains('FloatLiteral(3.14)'));
    });

    test('StringLiteralNode creation', () {
      final node = StringLiteralNode(
        value: 'hello',
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.value, 'hello');
      expect(node.toTreeString(), contains('StringLiteral("hello")'));
    });

    test('IdentifierNode creation', () {
      final node = IdentifierNode(
        name: 'myVar',
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.name, 'myVar');
      expect(node.toTreeString(), contains('Identifier(myVar)'));
    });

    test('BinaryExpressionNode creation', () {
      final left = IntegerLiteralNode(
        value: 5,
        position: const SourcePosition(line: 1, column: 1),
      );
      final right = IntegerLiteralNode(
        value: 3,
        position: const SourcePosition(line: 1, column: 5),
      );
      final node = BinaryExpressionNode(
        left: left,
        operator: BinaryOperator.add,
        right: right,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.operator, BinaryOperator.add);
      expect(node.children.length, 2);
      expect(node.toTreeString(), contains('BinaryExpr(+)'));
    });

    test('AssignmentExpressionNode creation', () {
      final target = IdentifierNode(
        name: 'x',
        position: const SourcePosition(line: 1, column: 1),
      );
      final value = IntegerLiteralNode(
        value: 10,
        position: const SourcePosition(line: 1, column: 5),
      );
      final node = AssignmentExpressionNode(
        target: target,
        operator: AssignmentOperator.assign,
        value: value,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.operator, AssignmentOperator.assign);
      expect(node.children.length, 2);
      expect(node.toTreeString(), contains('Assignment(=)'));
    });
  });

  group('BinaryOperator Extension Tests', () {
    test('BinaryOperator symbols', () {
      expect(BinaryOperator.add.symbol, '+');
      expect(BinaryOperator.subtract.symbol, '-');
      expect(BinaryOperator.multiply.symbol, '*');
      expect(BinaryOperator.divide.symbol, '/');
      expect(BinaryOperator.modulo.symbol, '%');
      expect(BinaryOperator.equal.symbol, '==');
      expect(BinaryOperator.notEqual.symbol, '!=');
      expect(BinaryOperator.less.symbol, '<');
      expect(BinaryOperator.greater.symbol, '>');
      expect(BinaryOperator.and.symbol, '&&');
      expect(BinaryOperator.or.symbol, '||');
    });

    test('BinaryOperator from TokenType', () {
      expect(BinaryOperatorExtension.fromTokenType(TokenType.opPlus),
          BinaryOperator.add);
      expect(BinaryOperatorExtension.fromTokenType(TokenType.opMinus),
          BinaryOperator.subtract);
      expect(BinaryOperatorExtension.fromTokenType(TokenType.opMultiply),
          BinaryOperator.multiply);
      expect(BinaryOperatorExtension.fromTokenType(TokenType.opEqual),
          BinaryOperator.equal);
      expect(BinaryOperatorExtension.fromTokenType(TokenType.opAnd),
          BinaryOperator.and);
    });
  });

  group('UnaryOperator Extension Tests', () {
    test('UnaryOperator symbols', () {
      expect(UnaryOperator.negate.symbol, '-');
      expect(UnaryOperator.not.symbol, '!');
      expect(UnaryOperator.preIncrement.symbol, '++');
      expect(UnaryOperator.postDecrement.symbol, '--');
    });

    test('UnaryOperator isPrefix', () {
      expect(UnaryOperator.negate.isPrefix, true);
      expect(UnaryOperator.not.isPrefix, true);
      expect(UnaryOperator.preIncrement.isPrefix, true);
      expect(UnaryOperator.postIncrement.isPrefix, false);
      expect(UnaryOperator.postDecrement.isPrefix, false);
    });
  });

  group('DiagramSyntaxAnalyzer - Expression Parsing', () {
    late DiagramSyntaxAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSyntaxAnalyzer();
    });

    test('Parse integer literal', () {
      final ast = analyzer.parseExpression('42');

      expect(ast, isA<IntegerLiteralNode>());
      expect((ast as IntegerLiteralNode).value, 42);
    });

    test('Parse float literal', () {
      final ast = analyzer.parseExpression('3.14');

      expect(ast, isA<FloatLiteralNode>());
      expect((ast as FloatLiteralNode).value, closeTo(3.14, 0.001));
    });

    test('Parse string literal', () {
      final ast = analyzer.parseExpression('"hello"');

      expect(ast, isA<StringLiteralNode>());
      expect((ast as StringLiteralNode).value, 'hello');
    });

    test('Parse identifier', () {
      final ast = analyzer.parseExpression('myVariable');

      expect(ast, isA<IdentifierNode>());
      expect((ast as IdentifierNode).name, 'myVariable');
    });

    test('Parse simple addition', () {
      final ast = analyzer.parseExpression('5 + 3');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.add);
      expect((binExpr.left as IntegerLiteralNode).value, 5);
      expect((binExpr.right as IntegerLiteralNode).value, 3);
    });

    test('Parse simple subtraction', () {
      final ast = analyzer.parseExpression('10 - 4');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.subtract);
    });

    test('Parse multiplication', () {
      final ast = analyzer.parseExpression('6 * 7');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.multiply);
    });

    test('Parse division', () {
      final ast = analyzer.parseExpression('20 / 4');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.divide);
    });

    test('Parse modulo', () {
      // Fixed: The lexer now correctly distinguishes between modulo operator and format specifiers
      // "a % b" is now correctly parsed as modulo, not as a format specifier
      final ast = analyzer.parseExpression('x % y');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.modulo);
      expect((binExpr.left as IdentifierNode).name, 'x');
      expect((binExpr.right as IdentifierNode).name, 'y');
    });

    test('Parse operator precedence (* before +)', () {
      final ast = analyzer.parseExpression('2 + 3 * 4');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.add);
      expect((binExpr.left as IntegerLiteralNode).value, 2);
      expect((binExpr.right as BinaryExpressionNode).operator,
          BinaryOperator.multiply);
    });

    test('Parse parenthesized expression', () {
      final ast = analyzer.parseExpression('(2 + 3) * 4');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.multiply);
      expect(
          (binExpr.left as BinaryExpressionNode).operator, BinaryOperator.add);
    });

    test('Parse comparison operators', () {
      final ast = analyzer.parseExpression('x > 5');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.greater);
    });

    test('Parse equality operators', () {
      final ast = analyzer.parseExpression('a == b');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.equal);
    });

    test('Parse logical AND', () {
      final ast = analyzer.parseExpression('x > 0 && y < 10');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.and);
    });

    test('Parse logical OR', () {
      final ast = analyzer.parseExpression('a || b');

      expect(ast, isA<BinaryExpressionNode>());
      final binExpr = ast as BinaryExpressionNode;
      expect(binExpr.operator, BinaryOperator.or);
    });

    test('Parse unary negation', () {
      final ast = analyzer.parseExpression('-5');

      expect(ast, isA<UnaryExpressionNode>());
      final unaryExpr = ast as UnaryExpressionNode;
      expect(unaryExpr.operator, UnaryOperator.negate);
    });

    test('Parse unary NOT', () {
      final ast = analyzer.parseExpression('!flag');

      expect(ast, isA<UnaryExpressionNode>());
      final unaryExpr = ast as UnaryExpressionNode;
      expect(unaryExpr.operator, UnaryOperator.not);
    });

    test('Parse pre-increment', () {
      final ast = analyzer.parseExpression('++i');

      expect(ast, isA<UnaryExpressionNode>());
      final unaryExpr = ast as UnaryExpressionNode;
      expect(unaryExpr.operator, UnaryOperator.preIncrement);
    });

    test('Parse post-increment', () {
      final ast = analyzer.parseExpression('i++');

      expect(ast, isA<UnaryExpressionNode>());
      final unaryExpr = ast as UnaryExpressionNode;
      expect(unaryExpr.operator, UnaryOperator.postIncrement);
    });

    test('Parse simple assignment', () {
      final ast = analyzer.parseExpression('x = 5');

      expect(ast, isA<AssignmentExpressionNode>());
      final assign = ast as AssignmentExpressionNode;
      expect(assign.operator, AssignmentOperator.assign);
      expect((assign.target as IdentifierNode).name, 'x');
      expect((assign.value as IntegerLiteralNode).value, 5);
    });

    test('Parse compound assignment +=', () {
      final ast = analyzer.parseExpression('x += 3');

      expect(ast, isA<AssignmentExpressionNode>());
      final assign = ast as AssignmentExpressionNode;
      expect(assign.operator, AssignmentOperator.addAssign);
    });

    test('Parse compound assignment -=', () {
      final ast = analyzer.parseExpression('y -= 2');

      expect(ast, isA<AssignmentExpressionNode>());
      final assign = ast as AssignmentExpressionNode;
      expect(assign.operator, AssignmentOperator.subtractAssign);
    });

    test('Parse function call', () {
      final ast = analyzer.parseExpression('sqrt(16)');

      expect(ast, isA<FunctionCallNode>());
      final call = ast as FunctionCallNode;
      expect(call.functionName, 'sqrt');
      expect(call.arguments.length, 1);
    });

    test('Parse function call with multiple arguments', () {
      final ast = analyzer.parseExpression('max(a, b, c)');

      expect(ast, isA<FunctionCallNode>());
      final call = ast as FunctionCallNode;
      expect(call.functionName, 'max');
      expect(call.arguments.length, 3);
    });

    test('Parse array access', () {
      final ast = analyzer.parseExpression('arr[0]');

      expect(ast, isA<ArrayAccessNode>());
      final access = ast as ArrayAccessNode;
      expect((access.array as IdentifierNode).name, 'arr');
      expect((access.index as IntegerLiteralNode).value, 0);
    });

    test('Parse conditional (ternary) expression', () {
      final ast = analyzer.parseExpression('x > 0 ? 1 : -1');

      expect(ast, isA<ConditionalExpressionNode>());
      final cond = ast as ConditionalExpressionNode;
      expect((cond.condition as BinaryExpressionNode).operator,
          BinaryOperator.greater);
    });

    test('Parse complex expression', () {
      final ast = analyzer.parseExpression('(a + b) * c - d / e % f');

      expect(ast, isA<BinaryExpressionNode>());
      // Should parse correctly respecting precedence
      expect(analyzer.errors, isEmpty);
    });
  });

  group('DiagramSyntaxAnalyzer - Validation', () {
    late DiagramSyntaxAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSyntaxAnalyzer();
    });

    test('Validate correct expression', () {
      expect(analyzer.validateExpression('x + 5'), true);
      expect(analyzer.validateExpression('a * (b + c)'), true);
      expect(analyzer.validateExpression('x = y + 1'), true);
    });

    test('Check balanced parentheses - valid', () {
      expect(analyzer.checkBalancedParentheses('(a + b)'), true);
      expect(analyzer.checkBalancedParentheses('((a))'), true);
      expect(analyzer.checkBalancedParentheses('a + b'), true);
    });

    test('Check balanced parentheses - invalid', () {
      expect(analyzer.checkBalancedParentheses('(a + b'), false);
      expect(analyzer.checkBalancedParentheses('a + b)'), false);
      expect(analyzer.checkBalancedParentheses('((a + b)'), false);
    });

    test('Check balanced brackets - valid', () {
      expect(analyzer.checkBalancedBrackets('arr[0]'), true);
      expect(analyzer.checkBalancedBrackets('arr[i][j]'), true);
    });

    test('Check balanced brackets - invalid', () {
      expect(analyzer.checkBalancedBrackets('arr[0'), false);
      expect(analyzer.checkBalancedBrackets('arr0]'), false);
    });

    test('Check balanced braces - valid', () {
      expect(analyzer.checkBalancedBraces('{}'), true);
      expect(analyzer.checkBalancedBraces('{{}}'), true);
    });

    test('Check balanced braces - invalid', () {
      expect(analyzer.checkBalancedBraces('{'), false);
      expect(analyzer.checkBalancedBraces('}'), false);
    });
  });

  group('DiagramSyntaxAnalyzer - Node Analysis', () {
    late DiagramSyntaxAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSyntaxAnalyzer();
    });

    test('Analyze process node with assignment', () {
      final node = DiagramNode(
        id: 'test-1',
        type: NodeType.process,
        position: const Offset(100, 100),
        text: 'x = 5',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isNotEmpty);
      expect(result.statements.first, isA<ExpressionStatementNode>());
    });

    test('Analyze process node with declaration', () {
      final node = DiagramNode(
        id: 'test-2',
        type: NodeType.preparation,
        position: const Offset(100, 100),
        text: 'int x = 10',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isNotEmpty);
      expect(result.statements.first, isA<DeclarationStatementNode>());
      final decl = result.statements.first as DeclarationStatementNode;
      expect(decl.dataType, DataType.integer);
      expect(decl.variableName, 'x');
    });

    test('Analyze process node with multiple variable declaration', () {
      // Test: int a, b, c should create 3 declarations
      final node = DiagramNode(
        id: 'test-multi-decl',
        type: NodeType.process,
        position: const Offset(100, 100),
        text: 'int a, b, c',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements.length, 3);

      // All should be DeclarationStatementNode with type int
      for (final stmt in result.statements) {
        expect(stmt, isA<DeclarationStatementNode>());
        expect((stmt as DeclarationStatementNode).dataType, DataType.integer);
      }

      // Check variable names
      expect(
          (result.statements[0] as DeclarationStatementNode).variableName, 'a');
      expect(
          (result.statements[1] as DeclarationStatementNode).variableName, 'b');
      expect(
          (result.statements[2] as DeclarationStatementNode).variableName, 'c');
    });

    test('Analyze process node with multiple float variables', () {
      final node = DiagramNode(
        id: 'test-multi-float',
        type: NodeType.process,
        position: const Offset(100, 100),
        text: 'float x, y, z',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements.length, 3);

      for (final stmt in result.statements) {
        expect(stmt, isA<DeclarationStatementNode>());
        expect((stmt as DeclarationStatementNode).dataType, DataType.float);
      }

      expect(
          (result.statements[0] as DeclarationStatementNode).variableName, 'x');
      expect(
          (result.statements[1] as DeclarationStatementNode).variableName, 'y');
      expect(
          (result.statements[2] as DeclarationStatementNode).variableName, 'z');
    });

    test('Analyze process node with multiple variables and initializer', () {
      // Test: int a = 1, b, c = 3 should work
      final node = DiagramNode(
        id: 'test-multi-init',
        type: NodeType.process,
        position: const Offset(100, 100),
        text: 'int a = 1, b, c = 3',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements.length, 3);

      final declA = result.statements[0] as DeclarationStatementNode;
      expect(declA.variableName, 'a');
      expect(declA.initializer, isNotNull);

      final declB = result.statements[1] as DeclarationStatementNode;
      expect(declB.variableName, 'b');
      expect(declB.initializer, isNull);

      final declC = result.statements[2] as DeclarationStatementNode;
      expect(declC.variableName, 'c');
      expect(declC.initializer, isNotNull);
    });

    test('Analyze decision node with condition', () {
      final node = DiagramNode(
        id: 'test-3',
        type: NodeType.decision,
        position: const Offset(100, 100),
        text: 'x > 0',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isNotEmpty);
    });

    test('Analyze terminal node (empty)', () {
      final node = DiagramNode(
        id: 'test-4',
        type: NodeType.terminal,
        position: const Offset(100, 100),
        text: 'Inicio',
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isEmpty);
    });

    test('Analyze data node with input (Spanish)', () {
      final node = DiagramNode(
        id: 'test-5',
        type: NodeType.data,
        position: const Offset(100, 100),
        text: 'Leer(x)',
        metadata: {'dataDirection': 'input'},
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isNotEmpty);
      expect(result.statements.first, isA<InputStatementNode>());
    });

    test('Analyze data node with output (Spanish)', () {
      final node = DiagramNode(
        id: 'test-6',
        type: NodeType.data,
        position: const Offset(100, 100),
        text: 'Mostrar(x)',
        metadata: {'dataDirection': 'output'},
      );

      final result = analyzer.analyzeNode(node);

      expect(result.isValid, true);
      expect(result.statements, isNotEmpty);
      expect(result.statements.first, isA<OutputStatementNode>());
    });
  });

  group('DiagramSyntaxAnalyzer - Diagram Analysis', () {
    late DiagramSyntaxAnalyzer analyzer;

    setUp(() {
      analyzer = DiagramSyntaxAnalyzer();
    });

    test('Analyze simple diagram', () {
      final startNode = DiagramNode(
        id: 'start',
        type: NodeType.terminal,
        position: const Offset(100, 50),
        text: 'Inicio',
      );
      final processNode = DiagramNode(
        id: 'process',
        type: NodeType.process,
        position: const Offset(100, 150),
        text: 'x = 5',
      );
      final endNode = DiagramNode(
        id: 'end',
        type: NodeType.terminal,
        position: const Offset(100, 250),
        text: 'Fin',
      );

      final nodes = [startNode, processNode, endNode];

      final connections = <Connection>[
        Connection(
          source: startNode,
          target: processNode,
        ),
        Connection(
          source: processNode,
          target: endNode,
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, connections);

      expect(result.isValid, true);
      expect(result.ast, isNotNull);
      expect(result.nodeResults.length, 3);
    });

    test('Analyze diagram with declarations and operations', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'prep',
          type: NodeType.preparation,
          position: const Offset(100, 150),
          text: 'int a = 0',
        ),
        DiagramNode(
          id: 'proc',
          type: NodeType.process,
          position: const Offset(100, 250),
          text: 'a = a + 1',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 350),
          text: 'Fin',
        ),
      ];

      final connections = <Connection>[];

      final result = analyzer.analyzeDiagram(nodes, connections);

      expect(result.isValid, true);
      expect(result.ast, isNotNull);
      expect(result.ast!.globalDeclarations, isNotEmpty);
    });

    test('Generate analysis report', () {
      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 150),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);
      final report = analyzer.generateReport(result);

      expect(report, contains('REPORTE'));
      expect(report, contains('Nodos analizados'));
    });
  });

  group('Statement Node Tests', () {
    test('DeclarationStatementNode with initializer', () {
      final init = IntegerLiteralNode(
        value: 5,
        position: const SourcePosition(line: 1, column: 10),
      );
      final node = DeclarationStatementNode(
        dataType: DataType.integer,
        variableName: 'count',
        initializer: init,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.dataType, DataType.integer);
      expect(node.variableName, 'count');
      expect(node.initializer, isNotNull);
      expect(node.toTreeString(), contains('Declaration'));
    });

    test('DeclarationStatementNode array', () {
      final node = DeclarationStatementNode(
        dataType: DataType.integer,
        variableName: 'arr',
        isArray: true,
        arraySize: 10,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.isArray, true);
      expect(node.arraySize, 10);
    });

    test('InputStatementNode creation', () {
      final vars = [
        IdentifierNode(
          name: 'x',
          position: const SourcePosition(line: 1, column: 6),
        ),
      ];
      final node = InputStatementNode(
        variables: vars,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.variables.length, 1);
      expect(node.toTreeString(), contains('InputStmt'));
    });

    test('OutputStatementNode creation', () {
      final exprs = [
        IdentifierNode(
          name: 'result',
          position: const SourcePosition(line: 1, column: 9),
        ),
      ];
      final node = OutputStatementNode(
        expressions: exprs,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.expressions.length, 1);
      expect(node.toTreeString(), contains('OutputStmt'));
    });

    test('BlockStatementNode creation', () {
      final stmts = [
        ExpressionStatementNode(
          expression: IntegerLiteralNode(
            value: 1,
            position: const SourcePosition(line: 2, column: 3),
          ),
          position: const SourcePosition(line: 2, column: 1),
        ),
      ];
      final node = BlockStatementNode(
        statements: stmts,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(node.statements.length, 1);
      expect(node.toTreeString(), contains('Block'));
    });
  });

  group('AST Visitor Tests', () {
    test('DefaultASTVisitor returns null', () {
      final visitor = DefaultASTVisitor<int>();
      final node = IntegerLiteralNode(
        value: 42,
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(visitor.visitIntegerLiteral(node), isNull);
    });

    test('NodeCollector collects specific node types', () {
      final root = BinaryExpressionNode(
        left: IntegerLiteralNode(
          value: 5,
          position: const SourcePosition(line: 1, column: 1),
        ),
        operator: BinaryOperator.add,
        right: IntegerLiteralNode(
          value: 3,
          position: const SourcePosition(line: 1, column: 5),
        ),
        position: const SourcePosition(line: 1, column: 1),
      );

      final collector = NodeCollector<IntegerLiteralNode>();
      collector.collect(root);

      expect(collector.nodes.length, 2);
    });
  });

  group('SyntaxError Tests', () {
    test('Create unexpected token error', () {
      final error = SyntaxError.unexpectedToken(
        'xyz',
        const SourceLocation(line: 1, column: 5),
        expected: 'operador',
      );

      expect(error.code, CompilerErrorCode.unexpectedToken);
      expect(error.message, contains('xyz'));
      expect(error.suggestion, isNotNull);
    });

    test('Create missing token error', () {
      final error = SyntaxError.missingToken(
        ')',
        const SourceLocation(line: 1, column: 10),
      );

      expect(error.code, CompilerErrorCode.missingToken);
      expect(error.message, contains(')'));
    });

    test('Create unbalanced parentheses error', () {
      final error = SyntaxError.unbalancedParentheses(
        const SourceLocation(line: 1, column: 1),
      );

      expect(error.code, CompilerErrorCode.unbalancedParentheses);
      expect(error.suggestion, isNotNull);
    });

    test('Create invalid expression error', () {
      final error = SyntaxError.invalidExpression(
        const SourceLocation(line: 1, column: 1),
        details: 'operando faltante',
      );

      expect(error.code, CompilerErrorCode.invalidExpression);
      expect(error.message, contains('operando faltante'));
    });
  });

  group('Compiler Pipeline Integration', () {
    test('Pipeline runs syntactic analysis', () {
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
          text: 'x = 10',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      expect(result.syntaxResult, isNotNull);
      expect(result.ast, isNotNull);
    });

    test('Pipeline parseExpression utility', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('a + b * c');

      expect(ast, isNotNull);
      expect(ast, isA<BinaryExpressionNode>());
    });

    test('Pipeline validateExpression utility', () {
      final pipeline = DiagramCompilerPipeline();

      expect(pipeline.validateExpression('x + 5'), true);
      expect(pipeline.checkBalancedParentheses('(a + b)'), true);
    });
  });

  group('Pointer Operators Tests', () {
    test('Address-of operator (&) parsing', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('&x');

      expect(ast, isNotNull);
      expect(ast, isA<UnaryExpressionNode>());
      final unary = ast as UnaryExpressionNode;
      expect(unary.operator, UnaryOperator.addressOf);
    });

    test('Dereference operator (*) parsing', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('*ptr');

      expect(ast, isNotNull);
      expect(ast, isA<UnaryExpressionNode>());
      final unary = ast as UnaryExpressionNode;
      expect(unary.operator, UnaryOperator.dereference);
    });

    test('Nested pointer operators', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('**ptr');

      expect(ast, isNotNull);
      expect(ast, isA<UnaryExpressionNode>());
    });

    test('Function call with address-of arguments', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('Swap(&a, &b)');

      expect(ast, isNotNull);
      expect(ast, isA<FunctionCallNode>());
      final call = ast as FunctionCallNode;
      expect(call.functionName, 'Swap');
      expect(call.arguments.length, 2);
      expect(call.arguments[0], isA<UnaryExpressionNode>());
      expect(call.arguments[1], isA<UnaryExpressionNode>());
    });
  });

  group('Return Statement Tests', () {
    test('Return statement in data node', () {
      final pipeline = DiagramCompilerPipeline();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio TestFunc(x)',
        ),
        DiagramNode(
          id: 'data',
          type: NodeType.data,
          position: const Offset(100, 150),
          text: 'return x',
          metadata: {'isReturn': true},
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin TestFunc',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      expect(result.syntaxResult, isNotNull);
      // Check that syntax analysis succeeded (return statement was parsed correctly)
      expect(result.syntaxResult!.isValid, isTrue,
          reason: 'Syntax analysis should succeed for return statement');
    });
  });

  group('Array Initializer Tests', () {
    test('Simple array initializer parsing', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('{1, 2, 3, 4, 5}');

      expect(ast, isNotNull);
      expect(ast, isA<ArrayInitializerNode>());
      final init = ast as ArrayInitializerNode;
      expect(init.elements.length, 5);
      expect(init.elements[0], isA<IntegerLiteralNode>());
      expect((init.elements[0] as IntegerLiteralNode).value, 1);
      expect((init.elements[4] as IntegerLiteralNode).value, 5);
    });

    test('Array initializer toCString', () {
      final init = ArrayInitializerNode(
        elements: [
          IntegerLiteralNode(
              value: 10, position: const SourcePosition(line: 1, column: 2)),
          IntegerLiteralNode(
              value: 25, position: const SourcePosition(line: 1, column: 5)),
          IntegerLiteralNode(
              value: 8, position: const SourcePosition(line: 1, column: 8)),
        ],
        position: const SourcePosition(line: 1, column: 1),
      );

      expect(init.toCString(), '{10, 25, 8}');
    });

    test('Array declaration with initializer in process node', () {
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
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'int arr[5] = {10, 25, 8, 42, 17}',
          metadata: {'processType': 'array_init'},
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      expect(result.success, isTrue);
      expect(result.syntaxResult, isNotNull);
      expect(result.syntaxResult!.errors, isEmpty);
    });

    test('Empty array initializer', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('{}');

      expect(ast, isNotNull);
      expect(ast, isA<ArrayInitializerNode>());
      final init = ast as ArrayInitializerNode;
      expect(init.elements.length, 0);
    });

    test('Nested array initializer (2D array)', () {
      final pipeline = DiagramCompilerPipeline();

      final ast = pipeline.parseExpression('{{1, 2}, {3, 4}}');

      expect(ast, isNotNull);
      expect(ast, isA<ArrayInitializerNode>());
      final init = ast as ArrayInitializerNode;
      expect(init.elements.length, 2);
      expect(init.elements[0], isA<ArrayInitializerNode>());
      expect(init.elements[1], isA<ArrayInitializerNode>());
    });
  });

  group('Pointer Declaration Tests', () {
    test('Pointer declaration: int *ptr', () {
      final analyzer = DiagramSyntaxAnalyzer();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'process',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'int *ptr',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(result.isValid, isTrue, reason: 'Should parse int *ptr');
      expect(result.errors, isEmpty);

      // Check AST
      expect(result.ast, isNotNull);
      final processNode = result.ast!.diagramNodes
          .firstWhere((n) => n.diagramNodeId == 'process');
      expect(processNode.statements, isNotEmpty);
      expect(processNode.statements.first, isA<DeclarationStatementNode>());

      final decl = processNode.statements.first as DeclarationStatementNode;
      expect(decl.variableName, 'ptr');
      expect(decl.dataType, DataType.integer);
      expect(decl.isPointer, isTrue);
    });

    test('Pointer declaration with initialization: int *ptr = arr', () {
      final analyzer = DiagramSyntaxAnalyzer();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'process_arr',
          type: NodeType.process,
          position: const Offset(100, 120),
          text: 'int arr[5]',
        ),
        DiagramNode(
          id: 'process_ptr',
          type: NodeType.process,
          position: const Offset(100, 190),
          text: 'int *ptr = arr',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 260),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(result.isValid, isTrue, reason: 'Should parse int *ptr = arr');
      expect(result.errors, isEmpty);

      // Check AST for pointer declaration
      expect(result.ast, isNotNull);
      final ptrNode = result.ast!.diagramNodes
          .firstWhere((n) => n.diagramNodeId == 'process_ptr');
      expect(ptrNode.statements, isNotEmpty);

      final decl = ptrNode.statements.first as DeclarationStatementNode;
      expect(decl.variableName, 'ptr');
      expect(decl.isPointer, isTrue);
      expect(decl.initializer, isNotNull);
    });

    test('Template P20 - Pointers and Arrays declaration', () {
      final pipeline = DiagramCompilerPipeline();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(280, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'process_arr',
          type: NodeType.process,
          position: const Offset(280, 140),
          text: 'int arr[5] = {10, 20, 30, 40, 50}',
        ),
        DiagramNode(
          id: 'process_ptr',
          type: NodeType.process,
          position: const Offset(280, 230),
          text: 'int *ptr = arr',
        ),
        DiagramNode(
          id: 'process_i',
          type: NodeType.process,
          position: const Offset(280, 320),
          text: 'int i',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(280, 730),
          text: 'Fin',
        ),
      ];

      final result = pipeline.compile(nodes, []);

      // Should compile without syntax errors
      final syntaxErrors = result.errors.all
          .where((e) =>
              e.code == CompilerErrorCode.unexpectedToken ||
              e.code == CompilerErrorCode.invalidDeclaration)
          .toList();
      expect(syntaxErrors, isEmpty,
          reason: 'Should not have syntax errors for pointer declaration');
    });

    test('Multiple pointer declarations: int *a, *b', () {
      final analyzer = DiagramSyntaxAnalyzer();

      final nodes = [
        DiagramNode(
          id: 'start',
          type: NodeType.terminal,
          position: const Offset(100, 50),
          text: 'Inicio',
        ),
        DiagramNode(
          id: 'process',
          type: NodeType.process,
          position: const Offset(100, 150),
          text: 'int *a, *b',
        ),
        DiagramNode(
          id: 'end',
          type: NodeType.terminal,
          position: const Offset(100, 250),
          text: 'Fin',
        ),
      ];

      final result = analyzer.analyzeDiagram(nodes, []);

      expect(result.isValid, isTrue);

      // Check AST
      expect(result.ast, isNotNull);
      final processNode = result.ast!.diagramNodes
          .firstWhere((n) => n.diagramNodeId == 'process');

      // Should have two declarations
      expect(processNode.statements.length, greaterThanOrEqualTo(2));

      final declA = processNode.statements[0] as DeclarationStatementNode;
      expect(declA.variableName, 'a');
      expect(declA.isPointer, isTrue);

      final declB = processNode.statements[1] as DeclarationStatementNode;
      expect(declB.variableName, 'b');
      expect(declB.isPointer, isTrue);
    });
  });
}
