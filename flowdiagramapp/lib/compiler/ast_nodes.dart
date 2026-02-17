/// AST Nodes for FlowCode Diagram Compiler
/// Defines the Abstract Syntax Tree node types for the syntactic analysis phase
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

import 'token.dart';
import 'symbol_table.dart';

/// Base class for all AST nodes
abstract class ASTNode {
  /// The source location of this node
  final SourcePosition position;

  /// Node ID from the diagram (optional)
  final String? nodeId;

  const ASTNode({
    required this.position,
    this.nodeId,
  });

  /// Accept a visitor
  T accept<T>(ASTVisitor<T> visitor);

  /// Get all child nodes
  List<ASTNode> get children;

  /// Convert to a readable string representation
  String toTreeString([int indent = 0]);

  /// Helper to create indentation
  String _indent(int level) => '  ' * level;
}

/// Source position information
class SourcePosition {
  final int line;
  final int column;
  final int? endLine;
  final int? endColumn;

  const SourcePosition({
    required this.line,
    required this.column,
    this.endLine,
    this.endColumn,
  });

  factory SourcePosition.fromToken(Token token) {
    return SourcePosition(
      line: token.line,
      column: token.column,
    );
  }

  @override
  String toString() => 'line $line, col $column';
}

// ============================================
// VISITOR PATTERN
// ============================================

/// Visitor interface for AST traversal
abstract class ASTVisitor<T> {
  // Literals
  T visitIntegerLiteral(IntegerLiteralNode node);
  T visitFloatLiteral(FloatLiteralNode node);
  T visitStringLiteral(StringLiteralNode node);
  T visitCharLiteral(CharLiteralNode node);
  T visitBooleanLiteral(BooleanLiteralNode node);

  // Identifiers
  T visitIdentifier(IdentifierNode node);

  // Expressions
  T visitBinaryExpression(BinaryExpressionNode node);
  T visitUnaryExpression(UnaryExpressionNode node);
  T visitAssignmentExpression(AssignmentExpressionNode node);
  T visitConditionalExpression(ConditionalExpressionNode node);
  T visitFunctionCall(FunctionCallNode node);
  T visitArrayAccess(ArrayAccessNode node);
  T visitArrayInitializer(ArrayInitializerNode node);

  // Statements
  T visitExpressionStatement(ExpressionStatementNode node);
  T visitDeclarationStatement(DeclarationStatementNode node);
  T visitInputStatement(InputStatementNode node);
  T visitOutputStatement(OutputStatementNode node);
  T visitIfStatement(IfStatementNode node);
  T visitWhileStatement(WhileStatementNode node);
  T visitForStatement(ForStatementNode node);
  T visitDoWhileStatement(DoWhileStatementNode node);
  T visitBlockStatement(BlockStatementNode node);
  T visitReturnStatement(ReturnStatementNode node);
  T visitBreakStatement(BreakStatementNode node);
  T visitContinueStatement(ContinueStatementNode node);

  // Program structure
  T visitProgram(ProgramNode node);
  T visitDiagramNode(DiagramASTNode node);
}

// ============================================
// LITERAL NODES
// ============================================

/// Integer literal: 42, -17, 0
class IntegerLiteralNode extends ASTNode {
  final int value;

