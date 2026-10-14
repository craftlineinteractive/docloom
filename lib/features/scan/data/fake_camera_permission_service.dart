import '../domain/camera_permission_service.dart';

class FakeCameraPermissionService implements CameraPermissionService {
  FakeCameraPermissionService({
    this.status = CameraPermissionState.granted,
    this.requestResult,
  });

  CameraPermissionState status;
  CameraPermissionState? requestResult;
  int checkStatusCount = 0;
  int requestPermissionCount = 0;
  int openSettingsCount = 0;

  @override
  Future<CameraPermissionState> checkStatus() async {
    checkStatusCount++;
    return status;
  }

  @override
  Future<CameraPermissionState> requestPermission() async {
    requestPermissionCount++;
    status = requestResult ?? status;
    return status;
  }

  @override
  Future<bool> openSettings() async {
    openSettingsCount++;
    return true;
  }
}
