import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/home_providers.dart';
import '../../../../core/widgets/widgets.dart';
import '../../application/library_actions.dart';

Future<void> batchDeleteWithToast(
  BuildContext context,
  WidgetRef ref,
  List<String> ids,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(libraryActionsProvider);
  ref.read(selectModeProvider.notifier).exit();
  ref.read(selectionProvider.notifier).clear();
  await actions.deleteDocuments(ids);
  ref.refreshLibrary();
  showAppToastWithMessenger(
    messenger,
    '${ids.length} documents moved to Trash',
    actionLabel: 'Undo',
    duration: const Duration(seconds: 5),
    onAction: () async {
      await actions.undoDeleteDocuments(ids);
      ref.refreshLibrary();
    },
  );
}
