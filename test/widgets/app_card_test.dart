import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_card.dart';

void main() {
  testWidgets('AppCard renders child and triggers onTap when set', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    await tester.tap(find.text('Card Content'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppCard without onTap renders non-tappable child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppCard(
            child: Text('Static Card'),
          ),
        ),
      ),
    );

    expect(find.text('Static Card'), findsOneWidget);
  });
}
