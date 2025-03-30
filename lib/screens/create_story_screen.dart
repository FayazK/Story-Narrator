// ... (previous imports remain the same)

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  // ... (previous state variables remain the same)
  
  bool _isGenerating = false;

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

  // ... (rest of the code remains the same)
}