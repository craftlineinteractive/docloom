import 'crop_type.dart';

enum CaptureMode {
  photo,
  idCard,
  document,
  book,
  signature,
  qr,
  ocr;

  String get label => switch (this) {
        CaptureMode.photo => 'Photo',
        CaptureMode.idCard => 'ID Card',
        CaptureMode.document => 'Document',
        CaptureMode.book => 'Book',
        CaptureMode.signature => 'Signature',
        CaptureMode.qr => 'QR Scanner',
        CaptureMode.ocr => 'OCR Text',
      };

  bool get visible => this != CaptureMode.qr && this != CaptureMode.ocr;

  bool get hasPopup =>
      this == CaptureMode.photo ||
      this == CaptureMode.idCard ||
      this == CaptureMode.book;

  CropType get cropType =>
      this == CaptureMode.photo ? CropType.rect : CropType.quad;

  bool get autoDetect => this != CaptureMode.photo;

  String? get defaultFilterId => switch (this) {
        CaptureMode.photo => 'original',
        CaptureMode.idCard => 'auto_enhance',
        CaptureMode.book => 'auto_enhance',
        CaptureMode.signature => 'black_white',
        CaptureMode.document => null,
        CaptureMode.qr => 'original',
        CaptureMode.ocr => 'original',
      };
}
