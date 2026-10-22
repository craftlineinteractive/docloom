import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/presentation/review/review_bottom_bar.dart';

void main() {
  Widget buildBar({required bool isCropVisible}) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: ReviewBottomBar(
          isColorOpen: false,
          isCropVisible: isCropVisible,
          selectedFilterId: 'original',
          onSelectFilter: (_) {},
          onApplyToAll: () {},
          onCrop: () {},
          onColor: () {},
          onRotate: () {},
          onArrange: () {},
          onRetake: () {},
          onDelete: () {},
          onCheck: () {},
        ),
      ),
    );
  }

  testWidgets('ReviewBottomBar shows Crop tool when isCropVisible is true', (tester) async {
    await tester.pumpWidget(buildBar(isCropVisible: true));
    expect(find.text('Crop'), findsOneWidget);
  });

  testWidgets('ReviewBottomBar hides Crop tool when isCropVisible is false (e.g. ID card page)', (tester) async {
    await tester.pumpWidget(buildBar(isCropVisible: false));
    expect(find.text('Crop'), findsNothing);
  });
}
