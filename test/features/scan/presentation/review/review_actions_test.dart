import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/presentation/review/arrange_screen.dart';
import 'package:docloom/features/scan/presentation/review/review_screen.dart';

void main() {
  late Directory tempDir;
  late String dummyFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('review_actions_test_');
    dummyFile = '${tempDir.path}/prev.jpg';
    File(dummyFile).writeAsBytesSync([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
  });

  tearDownAll(() {
    try { tempDir.deleteSync(recursive: true); } catch (_) {}
  });

  ScanSessionPage makePage(String id) => ScanSessionPage(
        id: id,
        capturePath: dummyFile,
        previewPath: dummyFile,
        quad: Quad.unit(),
        rotation: 0,
        filterId: 'vivid_light',
      );

  Widget buildApp(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ReviewScreen()),
    );
  }

  testWidgets('tapping document title opens rename dialog and updates name', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1'));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    expect(find.text('docLoom Scan'), findsOneWidget);
    await tester.tap(find.text('docLoom Scan'));
    await tester.pumpAndSettle();

    expect(find.text('Rename document'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'My Contract');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).name, equals('My Contract'));
    expect(find.text('My Contract'), findsOneWidget);
  });

  testWidgets('tapping arrange tool opens ArrangeScreen', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1'));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Arrange'));
    await tester.pumpAndSettle();

    expect(find.byType(ArrangeScreen), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(ArrangeScreen), findsNothing);
  });
}
