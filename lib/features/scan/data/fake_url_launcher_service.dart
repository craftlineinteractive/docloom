import '../domain/url_launcher_service.dart';

class FakeUrlLauncherService implements UrlLauncherService {
  final List<Uri> launchedUris = [];
  bool canLaunchResult = true;
  bool launchResult = true;

  @override
  Future<bool> canLaunch(Uri uri) async => canLaunchResult;

  @override
  Future<bool> launch(Uri uri) async {
    launchedUris.add(uri);
    return launchResult;
  }
}
