import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

class DbCheckStatsCard extends StatelessWidget {
  const DbCheckStatsCard({
    super.key,
    required this.folderCount,
    required this.rootDocCount,
    required this.trashedDocCount,
    required this.fileCount,
    required this.logs,
  });

  final int folderCount, rootDocCount, trashedDocCount, fileCount;
  final List<String> logs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Live Counts'),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _StatRow(label: 'Active Folders', value: '$folderCount'),
              const Divider(height: AppSpacing.md),
              _StatRow(label: 'Root Documents', value: '$rootDocCount'),
              const Divider(height: AppSpacing.md),
              _StatRow(label: 'Trashed Documents', value: '$trashedDocCount'),
              const Divider(height: AppSpacing.md),
              _StatRow(label: 'Files on Disk', value: '$fileCount'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(title: 'Action Results', count: logs.length),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: logs.isEmpty
              ? Text(
                  'No actions performed yet.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < logs.length; i++) ...[
                      if (i > 0) const Divider(height: AppSpacing.sm),
                      Text(
                        logs[i],
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        Text(value, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
