# ISO 5807 Flowchart Symbols - Implementation Guide

## Overview

This document describes the implementation of ISO 5807 flowchart symbols in **flowdiagramapp**. The ISO 5807 standard (Information processing — Documentation symbols and conventions for data, program and system flowcharts, program network charts and system resources charts) defines standardized symbols for creating flowcharts.

Our implementation includes **24 symbol types** organized into **4 categories**.

---

## Symbol Categories

### 1. Basic Symbols (with C Code Generation)

These symbols are the core flowchart elements that support automatic C code generation.

| Symbol | NodeType | Shape | Description | C Code Generated |
|--------|----------|-------|-------------|------------------|
| **Terminal** | `terminal` | Oval/Stadium | Start and End points of the flowchart | `int main() { ... }` / `return 0;` |
| **Process** | `process` | Rectangle | General processing operations | Variable declarations, assignments, operations |
| **Decision** | `decision` | Diamond/Rhombus | Conditional branching (if/else) | `if (condition) { ... } else { ... }` |
| **Preparation** | `preparation` | Hexagon | Loop initialization | `for (init; condition; increment)` |
| **Data** | `data` | Parallelogram | Input/Output operations | `scanf()` / `printf()` |
| **Predefined Process** | `predefinedProcess` | Rectangle with double vertical lines | Subroutine/Function call | Function calls |

### 2. Data Symbols (ISO 5807 - No Code Generation)

These symbols represent different types of data storage and I/O devices.

| Symbol | NodeType | Shape | Description |
|--------|----------|-------|-------------|
| **Stored Data** | `storedData` | Rectangle with curved base | General data storage |
| **Internal Storage** | `internalStorage` | Rectangle with internal grid | RAM/Memory storage |
| **Sequential Storage** | `sequentialStorage` | Circle with tail (tape reel) | Magnetic tape/Sequential access |
| **Direct Storage** | `directStorage` | Cylinder | Database/Direct access storage |
| **Document** | `document` | Rectangle with wavy bottom | Printed document output |
| **Manual Input** | `manualInput` | Parallelogram with sloped top | Keyboard/Manual data entry |
| **Card** | `card` | Rectangle with cut corner | Punched card input |
| **Punched Tape** | `punchedTape` | Wavy rectangle | Paper tape input |
| **Display** | `display` | Bullet/CRT shape | Screen/Monitor output |

### 3. Process Symbols (ISO 5807 - No Code Generation)

These symbols represent different types of processing operations.

| Symbol | NodeType | Shape | Description |
|--------|----------|-------|-------------|
| **Manual Operation** | `manualOperation` | Trapezoid | Human-performed operation |
| **Parallel Mode** | `parallelMode` | Double horizontal bars | Parallel processing fork/join |
| **Loop Limit** | `loopLimit` | Chamfered rectangle | Loop boundary (start/end) |
| **Collate** | `collate` | Circle with diagonal X | Merge/combine data streams |
| **Summing Junction** | `summingJunction` | Circle with + cross | Sum/union of data streams |

### 4. Special Symbols (ISO 5807 - No Code Generation)

These symbols are used for flowchart organization and documentation.

| Symbol | NodeType | Shape | Description | Stroke Style |
|--------|----------|-------|-------------|--------------|
| **Connector** | `connector` | Circle | On-page connector (jump point) | Solid |
| **Off-page Connector** | `offPageConnector` | Pentagon (pointing down) | Off-page connector | Solid |
| **Annotation** | `annotation` | Open bracket | Annotation/Comment | Dashed |
| **Comment** | `comment` | Dashed rectangle | Comment block | Dashed |

---

## Implementation Details

### NodeType Enum

```dart
enum NodeType {
  // Basic Symbols (with C code generation)
  terminal,
  process,
  decision,
  preparation,
  data,
  predefinedProcess,

  // Data Symbols (ISO 5807)
  storedData,
  internalStorage,
  sequentialStorage,
  directStorage,
  document,
  manualInput,
  card,
  punchedTape,
  display,

  // Process Symbols (ISO 5807)
  manualOperation,
  parallelMode,
  loopLimit,
  collate,
  summingJunction,

  // Special Symbols (ISO 5807)
  connector,
  offPageConnector,
  annotation,
  comment,
}
```

### Extension Methods

The `NodeTypeExtension` provides useful metadata for each symbol:

```dart
extension NodeTypeExtension on NodeType {
  /// Returns true if this node type supports C code generation
  bool get hasCodeGeneration;
  
  /// Returns the ISO 5807 category ('Basic', 'Data', 'Process', 'Special')
  String get isoCategory;
  
  /// Returns the English name according to ISO 5807
  String get isoName;
  
  /// Returns a description of the symbol's shape
  String get shapeDescription;
}
```

### Shape Rendering

Each symbol has a custom path defined in the `getPath()` method of `DiagramNode`:

