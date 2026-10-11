import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TintedIcon extends StatelessWidget {
  const TintedIcon({
    super.key,
    required this.icon,
    this.tint,
    this.color,
    this.size = 36,
    this.iconSize,
  });

  final IconData icon;
  final Color? tint;
  final Color? color;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final effectiveTint = tint ?? AppColors.primaryTint;
    final effectiveColor = color ?? AppColors.primary;
    final effectiveIconSize = iconSize ?? (size * 0.55);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveTint,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: effectiveIconSize,
          color: effectiveColor,
        ),
      ),
    );
  }
}
