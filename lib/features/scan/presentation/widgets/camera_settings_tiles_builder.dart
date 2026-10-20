import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../application/camera_settings_provider.dart';
import '../../domain/camera_setting_tile.dart';
import '../../domain/camera_settings.dart';
import '../../domain/scan_filter.dart';
import 'camera_picker_bottom_sheet.dart';
import 'camera_picker_option.dart';

abstract final class CameraSettingsTilesBuilder {
  static List<CameraSettingTile> build({
    required BuildContext context,
    required WidgetRef ref,
    required CameraSettings settings,
    required VoidCallback onHomeScreenTap,
  }) {
    final notifier = ref.read(cameraSettingsProvider.notifier);

    return [
      CameraSettingTile(
        id: 'auto_crop',
        icon: LucideIcons.crop,
        label: 'Auto Crop',
        valueText: settings.autoCrop ? 'On' : 'Off',
        isOn: settings.autoCrop,
        visible: true,
        onTap: notifier.toggleAutoCrop,
      ),
      CameraSettingTile(
        id: 'color_filter',
        icon: LucideIcons.palette,
        label: 'Color Filter',
        valueText: ScanFilter.fromId(settings.filterId).label,
        visible: true,
        onTap: () => CameraPickerBottomSheet.show<String>(
          context: context,
          title: 'Color Filter',
          options: ScanFilter.all
              .map((f) => CameraPickerOption(value: f.id, label: f.label))
              .toList(),
          initialValue: settings.filterId,
          onSelected: notifier.setColorFilter,
        ),
      ),
      CameraSettingTile(
        id: 'home_screen',
        icon: LucideIcons.house,
        label: 'Home Screen',
        valueText: '',
        visible: true,
        onTap: onHomeScreenTap,
      ),
      CameraSettingTile(
        id: 'spirit_level',
        icon: LucideIcons.circleDot,
        label: 'Spirit Level',
        valueText: settings.spiritLevel ? 'On' : 'Off',
        isOn: settings.spiritLevel,
        visible: true,
        onTap: notifier.toggleSpiritLevel,
      ),
      CameraSettingTile(
        id: 'scan_quality',
        icon: LucideIcons.sparkles,
        label: 'Scan Quality',
        valueText: settings.scanQuality.label,
        visible: true,
        onTap: () => CameraPickerBottomSheet.show<ScanQuality>(
          context: context,
          title: 'Scan Quality',
          options: ScanQuality.values
              .map((q) => CameraPickerOption(
                    value: q,
                    label: q.label,
                    caption: q.caption,
                  ))
              .toList(),
          initialValue: settings.scanQuality,
          onSelected: notifier.setScanQuality,
        ),
      ),
      CameraSettingTile(
        id: 'auto_capture_time',
        icon: LucideIcons.clock,
        label: 'Auto Capture\nTime',
        valueText: '${settings.autoCaptureTimeSeconds} sec',
        visible: true,
        onTap: () => CameraPickerBottomSheet.show<int>(
          context: context,
          title: 'Auto Capture Time',
          options: const [
            CameraPickerOption(value: 1, label: '1 sec'),
            CameraPickerOption(value: 2, label: '2 sec'),
            CameraPickerOption(value: 3, label: '3 sec'),
          ],
          initialValue: settings.autoCaptureTimeSeconds,
          onSelected: notifier.setAutoCaptureTime,
        ),
      ),
      CameraSettingTile(
        id: 'capture_sound',
        icon: LucideIcons.volume2,
        label: 'Capture Sound',
        valueText: settings.captureSound ? 'On' : 'Off',
        isOn: settings.captureSound,
        visible: false,
        onTap: () {},
      ),
      CameraSettingTile(
        id: 'focus_sound',
        icon: LucideIcons.scan,
        label: 'Focus Sound',
        valueText: settings.focusSound ? 'On' : 'Off',
        isOn: settings.focusSound,
        visible: false,
        onTap: () {},
      ),
      CameraSettingTile(
        id: 'image_rotation',
        icon: LucideIcons.smartphone,
        label: 'Image Rotation',
        valueText: settings.imageRotation,
        visible: false,
        onTap: () {},
      ),
      CameraSettingTile(
        id: 'settings',
        icon: LucideIcons.settings,
        label: 'Settings',
        valueText: '',
        visible: false,
        onTap: () {},
      ),
    ];
  }
}
