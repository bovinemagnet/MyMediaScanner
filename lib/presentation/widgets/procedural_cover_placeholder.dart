import 'package:flutter/material.dart';
import 'package:mymediascanner/app/theme/app_media_colors.dart';
import 'package:mymediascanner/domain/entities/media_type.dart';

/// Paints a cover-art placeholder when an item has no `coverUrl`.
///
/// The output is size-agnostic: the painter scales stripes, monogram, and
/// type badge to the available canvas. The colour palette is pulled from
/// [AppMediaColors] so each theme's media tints flow through automatically.
class ProceduralCoverPlaceholder extends StatelessWidget {
  const ProceduralCoverPlaceholder({
    super.key,
    required this.title,
    required this.mediaType,
    this.showTypeBadge = true,
  });

  /// Used to derive the monogram (first two meaningful letters).
  final String title;
  final MediaType mediaType;
  final bool showTypeBadge;

  @override
  Widget build(BuildContext context) {
    final mediaColors = context.mediaColors;
    return CustomPaint(
      painter: _ProceduralCoverPainter(
        monogram: _monogramFor(title),
        typeLabel: showTypeBadge ? mediaType.label.toUpperCase() : null,
        background: mediaColors.softFor(mediaType),
        stripe: mediaColors.solidFor(mediaType).withValues(alpha: 0.18),
        ink: mediaColors.inkFor(mediaType),
      ),
      child: const SizedBox.expand(),
    );
  }

  static String _monogramFor(String title) {
    final words = title
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final word = words.first;
      return word.length >= 2
          ? word.substring(0, 2).toUpperCase()
          : word.toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}

class _ProceduralCoverPainter extends CustomPainter {
  _ProceduralCoverPainter({
    required this.monogram,
    required this.typeLabel,
    required this.background,
    required this.stripe,
    required this.ink,
  });

  final String monogram;
  final String? typeLabel;
  final Color background;
  final Color stripe;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background fill.
    canvas.drawRect(rect, Paint()..color = background);

    // Diagonal stripes.
    final stripePaint = Paint()
      ..color = stripe
      ..style = PaintingStyle.fill;
    final stripeWidth = size.shortestSide * 0.08;
    final spacing = stripeWidth * 2.6;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    // Monogram in the centre.
    final monogramSize = size.shortestSide * 0.42;
    final textPainter = TextPainter(
      text: TextSpan(
        text: monogram,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w800,
          fontSize: monogramSize,
          color: ink,
          letterSpacing: -monogramSize * 0.04,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Type badge top-right.
    final label = typeLabel;
    if (label == null) return;
    final badgeSize = size.shortestSide * 0.11;
    final badgePainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w700,
          fontSize: badgeSize,
          color: ink,
          letterSpacing: badgeSize * 0.06,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pad = size.shortestSide * 0.06;
    final badgeRect = Rect.fromLTWH(
      size.width - badgePainter.width - pad * 1.6,
      pad * 0.6,
      badgePainter.width + pad,
      badgePainter.height + pad * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(pad * 0.6)),
      Paint()..color = ink.withValues(alpha: 0.12),
    );
    badgePainter.paint(
      canvas,
      Offset(badgeRect.left + pad * 0.5, badgeRect.top + pad * 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _ProceduralCoverPainter oldDelegate) {
    return oldDelegate.monogram != monogram ||
        oldDelegate.typeLabel != typeLabel ||
        oldDelegate.background != background ||
        oldDelegate.stripe != stripe ||
        oldDelegate.ink != ink;
  }
}
