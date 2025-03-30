import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';
import '../../database/database_helper.dart';
import '../../models/story.dart';
import '../../prompts/story_generation_prompt.dart';

class StoryGeneratorHelper {
  /// Build the user message from all form inputs
  static String buildUserMessage({
    required String storyIdea,
    String? title,
    String? genre,
    String? era,
    String? setting,
    bool isHistorical = false,
    String? characterInformation,
  }) {
    final StringBuffer message = StringBuffer();

    // Add the story idea
    message.writeln('Story Idea: ${storyIdea.trim()}');
    message.writeln();

    // Add title if provided
    if (title != null && title.isNotEmpty) {
      message.writeln('Title: ${title.trim()}');
      message.writeln();
    }

    // Add genre if selected
    if (genre != null && genre.isNotEmpty) {
      message.writeln('Genre: $genre');
    }

    // Add era if selected
    if (era != null && era.isNotEmpty) {
      message.writeln('Era: $era');
    }

    // Add setting if selected
    if (setting != null && setting.isNotEmpty) {
      message.writeln('Setting: $setting');
    }

    // Add historical flag if selected
    if (isHistorical) {
      message.writeln('Include Historical Elements: Yes');
    }

    // Add character information if provided
    if (characterInformation != null && characterInformation.isNotEmpty) {
      message.writeln();
      message.writeln('Characters:');
      message.writeln(characterInformation);
    }

    return message.toString();
  }

  /// Generate a story using Gemini API
  static Future<int> generateStory({
    required String storyIdea,
    required String title,
    String? genre,
    String? era,
    String? setting,
    bool isHistorical = false,
    String? characterInformation,
  }) async {
    try {
      // First save the story to the database to get an ID
      final dbHelper = DatabaseHelper();

      // Create a new Story object with basic info
      final story = Story(
        title: title.isNotEmpty ? title : 'Untitled Story',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Insert the story and get its ID
      final int storyId = await dbHelper.insertStory(story);

      // Get the Gemini service instance
      final geminiService = GeminiService();

      // Prepare the user message with all inputs
      final String userMessage = buildUserMessage(
        storyIdea: storyIdea,
        title: title,
        genre: genre,
        era: era,
        setting: setting,
        isHistorical: isHistorical,
        characterInformation: characterInformation,
      );

      // Get the system prompt
      final String systemPrompt = StoryGenerationPrompt.getSystemPrompt();

      // Generate the story with the storyId to save the AI response
      await geminiService.generateStory(
        systemPrompt,
        userMessage,
        storyId: storyId,
      );

      return storyId;
    } catch (e) {
      debugPrint('Error generating story: $e');
      throw Exception('Failed to generate story: $e');
    }
  }
}