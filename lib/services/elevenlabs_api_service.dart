// lib/services/elevenlabs_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/voice.dart';
import '../utils/secure_storage.dart';

/// A comprehensive service for interacting with the ElevenLabs API.
/// Handles API key management, user information, voice management, and text-to-speech operations.
class ElevenlabsApiService {
  //---------------------------------------------------------------------
  // SECTION 1: Class Definition and Constants
  //---------------------------------------------------------------------
  
  /// HTTP client for API requests
  final Dio _dio = Dio();
  
  /// Base URL for ElevenLabs API
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  /// Default model for text-to-speech
  static const String _defaultModel = 'eleven_multilingual_v2';
  
  /// Voice profiles for different character types
  static const Map<String, String> _voiceProfiles = {
    'male_elderly': 'ErXwobaYiN019PkySvjV', // Antoni - warm, grandfatherly
    'male_young': 'MF3mGyEYCl7XYWbV9V6O',   // Elli - young male
    'female_young': 'EXAVITQu4vr4xnSDxMaL',  // Bella - young female
    'female_elderly': 'pNInz6obpgDQGcFmaJgB', // Grace - elderly female
    'narrator': 'XB0fDUnXU5powFXDhCwa'       // default narrator voice
  };
  
  /// Default voice settings
  static const Map<String, dynamic> _defaultVoiceSettings = {
    'stability': 0.5,
    'similarity_boost': 0.75,
  };

  //---------------------------------------------------------------------
  // SECTION 2: API Key Management
  //---------------------------------------------------------------------
  
  /// Stored API key for reuse
  String? _apiKey;
  
