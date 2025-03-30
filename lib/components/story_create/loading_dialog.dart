import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ui/app_colors.dart';

class LoadingDialog extends StatefulWidget {
  final VoidCallback? onCancel;

  const LoadingDialog({
    super.key,
    this.onCancel,
  });

  static void show(BuildContext context, {VoidCallback? onCancel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(onCancel: onCancel),
    );
  }

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  int _currentTipIndex = 0;
  late final List<String> _writingTips;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _writingTips = [
      "Creating your character profiles...",
      "Crafting the perfect story structure...",
      "Adding engaging plot twists...",
      "Developing the story world...",
      "Polishing the narrative flow...",
      "Adding descriptive details...",
      "Weaving subplots together...",
      "Finalizing character arcs...",
    ];

    // Simulate progress and rotate tips
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _progress += 0.004; // Increment progress
          if (_progress >= 1.0) {
            _progress = 0.0;
          }
        });
        _startProgressSimulation();
      }
    });

    // Rotate tips every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _writingTips.length;
        });
        _startProgressSimulation();
      }
    });
  }

  String _getEstimatedTime() {
    // Simple estimation based on progress
    final remainingProgress = 1.0 - _progress;
    final estimatedSeconds = (remainingProgress * 60).round(); // Assume 60 seconds total
    if (estimatedSeconds > 45) {
      return "About a minute";
    } else if (estimatedSeconds > 30) {
      return "About 45 seconds";
    } else if (estimatedSeconds > 15) {
      return "About 30 seconds";
    } else {
      return "Almost done...";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            
            // Progress Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    color: AppColors.primary,
                    strokeWidth: 8,
                  ),
                ),
                Icon(
                  Icons.auto_stories,
                  size: 32,
                  color: AppColors.primary,
                ).animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 3.seconds),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Generating your story...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms),
            const SizedBox(height: 8),

            // Current Action Text
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                _writingTips[_currentTipIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ).animate()
                .fadeIn(duration: 400.ms)
                .moveY(begin: 10, end: 0),
            ),

            // Estimated Time
            Text(
              _getEstimatedTime(),
              style: TextStyle(
                color: AppColors.textMedium.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Button
            if (widget.onCancel != null)
              TextButton(
                onPressed: widget.onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMedium,
                ),
                child: const Text('Cancel Generation'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}