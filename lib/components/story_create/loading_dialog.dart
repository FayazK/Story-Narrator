import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ui/app_colors.dart';

class LoadingDialog extends StatefulWidget {
  final VoidCallback? onCancel;
  final double progress;

  const LoadingDialog({
    super.key,
    this.onCancel,
    this.progress = 0.0,
  });

  static void show(BuildContext context, {VoidCallback? onCancel, double progress = 0.0}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(onCancel: onCancel, progress: progress),
    );
  }
  
  /// Update the progress of an already shown dialog
  static void updateProgress(BuildContext context, double progress) {
    // Find the loading dialog state in the widget tree
    final LoadingDialogState? state = context.findAncestorStateOfType<LoadingDialogState>();
    if (state != null) {
      state.updateProgress(progress);
    }
  }

  @override
  State<LoadingDialog> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
  int _currentTipIndex = 0;
  late final List<String> _writingTips;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    _initializeTips();
    _startTipRotation();
  }

  /// Initialize the writing tips
  void _initializeTips() {
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
  }
  
  /// Update progress from parent
  void updateProgress(double progress) {
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  /// Start rotating tips every few seconds
  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _writingTips.length;
        });
        _startTipRotation(); // Continue rotation
      }
    });
  }

  String _getEstimatedTime() {

    if (_progress < 0.1) {
      return "Starting up...";
    } else if (_progress < 0.3) {
      return "About a minute remaining";
    } else if (_progress < 0.6) {
      return "About 30 seconds remaining";
    } else if (_progress < 0.9) {
      return "Almost done...";
    } else {
      return "Finalizing your story...";
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
                    value: _progress, // Use actual progress value from parent
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