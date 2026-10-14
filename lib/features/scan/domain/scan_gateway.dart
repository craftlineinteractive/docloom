sealed class ScanOutcome {
  const ScanOutcome();
}

final class ScanSuccess extends ScanOutcome {
  const ScanSuccess(this.imagePaths);
  final List<String> imagePaths;
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
