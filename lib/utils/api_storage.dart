import 'package:shared_preferences/shared_preferences.dart';

/// Simple storage utility for API keys using SharedPreferences
/// 
/// NOTE: This is a simplified solution. In a production app, you would want to use
/// more secure methods like flutter_secure_storage (once properly set up)
class ApiKeyStorage {
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _elevenlabsApiKeyKey = 'elevenlabs_api_key';
  static const String _selectedGeminiModelKey = 'selected_gemini_model';
  
  // Save Gemini API key
  static Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }
  
  // Get Gemini API key
  static Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }
  
  // Save ElevenLabs API key
  static Future<void> saveElevenlabsApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_elevenlabsApiKeyKey, apiKey);
  }
  
  // Get ElevenLabs API key
  static Future<String?> getElevenlabsApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_elevenlabsApiKeyKey);
  }
  
  // Save selected Gemini model
  static Future<void> saveSelectedGeminiModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedGeminiModelKey, modelName);
  }
  
  // Get selected Gemini model
  static Future<String?> getSelectedGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedGeminiModelKey);
  }
  
  // Clear all saved API keys
  static Future<void> clearAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
    await prefs.remove(_elevenlabsApiKeyKey);
    await prefs.remove(_selectedGeminiModelKey);
  }
}