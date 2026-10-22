import 'dart:io';

void main() {
  final dirs = [Directory('lib'), Directory('test')];
  int violations = 0;
  for (final dir in dirs) {
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final lines = entity.readAsLinesSync().length;
        if (lines >= 150) {
          print('VIOLATION: ${entity.path} has $lines lines (must be < 150)');
          violations++;
        }
      }
    }
  }
  if (violations == 0) {
    print('ALL files in lib/ and test/ are under 150 lines. OK!');
  } else {
    print('Found $violations violations!');
    exitCode = 1;
  }
}
