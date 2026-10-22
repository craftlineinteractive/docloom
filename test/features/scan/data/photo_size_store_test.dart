import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/scan/data/photo_size_store.dart';
import 'package:docloom/features/scan/domain/photo_size.dart';
import 'package:docloom/features/scan/domain/photo_size_presets.dart';

void main() {
  test('PhotoSizeStore saves and loads custom list and selectedId', () async {
    final tempDir = Directory.systemTemp.createTempSync();
    final filePath = '${tempDir.path}/photo_sizes.json';
    final store = PhotoSizeStore(filePath: filePath);

    final initial = await store.load();
    expect(initial.sizes.length, equals(PhotoSizePresets.defaults.length));
    expect(initial.selectedId, equals('preset_2x2_in'));

    // Save with custom size
    const custom = PhotoSize(
      id: 'custom_123',
      width: 40,
      height: 40,
      unit: PhotoUnit.mm,
      dpi: 300,
    );
    final updatedList = [...initial.sizes, custom];
    await store.save(sizes: updatedList, selectedId: 'custom_123');

    final loaded = await store.load();
    expect(loaded.sizes.length, equals(updatedList.length));
    expect(loaded.selectedId, equals('custom_123'));
    expect(loaded.sizes.any((s) => s.id == 'custom_123'), isTrue);

    // Delete custom size
    final afterDelete = loaded.sizes.where((s) => s.id != 'custom_123').toList();
    await store.save(sizes: afterDelete, selectedId: 'preset_2x2_in');

    final loadedAfterDelete = await store.load();
    expect(loadedAfterDelete.sizes.length, equals(PhotoSizePresets.defaults.length));
    expect(loadedAfterDelete.sizes.any((s) => s.id == 'custom_123'), isFalse);

    // Reset defaults
    await store.resetDefaults();
    final reset = await store.load();
    expect(reset.sizes.length, equals(PhotoSizePresets.defaults.length));

    tempDir.deleteSync(recursive: true);
  });
}
