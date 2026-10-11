import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  factory SettingsRow.nav({
    Key? key,
    Widget? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      SettingsRow(
        key: key,
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        enabled: enabled,
        trailing: const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textSecondary),
      );

  factory SettingsRow.value({
    Key? key,
    Widget? icon,
    required String title,
    required String value,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
  }) =>
      SettingsRow(
        key: key,
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        enabled: enabled,
        trailing: Builder(
          builder: (context) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      );

  factory SettingsRow.toggle({
    Key? key,
    Widget? icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) =>
      SettingsRow(
        key: key,
        icon: icon,
        title: title,
        subtitle: subtitle,
        enabled: enabled,
        trailing: Switch(value: value, onChanged: enabled ? onChanged : null),
      );

  final Widget? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = enabled ? onTap : null;
    final rowContent = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: AppSpacing.md)],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: AppSpacing.sm), trailing!],
          ],
        ),
      ),
    );

    final widget = Opacity(opacity: enabled ? 1.0 : 0.4, child: rowContent);
    if (effectiveOnTap != null) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: effectiveOnTap, child: widget),
      );
    }
    return widget;
  }
}
