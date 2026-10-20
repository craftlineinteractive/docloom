import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/camera_settings.dart';
import 'scan_providers.dart';

class CameraSettingsNotifier extends Notifier<CameraSettings> {
  @override
  CameraSettings build() {
    final autoCrop = ref.read(autoCropEnabledProvider);
    return CameraSettings(autoCrop: autoCrop);
  }

  void toggleAutoCrop() {
    state = state.copyWith(autoCrop: !state.autoCrop);
    ref.read(autoCropEnabledProvider.notifier).setEnabled(state.autoCrop);
  }

  void toggleSpiritLevel() {
    state = state.copyWith(spiritLevel: !state.spiritLevel);
  }

  void setColorFilter(String filterId) {
    state = state.copyWith(filterId: filterId);
  }

  void setScanQuality(ScanQuality quality) {
    state = state.copyWith(scanQuality: quality);
  }

  void setAutoCaptureTime(int seconds) {
    state = state.copyWith(autoCaptureTimeSeconds: seconds);
  }
}

final cameraSettingsProvider =
    NotifierProvider<CameraSettingsNotifier, CameraSettings>(CameraSettingsNotifier.new);

class CameraSettingsOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setOpen(bool value) => state = value;
  void toggle() => state = !state;
}

final cameraSettingsOpenProvider =
    NotifierProvider<CameraSettingsOpenNotifier, bool>(CameraSettingsOpenNotifier.new);

final autoCaptureSuspendedProvider = Provider<bool>((ref) {
  return ref.watch(cameraSettingsOpenProvider);
});
