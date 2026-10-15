import 'dart:io';
import 'package:path/path.dart' as p;

abstract final class ScanSessionDirHelper {
  static Directory getSessionDir(String sessionId) {
    return Directory(
      p.join(Directory.systemTemp.path, 'cache', 'scan_session', sessionId),
    );
  }

  static void deleteSessionDir(String sessionId) {
    try {
      final dir = getSessionDir(sessionId);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (_) {}
  }
}
