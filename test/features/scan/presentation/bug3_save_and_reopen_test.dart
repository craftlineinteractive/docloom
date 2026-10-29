import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/features/documents/domain/document.dart';
import 'package:docloom/features/scan/application/scan_providers.dart';
import 'package:docloom/features/scan/application/scan_save_service.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_gateway.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';
import 'package:docloom/features/scan/domain/scanned_page.dart';

class _FakeGateway implements ScanGateway {
  _FakeGateway(this.outcomes);
  final List<ScanOutcome> outcomes;
  int index = 0;

  @override
  Future<ScanOutcome> scan({required int pageLimit}) async {
    if (index < outcomes.length) {
      return outcomes[index++];
    }
    return const ScanCancelled();
  }
}

class _TrackingSaveService implements ScanSaveService {
  int saveCalls = 0;
  bool shouldThrow = false;

  @override
  Future<Document> save({required List<ScannedPage> pages, String? folderId, String? name}) async {
    if (shouldThrow) throw Exception('Real disk failure');
    saveCalls++;
    final now = DateTime.now();
    return Document(id: 'doc-$saveCalls', name: name ?? 'doc', createdAt: now, updatedAt: now);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Bug 3: scan and save, reopen camera, go back: no save call, no toast, session empty', () async {
    final gateway = _FakeGateway([
      const ScanSuccess([ScannedPage(originalPath: '/dummy/page1.jpg')]),
      const ScanCancelled(),
    ]);
    final saveService = _TrackingSaveService();

    final container = ProviderContainer(overrides: [
      scanGatewayProvider.overrideWithValue(gateway),
      scanSaveServiceProvider.overrideWithValue(saveService),
    ]);
    addTearDown(container.dispose);

    final toasts = <String>[];

    // 1. Pre-populate session to simulate capture during first scan
    container.read(scanSessionProvider.notifier).addPage(
      ScanSessionPage(
        id: '1', capturePath: '/dummy/page1.jpg', previewPath: '/dummy/prev1.jpg',
        quad: Quad.unit(), rotation: 0, filterId: 'original',
      ),
    );
    expect(container.read(scanSessionProvider).pages.length, equals(1));

    // 2. Perform first scan and save
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);
    expect(saveService.saveCalls, equals(1));
    expect(toasts, equals(['Saved 1 pages']));

    // Verify session was reset and directory deleted/empty after save
    expect(container.read(scanSessionProvider).pages, isEmpty);

    // 3. Reopen camera
    // Reopening starts with an empty session
    expect(container.read(scanSessionProvider).pages, isEmpty);

    // 4. Go back with zero pages (gateway returns ScanCancelled)
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);

    // Verify: no second save call, no failure toast, session empty
    expect(saveService.saveCalls, equals(1));
    expect(toasts.contains('Failed to save document. Please try again.'), isFalse);
    expect(container.read(scanSessionProvider).pages, isEmpty);
  });

  test('Bug 3: failure toast appears only for real failure', () async {
    final gateway = _FakeGateway([
      const ScanSuccess([ScannedPage(originalPath: '/dummy/page1.jpg')]),
    ]);
    final saveService = _TrackingSaveService()..shouldThrow = true;

    final container = ProviderContainer(overrides: [
      scanGatewayProvider.overrideWithValue(gateway),
      scanSaveServiceProvider.overrideWithValue(saveService),
    ]);
    addTearDown(container.dispose);

    final toasts = <String>[];
    await container.read(scanControllerProvider.notifier).startScan(onToast: toasts.add);
    expect(saveService.saveCalls, equals(0));
    expect(toasts, equals(['Failed to save document. Please try again.']));
  });
}
