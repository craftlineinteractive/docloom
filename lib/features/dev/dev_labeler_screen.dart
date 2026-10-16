import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../scan/domain/quad.dart';
import '../scan/presentation/adjust/crop_editor.dart';

class DevLabelerScreen extends StatefulWidget {
  const DevLabelerScreen({super.key});

  @override
  State<DevLabelerScreen> createState() => _DevLabelerScreenState();
}

class _DevLabelerScreenState extends State<DevLabelerScreen> {
  static const _fixtures = [
    '01_baseline.jpg', '02_baseline.jpg', '03_baseline.jpg',
    '04_tilted_page.jpg', '05_tilted_page.jpg', '06_rotated_page.jpg',
    '07_rotated_page.jpg', '08_shadow_page.jpg', '09_shadow_page.jpg',
    '10_dim_light.jpg', '11_dim_light.jpg', '12_patterned_desk.jpg',
    '13_patterned_desk.jpg', '14_white_on_white.jpg', '15_book_cover.jpg',
    '16_open_book.jpg', '17_reciept_bill.jpg', '18_blank_card.jpg',
    '19_croped_page_edge.jpg',
  ];

  int _currentIndex = 0;
  Quad _quad = Quad.defaultInset();

  String get _currentPath => 'test/fixtures/documents/${_fixtures[_currentIndex]}';

  String get _jsonString {
    double r(double v) => double.parse(v.toStringAsFixed(4));
    final map = {
      'corners': [
        [r(_quad.tl.dx), r(_quad.tl.dy)],
        [r(_quad.tr.dx), r(_quad.tr.dy)],
        [r(_quad.br.dx), r(_quad.br.dy)],
        [r(_quad.bl.dx), r(_quad.bl.dy)],
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  void _copyJson() {
    Clipboard.setData(ClipboardData(text: _jsonString));
    showAppToastGlobal('Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final file = File(_currentPath);
    final exists = file.existsSync();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Labeler: ${_fixtures[_currentIndex]}',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
            onPressed: _currentIndex > 0
                ? () => setState(() {
                      _currentIndex--;
                      _quad = Quad.defaultInset();
                    })
                : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: AppColors.textPrimary),
            onPressed: _currentIndex < _fixtures.length - 1
                ? () => setState(() {
                      _currentIndex++;
                      _quad = Quad.defaultInset();
                    })
                : null,
          ),
        ],
      ),
      body: exists
          ? Column(
              children: [
                Expanded(
                  child: CropEditor(
                    key: ValueKey(_currentPath),
                    previewPath: _currentPath,
                    quad: _quad,
                    onChanged: (q) => setState(() => _quad = q),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        _jsonString,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Reset',
                              variant: AppButtonVariant.outlined,
                              onPressed: () => setState(() => _quad = Quad.defaultInset()),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: 'Copy JSON',
                              icon: const Icon(LucideIcons.copy, size: 16, color: AppColors.surface),
                              onPressed: _copyJson,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'File not found: $_currentPath',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
              ),
            ),
    );
  }
}
