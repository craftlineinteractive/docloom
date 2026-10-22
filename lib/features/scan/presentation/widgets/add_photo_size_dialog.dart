import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/photo_size.dart';

class AddPhotoSizeDialog extends StatefulWidget {
  const AddPhotoSizeDialog({super.key});

  static Future<PhotoSize?> show(BuildContext context) =>
      showDialog<PhotoSize>(context: context, builder: (_) => const AddPhotoSizeDialog());

  @override
  State<AddPhotoSizeDialog> createState() => _AddPhotoSizeDialogState();
}

class _AddPhotoSizeDialogState extends State<AddPhotoSizeDialog> {
  final _widthCtrl = TextEditingController(text: '35');
  final _heightCtrl = TextEditingController(text: '45');
  final _dpiCtrl = TextEditingController(text: '300');
  PhotoUnit _unit = PhotoUnit.mm;
  String? _error;

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _dpiCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final w = double.tryParse(_widthCtrl.text.trim());
    final h = double.tryParse(_heightCtrl.text.trim());
    final dpi = int.tryParse(_dpiCtrl.text.trim()) ?? 300;
    if (w == null || w <= 0 || w > 10000 || h == null || h <= 0 || h > 10000) {
      setState(() => _error = 'Enter valid dimensions (1-10000)');
      return;
    }
    if (_unit != PhotoUnit.px && (dpi < 72 || dpi > 1200)) {
      setState(() => _error = 'DPI must be between 72 and 1200');
      return;
    }
    Navigator.of(context).pop(PhotoSize(
      id: 'custom_${const Uuid().v4().substring(0, 8)}',
      width: w,
      height: h,
      unit: _unit,
      dpi: _unit == PhotoUnit.px ? 1 : dpi,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: const Text('Add Custom Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(_error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
              ),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _widthCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Width', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Height', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<PhotoUnit>(
              initialValue: _unit,
              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
              items: PhotoUnit.values
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.name.toUpperCase())))
                  .toList(),
              onChanged: (u) => u != null ? setState(() => _unit = u) : null,
            ),
            if (_unit != PhotoUnit.px) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _dpiCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'DPI (e.g. 300)', border: OutlineInputBorder()),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _submit,
          child: const Text('Add', style: TextStyle(color: AppColors.textOnDark)),
        ),
      ],
    );
  }
}
