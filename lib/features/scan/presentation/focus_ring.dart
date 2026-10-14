import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

class FocusRing extends StatefulWidget {
  const FocusRing({
    super.key,
    required this.position,
    required this.onDismiss,
  });

  final Offset position;
  final VoidCallback onDismiss;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const halfSize = AppSizes.focusRing / 2;
    return Positioned(
      left: widget.position.dx - halfSize,
      top: widget.position.dy - halfSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: AppSizes.focusRing,
                height: AppSizes.focusRing,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.gold,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(halfSize),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
