import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../domain/scan_gateway.dart';

class MlKitScanGateway implements ScanGateway {
  const MlKitScanGateway();

  static const String _defaultError =
      'Scanner not available. Check that Google Play services is installed and up to date.';

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    if (!Platform.isAndroid) {
      return const ScanFailure('Scanning is only available on Android');
    }

    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        isGalleryImport: true,
        pageLimit: pageLimit,
      ),
    );

    try {
      final result = await scanner.scanDocument();
      final images = result.images;
      if (images == null || images.isEmpty) {
        return const ScanCancelled();
      }
      return ScanSuccess(List<String>.unmodifiable(images));
    } on PlatformException catch (e) {
      if (_isCancelled(e)) {
        return const ScanCancelled();
      }
      return const ScanFailure(_defaultError);
    } catch (_) {
      return const ScanFailure(_defaultError);
    } finally {
      await scanner.close();
    }
  }

  bool _isCancelled(PlatformException e) {
    final msg = (e.message ?? '').toLowerCase();
    final details = (e.details?.toString() ?? '').toLowerCase();
    return msg.contains('cancel') ||
        details.contains('cancel') ||
        e.code.toLowerCase().contains('cancel');
  }
}
