import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/router/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import 'widgets/gallery_interactive_section.dart';

class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'Component Gallery',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              label: 'DB & Storage Check Screen',
              icon: const Icon(LucideIcons.database, size: 18, color: AppColors.surface),
              onPressed: () => context.push(Routes.dbCheck),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'AppButton'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(label: 'Filled', onPressed: () {}),
                AppButton(label: 'Outlined', variant: AppButtonVariant.outlined, onPressed: () {}),
                AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
                AppButton(label: 'Danger', variant: AppButtonVariant.danger, onPressed: () {}),
                const AppButton(label: 'Disabled', onPressed: null),
                const AppButton(label: 'Loading', loading: true),
                AppButton(
                  label: 'With Icon',
                  icon: const Icon(LucideIcons.sparkles, size: 18, color: AppColors.surface),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'AppIconButton & TintedIcon'),
            Row(
              children: [
                AppIconButton(icon: LucideIcons.search, tooltip: 'Search', onPressed: () {}),
                const SizedBox(width: AppSpacing.md),
                const TintedIcon(icon: LucideIcons.folder),
                const SizedBox(width: AppSpacing.md),
                const TintedIcon(
                  icon: LucideIcons.crown,
                  tint: AppColors.goldTint,
                  color: AppColors.gold,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'AppCard'),
            const AppCard(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('AppCard without onTap'),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => showAppToast(context, 'Tapped card with ripple'),
              child: const Text('AppCard with onTap (tappable ripple)'),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'SectionHeader With Trailing',
              count: 3,
              trailing: AppIconButton(
                icon: LucideIcons.moreVertical,
                tooltip: 'More',
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const GalleryInteractiveSection(),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'AppTextField'),
            const AppTextField(
              label: 'Document Title',
              hint: 'Enter file name...',
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Invalid Input',
              hint: 'Required field',
              errorText: 'Name cannot be empty',
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'FabPill'),
            SizedBox(
              height: 72,
              child: Center(
                child: FabPill(
                  onCamera: () => showAppToast(context, 'Camera clicked'),
                  onAdd: () => showAppToast(context, 'Add clicked'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'EmptyState'),
            EmptyState(
              icon: LucideIcons.fileText,
              title: 'No Documents Yet',
              body: 'Scan or import your first file to preview it here.',
              actionLabel: 'Scan Document',
              onAction: () => showAppToast(context, 'Action pressed'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
