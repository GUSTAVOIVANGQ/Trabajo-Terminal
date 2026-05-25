/// Symbol Table for FlowCode Diagram Compiler
/// Manages variable declarations, scopes, and type information
///
/// This is part of the source-to-source compiler that transforms
/// flowchart diagrams into C code through proper compilation phases.

/// Represents the data type of a symbol
enum DataType {
  integer, // int
  float, // float
  double_, // double (underscore because 'double' is reserved in Dart)
  char, // char
  string, // char* or char[]
  boolean, // bool
  void_, // void (underscore because 'void' is reserved in Dart)
  array, // array of any type
  pointer, // pointer to any type
  function_, // function type
  unknown, // type not yet determined
}

/// Extension to provide metadata about each DataType
extension DataTypeExtension on DataType {
  /// Returns the C representation of this data type
  String get cRepresentation {
    switch (this) {
      case DataType.integer:
        return 'int';
      case DataType.float:
        return 'float';
      case DataType.double_:
        return 'double';
      case DataType.char:
        return 'char';
      case DataType.string:
        return 'char*';
      case DataType.boolean:
        return 'bool';
      case DataType.void_:
        return 'void';
      case DataType.array:
        return '[]';
      case DataType.pointer:
        return '*';
      case DataType.function_:
        return 'function';
      case DataType.unknown:
        return 'unknown';
    }
  }

  /// Returns the default value for this data type in C
  String get defaultValue {
    switch (this) {
      case DataType.integer:
        return '0';
      case DataType.float:
        return '0.0f';
      case DataType.double_:
        return '0.0';
      case DataType.char:
        return "'\\0'";
      case DataType.string:
        return 'NULL';
      case DataType.boolean:
        return 'false';
      case DataType.void_:
        return '';
      case DataType.array:
        return '{}';
      case DataType.pointer:
        return 'NULL';
      case DataType.function_:
        return '';
      case DataType.unknown:
        return '0';
    }
  }

  /// Returns the printf format specifier for this data type
  String get formatSpecifier {
    switch (this) {
      case DataType.integer:
        return '%d';
      case DataType.float:
        return '%f';
      case DataType.double_:
        return '%lf';
      case DataType.char:
        return '%c';
      case DataType.string:
        return '%s';
      case DataType.boolean:
        return '%d';
      case DataType.pointer:
        return '%p';
      default:
        return '%d';
    }
  }

  /// Returns the scanf format specifier for this data type
  String get scanfSpecifier {
    switch (this) {
      case DataType.integer:
        return '%d';
      case DataType.float:
        return '%f';
      case DataType.double_:
        return '%lf';
      case DataType.char:
        return ' %c'; // Space before %c to skip whitespace
      case DataType.string:
        return '%s';
      case DataType.boolean:
        return '%d';
      default:
        return '%d';
    }
  }

  /// Returns the size in bytes (typical)
  int get sizeInBytes {
    switch (this) {
      case DataType.integer:
        return 4;
      case DataType.float:
        return 4;
      case DataType.double_:
        return 8;
      case DataType.char:
        return 1;
      case DataType.string:
        return 8; // Pointer size
      case DataType.boolean:
        return 1;
      case DataType.void_:
        return 0;
      case DataType.pointer:
        return 8;
      default:
        return 4;
    }
  }

  /// Returns true if this type is numeric
  bool get isNumeric {
    return this == DataType.integer ||
        this == DataType.float ||
        this == DataType.double_;
  }

  /// Returns true if this type can be used in arithmetic operations
  bool get isArithmetic {
    return isNumeric || this == DataType.char;
  }
}

/// Represents the category of a symbol
enum SymbolCategory {
  variable, // Regular variable
  constant, // Const variable
  parameter, // Function parameter
  function_, // Function name
  array, // Array variable
  label, // Label (for goto)
  typedef_, // Type definition
}

/// Information about a single symbol in the symbol table
class SymbolInfo {
  /// The name/identifier of the symbol
  final String name;

  /// The data type of the symbol
  DataType dataType;

  /// The category of this symbol
  final SymbolCategory category;

  /// The scope level where this symbol was declared (0 = global)
  final int scopeLevel;

  /// The scope ID (unique identifier for nested scopes)
  final int scopeId;

  /// The ID of the diagram node where this symbol was declared
  final String? declaringNodeId;

  /// The line number where the symbol was first declared
  final int declarationLine;

  /// The column number where the symbol was first declared
  final int declarationColumn;

