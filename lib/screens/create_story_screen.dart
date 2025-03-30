import 'package:flutter/material.dart';
import '../utils/ui/app_colors.dart';
import '../screens/story_edit_screen.dart';
import '../utils/helpers/story_generator_helper.dart';
import '../components/story_create/story_idea_section.dart';
import '../components/story_create/story_config_section.dart';
import '../components/story_create/bottom_action_bar.dart';
import '../components/story_create/loading_dialog.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  // Form controllers
  final TextEditingController _storyIdeaController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Form values - all optional
  String? _selectedGenre;
  String? _selectedEra;
  String? _selectedSetting;
  bool _isHistorical = false;
  String _characterInformation = '';
  bool _isGenerating = false;

  @override
  void dispose() {
    _storyIdeaController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Show help dialog with information about the story creation process
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Creating Your Story',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Story Idea',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Start with a basic idea or concept. You can be as detailed or brief as you like. Our AI will help expand your idea into a complete story.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Configuration Options',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Use the options on the right to customize your story\'s genre, era, setting, and characters. All these fields are optional.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Generation Process',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'After you click "Generate Story", our AI will:',
                ),
                const SizedBox(height: 8),
                const Text('• Create a complete narrative structure\n'
                    '• Develop your characters\n'
                    '• Generate scene descriptions\n'
                    '• Write dialogue and narration'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  /// Cancel the story generation process
  void _cancelGeneration() {
    setState(() {
      _isGenerating = false;
    });
    Navigator.of(context).pop(); // Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story generation cancelled')),
    );
  }

  /// Generate a story using StoryGeneratorHelper
  Future<void> _generateStory() async {
    if (_isGenerating) return;

    // Check if the story idea is empty
    if (_storyIdeaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a story idea')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Show loading indicator
    LoadingDialog.show(
      context,
      onCancel: _cancelGeneration,
    );

    try {
      // Generate the story
      final int storyId = await StoryGeneratorHelper.generateStory(
        storyIdea: _storyIdeaController.text,
        title: _titleController.text,
        genre: _selectedGenre,
        era: _selectedEra,
        setting: _selectedSetting,
        isHistorical: _isHistorical,
        characterInformation: _characterInformation,
      );

      if (!mounted || !_isGenerating) return;

      // Hide loading dialog
      Navigator.of(context).pop();

      setState(() {
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story generated and saved successfully!')),
      );

      // Navigate to the story edit screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StoryEditScreen(storyId: storyId),
        ),
      );
    } catch (e) {
      if (!mounted || !_isGenerating) return;

      // Hide loading dialog
      Navigator.of(context).pop();

      setState(() {
        _isGenerating = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating story: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Story',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.bgSurface),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Idea Input Section - 60% width
            Expanded(
              flex: 6,
              child: StoryIdeaSection(
                titleController: _titleController,
                storyIdeaController: _storyIdeaController,
              ),
            ),

            // Vertical divider
            Container(
              width: 1,
              color: AppColors.divider,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),

            // Story Configuration Section - 40% width
            Expanded(
              flex: 4,
              child: StoryConfigSection(
                selectedGenre: _selectedGenre,
                selectedEra: _selectedEra,
                selectedSetting: _selectedSetting,
                isHistorical: _isHistorical,
                characterInformation: _characterInformation,
                onGenreChanged: (value) => setState(() => _selectedGenre = value),
                onEraChanged: (value) => setState(() => _selectedEra = value),
                onSettingChanged: (value) => setState(() => _selectedSetting = value),
                onHistoricalChanged: (value) => setState(() => _isHistorical = value),
                onCharacterInfoChanged: (value) => setState(() => _characterInformation = value),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onCancel: () => Navigator.of(context).pop(),
        onGenerate: _generateStory,
      ),
    );
  }
}