import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/presentation/widgets/id_card_step_banner.dart';

void main() {
  testWidgets('IdCardStepBanner displays step 1 text and handles cancel', (tester) async {
    var cancelled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IdCardStepBanner(
            step: 1,
            onCancel: () => cancelled = true,
          ),
        ),
      ),
    );

    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Scan front side of ID Card'), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    expect(cancelled, isTrue);
  });

  testWidgets('IdCardStepBanner displays step 2 text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IdCardStepBanner(
            step: 2,
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('Now scan the back side'), findsOneWidget);
  });
}
