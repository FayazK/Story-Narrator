import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A button with a simple shimmer effect and thin gray border
class ShimmerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ShimmerButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<ShimmerButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color.lerp(
                  Colors.grey.shade300,
                  Colors.grey.shade500,
                  (_controller.value - 0.5).abs() * 2,
                )!,
                width: 1.0,
              ),
              color: _isHovered ? AppColors.primary.withOpacity(0.05) : Colors.white,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(11),
                splashColor: AppColors.primary.withOpacity(0.1),
                highlightColor: AppColors.primary.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
