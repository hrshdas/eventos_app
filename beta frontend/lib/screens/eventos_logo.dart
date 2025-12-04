import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Vector-based EVENTOS wordmark painted with CustomPainter.
///
/// API:
///   - size: overall width of the wordmark (height is derived from aspect ratio)
///   - color: color used for all strokes/fills
///
/// Implementation notes:
/// - The canvas uses a vector grid of baseW x baseH and scales all strokes/paths.
/// - Letters are drawn with thick strokes and rounded caps for a bold, modern look.
/// - “O” is a circle with a centered small dot.
/// - “S” uses quadratic beziers for a smooth curve.
///
/// Tweakable constants:
/// - strokeBase: controls overall letter stroke thickness (scaled with size)
/// - dotRatio: size of the inner dot inside the “O” (relative to letter height)
class EventosLogo extends StatelessWidget {
  final double size; // overall width
  final Color color;

  const EventosLogo({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Keep aspect ratio based on our base grid below.
    const double baseW = _EventosLogoPainter.baseW;
    const double baseH = _EventosLogoPainter.baseH;
    return SizedBox(
      width: size,
      height: size * (baseH / baseW),
      child: CustomPaint(
        painter: _EventosLogoPainter(color: color),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

class _EventosLogoPainter extends CustomPainter {
  _EventosLogoPainter({required this.color});

  final Color color;

  // Base vector grid (width x height). We draw in this space and scale to fit.
  static const double baseW = 420.0;
  static const double baseH = 100.0;

  // Letter layout: widths and spacing on the base grid.
  static const double letterW = 52.0;  // default letter width for E,V,E,N,T,S
  static const double letterO = 62.0;  // wider for the “O”
  static const double spacing = 14.0;  // spacing between letters

  // Strokes and dot
  static const double strokeBase = 12.0;    // base stroke thickness (scaled)
  static const double dotRatio = 0.18;      // inner dot diameter = dotRatio * letter height

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / baseW;
    final double stroke = strokeBase * scale;
    final double h = baseH * scale;
    final double letterH = h * 0.72; // letters height (with some top/bottom margins)
    final double baselineY = (h - letterH) / 2.0; // top y of letters

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double x = 0.0;

    // E
    x = _drawE(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    x += spacing * scale;

    // V
    x = _drawV(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    x += spacing * scale;

    // Second E
    x = _drawE(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    x += spacing * scale;

    // N
    x = _drawN(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    x += spacing * scale;

    // T
    x = _drawT(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    x += spacing * scale;

    // O (circle + centered dot)
    x = _drawO(canvas, x, baselineY, letterO * scale, letterH, strokePaint, fillPaint);
    x += spacing * scale;

    // S (bezier)
    x = _drawS(canvas, x, baselineY, letterW * scale, letterH, strokePaint);
    // no extra spacing after last letter
  }

  // E: vertical + three horizontals
  double _drawE(Canvas canvas, double x, double y, double w, double h, Paint p) {
    final double left = x + w * 0.15;
    final double right = x + w * 0.98;
    final double top = y + h * 0.0;
    final double mid = y + h * 0.50;
    final double bottom = y + h * 1.0;

    final path = Path()
      ..moveTo(left, top)
      ..lineTo(left, bottom)            // vertical
      ..moveTo(left, top)
      ..lineTo(right, top)              // top arm
      ..moveTo(left, mid)
      ..lineTo(x + w * 0.78, mid)       // mid arm
      ..moveTo(left, bottom)
      ..lineTo(right, bottom);          // bottom arm

    canvas.drawPath(path, p);
    return x + w;
  }

  // V: two diagonals meet at bottom
  double _drawV(Canvas canvas, double x, double y, double w, double h, Paint p) {
    final double topLx = x + w * 0.10;
    final double topRx = x + w * 0.90;
    final double topY = y + h * 0.0;
    final double bottomX = x + w * 0.50;
    final double bottomY = y + h * 1.0;

    final path = Path()
      ..moveTo(topLx, topY)
      ..lineTo(bottomX, bottomY)
      ..lineTo(topRx, topY);

    canvas.drawPath(path, p);
    return x + w;
  }

  // N: left vertical + diagonal up + right vertical
  double _drawN(Canvas canvas, double x, double y, double w, double h, Paint p) {
    final double leftX = x + w * 0.10;
    final double rightX = x + w * 0.90;
    final double topY = y + h * 0.0;
    final double bottomY = y + h * 1.0;

    final path = Path()
      ..moveTo(leftX, bottomY)
      ..lineTo(leftX, topY)         // left vertical
      ..lineTo(rightX, bottomY)     // diagonal
      ..moveTo(rightX, bottomY)
      ..lineTo(rightX, topY);       // right vertical

    canvas.drawPath(path, p);
    return x + w;
  }

  // T: top bar + center vertical
  double _drawT(Canvas canvas, double x, double y, double w, double h, Paint p) {
    final double left = x + w * 0.05;
    final double right = x + w * 0.95;
    final double top = y + h * 0.0;
    final double midX = x + w * 0.50;
    final double bottom = y + h * 1.0;

    final path = Path()
      ..moveTo(left, top)
      ..lineTo(right, top)       // top bar
      ..moveTo(midX, top)
      ..lineTo(midX, bottom);    // stem

    canvas.drawPath(path, p);
    return x + w;
  }

  // O: outer circle stroked + inner dot filled+stroked (centered)
  double _drawO(Canvas canvas, double x, double y, double w, double h, Paint stroke, Paint fill) {
    // Fit a circle within the letter box
    final double cx = x + w * 0.50;
    final double cy = y + h * 0.50;
    final double r = (h * 0.48); // outer radius (stroke draws inside/outside)

    canvas.drawCircle(Offset(cx, cy), r, stroke);

    final double dotR = h * dotRatio * 0.5; // radius from dotRatio of height
    canvas.drawCircle(Offset(cx, cy), dotR, fill);
    canvas.drawCircle(Offset(cx, cy), dotR, stroke);
    return x + w;
  }

  // S: two smooth curves using quadratic beziers
  double _drawS(Canvas canvas, double x, double y, double w, double h, Paint p) {
    final double left = x + w * 0.10;
    final double right = x + w * 0.90;
    final double top = y + h * 0.0;
    final double midY = y + h * 0.50;
    final double bottom = y + h * 1.0;

    final path = Path()
      // Upper curve: start near right, curve to mid-left
      ..moveTo(right, y + h * 0.15)
      ..quadraticBezierTo(x + w * 0.55, top, x + w * 0.35, midY)
      // Lower curve: continue to bottom-right
      ..quadraticBezierTo(x + w * 0.60, y + h * 0.80, right, bottom - h * 0.15);

    canvas.drawPath(path, p);
    return x + w;
  }

  @override
  bool shouldRepaint(covariant _EventosLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}