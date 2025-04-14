import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/image_service.dart';
import '../../utils/constants.dart';

/// AddGearController
/// Handles business logic and database operations for the add gear screen
class AddGearController {
  // State notifiers
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isSuccess = ValueNotifier<bool>(false);

  // Form values
  final ValueNotifier<String> name = ValueNotifier<String>('');
  final ValueNotifier<String> category = ValueNotifier<String>(Constants.gearCategories.first);
  final ValueNotifier<String> description = ValueNotifier<String>('');
  final ValueNotifier<String> serialNumber = ValueNotifier<String>('');
  final ValueNotifier<DateTime?> purchaseDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<String?> thumbnailPath = ValueNotifier<String?>(null);

  // Validation
  bool validateForm() {
    // Reset error message
    errorMessage.value = null;

    // Validate name
    if (name.value.trim().isEmpty) {
      errorMessage.value = 'Name is required';
      return false;
    }

    // Validate category
    if (category.value.trim().isEmpty) {
      errorMessage.value = 'Category is required';
      return false;
    }

    return true;
  }

  // Save gear to database
  Future<bool> saveGear() async {
    // Validate form
    if (!validateForm()) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Process image if selected
      String? finalImagePath;
      if (thumbnailPath.value != null && thumbnailPath.value!.isNotEmpty) {
        try {
          final imageFile = File(thumbnailPath.value!);
          if (await imageFile.exists()) {
            final savedPath = await ImageService.saveImage(imageFile, name.value.trim());
            if (savedPath != null) {
              finalImagePath = savedPath;
            }
          }
        } catch (e) {
          print('Error processing image: $e');
          // Continue without the image if there's an error
        }
      }

      // Create gear object
      final gear = Gear(
        name: name.value.trim(),
        category: category.value,
        description: description.value.trim().isNotEmpty ? description.value.trim() : null,
        serialNumber: serialNumber.value.trim().isNotEmpty ? serialNumber.value.trim() : null,
        purchaseDate: purchaseDate.value,
        thumbnailPath: finalImagePath,
        isOut: false, // Explicitly set isOut to false
        lastNote: null,
      );

      // Save to database
      final id = await DBService.insertGear(gear);

      if (id > 0) {
        isSuccess.value = true;
        return true;
      } else {
        errorMessage.value = 'Failed to save gear';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      // Use a logger in production code instead of print
      // print('Error saving gear: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Set thumbnail path
  void setThumbnailPath(String path) {
    thumbnailPath.value = path;
  }

  // Set purchase date
  void setPurchaseDate(DateTime date) {
    purchaseDate.value = date;
  }

  // Reset form
  void resetForm() {
    name.value = '';
    category.value = Constants.gearCategories.first;
    description.value = '';
    serialNumber.value = '';
    purchaseDate.value = null;
    thumbnailPath.value = null;
    errorMessage.value = null;
    isSuccess.value = false;
  }

  // Dispose resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    isSuccess.dispose();
    name.dispose();
    category.dispose();
    description.dispose();
    serialNumber.dispose();
    purchaseDate.dispose();
    thumbnailPath.dispose();
  }
}
