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
      await trashService.purgeExpired();
      await trashService.cleanOrphanDirectories();
      container.dispose();
    } catch (error, stackTrace) {
      debugPrint('Startup maintenance error: $error\n$stackTrace');
    }
  });
}

