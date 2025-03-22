import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';

class GeminiApiService {
  // Models available in Gemini
  static const List<String> _availableModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
    'gemini-2.0-pro'
  ];
  
  // Validate the API key by attempting to initialize a model and make a simple request
  Future<bool> validateApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      return false;
    }
    
    // Maximum number of retry attempts
    const maxRetries = 2;
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        // Initialize the model with the API key to test if it's valid
        final model = GenerativeModel(
          model: 'gemini-1.5-flash', // Use a more stable model for validation
          apiKey: apiKey,
        );
        
        // Simple prompt to test API key validity
        final content = [Content.text('test')];
        
        // Add timeout using the Future API
        await model.generateContent(content)
          .timeout(const Duration(seconds: 5), onTimeout: () {
            throw TimeoutException('API request timed out');
          });
        
        print('API key validation successful');
        return true; // If we get here, the API key is valid
      } catch (e) {
        print('API key validation attempt ${retryCount + 1} failed: $e');
        retryCount++;
        if (retryCount <= maxRetries) {
          // Wait before retrying
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }
    
    return false; // All retry attempts failed
  }
  
  // Get available Gemini models (hardcoded since the package doesn't support listing)
  Future<List<String>> getAvailableModels(String apiKey) async {
    // Simply return the predefined list of models
    // No API call needed since we can't list models with the package
    return _availableModels;
  }
  
  // Get default Gemini model
  String getDefaultModel() {
    return 'gemini-2.0-pro'; // Return the recommended default model
  }
}