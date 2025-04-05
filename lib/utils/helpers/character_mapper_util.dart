// lib/utils/helpers/character_mapper_util.dart
import 'package:flutter/foundation.dart';
import '../../models/story.dart';
import '../../models/character.dart';

/// Utility class to handle character mapping in story processing
class CharacterMapperUtil {
  /// Map all character scripts to their respective character IDs
  ///
  /// This utility function fixes one key issue in the story creation process:
  /// properly linking character scripts to characters by name when IDs
  /// aren't available or reliable (like during XML import)
  static Story mapCharacterScripts(Story story) {
    try {
      // Create a map of character names to their character objects
      final Map<String, Character> characterNameMap = {};

      // Build the name-to-character mapping
      for (final character in story.characters) {
        characterNameMap[character.name.toLowerCase()] = character;
      }

      // Update all scenes and their scripts
      final updatedScenes =
          story.scenes.map((scene) {
            // Process scripts in the scene
            final updatedScripts =
                scene.scripts.map((script) {
                  // Only process character scripts (non-narrator scripts)
                  if (!script.isNarrator) {
                    // Try mapping by character name first (most reliable)
                    if (script.characterName != null &&
                        script.characterName!.isNotEmpty) {
                      final characterKey = script.characterName!.toLowerCase();
                      if (characterNameMap.containsKey(characterKey)) {
                        final matchedCharacter =
                            characterNameMap[characterKey]!;
                        // Return script with updated character ID
                        if (matchedCharacter.id != null) {
                          return script.copyWith(
                            characterId: matchedCharacter.id,
                          );
                        }
                      }
                    }

                    // If character name mapping failed but we have a valid ID, keep the ID
                    if (script.characterId != null && script.characterId! > 0) {
                      return script;
                    }

                    // If all else fails, try to find a character by similar name
                    for (final characterEntry in characterNameMap.entries) {
                      final characterName = characterEntry.key;

                      // Try to extract potential character name from the script text
                      // (Often dialogue starts with "Character name: ")
                      final scriptFirstLine =
                          script.scriptText.split('\n').first;
                      if (scriptFirstLine.toLowerCase().contains(
                        characterName,
                      )) {
                        final character = characterEntry.value;
                        if (character.id != null) {
                          return script.copyWith(
                            characterId: character.id,
                            characterName: character.name,
                          );
                        }
                      }
                    }
                  }

                  // If no mapping was successful or it's a narrator script, return as is
                  return script;
                }).toList();

            // Return updated scene with fixed scripts
            return scene.copyWith(scripts: updatedScripts);
          }).toList();

      // Return the updated story
      return story.copyWith(scenes: updatedScenes);
    } catch (e) {
      debugPrint('Error mapping character scripts: $e');
      // Return original story if mapping fails
      return story;
    }
  }
}
