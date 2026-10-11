import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon_button.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBack = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;

  static const double _barHeight = 56;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight);

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBack) {
      effectiveLeading = AppIconButton(
        icon: LucideIcons.arrowLeft,
        tooltip: 'Back',
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: effectiveLeading,
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
      ),
      actions: actions,
    );
  }
}
