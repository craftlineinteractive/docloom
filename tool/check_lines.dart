// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  var over = 0;
  for (final dir in ['lib', 'test']) {
    for (final entity in Directory(dir).listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final count = entity.readAsLinesSync().length;
        if (count > 150) {
          print('${entity.path}: $count lines');
          over++;
        }
      }
    }
  }
  if (over == 0) {
    print('ALL files <= 150 lines! Perfect.');
  } else {
    print('Total violating files: $over');
    exit(1);
  }
}
