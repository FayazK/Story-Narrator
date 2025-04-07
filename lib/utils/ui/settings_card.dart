import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A card container for settings sections
class SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final bool isExpanded;
  final Widget? trailing;

  const SettingsCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.isExpanded = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        childrenPadding: const EdgeInsets.all(16),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMedium,
        title: Row(
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: .7),
                    AppColors.primaryDark.withValues(alpha: .8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Optional trailing widget
            if (trailing != null) trailing!,
          ],
        ),
        children: [child],
      ),
    );
  }
}
