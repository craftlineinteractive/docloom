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
    required CameraPermissionState perm,
    required bool hasErr,
    required VoidCallback onRequestPerm,
    required VoidCallback onOpenSettings,
    required VoidCallback onRetryInit,
    required VoidCallback onBack,
  }) {
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
    if (s.pages.isNotEmpty &&
        await ReviewDialogs.showDiscardScanDialog(context, s.pages.length) &&
        context.mounted) {
      ref.read(scanSessionProvider.notifier).discard();
      Navigator.of(context).pop(const ScanCancelled());
    } else if (s.pages.isEmpty && context.mounted) {
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
        context: state.context,
        session: session,
        isRetake: isRetake,
        onCheck: state._onFinishScan,
      ),
      onBack: state._onBack,
      onToggleFlash: state._onCycleFlash,
      onToggleGrid: state._toggleGrid,
      onFlipCamera: state._flip,
      onTapPreview: state._onTapPreview,
      onDismissFocus: state._dismissFocus,
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
