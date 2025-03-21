// lib/models/script.dart
class Script {
  final int? id;
  final int sceneId;
  final int? characterId; // NULL for narrator scripts
  final String scriptText;
  final String language;
  final bool urduFlavor;
  final String? voiceAction;
  final String? voiceoverPath;
  final int scriptOrder;

  Script({
    this.id,
    required this.sceneId,
    this.characterId, // Narrator scripts will have characterId = null
    required this.scriptText,
    this.language = 'english',
    this.urduFlavor = false,
    this.voiceAction,
    this.voiceoverPath,
    this.scriptOrder = 0,
  });

  /// Check if this is a narrator script
  bool get isNarrator => characterId == null;

  factory Script.fromMap(Map<String, dynamic> map) {
    return Script(
      id: map['id'],
      sceneId: map['scene_id'],
      characterId: map['character_id'],
      scriptText: map['script_text'],
      language: map['language'],
      urduFlavor: map['urdu_flavor'] == 1,
      voiceAction: map['voice_action'],
      voiceoverPath: map['voiceover_path'],
      scriptOrder: map['script_order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scene_id': sceneId,
      'character_id': characterId,
      'script_text': scriptText,
      'language': language,
      'urdu_flavor': urduFlavor ? 1 : 0,
      'voice_action': voiceAction,
      'voiceover_path': voiceoverPath,
      'script_order': scriptOrder,
    };
  }

  /// Create a narrator script
  factory Script.narrator({
    int? id,
    required int sceneId,
    required String scriptText,
    String language = 'english',
    bool urduFlavor = false,
    String? voiceAction,
    String? voiceoverPath,
    int scriptOrder = 0,
  }) {
    return Script(
      id: id,
      sceneId: sceneId,
      characterId: null,
      // Narrator script has null characterId
      scriptText: scriptText,
      language: language,
      urduFlavor: urduFlavor,
      voiceAction: voiceAction,
      voiceoverPath: voiceoverPath,
      scriptOrder: scriptOrder,
    );
  }

  /// Create a character script
  factory Script.character({
    int? id,
    required int sceneId,
    required int characterId,
    required String scriptText,
    String language = 'english',
    bool urduFlavor = false,
    String? voiceAction,
    String? voiceoverPath,
    int scriptOrder = 0,
  }) {
    return Script(
      id: id,
      sceneId: sceneId,
      characterId: characterId,
      scriptText: scriptText,
      language: language,
      urduFlavor: urduFlavor,
      voiceAction: voiceAction,
      voiceoverPath: voiceoverPath,
      scriptOrder: scriptOrder,
    );
  }

  Script copyWith({
    int? id,
    int? sceneId,
    int? characterId,
    bool clearCharacterId = false,
    String? scriptText,
    String? language,
    bool? urduFlavor,
    String? voiceAction,
    bool clearVoiceAction = false,
    String? voiceoverPath,
    bool clearVoiceoverPath = false,
    int? scriptOrder,
  }) {
    return Script(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      characterId: clearCharacterId ? null : (characterId ?? this.characterId),
      scriptText: scriptText ?? this.scriptText,
      language: language ?? this.language,
      urduFlavor: urduFlavor ?? this.urduFlavor,
      voiceAction: clearVoiceAction ? null : (voiceAction ?? this.voiceAction),
      voiceoverPath:
          clearVoiceoverPath ? null : (voiceoverPath ?? this.voiceoverPath),
      scriptOrder: scriptOrder ?? this.scriptOrder,
    );
  }
}
