import 'package:url_launcher/url_launcher.dart' as ul;
import '../domain/url_launcher_service.dart';

class PluginUrlLauncherService implements UrlLauncherService {
  const PluginUrlLauncherService();

  @override
  Future<bool> canLaunch(Uri uri) async {
    return ul.canLaunchUrl(uri);
  }

  @override
  Future<bool> launch(Uri uri) async {
    return ul.launchUrl(uri, mode: ul.LaunchMode.externalApplication);
  }
}
