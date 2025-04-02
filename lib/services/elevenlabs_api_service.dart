import 'package:dio/dio.dart';
import '../models/voice.dart';

class ElevenlabsApiService {
  final Dio _dio = Dio();
  
  // Base URL for ElevenLabs API
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Validate the API key by attempting to get models list
  Future<bool> validateApiKey(String apiKey) async {
    try {
      // Use the getModels method to verify the API key
      final models = await getModels(apiKey);
      return models != null;
    } catch (e) {
      return false;
    }
  }
  
  // Get available models from ElevenLabs
  Future<List<Map<String, dynamic>>?> getModels(String apiKey) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/models',
        options: Options(
          headers: {
            'xi-api-key': apiKey,
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
      return null;
    }
  }
  
  // Get user account information
  Future<Map<String, dynamic>?> getUserInfo(String apiKey) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/user',
        options: Options(
          headers: {'xi-api-key': apiKey},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get subscription information
  Future<Map<String, dynamic>?> getSubscriptionInfo(String apiKey) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/user/subscription',
        options: Options(
          headers: {'xi-api-key': apiKey},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get shared voices from ElevenLabs
  Future<List<Voice>?> getSharedVoices(String apiKey, {
    int pageSize = 30,
    int page = 1,
    String? category,
    String? gender,
    String? search,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {
        'page_size': pageSize,
        'page': page,
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
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> voicesData = response.data['voices'] ?? [];
        return voicesData.map((voice) => Voice.fromJson(voice)).toList();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get voice settings for a particular voice
  Future<Map<String, dynamic>?> getVoiceSettings(String apiKey, String voiceId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/voices/$voiceId/settings',
        options: Options(
          headers: {
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get audio preview for a voice
  Future<String?> getVoiceAudioUrl(String apiKey, String voiceId, String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/voices/$voiceId/stream',
        options: Options(
          headers: {
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
            'Accept': 'audio/mpeg',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          }
        },
      );
      
      if (response.statusCode == 200) {
        // Convert the binary data to an audio file
        // This would typically be handled by saving to a temporary file
        // and returning the file path or a data URI
        final bytes = response.data as List<int>;
        final base64 = 'data:audio/mpeg;base64,${String.fromCharCodes(bytes)}';
        return base64;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Add a shared voice to user library
  Future<bool> addSharedVoiceToLibrary(String apiKey, String voiceId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/voices/add',
        options: Options(
          headers: {
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {'voice_id': voiceId},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
