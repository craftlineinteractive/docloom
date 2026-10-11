import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final displayTitle = count != null ? '$title ($count)' : title;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouch),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            displayTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
