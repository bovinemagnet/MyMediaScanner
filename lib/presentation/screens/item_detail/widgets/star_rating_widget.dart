import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 32,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () => onChanged(starValue),
          child: Icon(
            starValue <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber.shade700,
            size: size,
            semanticLabel: 'Rate $starValue stars',
          ),
        );
      }),
    );
  }
}
