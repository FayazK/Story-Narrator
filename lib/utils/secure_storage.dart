import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage manager for API keys and app settings
/// Uses SharedPreferences with simple encryption for API keys
class SecureStorageManager {
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _elevenlabsApiKeyKey = 'elevenlabs_api_key';
  static const String _selectedGeminiModelKey = 'selected_gemini_model';
  static const String _keyConfiguredKey = 'key_configured';
  
  // Simple encryption/obfuscation for API keys (not truly secure but better than plaintext)
  static String _encrypt(String text) {
    // Use base64 encoding instead of Caesar cipher to handle special characters better
    return base64Encode(utf8.encode(text));
  }
  
  // Decrypt the encrypted text
  static String _decrypt(String text) {
    try {
      return utf8.decode(base64Decode(text));
    } catch (e) {
      // Fallback for any decoding errors
      return '';
    }
  }
  
  // Save Gemini API key
  static Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, _encrypt(apiKey));
    await prefs.setBool('${_keyConfiguredKey}_gemini', true);
  }
  
  // Get Gemini API key
  static Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_geminiApiKeyKey);
    if (encrypted == null) return null;
    return _decrypt(encrypted);
  }
  
  // Check if Gemini API key is configured
  static Future<bool> isGeminiKeyConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_keyConfiguredKey}_gemini') ?? false;
  }
  
  // Save ElevenLabs API key
  static Future<void> saveElevenlabsApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_elevenlabsApiKeyKey, _encrypt(apiKey));
    await prefs.setBool('${_keyConfiguredKey}_elevenlabs', true);
  }
  
  // Get ElevenLabs API key
  static Future<String?> getElevenlabsApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_elevenlabsApiKeyKey);
    if (encrypted == null) return null;
    return _decrypt(encrypted);
  }
  
  // Check if ElevenLabs API key is configured
  static Future<bool> isElevenlabsKeyConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_keyConfiguredKey}_elevenlabs') ?? false;
  }
  
  // Save selected Gemini model using shared preferences
  static Future<void> saveSelectedGeminiModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedGeminiModelKey, modelName);
  }
  
  // Get selected Gemini model
  static Future<String?> getSelectedGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedGeminiModelKey);
  }
  
  // Clear all saved API keys (for logging out or resetting)
  static Future<void> clearAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
    await prefs.remove(_elevenlabsApiKeyKey);
    await prefs.remove(_selectedGeminiModelKey);
    await prefs.remove('${_keyConfiguredKey}_gemini');
    await prefs.remove('${_keyConfiguredKey}_elevenlabs');
  }
}
