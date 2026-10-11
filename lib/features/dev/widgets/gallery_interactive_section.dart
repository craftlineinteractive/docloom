import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

class GalleryInteractiveSection extends StatefulWidget {
  const GalleryInteractiveSection({super.key});

  @override
  State<GalleryInteractiveSection> createState() => _GalleryInteractiveSectionState();
}

class _GalleryInteractiveSectionState extends State<GalleryInteractiveSection> {
  bool _toggleValue = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'SettingsRow'),
        SettingsRow.nav(
          title: 'Account Settings',
          subtitle: 'Profile and preferences',
          onTap: () => showAppToast(context, 'Tapped account'),
        ),
        SettingsRow.value(
          title: 'Theme Option',
          value: 'Light Mode',
          subtitle: 'Active system theme',
          onTap: () => showAppToast(context, 'Tapped theme'),
        ),
        SettingsRow.toggle(
          title: 'Notifications',
          subtitle: 'Receive alerts',
          value: _toggleValue,
          onChanged: (val) => setState(() => _toggleValue = val),
        ),
        const SettingsRow(
          title: 'Disabled Option',
          subtitle: 'Unavailable feature (40% opacity)',
          enabled: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Dialogs, BottomSheet & Toast'),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Dialog',
              variant: AppButtonVariant.outlined,
              onPressed: () async {
                final result = await showAppDialog(
                  context,
                  title: 'Confirm Action',
                  body: 'Would you like to proceed with this operation?',
                  confirmLabel: 'Proceed',
                );
                if (context.mounted) {
                  showAppToast(context, 'Result: $result');
                }
              },
            ),
            AppButton(
              label: 'Destructive Dialog',
              variant: AppButtonVariant.danger,
              onPressed: () async {
                final result = await showAppDialog(
                  context,
                  title: 'Delete Document',
                  body: 'This will move the document to trash.',
                  confirmLabel: 'Delete',
                  destructive: true,
                );
                if (context.mounted) {
                  showAppToast(context, 'Result: $result');
                }
              },
            ),
            AppButton(
              label: 'Bottom Sheet',
              variant: AppButtonVariant.filled,
              onPressed: () {
                showAppBottomSheet<void>(
                  context,
                  title: 'Sample Sheet',
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('BottomSheet content container'),
                  ),
                );
              },
            ),
            AppButton(
              label: 'Toast with Action',
              variant: AppButtonVariant.text,
              onPressed: () {
                showAppToast(
                  context,
                  'Item saved successfully',
                  actionLabel: 'Undo',
                  onAction: () {},
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
