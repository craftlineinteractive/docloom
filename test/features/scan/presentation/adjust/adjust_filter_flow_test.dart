import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_result.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_screen.dart';
import 'package:docloom/features/scan/presentation/adjust/filter_bottom_sheet.dart';

void main() {
  late Directory tempDir;
  late String rawPath, importPath, previewPath;
  late FakeImageEngine fakeEngine;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('adjust_filter_test_');
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

  Widget buildApp({void Function(AdjustResult? r)? onResult}) {
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

  testWidgets('Filter row displays default filter and opens sheet with 5 presets', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    expect(find.text('FILTER'), findsOneWidget);
    expect(find.text('Vivid Light'), findsOneWidget);

    await tester.tap(find.text('Vivid Light'));
    await tester.pumpAndSettle();

    expect(find.byType(FilterBottomSheet), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('5 Presets'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget);
    expect(find.text('Auto Enhance'), findsOneWidget);
    expect(find.text('Grayscale'), findsOneWidget);
    expect(find.text('Black & White'), findsOneWidget);

    // Pick Grayscale
    await tester.tap(find.text('Grayscale'));
    await tester.pumpAndSettle();

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(FilterBottomSheet), findsNothing);
    expect(find.text('Grayscale'), findsOneWidget);
  });

  testWidgets('Picking filter updates continue result filterId', (tester) async {
    AdjustResult? outcome;
    await tester.pumpWidget(buildApp(onResult: (r) => outcome = r));
    await tester.tap(find.text('Open Adjust'));
    await tester.pumpAndSettle();

    // Open filter sheet and pick Black & White
    await tester.tap(find.text('Vivid Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Black & White'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(fakeEngine.lastRenderFilterId, equals('black_white'));
    expect(outcome, isNotNull);
    expect(outcome!.filterId, equals('black_white'));
  });
}
