import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/capture_mode.dart';
import '../domain/quad.dart';

enum IdCardScanType {
  singleSide,
  bothSides;

  String get label => switch (this) {
        IdCardScanType.singleSide => 'Single side',
        IdCardScanType.bothSides => 'Both sides',
      };
}

enum BookScanType {
  singlePage,
  twoPagesSplit;

  String get label => switch (this) {
        BookScanType.singlePage => 'Single page',
        BookScanType.twoPagesSplit => 'Two pages (auto split)',
      };
}

class IdCardFrontResult {
  const IdCardFrontResult({
    required this.capturePath,
    required this.previewPath,
    required this.renderedPath,
    required this.quad,
    required this.rotation,
    required this.filterId,
  });

  final String capturePath, previewPath, renderedPath;
  final Quad quad;
  final int rotation;
  final String filterId;
}

class IdCardFrontNotifier extends Notifier<IdCardFrontResult?> {
  @override
  IdCardFrontResult? build() => null;
  void setFront(IdCardFrontResult? result) => state = result;
  void clear() => state = null;
}

final idCardFrontProvider =
    NotifierProvider<IdCardFrontNotifier, IdCardFrontResult?>(IdCardFrontNotifier.new);

class CaptureModeNotifier extends Notifier<CaptureMode> {
  CaptureModeNotifier([this._initial = CaptureMode.document]);
  final CaptureMode _initial;

  @override
  CaptureMode build() => _initial;
  void setMode(CaptureMode mode) => state = mode;
}

final captureModeProvider =
    NotifierProvider<CaptureModeNotifier, CaptureMode>(CaptureModeNotifier.new);

class IdCardScanTypeNotifier extends Notifier<IdCardScanType> {
  @override
  IdCardScanType build() => IdCardScanType.singleSide;
  void setType(IdCardScanType type) => state = type;
}

final idCardScanTypeProvider =
    NotifierProvider<IdCardScanTypeNotifier, IdCardScanType>(IdCardScanTypeNotifier.new);

class BookScanTypeNotifier extends Notifier<BookScanType> {
  @override
  BookScanType build() => BookScanType.twoPagesSplit;
  void setType(BookScanType type) => state = type;
}

final bookScanTypeProvider =
    NotifierProvider<BookScanTypeNotifier, BookScanType>(BookScanTypeNotifier.new);
