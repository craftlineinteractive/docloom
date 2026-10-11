import 'dart:io';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../core/db/app_database.dart';
import '../core/providers/app_providers.dart';
import '../core/storage/document_file_store.dart';

Future<List<Override>> bootstrap() async {
  final dbPath = p.join(await getDatabasesPath(), 'docloom.db');
  final appDb = await AppDatabase.open(
    factory: databaseFactory,
    path: dbPath,
  );

  final docsDir = await getApplicationDocumentsDirectory();
  final fileStoreRoot = Directory(p.join(docsDir.path, 'docloom'));
  final fileStore = DocumentFileStore(fileStoreRoot);

  return [
    appDatabaseProvider.overrideWithValue(appDb),
    fileStoreProvider.overrideWithValue(fileStore),
  ];
}
