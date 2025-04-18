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

  // Initialize the controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Load data from database
      await Future.wait([
        _loadGear(),
        _loadMembers(),
        _loadProjects(),
        _loadBookings(),
        _loadStudios(),
        _loadRecentActivity(),
        _loadDashboardStatistics(),
      ]);
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

  // Load gear from database
  Future<void> _loadGear() async {
    try {
      // Use retry logic for database operations
      final gear = await RetryService.retry<List<Gear>>(
        operation: () => DBService.getAllGear(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      gearList.value = gear;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading gear', e, stackTrace);

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

  // Load members from database
  Future<void> _loadMembers() async {
    try {
      // Use retry logic for database operations
      final members = await RetryService.retry<List<Member>>(
        operation: () => DBService.getAllMembers(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      memberList.value = members;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading members', e, stackTrace);

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

  // Load projects from database
  Future<void> _loadProjects() async {
    try {
      // Use retry logic for database operations
      final projects = await RetryService.retry<List<Project>>(
        operation: () => DBService.getAllProjects(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      projectList.value = projects;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading projects', e, stackTrace);

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

  // Load bookings from database
  Future<void> _loadBookings() async {
    try {
      // Use retry logic for database operations
      final bookings = await RetryService.retry<List<Booking>>(
        operation: () => DBService.getAllBookings(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      bookingList.value = bookings;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading bookings', e, stackTrace);

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

  // Load studios from database
  Future<void> _loadStudios() async {
    try {
      // Use retry logic for database operations
      final studios = await RetryService.retry<List<Studio>>(
        operation: () => DBService.getAllStudios(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      studioList.value = studios;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading studios', e, stackTrace);

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

      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if the studio table doesn't exist
      studioList.value = [];
    }
  }

  // Load recent activity from database
  Future<void> _loadRecentActivity() async {
    try {
      // Use retry logic for database operations
      final activity = await RetryService.retry<List<ActivityLog>>(
        operation: () => DBService.getRecentActivityLogs(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      recentActivity.value = activity;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading activity logs', e, stackTrace);

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

  // Load dashboard statistics from database
  Future<void> _loadDashboardStatistics() async {
    try {
      // Load all statistics in parallel for efficiency
      final results = await Future.wait([
        RetryService.retry<int>(
          operation: () => DBService.getGearOutCount(),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        ),
        RetryService.retry<int>(
          operation: () => DBService.getBookingsTodayCount(),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        ),
        RetryService.retry<int>(
          operation: () => DBService.getGearReturningSoonCount(),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        ),
        RetryService.retry<Booking?>(
          operation: () => DBService.getStudioBookingToday(),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        ),
      ]);

      // Update the value notifiers
      gearOutCount.value = results[0] as int;
      bookingsTodayCount.value = results[1] as int;
      gearReturningCount.value = results[2] as int;
      studioBookingToday.value = results[3] as Booking?;
    } catch (e, stackTrace) {
      // Log the error
      LogService.error('Error loading dashboard statistics', e, stackTrace);

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

      // Set default values instead of rethrowing
      // This allows the dashboard to continue functioning even if statistics fail to load
      gearOutCount.value = 0;
      bookingsTodayCount.value = 0;
      gearReturningCount.value = 0;
      studioBookingToday.value = null;
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

  // Dispose resources
  void dispose() {
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
}
