// lib/models/character.dart
class Character {
  final int? id;
  final int storyId;
  final String name;
  final String? gender;
  final String? voiceDescription;

  Character({
    this.id,
    required this.storyId,
    required this.name,
    this.gender,
    this.voiceDescription,
  });

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'],
      storyId: map['story_id'],
      name: map['name'],
      gender: map['gender'],
      voiceDescription: map['voice_description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story_id': storyId,
      'name': name,
      'gender': gender,
      'voice_description': voiceDescription,
    };
  }
}