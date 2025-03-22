import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'shimmer_button.dart';

/// A responsive sidebar that adjusts based on screen size
class ResponsiveSidebar extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onCreateStory;
  final VoidCallback onSettings;

  const ResponsiveSidebar({
    super.key,
    required this.width,
    required this.height,
    required this.onCreateStory,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we're in compact mode (width < 130px)
    final bool isCompact = width < 130;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.sidebarGradient,
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          // App Logo/Title section
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: isCompact ? 8.0 : 16.0,
            ),
            child: isCompact
                ? Icon(
                    Icons.auto_stories,
                    color: AppColors.textLight,
                    size: 32,
                  )
                : Text(
                    'Story Narrator',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          
          const SizedBox(height: 20),
          
          // Create Story Button with rainbow shimmer effect
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8.0 : 16.0,
            ),
            child: isCompact
                ? ShimmerButton(
                    icon: Icons.add_circle_outline,
                    label: 'Create',
                    onPressed: onCreateStory,
                    isCompact: true,
                  )
                : ShimmerButton(
                    icon: Icons.add_circle_outline,
                    label: 'Create Story',
                    onPressed: onCreateStory,
                  ),
          ),
          
          // Fill the space between the create button and settings button
          const Spacer(),
          
          // Settings Button at the bottom
          Padding(
            padding: EdgeInsets.only(
              left: isCompact ? 8.0 : 16.0,
              right: isCompact ? 8.0 : 16.0,
              bottom: 30.0,
            ),
            child: isCompact
                ? ShimmerButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: onSettings,
                    isCompact: true,
                  )
                : ShimmerButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: onSettings,
                  ),
          ),
        ],
      ),
    );
  }
}
