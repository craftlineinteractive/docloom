import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/dev/component_gallery_screen.dart';
import '../../features/dev/db_check_screen.dart';
import '../../features/folders/presentation/folder_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.folder,
      builder: (context, state) => FolderScreen(
        folderId: state.pathParameters['id']!,
      ),
    ),
    if (kDebugMode)
      GoRoute(
        path: Routes.gallery,
        builder: (context, state) => const ComponentGalleryScreen(),
      ),
    if (kDebugMode)
      GoRoute(
        path: Routes.dbCheck,
        builder: (context, state) => const DbCheckScreen(),
      ),
  ],
);
