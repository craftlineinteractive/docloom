enum CropType {
  quad,
  rect;

  static CropType fromString(String? type) {
    if (type == 'rect') return CropType.rect;
    return CropType.quad;
  }
}
