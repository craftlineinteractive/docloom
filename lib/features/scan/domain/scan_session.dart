import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_config.dart';
import 'quad.dart';
import 'scan_session_dir_helper.dart';
import 'scan_session_page.dart';

export 'scan_session_dir_helper.dart';
export 'scan_session_page.dart';

class ScanSession {
  const ScanSession({
    required this.id,
    this.name,
    this.pages = const [],
  });

  final String id;
  final String? name;
  final List<ScanSessionPage> pages;

  ScanSession copyWith({
    String? id,
    String? name,
    List<ScanSessionPage>? pages,
  }) =>
      ScanSession(
        id: id ?? this.id,
        name: name ?? this.name,
        pages: pages ?? this.pages,
      );
}

class ScanSessionNotifier extends Notifier<ScanSession> {
  ScanSessionNotifier([String? initialId]) : _initialId = initialId;
  final String? _initialId;

  @override
  ScanSession build() => ScanSession(
        id: _initialId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      );

  void init(String sessionId) {
    state = ScanSession(id: sessionId);
  }

  bool addPage(ScanSessionPage page) {
    if (state.pages.length >= AppConfig.scanPageLimit) {
      return false;
    }
    state = state.copyWith(pages: [...state.pages, page]);
    return true;
  }

  void replacePage(int index, ScanSessionPage newPage) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages);
    updated[index] = newPage;
    state = state.copyWith(pages: updated);
  }

  void removePage(int index) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages)..removeAt(index);
    state = state.copyWith(pages: updated);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.pages.length) return;
    if (newIndex < 0 || newIndex >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages);
    final page = updated.removeAt(oldIndex);
    updated.insert(newIndex, page);
    state = state.copyWith(pages: updated);
  }

  void updateCrop(int index, Quad quad) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages);
    updated[index] = updated[index].copyWith(quad: quad);
    state = state.copyWith(pages: updated);
  }

  void setRotation(int index, int rotation) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages);
    updated[index] = updated[index].copyWith(rotation: rotation);
    state = state.copyWith(pages: updated);
  }

  void setFilter(int index, String filterId) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ScanSessionPage>.from(state.pages);
    updated[index] = updated[index].copyWith(filterId: filterId);
    state = state.copyWith(pages: updated);
  }

  void setFilterForAll(String filterId) {
    final updated =
        state.pages.map((p) => p.copyWith(filterId: filterId)).toList();
    state = state.copyWith(pages: updated);
  }

  void setName(String? name) {
    state = state.copyWith(name: name);
  }

  void discard() {
    ScanSessionDirHelper.deleteSessionDir(state.id);
    state = ScanSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}

final scanSessionProvider =
    NotifierProvider<ScanSessionNotifier, ScanSession>(ScanSessionNotifier.new);
