import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/qr_scanner_providers.dart';
import '../../domain/qr_parsed_content.dart';
import 'qr_url_confirm_dialog.dart';

class QrResultActions extends ConsumerWidget {
  const QrResultActions({
    super.key,
    required this.content,
    required this.onScanAgain,
  });

  final QrParsedContent content;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wifi = content is WifiQrContent ? content as WifiQrContent : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wifi != null && wifi.password.isNotEmpty) ...[
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryLight),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: wifi.password));
              _showSnack(context, 'Wi-Fi password copied');
            },
            icon: const Icon(Icons.password, size: 18),
            label: const Text('Copy Password'),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content.rawText));
                  _showSnack(context, 'Copied to clipboard');
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy'),
              ),
            ),
            if (content.canOpen && content.openUri != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => _handleOpen(context, ref, content.openUri!),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Open'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onScanAgain();
          },
          child: const Text('Scan again'),
        ),
      ],
    );
  }

  Future<void> _handleOpen(BuildContext context, WidgetRef ref, Uri uri) async {
    final confirmed = await QrUrlConfirmDialog.show(context, uri);
    if (confirmed && context.mounted) {
      await ref.read(urlLauncherServiceProvider).launch(uri);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}
