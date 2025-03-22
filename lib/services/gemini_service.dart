// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/story_service.dart';
import '../models/story.dart';
import '../models/script.dart';
import '../utils/api_storage.dart';

class GeminiService {
  final StoryService _storyService = StoryService();
  
  /// Generate a story using the Gemini API
  Future<String> generateStory(String systemPrompt, String userMessage) async {
    try {
      // Get API key from storage
      final apiKey = await ApiKeyStorage.getGeminiApiKey();
      
      // Check if API key is available
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not found. Please add your API key in the settings.');
      }
      
      // Get selected model or use default
      String modelName = await ApiKeyStorage.getSelectedGeminiModel() ?? 'gemini-1.5-pro';
      
      // Initialize the Gemini API with system instructions
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
      );
      
      // Send the user message and get response
      final response = await model.generateContent([Content.text(userMessage)]);
      
      // Extract the story text from the response
      final storyText = response.text;
      
      if (storyText == null || storyText.isEmpty) {
        throw Exception('Generated story is empty');
      }
      
      return storyText;
    } catch (e) {
      print('Error generating story: $e');
      rethrow;
    }
  }

  /// Process XML directly from Gemini and store it in the database
  Future<Story?> processGeminiStoryXml(String xmlString) async {
    try {
      // Import the story XML
      final storyId = await _storyService.importStoryFromXml(xmlString);

      // Retrieve the full story object with all related data
      return await _storyService.getStoryById(storyId);
    } catch (e) {
      print('Error processing Gemini XML: $e');
      return null;
    }
  }

  /// Generate voiceovers for specific scripts in a story
  Future<List<Script>> generateVoiceoversForScripts(Story story, List<Script> scripts) async {
    final StoryService storyService = _storyService;
    final List<Script> processedScripts = [];

    try {
      for (var script in scripts) {
        if (script.id != null) {
          if (script.isNarrator) {
            // Narrator script
            await storyService.generateScriptVoiceover(script);
          } else {
            // Character script - find the associated character
            final character = story.characters.firstWhere(
                  (c) => c.id == script.characterId,
              orElse: () => throw Exception('Character not found for script: ${script.id}'),
            );

            await storyService.generateScriptVoiceover(script, character: character);
          }

          processedScripts.add(script);
        }
      }

      return processedScripts;
    } catch (e) {
      print('Error generating voiceovers for scripts: $e');
      return processedScripts; // Return any successfully processed scripts
    }
  }
}