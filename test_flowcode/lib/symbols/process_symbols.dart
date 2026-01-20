import 'package:flutter/material.dart';
import 'package:test_flowcode/symbols/data_symbols.dart'; // Import base class

// Process: Rectángulo
class ProcessSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
}

// Predefined process: Rectángulo con doble borde (vertical lines)
class PredefinedProcessSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final margin = size.width * 0.15;
    canvas.drawLine(Offset(margin, 0), Offset(margin, size.height), paint);
    canvas.drawLine(
      Offset(size.width - margin, 0),
      Offset(size.width - margin, size.height),
      paint,
    );
  }
}

// Manual operation: Trapecio
class ManualOperationSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final slope = size.width * 0.2; // Slope amount

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - slope, size.height);
    path.lineTo(slope, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
}

// Preparation: Hexágono (Elongated)
class PreparationSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final pointWidth = size.width * 0.2;

    path.moveTo(0, size.height / 2); // Left point
    path.lineTo(pointWidth, 0); // Top left
    path.lineTo(size.width - pointWidth, 0); // Top right
    path.lineTo(size.width, size.height / 2); // Right point
    path.lineTo(size.width - pointWidth, size.height); // Bottom right
    path.lineTo(pointWidth, size.height); // Bottom left
    path.close();

    canvas.drawPath(path, paint);
  }
}

// Decision: Rombo
class DecisionSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
}

// Collate: Círculo con cruz diagonal (X)
class CollateSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Circle
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);

    // Diagonal Cross (X)
    // 45 degrees. sin(45) = cos(45) ~ 0.707
    final offset = radius * 0.707;
    canvas.drawLine(
      center - Offset(offset, offset),
      center + Offset(offset, offset),
      paint,
    );
    canvas.drawLine(
      center - Offset(offset, -offset),
      center + Offset(offset, -offset),
      paint,
    );
  }
}

// Summing junction: Círculo con cruz vertical (+)
class SummingJunctionSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Circle
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);

    // Vertical/Horizontal Cross (+)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }
}

// Parallel mode: Barra doble horizontal (Two horizontal lines)
class ParallelModeSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Usually enclosing lines for parallel operations
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }
}

// Loop limit: Símbolo doble (inicio/fin de ciclo)
// Usually Start Loop: Rectangle with corners cut at top? Or chamfered?
// ISO 5807 Loop: "Preparation" is often used for loops (Hexagon).
// BUT "Loop Limit" is separate.
// Typically: Two parts. Begin Loop (Chamfered Rectangle) and End Loop (Same flipped).
// I will draw the "Loop Limit" as a chamfered rectangle (Start Loop).
class LoopLimitSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final cut = size.width * 0.15;

    // Start Loop shape (Chamfered corners)
    path.moveTo(cut, 0);
    path.lineTo(size.width - cut, 0);
    path.lineTo(
      size.width,
      size.height * 0.4,
    ); // Sloped down side? Or simple chamfer?
    // Standard Loop Limit is chopped corners usually.
    // Let's do simple chamfered rectangle.
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);
  }
}
