// lib/models/story.dart
import 'character.dart';
import 'story_scene.dart';

class Story {
  final int? id;
  final String title;
  final String? imagePrompt;
  final String? createdAt;
  final String? updatedAt;
  final String? aiResponse;
  final List<Character> characters;
  final List<StoryScene> scenes;

  Story({
    this.id,
    required this.title,
    this.imagePrompt,
    this.createdAt,
    this.updatedAt,
    this.aiResponse,
    this.characters = const [],
    this.scenes = const [],
  });

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      title: map['title'],
      imagePrompt: map['image_prompt'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      aiResponse: map['ai_response'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'image_prompt': imagePrompt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'ai_response': aiResponse,
    };
  }

  Story copyWith({
    int? id,
    String? title,
    String? imagePrompt,
    String? createdAt,
    String? updatedAt,
    String? aiResponse,
    List<Character>? characters,
    List<StoryScene>? scenes,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aiResponse: aiResponse ?? this.aiResponse,
      characters: characters ?? this.characters,
      scenes: scenes ?? this.scenes,
    );
  }
}