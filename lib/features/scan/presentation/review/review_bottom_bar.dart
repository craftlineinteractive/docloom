import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'review_filter_row.dart';
import 'review_toolbar.dart';

class ReviewBottomBar extends StatelessWidget {
  const ReviewBottomBar({
    super.key,
    required this.isColorOpen,
    required this.selectedFilterId,
    required this.onSelectFilter,
    required this.onApplyToAll,
    required this.onCrop,
    required this.onColor,
    required this.onRotate,
    required this.onArrange,
    required this.onRetake,
    required this.onDelete,
    required this.onCheck,
    this.isCropVisible = true,
    this.thumbnails = const {},
  });

  final bool isColorOpen, isCropVisible;
  final String selectedFilterId;
  final ValueChanged<String> onSelectFilter;
  final VoidCallback onApplyToAll, onCrop, onColor, onRotate, onArrange, onRetake, onDelete, onCheck;
  final Map<String, Uint8List> thumbnails;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isColorOpen)
            ReviewFilterSubRow(
              selectedFilterId: selectedFilterId,
              onSelectFilter: onSelectFilter,
              onApplyToAll: onApplyToAll,
              thumbnails: thumbnails,
            ),
          ReviewToolbar(
            isColorActive: isColorOpen,
            isCropVisible: isCropVisible,
            onCrop: onCrop,
            onColor: onColor,
            onRotate: onRotate,
            onArrange: onArrange,
            onRetake: onRetake,
            onDelete: onDelete,
            onCheck: onCheck,
          ),
        ],
      ),
    );
  }
}
