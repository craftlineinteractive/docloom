import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/presentation/review/review_filter_row.dart';
import 'package:docloom/features/scan/presentation/review/review_screen.dart';

void main() {
  late Directory tempDir;
  late String dummyFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('review_flow_test_');
    dummyFile = '${tempDir.path}/prev.jpg';
    File(dummyFile).writeAsBytesSync([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
  });

  tearDownAll(() {
    try { tempDir.deleteSync(recursive: true); } catch (_) {}
  });

  ScanSessionPage makePage(String id, {String filter = 'vivid_light', int rot = 0}) =>
      ScanSessionPage(id: id, capturePath: dummyFile, previewPath: dummyFile, quad: Quad.unit(), rotation: rot, filterId: filter);

  Widget buildApp(ProviderContainer container, {int initialIndex = 0}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ReviewScreen(initialIndex: initialIndex),
      ),
    );
  }

  testWidgets('Review counter displays 1 / 3 and swiping updates to 2 / 3', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1'));
    n.addPage(makePage('p2'));
    n.addPage(makePage('p3'));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('delete-last-page flow: multiple pages asks delete page, single page asks discard scan', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1'));
    n.addPage(makePage('p2'));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this page?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages.length, equals(1));
    expect(find.text('1 / 1'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Discard this scan?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages, isEmpty);
  });

  testWidgets('color tool toggles sub-row and apply-to-all updates all pages', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1', filter: 'original'));
    n.addPage(makePage('p2', filter: 'original'));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewFilterSubRow), findsNothing);
    await tester.tap(find.text('Color'));
    await tester.pumpAndSettle();

    expect(find.byType(ReviewFilterSubRow), findsOneWidget);
    await tester.tap(find.text('Grayscale'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages[0].filterId, equals('grayscale'));
    expect(container.read(scanSessionProvider).pages[1].filterId, equals('original'));

    await tester.tap(find.text('Apply to all pages'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages[0].filterId, equals('grayscale'));
    expect(container.read(scanSessionProvider).pages[1].filterId, equals('grayscale'));
  });

  testWidgets('rotate tool increments rotation by 90 degrees', (tester) async {
    final container = ProviderContainer(overrides: [engineProvider.overrideWithValue(FakeImageEngine())]);
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1', rot: 0));

    await tester.pumpWidget(buildApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();

    expect(container.read(scanSessionProvider).pages[0].rotation, equals(90));
  });
}
