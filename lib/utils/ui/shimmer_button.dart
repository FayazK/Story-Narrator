import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A button with a rainbow shimmer gradient effect
class ShimmerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isCompact;

  const ShimmerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isCompact = false,
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
      duration: const Duration(seconds: 3),
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
              gradient: AppColors.rainbowGradient(_controller.value * 2 * 3.14159),
              boxShadow: _isHovered ? AppColors.softShadow : null,
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: widget.isCompact ? 12.0 : 16.0,
                  horizontal: widget.isCompact ? 12.0 : 16.0,
                ),
                fixedSize: widget.isCompact ? null : const Size.fromWidth(double.maxFinite),
              ),
              child: Row(
                mainAxisSize: widget.isCompact ? MainAxisSize.min : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: widget.isCompact ? 18 : 24),
                  SizedBox(width: widget.isCompact ? 6 : 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.isCompact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
