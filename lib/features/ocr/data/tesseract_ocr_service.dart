import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../domain/ocr_service.dart';

class TesseractOcrService implements OcrService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main';

  Future<Directory> _getTessdataDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'tessdata'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<bool> isLanguageAvailable(String code) async {
    if (code == 'eng') return true;
    final dir = await _getTessdataDir();
    return File(p.join(dir.path, '$code.traineddata')).exists();
  }

  @override
  Future<List<String>> getAvailableLanguageCodes() async {
    final dir = await _getTessdataDir();
    final list = <String>['eng'];
    if (await dir.exists()) {
      for (final entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.traineddata')) {
          final name = p.basenameWithoutExtension(entity.path);
          if (name != 'eng' && !list.contains(name)) {
            list.add(name);
          }
        }
      }
    }
    return list;
  }

  @override
  Future<void> downloadLanguage(
    String code, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await _getTessdataDir();
    final destFile = File(p.join(dir.path, '$code.traineddata'));
    final tempFile = File(p.join(dir.path, '$code.traineddata.tmp'));

    final client = HttpClient();
    try {
      final uri = Uri.parse('$_baseUrl/$code.traineddata');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Download failed with status ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      var received = 0;
      final sink = tempFile.openWrite();

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }
      await sink.flush();
      await sink.close();

      if (await destFile.exists()) {
        await destFile.delete();
      }
      await tempFile.rename(destFile.path);
      onProgress?.call(1.0);
    } finally {
      client.close();
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<void> deleteLanguage(String code) async {
    if (code == 'eng') return;
    final dir = await _getTessdataDir();
    final file = File(p.join(dir.path, '$code.traineddata'));
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<String> extractText(
    String imagePath, {
    required String languageCode,
  }) async {
    return FlutterTesseractOcr.extractText(
      imagePath,
      language: languageCode,
      args: {'preserve_interword_spaces': '1'},
    );
  }
}
