// lib/models/scene_image.dart

class SceneImage {
  final int? id;
  final int sceneId;
  final String prompt;
  final String? imagePath; // Path to the locally stored image, if generated/saved

  SceneImage({
    this.id,
    required this.sceneId,
    required this.prompt,
    this.imagePath,
  });

  /// Creates a SceneImage instance from a database map.
  factory SceneImage.fromMap(Map<String, dynamic> map) {
    return SceneImage(
      id: map['id'] as int?,
      sceneId: map['scene_id'] as int,
      prompt: map['prompt'] as String,
      imagePath: map['image_path'] as String?,
    );
  }

  /// Converts the SceneImage instance to a map for database insertion/updates.
  /// Note: 'id' is typically handled by the database auto-increment.
  Map<String, dynamic> toMap() {
    return {
      'scene_id': sceneId,
      'prompt': prompt,
      'image_path': imagePath,
    };
  }

  SceneImage copyWith({
    int? id,
    int? sceneId,
    String? prompt,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return SceneImage(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      prompt: prompt ?? this.prompt,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }
}
