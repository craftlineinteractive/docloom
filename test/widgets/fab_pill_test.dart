import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/theme/app_theme.dart';
import 'package:docloom/core/widgets/fab_pill.dart';

void main() {
  testWidgets('FabPill renders both buttons and triggers callbacks', (tester) async {
    bool cameraTapped = false;
    bool addTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: FabPill(
            onCamera: () => cameraTapped = true,
            onAdd: () => addTapped = true,
          ),
        ),
      ),
    );

    expect(find.byType(FabPill), findsOneWidget);
    expect(find.bySemanticsLabel('Scan document'), findsOneWidget);
    expect(find.bySemanticsLabel('Import'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Scan document'));
    await tester.pump();
    expect(cameraTapped, isTrue);

    await tester.tap(find.bySemanticsLabel('Import'));
    await tester.pump();
    expect(addTapped, isTrue);
  });
}
