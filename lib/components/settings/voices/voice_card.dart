// lib/components/settings/voices/voice_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/ui/app_colors.dart';
import '../../../models/voice.dart';
import '../../../providers/shared_voices_provider.dart';

class VoiceCard extends ConsumerWidget {
  final Voice voice;
  final bool isPlaying;

  const VoiceCard({
    super.key,
    required this.voice,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gender badge
              _buildVoiceHeader(),
              
              // Voice details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Voice name with language badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            voice.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (voice.language != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              voice.language!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Voice accent and age
                    if (voice.accent != null || voice.age != null)
                      Text(
                        [
                          if (voice.accent != null) voice.accent,
                          if (voice.age != null) voice.age,
                        ].where((e) => e != null).join(', '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    
                    // Voice description
                    if (voice.description != null)
                      Text(
                        voice.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Preview button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isPlaying) {
                              ref.read(sharedVoicesProvider.notifier).stopVoicePreview();
                            } else {
                              ref.read(sharedVoicesProvider.notifier).playVoicePreview(
                                    voice.id,
                                    voice.sampleText ?? 'Hello, this is a sample of my voice. How do you like it?',
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: isPlaying 
                                ? Colors.orange 
                                : AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: Icon(
                            isPlaying ? Icons.stop : Icons.play_arrow,
                            size: 18,
                          ),
                          label: Text(
                            isPlaying ? 'Stop' : 'Preview',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        
                        // Add/Remove button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (voice.isAddedToLibrary) {
                              ref.read(sharedVoicesProvider.notifier).removeVoiceFromLibrary(voice.id);
                            } else {
                              ref.read(sharedVoicesProvider.notifier).addVoiceToLibrary(voice);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: voice.isAddedToLibrary 
                                ? AppColors.accent4 
                                : Colors.white,
                            backgroundColor: voice.isAddedToLibrary 
                                ? Colors.white 
                                : AppColors.accent2,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: voice.isAddedToLibrary 
                                  ? BorderSide(color: AppColors.accent4) 
                                  : BorderSide.none,
                            ),
                          ),
                          icon: Icon(
                            voice.isAddedToLibrary 
                                ? Icons.delete_outline 
                                : Icons.add,
                            size: 18,
                          ),
                          label: Text(
                            voice.isAddedToLibrary ? 'Remove' : 'Add',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build voice header with color based on gender
  Widget _buildVoiceHeader() {
    final Color headerColor = _getGenderColor();
    final String? useCase = voice.useCase;
    final String category = voice.category ?? '';
    
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: headerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gender badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              (voice.gender ?? 'Unknown').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
          
          // Use case and category
          Flexible(
            child: Text(
              [
                if (useCase != null && useCase.isNotEmpty) useCase,
                if (category.isNotEmpty) category,
              ].where((e) => e.isNotEmpty).join(' · '),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Get color based on gender
  Color _getGenderColor() {
    final gender = voice.gender?.toLowerCase() ?? '';
    
    if (gender.contains('female')) {
      return Colors.purple.shade700;
    } else if (gender.contains('male')) {
      return Colors.blue.shade700;
    } else {
      return Colors.grey.shade700;
    }
  }
}
