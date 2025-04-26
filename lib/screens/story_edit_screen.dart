import 'dart:io';
import 'package:flutter/material.dart';
import '../components/story_edit/index.dart';
import '../database/database_helper.dart';
import '../models/story.dart';
import '../models/character.dart';
import '../models/script.dart';
import '../services/elevenlabs_api_service.dart';
import '../services/gemini_service.dart'; // Added import
import '../utils/ui/app_colors.dart';
import '../utils/ui/content_container.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_voices_provider.dart';

class StoryEditScreen extends StatefulWidget {
  final int storyId;

  const StoryEditScreen({super.key, required this.storyId});

  @override
  State<StoryEditScreen> createState() => _StoryEditScreenState();
}

class _StoryEditScreenState extends State<StoryEditScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ElevenlabsApiService _elevenLabsService = ElevenlabsApiService();
  final GeminiService _geminiService = GeminiService(); // Added instance

  Story? _story;
  bool _isLoading = true;
  bool _isGeneratingVoice = false;
  int _selectedSceneIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final story = await _databaseHelper.getStory(widget.storyId);

      if (mounted) {
        setState(() {
          _story = story;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading story: $e'),
            backgroundColor: AppColors.accent4,
          ),
        );
      }
    }
  }

  void _handleSceneSelection(int index) {
    setState(() {
      _selectedSceneIndex = index;
    });
  }

  Future<void> _handleVoiceGeneration(Script script) async {
    if (_story == null) return;

    try {
      setState(() {
        _isGeneratingVoice = true;
      });

      // Initialize ElevenLabs service if needed
      await _elevenLabsService.initialize();

      // Find character associated with this script (null for narrator)
      Character? character;
      String? voiceId;

      if (script.characterId != null) {
        character = _story!.characters.firstWhere(
          (char) => char.id == script.characterId,
          orElse: () => throw Exception('Character not found'),
        );
        voiceId = character.voiceId;
      }

      // Create output directory for audio files if it doesn't exist
      final appDocDir = await getApplicationDocumentsDirectory();
      final outputDir = Directory('${appDocDir.path}/voiceovers');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Generate a filename for the audio file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'script_${script.id}_$timestamp.mp3';
      final outputPath = '${outputDir.path}/$filename';

      // Generate the voiceover
      await _elevenLabsService.generateVoiceover(
        text: script.scriptText,
        outputPath: outputPath,
        gender: character?.gender,
        voiceDescription: character?.voiceDescription,
        voiceId: voiceId,
      );

      // Update the script with the new voiceover path
      await _databaseHelper.updateScriptVoiceoverPath(script.id!, outputPath);

      // Reload the story to get the updated data
      await _loadStory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice generated successfully'),
            backgroundColor: AppColors.accent2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating voice: $e'),
            backgroundColor: AppColors.accent4,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingVoice = false;
        });
      }
    }
  }

  Future<void> _handleCharacterVoiceSelection(
    Character character,
    String voiceId,
  ) async {
    try {
      await _databaseHelper.updateCharacterVoiceId(character.id!, voiceId);
      await _loadStory(); // Reload to get updated data

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice updated for ${character.name}'),
            backgroundColor: AppColors.accent2,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating voice: $e'),
            backgroundColor: AppColors.accent4,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_story?.title ?? 'Story Editor'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Implement save functionality
            },
            tooltip: 'Save Changes',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // TODO: Implement story playback
            },
            tooltip: 'Preview Story',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _story == null
              ? const Center(child: Text('Story not found'))
              : ContentContainer(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left sidebar with scenes list
                    ScenesSidebar(
                      scenes: _story!.scenes,
                      selectedSceneIndex: _selectedSceneIndex,
                      onSceneSelected: _handleSceneSelection,
                    ),

                    // Main content area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Story details with characters column
                            Consumer(
                              builder: (context, ref, _) {
                                final userVoicesData = ref.watch(
                                  userVoicesProvider,
                                );
                                final userVoicesNotifier = ref.read(
                                  userVoicesProvider.notifier,
                                );

                                return StoryDetailsCard(
                                  story: _story!,
                                  onStoryUpdated: _loadStory,
                                  onVoiceSelected:
                                      _handleCharacterVoiceSelection,
                                  voices: userVoicesData.voices,
                                  onPreviewVoice: (voiceId) {
                                    userVoicesNotifier.playVoicePreview(
                                      voiceId,
                                      "Hello, this is a sample preview.", // Default preview text
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Selected scene details
                            if (_story!.scenes.isNotEmpty)
                              SceneDetails(
                                scene: _story!.scenes[_selectedSceneIndex],
                                characters: _story!.characters,
                                onGenerateVoice: _handleVoiceGeneration,
                                storyTitle: _story!.title, // Added
                                dbHelper: _databaseHelper, // Added
                                geminiService: _geminiService, // Added
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      // Show loading indicator overlay when generating voice
      floatingActionButton:
          _isGeneratingVoice
              ? FloatingActionButton(
                onPressed: null,
                backgroundColor: AppColors.primary,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : null,
    );
  }
}
