import 'dart:collection';
import 'package:flutter/foundation.dart';

@immutable
class PreviewCacheKey {
  const PreviewCacheKey({
    required this.path,
    required this.quadHash,
    required this.rotation,
    required this.filterId,
    this.maxSide,
  });

  final String path;
  final int quadHash;
  final int rotation;
  final String filterId;
  final int? maxSide;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreviewCacheKey &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          quadHash == other.quadHash &&
          rotation == other.rotation &&
          filterId == other.filterId &&
          maxSide == other.maxSide;

  @override
  int get hashCode => Object.hash(path, quadHash, rotation, filterId, maxSide);

  @override
  String toString() =>
      'PreviewCacheKey(path: $path, quadHash: $quadHash, rot: $rotation, filter: $filterId, maxSide: $maxSide)';
}

class PreviewLruCache {
  PreviewLruCache({this.capacity = 20});

  final int capacity;
  final LinkedHashMap<PreviewCacheKey, Uint8List> _cache = LinkedHashMap();

  int get length => _cache.length;

  bool containsKey(PreviewCacheKey key) => _cache.containsKey(key);

  Uint8List? get(PreviewCacheKey key) {
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(PreviewCacheKey key, Uint8List value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= capacity && _cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  void clear() => _cache.clear();
}
