import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    const cardRadius = BorderRadius.all(Radius.circular(AppRadius.lg));

    Widget body = padding != null ? Padding(padding: padding!, child: child) : child;

    if (onTap != null) {
      body = InkWell(
        onTap: onTap,
        borderRadius: cardRadius,
        child: body,
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: cardRadius,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: cardRadius,
        clipBehavior: Clip.antiAlias,
        child: body,
      ),
    );
  }
}
