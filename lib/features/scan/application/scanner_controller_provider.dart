import 'package:flutter_better_scanner/flutter_better_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plugin_camera_service.dart';
import '../domain/camera_settings.dart';
import 'camera_settings_provider.dart';
import 'scan_providers.dart';

ScanEnhancement filterIdToEnhancement(String filterId) => switch (filterId) {
      'original' => ScanEnhancement.original,
      'auto' || 'auto_enhance' => ScanEnhancement.auto,
      'magic_color' || 'vivid_light' => ScanEnhancement.magicColor,
      'black_white' || 'clean_black' => ScanEnhancement.blackWhite,
      'grayscale' => ScanEnhancement.grayscale,
      'shadow_removal' || 'shadowRemoval' => ScanEnhancement.shadowRemoval,
      'color_document' || 'colorDocument' => ScanEnhancement.colorDocument,
      'whiteboard' => ScanEnhancement.whiteboard,
      _ => ScanEnhancement.magicColor,
    };

String enhancementToFilterId(ScanEnhancement e) => switch (e) {
      ScanEnhancement.original => 'original',
      ScanEnhancement.auto => 'auto_enhance',
      ScanEnhancement.magicColor => 'vivid_light',
      ScanEnhancement.blackWhite => 'black_white',
      ScanEnhancement.grayscale => 'grayscale',
      ScanEnhancement.shadowRemoval => 'shadow_removal',
      ScanEnhancement.colorDocument => 'color_document',
      ScanEnhancement.whiteboard => 'whiteboard',
    };

int scanQualityToWorkingRes(ScanQuality q) => switch (q) {
      ScanQuality.standard => 2000,
      ScanQuality.high => 2600,
      ScanQuality.max => 3200,
    };

int scanQualityToExportQuality(ScanQuality q) => switch (q) {
      ScanQuality.standard => 85,
      ScanQuality.high => 92,
      ScanQuality.max => 98,
    };

ScannerConfig buildScannerConfig(CameraSettings s, {bool grid = false}) {
  return ScannerConfig(
    autoCrop: s.autoCrop,
    enhancement: filterIdToEnhancement(s.filterId),
    exportQuality: scanQualityToExportQuality(s.scanQuality),
    workingResolution: scanQualityToWorkingRes(s.scanQuality),
    showGrid: grid,
    autoCaptureTuning: AutoCaptureTuning(
      holdDuration: Duration(seconds: s.autoCaptureTimeSeconds),
    ),
  );
}

final betterScannerControllerProvider = Provider.autoDispose<ScannerController?>((ref) {
  final cam = ref.watch(cameraServiceProvider);
  if (cam is! PluginCameraService) return null;

  final settings = ref.read(cameraSettingsProvider);
  final controller = ScannerController(
    config: buildScannerConfig(settings),
  );

  ref.listen<CameraSettings>(cameraSettingsProvider, (_, next) {
    controller.updateConfig(
      buildScannerConfig(next, grid: controller.gridVisible),
    );
  });

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

