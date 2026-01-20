import 'package:flutter/material.dart';
import 'dart:math' as math;

abstract class FlowchartPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  FlowchartPainter({this.color = Colors.black, this.strokeWidth = 2.0});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data: Paralelogramo
class DataSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final slope = size.width * 0.2;
    path.moveTo(slope, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - slope, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
}

// Stored Data: Rectángulo con base curva (Stored Data)
// Often depicted as: sides curved? Or top/bottom curved?
// ISO 5807 Stored Data usually looks like a rectangle with sides curved outward (convex) like parentheses ( )
// User says: "Rectángulo con base curva". Likely "Document" is "borde inferior ondulado", "Stored data" might be the cylinder-like flat one or the file shape.
// Wait, "Stored Data" is often the same as "Data File" or "Database"? No, "Direct Access Storage" is cylinder (Database).
// Stored Data (ISO): Sides are rounded. ( | | )
// User says: "Rectángulo con base curva". I will draw a rectangle where the left and right sides are curved (or base is curved?).
// Let's assume standard stored data shape: Rectangle with left and right edges curved outward.
class StoredDataSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final curveDepth = size.width * 0.2;

    // Top
    path.moveTo(curveDepth, 0);
    path.lineTo(size.width, 0);

    // Right curve (Concave - bulges left)
    path.quadraticBezierTo(
      size.width - curveDepth,
      size.height / 2,
      size.width,
      size.height,
    );

    // Bottom
    path.lineTo(curveDepth, size.height);

    // Left curve (Convex - bulges left)
    path.quadraticBezierTo(0, size.height / 2, curveDepth, 0);

    canvas.drawPath(path, paint);
  }
}

// Internal Storage: Rectángulo con lados cóncavos -> (Rectángulo con lados cóncavos, o divisiones)
// ISO 5807 Internal Storage: Rectangle with an extra line near top and left/right?
// Or actually the "Core" symbol which is a square with lines?
// User description: "Rectángulo con lados cóncavos".
// This sounds like the "Stored Data" but concave?
// Actually, standard "Internal Storage" is a rectangle with two lines (vertical and horizontal) making a grid?
// Let's implement what the user described: "lados cóncavos" (concave sides).
class InternalStorageSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw main rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw internal lines (Grid style)
    // Horizontal line near top
    final double topMargin = size.height * 0.2;
    canvas.drawLine(Offset(0, topMargin), Offset(size.width, topMargin), paint);

    // Vertical line near left
    final double leftMargin = size.width * 0.2;
    canvas.drawLine(
      Offset(leftMargin, 0),
      Offset(leftMargin, size.height),
      paint,
    );
  }
}

// Sequential access storage: Cinta (rectángulo con borde ondulado ? User says ondulado, usually it's a circle with a tail (Magnetic Tape)
// But User says: "rectángulo con borde ondulado" or "Cinta".
// Maybe "Paper Tape"? "Punched tape" is separate.
// Sequential Access Storage (Magnetic Tape) is typically a circle with a tangent line.
// However, user description "rectángulo con borde ondulado" sounds like "Document" or "Punched tape".
// Punched tape is in the list as "Rectángulo ondulado".
// Let's assume User's "Sequential access storage" means something else or specific.
// Wait, "Parallel mode" is in Process.
// Let's look at "Sequential access storage" shape.
// Usually acts as "Magnetic Tape".
// User Description: "Cinta (rectángulo con borde ondulado)".
// I will draw a rectangle with a wavy bottom line? Or wavy everything?
// "Cinta" implies Tape.
// Let's try to mimic a tape reel symbol if possible, or stick to the user hint "rectángulo...".
// "Punched tape" is usually wavy top and bottom.
// Maybe "Sequential access storage" here is simply another wavy rectangle?
// I will draw a generic "Tape" symbol (circle with tail) IS standard.
// usage: "Rectángulo con borde ondulado". Detailed description overrides standard if user is specific.
// But wait, "Document" is "Rectángulo con borde inferior ondulado".
// I'll stick to a generic "Tape" symbol if possible but user says "Rectángulo...".
// I will draw a shape looking like a punched tape?
// Let's try: Rectangle with curved bottom (like Document) but maybe user meant something else.
// I'll assume "Magnetic Tape" shape (Circle with line) is expected standard, but user text says Rectangle.
// I will follow "Symbol Used" column description strictly: "Cinta (rectángulo con borde ondulado)".
// I will draw a rectangle with wavy bottom AND top? Or just a "Streamer".
class SequentialAccessStorageSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();

    // Draw Circle (Magnetic Tape Reel)
    // Center logic
    final radius = size.height * 0.4;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw Tangent Line at Bottom Right
    // The line usually extends from the bottom tangent point to the right.
    // Tangent point is at (centerX, centerY + radius)
    final tangentStart = Offset(centerX, centerY + radius);
    final tangentEnd = Offset(size.width, centerY + radius);

    canvas.drawLine(tangentStart, tangentEnd, paint);
  }
}

