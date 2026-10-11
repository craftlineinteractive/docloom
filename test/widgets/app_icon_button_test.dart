import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_icon_button.dart';

void main() {
  testWidgets('AppIconButton renders with tooltip and triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppIconButton(
            icon: LucideIcons.search,
            tooltip: 'Search Documents',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(AppIconButton), findsOneWidget);
    expect(find.byTooltip('Search Documents'), findsOneWidget);

    final size = tester.getSize(find.byType(AppIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));

    await tester.tap(find.byType(AppIconButton));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppIconButton does not trigger when disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppIconButton(
            icon: LucideIcons.search,
            tooltip: 'Disabled Search',
            onPressed: null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppIconButton));
    await tester.pump();
  });
}
