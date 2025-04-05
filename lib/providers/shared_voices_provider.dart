// lib/providers/shared_voices_provider.dart
import 'dart:async'; // Added for StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/elevenlabs_api_service.dart';
import '../database/database_helper.dart';
import '../models/voice.dart';

// States for the shared voices feature
enum SharedVoicesState { initial, loading, loaded, error }

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
    // Allow explicitly setting errorMessage to null
    ValueGetter<String?>? errorMessage,
    // Allow explicitly setting currentlyPlayingVoiceId to null
    ValueGetter<String?>? currentlyPlayingVoiceId,
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
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      currentlyPlayingVoiceId:
          currentlyPlayingVoiceId != null
              ? currentlyPlayingVoiceId()
              : this.currentlyPlayingVoiceId,
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
  final ElevenlabsApiService _elevenLabsService;
  final DatabaseHelper _databaseHelper;
  StreamSubscription<PlayerState>?
  _playerStateSubscription; // Added to manage listener

  SharedVoicesNotifier(this._elevenLabsService, this._databaseHelper)
    : super(
        SharedVoicesData(
          voices: [],
          state: SharedVoicesState.initial,
          audioPlayer: AudioPlayer(),
        ),
      );

  @override
  void dispose() {
    _playerStateSubscription?.cancel(); // Cancel listener on dispose
    state.audioPlayer.dispose();
    super.dispose();
  }

  // Method to load shared voices
  Future<void> loadSharedVoices({
    bool refresh = false,
    int pageSize = 30,
  }) async {
    // Avoid concurrent loads
    if (state.state == SharedVoicesState.loading && !refresh) return;

    try {
      // Update state to loading
      state = state.copyWith(
        state: SharedVoicesState.loading,
        errorMessage: () => null, // Clear previous error
      );

      // If refreshing, reset page to 1
      final currentPage = refresh ? 1 : state.currentPage;

      // Fetch voices from API
      final fetchedVoices = await _elevenLabsService.getSharedVoices(
        pageSize: pageSize,
        page: currentPage,
        category: state.categoryFilter,
        gender: state.genderFilter,
        search: state.searchQuery,
      );

      // Handle potential null response from API
      if (fetchedVoices == null) {
        throw Exception('API returned null voice list');
      }

      // Check which voices are already in the database
      final List<Voice> enhancedVoices = [];
      for (var voice in fetchedVoices) {
        // Iterate over the non-null list
        // Assuming voice.id is non-nullable based on Voice model usage elsewhere
        final isInLibrary = await _databaseHelper.isVoiceInLibrary(voice.id);
        enhancedVoices.add(voice.copyWith(isAddedToLibrary: isInLibrary));
      }

      // Update state with fetched voices
      state = state.copyWith(
        voices: refresh ? enhancedVoices : [...state.voices, ...enhancedVoices],
        state: SharedVoicesState.loaded,
        hasMoreVoices:
            fetchedVoices.length >= pageSize, // Use non-null list here
        currentPage: currentPage + 1,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        state: SharedVoicesState.error,
        errorMessage: () => 'Failed to load shared voices: $e',
        // If it was a refresh, keep existing voices, otherwise clear potentially partial list
        voices: refresh ? state.voices : [],
        hasMoreVoices: false, // Assume no more voices on error
      );
    }
  }

  // Method to load more voices (pagination)
  Future<void> loadMoreVoices() async {
    if (state.state == SharedVoicesState.loading || !state.hasMoreVoices)
      return;
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
    // Update filter state immediately for responsiveness (optional)
    state = state.copyWith(
      searchQuery: searchQuery,
      categoryFilter: categoryFilter,
      genderFilter: genderFilter,
      currentPage: 1, // Reset page when filters change
      hasMoreVoices:
          false, // Assume new filter might have fewer results initially
      voices: [], // Clear existing voices for new filter results
      state: SharedVoicesState.loading, // Show loading indicator immediately
    );

    // Refresh voices with new filters
    await refreshVoices();
  }

  // Method to play voice preview
  Future<void> playVoicePreview(String voiceId, String previewText) async {
    // Stop current playback and cancel previous listener
    await stopVoicePreview();

    try {
      // Find the voice in the list
      final voice = state.voices.firstWhere((v) => v.id == voiceId);

      // Update state to show which voice is playing
      state = state.copyWith(
        currentlyPlayingVoiceId: () => voiceId,
        errorMessage: () => null, // Clear error on new playback attempt
      );

      String? urlToPlay;

      // First try to use the previewUrl directly if available
      if (voice.previewUrl != null && voice.previewUrl!.isNotEmpty) {
        urlToPlay = voice.previewUrl!;
      } else {
        // If no previewUrl is available, generate one
        final generatedUrl = await _elevenLabsService.getVoicePreviewAudio(
          voiceId,
          previewText,
        );

        if (generatedUrl == null) {
          throw Exception('Failed to get preview audio URL');
        }
        urlToPlay = generatedUrl;
      }

      // Ensure URL is not null before proceeding
      if (urlToPlay == null) {
        throw Exception('Audio URL is null');
      }

      // Play the audio
      await state.audioPlayer.setUrl(urlToPlay);
      await state.audioPlayer.play();

      // Cancel any previous listener before starting new playback (redundant check, but safe)
      await _playerStateSubscription?.cancel();
      _playerStateSubscription = null; // Clear reference

      // Set up listener for when audio finishes
      _playerStateSubscription = state.audioPlayer.playerStateStream.listen((
        playerState,
      ) {
        if (playerState.processingState == ProcessingState.completed) {
          // Check if it's still the currently playing voice before stopping
          if (state.currentlyPlayingVoiceId == voiceId) {
            stopVoicePreview();
          }
        }
        // Note: Runtime playback errors (after successful start) might need
        // more specific handling if required, potentially via other streams
        // or observing unexpected state transitions (e.g., back to idle).
        // The primary error handling is in the surrounding try-catch block.
      });
    } catch (e) {
      debugPrint('Error playing voice preview: $e');
      // Update state with error message
      state = state.copyWith(
        currentlyPlayingVoiceId: () => null, // Clear playing ID on error
        errorMessage: () => 'Failed to play preview: $e',
      );
      // Ensure player is stopped if an error occurred before playback started
      if (state.audioPlayer.playing) {
        await state.audioPlayer.stop();
      }
      _playerStateSubscription?.cancel(); // Clean up listener on error too
      _playerStateSubscription = null;
    }
  }

  // Method to stop voice preview
  Future<void> stopVoicePreview() async {
    // Cancel listener first
    await _playerStateSubscription?.cancel();
    _playerStateSubscription = null; // Clear reference

    // Stop playback only if it's actually playing
    if (state.audioPlayer.playing) {
      await state.audioPlayer.stop();
    }

    // Only update state if a voice ID was set, to avoid unnecessary rebuilds
    if (state.currentlyPlayingVoiceId != null) {
      state = state.copyWith(currentlyPlayingVoiceId: () => null);
    }
  }

  // Method to add a voice to the library
  Future<void> addVoiceToLibrary(Voice voice) async {
    try {
      // Add to ElevenLabs library first
      final success = await _elevenLabsService.addSharedVoiceToLibrary(
        voice.id,
      );

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
      final voices = List<Voice>.from(state.voices); // Create mutable copy
      final index = voices.indexWhere((v) => v.id == voice.id);

      if (index != -1) {
        voices[index] = voiceWithTimestamp; // Update the item
        state = state.copyWith(
          voices: voices, // Assign the updated list
        );
      }
    } catch (e) {
      debugPrint('Error adding voice to library: $e');
      // Optionally update state with an error message for the UI
      // state = state.copyWith(errorMessage: () => 'Failed to add voice: $e');
      rethrow; // Rethrow to allow UI to handle specific errors if needed
    }
  }

  // Method to remove a voice from the library
  Future<void> removeVoiceFromLibrary(String voiceId) async {
    try {
      // Remove from local database
      await _databaseHelper.removeVoice(voiceId);

      // Update voice in state
      final voices = List<Voice>.from(state.voices); // Create mutable copy
      final index = voices.indexWhere((v) => v.id == voiceId);

      if (index != -1) {
        // Update the specific voice instance
        voices[index] = voices[index].copyWith(
          isAddedToLibrary: false,
          addedAt: null,
        ); // Clear addedAt too
        state = state.copyWith(
          voices: voices, // Assign the updated list
        );
      }
    } catch (e) {
      debugPrint('Error removing voice from library: $e');
      // Optionally update state with an error message for the UI
      // state = state.copyWith(errorMessage: () => 'Failed to remove voice: $e');
      rethrow; // Rethrow to allow UI to handle specific errors if needed
    }
  }
}

// Provider definitions
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final elevenLabsServiceProvider = Provider<ElevenlabsApiService>((ref) {
  // Consider adding error handling or configuration here if needed
  return ElevenlabsApiService();
});

final sharedVoicesProvider =
    StateNotifierProvider<SharedVoicesNotifier, SharedVoicesData>((ref) {
      final elevenLabsService = ref.watch(elevenLabsServiceProvider);
      final databaseHelper = ref.watch(databaseHelperProvider);
      // Load initial voices when the provider is first created
      final notifier = SharedVoicesNotifier(elevenLabsService, databaseHelper);
      notifier.loadSharedVoices(); // Trigger initial load
      return notifier;
    });
