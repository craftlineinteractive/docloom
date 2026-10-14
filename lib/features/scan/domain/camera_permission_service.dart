enum CameraPermissionState {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
}

abstract interface class CameraPermissionService {
  Future<CameraPermissionState> checkStatus();
  Future<CameraPermissionState> requestPermission();
  Future<bool> openSettings();
}