```dart
Path getPath() {
  switch (type) {
    case NodeType.terminal:
      // Stadium shape (rounded rectangle)
    case NodeType.process:
      // Rectangle
    case NodeType.decision:
      // Diamond/Rhombus
    // ... etc
  }
}
```

### Dashed Stroke Support

Annotation and Comment symbols use dashed strokes per ISO 5807:

```dart
bool get usesDashedStroke {
  return type == NodeType.annotation || type == NodeType.comment;
}
```

---

## Validation Rules

The `DiagramValidator` enforces structural rules for each symbol type:

### Connection Requirements

| Symbol Type | Min Inputs | Min Outputs | Notes |
|-------------|------------|-------------|-------|
| Terminal (Start) | 0 | 1 | Must have output |
| Terminal (End) | 1+ | 0 | Cannot have outputs |
| Process | 1 | 1 | Standard flow |
| Decision | 1 | 2 | True/False branches |
| Preparation | 1 | 1 | Loop initialization |
| Data | 1 | 1 | I/O operation |
| Predefined Process | 1 | 1 | Function call |
| Manual Operation | 1 | 1 | Human operation |
| Parallel Mode | 1 | 2+ | Fork to parallel processes |
| Loop Limit | 1 | 2 | Continue/Exit loop |
| **Collate** | 0* | 0* | Needs at least 1 connection (in OR out) |
| **Summing Junction** | 0* | 0* | Needs at least 1 connection (in OR out) |
| Connector | 0* | 0* | Entry OR exit point |
| Off-page Connector | 0* | 0* | Entry OR exit point |
| Annotation | 0 | 0 | Does not participate in flow |
| Comment | 0 | 0 | Does not participate in flow |
| Data Storage Symbols | 1* | 0* | Can be read-only or write-only |

*Special validation rules apply

### Connector Validation

- Connectors should have matching labels
- A connector with label "A" should have a corresponding connector "A" elsewhere
- Connectors can be entry points (outputs only) or exit points (inputs only)

---

## Color Scheme

Each category has a distinct color scheme for visual identification:

| Category | Primary Color | Example Symbols |
|----------|---------------|-----------------|
| Basic | Various | Green (Terminal), Blue (Process), Orange (Decision) |
| Data | Blue shades | All data storage and I/O symbols |
| Process | Green/Teal shades | Manual Operation, Parallel Mode, Loop Limit, Collate, Summing Junction |
| Special | Amber/Grey | Connectors (Amber), Annotations (Grey) |

---

## User Interface

### Node Palette

The Node Palette organizes symbols into expandable categories:

1. **Basic** - Terminal, Process, Decision, Preparation, Data, Predefined Process
2. **Process** - Manual Operation, Parallel Mode, Loop Limit
3. **Data** - Stored Data, Internal Storage, Sequential Storage, Direct Storage, Document, Manual Input, Card, Punched Tape, Display
4. **Special** - Connector, Off-page Connector, Annotation, Comment

Symbols with C code generation support are marked with a "C" badge.

### Node Editor Dialogs

Specialized dialogs are available for:

- **Process nodes** - `ProcessNodeDialog`
- **Decision nodes** - `DecisionNodeDialog`
- **Data nodes** - `DataNodeDialog`
- **Preparation nodes** - `PreparationNodeDialog`
- **Predefined Process nodes** - `SubprocessNodeDialog`
- **Connector nodes** - `ConnectorNodeDialog`
- **Comment/Annotation nodes** - `CommentNodeDialog`

Other ISO 5807 symbols use a generic text editor dialog.

---

## File References

| File | Purpose |
|------|---------|
| `lib/models/diagram_node.dart` | NodeType enum, shape paths, extension methods |
| `lib/models/diagram_validator.dart` | Validation rules for all symbol types |
| `lib/models/code_generator.dart` | C code generation for basic symbols |
| `lib/widgets/node_palette.dart` | Symbol selection UI |
| `lib/widgets/flow_diagram_canvas_final.dart` | Canvas rendering with dashed stroke support |
| `lib/widgets/node_editor_dialog.dart` | Dialog router for node editing |
| `lib/themes/app_themes.dart` | Color definitions for all symbol types |

---

## Future Enhancements

Potential improvements for ISO 5807 compliance:

1. **Flowline symbols** - Add explicit flowline types (normal, crossing, junction)
2. **Additional annotations** - Support for multiple annotation styles
3. **Symbol sizing** - Allow configurable symbol dimensions
4. **Export formats** - Export diagrams in standard interchange formats
5. **Template library** - Pre-built flowchart templates using ISO symbols

---

## References

- ISO 5807:1985 - Information processing — Documentation symbols and conventions for data, program and system flowcharts, program network charts and system resources charts
- ANSI X3.5-1970 - Flowchart Symbols and Their Usage in Information Processing

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | January 2026 | Initial implementation with 22 ISO 5807 symbols |

