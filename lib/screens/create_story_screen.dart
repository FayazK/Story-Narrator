import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/ui/app_colors.dart';
import '../utils/ui/content_container.dart';
import '../services/gemini_service.dart';
import '../prompts/story_generation_prompt.dart';

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
  
  // Available options for dropdowns
  final List<String> _genres = [
    'Fantasy', 'Science Fiction', 'Mystery', 'Romance', 
    'Horror', 'Adventure', 'Historical Fiction', 'Thriller',
    'Comedy', 'Drama', 'Fairy Tale', 'Fable', 'Dystopian',
    'Steampunk', 'Western', 'Cyberpunk', 'Paranormal'
  ];
  
  final List<String> _eras = [
    'Ancient', 'Medieval', 'Renaissance', 'Industrial Revolution',
    'Victorian', 'Early 20th Century', 'Modern', 'Future', 'Post-Apocalyptic'
  ];
  
  final List<String> _settings = [
    'Urban', 'Rural', 'Wilderness', 'Coastal', 'Mountain', 
    'Desert', 'Island', 'Space', 'Underwater', 'Underground',
    'Kingdom', 'Empire', 'Village', 'Academy', 'Mansion'
  ];

  @override
  void dispose() {
    _storyIdeaController.dispose();
    _titleController.dispose();
    super.dispose();
  }
  
  /// Generate a story using Gemini API
  Future<void> _generateStory() async {
    // Check if the story idea is empty
    if (_storyIdeaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a story idea')),
      );
      return;
    }
    
    // Show loading indicator
    _showLoadingDialog();
    
    try {
      // Get the Gemini service instance
      final geminiService = GeminiService();
      
      // Prepare the user message with all inputs
      final String userMessage = _buildUserMessage();
      
      // Get the system prompt
      final String systemPrompt = StoryGenerationPrompt.getSystemPrompt();
      
      // Generate the story
      final story = await geminiService.generateStory(systemPrompt, userMessage);
      
      // Hide loading dialog
      Navigator.of(context).pop();
      
      // Navigate to story view or save it
      // TODO: Implement save and view functionality
      
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story generated successfully!')),
      );
      
      // Print the generated story to console for now
      print('Generated Story:\n$story');
      
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating story: ${e.toString()}')),
      );
    }
  }
  
  /// Build the user message from all form inputs
  String _buildUserMessage() {
    final StringBuffer message = StringBuffer();
    
    // Add the story idea
    message.writeln('Story Idea: ${_storyIdeaController.text.trim()}');
    message.writeln();
    
    // Add title if provided
    if (_titleController.text.isNotEmpty) {
      message.writeln('Title: ${_titleController.text.trim()}');
      message.writeln();
    }
    
    // Add genre if selected
    if (_selectedGenre != null && _selectedGenre!.isNotEmpty) {
      message.writeln('Genre: $_selectedGenre');
    }
    
    // Add era if selected
    if (_selectedEra != null && _selectedEra!.isNotEmpty) {
      message.writeln('Era: $_selectedEra');
    }
    
    // Add setting if selected
    if (_selectedSetting != null && _selectedSetting!.isNotEmpty) {
      message.writeln('Setting: $_selectedSetting');
    }
    
    // Add historical flag if selected
    if (_isHistorical) {
      message.writeln('Include Historical Elements: Yes');
    }
    
    // Add character information if provided
    if (_characterInformation.isNotEmpty) {
      message.writeln();
      message.writeln('Characters:');
      message.writeln(_characterInformation);
    }
    
    return message.toString();
  }
  
  /// Show a loading dialog while generating the story
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'Generating your story...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a moment as our AI crafts your narrative.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
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
            onPressed: () {
              // TODO: Show help dialog
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Idea Input Section - 60% width
            Expanded(
              flex: 6,
              child: _buildStoryIdeaSection(),
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
              child: _buildStoryConfigSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // Section for story idea input
  Widget _buildStoryIdeaSection() {
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
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title input
            TextField(
              controller: _titleController,
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
                controller: _storyIdeaController,
                maxLines: 18,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Start typing your story idea or concept here...\n\nExample: "A detective with the ability to see memories of the dead investigates a series of mysterious disappearances in a small coastal town."',
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
                border: Border.all(
                  color: AppColors.primaryLight,
                ),
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
                      _buildPromptChip('A hero with a secret power'),
                      _buildPromptChip('Unexpected friendship'),
                      _buildPromptChip('Lost in an unknown world'),
                      _buildPromptChip('Time travel adventure'),
                      _buildPromptChip('Mystery in a small town'),
                      _buildPromptChip('Coming of age journey'),
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

  // Section for configuring story settings
  Widget _buildStoryConfigSection() {
    return ContentContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Story Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your story settings. All fields are optional.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            
            // Form fields
            _buildConfigForm(),
            
            const SizedBox(height: 32),
            
            // Characters section
            _buildCharactersSection(),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
    );
  }

  // Form for story configuration
  Widget _buildConfigForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre dropdown
          const Text(
            'Genre (optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedGenre,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Select a genre (optional)',
            ),
            items: _genres.map((genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGenre = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Era dropdown
          const Text(
            'Era (optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedEra,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Select an era (optional)',
            ),
            items: _eras.map((era) {
              return DropdownMenuItem<String>(
                value: era,
                child: Text(era),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEra = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Setting dropdown
          const Text(
            'Setting (optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedSetting,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Select a setting (optional)',
            ),
            items: _settings.map((setting) {
              return DropdownMenuItem<String>(
                value: setting,
                child: Text(setting),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSetting = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Historical toggle
          Row(
            children: [
              Switch(
                value: _isHistorical,
                onChanged: (value) {
                  setState(() {
                    _isHistorical = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Based on Historical Events',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Characters section with add/remove capability
  Widget _buildCharactersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Characters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Describe your characters and their roles (optional)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 16),
          
          // Character text area
          TextField(
            controller: TextEditingController(),
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Example:\n- Sarah: 28-year-old detective with a mysterious past\n- Marcus: Town sheriff hiding dark secrets\n- Emily: Local librarian who discovers an ancient artifact',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) {
              // Store character information as free-form text
              setState(() {
                _characterInformation = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // Bottom action bar with buttons
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              _generateStory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Generate Story',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Inspiration prompt chip
  Widget _buildPromptChip(String prompt) {
    return InkWell(
      onTap: () {
        // Insert the prompt into the text field
        _storyIdeaController.text = prompt;
      },
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
