abstract final class Routes {
  static const home = '/';
  static const search = '/search';
  static const folder = '/folder/:id';
  static String folderPath(String id) => '/folder/$id';
  static const gallery = '/dev/gallery';
  static const dbCheck = '/dev/db-check';
  static const scanCamera = '/scan/camera';
  static const devLabeler = '/dev/labeler';
}
