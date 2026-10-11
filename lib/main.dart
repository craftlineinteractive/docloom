import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';
import 'core/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await bootstrap();
  runApp(ProviderScope(overrides: overrides, child: const DocLoomApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final container = ProviderContainer(overrides: overrides);
      final trashService = container.read(trashServiceProvider);
      final purged = await trashService.purgeExpired();
      if (kDebugMode) {
        debugPrint('TrashService: Purged $purged expired documents on startup');
      }
    } catch (error, stackTrace) {
      debugPrint('Startup trash purge error: $error\n$stackTrace');
    }
  });
}
