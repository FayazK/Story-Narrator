// lib/providers/shared_voices_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/elevenlabs_service.dart';
import '../database/database_helper.dart';
import '../models/voice.dart';

// States for the shared voices feature
enum SharedVoicesState {
  initial,
  loading,
  loaded,
  error,
}

// State class for shared voices
class SharedVoicesData {
  final List<Voice> voices;
  final SharedVoicesState state;
  final String? errorMessage;
  final String? currentlyPlayingVoiceId;
  final bool hasMoreVoices;
  final int currentPage;
  final String? searchQuery;
  final String? categoryFilter;
  final String? genderFilter;
  final AudioPlayer audioPlayer;

  SharedVoicesData({
    required this.voices,
    required this.state,
    this.errorMessage,
    this.currentlyPlayingVoiceId,
    this.hasMoreVoices = false,
    this.currentPage = 1,
    this.searchQuery,
    this.categoryFilter,
    this.genderFilter,
    required this.audioPlayer,
  });

  // Copy with method for immutability
  SharedVoicesData copyWith({
    List<Voice>? voices,
    SharedVoicesState? state,
    String? errorMessage,
    String? currentlyPlayingVoiceId,
    bool? hasMoreVoices,
    int? currentPage,
    String? searchQuery,
    String? categoryFilter,
    String? genderFilter,
    AudioPlayer? audioPlayer,
  }) {
    return SharedVoicesData(
      voices: voices ?? this.voices,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      currentlyPlayingVoiceId: currentlyPlayingVoiceId ?? this.currentlyPlayingVoiceId,
      hasMoreVoices: hasMoreVoices ?? this.hasMoreVoices,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      genderFilter: genderFilter ?? this.genderFilter,
      audioPlayer: audioPlayer ?? this.audioPlayer,
    );
  }
}

// Notifier class for shared voices
class SharedVoicesNotifier extends StateNotifier<SharedVoicesData> {
  final ElevenLabsService _elevenLabsService;
  final DatabaseHelper _databaseHelper;

  SharedVoicesNotifier(this._elevenLabsService, this._databaseHelper)
      : super(SharedVoicesData(
          voices: [],
          state: SharedVoicesState.initial,
          audioPlayer: AudioPlayer(),
        ));

  @override
  void dispose() {
    state.audioPlayer.dispose();
    super.dispose();
  }

  // Method to load shared voices
  Future<void> loadSharedVoices({
    bool refresh = false,
    int pageSize = 30,
  }) async {
    try {
      // Update state to loading
      state = state.copyWith(
        state: SharedVoicesState.loading,
        errorMessage: null,
      );

      // If refreshing, reset page to 1
      final currentPage = refresh ? 1 : state.currentPage;

      // Fetch voices from API
      final voices = await _elevenLabsService.getSharedVoices(
        pageSize: pageSize,
        page: currentPage,
        category: state.categoryFilter,
        gender: state.genderFilter,
        search: state.searchQuery,
      );

      // Check which voices are already in the database
      final List<Voice> enhancedVoices = [];
      for (var voice in voices) {
        final isInLibrary = await _databaseHelper.isVoiceInLibrary(voice.id);
        enhancedVoices.add(voice.copyWith(isAddedToLibrary: isInLibrary));
      }

      // Update state with fetched voices
      state = state.copyWith(
        voices: refresh ? enhancedVoices : [...state.voices, ...enhancedVoices],
        state: SharedVoicesState.loaded,
        hasMoreVoices: voices.length >= pageSize,
        currentPage: currentPage + 1,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        state: SharedVoicesState.error,
        errorMessage: 'Failed to load shared voices: $e',
      );
    }
  }

  // Method to load more voices (pagination)
  Future<void> loadMoreVoices() async {
    if (state.state == SharedVoicesState.loading || !state.hasMoreVoices) return;
    await loadSharedVoices(refresh: false);
  }

  // Method to refresh voices
  Future<void> refreshVoices() async {
    await loadSharedVoices(refresh: true);
  }

