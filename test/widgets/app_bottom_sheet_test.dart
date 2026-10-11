import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_bottom_sheet.dart';

void main() {
  testWidgets('showAppBottomSheet displays title and child widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showAppBottomSheet<void>(
                  context,
                  title: 'Sheet Header',
                  child: const Text('Sheet Body Content'),
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet Header'), findsOneWidget);
    expect(find.text('Sheet Body Content'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet Body Content'), findsNothing);
  });
}
