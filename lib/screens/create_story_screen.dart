import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/ui/app_colors.dart';
import '../utils/ui/content_container.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  // Form controllers
  final TextEditingController _storyIdeaController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  
  // Form values
  String _selectedGenre = 'Fantasy';
  String _selectedEra = 'Modern';
  String _selectedSetting = 'Urban';
  bool _isHistorical = false;
  int _characterCount = 2;
  
  // Character names - expandable based on character count
  List<String> _characterNames = ['', ''];
  List<String> _characterRoles = ['Protagonist', 'Antagonist'];
  
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
            'Genre',
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
            ),
            items: _genres.map((genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGenre = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Era dropdown
          const Text(
            'Era',
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
            ),
            items: _eras.map((era) {
              return DropdownMenuItem<String>(
                value: era,
                child: Text(era),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEra = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Setting dropdown
          const Text(
            'Setting',
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
            ),
            items: _settings.map((setting) {
              return DropdownMenuItem<String>(
                value: setting,
                child: Text(setting),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSetting = value!;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Characters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Character',
                onPressed: () {
                  if (_characterCount < 10) {
                    setState(() {
                      _characterCount++;
                      _characterNames.add('');
                      _characterRoles.add('Supporting Character');
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Define key characters in your story (optional)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 16),
          
          // Character list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _characterCount,
            itemBuilder: (context, index) {
              return _buildCharacterInput(index);
            },
          ),
        ],
      ),
    );
  }

  // Individual character input row
  Widget _buildCharacterInput(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                _characterNames[index] = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              controller: TextEditingController(text: _characterRoles[index]),
              onChanged: (value) {
                _characterRoles[index] = value;
              },
            ),
          ),
          if (index > 1) // First two characters can't be removed
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  _characterNames.removeAt(index);
                  _characterRoles.removeAt(index);
                  _characterCount--;
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
              // TODO: Save and generate story
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
