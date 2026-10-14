import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_toast.dart';
import 'router/app_router.dart';

class DocLoomApp extends StatelessWidget {
  const DocLoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'docLoom',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
