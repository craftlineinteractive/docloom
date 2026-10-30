part of 'camera_screen.dart';

abstract final class _CameraScreenHelper {
  static const overlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.cameraBlack,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static Widget? buildStateView({
    required bool isCheckingPerm,
    required CameraPermissionState perm,
    required bool hasErr,
    required VoidCallback onRequestPerm,
    required VoidCallback onOpenSettings,
    required VoidCallback onRetryInit,
    required VoidCallback onBack,
  }) {
    if (isCheckingPerm) {
      return const ColoredBox(color: AppColors.cameraBlack);
    }
    if (perm != CameraPermissionState.granted) {
      return CameraPermissionView(
        state: perm,
        onRequest: onRequestPerm,
        onBack: onBack,
        onOpenSettings: onOpenSettings,
      );
    }
    if (hasErr) return CameraErrorView(onRetry: onRetryInit, onBack: onBack);
    return null;
  }

  static Future<void> handleBack(
    BuildContext context,
    WidgetRef ref,
    int? retakePageIndex,
  ) async {
    if (ref.read(cameraSettingsOpenProvider)) {
      ref.read(cameraSettingsOpenProvider.notifier).setOpen(false);
    } else if (retakePageIndex != null) {
      Navigator.of(context).pop(null);
    } else {
      await exitScan(context, ref);
    }
  }

  static Future<void> exitScan(BuildContext context, WidgetRef ref) async {
    final s = ref.read(scanSessionProvider);
    if (s.pages.isNotEmpty) {
      final act = await ReviewDialogs.showBackScanDialog(context, s.pages.length);
      if (act == null || !context.mounted) return;
      if (act == BackScanAction.saveAndExit) {
        final success = await ScanFinishCoordinator.finish(context: context, ref: ref);
        if (success != null && context.mounted) Navigator.of(context).pop(success);
      } else {
        ref.read(scanSessionProvider.notifier).discard();
        Navigator.of(context).pop(const ScanCancelled());
      }
    } else if (context.mounted) {
      Navigator.of(context).pop(const ScanCancelled());
    }
  }

  static CameraFlash nextFlash(CameraFlash current) => switch (current) {
    CameraFlash.off => CameraFlash.on,
    CameraFlash.on => CameraFlash.auto,
    CameraFlash.auto => CameraFlash.off,
  };

  static Widget buildBody(_CameraScreenState state) {
    CameraQrCoordinator.setup(
      context: state.context,
      ref: state.ref,
      camera: state.ref.read(cameraServiceProvider),
    );
    final session = state.ref.watch(scanSessionProvider);
    final isRetake = state.widget.retakePageIndex != null;
    final isSettingsOpen = state.ref.watch(cameraSettingsOpenProvider);

    return CameraBody(
      camera: state.ref.read(cameraServiceProvider),
      scannerController: state.ref.read(betterScannerControllerProvider),
      isGridVisible: state._grid,
      focusPos: state._focusPos,
      isInitializing: state._isInit,
      isCapturing: state._isCap,
      isSettingsOpen: isSettingsOpen,
      onSettingsTap: () =>
          state.ref.read(cameraSettingsOpenProvider.notifier).toggle(),
      onCloseSettings: () =>
          state.ref.read(cameraSettingsOpenProvider.notifier).setOpen(false),
      onHomeScreenTap: () {
        state.ref.read(cameraSettingsOpenProvider.notifier).setOpen(false);
        exitScan(state.context, state.ref);
      },
      leftSlot: CameraSlotsHelper.buildLeft(
        context: state.context,
        session: session,
        isRetake: isRetake,
        onOutcome: (o) => (o is ScanSuccess && state.mounted)
            ? Navigator.of(state.context).pop(o)
            : null,
      ),
      rightSlot: CameraSlotsHelper.buildRight(
        context: state.context, session: session, isRetake: isRetake,
        onCheck: () async {
          final s = await ScanFinishCoordinator.finish(context: state.context, ref: state.ref);
          if (s != null && state.mounted) Navigator.of(state.context).pop(s);
        },
      ),
      onBack: state._onBack,
      onToggleFlash: () {
        state.ref.read(betterScannerControllerProvider)?.cycleFlashMode();
        state._camera.setFlash(nextFlash(state._camera.currentFlash));
        state._update();
      },
      onToggleGrid: () => state._update(() => state._grid = !state._grid),
      onFlipCamera: () {
        state.ref.read(betterScannerControllerProvider)?.switchCamera();
        state._lens = state._lens == CameraLens.back ? CameraLens.front : CameraLens.back;
        state._initCamera();
      },
      onTapPreview: (d, s) {
        state._update(() => state._focusPos = d.localPosition);
        state._camera.setFocusPoint(Offset((d.localPosition.dx / s.width).clamp(0.0, 1.0), (d.localPosition.dy / s.height).clamp(0.0, 1.0)));
      },
      onDismissFocus: () => state._update(() => state._focusPos = null),
      onCapture: state._onCapture,
    );
  }

  static Widget buildRoot({
    required _CameraScreenState state,
    required Widget? stateView,
  }) {
    if (stateView != null) return stateView;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => didPop ? null : state._onBack(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: buildBody(state),
      ),
    );
  }
}
