// lib/services/gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/story_service.dart';
import '../models/story.dart';
import '../models/script.dart';
import '../utils/secure_storage.dart';
import '../database/database_helper.dart';
import '../utils/helpers/xml_parser_util.dart';

class GeminiService {
  final StoryService _storyService = StoryService();

  /// Clean the AI response to extract only the XML part
  String _cleanAiResponse(String aiResponse) {
    // Import the standardized XML parser
    return XmlParserUtil.extractXmlFromText(aiResponse);
  }

  /// Generate a story using the Gemini API and optionally save it to the database
  Future<String> generateStory(
    String systemPrompt,
    String userMessage, {
    int? storyId,
  }) async {
    try {
      // Get API key from storage
      final apiKey = await SecureStorageManager.getGeminiApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not found. Please add your API key in the settings.',
        );
      }

      // Trim API key to remove any leading/trailing spaces
      final trimmedApiKey = apiKey.trim();

      // Get selected model or use default
      String modelName = 'gemini-2.0-flash';

      // Initialize the Gemini API with system instructions
      final model = GenerativeModel(
        model: modelName,
        apiKey: trimmedApiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      // Send the user message and get response
      final response = await model.generateContent([Content.text(userMessage)]);

      // Extract the story text from the response
      final storyText = response.text;

      if (storyText == null || storyText.isEmpty) {
        throw Exception('Generated story is empty');
      }

      // Extract just the XML part from the response
      final String cleanedResponse = _cleanAiResponse(storyText);

      // If a storyId is provided, save the AI response to the database
      if (storyId != null) {
        final dbHelper = DatabaseHelper();
        // Save the cleaned XML response
        await dbHelper.updateStoryAiResponse(storyId, cleanedResponse);
      }

      return cleanedResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> generateImagePrompts(
    String systemPrompt,
    String userMessage, {
    int? storyId,
  }) async {
    try {
      // Get API key from storage
      final apiKey = await SecureStorageManager.getGeminiApiKey();

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not found. Please add your API key in the settings.',
        );
      }

      // Trim API key to remove any leading/trailing spaces
      final trimmedApiKey = apiKey.trim();

      // Get selected model or use default
      String modelName = 'gemini-2.0-flash';

      // Initialize the Gemini API with system instructions
      final model = GenerativeModel(
        model: modelName,
        apiKey: trimmedApiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      // Send the user message and get response
      final response = await model.generateContent([Content.text(userMessage)]);

      // Extract the story text from the response
      final promptText = response.text;

      if (promptText == null || promptText.isEmpty) {
        throw Exception('Generated Prompts is empty');
      }

      return promptText;
    } catch (e) {
      rethrow;
    }
  } // generateImagePrompts

  /// Update the AI response for an existing story
  Future<int> updateAiResponse(int storyId, String aiResponse) async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.updateStoryAiResponse(storyId, aiResponse);
  }

  /// Process XML directly from Gemini and store it in the database
  Future<Story?> processGeminiStoryXml(String xmlString) async {
    try {
      // Extract just the XML part
      final cleanedXml = _cleanAiResponse(xmlString);

      // Import the story XML
      final storyId = await _storyService.importStoryFromXml(cleanedXml);

      // Retrieve the full story object with all related data
      return await _storyService.getStoryById(storyId);
    } catch (e) {
      return null;
    }
  }

  /// Generate voiceovers for specific scripts in a story
  Future<List<Script>> generateVoiceoversForScripts(
    Story story,
    List<Script> scripts,
  ) async {
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
              orElse:
                  () =>
                      throw Exception(
                        'Character not found for script: ${script.id}',
                      ),
            );

            await storyService.generateScriptVoiceover(
              script,
              character: character,
            );
          }

          processedScripts.add(script);
        }
      }

      return processedScripts;
    } catch (e) {
      return processedScripts; // Return any successfully processed scripts
    }
  }
}
