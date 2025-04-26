import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/story_scene.dart';
import '../../models/script.dart';
import '../../models/character.dart';
import '../../models/scene_image.dart'; // Added
import '../../database/database_helper.dart'; // Added
import 'package:xml/xml.dart'; // Added for XML parsing
import '../../services/gemini_service.dart'; // Added
import '../../prompts/scene_image_generation_prompt.dart'; // Added
import '../../utils/ui/app_colors.dart';
import 'script_item.dart';

class SceneDetails extends StatelessWidget {
  final StoryScene scene;
  final List<Character> characters;
  final Function(Script) onGenerateVoice;
  final String storyTitle; // Added
  final DatabaseHelper dbHelper; // Added
  final GeminiService geminiService; // Added

  const SceneDetails({
    super.key,
    required this.scene,
    required this.characters,
    required this.onGenerateVoice,
    required this.storyTitle, // Added
    required this.dbHelper, // Added
    required this.geminiService, // Added
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
                Row( // Wrap icons in a Row
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton( // Removed const
                      icon: const Icon(Icons.auto_awesome, color: AppColors.accent1), // Use accent1 color
                      onPressed: () => _handleMagicWandPressed(context), // Correct onPressed signature
                      tooltip: 'Generate Image Suggestions',
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

  // --- Helper Methods ---

  void _handleMagicWandPressed(BuildContext context) {
    if (scene.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot generate images for an unsaved scene.')),
      );
      return;
    }
    _showImageGenerationDialog(context);
  }

  void _showImageGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ImageGenerationDialog(
          storyTitle: storyTitle,
          scene: scene,
          dbHelper: dbHelper,
          geminiService: geminiService,
        );
      },
    );
  }
} // End of SceneDetails class


// --- Image Generation Dialog Widget ---

class ImageGenerationDialog extends StatefulWidget {
  final String storyTitle;
  final StoryScene scene;
  final DatabaseHelper dbHelper;
  final GeminiService geminiService;

  const ImageGenerationDialog({
    super.key,
    required this.storyTitle,
    required this.scene,
    required this.dbHelper,
    required this.geminiService,
  });

  @override
  State<ImageGenerationDialog> createState() => _ImageGenerationDialogState();
}

class _ImageGenerationDialogState extends State<ImageGenerationDialog> {
  bool _isLoading = true;
  List<SceneImage>? _existingImages;
  String? _geminiResponse;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _existingImages = null;
      _geminiResponse = null;
    });

    try {
      final images = await widget.dbHelper.getSceneImagesBySceneId(widget.scene.id!);
      if (!mounted) return;

      if (images.isNotEmpty) {
        setState(() {
          _existingImages = images;
          _isLoading = false;
        });
      } else {
        // No existing images, trigger Gemini generation
        await _generateImagePrompts();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error fetching existing images: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateImagePrompts() async {
     if (!mounted) return;
     // Ensure loading is true before API call
     setState(() {
       _isLoading = true;
       _error = null; // Clear previous errors
     });

    try {
      // Construct User Prompt
      final imageFocus = widget.scene.imagePrompt?.isNotEmpty ?? false
          ? widget.scene.imagePrompt!
          : widget.scene.narration?.scriptText ?? 'General scene atmosphere and actions.'; // Fallback if imagePrompt and narration are null/empty
      final characterActions = widget.scene.characterActions?.isNotEmpty ?? false
          ? widget.scene.characterActions!
          : 'No specific character actions described.';

      final userPrompt = """
Story Title: ${widget.storyTitle}
Scene Number: ${widget.scene.sceneNumber}
Desired Image Focus: $imageFocus
Character Actions: $characterActions
""";

      // Call Gemini Service - IMPORTANT: Assuming generateStory returns raw text here
      // If generateStory strictly returns cleaned XML, GeminiService needs modification
      // or a new method. For now, proceed with this assumption.
      final response = await widget.geminiService.generateImagePrompts(
        sceneImageGenerationSystemPrompt, // Use the specific system prompt
        userPrompt,
        // No storyId needed here as we are not saving the response to the story table
      );

      if (!mounted) return;

      // 1. Clean the response
      String cleanedResponse = response
          .replaceAll(RegExp(r'^```(?:xml)?\s*|\s*```$'), '') // Remove markdown fences
          .trim();

      // 2. Parse XML and Extract Prompts
      List<SceneImage> newImages = [];
      try {
        final document = XmlDocument.parse(cleanedResponse);
        final promptsElement = document.findElements('prompts').firstOrNull;
        if (promptsElement != null) {
          final promptElements = promptsElement.findElements('prompt');
          for (var promptElement in promptElements) {
            final promptText = promptElement.innerText.trim();
            if (promptText.isNotEmpty) {
              newImages.add(SceneImage(
                sceneId: widget.scene.id!,
                prompt: promptText,
                // imagePath and other fields will be null initially
              ));
            }
          }
        } else {
          throw Exception('Could not find <prompts> tag in the response.');
        }

        // 3. Insert into Database
        if (newImages.isNotEmpty) {
          for (var image in newImages) {
            await widget.dbHelper.insertSceneImage(image);
            if (!mounted) return; // Check mounted status after each async operation
          }
          // 4. Refresh data on success
          await _fetchData(); // Re-fetch to show the newly added images
        } else {
           // If no prompts were extracted, still stop loading
           if (!mounted) return;
           setState(() {
             _isLoading = false;
             // Optionally set an error or message if no prompts found
             _error = 'No valid image prompts were generated.';
           });
        }

      } catch (parseOrDbError) {
        // Handle parsing or DB errors
        if (!mounted) return;
        setState(() {
          _error = 'Error processing suggestions: ${parseOrDbError.toString()}';
          _isLoading = false;
        });
      }

    } catch (e) { // Catch errors from the Gemini API call itself
      if (!mounted) return;
      setState(() {
        _error = 'Error generating suggestions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Image Suggestions for Scene ${widget.scene.sceneNumber}'),
      content: SizedBox( // Constrain dialog size
        width: double.maxFinite,
        child: _buildDialogContent(),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildDialogContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return SingleChildScrollView(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)));
    }
    if (_existingImages != null && _existingImages!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Existing Image Prompts:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded( // Make list scrollable
            child: ListView.separated( // Use separated for dividers
              shrinkWrap: true,
              itemCount: _existingImages!.length,
              separatorBuilder: (context, index) => const Divider(height: 1), // Add dividers
              itemBuilder: (context, index) {
                final img = _existingImages![index];
                // TODO: Optionally display image if img.imagePath is valid
                return Padding( // Add padding around each item
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      img.prompt,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // subtitle: img.imagePath != null ? Text('Path: ${img.imagePath}', style: Theme.of(context).textTheme.bodySmall) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.content_copy, size: 20.0),
                      tooltip: 'Copy Prompt',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: img.prompt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Prompt copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0), // Adjust padding
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    if (_geminiResponse != null) {
       return Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text("Generated Suggestions:", style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 8),
           Expanded( // Make response scrollable
             child: SingleChildScrollView(
               child: SelectableText(_geminiResponse!), // Use SelectableText
             ),
           ),
         ],
       );
    }
    // Fallback if no existing images and no error/loading state
    return const Center(child: Text('No suggestions generated or available.'));
  }
}


// --- Original _MetadataItem Widget ---

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
