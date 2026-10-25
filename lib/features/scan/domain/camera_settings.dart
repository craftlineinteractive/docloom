import 'package:flutter/foundation.dart';

enum ScanQuality {
  standard(label: 'Standard', caption: 'Fastest', maxOutputLongSide: 2000),
  high(label: 'High', caption: 'Recommended', maxOutputLongSide: 3000),
  max(label: 'Max', caption: 'Largest files', maxOutputLongSide: 4000);

  const ScanQuality({
    required this.label,
    required this.caption,
    required this.maxOutputLongSide,
  });
  final String label;
  final String caption;
  final int maxOutputLongSide;
}

@immutable
class CameraSettings {
  const CameraSettings({
    this.autoCrop = true,
    this.filterId = 'vivid_light',
    this.spiritLevel = true,
    this.scanQuality = ScanQuality.high,
    this.autoCaptureTimeSeconds = 2,
    this.captureSound = true,
    this.focusSound = true,
    this.imageRotation = 'Auto',
  });

  final bool autoCrop;
  final String filterId;
  final bool spiritLevel;
  final ScanQuality scanQuality;
  final int autoCaptureTimeSeconds;
  final bool captureSound;
  final bool focusSound;
  final String imageRotation;

  CameraSettings copyWith({
    bool? autoCrop,
    String? filterId,
    bool? spiritLevel,
    ScanQuality? scanQuality,
    int? autoCaptureTimeSeconds,
    bool? captureSound,
    bool? focusSound,
    String? imageRotation,
  }) {
    return CameraSettings(
      autoCrop: autoCrop ?? this.autoCrop,
      filterId: filterId ?? this.filterId,
      spiritLevel: spiritLevel ?? this.spiritLevel,
      scanQuality: scanQuality ?? this.scanQuality,
      autoCaptureTimeSeconds: autoCaptureTimeSeconds ?? this.autoCaptureTimeSeconds,
      captureSound: captureSound ?? this.captureSound,
      focusSound: focusSound ?? this.focusSound,
      imageRotation: imageRotation ?? this.imageRotation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraSettings &&
          runtimeType == other.runtimeType &&
          autoCrop == other.autoCrop &&
          filterId == other.filterId &&
          spiritLevel == other.spiritLevel &&
          scanQuality == other.scanQuality &&
          autoCaptureTimeSeconds == other.autoCaptureTimeSeconds &&
          captureSound == other.captureSound &&
          focusSound == other.focusSound &&
          imageRotation == other.imageRotation;

  @override
  int get hashCode => Object.hash(
        autoCrop,
        filterId,
        spiritLevel,
        scanQuality,
        autoCaptureTimeSeconds,
        captureSound,
        focusSound,
        imageRotation,
      );
}
