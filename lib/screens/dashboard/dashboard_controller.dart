import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../services/contextual_error_handler.dart';
import '../../services/error_service.dart';
import '../../services/error_type.dart';
import '../../services/error_feedback_level.dart';
import '../../services/retry_service.dart';
import '../../services/retry_strategy.dart';
import '../../utils/constants.dart';

/// DashboardController
/// Handles business logic and database operations for the dashboard screen
/// Consolidated controller that combines functionality from previous versions
class DashboardController {
  // Static test controller for unit testing
  static DashboardController? testController;
  // Build context for error handling
  BuildContext? context;
  // State notifiers
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<List<Member>> memberList = ValueNotifier<List<Member>>([]);
  final ValueNotifier<List<Project>> projectList = ValueNotifier<List<Project>>([]);
  final ValueNotifier<List<Booking>> bookingList = ValueNotifier<List<Booking>>([]);
  final ValueNotifier<List<Studio>> studioList = ValueNotifier<List<Studio>>([]);
  final ValueNotifier<List<ActivityLog>> recentActivity = ValueNotifier<List<ActivityLog>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Dashboard statistics
  final ValueNotifier<int> gearOutCount = ValueNotifier<int>(0);
  final ValueNotifier<int> bookingsTodayCount = ValueNotifier<int>(0);
  final ValueNotifier<int> gearReturningCount = ValueNotifier<int>(0);
  final ValueNotifier<Booking?> studioBookingToday = ValueNotifier<Booking?>(null);

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Dispose of resources
  void dispose() {
    // Dispose of all ValueNotifiers
    gearList.dispose();
    memberList.dispose();
    projectList.dispose();
    bookingList.dispose();
    studioList.dispose();
    recentActivity.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    gearOutCount.dispose();
    bookingsTodayCount.dispose();
    gearReturningCount.dispose();
    studioBookingToday.dispose();
  }

  // Initialize the controller with lazy loading
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Load essential data first (statistics and recent activity)
      await Future.wait([
        _loadDashboardStatistics(),
        _loadRecentActivity(),
      ]);

