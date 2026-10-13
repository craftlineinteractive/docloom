import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class FolderPaletteRow extends StatelessWidget {
  const FolderPaletteRow({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(AppColors.folderPalette.length, (i) {
        final color = AppColors.folderPalette[i];
        final isSelected = i == selectedIndex;
        return InkWell(
          onTap: () => onSelect(i),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: AppColors.primary, width: 3) : null,
              ),
              child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
            ),
          ),
        );
      }),
    );
  }
}
