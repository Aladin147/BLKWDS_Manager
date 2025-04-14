import 'dart:io';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// ImageService
/// Handles image operations for gear thumbnails
class ImageService {
  /// Pick an image from the file system
  static Future<File?> pickImage() async {
    try {
      // Use file_selector to select an image
      final file_selector.XTypeGroup imageTypeGroup = file_selector.XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png', 'gif'],
      );

      final file_selector.XFile? file = await file_selector.openFile(
        acceptedTypeGroups: [imageTypeGroup],
      );

      if (file == null) {
        return null;
      }

      return File(file.path);
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error picking image: $e');
      return null;
    }
  }

  /// Save an image to the app's local storage
  static Future<String?> saveImage(File imageFile, String gearName) async {
    try {
      // Create a unique filename based on gear name and timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String sanitizedName = gearName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_').toLowerCase();
      final String filename = '${sanitizedName}_$timestamp${path.extension(imageFile.path)}';

      // Get the app's local storage directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');

      // Create the images directory if it doesn't exist
      final Directory imagesDirFile = Directory(imagesDir);
      if (!await imagesDirFile.exists()) {
        await imagesDirFile.create(recursive: true);
      }

      // Copy the image to the app's local storage
      final String destPath = path.join(imagesDir, filename);
      await imageFile.copy(destPath);

      return destPath;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error saving image: $e');
      return null;
    }
  }

  /// Delete an image from the app's local storage
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }

      return false;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error deleting image: $e');
      return false;
    }
  }
}