  /// Initialize the service by fetching the API key from storage
  Future<void> initialize() async {
    _apiKey = await SecureStorageManager.getElevenlabsApiKey();
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('ElevenLabs API key not found. Please add it in the settings.');
    }
  }
  
  /// Get the API key, either from parameter or stored key
  Future<String> _getApiKey(String? apiKey) async {
    // Use provided key, or fetch stored key if not initialized
    if (apiKey != null && apiKey.isNotEmpty) {
      return apiKey;
    }
    
    if (_apiKey == null || _apiKey!.isEmpty) {
      await initialize();
    }
    
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('ElevenLabs API key not found. Please add it in the settings.');
    }
    
    return _apiKey!;
  }
  
  /// Validate the API key by attempting to get models list
  Future<bool> validateApiKey(String apiKey) async {
    try {
      // Use the getModels method to verify the API key
      final models = await getModels(apiKey);
      return models != null;
    } catch (e) {
      debugPrint('Error validating API key: $e');
      return false;
    }
  }

  //---------------------------------------------------------------------
  // SECTION 3: User and Account Methods
  //---------------------------------------------------------------------
  
  /// Get user account information
  Future<Map<String, dynamic>?> getUserInfo([String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.get(
        '$_baseUrl/user',
        options: Options(
          headers: {'xi-api-key': key},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user info: $e');
      return null;
    }
  }
  
  /// Get subscription information
  Future<Map<String, dynamic>?> getSubscriptionInfo([String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.get(
        '$_baseUrl/user/subscription',
        options: Options(
          headers: {'xi-api-key': key},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting subscription info: $e');
      return null;
    }
  }

  //---------------------------------------------------------------------
  // SECTION 4: Model and Voice Discovery Methods
  //---------------------------------------------------------------------
  
  /// Get available models from ElevenLabs
  Future<List<Map<String, dynamic>>?> getModels([String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.get(
        '$_baseUrl/models',
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> modelsData = response.data;
        return modelsData.map((model) => model as Map<String, dynamic>).toList();
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting models: $e');
      return null;
    }
  }
  
  /// Get available voices from ElevenLabs
  Future<List<Map<String, dynamic>>?> getAvailableVoices([String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.get(
        '$_baseUrl/voices',
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data['voices']);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting available voices: $e');
      return null;
    }
  }
  
  /// Get shared voices from ElevenLabs with filtering options
  Future<List<Voice>?> getSharedVoices({
    String? apiKey,
    int pageSize = 30,
    int page = 1,
    String? category,
    String? gender,
    String? search,
    bool featured = false,
    bool readerAppEnabled = true,
  }) async {
    try {
      final key = await _getApiKey(apiKey);
      
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page_size': pageSize,
        'featured': featured,
        'reader_app_enabled': readerAppEnabled,
      };
      
      // Add optional filters if present
      if (category != null) queryParams['category'] = category;
      if (gender != null) queryParams['gender'] = gender;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final response = await _dio.get(
        '$_baseUrl/shared-voices',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> voicesData = responseData['voices'] ?? [];
        return voicesData.map((voice) => Voice.fromJson(voice)).toList();
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching shared voices: $e');
      return null;
    }
  }
  
  /// Get the best matching voice ID based on the voice description
  String getVoiceId(String? gender, String? voiceDescription) {
    if (voiceDescription == null || voiceDescription.isEmpty) {
      return _voiceProfiles['narrator']!;
    }

    // Simple matching logic based on description keywords
    final description = voiceDescription.toLowerCase();
    final genderStr = gender?.toLowerCase() ?? '';

    if (description.contains('grandfatherly') ||
        description.contains('wisdom') ||
        description.contains('elderly') && genderStr.contains('male')) {
      return _voiceProfiles['male_elderly']!;
    } else if (description.contains('young') && genderStr.contains('male') ||
        description.contains('boy') ||
        description.contains('eager')) {
      return _voiceProfiles['male_young']!;
    } else if (description.contains('young') && genderStr.contains('female') ||
        description.contains('girl')) {
      return _voiceProfiles['female_young']!;
    } else if (description.contains('elderly') && genderStr.contains('female') ||
        description.contains('grandmother')) {
      return _voiceProfiles['female_elderly']!;
    }

    // Default narrator voice
    return _voiceProfiles['narrator']!;
  }

  //---------------------------------------------------------------------
  // SECTION 5: Voice Manipulation Methods
  //---------------------------------------------------------------------
  
  /// Get voice settings for a particular voice
  Future<Map<String, dynamic>?> getVoiceSettings(String voiceId, [String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.get(
        '$_baseUrl/voices/$voiceId/settings',
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting voice settings: $e');
      return null;
    }
  }
  
  /// Get audio preview for a voice
  Future<String?> getVoiceAudioUrl(String voiceId, String text, [String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.post(
        '$_baseUrl/voices/$voiceId/stream',
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': _defaultModel,
          'voice_settings': _defaultVoiceSettings,
        },
      );
      
      if (response.statusCode == 200) {
        // Convert the binary data to an audio file
        final bytes = response.data as List<int>;
        final base64 = 'data:audio/mpeg;base64,${base64Encode(bytes)}';
        return base64;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting voice audio: $e');
      return null;
    }
  }
  
  /// Get a voice preview directly from the preview URL
  Future<String?> getVoicePreviewAudio(String voiceId, String previewText, [String? apiKey]) async {
    try {
      // If the voice has a preview URL, we should use that directly
      // Otherwise, we need to generate a preview
      
      // Here, we'll just delegate to getVoiceAudioUrl since the preview generation logic
      // would be more complex and require fetching the voice details first
      return await getVoiceAudioUrl(voiceId, previewText, apiKey);
    } catch (e) {
      debugPrint('Error getting voice preview: $e');
      return null;
    }
  }
  
  /// Add a shared voice to user library
  Future<bool> addSharedVoiceToLibrary(String voiceId, [String? apiKey]) async {
    try {
      final key = await _getApiKey(apiKey);
      
      final response = await _dio.post(
        '$_baseUrl/voices/add',
        options: Options(
          headers: {
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
        ),
        data: {'voice_id': voiceId},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error adding voice to library: $e');
      return false;
    }
  }

  //---------------------------------------------------------------------
  // SECTION 6: Text-to-Speech Methods
  //---------------------------------------------------------------------
  
  /// Generate a voiceover from text using ElevenLabs API
  Future<File> generateVoiceover({
    required String text,
    required String outputPath,
    String? gender,
    String? voiceDescription,
    String? voiceId,
    String? apiKey,
    String? language,
    bool urduFlavor = false,
    String? modelId,
  }) async {
    try {
      final key = await _getApiKey(apiKey);
      
      // Use provided voiceId or determine based on description
      final String finalVoiceId = voiceId ?? getVoiceId(gender, voiceDescription);
      
      // Get voice parameters based on language
      final voiceParams = getVoiceParameters(language ?? 'english', urduFlavor);
      
      final response = await _dio.post(
        '$_baseUrl/text-to-speech/$finalVoiceId/stream',
        options: Options(
          headers: {
            'Accept': 'audio/mpeg',
            'xi-api-key': key,
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': modelId ?? voiceParams['model_id'],
          'voice_settings': voiceParams['voice_settings'],
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to generate voiceover: ${response.statusMessage}');
      }
      
      // Save the audio to file
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(response.data);
      
      return outputFile;
    } catch (e) {
      debugPrint('Error generating voiceover: $e');
      rethrow;
    }
  }
  
  /// Process voice parameters based on language and Urdu flavor
  Map<String, dynamic> getVoiceParameters(String language, bool urduFlavor) {
    // Adjust voice parameters based on language
    double stability = 0.5;
    double similarityBoost = 0.75;
    String modelId = _defaultModel;
    
    // Adjust parameters based on language
    if (language.toLowerCase() == 'hindi' && urduFlavor) {
      // Adjust parameters for Hindi with Urdu flavor
      stability = 0.4;  // Lower stability for more expression
      similarityBoost = 0.8;  // Higher similarity for stronger accent
    } else if (language.toLowerCase() == 'hindi') {
      // Adjust parameters for standard Hindi
      stability = 0.45;
      similarityBoost = 0.7;
    }
    
    return {
      'model_id': modelId,
      'voice_settings': {
        'stability': stability,
        'similarity_boost': similarityBoost,
      }
    };
  }
}
