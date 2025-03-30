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
  bool _isApiConfigured = false;
  int? _generatedStoryId;
  double _generationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkApiConfiguration();
  }
  
  @override
  void dispose() {
    _storyIdeaController.dispose();
    _titleController.dispose();
    // If there's a partially generated story that wasn't completed, clean it up
    _cleanupPartialStory();
    super.dispose();
  }
  
  /// Check if the Gemini API is configured
  Future<void> _checkApiConfiguration() async {
    final isConfigured = await StoryGeneratorHelper.isGeminiApiConfigured();
    setState(() {
      _isApiConfigured = isConfigured;
    });
  }
  
  /// Clean up any partially generated story if needed
  Future<void> _cleanupPartialStory() async {
    if (_generatedStoryId != null && _isGenerating) {
      await StoryGeneratorHelper.cleanupPartialStory(_generatedStoryId!);
    }
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
    
    // Clean up the partial story if one was created
    if (_generatedStoryId != null) {
      StoryGeneratorHelper.cleanupPartialStory(_generatedStoryId!);
      _generatedStoryId = null;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story generation cancelled')),
    );
  }

  /// Check if API is configured, show a message if not
  void _showApiConfigurationMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'API Key Required',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'You need to configure your Gemini API key in the settings before generating stories.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Generate a story using StoryGeneratorHelper
  Future<void> _generateStory() async {
    if (_isGenerating) return;
    
    // Check if API is configured
    if (!_isApiConfigured) {
      _showApiConfigurationMessage();
      return;
    }

    // Check if the story idea is empty
    if (_storyIdeaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a story idea')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _generatedStoryId = null;
    });

    // Show loading indicator with progress
    LoadingDialog.show(
      context,
      onCancel: _cancelGeneration,
      progress: _generationProgress,
    );

    try {
      // Generate the story with progress tracking
      final int storyId = await StoryGeneratorHelper.generateStory(
        storyIdea: _storyIdeaController.text,
        title: _titleController.text,
        genre: _selectedGenre,
        era: _selectedEra,
        setting: _selectedSetting,
        isHistorical: _isHistorical,
        characterInformation: _characterInformation,
        isCancelled: !_isGenerating, // Pass cancellation state
        onProgress: (progress) {
          // Update progress in the UI
          if (mounted) {
            setState(() {
              _generationProgress = progress;
            });
            
            // Update the dialog's progress
            if (Navigator.of(context).canPop()) {
              LoadingDialog.updateProgress(context, progress);
            }
          }
        },
      );

      // Save the generated story ID for potential cleanup
      _generatedStoryId = storyId;

      if (!mounted || !_isGenerating) return;

      // Hide loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isGenerating = false;
        _generationProgress = 1.0;
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
      if (!mounted) return;

      // Hide loading dialog if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isGenerating = false;
      });

      // Only show error if not a cancellation exception
      if (e.toString() != 'Exception: Story generation was cancelled') {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating story: ${e.toString()}')),
        );
      }
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