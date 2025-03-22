// lib/models/character.dart
class Character {
  final int? id;
  final int storyId;
  final String name;
  final String? gender;
  final String? voiceDescription;
  final String? voiceId;

  Character({
    this.id,
    required this.storyId,
    required this.name,
    this.gender,
    this.voiceDescription,
    this.voiceId,
  });

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      storyId: map['story_id'],
      name: map['name'],
      gender: map['gender'],
      voiceDescription: map['voice_description'],
      voiceId: map['voice_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story_id': storyId,
      'name': name,
      'gender': gender,
      'voice_description': voiceDescription,
      'voice_id': voiceId,
    };
  }
  
  /// Create a copy of this Character with some fields replaced
  Character copyWith({
    int? id,
    int? storyId,
    String? name,
    String? gender,
    String? voiceDescription,
    String? voiceId,
  }) {
    return Character(
      id: id ?? this.id,
      storyId: storyId ?? this.storyId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      voiceDescription: voiceDescription ?? this.voiceDescription,
      voiceId: voiceId ?? this.voiceId,
    );
  }
}
