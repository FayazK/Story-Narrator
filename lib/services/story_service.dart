// lib/services/story_service.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../models/story.dart';
import '../models/script.dart';
import '../models/character.dart';
import '../utils/xml_parser.dart';
import '../utils/helpers/xml_parser_util.dart';
import '../utils/helpers/character_mapper_util.dart';
import 'elevenlabs_api_service.dart'; // Changed import

class StoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ElevenlabsApiService _elevenLabsService =
      ElevenlabsApiService(); // Changed type

  /// Extract XML content from text
  String _extractXml(String text) {
    // Use the standardized XML parser utility
    return XmlParserUtil.extractXmlFromText(text);
  }

  /// Import a story from XML string
  Future<int> importStoryFromXml(String xmlString) async {
    try {
      // Extract just the XML content in case there's extra text
      final purifiedXml = _extractXml(xmlString);

      // Parse XML to Story object
      Story story = StoryXmlParser.parseStoryXml(purifiedXml);

      // Process character mappings to ensure proper relationships
      story = CharacterMapperUtil.mapCharacterScripts(story);

      // Save to database
      return await _dbHelper.insertCompleteStory(story);
    } catch (e) {
      rethrow;
    }
  }

  /// Import a story from Gemini-generated XML string
  Future<int> importStoryFromGeminiXml(String xmlString) async {
    return await importStoryFromXml(xmlString);
  }

  /// Get all stories
  Future<List<Story>> getAllStories() async {
    return await _dbHelper.getAllStories();
  }

  /// Get a story by ID with all related data
  Future<Story?> getStoryById(int id) async {
    return await _dbHelper.getStory(id);
  }

  /// Generate and save voiceover for a script (either narrator or character)
  Future<String> generateScriptVoiceover(
    Script script, {
    Character? character,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final voiceoverDir = Directory('${dir.path}/voiceovers');

    if (!await voiceoverDir.exists()) {
      await voiceoverDir.create(recursive: true);
    }

    final scriptType = script.isNarrator ? 'narrator' : 'character';
    final fileName =
        '${scriptType}_${script.id}_${DateTime.now().millisecondsSinceEpoch}.mp3';
    final filePath = '${voiceoverDir.path}/$fileName';

    try {
      // Generate voiceover using ElevenLabs API
      await _elevenLabsService.generateVoiceover(
        text: script.scriptText,
        outputPath: filePath,
        gender: character?.gender,
        voiceDescription:
            script.isNarrator ? 'narrator' : character?.voiceDescription,
        voiceId: character?.voiceId, // Use voice_id if available
      );

      // Update the database with the path
      await _dbHelper.updateScriptVoiceoverPath(script.id!, filePath);

      return filePath;
    } catch (e) {
      // In case of error, create a placeholder file
      await File(filePath).writeAsString('Error generating voiceover: $e');
      throw Exception('Failed to generate $scriptType voiceover: $e');
    }
  }

  /// Generate voiceovers for all scripts in a story
  Future<void> generateAllVoiceovers(Story story) async {
    // Generate voiceovers for all scenes
    for (var scene in story.scenes) {
      for (var script in scene.scripts) {
        if (script.id != null) {
          if (script.isNarrator) {
            // Narrator script
            await generateScriptVoiceover(script);
          } else {
            // Character script - find the associated character
            final character = story.characters.firstWhere(
              (c) => c.id == script.characterId,
              orElse:
                  () => Character(
                    storyId: story.id!,
                    name: 'Unknown Character',
                    gender: 'neutral',
                    voiceDescription: 'neutral voice',
                  ),
            );

            await generateScriptVoiceover(script, character: character);
          }
        }
      }
    }
  }

  /// Delete a story and all associated data
  Future<int> deleteStory(int id) async {
    return await _dbHelper.deleteStory(id);
  }

  /// Get voiceover file for a script
  File? getScriptVoiceoverFile(Script script) {
    if (script.voiceoverPath == null) return null;

    final file = File(script.voiceoverPath!);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  /// Get ElevenLabs voice ID for a character based on voice description
  String getElevenLabsVoiceId(String? gender, String? voiceDescription) {
    return _elevenLabsService.getVoiceId(gender, voiceDescription);
  }

  /// Get available ElevenLabs voices
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    final voices = await _elevenLabsService.getAvailableVoices();
    return voices ?? []; // Return empty list if null
  }

  /// Set voice ID for a character
  Future<int> setCharacterVoiceId(int characterId, String voiceId) async {
    return await _dbHelper.updateCharacterVoiceId(characterId, voiceId);
  }
}
