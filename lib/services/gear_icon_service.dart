import 'package:flutter/material.dart';

/// GearIconService
/// Service for mapping gear categories to specific icons
class GearIconService {
  /// Get the icon for a gear category
  static IconData getIconForCategory(String category) {
    final normalizedCategory = category.toLowerCase().trim();

    // Map categories to specific icons
    switch (normalizedCategory) {
      case 'camera':
        return Icons.videocam;
      case 'lens':
        return Icons.camera;
      case 'audio':
        return Icons.mic;
      case 'lighting':
        return Icons.light_mode;
      case 'stabilizer':
        return Icons.video_stable;
      case 'support':
        return Icons.architecture;
      case 'power':
        return Icons.battery_full;
      case 'storage':
        return Icons.sd_storage;
      case 'monitor':
        return Icons.desktop_windows;
      case 'grip':
        return Icons.pan_tool;
      case 'drone':
        return Icons.flight;
      case 'accessory':
        return Icons.devices;
      default:
        return Icons.devices_other;
    }
  }

  /// Get the color for a gear category
  static Color getColorForCategory(String category) {
    final normalizedCategory = category.toLowerCase().trim();

    // Map categories to specific colors
    switch (normalizedCategory) {
      case 'camera':
        return Colors.red;
      case 'lens':
        return Colors.orange;
      case 'audio':
        return Colors.blue;
      case 'lighting':
        return Colors.amber;
      case 'stabilizer':
        return Colors.green;
      case 'support':
        return Colors.brown;
      case 'power':
        return Colors.purple;
      case 'storage':
        return Colors.teal;
      case 'monitor':
        return Colors.indigo;
      case 'grip':
        return Colors.deepOrange;
      case 'drone':
        return Colors.lightBlue;
      case 'accessory':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  /// Get a list of all supported gear categories
  static List<String> getAllCategories() {
    return [
      'Camera',
      'Lens',
      'Audio',
      'Lighting',
      'Stabilizer',
      'Support',
      'Power',
      'Storage',
      'Monitor',
      'Grip',
      'Drone',
      'Accessory',
    ];
  }
}
