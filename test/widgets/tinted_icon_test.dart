import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:docloom/core/theme/app_colors.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/tinted_icon.dart';

void main() {
  testWidgets('TintedIcon renders with default primaryTint circle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: TintedIcon(
            icon: LucideIcons.folder,
            size: 36,
          ),
        ),
      ),
    );

    expect(find.byType(TintedIcon), findsOneWidget);
    expect(find.byIcon(LucideIcons.folder), findsOneWidget);
  });

  testWidgets('TintedIcon applies custom tint and color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: TintedIcon(
            icon: LucideIcons.crown,
            tint: AppColors.goldTint,
            color: AppColors.gold,
          ),
        ),
      ),
    );

    final iconWidget = tester.widget<Icon>(find.byIcon(LucideIcons.crown));
    expect(iconWidget.color, equals(AppColors.gold));
  });
}
