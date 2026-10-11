import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renders and fires onTap when enabled', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Click Me',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Click Me'), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppButton does not fire onTap when disabled or loading', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Disabled',
            onPressed: null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Loading',
            loading: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tapped, isFalse);
  });
}
