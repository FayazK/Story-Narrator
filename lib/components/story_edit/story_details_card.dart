import 'package:flutter/material.dart';
import '../../models/story.dart';
import '../../utils/ui/app_colors.dart';
import '../../services/story_repair_service.dart';

class StoryDetailsCard extends StatelessWidget {
  final Story story;
  final VoidCallback? onStoryUpdated;

  const StoryDetailsCard({
    super.key,
    required this.story,
    this.onStoryUpdated,
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
                Row(
                  children: [
                    // Fix Story Button
                    if (story.scenes.isEmpty || story.characters.isEmpty) // Only show if story has no scenes/characters
                      Tooltip(
                        message: 'Attempt to fix story structure by reparsing AI response',
                        child: IconButton(
                          icon: const Icon(Icons.healing, color: AppColors.accent3),
                          onPressed: () => _repairStory(context),
                          tooltip: 'Fix Story',
                        ),
                      ),
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () {
                        // TODO: Implement edit story details functionality
                      },
                      tooltip: 'Edit Story Details',
                    ),
                  ],
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

  /// Attempt to repair the story by reparsing the AI response
  Future<void> _repairStory(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Fixing Story',
            style: TextStyle(color: AppColors.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Attempting to repair story structure...'),
              const SizedBox(height: 8),
              const Text(
                'This will reanalyze the AI response and rebuild characters and scenes.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    try {
      // Use the story repair service to fix the story
      final repairService = StoryRepairService();
      final success = await repairService.repairStory(story.id!);

      // Pop the loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Story structure was successfully repaired!'),
              backgroundColor: AppColors.accent2,
            ),
          );

          // Refresh the screen
          onStoryUpdated?.call();
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to repair story. Check console for details.'),
              backgroundColor: AppColors.accent4,
            ),
          );
        }
      }
    } catch (e) {
      // Pop the loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error repairing story: $e'),
            backgroundColor: AppColors.accent4,
          ),
        );
      }
    }
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
