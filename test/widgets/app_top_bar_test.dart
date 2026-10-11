import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_top_bar.dart';

void main() {
  testWidgets('AppTopBar displays title and renders 56 high', (tester) async {
    const bar = AppTopBar(title: 'Top Bar Title');
    expect(bar.preferredSize.height, equals(56));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          appBar: bar,
        ),
      ),
    );

    expect(find.text('Top Bar Title'), findsOneWidget);
  });

  testWidgets('AppTopBar renders back button when showBack is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          appBar: AppTopBar(
            title: 'Detail Screen',
            showBack: true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Back'), findsOneWidget);
  });
}
