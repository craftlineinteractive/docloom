import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:docloom/core/providers/app_providers.dart';
import 'package:docloom/core/storage/document_file_store.dart';
import 'package:docloom/core/widgets/page_thumbnail.dart';

void main() {
  late Directory tempDir;
  late DocumentFileStore fileStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('page_thumbnail_test_');
    fileStore = DocumentFileStore(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  Widget buildWidget(String? relativePath) {
    return ProviderScope(
      overrides: [
        fileStoreProvider.overrideWithValue(fileStore),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: PageThumbnail(relativePath: relativePath),
        ),
      ),
    );
  }

  group('PageThumbnail.resolveThumbnailPath', () {
    test('resolves original path to _thumb.png', () {
      expect(
        PageThumbnail.resolveThumbnailPath('documents/doc1/page1_original.jpg'),
        equals('documents/doc1/page1_thumb.png'),
      );
    });

    test('resolves edited path to _thumb.png', () {
      expect(
        PageThumbnail.resolveThumbnailPath('documents/doc1/page1_edited.png'),
        equals('documents/doc1/page1_thumb.png'),
      );
    });

    test('keeps existing _thumb.png unchanged', () {
      expect(
        PageThumbnail.resolveThumbnailPath('documents/doc1/page1_thumb.png'),
        equals('documents/doc1/page1_thumb.png'),
      );
    });

    test('returns null for null, empty or non-matching paths', () {
      expect(PageThumbnail.resolveThumbnailPath(null), isNull);
      expect(PageThumbnail.resolveThumbnailPath(''), isNull);
      expect(PageThumbnail.resolveThumbnailPath('documents/doc1/notes.txt'), isNull);
    });
  });

  testWidgets('PageThumbnail renders placeholder for null path without exception', (tester) async {
    await tester.pumpWidget(buildWidget(null));
    expect(find.byIcon(LucideIcons.fileText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PageThumbnail renders placeholder for missing file without exception', (tester) async {
    await tester.pumpWidget(buildWidget('documents/doc1/page1_original.jpg'));
    expect(find.byIcon(LucideIcons.fileText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
