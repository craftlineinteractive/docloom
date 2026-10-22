import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/checkerboard.dart';
import '../domain/signature.dart';

class SignaturePreviewScreen extends ConsumerWidget {
  const SignaturePreviewScreen({super.key, required this.processedPngPath});

  final String processedPngPath;

  static Future<bool?> push(BuildContext context, String path) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SignaturePreviewScreen(processedPngPath: path)),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final baseDir = await getApplicationSupportDirectory();
    final sigsDir = Directory('${baseDir.path}/signatures');
    if (!sigsDir.existsSync()) sigsDir.createSync(recursive: true);

    final id = const Uuid().v4();
    final finalPath = '${sigsDir.path}/$id.png';
    await File(processedPngPath).copy(finalPath);

    final signature = Signature(
      id: id,
      path: finalPath,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await ref.read(signatureRepositoryProvider).add(signature);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature saved successfully')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.cropDeskBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Signature Preview', style: TextStyle(color: AppColors.textOnDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textOnDark),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 300),
                      child: Checkerboard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Image.file(
                              File(processedPngPath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textOnDark,
                        side: const BorderSide(color: AppColors.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnDark,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      onPressed: () => _save(context, ref),
                      child: const Text('Save Signature'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
