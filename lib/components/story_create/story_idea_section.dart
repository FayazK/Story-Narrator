import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ui/app_colors.dart';
import '../../utils/ui/content_container.dart';
import 'prompt_chip.dart';

class StoryIdeaSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController storyIdeaController;

  const StoryIdeaSection({
    super.key,
    required this.titleController,
    required this.storyIdeaController,
  });

  @override
  Widget build(BuildContext context) {
    return ContentContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Story Idea',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe your story idea in as much or as little detail as you want. Our AI will help expand your concept into a full narrative.',
              style: TextStyle(fontSize: 16, color: AppColors.textMedium),
            ),
            const SizedBox(height: 24),

            // Title input
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Story Title',
                hintText: 'Enter a title for your story',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Story idea text area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppColors.subtleShadow,
              ),
              child: TextField(
                controller: storyIdeaController,
                maxLines: 18,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText:
                      'Start typing your story idea or concept here...\n\nExample: "A detective with the ability to see memories of the dead investigates a series of mysterious disappearances in a small coastal town."',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Story idea suggestions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Need inspiration?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PromptChip(
                        prompt: 'A hero with a secret power',
                        onTap: () => storyIdeaController.text = 'A hero with a secret power',
                      ),
                      PromptChip(
                        prompt: 'Unexpected friendship',
                        onTap: () => storyIdeaController.text = 'Unexpected friendship',
                      ),
                      PromptChip(
                        prompt: 'Lost in an unknown world',
                        onTap: () => storyIdeaController.text = 'Lost in an unknown world',
                      ),
                      PromptChip(
                        prompt: 'Time travel adventure',
                        onTap: () => storyIdeaController.text = 'Time travel adventure',
                      ),
                      PromptChip(
                        prompt: 'Mystery in a small town',
                        onTap: () => storyIdeaController.text = 'Mystery in a small town',
                      ),
                      PromptChip(
                        prompt: 'Coming of age journey',
                        onTap: () => storyIdeaController.text = 'Coming of age journey',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}