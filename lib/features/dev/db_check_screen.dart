import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import '../documents/domain/document_sort.dart';
import '../documents/domain/new_page.dart';
import 'widgets/db_check_action_buttons.dart';
import 'widgets/db_check_stats_card.dart';

class DbCheckScreen extends ConsumerStatefulWidget {
  const DbCheckScreen({super.key});

  @override
  ConsumerState<DbCheckScreen> createState() => _DbCheckScreenState();
}

class _DbCheckScreenState extends ConsumerState<DbCheckScreen> {
  int _folderCount = 0, _rootDocCount = 0, _trashedDocCount = 0, _fileCount = 0, _folderSeq = 1;
  bool _busy = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCounts());
  }

  void _addLog(String msg) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toIso8601String().substring(11, 19)}: $msg');
      if (_logs.length > 10) _logs.removeLast();
    });
  }

  Future<void> _refreshCounts() async {
    final folders = await ref.read(folderRepositoryProvider).listActive();
    final docs = await ref.read(documentRepositoryProvider).listInFolder();
    final trashed = await ref.read(trashRepositoryProvider).listTrashedDocuments();
    final files = await ref.read(fileStoreProvider).countFiles();
    if (!mounted) return;
    setState(() {
      _folderCount = folders.length;
      _rootDocCount = docs.length;
      _trashedDocCount = trashed.length;
      _fileCount = files;
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _refreshCounts();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createFolder() => _runAction(() async {
    final folder = await ref.read(folderRepositoryProvider).create(
      name: 'Test Folder ${_folderSeq++}',
    );
    _addLog('Created folder "${folder.name}" (${folder.id})');
  });

  Future<void> _createDoc() => _runAction(() async {
    final idGen = ref.read(idGeneratorProvider);
    final fileStore = ref.read(fileStoreProvider);
    final docId = idGen(), p1Id = idGen(), p2Id = idGen();
    final rel1 = await fileStore.writeEdited(documentId: docId, pageId: p1Id, bytes: const [0, 1, 2]);
    final rel2 = await fileStore.writeEdited(documentId: docId, pageId: p2Id, bytes: const [3, 4, 5]);
    final doc = await ref.read(documentRepositoryProvider).createWithPages(
      id: docId,
      name: 'Doc ${DateTime.now().millisecondsSinceEpoch % 1000}',
      pages: [NewPage(id: p1Id, originalPath: rel1), NewPage(id: p2Id, originalPath: rel2)],
    );
    _addLog('Created doc "${doc.name}" with 2 pages');
  });

  Future<void> _trashNewestDoc() => _runAction(() async {
    final docs = await ref.read(documentRepositoryProvider).listInFolder(sort: DocumentSort.modifiedDesc);
    if (docs.isEmpty) return _addLog('No root document to trash');
    await ref.read(documentRepositoryProvider).moveToTrash(docs.first.document.id);
    _addLog('Trashed doc "${docs.first.document.name}"');
  });

  Future<void> _restoreNewestDoc() => _runAction(() async {
    final trashed = await ref.read(trashRepositoryProvider).listTrashedDocuments();
    if (trashed.isEmpty) return _addLog('No trashed document to restore');
    final res = await ref.read(trashRepositoryProvider).restoreDocument(trashed.first.document.id);
    _addLog('Restored "${trashed.first.document.name}" (toRoot: ${res.restoredToRoot})');
  });

  Future<void> _emptyTrash() => _runAction(() async {
    await ref.read(trashServiceProvider).emptyTrash();
    _addLog('Emptied trash');
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'DB & Storage Check', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Actions'),
            DbCheckActionButtons(
              onCreateFolder: _createFolder,
              onCreateDocument: _createDoc,
              onTrashNewestDoc: _trashNewestDoc,
              onRestoreNewestDoc: _restoreNewestDoc,
              onEmptyTrash: _emptyTrash,
              busy: _busy,
            ),
            const SizedBox(height: AppSpacing.lg),
            DbCheckStatsCard(
              folderCount: _folderCount,
              rootDocCount: _rootDocCount,
              trashedDocCount: _trashedDocCount,
              fileCount: _fileCount,
              logs: _logs,
            ),
          ],
        ),
      ),
    );
  }
}
