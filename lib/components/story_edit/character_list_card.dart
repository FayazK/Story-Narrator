import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../utils/ui/app_colors.dart';

class CharacterListCard extends StatefulWidget {
  final List<Character> characters;
  final Function(Character, String) onVoiceSelected;

  const CharacterListCard({
    super.key,
    required this.characters,
    required this.onVoiceSelected,
  });

  @override
  State<CharacterListCard> createState() => _CharacterListCardState();
}

class _CharacterListCardState extends State<CharacterListCard> {
  // Mock-up of voice data from ElevenLabs - this would be fetched in a real implementation
  final List<Map<String, dynamic>> _mockVoices = [
    {'id': 'voice1', 'name': 'Adam', 'description': 'Male, American accent'},
    {'id': 'voice2', 'name': 'Emma', 'description': 'Female, British accent'},
    {'id': 'voice3', 'name': 'Jason', 'description': 'Male, Australian accent'},
    {'id': 'voice4', 'name': 'Sarah', 'description': 'Female, American accent'},
    {'id': 'voice5', 'name': 'Michael', 'description': 'Male, British accent'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Characters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: () {
                    // TODO: Implement refresh voices functionality
                  },
                  tooltip: 'Refresh Voice List',
                ),
              ],
            ),
            const Divider(),
            // Character List
            const SizedBox(height: 8),
            if (widget.characters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No characters available',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: widget.characters.map((character) {
                  return _CharacterItem(
                    character: character,
                    availableVoices: _mockVoices,
                    onVoiceSelected: widget.onVoiceSelected,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CharacterItem extends StatelessWidget {
  final Character character;
  final List<Map<String, dynamic>> availableVoices;
  final Function(Character, String) onVoiceSelected;

  const _CharacterItem({
    required this.character,
    required this.availableVoices,
    required this.onVoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Character Avatar/Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    character.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Character Name and Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (character.gender != null || character.voiceDescription != null)
                      Text(
                        [
                          if (character.gender != null) character.gender,
                          if (character.voiceDescription != null) character.voiceDescription,
                        ].join(', '),
                        style: const TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Voice Dropdown
          Row(
            children: [
              const Text(
                'Voice:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: character.voiceId,
                  hint: const Text('Select a voice'),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onVoiceSelected(character, newValue);
                    }
                  },
                  items: availableVoices.map<DropdownMenuItem<String>>((Map<String, dynamic> voice) {
                    return DropdownMenuItem<String>(
                      value: voice['id'],
                      child: Text('${voice['name']} - ${voice['description']}'),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
