// lib/models/voice.dart
import 'dart:convert';

class Voice {
  final String id;
  final String name;
  final String? category;
  final String? description;
  final String? previewUrl;
  final String? gender;
  final String? accent;
  final String? age;
  final String? useCase;
  final String? sampleText;
  final bool isAddedToLibrary;
  final DateTime? addedAt;

  Voice({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.previewUrl,
    this.gender,
    this.accent,
    this.age,
    this.useCase,
    this.sampleText,
    this.isAddedToLibrary = false,
    this.addedAt,
  });

  Voice copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? previewUrl,
    String? gender,
    String? accent,
    String? age,
    String? useCase,
    String? sampleText,
    bool? isAddedToLibrary,
    DateTime? addedAt,
  }) {
    return Voice(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      previewUrl: previewUrl ?? this.previewUrl,
      gender: gender ?? this.gender,
      accent: accent ?? this.accent,
      age: age ?? this.age,
      useCase: useCase ?? this.useCase,
      sampleText: sampleText ?? this.sampleText,
      isAddedToLibrary: isAddedToLibrary ?? this.isAddedToLibrary,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'preview_url': previewUrl,
      'gender': gender,
      'accent': accent,
      'age': age,
      'use_case': useCase,
      'sample_text': sampleText,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  factory Voice.fromMap(Map<String, dynamic> map) {
    return Voice(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      previewUrl: map['preview_url'],
      gender: map['gender'],
      accent: map['accent'],
      age: map['age'],
      useCase: map['use_case'],
      sampleText: map['sample_text'],
      isAddedToLibrary: map['added_at'] != null,
      addedAt: map['added_at'] != null 
          ? DateTime.parse(map['added_at']) 
          : null,
    );
  }

  // For API data conversion
  factory Voice.fromJson(Map<String, dynamic> json, {bool isInLibrary = false}) {
    // Handle different API response structures
    return Voice(
      id: json['voice_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      gender: json['labels']?['gender'],
      accent: json['labels']?['accent'],
      age: json['labels']?['age'],
      useCase: json['labels']?['use_case'] ?? json['useCase'],
      previewUrl: json['preview_url'],
      sampleText: json['sample_text'] ?? json['preview_text'],
      isAddedToLibrary: isInLibrary,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Voice(id: $id, name: $name, gender: $gender, accent: $accent)';
  }
}
