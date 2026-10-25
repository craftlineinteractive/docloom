import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/dev/component_gallery_screen.dart';
import '../../features/dev/db_check_screen.dart';
import '../../features/dev/dev_labeler_screen.dart';
import '../../features/dev/edge_debug_screen.dart';
import '../../features/dev/scanner_spike_screen.dart';
import '../../features/folders/presentation/folder_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/scan/presentation/camera_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: Routes.folder,
      builder: (context, state) => FolderScreen(
        folderId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: Routes.scanCamera,
      builder: (context, state) => const CameraScreen(),
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
    if (kDebugMode)
      GoRoute(
        path: Routes.devLabeler,
        builder: (context, state) => const DevLabelerScreen(),
      ),
    if (kDebugMode)
      GoRoute(
        path: Routes.edgeDebug,
        builder: (context, state) => const EdgeDebugScreen(),
      ),
    if (kDebugMode)
      GoRoute(
        path: Routes.scannerSpike,
        builder: (context, state) => const ScannerSpikeScreen(),
      ),
  ],
);
