import 'package:flutter/material.dart';
import '../../utils/ui/app_colors.dart';

class PlaceholderContent extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderContent({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This feature is coming soon.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
