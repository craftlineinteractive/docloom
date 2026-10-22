abstract interface class UrlLauncherService {
  Future<bool> canLaunch(Uri uri);
  Future<bool> launch(Uri uri);
}
