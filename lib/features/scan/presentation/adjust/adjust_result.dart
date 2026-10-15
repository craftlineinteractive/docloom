import '../../domain/quad.dart';

class AdjustResult {
  const AdjustResult({
    required this.renderedPath,
    required this.quad,
    required this.rotation,
    this.filterId = 'vivid_light',
  });

  final String renderedPath;
  final Quad quad;
  final int rotation;
  final String filterId;
}
