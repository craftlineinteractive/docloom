import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/presentation/adjust/crop_editor.dart';
import 'package:docloom/features/scan/presentation/adjust/crop_magnifier.dart';

void main() {
  late String dummyPath;

  setUpAll(() {
    final tempDir = Directory.systemTemp.createTempSync('crop_test_');
    final file = File('${tempDir.path}/preview.jpg')..writeAsBytesSync([1, 2, 3]);
    dummyPath = file.path;
  });

  Widget buildEditor({
    required Quad quad,
    required ValueChanged<Quad> onChanged,
    double aspectRatio = 1.0,
  }) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 400,
              height: 400,
              child: CropEditor(
                previewPath: dummyPath,
                quad: quad,
                aspectRatio: aspectRatio,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );

  testWidgets('Top-left and Top-right corner drags update quad', (tester) async {
    Quad currentQuad = Quad.defaultInset(0.1);
    final changes = <Quad>[];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (ctx, setState) => buildEditor(
          quad: currentQuad,
          onChanged: (q) {
            changes.add(q);
            setState(() => currentQuad = q);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Top-left is at (40, 40)
    final gesture = await tester.startGesture(const Offset(40, 40));
    await tester.pump();
    expect(find.byType(CropMagnifier), findsOneWidget);

    await gesture.moveTo(const Offset(60, 60));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(CropMagnifier), findsNothing);
    expect(changes, isNotEmpty);
    expect(changes.last.topLeft.dx, closeTo(0.15, 0.01));
    expect(changes.last.topLeft.dy, closeTo(0.15, 0.01));

    // Top-right is at (360, 40)
    final trGesture = await tester.startGesture(const Offset(360, 40));
    await trGesture.moveTo(const Offset(340, 60));
    await tester.pump();
    await trGesture.up();
    await tester.pumpAndSettle();

    expect(changes.last.topRight.dx, closeTo(0.85, 0.01));
    expect(changes.last.topRight.dy, closeTo(0.15, 0.01));
  });

  testWidgets('Bottom-right and Bottom-left corner drags update quad', (tester) async {
    Quad currentQuad = Quad.defaultInset(0.1);
    final changes = <Quad>[];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (ctx, setState) => buildEditor(
          quad: currentQuad,
          onChanged: (q) {
            changes.add(q);
            setState(() => currentQuad = q);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Bottom-right is at (360, 360)
    final brGesture = await tester.startGesture(const Offset(360, 360));
    await brGesture.moveTo(const Offset(340, 340));
    await tester.pump();
    await brGesture.up();
    await tester.pumpAndSettle();

    expect(changes.last.bottomRight.dx, closeTo(0.85, 0.01));
    expect(changes.last.bottomRight.dy, closeTo(0.85, 0.01));

    // Bottom-left is at (40, 360)
    final blGesture = await tester.startGesture(const Offset(40, 360));
    await blGesture.moveTo(const Offset(60, 340));
    await tester.pump();
    await blGesture.up();
    await tester.pumpAndSettle();

    expect(changes.last.bottomLeft.dx, closeTo(0.15, 0.01));
    expect(changes.last.bottomLeft.dy, closeTo(0.85, 0.01));
  });

  testWidgets('Invalid move that violates quad convexity/min-area is rejected', (tester) async {
    Quad currentQuad = Quad.defaultInset(0.1);
    final changes = <Quad>[];

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (ctx, setState) => buildEditor(
          quad: currentQuad,
          onChanged: (q) {
            changes.add(q);
            setState(() => currentQuad = q);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Drag top-left (40, 40) past bottom-right to (390, 390) -> cross-over makes it invalid
    final gesture = await tester.startGesture(const Offset(40, 40));
    await gesture.moveTo(const Offset(390, 390));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    for (final q in changes) {
      expect(q.isValid, isTrue);
    }
  });
}
