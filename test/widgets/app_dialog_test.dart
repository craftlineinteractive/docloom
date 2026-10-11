import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_dialog.dart';

void main() {
  testWidgets('showAppDialog returns true on confirm and false on cancel', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                dialogResult = await showAppDialog(
                  context,
                  title: 'Confirm Operation',
                  body: 'Are you sure?',
                  confirmLabel: 'Proceed',
                  cancelLabel: 'Dismiss',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    // Test cancel
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Operation'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(dialogResult, isFalse);

    // Test confirm
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed'));
    await tester.pumpAndSettle();
    expect(dialogResult, isTrue);
  });
}
