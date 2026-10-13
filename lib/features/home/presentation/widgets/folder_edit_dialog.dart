import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../application/library_actions.dart';
import 'folder_palette_row.dart';

class FolderEditDialog extends ConsumerStatefulWidget {
  const FolderEditDialog({
    super.key,
    this.folderId,
    this.initialName = '',
    this.initialColorIndex = 0,
    this.isRename = false,
  });

  final String? folderId;
  final String initialName;
  final int initialColorIndex;
  final bool isRename;

  static Future<void> showCreate(BuildContext context) =>
      showDialog<void>(context: context, builder: (_) => const FolderEditDialog());

  static Future<void> showRename(
    BuildContext context, {
    required String folderId,
    required String currentName,
    required int currentColorIndex,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => FolderEditDialog(
          folderId: folderId,
          initialName: currentName,
          initialColorIndex: currentColorIndex,
          isRename: true,
        ),
      );

  @override
  ConsumerState<FolderEditDialog> createState() => _FolderEditDialogState();
}

class _FolderEditDialogState extends ConsumerState<FolderEditDialog> {
  late final TextEditingController _controller;
  late int _selectedColor;
  String? _errorText;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _selectedColor = widget.initialColorIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Folder name cannot be empty');
      return;
    }
    setState(() {
      _errorText = null;
      _submitting = true;
    });

    try {
      final actions = ref.read(libraryActionsProvider);
      if (widget.isRename) {
        await actions.renameFolder(id: widget.folderId!, name: name);
      } else {
        await actions.createFolder(name: name, colorIndex: _selectedColor);
      }
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl))),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.isRename ? 'Rename folder' : 'New folder', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(controller: _controller, label: 'Folder name', hint: 'Enter name', errorText: _errorText),
            if (!widget.isRename) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Color', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              FolderPaletteRow(selectedIndex: _selectedColor, onSelect: (i) => setState(() => _selectedColor = i)),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(label: 'Cancel', variant: AppButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: AppSpacing.sm),
                AppButton(label: widget.isRename ? 'Save' : 'Create', loading: _submitting, onPressed: _submit),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
