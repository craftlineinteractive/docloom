import '../domain/qr_parsed_content.dart';

class QrScanState {
  const QrScanState({
    this.isProcessing = false,
    this.isSheetOpen = false,
    this.currentResult,
    this.lastScannedText,
    this.lastScannedTime,
  });

  final bool isProcessing;
  final bool isSheetOpen;
  final QrParsedContent? currentResult;
  final String? lastScannedText;
  final DateTime? lastScannedTime;

  QrScanState copyWith({
    bool? isProcessing,
    bool? isSheetOpen,
    QrParsedContent? currentResult,
    bool clearResult = false,
    String? lastScannedText,
    DateTime? lastScannedTime,
  }) {
    return QrScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      isSheetOpen: isSheetOpen ?? this.isSheetOpen,
      currentResult: clearResult ? null : (currentResult ?? this.currentResult),
      lastScannedText: lastScannedText ?? this.lastScannedText,
      lastScannedTime: lastScannedTime ?? this.lastScannedTime,
    );
  }
}
