import 'package:flutter/material.dart';
import '../../utils/ui/app_colors.dart';

class PromptChip extends StatelessWidget {
  final String prompt;
  final VoidCallback onTap;

  const PromptChip({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          prompt,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}