import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/constants.dart';

/// GearManagementController
/// Handles business logic for gear management operations
class GearManagementController {
  // Build context for error handling
  BuildContext? context;

  // State notifiers
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<List<Gear>> filteredGearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Initialize the controller
  Future<void> initialize() async {
    await loadGear();

    // Set up listeners
    searchQuery.addListener(_applyFilters);
  }

  // Load gear from the database
  Future<void> loadGear() async {
    // Clear the cache to ensure we get fresh data
    CacheService().remove('all_gear');

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final gear = await DBService.getAllGear();
      gearList.value = gear;
      _applyFilters();
    } catch (e, stackTrace) {
      LogService.error('Failed to load gear', e, stackTrace);
      errorMessage.value = ErrorService.getUserFriendlyMessage(
        ErrorType.database,
        e.toString(),
      );

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Apply search filter
  void _applyFilters() {
    final query = searchQuery.value.toLowerCase();

    final filtered = gearList.value.where((gear) {
      // Apply search filter
      final matchesSearch = query.isEmpty ||
          gear.name.toLowerCase().contains(query) ||
          gear.category.toLowerCase().contains(query) ||
          (gear.serialNumber?.toLowerCase().contains(query) ?? false) ||
          (gear.description?.toLowerCase().contains(query) ?? false);

      return matchesSearch;
    }).toList();

    filteredGearList.value = filtered;
  }

  // Delete a gear item
  Future<bool> deleteGear(int gearId) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final success = await DBService.deleteGear(gearId);

      if (success > 0) {
        // Update local lists
        final updatedList = List<Gear>.from(gearList.value)
          ..removeWhere((gear) => gear.id == gearId);
        gearList.value = updatedList;
        _applyFilters();
      }

      return success > 0;
    } catch (e, stackTrace) {
      LogService.error('Failed to delete gear', e, stackTrace);
      errorMessage.value = ErrorService.getUserFriendlyMessage(
        ErrorType.database,
        e.toString(),
      );

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check out gear to a member
  Future<bool> checkOutGear(int gearId, int memberId, {String? note}) async {
    // Validate gear is not already checked out
    final gear = gearList.value.firstWhere(
      (g) => g.id == gearId,
      orElse: () => Gear(id: null, name: '', category: ''),
    );

    if (gear.id == null) {
      errorMessage.value = Constants.gearNotFound;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          Constants.gearNotFound,
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    }

    if (gear.isOut) {
      errorMessage.value = 'This gear is already checked out';

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          'This gear is already checked out',
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Clear the cache before the operation to ensure fresh data
      CacheService().remove('all_gear');

      final success = await DBService.checkOutGear(
        gearId,
        memberId,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Update the local gear item to reflect the change immediately
        final updatedGear = gear.copyWith(isOut: true, lastNote: note);

        // Update the gear in the local lists
        final updatedList = List<Gear>.from(gearList.value);
        final index = updatedList.indexWhere((g) => g.id == gearId);
        if (index >= 0) {
          updatedList[index] = updatedGear;
          gearList.value = updatedList;
          _applyFilters();
        }
      }

      return success;
    } catch (e, stackTrace) {
      LogService.error('Failed to check out gear', e, stackTrace);
      errorMessage.value = ErrorService.getUserFriendlyMessage(
        ErrorType.database,
        e.toString(),
      );

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check in gear
  Future<bool> checkInGear(int gearId, {String? note}) async {
    // Validate gear is checked out
    final gear = gearList.value.firstWhere(
      (g) => g.id == gearId,
      orElse: () => Gear(id: null, name: '', category: ''),
    );

    if (gear.id == null) {
      errorMessage.value = Constants.gearNotFound;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          Constants.gearNotFound,
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    }

    if (!gear.isOut) {
      errorMessage.value = 'This gear is already checked in';

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          'This gear is already checked in',
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Clear the cache before the operation to ensure fresh data
      CacheService().remove('all_gear');

      final success = await DBService.checkInGear(
        gearId,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Update the local gear item to reflect the change immediately
        final updatedGear = gear.copyWith(isOut: false, lastNote: note);

        // Update the gear in the local lists
        final updatedList = List<Gear>.from(gearList.value);
        final index = updatedList.indexWhere((g) => g.id == gearId);
        if (index >= 0) {
          updatedList[index] = updatedGear;
          gearList.value = updatedList;
          _applyFilters();
        }
      }

      return success;
    } catch (e, stackTrace) {
      LogService.error('Failed to check in gear', e, stackTrace);
      errorMessage.value = ErrorService.getUserFriendlyMessage(
        ErrorType.database,
        e.toString(),
      );

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get a gear item by ID
  Gear? getGearById(int id) {
    try {
      return gearList.value.firstWhere((gear) => gear.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    gearList.dispose();
    filteredGearList.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    searchQuery.dispose();
  }
}
