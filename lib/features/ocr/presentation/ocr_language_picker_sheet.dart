import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_toast.dart';
import '../application/ocr_providers.dart';
import '../domain/ocr_language.dart';
import 'ocr_language_tile.dart';

class OcrLanguagePickerSheet extends ConsumerStatefulWidget {
  const OcrLanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const OcrLanguagePickerSheet(),
      );

  @override
  ConsumerState<OcrLanguagePickerSheet> createState() =>
      _OcrLanguagePickerSheetState();
}

class _OcrLanguagePickerSheetState
    extends ConsumerState<OcrLanguagePickerSheet> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeLang = ref.watch(activeOcrLanguageProvider);
    final downloaded = ref.watch(downloadedLanguagesProvider).value ?? ['eng'];
    final progressMap = ref.watch(languageDownloadProgressProvider);

    final filtered = OcrLanguage.all.where((l) {
      if (_filterIndex == 1) return l.isIndian;
      if (_filterIndex == 2) return !l.isIndian && l.code != 'eng';
      return true;
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OCR Language', style: AppTypography.textTheme.titleMedium),
                    Text('Download offline models on-demand',
                        style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          _buildFilterTabs(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
              itemBuilder: (context, index) {
                final lang = filtered[index];
                return OcrLanguageTile(
                  lang: lang,
                  isSelected: lang.code == activeLang.code,
                  isDownloaded: lang.isBundled || downloaded.contains(lang.code),
                  progress: progressMap[lang.code],
                  onTap: () => _handleTap(lang, lang.isBundled || downloaded.contains(lang.code), progressMap[lang.code]),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildFilterTabs() {
    final tabs = ['All (${OcrLanguage.all.length})', 'Indian (13)', 'Global (13)'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSel = _filterIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              selected: isSel,
              label: Text(tabs[i], style: const TextStyle(fontSize: 12)),
              onSelected: (_) => setState(() => _filterIndex = i),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryTint,
              checkmarkColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                side: BorderSide(color: isSel ? AppColors.primary : AppColors.cardBorder),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _handleTap(OcrLanguage lang, bool isDownloaded, double? progress) async {
    if (progress != null) return;
    if (isDownloaded) {
      ref.read(activeOcrLanguageProvider.notifier).selectLanguage(lang);
      Navigator.of(context).pop();
    } else {
      showAppToastGlobal('Downloading ${lang.name} pack...');
      try {
        await ref.read(downloadedLanguagesProvider.notifier).download(lang);
        showAppToastGlobal('${lang.name} downloaded successfully');
      } catch (e) {
        showAppToastGlobal('Download failed: $e');
      }
    }
  }
}