  /// Whether this symbol has been initialized
  bool isInitialized;

  /// Whether this symbol has been used (for dead code detection)
  bool isUsed;

  /// The initial value (if any)
  dynamic initialValue;

  /// For arrays: the size/dimensions
  List<int>? arrayDimensions;

  /// For functions: the parameter types
  List<DataType>? parameterTypes;

  /// For functions: the return type
  DataType? returnType;

  /// Additional metadata
  Map<String, dynamic> metadata;

  SymbolInfo({
    required this.name,
    required this.dataType,
    required this.category,
    required this.scopeLevel,
    required this.scopeId,
    this.declaringNodeId,
    this.declarationLine = 1,
    this.declarationColumn = 1,
    this.isInitialized = false,
    this.isUsed = false,
    this.initialValue,
    this.arrayDimensions,
    this.parameterTypes,
    this.returnType,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  /// Creates a copy of this symbol info with some fields changed
  SymbolInfo copyWith({
    String? name,
    DataType? dataType,
    SymbolCategory? category,
    int? scopeLevel,
    int? scopeId,
    String? declaringNodeId,
    int? declarationLine,
    int? declarationColumn,
    bool? isInitialized,
    bool? isUsed,
    dynamic initialValue,
    List<int>? arrayDimensions,
    List<DataType>? parameterTypes,
    DataType? returnType,
    Map<String, dynamic>? metadata,
  }) {
    return SymbolInfo(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      category: category ?? this.category,
      scopeLevel: scopeLevel ?? this.scopeLevel,
      scopeId: scopeId ?? this.scopeId,
      declaringNodeId: declaringNodeId ?? this.declaringNodeId,
      declarationLine: declarationLine ?? this.declarationLine,
      declarationColumn: declarationColumn ?? this.declarationColumn,
      isInitialized: isInitialized ?? this.isInitialized,
      isUsed: isUsed ?? this.isUsed,
      initialValue: initialValue ?? this.initialValue,
      arrayDimensions: arrayDimensions ?? this.arrayDimensions,
      parameterTypes: parameterTypes ?? this.parameterTypes,
      returnType: returnType ?? this.returnType,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  @override
  String toString() {
    return 'SymbolInfo($name: ${dataType.cRepresentation}, scope: $scopeLevel, '
        'initialized: $isInitialized, used: $isUsed)';
  }

  /// Returns a detailed representation for debugging
  String toDetailedString() {
    final buffer = StringBuffer();
    buffer.writeln('Symbol: $name');
    buffer.writeln('  Type: ${dataType.cRepresentation}');
    buffer.writeln('  Category: $category');
    buffer.writeln('  Scope Level: $scopeLevel');
    buffer.writeln('  Scope ID: $scopeId');
    buffer.writeln(
        '  Declared at: line $declarationLine, col $declarationColumn');
    buffer.writeln('  Node ID: $declaringNodeId');
    buffer.writeln('  Initialized: $isInitialized');
    buffer.writeln('  Used: $isUsed');
    if (initialValue != null) {
      buffer.writeln('  Initial Value: $initialValue');
    }
    if (arrayDimensions != null) {
      buffer.writeln('  Array Dimensions: $arrayDimensions');
    }
    return buffer.toString();
  }
}

/// Represents a scope in the symbol table
class Scope {
  /// Unique identifier for this scope
  final int id;

  /// The depth level of this scope (0 = global)
  final int level;

  /// The parent scope (null for global scope)
  final Scope? parent;

  /// Symbols declared in this scope (name -> SymbolInfo)
  final Map<String, SymbolInfo> symbols;

  /// Child scopes
  final List<Scope> children;

  /// The node ID where this scope was created
  final String? nodeId;

  /// Description of this scope (e.g., "if-then", "while-body", "function-X")
  final String description;

  Scope({
    required this.id,
    required this.level,
    this.parent,
    Map<String, SymbolInfo>? symbols,
    List<Scope>? children,
    this.nodeId,
    this.description = '',
  })  : symbols = symbols ?? {},
        children = children ?? [];

  /// Returns true if this scope contains a symbol with the given name
  bool hasSymbol(String name) => symbols.containsKey(name);

  /// Gets a symbol from this scope (not looking in parent scopes)
  SymbolInfo? getSymbol(String name) => symbols[name];

  @override
  String toString() =>
      'Scope(id: $id, level: $level, symbols: ${symbols.keys.toList()})';
}

/// The Symbol Table manages all symbols and scopes in the program
class SymbolTable {
  /// All scopes in the program
  final List<Scope> _scopes = [];

  /// The current active scope
  Scope? _currentScope;

  /// Counter for generating unique scope IDs
  int _scopeIdCounter = 0;

  /// Global symbols (available everywhere)
  final Map<String, SymbolInfo> _globalSymbols = {};

  /// List of all symbols (for iteration)
  final List<SymbolInfo> _allSymbols = [];

  /// Errors encountered during symbol table operations
  final List<String> _errors = [];

  /// Warnings encountered during symbol table operations
  final List<String> _warnings = [];

  SymbolTable() {
    // Initialize with global scope
    _initializeGlobalScope();
  }

  /// Initialize the global scope
  void _initializeGlobalScope() {
    final globalScope = Scope(
      id: _scopeIdCounter++,
      level: 0,
      description: 'global',
    );
    _scopes.add(globalScope);
    _currentScope = globalScope;
  }

  /// Returns the current scope level
  int get currentScopeLevel => _currentScope?.level ?? 0;

  /// Returns the current scope ID
  int get currentScopeId => _currentScope?.id ?? 0;

  /// Returns all errors
  List<String> get errors => List.unmodifiable(_errors);

  /// Returns all warnings
  List<String> get warnings => List.unmodifiable(_warnings);

  /// Returns all symbols
  List<SymbolInfo> get allSymbols => List.unmodifiable(_allSymbols);

  /// Returns the number of symbols
  int get symbolCount => _allSymbols.length;

  /// Enter a new scope
  void enterScope({String? nodeId, String description = ''}) {
    final newScope = Scope(
      id: _scopeIdCounter++,
      level: (_currentScope?.level ?? -1) + 1,
      parent: _currentScope,
      nodeId: nodeId,
      description: description,
    );

    _currentScope?.children.add(newScope);
    _scopes.add(newScope);
    _currentScope = newScope;
  }

  /// Exit the current scope (return to parent scope)
  void exitScope() {
    if (_currentScope?.parent != null) {
      _currentScope = _currentScope!.parent;
    }
  }

  /// Declare a new symbol in the current scope
  bool declareSymbol({
    required String name,
    required DataType dataType,
    SymbolCategory category = SymbolCategory.variable,
    String? nodeId,
    int line = 1,
    int column = 1,
    bool isInitialized = false,
    dynamic initialValue,
    List<int>? arrayDimensions,
  }) {
    // Check if symbol already exists in current scope
    if (_currentScope?.hasSymbol(name) ?? false) {
      _errors.add('Error: Symbol "$name" already declared in current scope at '
          'line $line, column $column');
      return false;
    }

    // Create the symbol info
    final symbol = SymbolInfo(
      name: name,
      dataType: dataType,
      category: category,
      scopeLevel: _currentScope?.level ?? 0,
      scopeId: _currentScope?.id ?? 0,
      declaringNodeId: nodeId,
      declarationLine: line,
      declarationColumn: column,
      isInitialized: isInitialized,
      initialValue: initialValue,
      arrayDimensions: arrayDimensions,
    );

    // Add to current scope
    _currentScope?.symbols[name] = symbol;
    _allSymbols.add(symbol);

    // Also add to global symbols if at global scope
    if ((_currentScope?.level ?? 0) == 0) {
      _globalSymbols[name] = symbol;
    }

    return true;
  }

  /// Look up a symbol by name (searches current scope and all parent scopes)
  SymbolInfo? lookup(String name) {
    Scope? scope = _currentScope;

    while (scope != null) {
      final symbol = scope.getSymbol(name);
      if (symbol != null) {
        return symbol;
      }
      scope = scope.parent;
    }

    // Check global symbols as fallback
    return _globalSymbols[name];
  }

  /// Look up a symbol only in the current scope
  SymbolInfo? lookupInCurrentScope(String name) {
    return _currentScope?.getSymbol(name);
  }

  /// Check if a symbol exists (in any accessible scope)
  bool symbolExists(String name) {
    return lookup(name) != null;
  }

  /// Mark a symbol as used
  void markAsUsed(String name) {
    final symbol = lookup(name);
    if (symbol != null) {
      symbol.isUsed = true;
    }
  }

  /// Mark a symbol as initialized
  void markAsInitialized(String name) {
    final symbol = lookup(name);
    if (symbol != null) {
      symbol.isInitialized = true;
    }
  }

  /// Update the type of a symbol (useful for type inference)
  void updateType(String name, DataType newType) {
    final symbol = lookup(name);
    if (symbol != null) {
      symbol.dataType = newType;
    }
  }

  /// Get all symbols that are unused (for dead code detection)
  List<SymbolInfo> getUnusedSymbols() {
    return _allSymbols.where((s) => !s.isUsed).toList();
  }

  /// Get all symbols that are uninitialized before use
  List<SymbolInfo> getUninitializedSymbols() {
    return _allSymbols.where((s) => !s.isInitialized && s.isUsed).toList();
  }

  /// Get all symbols of a specific type
  List<SymbolInfo> getSymbolsByType(DataType type) {
    return _allSymbols.where((s) => s.dataType == type).toList();
  }

  /// Get all symbols in a specific scope
  List<SymbolInfo> getSymbolsInScope(int scopeId) {
    return _allSymbols.where((s) => s.scopeId == scopeId).toList();
  }

  /// Clear all errors and warnings
  void clearMessages() {
    _errors.clear();
    _warnings.clear();
  }

  /// Reset the symbol table (clear everything)
  void reset() {
    _scopes.clear();
    _globalSymbols.clear();
    _allSymbols.clear();
    _errors.clear();
    _warnings.clear();
    _scopeIdCounter = 0;
    _currentScope = null;
    _initializeGlobalScope();
  }

  /// Generate C variable declarations for all symbols.
  /// [excludeVars] allows the caller to skip variables that will be declared
  /// inline (e.g., arrays with brace-initializers like `int arr[5] = {1,2,3}`).
  String generateCDeclarations({Set<String>? excludeVars}) {
    final buffer = StringBuffer();

    // Emit array declarations individually with their size
    for (final symbol in _allSymbols) {
      if (symbol.category == SymbolCategory.array) {
        // Skip excluded variables (they'll be declared inline with initializer)
        if (excludeVars != null && excludeVars.contains(symbol.name)) continue;
        final typeStr = symbol.dataType.cRepresentation;
        final dims = symbol.arrayDimensions;
        if (dims != null && dims.isNotEmpty) {
          final sizeSuffix = dims.map((d) => '[$d]').join();
          buffer.writeln('$typeStr ${symbol.name}$sizeSuffix;');
        } else {
          buffer.writeln('$typeStr ${symbol.name}[];');
        }
      }
    }

    // Group scalar variables by type for cleaner output
    final groupedByType = <DataType, List<SymbolInfo>>{};
    for (final symbol in _allSymbols) {
      if (symbol.category == SymbolCategory.variable ||
          symbol.category == SymbolCategory.constant) {
        // Skip excluded variables
        if (excludeVars != null && excludeVars.contains(symbol.name)) continue;
        groupedByType.putIfAbsent(symbol.dataType, () => []).add(symbol);
      }
    }

    // Generate scalar declarations (without initial values — assignments are emitted
    // separately in the main body from the process nodes, to avoid duplication).
    for (final entry in groupedByType.entries) {
      final typeStr = entry.key.cRepresentation;
      final names = entry.value.map((s) => s.name).join(', ');

      if (entry.value.any((s) => s.category == SymbolCategory.constant)) {
        buffer.writeln('const $typeStr $names;');
      } else {
        buffer.writeln('$typeStr $names;');
      }
    }

    return buffer.toString();
  }

  /// Returns a string representation of the symbol table
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== Symbol Table ===');
    buffer.writeln('Total symbols: ${_allSymbols.length}');
    buffer.writeln('Total scopes: ${_scopes.length}');
    buffer.writeln('Current scope level: $currentScopeLevel');
    buffer.writeln('\nSymbols:');
    for (final symbol in _allSymbols) {
      buffer.writeln('  $symbol');
    }
    if (_errors.isNotEmpty) {
      buffer.writeln('\nErrors:');
      for (final error in _errors) {
        buffer.writeln('  $error');
      }
    }
    if (_warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in _warnings) {
        buffer.writeln('  $warning');
      }
    }
    return buffer.toString();
  }

  /// Export symbol table as JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'symbolCount': _allSymbols.length,
      'scopeCount': _scopes.length,
      'currentScopeLevel': currentScopeLevel,
      'symbols': _allSymbols.map((s) {
        return {
          'name': s.name,
          'type': s.dataType.cRepresentation,
          'category': s.category.toString(),
          'scopeLevel': s.scopeLevel,
          'initialized': s.isInitialized,
          'used': s.isUsed,
        };
      }).toList(),
      'errors': _errors,
      'warnings': _warnings,
    };
  }
}