  // Method to filter voices
  Future<void> filterVoices({
    String? searchQuery,
    String? categoryFilter,
    String? genderFilter,
  }) async {
    // Update filter state
    state = state.copyWith(
      searchQuery: searchQuery,
      categoryFilter: categoryFilter,
      genderFilter: genderFilter,
    );
    
    // Refresh voices with new filters
    await refreshVoices();
  }

  // Method to play voice preview
  Future<void> playVoicePreview(String voiceId, String previewText) async {
    // Stop current playback if any
    if (state.currentlyPlayingVoiceId != null) {
      await state.audioPlayer.stop();
    }

    try {
      // Update state to show which voice is playing
      state = state.copyWith(
        currentlyPlayingVoiceId: voiceId,
      );

      // Get voice preview URL or generate one
      final audioUrl = await _elevenLabsService.getVoicePreviewAudio(voiceId, previewText);
      
      if (audioUrl == null) {
        throw Exception('Failed to get voice preview');
      }
      
      // If URL starts with data:, it's a base64 encoded audio
      if (audioUrl.startsWith('data:')) {
        // Extract base64 data
        final base64Data = audioUrl.split(',')[1];
        // Play audio from memory
        await state.audioPlayer.setAudioSource(
          AudioSource.uri(Uri.dataFromString(
            base64Data,
            mimeType: 'audio/mpeg',
            encoding: Encoding.getByName('base64'),
          )),
        );
      } else {
        // Play audio from URL
        await state.audioPlayer.setUrl(audioUrl);
      }
      
      await state.audioPlayer.play();
      
      // Set up listener for when audio finishes
      state.audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          stopVoicePreview();
        }
      });
    } catch (e) {
      debugPrint('Error playing voice preview: $e');
      state = state.copyWith(
        currentlyPlayingVoiceId: null,
      );
    }
  }

  // Method to stop voice preview
  Future<void> stopVoicePreview() async {
    if (state.currentlyPlayingVoiceId != null) {
      await state.audioPlayer.stop();
      state = state.copyWith(
        currentlyPlayingVoiceId: null,
      );
    }
  }

  // Method to add a voice to the library
  Future<void> addVoiceToLibrary(Voice voice) async {
    try {
      // Add to ElevenLabs library first
      final success = await _elevenLabsService.addSharedVoiceToLibrary(voice.id);
      
      if (!success) {
        throw Exception('Failed to add voice to ElevenLabs library');
      }
      
      // Add to local database
      final voiceWithTimestamp = voice.copyWith(
        isAddedToLibrary: true,
        addedAt: DateTime.now(),
      );
      
      await _databaseHelper.insertVoice(voiceWithTimestamp);
      
      // Update voice in state
      final voices = [...state.voices];
      final index = voices.indexWhere((v) => v.id == voice.id);
      
      if (index != -1) {
        voices[index] = voiceWithTimestamp;
        state = state.copyWith(
          voices: voices,
        );
      }
    } catch (e) {
      debugPrint('Error adding voice to library: $e');
      rethrow;
    }
  }

  // Method to remove a voice from the library
  Future<void> removeVoiceFromLibrary(String voiceId) async {
    try {
      // Remove from local database
      await _databaseHelper.removeVoice(voiceId);
      
      // Update voice in state
      final voices = [...state.voices];
      final index = voices.indexWhere((v) => v.id == voiceId);
      
      if (index != -1) {
        voices[index] = voices[index].copyWith(isAddedToLibrary: false);
        state = state.copyWith(
          voices: voices,
        );
      }
    } catch (e) {
      debugPrint('Error removing voice from library: $e');
      rethrow;
    }
  }
}

// Provider definitions
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  return ElevenLabsService();
});

final sharedVoicesProvider = StateNotifierProvider<SharedVoicesNotifier, SharedVoicesData>((ref) {
  final elevenLabsService = ref.watch(elevenLabsServiceProvider);
  final databaseHelper = ref.watch(databaseHelperProvider);
  return SharedVoicesNotifier(elevenLabsService, databaseHelper);
});