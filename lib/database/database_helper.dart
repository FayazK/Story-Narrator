// lib/database/database_helper.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/story.dart';
import '../models/character.dart';
import '../models/story_scene.dart';
import '../models/script.dart';
import '../models/voice.dart';
import '../models/scene_image.dart'; // Import the new model

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
    Directory documentsDirectory = await getApplicationSupportDirectory();
    String dbPath = join(documentsDirectory.path, 'databases', 'story_narrator.db');
    
    // Ensure the directory exists
    Directory(dirname(dbPath)).create(recursive: true);
    
    return await openDatabase(
      dbPath,
      version: 5, // Increased version number to add scene_images table
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }
  
  /// Upgrade database when schema changes
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');
    
    // Apply migrations based on oldVersion
    if (oldVersion < 3) {
      // Migration to version 3: Add character_name column to scripts table
      try {
        await db.execute('ALTER TABLE scripts ADD COLUMN character_name TEXT');
        debugPrint('Added character_name column to scripts table');
      } catch (e) {
        debugPrint('Error adding character_name column: $e');
        // If the column already exists or there's another issue, log it but don't crash
      }
    }
    
    if (oldVersion < 4) {
      // Migration to version 4: Add voices table
      try {
        await db.execute('''
          CREATE TABLE voices (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT,
            description TEXT,
            preview_url TEXT,
            gender TEXT,
            accent TEXT,
            age TEXT,
            use_case TEXT,
            sample_text TEXT,
            language TEXT,
            locale TEXT,
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        debugPrint('Created voices table');
      } catch (e) {
        debugPrint('Error creating voices table: $e');
      }
    }

    if (oldVersion < 5) {
      // Migration to version 5: Add scene_images table
      try {
        await db.execute('''
          CREATE TABLE scene_images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            scene_id INTEGER NOT NULL,
            prompt TEXT NOT NULL,
            image_path TEXT, -- Nullable
            FOREIGN KEY (scene_id) REFERENCES scenes (id) ON DELETE CASCADE
          )
        ''');
        debugPrint('Created scene_images table');

        await db.execute('CREATE INDEX idx_scene_images_scene_id ON scene_images (scene_id)');
        debugPrint('Created index idx_scene_images_scene_id on scene_images table');
      } catch (e) {
        debugPrint('Error creating scene_images table or index: $e');
      }
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create stories table
    await db.execute('''
      CREATE TABLE stories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        image_prompt TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        ai_response TEXT
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
        voice_id TEXT,
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
        character_name TEXT, -- Used for character mapping during import
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
    
    // Create voices table
    await db.execute('''
      CREATE TABLE voices (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        description TEXT,
        preview_url TEXT,
        gender TEXT,
        accent TEXT,
        age TEXT,
        use_case TEXT,
        sample_text TEXT,
        language TEXT,
        locale TEXT,
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
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
    debugPrint('Getting all stories');
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
      final Map<String, int> characterNameToIdMap = {};
      
      for (var character in story.characters) {
        // Add the story ID to the character
        final charMap = character.toMap()..['story_id'] = storyId;
        int characterId = await txn.insert('characters', charMap);
        characterIds.add(characterId);
        
        // Add to name-to-id mapping for later character script processing
        characterNameToIdMap[character.name] = characterId;
      }

      // Insert scenes and scripts
      for (var scene in story.scenes) {
        int sceneId = await txn.insert('scenes', scene.toMap()..['story_id'] = storyId);

        // Insert all scripts for this scene
        for (var script in scene.scripts) {
          final scriptMap = script.toMap()..['scene_id'] = sceneId;
          
          // If this is a character script, determine the correct character ID
          if (!script.isNarrator) {
            // Use characterName to look up the character ID if available
            if (script.characterName != null && characterNameToIdMap.containsKey(script.characterName)) {
              scriptMap['character_id'] = characterNameToIdMap[script.characterName];
            } 
            // Fall back to the legacy approach using temporary index IDs if necessary
            else if (script.characterId != null && script.characterId! >= 0 && 
                     script.characterId! < characterIds.length) {
              scriptMap['character_id'] = characterIds[script.characterId!];
            }
          }
          
          // Insert the script
          await txn.insert('scripts', scriptMap);
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
  
  /// Check if the database exists
  Future<bool> databaseExists() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, 'databases', 'story_narrator.db');
    return File(dbPath).exists();
  }

  /// Update a story's AI response
  Future<int> updateStoryAiResponse(int id, String aiResponse) async {
    final Database db = await database;
    return await db.update(
      'stories',
      {'ai_response': aiResponse},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update a character's voice ID
  Future<int> updateCharacterVoiceId(int id, String voiceId) async {
    final Database db = await database;
    return await db.update(
      'characters',
      {'voice_id': voiceId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Voice CRUD operations
  
  /// Insert a new voice into the voices table
  Future<void> insertVoice(Voice voice) async {
    final Database db = await database;
    
    try {
      await db.insert(
        'voices',
        voice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace if already exists
      );
    } catch (e) {
      debugPrint('Error inserting voice: $e');
      rethrow;
    }
  }
  
  /// Check if a voice is already in the library
  Future<bool> isVoiceInLibrary(String voiceId) async {
    final Database db = await database;
    
    try {
      final result = await db.query(
        'voices',
        where: 'id = ?',
        whereArgs: [voiceId],
        limit: 1,
      );
      
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if voice is in library: $e');
      return false;
    }
  }
  
  /// Get all voices from the library
  Future<List<Voice>> getAllVoices() async {
    final Database db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query('voices');
      
      return List.generate(maps.length, (i) {
        return Voice.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('Error getting all voices: $e');
      return [];
    }
  }
  
  /// Get a voice by ID
  Future<Voice?> getVoiceById(String voiceId) async {
    final Database db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'voices',
        where: 'id = ?',
        whereArgs: [voiceId],
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      
      return Voice.fromMap(maps.first);
    } catch (e) {
      debugPrint('Error getting voice by ID: $e');
      return null;
    }
  }
  
  /// Remove a voice from the library
  Future<void> removeVoice(String voiceId) async {
    final Database db = await database;
    
    try {
      await db.delete(
        'voices',
        where: 'id = ?',
        whereArgs: [voiceId],
      );
    } catch (e) {
      debugPrint('Error removing voice: $e');
      rethrow;
    }
  }

  // SceneImage CRUD operations

  /// Get all scene images associated with a specific scene ID
  Future<List<SceneImage>> getSceneImagesBySceneId(int sceneId) async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'scene_images',
        where: 'scene_id = ?',
        whereArgs: [sceneId],
        orderBy: 'id ASC', // Or order as needed, e.g., by creation time if added
      );

      return List.generate(maps.length, (i) {
        return SceneImage.fromMap(maps[i]);
      });
    } catch (e) {
      debugPrint('Error getting scene images by scene ID $sceneId: $e');
      return []; // Return empty list on error
    }
  }

  /// Insert a new scene image record
  Future<int> insertSceneImage(SceneImage sceneImage) async {
    final Database db = await database;
    try {
      return await db.insert(
        'scene_images',
        sceneImage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Or fail/ignore as needed
      );
    } catch (e) {
      debugPrint('Error inserting scene image: $e');
      rethrow;
    }
  }

  /// Delete a scene image record by its ID
  Future<int> deleteSceneImage(int id) async {
    final Database db = await database;
    try {
      return await db.delete(
        'scene_images',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting scene image with ID $id: $e');
      rethrow;
    }
  }

  /// Update a scene image record (e.g., update image_path)
  Future<int> updateSceneImage(SceneImage sceneImage) async {
    final Database db = await database;
    if (sceneImage.id == null) {
      throw ArgumentError("Cannot update a SceneImage without an ID.");
    }
    try {
      return await db.update(
        'scene_images',
        sceneImage.toMap(), // Ensure toMap doesn't include ID if not needed for update
        where: 'id = ?',
        whereArgs: [sceneImage.id],
      );
    } catch (e) {
      debugPrint('Error updating scene image with ID ${sceneImage.id}: $e');
      rethrow;
    }
  }
}
