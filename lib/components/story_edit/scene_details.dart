import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/story_scene.dart';
import '../../models/script.dart';
import '../../models/character.dart';
import '../../utils/ui/app_colors.dart';
import 'script_item.dart';

class SceneDetails extends StatelessWidget {
  final StoryScene scene;
  final List<Character> characters;
  final Function(Script) onGenerateVoice;

  const SceneDetails({
    super.key,
    required this.scene,
    required this.characters,
    required this.onGenerateVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with scene number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scene ${scene.sceneNumber} Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    // TODO: Implement scene details edit functionality
                  },
                  tooltip: 'Edit Scene Details',
                ),
              ],
            ),
            const Divider(),

            // Scene metadata (if available)
            if (scene.characterActions != null ||
                scene.backgroundImage != null ||
                scene.backgroundSound != null ||
                scene.soundEffects != null)
              _buildSceneMetadata(),

            const SizedBox(height: 16),

            // Narration section (if available)
            if (scene.narration != null) _buildNarrationSection(),

            const SizedBox(height: 16),

            // Character scripts section
            _buildCharacterScriptsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneMetadata() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scene.characterActions != null &&
              scene.characterActions!.isNotEmpty)
            _MetadataItem(
              icon: Icons.people,
              label: 'Character Actions',
              value: scene.characterActions!,
            ),
          if (scene.backgroundImage != null &&
              scene.backgroundImage!.isNotEmpty)
            _MetadataItem(
              icon: Icons.image,
              label: 'Background Image',
              value: scene.backgroundImage!,
            ),
          if (scene.backgroundSound != null &&
              scene.backgroundSound!.isNotEmpty)
            _MetadataItem(
              icon: Icons.music_note,
              label: 'Background Sound',
              value: scene.backgroundSound!,
            ),
          if (scene.soundEffects != null && scene.soundEffects!.isNotEmpty)
            _MetadataItem(
              icon: Icons.surround_sound,
              label: 'Sound Effects',
              value: scene.soundEffects!,
            ),
        ],
      ),
    );
  }

  Widget _buildNarrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Narration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ScriptItem(
          script: scene.narration!,
          character: null, // Narrator doesn't have a character
          onGenerateVoice: onGenerateVoice,
        ),
      ],
    );
  }

  Widget _buildCharacterScriptsSection() {
    final characterScripts = scene.characterScripts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Character Dialogues',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        if (characterScripts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No character dialogues in this scene',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textMedium,
              ),
            ),
          )
        else
          Column(
            children:
                characterScripts.map((script) {
                  // Find the character for this script
                  final character = characters.firstWhere(
                    (char) => char.id == script.characterId,
                    orElse:
                        () => Character(
                          storyId: scene.storyId,
                          name: 'Unknown Character',
                        ),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ScriptItem(
                      script: script,
                      character: character,
                      onGenerateVoice: onGenerateVoice,
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
}

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label copied to clipboard'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.content_copy,
                    size: 16,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
