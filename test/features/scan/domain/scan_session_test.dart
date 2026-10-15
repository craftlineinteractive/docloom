import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docloom/core/constants/app_config.dart';
import 'package:docloom/features/scan/domain/quad.dart';
import 'package:docloom/features/scan/domain/scan_session.dart';

void main() {
  ScanSessionPage makePage(String id, {String filter = 'vivid_light', int rot = 0}) {
    return ScanSessionPage(
      id: id,
      capturePath: '/tmp/cap_$id.jpg',
      previewPath: '/tmp/prev_$id.jpg',
      quad: Quad.unit(),
      rotation: rot,
      filterId: filter,
    );
  }

  test('ScanSessionNotifier adds pages up to AppConfig.scanPageLimit and rejects beyond', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    for (var i = 0; i < AppConfig.scanPageLimit; i++) {
      final added = notifier.addPage(makePage('page_$i'));
      expect(added, isTrue);
    }

    expect(container.read(scanSessionProvider).pages.length, equals(AppConfig.scanPageLimit));

    final beyondLimit = notifier.addPage(makePage('page_extra'));
    expect(beyondLimit, isFalse);
    expect(container.read(scanSessionProvider).pages.length, equals(AppConfig.scanPageLimit));
  });

  test('replacePage updates the page at specific index', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1'));
    notifier.addPage(makePage('2'));

    final newPage = makePage('2_new', filter: 'black_white');
    notifier.replacePage(1, newPage);

    final pages = container.read(scanSessionProvider).pages;
    expect(pages[1].id, equals('2_new'));
    expect(pages[1].filterId, equals('black_white'));
  });

  test('removePage removes the page at specific index', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1'));
    notifier.addPage(makePage('2'));
    notifier.addPage(makePage('3'));

    notifier.removePage(1);

    final pages = container.read(scanSessionProvider).pages;
    expect(pages.length, equals(2));
    expect(pages.map((p) => p.id), equals(['1', '3']));
  });

  test('reorder moves page from oldIndex to newIndex correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1'));
    notifier.addPage(makePage('2'));
    notifier.addPage(makePage('3'));
    notifier.addPage(makePage('4'));

    notifier.reorder(0, 2);
    var pages = container.read(scanSessionProvider).pages;
    expect(pages.map((p) => p.id), equals(['2', '3', '1', '4']));

    notifier.reorder(2, 0);
    pages = container.read(scanSessionProvider).pages;
    expect(pages.map((p) => p.id), equals(['1', '2', '3', '4']));
  });

  test('setFilter and setFilterForAll update filters', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1', filter: 'original'));
    notifier.addPage(makePage('2', filter: 'original'));

    notifier.setFilter(0, 'grayscale');
    expect(container.read(scanSessionProvider).pages[0].filterId, equals('grayscale'));
    expect(container.read(scanSessionProvider).pages[1].filterId, equals('original'));

    notifier.setFilterForAll('black_white');
    expect(container.read(scanSessionProvider).pages[0].filterId, equals('black_white'));
    expect(container.read(scanSessionProvider).pages[1].filterId, equals('black_white'));
  });

  test('updateCrop, setRotation and setName modify session state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1'));
    notifier.setName('Invoice 2026');
    expect(container.read(scanSessionProvider).name, equals('Invoice 2026'));

    notifier.setRotation(0, 90);
    expect(container.read(scanSessionProvider).pages[0].rotation, equals(90));

    final newQuad = Quad.defaultInset(0.2);
    notifier.updateCrop(0, newQuad);
    expect(container.read(scanSessionProvider).pages[0].quad, equals(newQuad));
  });

  test('discard clears pages and resets session id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(scanSessionProvider.notifier);

    notifier.addPage(makePage('1'));
    final oldId = container.read(scanSessionProvider).id;

    notifier.discard();
    final newSession = container.read(scanSessionProvider);
    expect(newSession.pages, isEmpty);
    expect(newSession.id, isNot(equals(oldId)));
  });
}
