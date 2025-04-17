import 'package:flutter/material.dart';

/// ProjectIconService
/// Service for mapping project types to specific icons
class ProjectIconService {
  /// Get the icon for a project based on its title and client
  static IconData getIconForProject(String title, String? client) {
    final normalizedTitle = title.toLowerCase().trim();
    final normalizedClient = client?.toLowerCase().trim() ?? '';
    
    // Check for specific project types in the title
    if (_containsAny(normalizedTitle, ['commercial', 'ad', 'advertisement', 'promo'])) {
      return Icons.monetization_on;
    }
    
    if (_containsAny(normalizedTitle, ['music', 'video', 'mv', 'music video'])) {
      return Icons.music_note;
    }
    
    if (_containsAny(normalizedTitle, ['documentary', 'doc', 'interview'])) {
      return Icons.mic;
    }
    
    if (_containsAny(normalizedTitle, ['film', 'movie', 'short', 'feature'])) {
      return Icons.movie;
    }
    
    if (_containsAny(normalizedTitle, ['wedding', 'event', 'ceremony'])) {
      return Icons.celebration;
    }
    
    if (_containsAny(normalizedTitle, ['corporate', 'training', 'business'])) {
      return Icons.business;
    }
    
    if (_containsAny(normalizedTitle, ['photo', 'photography', 'portrait', 'headshot'])) {
      return Icons.photo_camera;
    }
    
    if (_containsAny(normalizedTitle, ['podcast', 'audio', 'radio'])) {
      return Icons.podcasts;
    }
    
    // Check for specific client types
    if (_containsAny(normalizedClient, ['music', 'band', 'artist', 'label'])) {
      return Icons.music_note;
    }
    
    if (_containsAny(normalizedClient, ['corp', 'inc', 'llc', 'company', 'business'])) {
      return Icons.business;
    }
    
    if (_containsAny(normalizedClient, ['non-profit', 'nonprofit', 'charity', 'foundation', 'org'])) {
      return Icons.volunteer_activism;
    }
    
    // Default icon
    return Icons.folder_special;
  }
  
  /// Get the color for a project based on its title and client
  static Color getColorForProject(String title, String? client) {
    final normalizedTitle = title.toLowerCase().trim();
    final normalizedClient = client?.toLowerCase().trim() ?? '';
    
    // Check for specific project types in the title
    if (_containsAny(normalizedTitle, ['commercial', 'ad', 'advertisement', 'promo'])) {
      return Colors.green;
    }
    
    if (_containsAny(normalizedTitle, ['music', 'video', 'mv', 'music video'])) {
      return Colors.purple;
    }
    
    if (_containsAny(normalizedTitle, ['documentary', 'doc', 'interview'])) {
      return Colors.blue;
    }
    
    if (_containsAny(normalizedTitle, ['film', 'movie', 'short', 'feature'])) {
      return Colors.red;
    }
    
    if (_containsAny(normalizedTitle, ['wedding', 'event', 'ceremony'])) {
      return Colors.pink;
    }
    
    if (_containsAny(normalizedTitle, ['corporate', 'training', 'business'])) {
      return Colors.amber;
    }
    
    if (_containsAny(normalizedTitle, ['photo', 'photography', 'portrait', 'headshot'])) {
      return Colors.teal;
    }
    
    if (_containsAny(normalizedTitle, ['podcast', 'audio', 'radio'])) {
      return Colors.deepOrange;
    }
    
    // Check for specific client types
    if (_containsAny(normalizedClient, ['music', 'band', 'artist', 'label'])) {
      return Colors.purple;
    }
    
    if (_containsAny(normalizedClient, ['corp', 'inc', 'llc', 'company', 'business'])) {
      return Colors.amber;
    }
    
    if (_containsAny(normalizedClient, ['non-profit', 'nonprofit', 'charity', 'foundation', 'org'])) {
      return Colors.lightBlue;
    }
    
    // Default color
    return Colors.blueGrey;
  }
  
  /// Check if a string contains any of the given keywords
  static bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
