// lib/providers/user_voices_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/elevenlabs_api_service.dart';
import '../database/database_helper.dart';
import '../models/voice.dart';
// import 'shared_voices_provider.dart'; // Removed import of deleted file

// States for the user voices feature
enum UserVoicesState { initial, loading, loaded, error }

// State class for user voices
class UserVoicesData {
  final List<Voice> voices;
  final UserVoicesState state;
  final String? errorMessage;
  final String? currentlyPlayingVoiceId;
  final AudioPlayer audioPlayer;

  UserVoicesData({
    required this.voices,
    required this.state,
    this.errorMessage,
    this.currentlyPlayingVoiceId,
    required this.audioPlayer,
  });

  // Copy with method for immutability
  UserVoicesData copyWith({
    List<Voice>? voices,
    UserVoicesState? state,
    ValueGetter<String?>? errorMessage,
    ValueGetter<String?>? currentlyPlayingVoiceId,
    AudioPlayer? audioPlayer,
  }) {
    return UserVoicesData(
      voices: voices ?? this.voices,
      state: state ?? this.state,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      currentlyPlayingVoiceId:
          currentlyPlayingVoiceId != null
              ? currentlyPlayingVoiceId()
              : this.currentlyPlayingVoiceId,
      audioPlayer: audioPlayer ?? this.audioPlayer,
    );
  }
}

