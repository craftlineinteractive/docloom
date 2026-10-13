import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../application/library_actions.dart';

class DocumentRenameDialog extends ConsumerStatefulWidget {
  const DocumentRenameDialog({
    super.key,
    required this.documentId,
    required this.currentName,
  });

  final String documentId;
  final String currentName;

  static Future<void> show(
    BuildContext context, {
    required String documentId,
    required String currentName,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => DocumentRenameDialog(
          documentId: documentId,
          currentName: currentName,
        ),
      );

  @override
  ConsumerState<DocumentRenameDialog> createState() => _DocumentRenameDialogState();
}

class _DocumentRenameDialogState extends ConsumerState<DocumentRenameDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Document name cannot be empty');
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });

    try {
      await ref.read(libraryActionsProvider).renameDocument(
            id: widget.documentId,
            name: name,
          );
      ref.refreshLibrary();
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        showAppToast(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Rename document',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _controller,
              label: 'Document name',
              hint: 'Enter name',
              errorText: _errorText,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.text,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppButton(
                  label: 'Save',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
