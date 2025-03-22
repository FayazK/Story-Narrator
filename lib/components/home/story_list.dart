import 'package:flutter/material.dart';
import '../../models/story.dart';
import '../../utils/ui/app_colors.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;
  final Function(int) onStorySelected;

  const StoryList({
    super.key,
    required this.stories,
    required this.onStorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: AppColors.textMedium.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No stories found',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first story to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: stories.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final story = stories[index];
        return _StoryCard(
          story: story,
          onTap: () => onStorySelected(story.id!),
        );
      },
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _StoryCard({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story thumbnail or icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.book,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Story details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Created date
                    if (story.createdAt != null)
                      Text(
                        'Created: ${story.createdAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Stats row
                    Row(
                      children: [
                        _StatBubble(
                          icon: Icons.person,
                          label: 'Characters',
                          value: story.characters.length.toString(),
                        ),
                        const SizedBox(width: 12),
                        _StatBubble(
                          icon: Icons.movie,
                          label: 'Scenes',
                          value: story.scenes.length.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Edit icon
              Icon(
                Icons.chevron_right,
                color: AppColors.textMedium,
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
