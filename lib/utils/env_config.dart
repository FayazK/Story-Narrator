import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Utility class for accessing environment variables
class EnvConfig {
  /// Get the Gemini API key from environment variables
  /// Returns null if not found
  static String? getGeminiApiKey() {
    return dotenv.env['GEMINI_API_KEY'];
  }
  
  /// Get the ElevenLabs API key from environment variables
  /// Returns null if not found
  static String? getElevenlabsApiKey() {
    return dotenv.env['ELEVENLABS_API_KEY'];
  }
}