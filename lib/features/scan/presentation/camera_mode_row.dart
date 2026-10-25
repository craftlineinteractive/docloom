import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/capture_mode_provider.dart';
import '../domain/capture_mode.dart';
import '../../ocr/presentation/ocr_language_picker_sheet.dart';
import 'widgets/book_popup_dialog.dart';
import 'widgets/id_card_popup_dialog.dart';
import 'widgets/photo_size_popup_dialog.dart';

class CameraModeRow extends ConsumerStatefulWidget {
  const CameraModeRow({super.key});

  static Future<void> showModePopup(BuildContext context, CaptureMode mode) async {
    switch (mode) {
      case CaptureMode.photo:
        await PhotoSizePopupDialog.show(context);
        break;
      case CaptureMode.idCard:
        await IdCardPopupDialog.show(context);
        break;
      case CaptureMode.book:
        await BookPopupDialog.show(context);
        break;
      case CaptureMode.ocr:
        await OcrLanguagePickerSheet.show(context);
        break;
      default:
        break;
    }
  }

  @override
  ConsumerState<CameraModeRow> createState() => _CameraModeRowState();
}

class _CameraModeRowState extends ConsumerState<CameraModeRow> {
  final _scrollController = ScrollController();
  final Map<CaptureMode, GlobalKey> _itemKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter(CaptureMode mode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemContext = _itemKeys[mode]?.currentContext;
      if (itemContext != null && mounted) {
        Scrollable.ensureVisible(
          itemContext,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeMode = ref.watch(captureModeProvider);
    final visibleModes = CaptureMode.values.where((m) => m.visible).toList();

    for (final mode in visibleModes) {
      _itemKeys.putIfAbsent(mode, GlobalKey.new);
    }

    ref.listen<CaptureMode>(captureModeProvider, (_, next) {
      _scrollToCenter(next);
    });

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Center(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: visibleModes.map((mode) {
              final isSelected = mode == activeMode;
              return Padding(
                key: _itemKeys[mode],
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: InkWell(
                  onTap: () {
                    _scrollToCenter(mode);
                    if (isSelected && mode.hasPopup) {
                      CameraModeRow.showModePopup(context, mode);
                    } else {
                      ref.read(captureModeProvider.notifier).setMode(mode);
                      if (mode.hasPopup) {
                        CameraModeRow.showModePopup(context, mode);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppColors.primaryTint.withAlpha(50),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(120),
                              width: 1,
                            ),
                          )
                        : null,
                    child: Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.textOnDark : AppColors.textOnDarkMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
