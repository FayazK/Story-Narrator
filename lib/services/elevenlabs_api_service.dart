import 'package:dio/dio.dart';

class ElevenlabsApiService {
  final Dio _dio = Dio();
  
  // Base URL for ElevenLabs API
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  // Validate the API key by attempting to get user information
  Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/user',
        options: Options(
          headers: {'xi-api-key': apiKey},
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
}
