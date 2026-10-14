import 'package:permission_handler/permission_handler.dart';
import '../domain/camera_permission_service.dart';

class PluginCameraPermissionService implements CameraPermissionService {
  const PluginCameraPermissionService();

  @override
  Future<CameraPermissionState> checkStatus() async {
    final status = await Permission.camera.status;
    return _mapStatus(status);
  }

  @override
  Future<CameraPermissionState> requestPermission() async {
    final status = await Permission.camera.request();
    return _mapStatus(status);
  }

  @override
  Future<bool> openSettings() {
    return openAppSettings();
  }

  CameraPermissionState _mapStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      return CameraPermissionState.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      return CameraPermissionState.permanentlyDenied;
    }
    if (status.isDenied) {
      return CameraPermissionState.denied;
    }
    return CameraPermissionState.notDetermined;
  }
}
