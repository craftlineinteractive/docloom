import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_toast.dart';
import '../application/ocr_providers.dart';
import 'ocr_result_card.dart';

class OcrResultScreen extends ConsumerStatefulWidget {
  const OcrResultScreen({super.key, required this.imagePath, this.title = 'Scanned Document'});
  final String imagePath;
  final String title;

  @override
  ConsumerState<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends ConsumerState<OcrResultScreen> {
  final _controller = TextEditingController();
  bool _isLoading = true, _isEditing = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _processOcr();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processOcr() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      final lang = ref.read(activeOcrLanguageProvider);
      final text = await ref.read(ocrServiceProvider).extractText(widget.imagePath, languageCode: lang.code);
      if (mounted) setState(() { _controller.text = text.trim(); _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'OCR failed: $e'; _isLoading = false; });
    }
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    showAppToastGlobal('Text copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(activeOcrLanguageProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Extracted Text'),
        actions: [IconButton(icon: const Icon(LucideIcons.copy, size: 20), onPressed: _controller.text.isEmpty ? null : _copy)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OcrResultCard(
                imagePath: widget.imagePath,
                title: widget.title,
                language: lang,
                onPreviewOriginal: () => showDialog(context: context, builder: (_) => Dialog(child: ClipRRect(borderRadius: BorderRadius.circular(AppRadius.lg), child: Image.file(File(widget.imagePath))))),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECOGNIZED TEXT CONTENT', style: AppTypography.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  TextButton.icon(
                    icon: Icon(_isEditing ? LucideIcons.check : LucideIcons.pencil, size: 14),
                    label: Text(_isEditing ? 'Done' : 'Edit'),
                    onPressed: _isLoading ? null : () => setState(() => _isEditing = !_isEditing),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(child: _buildTextContainer()),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(icon: const Icon(LucideIcons.copy, size: 16), label: const Text('Copy'), onPressed: _controller.text.isEmpty ? null : _copy)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: FilledButton.icon(icon: const Icon(LucideIcons.share2, size: 16), label: const Text('Share'), onPressed: _controller.text.isEmpty ? null : _copy)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContainer() {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.cardBorder)),
        alignment: Alignment.center,
        child: const Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: AppSpacing.md), Text('Extracting text with on-device OCR...')]),
      );
    }
    if (_error.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.cardBorder)),
        child: Center(child: Text(_error, style: const TextStyle(color: AppColors.danger))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.cardBorder)),
      child: _isEditing
          ? TextField(controller: _controller, maxLines: null, expands: true, decoration: const InputDecoration(border: InputBorder.none))
          : SingleChildScrollView(child: SelectableText(_controller.text.isEmpty ? 'No text detected' : _controller.text, style: AppTypography.textTheme.bodySmall)),
    );
  }
}
