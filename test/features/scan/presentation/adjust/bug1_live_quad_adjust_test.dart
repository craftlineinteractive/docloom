import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/fake_image_engine.dart';
import 'package:docloom/features/scan/data/opencv_image_engine.dart';
import 'package:docloom/features/scan/domain/live_quad_mapper.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/presentation/adjust/adjust_screen.dart';
import 'package:docloom/features/scan/presentation/adjust/crop_editor.dart';

void main() {
  group('LiveQuadMapper and Bug 1 Adjust Quad Resolution', () {
    const fakeLive = Quad(
      topLeft: Offset(0.12, 0.15),
      topRight: Offset(0.88, 0.16),
      bottomRight: Offset(0.86, 0.85),
      bottomLeft: Offset(0.14, 0.84),
    );

    test('1:1 aspect live quad matches mapped quad within 2% of diagonal', () {
      final mapped = LiveQuadMapper.map(
        liveQuad: fakeLive,
        previewAspectRatio: 3 / 4,
        captureWidth: 3000,
        captureHeight: 4000,
      );
      final error = LiveQuadMapper.maxCornerErrorNormalized(fakeLive, mapped);
      expect(error, lessThan(0.02));
    });

    test('Rotated case: landscape capture vs portrait preview maps within 2% of expected', () {
      final mapped = LiveQuadMapper.map(
        liveQuad: fakeLive,
        previewAspectRatio: 3 / 4,
        captureWidth: 4000,
        captureHeight: 3000,
      );
      expect(mapped.isValid, isTrue);
      // Verify corners are rotated 90 degrees clockwise (tl maps to bl in landscape)
      final expectedBottomLeft = Offset(fakeLive.topLeft.dy, 1.0 - fakeLive.topLeft.dx);
      final dist = (mapped.bottomLeft - expectedBottomLeft).distance / 1.4142;
      expect(dist, lessThan(0.02));
    });

    test('Non-4:3 case: 16:9 preview vs 4:3 capture maps properly within bounds', () {
      final mapped = LiveQuadMapper.map(
        liveQuad: fakeLive,
        previewAspectRatio: 9 / 16,
        captureWidth: 3000,
        captureHeight: 4000,
      );
      expect(mapped.isValid, isTrue);
      expect(mapped.topLeft.dx, greaterThanOrEqualTo(0.0));
      expect(mapped.bottomRight.dx, lessThanOrEqualTo(1.0));
    });

    test('resolveInitialQuad uses live quad if within 1.5 seconds', () async {
      final quad = await LiveQuadMapper.resolveInitialQuad(
        liveQuad: fakeLive,
        liveQuadTime: DateTime.now().subtract(const Duration(milliseconds: 500)),
        previewAspect: 3 / 4,
        captureWidth: 3000,
        captureHeight: 4000,
        previewPath: 'dummy.jpg',
        detectFromFile: (_) async => null,
      );
      final error = LiveQuadMapper.maxCornerErrorNormalized(fakeLive, quad);
      expect(error, lessThan(0.02));
    });

    test('resolveInitialQuad uses live quad if within 1.5s of shutterTime even if capture delayed', () async {
      final shutter = DateTime.now().subtract(const Duration(milliseconds: 2500));
      final liveTime = shutter.subtract(const Duration(milliseconds: 200));
      final quad = await LiveQuadMapper.resolveInitialQuad(
        liveQuad: fakeLive,
        liveQuadTime: liveTime,
        shutterTime: shutter,
        previewAspect: 3 / 4,
        captureWidth: 3000,
        captureHeight: 4000,
        previewPath: 'dummy.jpg',
        detectFromFile: (_) async => null,
      );
      final error = LiveQuadMapper.maxCornerErrorNormalized(fakeLive, quad);
      expect(error, lessThan(0.02));
    });

    test('resolveInitialQuad falls back to detection if live quad expired (>1.5s before shutter)', () async {
      final shutter = DateTime.now();
      const detectedQuad = Quad(
        topLeft: Offset(0.2, 0.2),
        topRight: Offset(0.8, 0.2),
        bottomRight: Offset(0.8, 0.8),
        bottomLeft: Offset(0.2, 0.8),
      );
      final quad = await LiveQuadMapper.resolveInitialQuad(
        liveQuad: fakeLive,
        liveQuadTime: shutter.subtract(const Duration(milliseconds: 2000)),
        shutterTime: shutter,
        previewAspect: 3 / 4,
        captureWidth: 3000,
        captureHeight: 4000,
        previewPath: 'dummy.jpg',
        detectFromFile: (_) async => detectedQuad,
      );
      expect(quad, equals(detectedQuad));
    });

    test('resolveInitialQuad falls back to Quad.defaultInset if detection returns null', () async {
      final quad = await LiveQuadMapper.resolveInitialQuad(
        liveQuad: null,
        liveQuadTime: null,
        previewAspect: 3 / 4,
        captureWidth: 3000,
        captureHeight: 4000,
        previewPath: 'dummy.jpg',
        detectFromFile: (_) async => null,
      );
      expect(quad, equals(Quad.defaultInset()));
    });
  });

  group('AdjustScreen initialQuad widget test', () {
    testWidgets('AdjustScreen uses passed initialQuad in CropEditor', (tester) async {
      final tempDir = Directory.systemTemp.createTempSync('adjust_bug1_test_');
      addTearDown(() { try { tempDir.deleteSync(recursive: true); } catch (_) {} });
      final rawPath = (File('${tempDir.path}/raw.jpg')..writeAsBytesSync([1, 2, 3])).path;
      final importPath = (File('${tempDir.path}/import.jpg')..writeAsBytesSync([1, 2, 3])).path;
      final previewPath = (File('${tempDir.path}/prev.jpg')..writeAsBytesSync([1, 2, 3])).path;

      const customQuad = Quad(
        topLeft: Offset(0.15, 0.2), topRight: Offset(0.85, 0.2),
        bottomRight: Offset(0.85, 0.8), bottomLeft: Offset(0.15, 0.8),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [engineProvider.overrideWithValue(FakeImageEngine())],
          child: MaterialApp(
            home: AdjustScreen(
              previewPath: previewPath, importedPath: importPath,
              rawCapturePath: rawPath, initialQuad: customQuad,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editorFinder = find.byType(CropEditor);
      expect(editorFinder, findsOneWidget);
      final editor = tester.widget<CropEditor>(editorFinder);
      expect(editor.quad, equals(customQuad));
    });
  });
}
