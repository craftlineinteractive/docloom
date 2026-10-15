import 'quad.dart';

class ScanSessionPage {
  const ScanSessionPage({
    required this.id,
    required this.capturePath,
    required this.previewPath,
    required this.quad,
    required this.rotation,
    required this.filterId,
  });

  final String id;
  final String capturePath;
  final String previewPath;
  final Quad quad;
  final int rotation;
  final String filterId;

  ScanSessionPage copyWith({
    String? id,
    String? capturePath,
    String? previewPath,
    Quad? quad,
    int? rotation,
    String? filterId,
  }) =>
      ScanSessionPage(
        id: id ?? this.id,
        capturePath: capturePath ?? this.capturePath,
        previewPath: previewPath ?? this.previewPath,
        quad: quad ?? this.quad,
        rotation: rotation ?? this.rotation,
        filterId: filterId ?? this.filterId,
      );
}
