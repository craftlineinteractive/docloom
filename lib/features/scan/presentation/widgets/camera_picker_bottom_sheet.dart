import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'camera_picker_option.dart';

class CameraPickerBottomSheet<T> extends StatefulWidget {
  const CameraPickerBottomSheet({
    super.key, required this.title, required this.options,
    required this.initialValue, required this.onSelected,
  });

  final String title;
  final List<CameraPickerOption<T>> options;
  final T initialValue;
  final ValueChanged<T> onSelected;

  static Future<void> show<T>({
    required BuildContext context, required String title,
    required List<CameraPickerOption<T>> options,
    required T initialValue, required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => CameraPickerBottomSheet<T>(
        title: title, options: options, initialValue: initialValue, onSelected: onSelected,
      ),
    );
  }

  @override
  State<CameraPickerBottomSheet<T>> createState() => _CameraPickerBottomSheetState<T>();
}

class _CameraPickerBottomSheetState<T> extends State<CameraPickerBottomSheet<T>> {
  late T _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  Widget _buildRadio(bool isSel) => Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSel ? AppColors.primaryLight : AppColors.textSecondary, width: 2),
        ),
        child: isSel
            ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle)))
            : null,
      );

  Widget _buildOptionRow(CameraPickerOption<T> opt) {
    final isSel = opt.value == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = opt.value),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSel ? AppColors.darkSheetSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isSel ? Border.all(color: AppColors.darkSheetSelectedBorder) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.label, style: TextStyle(fontSize: 15, fontWeight: isSel ? FontWeight.w600 : FontWeight.w500, color: AppColors.textOnDark)),
                  if (opt.caption != null)
                    Text(opt.caption!, style: TextStyle(fontSize: 12, color: isSel ? AppColors.primaryLight : AppColors.textSecondary)),
                ],
              ),
            ),
            _buildRadio(isSel),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        border: Border(top: BorderSide(color: AppColors.gridLine, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.dragHandleDark, borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textOnDark)),
            const SizedBox(height: AppSpacing.md),
            ...widget.options.map(_buildOptionRow),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.textOnDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)), elevation: 0,
                ),
                onPressed: () { widget.onSelected(_selected); Navigator.of(context).pop(); },
                child: const Text('Done', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