      // Then load the rest of the data in the background
      _loadRemainingDataInBackground();
    } catch (e, stackTrace) {
      errorMessage.value = ErrorService.handleError(e, stackTrace: stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.database,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error initializing dashboard', e, stackTrace);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Load remaining data in the background
  Future<void> _loadRemainingDataInBackground() async {
    try {
      await Future.wait([
        _loadGear(),
        _loadMembers(),
        _loadProjects(),
        _loadBookings(),
        _loadStudios(),
      ]);
    } catch (e, stackTrace) {
      LogService.error('Error loading background data', e, stackTrace);
      // Don't show errors for background loading
    }
  }

  // Generic method to load data with retry and error handling
  Future<T> _loadDataWithRetry<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      // Use retry logic for database operations
      return await RetryService.retry<T>(
        operation: operation,
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error $operationName', e, stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          type: ErrorType.database,
          stackTrace: stackTrace,
          feedbackLevel: ErrorFeedbackLevel.silent, // Silent because we're rethrowing
        );
      }

      rethrow;
    }
  }

  // Load gear from database
  Future<void> _loadGear() async {
    final gear = await _loadDataWithRetry<List<Gear>>(
      () => DBService.getAllGear(),
      'loading gear',
    );
    gearList.value = gear;
  }

  // Load members from database
  Future<void> _loadMembers() async {
    final members = await _loadDataWithRetry<List<Member>>(
      () => DBService.getAllMembers(),
      'loading members',
    );
    memberList.value = members;
  }

  // Load projects from database
  Future<void> _loadProjects() async {
    final projects = await _loadDataWithRetry<List<Project>>(
      () => DBService.getAllProjects(),
      'loading projects',
    );
    projectList.value = projects;
  }

  // Load bookings from database
  Future<void> _loadBookings() async {
    final bookings = await _loadDataWithRetry<List<Booking>>(
      () => DBService.getAllBookings(),
      'loading bookings',
    );
    bookingList.value = bookings;
  }

  // Load studios from database
  Future<void> _loadStudios() async {
    try {
      final studios = await _loadDataWithRetry<List<Studio>>(
        () => DBService.getAllStudios(),
        'loading studios',
      );
      studioList.value = studios;
    } catch (e) {
      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if the studio table doesn't exist
      studioList.value = [];
    }
  }

  // Load recent activity from database
  Future<void> _loadRecentActivity() async {
    try {
      final activity = await _loadDataWithRetry<List<ActivityLog>>(
        () => DBService.getRecentActivityLogs(),
        'loading activity logs',
      );
      recentActivity.value = activity;
    } catch (e) {
      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if activity logs fail to load
      recentActivity.value = [];
      rethrow; // Still rethrow to trigger error handling in initialize()
    }
  }

  // Load dashboard statistics from database
  Future<void> _loadDashboardStatistics() async {
    try {
      // Load all statistics in parallel for efficiency
      final results = await Future.wait([
        _loadDataWithRetry<int>(
          () => DBService.getGearOutCount(),
          'loading gear out count',
        ),
        _loadDataWithRetry<int>(
          () => DBService.getBookingsTodayCount(),
          'loading bookings today count',
        ),
        _loadDataWithRetry<int>(
          () => DBService.getGearReturningSoonCount(),
          'loading gear returning soon count',
        ),
        _loadDataWithRetry<Booking?>(
          () => DBService.getStudioBookingToday(),
          'loading studio booking today',
        ),
      ]);

      // Update the value notifiers
      gearOutCount.value = results[0] as int;
      bookingsTodayCount.value = results[1] as int;
      gearReturningCount.value = results[2] as int;
      studioBookingToday.value = results[3] as Booking?;
    } catch (e) {
      // Set default values instead of rethrowing
      // This allows the dashboard to continue functioning even if statistics fail to load
      gearOutCount.value = 0;
      bookingsTodayCount.value = 0;
      gearReturningCount.value = 0;
      studioBookingToday.value = null;
      rethrow; // Still rethrow to trigger error handling in initialize()
    }
  }

  // Check out gear to a member
  Future<bool> checkOutGear(Gear gear, Member member, {String? note}) async {
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

    if (member.id == null) {
      errorMessage.value = Constants.memberNotFound;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          Constants.memberNotFound,
          type: ErrorType.validation,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Use retry logic for database operations
      final success = await RetryService.retry<bool>(
        operation: () => DBService.checkOutGear(gear.id!, member.id!, note: note),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      if (success) {
        // Reload data
        await Future.wait([
          _loadGear(),
          _loadRecentActivity(),
        ]);

        // Show success message if context is available
        if (context != null) {
          ErrorService.showSuccessSnackBar(context!, 'Gear checked out successfully');
        }

        return true;
      } else {
        errorMessage.value = Constants.gearAlreadyCheckedOut;

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            Constants.gearAlreadyCheckedOut,
            type: ErrorType.conflict,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg = '${Constants.generalError} ${e.toString()}';
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
        LogService.error('Error checking out gear', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check in gear
  Future<bool> checkInGear(Gear gear, {String? note}) async {
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

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Use retry logic for database operations
      final success = await RetryService.retry<bool>(
        operation: () => DBService.checkInGear(gear.id!, note: note),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      if (success) {
        // Reload data
        await Future.wait([
          _loadGear(),
          _loadRecentActivity(),
        ]);

        // Show success message if context is available
        if (context != null) {
          ErrorService.showSuccessSnackBar(context!, 'Gear checked in successfully');
        }

        return true;
      } else {
        errorMessage.value = Constants.gearAlreadyCheckedIn;

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            Constants.gearAlreadyCheckedIn,
            type: ErrorType.conflict,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }
    } catch (e, stackTrace) {
      final errorMsg = '${Constants.generalError} ${e.toString()}';
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
        LogService.error('Error checking in gear', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Search gear by name or category
  List<Gear> searchGear(String query) {
    if (query.isEmpty) {
      return gearList.value;
    }

    final lowerQuery = query.toLowerCase();
    return gearList.value.where((gear) {
      return gear.name.toLowerCase().contains(lowerQuery) ||
             gear.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get bookings for today
  List<Booking> getTodayBookings() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return bookingList.value.where((booking) {
      final bookingDate = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      return bookingDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get studio by ID
  Studio? getStudioById(int id) {
    try {
      return studioList.value.firstWhere((studio) => studio.id == id);
    } catch (e) {
      return null;
    }
  }

  // Legacy conversion methods removed

  // Refresh dashboard statistics only
  Future<void> refreshDashboardStatistics() async {
    try {
      await _loadDashboardStatistics();
    } catch (e, stackTrace) {
      LogService.error('Error refreshing dashboard statistics', e, stackTrace);

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
    }
  }

  // Refresh only essential dashboard data (faster than full initialize)
  Future<void> refreshEssentialData() async {
    try {
      // Show loading indicator
      isLoading.value = true;
      errorMessage.value = null;

      // Load only the essential data for the dashboard
      await Future.wait([
        _loadGear(),         // For gear status
        _loadBookings(),    // For bookings today
        _loadDashboardStatistics(), // For summary statistics
      ]);

      // Show success message if context is available
      if (context != null) {
        ErrorService.showSuccessSnackBar(context!, 'Dashboard refreshed');
      }
    } catch (e, stackTrace) {
      errorMessage.value = ErrorService.handleError(e, stackTrace: stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.database,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error refreshing dashboard data', e, stackTrace);
      }
    } finally {
      isLoading.value = false;
    }
  }


}
