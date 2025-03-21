// lib/database/database_helper.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/story.dart';
import '../models/character.dart';
import '../models/story_scene.dart';
import '../models/script.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'story_narrator.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create stories table
    await db.execute('''
      CREATE TABLE stories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image_prompt TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create characters table
    await db.execute('''
      CREATE TABLE characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        story_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        gender TEXT,
        voice_description TEXT,
        FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
      )
    ''');

    // Create scenes table
    await db.execute('''
      CREATE TABLE scenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        story_id INTEGER NOT NULL,
        scene_number INTEGER NOT NULL,
        background_image TEXT,
        character_actions TEXT,
        background_sound TEXT,
        sound_effects TEXT,
        FOREIGN KEY (story_id) REFERENCES stories (id) ON DELETE CASCADE
      )
    ''');

    // Create unified scripts table
    await db.execute('''
      CREATE TABLE scripts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scene_id INTEGER NOT NULL,
        character_id INTEGER, -- NULL for narrator scripts
        script_text TEXT NOT NULL,
        language TEXT NOT NULL DEFAULT 'english',
        urdu_flavor BOOLEAN DEFAULT 0,
        voice_action TEXT,
        voiceover_path TEXT,
        script_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (scene_id) REFERENCES scenes (id) ON DELETE CASCADE,
        FOREIGN KEY (character_id) REFERENCES characters (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_stories_title ON stories (title)');
    await db.execute('CREATE INDEX idx_characters_story_id ON characters (story_id)');
    await db.execute('CREATE INDEX idx_scenes_story_id ON scenes (story_id)');
    await db.execute('CREATE INDEX idx_scenes_number ON scenes (scene_number)');
    await db.execute('CREATE INDEX idx_scripts_scene_id ON scripts (scene_id)');
    await db.execute('CREATE INDEX idx_scripts_character_id ON scripts (character_id)');
  }

  // Story CRUD operations
  Future<int> insertStory(Story story) async {
    final Database db = await database;
    return await db.insert('stories', story.toMap());
  }

  Future<Story?> getStory(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'stories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    Story story = Story.fromMap(maps.first);

    // Get characters
    List<Character> characters = await getCharactersByStoryId(id);

    // Get scenes
    List<StoryScene> scenes = await getScenesByStoryId(id);

    return story.copyWith(
      characters: characters,
      scenes: scenes,
    );
  }

  Future<List<Story>> getAllStories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('stories');
    return List.generate(maps.length, (i) {
      return Story.fromMap(maps[i]);
    });
  }

  Future<int> updateStory(Story story) async {
    final Database db = await database;
    return await db.update(
      'stories',
      story.toMap(),
      where: 'id = ?',
      whereArgs: [story.id],
    );
  }

  Future<int> deleteStory(int id) async {
    final Database db = await database;
    return await db.delete(
      'stories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Character CRUD operations
  Future<int> insertCharacter(Character character) async {
    final Database db = await database;
    return await db.insert('characters', character.toMap());
  }

  Future<List<Character>> getCharactersByStoryId(int storyId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'characters',
      where: 'story_id = ?',
      whereArgs: [storyId],
    );
    return List.generate(maps.length, (i) {
      return Character.fromMap(maps[i]);
    });
  }

  // Scene CRUD operations
  Future<int> insertScene(StoryScene scene) async {
    final Database db = await database;
    return await db.insert('scenes', scene.toMap());
  }

  Future<List<StoryScene>> getScenesByStoryId(int storyId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scenes',
      where: 'story_id = ?',
      whereArgs: [storyId],
      orderBy: 'scene_number ASC',
    );

    List<StoryScene> scenes = [];
    for (var map in maps) {
      StoryScene scene = StoryScene.fromMap(map);

      // Get all scripts for this scene
      List<Script> scripts = await getScriptsBySceneId(scene.id!);

      scenes.add(scene.copyWith(
        scripts: scripts,
      ));
    }

    return scenes;
  }

  // Script CRUD operations
  Future<int> insertScript(Script script) async {
    final Database db = await database;
    return await db.insert('scripts', script.toMap());
  }

  Future<List<Script>> getScriptsBySceneId(int sceneId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scripts',
      where: 'scene_id = ?',
      whereArgs: [sceneId],
      orderBy: 'script_order ASC, id ASC', // Order by script_order first, then by id
    );

    return List.generate(maps.length, (i) {
      return Script.fromMap(maps[i]);
    });
  }

  Future<Script?> getNarrationBySceneId(int sceneId) async {
    final Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'scripts',
      where: 'scene_id = ? AND character_id IS NULL',
      whereArgs: [sceneId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Script.fromMap(maps.first);
  }

  Future<List<Script>> getCharacterScriptsBySceneId(int sceneId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scripts',
      where: 'scene_id = ? AND character_id IS NOT NULL',
      whereArgs: [sceneId],
      orderBy: 'script_order ASC, id ASC',
    );

    return List.generate(maps.length, (i) {
      return Script.fromMap(maps[i]);
    });
  }

  Future<int> updateScriptVoiceoverPath(int id, String path) async {
    final Database db = await database;
    return await db.update(
      'scripts',
      {'voiceover_path': path},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction to insert a complete story with all related data
  Future<int> insertCompleteStory(Story story) async {
    final Database db = await database;
    int storyId = 0;

    await db.transaction((txn) async {
      // Insert story
      storyId = await txn.insert('stories', story.toMap());

      // Insert characters
      final List<int> characterIds = [];
      for (var character in story.characters) {
        int characterId = await txn.insert('characters', character.toMap()..['story_id'] = storyId);
        characterIds.add(characterId);
      }

      // Insert scenes and scripts
      for (var scene in story.scenes) {
        int sceneId = await txn.insert('scenes', scene.toMap()..['story_id'] = storyId);

        // Insert all scripts for this scene
        for (var script in scene.scripts) {
          // If this is a character script, update the character_id to use the newly generated ID
          if (script.characterId != null) {
            // Use the characterIds list to map the original index to the new database ID
            // Note: In XML import, we temporarily use index as ID
            int characterIndex = script.characterId!;
            if (characterIndex >= 0 && characterIndex < characterIds.length) {
              int characterId = characterIds[characterIndex];
              await txn.insert('scripts', script.toMap()
                ..['scene_id'] = sceneId
                ..['character_id'] = characterId);
            }
          } else {
            // For narrator scripts, simply use null character_id
            await txn.insert('scripts', script.toMap()..['scene_id'] = sceneId);
          }
        }
      }
    });

    return storyId;
  }

  /// Get all scripts for a scene
  Future<List<Script>> getAllScriptsBySceneId(int sceneId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scripts',
      where: 'scene_id = ?',
      whereArgs: [sceneId],
      orderBy: 'script_order ASC, id ASC',
    );

    return List.generate(maps.length, (i) {
      return Script.fromMap(maps[i]);
    });
  }

  /// Update a script's text
  Future<int> updateScriptText(int id, String text) async {
    final Database db = await database;
    return await db.update(
      'scripts',
      {'script_text': text},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a script
  Future<int> deleteScript(int id) async {
    final Database db = await database;
    return await db.delete(
      'scripts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}