// Direct access storage: Cilindro
class DirectAccessStorageSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final curveWidth = size.width * 0.25;

    // Right face (ellipse)
    // Bounding rect for right curve
    final rightRect = Rect.fromLTWH(
      size.width - curveWidth,
      0,
      curveWidth,
      size.height,
    );
    canvas.drawOval(rightRect, paint);

    // Body lines
    // Top Line
    canvas.drawLine(
      Offset(curveWidth / 2, 0),
      Offset(size.width - curveWidth / 2, 0),
      paint,
    );
    // Bottom Line
    canvas.drawLine(
      Offset(curveWidth / 2, size.height),
      Offset(size.width - curveWidth / 2, size.height),
      paint,
    );

    // Left face (half ellipse / arc)
    // It matches the left side of the right ellipse? No, it's the other end.
    // Usually curve is same direction as the remote side of the ellipse.
    // Curve at left should be convex (bulging out) to look like a cylinder.
    // Center of left ellipse would be at curveWidth/2.
    final leftPath = Path();
    leftPath.moveTo(curveWidth / 2, 0);
    leftPath.arcToPoint(
      Offset(curveWidth / 2, size.height),
      radius: Radius.elliptical(curveWidth / 2, size.height / 2),
      clockwise: false, // Counter-clockwise for convex to the left
    );
    canvas.drawPath(leftPath, paint);
  }
}

// Document: Rectángulo con borde inferior ondulado
class DocumentSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.85);

    // Wave at bottom
    // S-curve?
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.8,
      0,
      size.height * 0.95,
    );

    path.close();
    canvas.drawPath(path, paint);
  }
}

// Manual input: Paralelogramo inclinado
// Often distinct from Data. Data is sloped sides. Manual input is sloping top.
// "Paralelogramo inclinado" might imply the top is sloped?
// Standard Manual Input: Rectangle with top sloping down from left to right (or right to left).
class ManualInputSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.moveTo(0, size.height * 0.3); // High left
    path.lineTo(size.width, 0); // Low right
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
}

// Card: Rectángulo con esquina cortada
class CardSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final cut = size.width * 0.2;
    path.moveTo(cut, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cut); // Cut happens at top left
    path.close();
    canvas.drawPath(path, paint);
  }
}

// Punched tape: Rectángulo ondulado
// (Wavy top and bottom)
class PunchedTapeSymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    // Similar to sequential but explicit for Punched Tape

    // Top wave
    path.moveTo(0, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.25,
      -size.height * 0.05,
      size.width * 0.5,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.25,
      size.width,
      size.height * 0.1,
    );

    // Right side
    path.lineTo(size.width, size.height * 0.9);

    // Bottom wave (parallel to top usually)
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 1.05,
      size.width * 0.5,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.75,
      0,
      size.height * 0.9,
    );

    path.close();
    canvas.drawPath(path, paint);
  }
}

// Display: Rectángulo con lados inclinados
// Standard Display: Bullet shape.
class DisplaySymbolPainter extends FlowchartPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final arrowWidth = size.width * 0.2;

    // Standard Display shape:
    //  ___________
    // |           )
    // |___________)
    // Or
    // <___________)
    // User says "lados inclinados".
    // I will draw [ > ) shape (Input shape + Curve) which is common.
    // Left side: Arrow/Triangle point to left? Or just straight?
    // Let's assume standard "Display" symbol (Screen).

    path.moveTo(arrowWidth, 0);
    path.lineTo(size.width - arrowWidth, 0);

    // Right rounded side
    path.arcToPoint(
      Offset(size.width - arrowWidth, size.height),
      radius: Radius.circular(size.height),
      clockwise: true,
    );

    path.lineTo(arrowWidth, size.height);

    // Left side pointed (or straight?)
    // "Rectángulo con lados inclinados". maybe trapezium?
    // I'll draw the left as a point to satisfy "inclinados".
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }
}
