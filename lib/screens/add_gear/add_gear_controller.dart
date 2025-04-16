import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/image_service.dart';
import '../../services/log_service.dart';
import '../../services/contextual_error_handler.dart';
import '../../services/error_service.dart';
import '../../services/error_type.dart';
import '../../services/retry_service.dart';
import '../../services/retry_strategy.dart';
import '../../utils/constants.dart';

/// AddGearController
/// Handles business logic and database operations for the add gear screen
class AddGearController {
  // Build context for error handling
  BuildContext? context;
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

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Validation
  bool validateForm() {
    // Reset error message
    errorMessage.value = null;

    // Validate name
    if (name.value.trim().isEmpty) {
      errorMessage.value = 'Name is required';

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          'Name is required',
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.toast,
        );
      }

      return false;
    }

    // Validate category
    if (category.value.trim().isEmpty) {
      errorMessage.value = 'Category is required';

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          'Category is required',
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.toast,
        );
      }

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
        } catch (e, stackTrace) {
          LogService.error('Error processing image', e, stackTrace);

          // Use contextual error handler if context is available
          if (context != null) {
            ContextualErrorHandler.handleError(
              context!,
              e,
              type: ErrorType.fileSystem,
              stackTrace: stackTrace,
              feedbackLevel: ErrorFeedbackLevel.toast,
            );
          }

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

      // Save to database with retry logic
      final id = await RetryService.retry<int>(
        operation: () => DBService.insertGear(gear),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      if (id > 0) {
        isSuccess.value = true;

        // Show success message if context is available
        if (context != null) {
          ErrorService.showSuccessSnackBar(context!, 'Gear added successfully');
        }

        return true;
      } else {
        errorMessage.value = 'Failed to save gear';

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            'Failed to save gear',
            type: ErrorType.database,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg = 'Error: ${e.toString()}';
      errorMessage.value = errorMsg;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error saving gear', e, stackTrace);
      }

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
