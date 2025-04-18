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
import '../../theme/blkwds_colors.dart';

/// CalendarController
/// Handles state management and business logic for the Calendar screen
class CalendarController {
  // Build context for error handling
  BuildContext? context;
  // Value notifiers for reactive UI updates
  final ValueNotifier<List<Booking>> bookingList = ValueNotifier<List<Booking>>([]);
  final ValueNotifier<List<Project>> projectList = ValueNotifier<List<Project>>([]);
  final ValueNotifier<List<Member>> memberList = ValueNotifier<List<Member>>([]);
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Filter state
  final ValueNotifier<int?> selectedProjectId = ValueNotifier<int?>(null);
  final ValueNotifier<int?> selectedMemberId = ValueNotifier<int?>(null);
  final ValueNotifier<int?> selectedGearId = ValueNotifier<int?>(null);
  final ValueNotifier<DateTime?> filterStartDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> filterEndDate = ValueNotifier<DateTime?>(null);

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Initialize controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await Future.wait([
        _loadBookings(),
        _loadProjects(),
        _loadMembers(),
        _loadGear(),
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
        LogService.error('Error initializing data', e, stackTrace);
      }
    } finally {
      isLoading.value = false;
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

  // Get filtered bookings
  List<Booking> getFilteredBookings() {
    List<Booking> filteredBookings = List.from(bookingList.value);

    // Filter by project
    if (selectedProjectId.value != null) {
      filteredBookings = filteredBookings.where((booking) =>
        booking.projectId == selectedProjectId.value
      ).toList();
    }

    // Filter by member
    if (selectedMemberId.value != null) {
      filteredBookings = filteredBookings.where((booking) {
        // Check if the member is assigned to any gear in this booking
        if (booking.assignedGearToMember != null) {
          return booking.assignedGearToMember!.values.contains(selectedMemberId.value);
        }
        return false;
      }).toList();
    }

    // Filter by gear
    if (selectedGearId.value != null) {
      filteredBookings = filteredBookings.where((booking) =>
        booking.gearIds.contains(selectedGearId.value)
      ).toList();
    }

    // Filter by date range
    if (filterStartDate.value != null) {
      filteredBookings = filteredBookings.where((booking) =>
        booking.endDate.isAfter(filterStartDate.value!)
      ).toList();
    }

    if (filterEndDate.value != null) {
      filteredBookings = filteredBookings.where((booking) =>
        booking.startDate.isBefore(filterEndDate.value!)
      ).toList();
    }

    return filteredBookings;
  }

  // Reset all filters
  void resetFilters() {
    selectedProjectId.value = null;
    selectedMemberId.value = null;
    selectedGearId.value = null;
    filterStartDate.value = null;
    filterEndDate.value = null;
  }

  // Get bookings for a specific day
  List<Booking> getBookingsForDay(DateTime day) {
    final filteredBookings = getFilteredBookings();
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return filteredBookings.where((booking) {
      // Check if booking overlaps with the day
      return (booking.startDate.isBefore(endOfDay) ||
              booking.startDate.isAtSameMomentAs(endOfDay)) &&
             (booking.endDate.isAfter(startOfDay) ||
              booking.endDate.isAtSameMomentAs(startOfDay));
    }).toList();
  }

  // Get bookings in a date range
  List<Booking> getBookingsInRange(DateTime start, DateTime end) {
    final filteredBookings = getFilteredBookings();

    return filteredBookings.where((booking) {
      // Check if booking overlaps with the range
      return (booking.startDate.isBefore(end) ||
              booking.startDate.isAtSameMomentAs(end)) &&
             (booking.endDate.isAfter(start) ||
              booking.endDate.isAtSameMomentAs(start));
    }).toList();
  }

  // Check if a day has any bookings
  bool hasBookingsOnDay(DateTime day) {
    return getBookingsForDay(day).isNotEmpty;
  }

  // Get color for a booking based on project
  Color getColorForBooking(Booking booking) {
    final project = getProjectById(booking.projectId);
    if (project != null) {
      // Use a hash-based approach to generate a color
      final int hash = project.title.hashCode;
      final List<Color> projectColors = [
        BLKWDSColors.mustardOrange,
        BLKWDSColors.electricMint,
        BLKWDSColors.accentTeal,
        BLKWDSColors.blkwdsGreen,
      ];

      return projectColors[hash.abs() % projectColors.length];
    }
    return BLKWDSColors.slateGrey;
  }

  // Get project by ID
  Project? getProjectById(int id) {
    try {
      return projectList.value.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get member by ID
  Member? getMemberById(int id) {
    try {
      return memberList.value.firstWhere((member) => member.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get gear by ID
  Gear? getGearById(int id) {
    try {
      return gearList.value.firstWhere((gear) => gear.id == id);
    } catch (e) {
      return null;
    }
  }

  // Dispose resources
  void dispose() {
    bookingList.dispose();
    projectList.dispose();
    memberList.dispose();
    gearList.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    selectedProjectId.dispose();
    selectedMemberId.dispose();
    selectedGearId.dispose();
    filterStartDate.dispose();
    filterEndDate.dispose();
  }
}
