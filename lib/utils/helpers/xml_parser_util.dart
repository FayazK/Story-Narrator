// lib/utils/helpers/xml_parser_util.dart
import 'package:flutter/foundation.dart';

/// Utility class to standardize XML parsing and extraction across the application
class XmlParserUtil {
  /// Extract XML content from a text that may contain other content
  /// Handles various formats including backticks, markdown, etc.
  static String extractXmlFromText(String text) {
    try {
      // Try to extract the XML part using multiple patterns
      // Pattern 1: Simple story tags
      final RegExp storyRegex = RegExp(r'<story>.*?</story>', dotAll: true);
      final match = storyRegex.firstMatch(text);
      
      if (match != null) {
        // Return just the XML content
        return match.group(0) ?? '';
      }
      
      // Pattern 2: XML with code block backticks
      final RegExp xmlWithBackticksRegex = RegExp(r'```(?:xml)?\s*(<story>.*?</story>)\s*```', dotAll: true);
      final backtickMatch = xmlWithBackticksRegex.firstMatch(text);
      
      if (backtickMatch != null && backtickMatch.groupCount >= 1) {
        return backtickMatch.group(1) ?? '';
      }
      
      // Pattern 3: XML with story_details (more specific pattern)
      final RegExp detailsRegex = RegExp(r'<story>\s*<story_details>.*?</story>', dotAll: true);
      final detailsMatch = detailsRegex.firstMatch(text);
      
      if (detailsMatch != null) {
        return detailsMatch.group(0) ?? '';
      }
      
      // Pattern 4: Look for any XML-like structure if all else fails
      final RegExp anyXmlRegex = RegExp(r'<[^>]+>.*?</[^>]+>', dotAll: true);
      final anyMatch = anyXmlRegex.firstMatch(text);
      
      if (anyMatch != null) {
        debugPrint('Warning: Using fallback XML extraction pattern');
        return anyMatch.group(0) ?? '';
      }
      
      // If no match found, return the original text
      return text;
    } catch (e) {
      debugPrint('Error extracting XML: $e');
      return text; // Return original text on error
    }
  }
  
  /// Clean XML string by removing comments, formatting, etc.
  static String cleanXmlString(String xmlString) {
    // Remove any XML declaration line if present
    var cleaned = xmlString.replaceAll(RegExp(r'<\?xml.*?\?>', caseSensitive: false), '');
    
    // Remove any comments
    cleaned = cleaned.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    
    // Remove any whitespace between tags to normalize
    cleaned = cleaned.replaceAll(RegExp(r'>\s+<'), '><');
    
    // Remove any backticks from code blocks
    cleaned = cleaned.replaceAll('```xml', '').replaceAll('```', '');
    
    // Try to ensure there's only one story element
    if (cleaned.contains('</story><story>')) {
      // Take only the first story element if multiple are present
      final regex = RegExp(r'<story>.*?</story>', dotAll: true);
      final match = regex.firstMatch(cleaned);
      if (match != null) {
        cleaned = match.group(0) ?? cleaned;
      }
    }
    
    return cleaned.trim();
  }
}
