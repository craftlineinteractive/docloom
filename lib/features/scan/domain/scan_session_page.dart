import 'capture_mode.dart';
import 'crop_type.dart';
import 'quad.dart';

class ScanSessionPage {
  const ScanSessionPage({
    required this.id,
    required this.capturePath,
    required this.previewPath,
    required this.quad,
    required this.rotation,
    required this.filterId,
    this.mode = CaptureMode.document,
    this.photoSizeId,
    CropType? cropType,
  }) : cropType = cropType ??
            (mode == CaptureMode.photo ? CropType.rect : CropType.quad);

  final String id;
  final String capturePath;
  final String previewPath;
  final Quad quad;
  final int rotation;
  final String filterId;
  final CaptureMode mode;
  final String? photoSizeId;
  final CropType cropType;

  ScanSessionPage copyWith({
    String? id,
    String? capturePath,
    String? previewPath,
    Quad? quad,
    int? rotation,
    String? filterId,
    CaptureMode? mode,
    String? photoSizeId,
    CropType? cropType,
  }) =>
      ScanSessionPage(
        id: id ?? this.id,
        capturePath: capturePath ?? this.capturePath,
        previewPath: previewPath ?? this.previewPath,
        quad: quad ?? this.quad,
        rotation: rotation ?? this.rotation,
        filterId: filterId ?? this.filterId,
        mode: mode ?? this.mode,
        photoSizeId: photoSizeId ?? this.photoSizeId,
        cropType: cropType ?? this.cropType,
      );
}
