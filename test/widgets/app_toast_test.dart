import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/app_toast.dart';

void main() {
  testWidgets('showAppToast displays floating snackbar and triggers action', (tester) async {
    bool actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showAppToast(
                  context,
                  'Operation Successful',
                  actionLabel: 'Undo',
                  onAction: () => actionPressed = true,
                );
              },
              child: const Text('Show Toast'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pumpAndSettle();

    expect(find.text('Operation Successful'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(actionPressed, isTrue);
  });
}
