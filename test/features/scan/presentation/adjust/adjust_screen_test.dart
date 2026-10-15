import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_result.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_screen.dart';

void main() {
  late Directory tempDir;
  late String rawPath;
  late String importPath;
  late String previewPath;
  late FakeImageEngine fakeEngine;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('adjust_test_');
    final rawFile = File('${tempDir.path}/raw.jpg')..writeAsBytesSync([1, 2, 3]);
    rawPath = rawFile.path;
    final importFile = File('${tempDir.path}/import.jpg')..writeAsBytesSync([1, 2, 3]);
    importPath = importFile.path;
    final previewFile = File('${tempDir.path}/preview.jpg')..writeAsBytesSync([1, 2, 3]);
    previewPath = previewFile.path;
    fakeEngine = FakeImageEngine();
  });

  tearDown(() {
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Widget buildAdjustApp({void Function(AdjustResult? result)? onResult}) {
    return ProviderScope(
      overrides: [engineProvider.overrideWithValue(fakeEngine)],
      child: MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () async {
                final r = await Navigator.of(ctx).push<AdjustResult>(
                  MaterialPageRoute(
                    builder: (_) => AdjustScreen(
                      previewPath: previewPath,
                      importedPath: importPath,
                      rawCapturePath: rawPath,
                      pageIndicator: '1/1',
                    ),
                  ),
                );
                onResult?.call(r);
              },
              child: const Text('Open Adjust'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Rotate keeps quad valid and rotates 90 degrees', (tester) async {
    await tester.pumpWidget(buildAdjustApp());
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    final initialQuad = Quad.defaultInset();
    expect(find.text('Rotate'), findsOneWidget);

    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();

    // Rotated 90
    final rotatedQuad = initialQuad.rotated90();
    expect(rotatedQuad.isValid, isTrue);

    // Rotate 3 more times back to original
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();

    expect(find.byType(AdjustScreen), findsOneWidget);
  });

  testWidgets('Reset restores quad to defaultInset', (tester) async {
    await tester.pumpWidget(buildAdjustApp());
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.byType(AdjustScreen), findsOneWidget);
  });

  testWidgets('Continue calls renderPage with original filter and returns result', (tester) async {
    AdjustResult? outcome;
    await tester.pumpWidget(buildAdjustApp(onResult: (r) => outcome = r));
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(fakeEngine.renderPageCount, equals(1));
    expect(fakeEngine.lastRenderSrc, equals(importPath));
    expect(fakeEngine.lastRenderFilterId, equals('vivid_light'));
    expect(fakeEngine.lastRenderRotation, equals(90));
    expect(fakeEngine.lastRenderQuad, equals(Quad.defaultInset().rotated90()));
    expect(outcome, isNotNull);
    expect(outcome!.rotation, equals(90));
    expect(outcome!.filterId, equals('vivid_light'));
  });

  testWidgets('Retake deletes capture files and pops with null', (tester) async {
    AdjustResult? outcome = const AdjustResult(renderedPath: 'x', quad: Quad(topLeft: Offset.zero, topRight: Offset.zero, bottomRight: Offset.zero, bottomLeft: Offset.zero), rotation: 0);
    await tester.pumpWidget(buildAdjustApp(onResult: (r) => outcome = r));
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    expect(File(rawPath).existsSync(), isTrue);
    expect(File(importPath).existsSync(), isTrue);
    expect(File(previewPath).existsSync(), isTrue);

    await tester.tap(find.text('Retake'));
    await tester.pumpAndSettle();

    expect(outcome, isNull);
    expect(File(rawPath).existsSync(), isFalse);
    expect(File(importPath).existsSync(), isFalse);
    expect(File(previewPath).existsSync(), isFalse);
  });
}
