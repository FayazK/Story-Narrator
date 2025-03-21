// lib/services/gemini_service.dart
import '../services/story_service.dart';
import '../models/story.dart';
import '../models/script.dart';

class GeminiService {
  final StoryService _storyService = StoryService();

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