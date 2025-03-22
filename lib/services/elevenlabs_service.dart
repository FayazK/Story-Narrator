// lib/services/elevenlabs_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  String? _apiKey;

  // Voice IDs for different character types
  static const Map<String, String> _voiceProfiles = {
    'male_elderly': 'ErXwobaYiN019PkySvjV', // Antoni - warm, grandfatherly
    'male_young': 'MF3mGyEYCl7XYWbV9V6O', // Elli - young male
    'female_young': 'EXAVITQu4vr4xnSDxMaL', // Bella - young female
    'female_elderly': 'pNInz6obpgDQGcFmaJgB', // Grace - elderly female
    'narrator': 'XB0fDUnXU5powFXDhCwa'  // default narrator voice
  };

  /// Initialize the service by fetching the API key from storage
  Future<void> initialize() async {
    _apiKey = await SecureStorageManager.getElevenlabsApiKey();
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('ElevenLabs API key not found. Please add it in the settings.');
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

  /// Generate a voiceover from text using ElevenLabs API
  Future<File> generateVoiceover({
    required String text,
    required String outputPath,
    String? gender,
    String? voiceDescription,
    String? voiceId,
  }) async {
    // Ensure API key is loaded
    if (_apiKey == null || _apiKey!.isEmpty) {
      await initialize();
    }

    // Use provided voiceId or determine based on description
    final String finalVoiceId = voiceId ?? getVoiceId(gender, voiceDescription);

    final uri = Uri.parse('$_baseUrl/text-to-speech/$finalVoiceId/stream');

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'audio/mpeg',
        'xi-api-key': _apiKey!,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate voiceover: ${response.body}');
    }

    // Save the audio to file
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(response.bodyBytes);

    return outputFile;
  }

  /// Get available voices from ElevenLabs
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    // Ensure API key is loaded
    if (_apiKey == null || _apiKey!.isEmpty) {
      await initialize();
    }

    final uri = Uri.parse('$_baseUrl/voices');

    final response = await http.get(
      uri,
      headers: {
        'xi-api-key': _apiKey!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch voices: ${response.body}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['voices']);
  }

  /// Process voice parameters based on language and Urdu flavor
  Map<String, dynamic> getVoiceParameters(String language, bool urduFlavor) {
    // Adjust voice parameters based on language
    double stability = 0.5;
    double similarityBoost = 0.75;
    String modelId = 'eleven_multilingual_v2';

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