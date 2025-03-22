import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageManager {
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _elevenlabsApiKeyKey = 'elevenlabs_api_key';
  static const String _selectedGeminiModelKey = 'selected_gemini_model';
  
  // Secure storage for API keys
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  // Save Gemini API key securely
  static Future<void> saveGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _geminiApiKeyKey, value: apiKey);
  }
  
  // Get Gemini API key
  static Future<String?> getGeminiApiKey() async {
    return await _secureStorage.read(key: _geminiApiKeyKey);
  }
  
  // Save ElevenLabs API key securely
  static Future<void> saveElevenlabsApiKey(String apiKey) async {
    await _secureStorage.write(key: _elevenlabsApiKeyKey, value: apiKey);
  }
  
  // Get ElevenLabs API key
  static Future<String?> getElevenlabsApiKey() async {
    return await _secureStorage.read(key: _elevenlabsApiKeyKey);
  }
  
  // Save selected Gemini model using shared preferences (not sensitive)
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
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedGeminiModelKey);
  }
}
