// lib/models/story_scene.dart
import 'script.dart';

class StoryScene {
  final int? id;
  final int storyId;
  final int sceneNumber;
  final String? backgroundImage;
  final String? characterActions;
  final String? backgroundSound;
  final String? soundEffects;
  final String? imagePrompt; // User-defined prompt focus for image generation
  final List<Script> scripts;

  StoryScene({
    this.id,
    required this.storyId,
    required this.sceneNumber,
    this.backgroundImage,
    this.characterActions,
    this.backgroundSound,
    this.soundEffects,
    this.imagePrompt,
    this.scripts = const [],
  });

  /// Get the narration script (first script with null characterId)
  Script? get narration {
    return scripts.where((script) => script.isNarrator).firstOrNull;
  }

  /// Get all character scripts (non-narrator scripts)
  List<Script> get characterScripts {
    return scripts.where((script) => !script.isNarrator).toList();
  }

  factory StoryScene.fromMap(Map<String, dynamic> map) {
    return StoryScene(
      id: map['id'],
      storyId: map['story_id'],
      sceneNumber: map['scene_number'],
      backgroundImage: map['background_image'],
      characterActions: map['character_actions'],
      backgroundSound: map['background_sound'],
      soundEffects: map['sound_effects'],
      // Note: scripts are loaded separately in DatabaseHelper
    );
  }

  Map<String, dynamic> toMap() {
    // Only include the scene data for the scenes table
    // Scripts are handled separately in the database operations
    return {
      if (id != null) 'id': id,
      'story_id': storyId,
      'scene_number': sceneNumber,
      'background_image': backgroundImage,
      'character_actions': characterActions,
      'background_sound': backgroundSound,
      'sound_effects': soundEffects,
    };
  }

  StoryScene copyWith({
    int? id,
    int? storyId,
    int? sceneNumber,
    String? backgroundImage,
    bool clearBackgroundImage = false,
    String? characterActions,
    bool clearCharacterActions = false,
    String? backgroundSound,
    bool clearBackgroundSound = false,
    String? soundEffects,
    bool clearSoundEffects = false,
    String? imagePrompt,
    bool clearImagePrompt = false,
    List<Script>? scripts,
  }) {
    return StoryScene(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      sceneNumber: sceneNumber ?? this.sceneNumber,
      backgroundImage: clearBackgroundImage ? null : (backgroundImage ?? this.backgroundImage),
      characterActions: clearCharacterActions ? null : (characterActions ?? this.characterActions),
      backgroundSound: clearBackgroundSound ? null : (backgroundSound ?? this.backgroundSound),
      soundEffects: clearSoundEffects ? null : (soundEffects ?? this.soundEffects),
      imagePrompt: clearImagePrompt ? null : (imagePrompt ?? this.imagePrompt),
      scripts: scripts ?? this.scripts,
    );
  }
}
