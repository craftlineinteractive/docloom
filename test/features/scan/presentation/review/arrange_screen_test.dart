import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/presentation/review/arrange_screen.dart';

void main() {
  late Directory tempDir;
  late String dummyFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('arrange_screen_test_');
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

  testWidgets('Arrange screen renders grid of cards with number badges', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('page_1'));
    n.addPage(makePage('page_2'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ArrangeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arrange pages'), findsOneWidget);
    expect(find.text('Long press, then drag to reorder'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Done button pops Arrange screen', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('p1'));

    bool popped = false;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ArrangeScreen()));
                popped = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Arrange pages'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(popped, isTrue);
  });

  testWidgets('reorder via drag target swaps pages', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final n = container.read(scanSessionProvider.notifier);
    n.addPage(makePage('first'));
    n.addPage(makePage('second'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ArrangeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Directly trigger DragTarget on second element receiving index 0
    final dragTargets = tester.widgetList<DragTarget<int>>(find.byType(DragTarget<int>));
    expect(dragTargets.length, 2);

    final target = dragTargets.last;
    target.onAcceptWithDetails?.call(DragTargetDetails<int>(data: 0, offset: Offset.zero));
    await tester.pumpAndSettle();

    final pages = container.read(scanSessionProvider).pages;
    expect(pages[0].id, equals('second'));
    expect(pages[1].id, equals('first'));
  });
}
