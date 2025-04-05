// lib/components/settings/voices/user_voices_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/ui/app_colors.dart';
import '../../../providers/user_voices_provider.dart'; // Use the new provider
import 'voice_card.dart'; // Reuse the voice card

class UserVoicesContent extends ConsumerStatefulWidget {
  const UserVoicesContent({super.key});

  @override
  ConsumerState<UserVoicesContent> createState() => _UserVoicesContentState();
}

class _UserVoicesContentState extends ConsumerState<UserVoicesContent> {
  @override
  void initState() {
    super.initState();

    // Load user voices when widget initializes
    // Use addPostFrameCallback to ensure provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if already loaded to avoid redundant calls if widget rebuilds
      final state = ref.read(userVoicesProvider);
      if (state.state == UserVoicesState.initial) {
        ref.read(userVoicesProvider.notifier).loadUserVoices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final voicesData = ref.watch(userVoicesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Voices', // Updated title
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your custom and cloned voices from ElevenLabs.', // Updated description
                  style: TextStyle(fontSize: 16, color: AppColors.textMedium),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24), // Spacing after header
          // Voice grid
          Expanded(child: _buildVoicesList(voicesData)),
        ],
      ),
    );
  }

  Widget _buildVoicesList(UserVoicesData voicesData) {
    // Show loading state
    if (voicesData.state == UserVoicesState.loading &&
        voicesData.voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Loading your voices...'),
          ],
        ),
      );
    }

    // Show error state
    if (voicesData.state == UserVoicesState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(voicesData.errorMessage ?? 'Failed to load your voices'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userVoicesProvider.notifier).refreshVoices();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (voicesData.voices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic_off_outlined, // Different icon for user voices
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'No custom voices found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You can add custom voices on the ElevenLabs website.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(userVoicesProvider.notifier).refreshVoices();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Show grid of voice cards
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: RefreshIndicator(
        onRefresh: () => ref.read(userVoicesProvider.notifier).refreshVoices(),
        color: AppColors.primary,
        child: GridView.builder(
          // No scroll controller needed as we removed pagination
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust as needed
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          padding: const EdgeInsets.all(8),
          itemCount:
              voicesData.voices.length, // Direct count, no pagination loader
          itemBuilder: (context, index) {
            final voice = voicesData.voices[index];
            final isPlaying = voicesData.currentlyPlayingVoiceId == voice.id;

            return VoiceCard(
              voice: voice,
              isPlaying: isPlaying,
              onPlayPause: () {
                if (isPlaying) {
                  ref.read(userVoicesProvider.notifier).stopVoicePreview();
                } else {
                  // Use description or sampleText, or a default if both are null
                  final previewText =
                      voice.description ??
                      voice.sampleText ??
                      'Hello, this is a preview of my voice.';
                  ref
                      .read(userVoicesProvider.notifier)
                      .playVoicePreview(voice.id, previewText);
                }
              },
              onAddRemove: () {
                // User voices are managed differently; adding/removing might just be local DB state
                // Assuming isAddedToLibrary reflects local DB status for user voices
                if (voice.isAddedToLibrary) {
                  // Use isAddedToLibrary directly
                  ref
                      .read(userVoicesProvider.notifier)
                      .removeVoiceFromLibrary(voice.id);
                } else {
                  ref
                      .read(userVoicesProvider.notifier)
                      .addVoiceToLibrary(voice);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
