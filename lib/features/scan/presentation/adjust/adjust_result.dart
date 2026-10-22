import '../../domain/quad.dart';

class AdjustResult {
  const AdjustResult({
    required this.renderedPath,
    required this.quad,
    required this.rotation,
    this.filterId = 'vivid_light',
    this.secondaryRenderedPath,
    this.secondaryQuad,
  });

  final String renderedPath;
  final Quad quad;
  final int rotation;
  final String filterId;
  final String? secondaryRenderedPath;
  final Quad? secondaryQuad;
}