// Notifier class for user voices
class UserVoicesNotifier extends StateNotifier<UserVoicesData> {
  final ElevenlabsApiService _elevenLabsService;
  final DatabaseHelper _databaseHelper;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  UserVoicesNotifier(this._elevenLabsService, this._databaseHelper)
    : super(
        UserVoicesData(
          voices: [],
          state: UserVoicesState.initial,
          audioPlayer: AudioPlayer(),
        ),
      );

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    state.audioPlayer.dispose();
    super.dispose();
  }

  // Method to load user voices
  Future<void> loadUserVoices({bool refresh = false}) async {
    if (state.state == UserVoicesState.loading && !refresh) return;

    try {
      state = state.copyWith(
        state: UserVoicesState.loading,
        errorMessage: () => null,
      );

      // Fetch user voices from API
      final fetchedVoices = await _elevenLabsService.getUserVoices();

      if (fetchedVoices == null) {
        throw Exception('API returned null user voice list');
      }

      // Check library status for each API voice
      final List<Voice> enhancedVoices = [];
      for (var voice in fetchedVoices) {
        final isInLibrary = await _databaseHelper.isVoiceInLibrary(voice.id);
        enhancedVoices.add(voice.copyWith(isAddedToLibrary: isInLibrary));
      }

      // Fetch all locally saved voices
      final localVoices = await _databaseHelper.getAllVoices();

      // Add local-only voices (not present in API response)
      for (var localVoice in localVoices) {
        final existsInApi = enhancedVoices.any((v) => v.id == localVoice.id);
        if (!existsInApi) {
          enhancedVoices.add(localVoice.copyWith(isAddedToLibrary: true));
        }
      }

      state = state.copyWith(
        voices: enhancedVoices,
        state: UserVoicesState.loaded,
      );
    } catch (e) {
      state = state.copyWith(
        state: UserVoicesState.error,
        errorMessage: () => 'Failed to load user voices: $e',
        voices: refresh ? state.voices : [], // Keep existing on refresh error
      );
    }
  }

  // Method to refresh voices
  Future<void> refreshVoices() async {
    await loadUserVoices(refresh: true);
  }

  // Method to play voice preview
  Future<void> playVoicePreview(String voiceId, String previewText) async {
    await stopVoicePreview();

    try {
      final voice = state.voices.firstWhere((v) => v.id == voiceId);

      state = state.copyWith(
        currentlyPlayingVoiceId: () => voiceId,
        errorMessage: () => null,
      );

      String? urlToPlay;

      if (voice.previewUrl != null && voice.previewUrl!.isNotEmpty) {
        urlToPlay = voice.previewUrl!;
      } else {
        // User voices might not always have a preview URL, generate if needed
        // Note: The API might not support generating previews for *all* user voice types
        // This uses the generic preview generation which might fail for some voices.
        final generatedUrl = await _elevenLabsService.getVoicePreviewAudio(
          voiceId,
          previewText, // Use a default preview text if needed
        );

        if (generatedUrl == null) {
          throw Exception('Failed to get preview audio URL');
        }
        urlToPlay = generatedUrl;
      }

      await state.audioPlayer.setUrl(urlToPlay);
      await state.audioPlayer.play();

      await _playerStateSubscription?.cancel();
      _playerStateSubscription = null;

      _playerStateSubscription = state.audioPlayer.playerStateStream.listen((
        playerState,
      ) {
        if (playerState.processingState == ProcessingState.completed) {
          if (state.currentlyPlayingVoiceId == voiceId) {
            stopVoicePreview();
          }
        }
      });
    } catch (e) {
      debugPrint('Error playing user voice preview: $e');
      state = state.copyWith(
        currentlyPlayingVoiceId: () => null,
        errorMessage: () => 'Failed to play preview: $e',
      );
      if (state.audioPlayer.playing) {
        await state.audioPlayer.stop();
      }
      _playerStateSubscription?.cancel();
      _playerStateSubscription = null;
    }
  }

  // Method to stop voice preview
  Future<void> stopVoicePreview() async {
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null;

    if (state.audioPlayer.playing) {
      await state.audioPlayer.stop();
    }

    if (state.currentlyPlayingVoiceId != null) {
      state = state.copyWith(currentlyPlayingVoiceId: () => null);
    }
  }

  // Method to add a voice to the library (local DB only for user voices)
  Future<void> addVoiceToLibrary(Voice voice) async {
    try {
      // User voices are already 'in their library' on ElevenLabs side.
      // We just need to track them locally if desired (e.g., for quick access/favorites).
      final voiceWithTimestamp = voice.copyWith(
        isAddedToLibrary: true,
        addedAt: DateTime.now(),
      );

      await _databaseHelper.insertVoice(voiceWithTimestamp);

      final voices = List<Voice>.from(state.voices);
      final index = voices.indexWhere((v) => v.id == voice.id);

      if (index != -1) {
        voices[index] = voiceWithTimestamp;
        state = state.copyWith(voices: voices);
      }
    } catch (e) {
      debugPrint('Error adding user voice to local library: $e');
      rethrow;
    }
  }

  // Method to remove a voice from the library (local DB only)
  Future<void> removeVoiceFromLibrary(String voiceId) async {
    try {
      await _databaseHelper.removeVoice(voiceId);

      final voices = List<Voice>.from(state.voices);
      final index = voices.indexWhere((v) => v.id == voiceId);

      if (index != -1) {
        voices[index] = voices[index].copyWith(
          isAddedToLibrary: false,
          addedAt: null,
        );
        state = state.copyWith(voices: voices);
      }
    } catch (e) {
      debugPrint('Error removing user voice from local library: $e');
      rethrow;
    }
  }
}

// Provider definitions (reuse existing ones if appropriate)
// Define necessary providers locally
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper(); // Use the factory constructor
});

final elevenLabsServiceProvider = Provider<ElevenlabsApiService>((ref) {
  // If ElevenlabsApiService needs dependencies (like API key), fetch them here
  // For now, assuming a simple constructor or singleton
  return ElevenlabsApiService();
});
// Example using providers defined in shared_voices_provider.dart
final userVoicesProvider =
    StateNotifierProvider<UserVoicesNotifier, UserVoicesData>((ref) {
      final elevenLabsService = ref.watch(elevenLabsServiceProvider);
      final databaseHelper = ref.watch(databaseHelperProvider);
      final notifier = UserVoicesNotifier(elevenLabsService, databaseHelper);
      notifier.loadUserVoices(); // Initial load
      return notifier;
    });
