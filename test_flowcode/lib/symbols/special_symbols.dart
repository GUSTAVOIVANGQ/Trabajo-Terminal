import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:test_flowcode/symbols/data_symbols.dart'; // Import base class

// Connector (on-page): Círculo
class ConnectorSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Circle
    double radius = size.shortestSide / 2;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }
}

// Off-page connector: Pentágono (Pointed down)
class OffPageConnectorSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0); // Top
    path.lineTo(size.width, size.height * 0.5); // Right side
    path.lineTo(size.width / 2, size.height); // Point down
    path.lineTo(0, size.height * 0.5); // Left side
    path.close();

    canvas.drawPath(path, paint);
  }
}

// Annotation: Llave / nota lateral (Bracket)
class AnnotationSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    // Open bracket [
    // But usually for annotation it's a bracket connected to line.
    // "Llave" = Brace? { or [.
    // ISO 5807 "Annotation" is an open rectangle with dashed line to process?
    // Or just a bracket.
    // User says "Llave / nota lateral".

    // I'll draw a callout bracket [
    path.moveTo(size.width * 0.8, 0); // Top Right end
    path.lineTo(size.width * 0.2, 0); // Top Line
    path.lineTo(size.width * 0.2, size.height); // Vertical Line
    path.lineTo(size.width * 0.8, size.height); // Bottom Line

    // Dashed line from center of vertical to left?
    // Often it connects to the flowchart.

    canvas.drawPath(path, paint);
  }
}

// Comment / Annotation area: Área delimitada con línea discontinua
class CommentSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw dashed rectangle
    // Helper for dashed path?
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Simple dashed drawing manual for rectangle
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + 5.0),
          paint,
        );
        distance += 10.0;
      }
    }
  }
}
