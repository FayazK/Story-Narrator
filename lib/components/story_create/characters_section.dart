import 'package:flutter/material.dart';
import '../../utils/ui/app_colors.dart';

class CharactersSection extends StatelessWidget {
  final String characterInformation;
  final ValueChanged<String> onCharacterInfoChanged;

  const CharactersSection({
    super.key,
    required this.characterInformation,
    required this.onCharacterInfoChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
          ),
          const SizedBox(height: 16),

          // Character text area
          TextField(
            controller: TextEditingController(text: characterInformation),
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  'Example:\n- Sarah: 28-year-old detective with a mysterious past\n- Marcus: Town sheriff hiding dark secrets\n- Emily: Local librarian who discovers an ancient artifact',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: onCharacterInfoChanged,
          ),
        ],
      ),
    );
  }
}