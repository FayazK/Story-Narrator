import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/story.dart';
import '../utils/helpers/xml_parser_util.dart';
import '../utils/xml_parser.dart';
import '../utils/helpers/character_mapper_util.dart';

/// Service to repair stories that failed to properly parse during creation
class StoryRepairService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Check if the scripts table has the character_name column
  Future<bool> _hasCharacterNameColumn() async {
    try {
      final db = await _dbHelper.database;
      
      // Try to get table info
      final tableInfo = await db.rawQuery("PRAGMA table_info(scripts)");
      
      // Check if character_name column exists
      return tableInfo.any((column) => column['name'] == 'character_name');
    } catch (e) {
      debugPrint('Error checking for character_name column: $e');
      return false;
    }
  }
  
  /// Repair a story by re-parsing its AI response
  Future<bool> repairStory(int storyId) async {
    try {
      // Get the story with its current state
      final story = await _dbHelper.getStory(storyId);
      if (story == null) {
        throw Exception('Story not found');
      }
      
      // Check if the story has an AI response
      if (story.aiResponse == null || story.aiResponse!.isEmpty) {
        throw Exception('Story does not have an AI response to repair from');
      }
      
      // Extract XML from the AI response
      final xmlContent = XmlParserUtil.extractXmlFromText(story.aiResponse!);
      if (xmlContent.isEmpty) {
        throw Exception('Could not extract XML from AI response');
      }
      
      // Parse the XML into a Story object
      Story parsedStory = StoryXmlParser.parseStoryXml(xmlContent);
      
      // Ensure character mappings are correct
      parsedStory = CharacterMapperUtil.mapCharacterScripts(parsedStory);
      
      // Extract title and image prompt from the XML if the current ones are empty/default
      final String newTitle = parsedStory.title.isNotEmpty ? parsedStory.title : story.title;
      final String? newImagePrompt = parsedStory.imagePrompt?.isNotEmpty == true ? parsedStory.imagePrompt : story.imagePrompt;
      
      // Copy over the ID and other metadata from the original story
      parsedStory = parsedStory.copyWith(
        id: story.id,
        title: newTitle,
        imagePrompt: newImagePrompt,
        createdAt: story.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
        aiResponse: story.aiResponse,
      );
      
      // Delete all existing scenes and characters for this story
      await _cleanupExistingStoryComponents(storyId);
      
      // Insert the new components
      await _insertStoryComponents(parsedStory);
      
      return true;
    } catch (e) {
      debugPrint('Error repairing story: $e');
      return false;
    }
  }
  
  /// Clean up existing story components before rebuilding
  Future<void> _cleanupExistingStoryComponents(int storyId) async {
    final db = await _dbHelper.database;
    
    // Use a transaction to ensure all operations complete or none do
    await db.transaction((txn) async {
      // Delete all characters for this story
      await txn.delete(
        'characters',
        where: 'story_id = ?',
        whereArgs: [storyId],
      );
      
      // Get all scene IDs for this story
      final sceneRows = await txn.query(
        'scenes',
        columns: ['id'],
        where: 'story_id = ?',
        whereArgs: [storyId],
      );
      
      final List<int> sceneIds = sceneRows.map<int>((row) => row['id'] as int).toList();
      
      // Delete all scripts for these scenes
      for (final sceneId in sceneIds) {
        await txn.delete(
          'scripts',
          where: 'scene_id = ?',
          whereArgs: [sceneId],
        );
      }
      
      // Delete all scenes for this story
      await txn.delete(
        'scenes',
        where: 'story_id = ?',
        whereArgs: [storyId],
      );
    });
  }
  
  /// Insert characters, scenes, and scripts for the repaired story
  Future<void> _insertStoryComponents(Story story) async {
    if (story.id == null) throw Exception('Story ID is required');
    
    // Check if character_name column exists
    final hasCharacterNameColumn = await _hasCharacterNameColumn();
    
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      // Update the story record with the proper title and image prompt
      await txn.update(
        'stories',
        {
          'title': story.title,
          'image_prompt': story.imagePrompt,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [story.id]
      );
      
      // Insert characters
      final Map<String, int> characterNameToIdMap = {};
      
      for (var character in story.characters) {
        // Add the story ID to the character
        final charMap = character.toMap()..['story_id'] = story.id;
        int characterId = await txn.insert('characters', charMap);
        characterNameToIdMap[character.name] = characterId;
      }
      
      // Insert scenes and scripts
      for (var scene in story.scenes) {
        int sceneId = await txn.insert('scenes', scene.toMap()..['story_id'] = story.id);
        
        // Insert all scripts for this scene
        for (var script in scene.scripts) {
          // Create script map but remove character_name if the column doesn't exist
          final scriptMap = script.toMap()..['scene_id'] = sceneId;
          
          // If character_name column doesn't exist, remove it from the map
          if (!hasCharacterNameColumn && scriptMap.containsKey('character_name')) {
            scriptMap.remove('character_name');
          }
          
          // If this is a character script, determine the correct character ID
          if (!script.isNarrator) {
            // Use characterName to look up the character ID if available
            if (script.characterName != null && characterNameToIdMap.containsKey(script.characterName)) {
              scriptMap['character_id'] = characterNameToIdMap[script.characterName];
            } 
            // If no character name match, check by looking up similar names
            else {
              String? matchedName;
              for (final name in characterNameToIdMap.keys) {
                if (script.scriptText.toLowerCase().contains(name.toLowerCase())) {
                  matchedName = name;
                  break;
                }
              }
              
              if (matchedName != null) {
                scriptMap['character_id'] = characterNameToIdMap[matchedName];
                // Only add character_name if the column exists
                if (hasCharacterNameColumn) {
                  scriptMap['character_name'] = matchedName;
                }
              }
            }
          }
          
          // Insert the script
          await txn.insert('scripts', scriptMap);
        }
      }
    });
  }
}