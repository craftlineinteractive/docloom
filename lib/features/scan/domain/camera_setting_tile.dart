import 'package:flutter/widgets.dart';

@immutable
class CameraSettingTile {
  const CameraSettingTile({
    required this.id,
    required this.icon,
    required this.label,
    required this.valueText,
    this.isOn,
    required this.visible,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final String label;
  final String valueText;
  final bool? isOn;
  final bool visible;
  final VoidCallback onTap;
}
