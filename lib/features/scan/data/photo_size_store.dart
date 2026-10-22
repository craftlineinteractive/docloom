import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../domain/photo_size.dart';
import '../domain/photo_size_presets.dart';

class PhotoSizeStore {
  PhotoSizeStore({Directory? dir, String? filePath})
      : _customDir = dir,
        _customFilePath = filePath;

  final Directory? _customDir;
  final String? _customFilePath;

  Future<File> _getFile() async {
    if (_customFilePath != null) return File(_customFilePath);
    final dir = _customDir ?? await getApplicationSupportDirectory();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return File(p.join(dir.path, 'photo_sizes.json'));
  }

  Future<({List<PhotoSize> sizes, String selectedId})> load() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return _restoreDefaults();
      }
      final content = await file.readAsString();
      if (content.trim().isEmpty) return _restoreDefaults();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final rawList = data['sizes'] as List<dynamic>? ?? [];
      final sizes = rawList
          .map((e) => PhotoSize.fromJson(e as Map<String, dynamic>))
          .toList();
      if (sizes.isEmpty) return _restoreDefaults();

      var selectedId = data['selectedId'] as String? ?? sizes.first.id;
      if (!sizes.any((s) => s.id == selectedId)) {
        selectedId = sizes.first.id;
      }
      return (sizes: sizes, selectedId: selectedId);
    } catch (_) {
      return _restoreDefaults();
    }
  }

  Future<({List<PhotoSize> sizes, String selectedId})> _restoreDefaults() async {
    final defaults = PhotoSizePresets.defaults;
    const selectedId = 'preset_2x2_in';
    await save(sizes: defaults, selectedId: selectedId);
    return (sizes: defaults, selectedId: selectedId);
  }

  Future<({List<PhotoSize> sizes, String selectedId})> resetDefaults() =>
      _restoreDefaults();

  Future<void> save({
    required List<PhotoSize> sizes,
    required String selectedId,
  }) async {
    final file = await _getFile();
    final effectiveSizes =
        sizes.isEmpty ? PhotoSizePresets.defaults : sizes;
    final effectiveSelectedId =
        effectiveSizes.any((s) => s.id == selectedId)
            ? selectedId
            : effectiveSizes.first.id;

    final json = jsonEncode({
      'selectedId': effectiveSelectedId,
      'sizes': effectiveSizes.map((s) => s.toJson()).toList(),
    });
    await file.writeAsString(json);
  }
}
