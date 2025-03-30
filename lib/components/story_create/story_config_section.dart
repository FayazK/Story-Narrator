import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/ui/app_colors.dart';
import '../../utils/ui/content_container.dart';
import 'characters_section.dart';

class StoryConfigSection extends StatelessWidget {
  final String? selectedGenre;
  final String? selectedEra;
  final String? selectedSetting;
  final bool isHistorical;
  final String characterInformation;
  final ValueChanged<String?> onGenreChanged;
  final ValueChanged<String?> onEraChanged;
  final ValueChanged<String?> onSettingChanged;
  final ValueChanged<bool> onHistoricalChanged;
  final ValueChanged<String> onCharacterInfoChanged;

  final List<String> genres = [
    'Fantasy', 'Science Fiction', 'Mystery', 'Romance', 'Horror',
    'Adventure', 'Historical Fiction', 'Thriller', 'Comedy', 'Drama',
    'Fairy Tale', 'Fable', 'Dystopian', 'Steampunk', 'Western',
    'Cyberpunk', 'Paranormal',
  ];

  final List<String> eras = [
    'Ancient', 'Medieval', 'Renaissance', 'Industrial Revolution',
    'Victorian', 'Early 20th Century', 'Modern', 'Future',
    'Post-Apocalyptic',
  ];

  final List<String> settings = [
    'Urban', 'Rural', 'Wilderness', 'Coastal', 'Mountain', 'Desert',
    'Island', 'Space', 'Underwater', 'Underground', 'Kingdom',
    'Empire', 'Village', 'Academy', 'Mansion',
  ];

  StoryConfigSection({
    super.key,
    this.selectedGenre,
    this.selectedEra,
    this.selectedSetting,
    required this.isHistorical,
    required this.characterInformation,
    required this.onGenreChanged,
    required this.onEraChanged,
    required this.onSettingChanged,
    required this.onHistoricalChanged,
    required this.onCharacterInfoChanged,
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
              style: TextStyle(fontSize: 16, color: AppColors.textMedium),
            ),
            const SizedBox(height: 24),

            // Form fields
            _buildConfigForm(),

            const SizedBox(height: 32),

            // Characters section
            CharactersSection(
              characterInformation: characterInformation,
              onCharacterInfoChanged: onCharacterInfoChanged,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
    );
  }

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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedGenre,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: 'Select a genre (optional)',
            ),
            items: genres.map((genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            onChanged: onGenreChanged,
          ),
          const SizedBox(height: 16),

          // Era dropdown
          const Text(
            'Era (optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedEra,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: 'Select an era (optional)',
            ),
            items: eras.map((era) {
              return DropdownMenuItem<String>(
                value: era,
                child: Text(era),
              );
            }).toList(),
            onChanged: onEraChanged,
          ),
          const SizedBox(height: 16),

          // Setting dropdown
          const Text(
            'Setting (optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedSetting,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: 'Select a setting (optional)',
            ),
            items: settings.map((setting) {
              return DropdownMenuItem<String>(
                value: setting,
                child: Text(setting),
              );
            }).toList(),
            onChanged: onSettingChanged,
          ),
          const SizedBox(height: 16),

          // Historical toggle
          Row(
            children: [
              Switch(
                value: isHistorical,
                onChanged: onHistoricalChanged,
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Based on Historical Events',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}