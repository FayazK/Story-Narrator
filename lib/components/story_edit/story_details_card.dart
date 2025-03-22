import 'package:flutter/material.dart';
import '../../models/story.dart';
import '../../utils/ui/app_colors.dart';

class StoryDetailsCard extends StatelessWidget {
  final Story story;

  const StoryDetailsCard({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Story Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    // TODO: Implement edit story details functionality
                  },
                  tooltip: 'Edit Story Details',
                ),
              ],
            ),
            const Divider(),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Title:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Image Prompt
            if (story.imagePrompt != null && story.imagePrompt!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'Image Prompt:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        story.imagePrompt!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Created/Updated timestamps
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Created:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      story.createdAt ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (story.updatedAt != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        'Last Updated:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        story.updatedAt!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Total scenes/characters count
            const SizedBox(height: 8),
            Row(
              children: [
                _StatBubble(
                  icon: Icons.movie,
                  label: 'Scenes',
                  value: story.scenes.length.toString(),
                ),
                const SizedBox(width: 16),
                _StatBubble(
                  icon: Icons.person,
                  label: 'Characters',
                  value: story.characters.length.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBubble({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
