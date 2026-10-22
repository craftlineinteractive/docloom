import 'photo_size.dart';

abstract final class PhotoSizePresets {
  static const List<PhotoSize> defaults = [
    PhotoSize(
      id: 'preset_2x2_in',
      width: 2,
      height: 2,
      unit: PhotoUnit.inches,
      dpi: 600,
      title: '2 × 2 INCHES',
      subtitle: 'DPI 600',
    ),
    PhotoSize(
      id: 'preset_35x45_mm',
      width: 35,
      height: 45,
      unit: PhotoUnit.mm,
      dpi: 300,
      title: '35 × 45 MM',
      subtitle: 'DPI 300',
    ),
    PhotoSize(
      id: 'preset_2x2_5_cm',
      width: 2,
      height: 2.5,
      unit: PhotoUnit.cm,
      dpi: 450,
      title: '2 × 2.5 CM',
      subtitle: 'DPI 450',
    ),
    PhotoSize(
      id: 'preset_600x600_px',
      width: 600,
      height: 600,
      unit: PhotoUnit.px,
      dpi: 1,
      title: '600 × 600 PX',
      subtitle: 'PIXEL',
    ),
    PhotoSize(
      id: 'preset_51x51_mm',
      width: 51,
      height: 51,
      unit: PhotoUnit.mm,
      dpi: 300,
      title: '51 × 51 MM',
      subtitle: 'DPI 300',
    ),
    PhotoSize(
      id: 'preset_25x35_mm',
      width: 25,
      height: 35,
      unit: PhotoUnit.mm,
      dpi: 450,
      title: '25 × 35 MM',
      subtitle: 'DPI 450',
    ),
  ];
}
