// Scan overlay widget with a semi-transparent dark background and a clear
// rectangular cutout for positioning barcodes.
//
// Author: Paul Snow
// Since: 0.0.0
import 'package:flutter/material.dart';

/// A semi-transparent overlay with a clear rectangular cutout in the centre,
/// corner brackets, and instructional text below.
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final cutoutWidth = size.width * 0.7;
        final cutoutHeight = cutoutWidth * 0.6;
        final cutoutRect = Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 - 40),
          width: cutoutWidth,
          height: cutoutHeight,
        );

        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _ScanOverlayPainter(
                cutoutRect: cutoutRect,
                cornerColour: Theme.of(context).colorScheme.primary,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: cutoutRect.bottom + 24,
              child: Text(
                'Position barcode in frame',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({
    required this.cutoutRect,
    required this.cornerColour,
  });

  final Rect cutoutRect;
  final Color cornerColour;

  static const double _cornerRadius = 12;
  static const double _cornerLength = 28;
  static const double _cornerStrokeWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the semi-transparent overlay with a cutout.
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);

    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(_cornerRadius),
    );

    // Create a path for the full screen minus the cutout.
    final backgroundPath =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(cutoutRRect)
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corner brackets.
    final cornerPaint =
        Paint()
          ..color = cornerColour
          ..strokeWidth = _cornerStrokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    _drawCornerBrackets(canvas, cutoutRect, cornerPaint);
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect, Paint paint) {
    const r = _cornerRadius;
    const l = _cornerLength;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + l)
        ..lineTo(rect.left, rect.top + r)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + r, rect.top)
        ..lineTo(rect.left + l, rect.top),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - l, rect.top)
        ..lineTo(rect.right - r, rect.top)
        ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + r)
        ..lineTo(rect.right, rect.top + l),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - l)
        ..lineTo(rect.left, rect.bottom - r)
        ..quadraticBezierTo(
          rect.left,
          rect.bottom,
          rect.left + r,
          rect.bottom,
        )
        ..lineTo(rect.left + l, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - l, rect.bottom)
        ..lineTo(rect.right - r, rect.bottom)
        ..quadraticBezierTo(
          rect.right,
          rect.bottom,
          rect.right,
          rect.bottom - r,
        )
        ..lineTo(rect.right, rect.bottom - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      cutoutRect != oldDelegate.cutoutRect ||
      cornerColour != oldDelegate.cornerColour;
}