  const IntegerLiteralNode({
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitIntegerLiteral(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}IntegerLiteral($value)';
}

/// Float literal: 3.14, -0.5, 1.0
class FloatLiteralNode extends ASTNode {
  final double value;

  const FloatLiteralNode({
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitFloatLiteral(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}FloatLiteral($value)';
}

/// String literal: "hello", "world"
class StringLiteralNode extends ASTNode {
  final String value;

  const StringLiteralNode({
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitStringLiteral(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}StringLiteral("$value")';
}

/// Character literal: 'a', 'X'
class CharLiteralNode extends ASTNode {
  final String value;

  const CharLiteralNode({
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitCharLiteral(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}CharLiteral(\'$value\')';
}

/// Boolean literal: true, false
class BooleanLiteralNode extends ASTNode {
  final bool value;

  const BooleanLiteralNode({
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitBooleanLiteral(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}BooleanLiteral($value)';
}

// ============================================
// IDENTIFIER NODE
// ============================================

/// Identifier: x, contador, suma
class IdentifierNode extends ASTNode {
  final String name;

  const IdentifierNode({
    required this.name,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitIdentifier(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) =>
      '${_indent(indent)}Identifier($name)';
}

// ============================================
// EXPRESSION NODES
// ============================================

/// Binary operators
enum BinaryOperator {
  // Arithmetic
  add, // +
  subtract, // -
  multiply, // *
  divide, // /
  modulo, // %

  // Comparison
  equal, // ==
  notEqual, // !=
  less, // <
  lessEqual, // <=
  greater, // >
  greaterEqual, // >=

  // Logical
  and, // &&
  or, // ||

  // Bitwise
  bitAnd, // &
  bitOr, // |
  bitXor, // ^
  shiftLeft, // <<
  shiftRight, // >>
}

/// Extension for BinaryOperator
extension BinaryOperatorExtension on BinaryOperator {
  String get symbol {
    switch (this) {
      case BinaryOperator.add:
        return '+';
      case BinaryOperator.subtract:
        return '-';
      case BinaryOperator.multiply:
        return '*';
      case BinaryOperator.divide:
        return '/';
      case BinaryOperator.modulo:
        return '%';
      case BinaryOperator.equal:
        return '==';
      case BinaryOperator.notEqual:
        return '!=';
      case BinaryOperator.less:
        return '<';
      case BinaryOperator.lessEqual:
        return '<=';
      case BinaryOperator.greater:
        return '>';
      case BinaryOperator.greaterEqual:
        return '>=';
      case BinaryOperator.and:
        return '&&';
      case BinaryOperator.or:
        return '||';
      case BinaryOperator.bitAnd:
        return '&';
      case BinaryOperator.bitOr:
        return '|';
      case BinaryOperator.bitXor:
        return '^';
      case BinaryOperator.shiftLeft:
        return '<<';
      case BinaryOperator.shiftRight:
        return '>>';
    }
  }

  /// Convert from TokenType
  static BinaryOperator? fromTokenType(TokenType type) {
    switch (type) {
      case TokenType.opPlus:
        return BinaryOperator.add;
      case TokenType.opMinus:
        return BinaryOperator.subtract;
      case TokenType.opMultiply:
        return BinaryOperator.multiply;
      case TokenType.opDivide:
        return BinaryOperator.divide;
      case TokenType.opModulo:
        return BinaryOperator.modulo;
      case TokenType.opEqual:
        return BinaryOperator.equal;
      case TokenType.opNotEqual:
        return BinaryOperator.notEqual;
      case TokenType.opLess:
        return BinaryOperator.less;
      case TokenType.opLessEqual:
        return BinaryOperator.lessEqual;
      case TokenType.opGreater:
        return BinaryOperator.greater;
      case TokenType.opGreaterEqual:
        return BinaryOperator.greaterEqual;
      case TokenType.opAnd:
        return BinaryOperator.and;
      case TokenType.opOr:
        return BinaryOperator.or;
      case TokenType.opBitAnd:
        return BinaryOperator.bitAnd;
      case TokenType.opBitOr:
        return BinaryOperator.bitOr;
      case TokenType.opBitXor:
        return BinaryOperator.bitXor;
      case TokenType.opShiftLeft:
        return BinaryOperator.shiftLeft;
      case TokenType.opShiftRight:
        return BinaryOperator.shiftRight;
      default:
        return null;
    }
  }
}

/// Binary expression: a + b, x > 5, etc.
class BinaryExpressionNode extends ASTNode {
  final ASTNode left;
  final BinaryOperator operator;
  final ASTNode right;

  const BinaryExpressionNode({
    required this.left,
    required this.operator,
    required this.right,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitBinaryExpression(this);

  @override
  List<ASTNode> get children => [left, right];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}BinaryExpr(${operator.symbol})');
    buffer.writeln(left.toTreeString(indent + 1));
    buffer.write(right.toTreeString(indent + 1));
    return buffer.toString();
  }
}

/// Unary operators
enum UnaryOperator {
  negate, // -
  not, // !
  bitNot, // ~
  preIncrement, // ++x
  preDecrement, // --x
  postIncrement, // x++
  postDecrement, // x--
  addressOf, // &x (address-of operator)
  dereference, // *x (pointer dereference)
}

/// Extension for UnaryOperator
extension UnaryOperatorExtension on UnaryOperator {
  String get symbol {
    switch (this) {
      case UnaryOperator.negate:
        return '-';
      case UnaryOperator.not:
        return '!';
      case UnaryOperator.bitNot:
        return '~';
      case UnaryOperator.preIncrement:
      case UnaryOperator.postIncrement:
        return '++';
      case UnaryOperator.preDecrement:
      case UnaryOperator.postDecrement:
        return '--';
      case UnaryOperator.addressOf:
        return '&';
      case UnaryOperator.dereference:
        return '*';
    }
  }

  bool get isPrefix {
    switch (this) {
      case UnaryOperator.negate:
      case UnaryOperator.not:
      case UnaryOperator.bitNot:
      case UnaryOperator.preIncrement:
      case UnaryOperator.preDecrement:
      case UnaryOperator.addressOf:
      case UnaryOperator.dereference:
        return true;
      case UnaryOperator.postIncrement:
      case UnaryOperator.postDecrement:
        return false;
    }
  }

  /// Convert from TokenType for prefix operators
  static UnaryOperator? fromTokenType(TokenType type, {bool isPrefix = true}) {
    switch (type) {
      case TokenType.opMinus:
        return UnaryOperator.negate;
      case TokenType.opNot:
        return UnaryOperator.not;
      case TokenType.opBitNot:
        return UnaryOperator.bitNot;
      case TokenType.opIncrement:
        return isPrefix
            ? UnaryOperator.preIncrement
            : UnaryOperator.postIncrement;
      case TokenType.opDecrement:
        return isPrefix
            ? UnaryOperator.preDecrement
            : UnaryOperator.postDecrement;
      case TokenType.opBitAnd:
        return UnaryOperator.addressOf;
      case TokenType.opMultiply:
        return UnaryOperator.dereference;
      default:
        return null;
    }
  }
}

/// Unary expression: -x, !condition, ++i
class UnaryExpressionNode extends ASTNode {
  final UnaryOperator operator;
  final ASTNode operand;

  const UnaryExpressionNode({
    required this.operator,
    required this.operand,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitUnaryExpression(this);

  @override
  List<ASTNode> get children => [operand];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}UnaryExpr(${operator.symbol})');
    buffer.write(operand.toTreeString(indent + 1));
    return buffer.toString();
  }
}

/// Assignment operators
enum AssignmentOperator {
  assign, // =
  addAssign, // +=
  subtractAssign, // -=
  multiplyAssign, // *=
  divideAssign, // /=
  moduloAssign, // %=
}

/// Extension for AssignmentOperator
extension AssignmentOperatorExtension on AssignmentOperator {
  String get symbol {
    switch (this) {
      case AssignmentOperator.assign:
        return '=';
      case AssignmentOperator.addAssign:
        return '+=';
      case AssignmentOperator.subtractAssign:
        return '-=';
      case AssignmentOperator.multiplyAssign:
        return '*=';
      case AssignmentOperator.divideAssign:
        return '/=';
      case AssignmentOperator.moduloAssign:
        return '%=';
    }
  }

  /// Convert from TokenType
  static AssignmentOperator? fromTokenType(TokenType type) {
    switch (type) {
      case TokenType.opAssign:
        return AssignmentOperator.assign;
      case TokenType.opPlusAssign:
        return AssignmentOperator.addAssign;
      case TokenType.opMinusAssign:
        return AssignmentOperator.subtractAssign;
      case TokenType.opMultiplyAssign:
        return AssignmentOperator.multiplyAssign;
      case TokenType.opDivideAssign:
        return AssignmentOperator.divideAssign;
      case TokenType.opModuloAssign:
        return AssignmentOperator.moduloAssign;
      default:
        return null;
    }
  }
}

/// Assignment expression: x = 5, y += 2
class AssignmentExpressionNode extends ASTNode {
  final ASTNode target;
  final AssignmentOperator operator;
  final ASTNode value;

  const AssignmentExpressionNode({
    required this.target,
    required this.operator,
    required this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitAssignmentExpression(this);

  @override
  List<ASTNode> get children => [target, value];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}Assignment(${operator.symbol})');
    buffer.writeln(target.toTreeString(indent + 1));
    buffer.write(value.toTreeString(indent + 1));
    return buffer.toString();
  }
}

/// Conditional expression: condition ? trueExpr : falseExpr
class ConditionalExpressionNode extends ASTNode {
  final ASTNode condition;
  final ASTNode trueExpression;
  final ASTNode falseExpression;

  const ConditionalExpressionNode({
    required this.condition,
    required this.trueExpression,
    required this.falseExpression,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) =>
      visitor.visitConditionalExpression(this);

  @override
  List<ASTNode> get children => [condition, trueExpression, falseExpression];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ConditionalExpr');
    buffer.writeln('${_indent(indent + 1)}Condition:');
    buffer.writeln(condition.toTreeString(indent + 2));
    buffer.writeln('${_indent(indent + 1)}True:');
    buffer.writeln(trueExpression.toTreeString(indent + 2));
    buffer.writeln('${_indent(indent + 1)}False:');
    buffer.write(falseExpression.toTreeString(indent + 2));
    return buffer.toString();
  }
}

/// Function call: printf("hello"), scanf("%d", &x)
class FunctionCallNode extends ASTNode {
  final String functionName;
  final List<ASTNode> arguments;

  const FunctionCallNode({
    required this.functionName,
    required this.arguments,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitFunctionCall(this);

  @override
  List<ASTNode> get children => arguments;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}FunctionCall($functionName)');
    for (var arg in arguments) {
      buffer.writeln(arg.toTreeString(indent + 1));
    }
    return buffer.toString().trimRight();
  }
}

/// Array access: arr[i], matrix[row][col]
class ArrayAccessNode extends ASTNode {
  final ASTNode array;
  final ASTNode index;

  const ArrayAccessNode({
    required this.array,
    required this.index,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitArrayAccess(this);

  @override
  List<ASTNode> get children => [array, index];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ArrayAccess');
    buffer.writeln(array.toTreeString(indent + 1));
    buffer.write(index.toTreeString(indent + 1));
    return buffer.toString();
  }
}

/// Array initializer: {1, 2, 3, 4, 5}
class ArrayInitializerNode extends ASTNode {
  final List<ASTNode> elements;

  const ArrayInitializerNode({
    required this.elements,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitArrayInitializer(this);

  @override
  List<ASTNode> get children => elements;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ArrayInitializer');
    for (var element in elements) {
      buffer.writeln(element.toTreeString(indent + 1));
    }
    return buffer.toString().trimRight();
  }

  /// Generate the C representation of this initializer
  String toCString() {
    return '{${elements.map((e) => _elementToCString(e)).join(', ')}}';
  }

  String _elementToCString(ASTNode element) {
    if (element is IntegerLiteralNode) {
      return element.value.toString();
    } else if (element is FloatLiteralNode) {
      return element.value.toString();
    } else if (element is StringLiteralNode) {
      return '"${element.value}"';
    } else if (element is CharLiteralNode) {
      return "'${element.value}'";
    } else if (element is BooleanLiteralNode) {
      return element.value ? '1' : '0';
    } else if (element is IdentifierNode) {
      return element.name;
    } else if (element is ArrayInitializerNode) {
      return element.toCString();
    }
    return element.toString();
  }
}

// ============================================
// STATEMENT NODES
// ============================================

/// Base class for statements
abstract class StatementNode extends ASTNode {
  const StatementNode({
    required super.position,
    super.nodeId,
  });
}

/// Expression statement: x = 5;
class ExpressionStatementNode extends StatementNode {
  final ASTNode expression;

  const ExpressionStatementNode({
    required this.expression,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitExpressionStatement(this);

  @override
  List<ASTNode> get children => [expression];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ExpressionStmt');
    buffer.write(expression.toTreeString(indent + 1));
    return buffer.toString();
  }
}

/// Declaration statement: int x = 5; or int *ptr = arr;
class DeclarationStatementNode extends StatementNode {
  final DataType dataType;
  final String variableName;
  final ASTNode? initializer;
  final bool isArray;
  final int? arraySize;
  final bool isPointer;

  const DeclarationStatementNode({
    required this.dataType,
    required this.variableName,
    this.initializer,
    this.isArray = false,
    this.arraySize,
    this.isPointer = false,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitDeclarationStatement(this);

  @override
  List<ASTNode> get children => initializer != null ? [initializer!] : [];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    final pointerStr = isPointer ? '*' : '';
    buffer.writeln(
        '${_indent(indent)}Declaration(${dataType.cRepresentation} $pointerStr$variableName)');
    if (initializer != null) {
      buffer.write(initializer!.toTreeString(indent + 1));
    }
    return buffer.toString();
  }
}

/// Input statement: Leer(x), scanf("%d", &x)
class InputStatementNode extends StatementNode {
  final List<IdentifierNode> variables;
  final String? formatString;

  const InputStatementNode({
    required this.variables,
    this.formatString,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitInputStatement(this);

  @override
  List<ASTNode> get children => variables;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln(
        '${_indent(indent)}InputStmt(${variables.map((v) => v.name).join(", ")})');
    return buffer.toString();
  }
}

/// Output statement: Mostrar(x), printf("%d", x)
class OutputStatementNode extends StatementNode {
  final List<ASTNode> expressions;
  final String? formatString;

  const OutputStatementNode({
    required this.expressions,
    this.formatString,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitOutputStatement(this);

  @override
  List<ASTNode> get children => expressions;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}OutputStmt');
    for (var expr in expressions) {
      buffer.writeln(expr.toTreeString(indent + 1));
    }
    return buffer.toString().trimRight();
  }
}

/// If statement: if (condition) { ... } else { ... }
class IfStatementNode extends StatementNode {
  final ASTNode condition;
  final StatementNode thenBranch;
  final StatementNode? elseBranch;

  const IfStatementNode({
    required this.condition,
    required this.thenBranch,
    this.elseBranch,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitIfStatement(this);

  @override
  List<ASTNode> get children => elseBranch != null
      ? [condition, thenBranch, elseBranch!]
      : [condition, thenBranch];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}IfStmt');
    buffer.writeln('${_indent(indent + 1)}Condition:');
    buffer.writeln(condition.toTreeString(indent + 2));
    buffer.writeln('${_indent(indent + 1)}Then:');
    buffer.writeln(thenBranch.toTreeString(indent + 2));
    if (elseBranch != null) {
      buffer.writeln('${_indent(indent + 1)}Else:');
      buffer.write(elseBranch!.toTreeString(indent + 2));
    }
    return buffer.toString().trimRight();
  }
}

/// While statement: while (condition) { ... }
class WhileStatementNode extends StatementNode {
  final ASTNode condition;
  final StatementNode body;

  const WhileStatementNode({
    required this.condition,
    required this.body,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitWhileStatement(this);

  @override
  List<ASTNode> get children => [condition, body];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}WhileStmt');
    buffer.writeln('${_indent(indent + 1)}Condition:');
    buffer.writeln(condition.toTreeString(indent + 2));
    buffer.writeln('${_indent(indent + 1)}Body:');
    buffer.write(body.toTreeString(indent + 2));
    return buffer.toString();
  }
}

/// For statement: for (init; condition; update) { ... }
class ForStatementNode extends StatementNode {
  final ASTNode? initializer;
  final ASTNode? condition;
  final ASTNode? update;
  final StatementNode body;

  const ForStatementNode({
    this.initializer,
    this.condition,
    this.update,
    required this.body,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitForStatement(this);

  @override
  List<ASTNode> get children {
    final result = <ASTNode>[];
    if (initializer != null) result.add(initializer!);
    if (condition != null) result.add(condition!);
    if (update != null) result.add(update!);
    result.add(body);
    return result;
  }

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ForStmt');
    if (initializer != null) {
      buffer.writeln('${_indent(indent + 1)}Init:');
      buffer.writeln(initializer!.toTreeString(indent + 2));
    }
    if (condition != null) {
      buffer.writeln('${_indent(indent + 1)}Condition:');
      buffer.writeln(condition!.toTreeString(indent + 2));
    }
    if (update != null) {
      buffer.writeln('${_indent(indent + 1)}Update:');
      buffer.writeln(update!.toTreeString(indent + 2));
    }
    buffer.writeln('${_indent(indent + 1)}Body:');
    buffer.write(body.toTreeString(indent + 2));
    return buffer.toString();
  }
}

/// Do-while statement: do { ... } while (condition);
class DoWhileStatementNode extends StatementNode {
  final StatementNode body;
  final ASTNode condition;

  const DoWhileStatementNode({
    required this.body,
    required this.condition,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitDoWhileStatement(this);

  @override
  List<ASTNode> get children => [body, condition];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}DoWhileStmt');
    buffer.writeln('${_indent(indent + 1)}Body:');
    buffer.writeln(body.toTreeString(indent + 2));
    buffer.writeln('${_indent(indent + 1)}Condition:');
    buffer.write(condition.toTreeString(indent + 2));
    return buffer.toString();
  }
}

/// Block statement: { stmt1; stmt2; ... }
class BlockStatementNode extends StatementNode {
  final List<StatementNode> statements;

  const BlockStatementNode({
    required this.statements,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitBlockStatement(this);

  @override
  List<ASTNode> get children => statements;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}Block');
    for (var stmt in statements) {
      buffer.writeln(stmt.toTreeString(indent + 1));
    }
    return buffer.toString().trimRight();
  }
}

/// Return statement: return value;
class ReturnStatementNode extends StatementNode {
  final ASTNode? value;

  const ReturnStatementNode({
    this.value,
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitReturnStatement(this);

  @override
  List<ASTNode> get children => value != null ? [value!] : [];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}ReturnStmt');
    if (value != null) {
      buffer.write(value!.toTreeString(indent + 1));
    }
    return buffer.toString();
  }
}

/// Break statement: break;
class BreakStatementNode extends StatementNode {
  const BreakStatementNode({
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitBreakStatement(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) => '${_indent(indent)}BreakStmt';
}

/// Continue statement: continue;
class ContinueStatementNode extends StatementNode {
  const ContinueStatementNode({
    required super.position,
    super.nodeId,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitContinueStatement(this);

  @override
  List<ASTNode> get children => [];

  @override
  String toTreeString([int indent = 0]) => '${_indent(indent)}ContinueStmt';
}

// ============================================
// PROGRAM STRUCTURE NODES
// ============================================

/// Represents a single diagram node's AST
class DiagramASTNode extends ASTNode {
  final String diagramNodeId;
  final String nodeType;
  final List<StatementNode> statements;
  final String? label;

  const DiagramASTNode({
    required this.diagramNodeId,
    required this.nodeType,
    required this.statements,
    this.label,
    required super.position,
  }) : super(nodeId: diagramNodeId);

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitDiagramNode(this);

  @override
  List<ASTNode> get children => statements;

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer
        .writeln('${_indent(indent)}DiagramNode($nodeType, id=$diagramNodeId)');
    for (var stmt in statements) {
      buffer.writeln(stmt.toTreeString(indent + 1));
    }
    return buffer.toString().trimRight();
  }
}

/// Root node of the program
class ProgramNode extends ASTNode {
  final List<DiagramASTNode> diagramNodes;
  final List<DeclarationStatementNode> globalDeclarations;

  const ProgramNode({
    required this.diagramNodes,
    required this.globalDeclarations,
    required super.position,
  });

  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitProgram(this);

  @override
  List<ASTNode> get children => [...globalDeclarations, ...diagramNodes];

  @override
  String toTreeString([int indent = 0]) {
    final buffer = StringBuffer();
    buffer.writeln('${_indent(indent)}Program');
    if (globalDeclarations.isNotEmpty) {
      buffer.writeln('${_indent(indent + 1)}GlobalDeclarations:');
      for (var decl in globalDeclarations) {
        buffer.writeln(decl.toTreeString(indent + 2));
      }
    }
    buffer.writeln('${_indent(indent + 1)}Nodes:');
    for (var node in diagramNodes) {
      buffer.writeln(node.toTreeString(indent + 2));
    }
    return buffer.toString().trimRight();
  }
}

// ============================================
// AST UTILITIES
// ============================================

/// Default visitor with no-op implementations
class DefaultASTVisitor<T> implements ASTVisitor<T?> {
  @override
  T? visitIntegerLiteral(IntegerLiteralNode node) => null;
  @override
  T? visitFloatLiteral(FloatLiteralNode node) => null;
  @override
  T? visitStringLiteral(StringLiteralNode node) => null;
  @override
  T? visitCharLiteral(CharLiteralNode node) => null;
  @override
  T? visitBooleanLiteral(BooleanLiteralNode node) => null;
  @override
  T? visitIdentifier(IdentifierNode node) => null;
  @override
  T? visitBinaryExpression(BinaryExpressionNode node) => null;
  @override
  T? visitUnaryExpression(UnaryExpressionNode node) => null;
  @override
  T? visitAssignmentExpression(AssignmentExpressionNode node) => null;
  @override
  T? visitConditionalExpression(ConditionalExpressionNode node) => null;
  @override
  T? visitFunctionCall(FunctionCallNode node) => null;
  @override
  T? visitArrayAccess(ArrayAccessNode node) => null;
  @override
  T? visitArrayInitializer(ArrayInitializerNode node) => null;
  @override
  T? visitExpressionStatement(ExpressionStatementNode node) => null;
  @override
  T? visitDeclarationStatement(DeclarationStatementNode node) => null;
  @override
  T? visitInputStatement(InputStatementNode node) => null;
  @override
  T? visitOutputStatement(OutputStatementNode node) => null;
  @override
  T? visitIfStatement(IfStatementNode node) => null;
  @override
  T? visitWhileStatement(WhileStatementNode node) => null;
  @override
  T? visitForStatement(ForStatementNode node) => null;
  @override
  T? visitDoWhileStatement(DoWhileStatementNode node) => null;
  @override
  T? visitBlockStatement(BlockStatementNode node) => null;
  @override
  T? visitReturnStatement(ReturnStatementNode node) => null;
  @override
  T? visitBreakStatement(BreakStatementNode node) => null;
  @override
  T? visitContinueStatement(ContinueStatementNode node) => null;
  @override
  T? visitProgram(ProgramNode node) => null;
  @override
  T? visitDiagramNode(DiagramASTNode node) => null;
}

/// Visitor that traverses all children
class TraversingASTVisitor extends DefaultASTVisitor<void> {
  void visitNode(ASTNode node) {
    node.accept(this);
    for (var child in node.children) {
      visitNode(child);
    }
  }
}

/// Collects all nodes of a specific type
class NodeCollector<T extends ASTNode> extends TraversingASTVisitor {
  final List<T> nodes = [];

  void collect(ASTNode root) {
    visitNode(root);
  }

  void _checkAndAdd(ASTNode node) {
    if (node is T) {
      nodes.add(node);
    }
  }

  @override
  void visitIntegerLiteral(IntegerLiteralNode node) => _checkAndAdd(node);
  @override
  void visitFloatLiteral(FloatLiteralNode node) => _checkAndAdd(node);
  @override
  void visitStringLiteral(StringLiteralNode node) => _checkAndAdd(node);
  @override
  void visitCharLiteral(CharLiteralNode node) => _checkAndAdd(node);
  @override
  void visitBooleanLiteral(BooleanLiteralNode node) => _checkAndAdd(node);
  @override
  void visitIdentifier(IdentifierNode node) => _checkAndAdd(node);
  @override
  void visitBinaryExpression(BinaryExpressionNode node) => _checkAndAdd(node);
  @override
  void visitUnaryExpression(UnaryExpressionNode node) => _checkAndAdd(node);
  @override
  void visitAssignmentExpression(AssignmentExpressionNode node) =>
      _checkAndAdd(node);
  @override
  void visitConditionalExpression(ConditionalExpressionNode node) =>
      _checkAndAdd(node);
  @override
  void visitFunctionCall(FunctionCallNode node) => _checkAndAdd(node);
  @override
  void visitArrayAccess(ArrayAccessNode node) => _checkAndAdd(node);
  @override
  void visitArrayInitializer(ArrayInitializerNode node) => _checkAndAdd(node);
  @override
  void visitExpressionStatement(ExpressionStatementNode node) =>
      _checkAndAdd(node);
  @override
  void visitDeclarationStatement(DeclarationStatementNode node) =>
      _checkAndAdd(node);
  @override
  void visitInputStatement(InputStatementNode node) => _checkAndAdd(node);
  @override
  void visitOutputStatement(OutputStatementNode node) => _checkAndAdd(node);
  @override
  void visitIfStatement(IfStatementNode node) => _checkAndAdd(node);
  @override
  void visitWhileStatement(WhileStatementNode node) => _checkAndAdd(node);
  @override
  void visitForStatement(ForStatementNode node) => _checkAndAdd(node);
  @override
  void visitDoWhileStatement(DoWhileStatementNode node) => _checkAndAdd(node);
  @override
  void visitBlockStatement(BlockStatementNode node) => _checkAndAdd(node);
  @override
  void visitReturnStatement(ReturnStatementNode node) => _checkAndAdd(node);
  @override
  void visitBreakStatement(BreakStatementNode node) => _checkAndAdd(node);
  @override
  void visitContinueStatement(ContinueStatementNode node) => _checkAndAdd(node);
  @override
  void visitProgram(ProgramNode node) => _checkAndAdd(node);
  @override
  void visitDiagramNode(DiagramASTNode node) => _checkAndAdd(node);
}
