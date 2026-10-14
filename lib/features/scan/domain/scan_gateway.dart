import 'scanned_page.dart';

sealed class ScanOutcome {
  const ScanOutcome();
}

final class ScanSuccess extends ScanOutcome {
  const ScanSuccess(this.pages, {this.suggestedName});
  final List<ScannedPage> pages;
  final String? suggestedName;
}

final class ScanCancelled extends ScanOutcome {
  const ScanCancelled();
}

final class ScanFailure extends ScanOutcome {
  const ScanFailure(this.message);
  final String message;
}

abstract interface class ScanGateway {
  Future<ScanOutcome> scan({required int pageLimit});
}
