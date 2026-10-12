import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/widgets.dart';
import 'db_check_actions.dart';
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

  Future<void> _run(Future<void> Function(DbCheckActions) fn) async {
    setState(() => _busy = true);
    try {
      final actions = DbCheckActions(ref: ref, addLog: _addLog);
      await fn(actions);
      await _refreshCounts();
    } catch (e, st) {
      _addLog('Error: $e');
      debugPrint('DB_CHECK ACTION ERROR: $e\n$st');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

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
              onCreateFolder: () => _run((a) => a.createFolder(_folderSeq++)),
              onCreateDocument: () => _run((a) => a.createDoc()),
              onTrashNewestDoc: () => _run((a) => a.trashNewestDoc()),
              onRestoreNewestDoc: () => _run((a) => a.restoreNewestDoc()),
              onEmptyTrash: () => _run((a) => a.emptyTrash()),
              onSeedData: () => _run((a) => a.seedData()),
              onClearAllData: () => _run((a) => a.clearAll()),
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
