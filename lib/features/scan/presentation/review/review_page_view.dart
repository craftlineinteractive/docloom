import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/image_engine.dart';
import '../../domain/scan_session_page.dart';
import 'review_page_card.dart';

class ReviewPageView extends StatelessWidget {
  const ReviewPageView({
    super.key,
    required this.controller,
    required this.pages,
    required this.currentIndex,
    required this.onPageChanged,
    required this.engine,
  });

  final PageController controller;
  final List<ScanSessionPage> pages;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ImageEngine engine;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (ctx, i) => ReviewPageCard(
              page: pages[i],
              engine: engine,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${currentIndex + 1} / ${pages.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
