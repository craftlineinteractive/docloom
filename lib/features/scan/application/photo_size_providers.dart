import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/photo_size_store.dart';
import '../domain/photo_size.dart';
import '../domain/photo_size_presets.dart';

class PhotoSizeState {
  const PhotoSizeState({
    required this.sizes,
    required this.selectedId,
  });

  final List<PhotoSize> sizes;
  final String selectedId;

  PhotoSize get selectedSize =>
      sizes.firstWhere((s) => s.id == selectedId, orElse: () => sizes.first);

  PhotoSize? findSize(String id) {
    for (final s in sizes) {
      if (s.id == id) return s;
    }
    return null;
  }

  PhotoSizeState copyWith({
    List<PhotoSize>? sizes,
    String? selectedId,
  }) =>
      PhotoSizeState(
        sizes: sizes ?? this.sizes,
        selectedId: selectedId ?? this.selectedId,
      );
}

final photoSizeStoreProvider = Provider<PhotoSizeStore>((ref) => PhotoSizeStore());

class PhotoSizeNotifier extends Notifier<PhotoSizeState> {
  @override
  PhotoSizeState build() {
    final store = ref.watch(photoSizeStoreProvider);
    Future.microtask(() async {
      final res = await store.load();
      state = PhotoSizeState(sizes: res.sizes, selectedId: res.selectedId);
    });
    return const PhotoSizeState(
      sizes: PhotoSizePresets.defaults,
      selectedId: 'preset_2x2_in',
    );
  }

  PhotoSize get selectedSize => state.selectedSize;
  PhotoSize? findSize(String id) => state.findSize(id);

  Future<void> select(String id) async {
    state = state.copyWith(selectedId: id);
    await ref.read(photoSizeStoreProvider).save(sizes: state.sizes, selectedId: state.selectedId);
  }

  Future<void> add(PhotoSize size) async {
    final updated = [...state.sizes, size];
    state = state.copyWith(sizes: updated, selectedId: size.id);
    await ref.read(photoSizeStoreProvider).save(sizes: state.sizes, selectedId: state.selectedId);
  }

  Future<void> remove(String id) async {
    var updated = state.sizes.where((s) => s.id != id).toList();
    if (updated.isEmpty) updated = PhotoSizePresets.defaults;
    final selectedId =
        updated.any((s) => s.id == state.selectedId) ? state.selectedId : updated.first.id;
    state = state.copyWith(sizes: updated, selectedId: selectedId);
    await ref.read(photoSizeStoreProvider).save(sizes: state.sizes, selectedId: state.selectedId);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= state.sizes.length) return;
    if (newIndex < 0 || newIndex > state.sizes.length) return;
    final updated = List<PhotoSize>.from(state.sizes);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = state.copyWith(sizes: updated);
    await ref.read(photoSizeStoreProvider).save(sizes: state.sizes, selectedId: state.selectedId);
  }
}

final photoSizesProvider =
    NotifierProvider<PhotoSizeNotifier, PhotoSizeState>(PhotoSizeNotifier.new);
