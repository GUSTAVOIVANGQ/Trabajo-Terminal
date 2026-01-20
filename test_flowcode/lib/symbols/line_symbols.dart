import 'package:flutter/material.dart';
import 'package:test_flowcode/symbols/data_symbols.dart'; // Import base class
import 'dart:ui'; // For Points

// Line: Flecha
class LineSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw Arrow
    final p1 = Offset(0, size.height / 2);
    final p2 = Offset(size.width, size.height / 2);

    canvas.drawLine(p1, p2, paint);

    // Arrow head
    final path = Path();
    path.moveTo(size.width - 10, size.height / 2 - 5);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 10, size.height / 2 + 5);
    canvas.drawPath(path, paint);
  }
}

// Control transfer: Flecha con etiqueta (Just an arrow with space for label? Or specific)
// I'll draw an arrow with a small text "Label" or assume the shape determines it.
class ControlTransferSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Same as line but maybe different style?
    // "Flecha con etiqueta" usually is just a line.

    final p1 = Offset(0, size.height / 2);
    final p2 = Offset(size.width, size.height / 2);
    canvas.drawLine(p1, p2, paint);

    // Arrow head
    final path = Path();
    path.moveTo(size.width - 10, size.height / 2 - 5);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 10, size.height / 2 + 5);
    canvas.drawPath(path, paint);

    // Text is handled by UI, but if symbol needs it:
    // I can simulate a label
  }
}

// Communication link: Línea con zigzag
class CommunicationLinkSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, size.height / 2);
    // Zigzag
    for (double i = 0; i < size.width; i += 10) {
      path.lineTo(i + 5, size.height / 2 - 5);
      path.lineTo(i + 10, size.height / 2 + 5);
    }
    canvas.drawPath(path, paint);
  }
}

// Dashed line: Línea discontinua
class DashedLineSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double dashWidth = 5;
    double dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
}
