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

import '../../utils/date_utils.dart';
import 'models/booking_filter.dart';

/// BookingPanelController
/// Handles state management and business logic for the Booking Panel screen
class BookingPanelController {
  // Build context for error handling
  BuildContext? context;
  // Value notifiers for reactive UI updates
  final ValueNotifier<List<Booking>> bookingList = ValueNotifier<List<Booking>>([]);
  final ValueNotifier<List<Project>> projectList = ValueNotifier<List<Project>>([]);
  final ValueNotifier<List<Member>> memberList = ValueNotifier<List<Member>>([]);
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<List<Studio>> studioList = ValueNotifier<List<Studio>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Filter-related notifiers
  final ValueNotifier<BookingFilter> filter = ValueNotifier<BookingFilter>(const BookingFilter());
  final ValueNotifier<List<Booking>> filteredBookingList = ValueNotifier<List<Booking>>([]);

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Initialize controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _loadBookings();
      await _loadProjects();
      await _loadMembers();
      await _loadGear();
      await _loadStudios();

      // Initialize filtered list with all bookings
      _applyFilters();
    } catch (e, stackTrace) {
      errorMessage.value = ErrorService.handleError(e, stackTrace: stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
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
      final bookings = await loadBookings();

      bookingList.value = bookings;

      // Update filtered list when bookings change
      _applyFilters();
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

  // This method can be overridden in tests
  Future<List<Booking>> loadBookings() async {
    return await RetryService.retry<List<Booking>>(
      operation: () => DBService.getAllBookings(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Load studios from database
  Future<void> _loadStudios() async {
    try {
      // Use retry logic for database operations
      final studios = await loadStudios();

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

  // This method can be overridden in tests
  Future<List<Studio>> loadStudios() async {
    return await RetryService.retry<List<Studio>>(
      operation: () => DBService.getAllStudios(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Apply filters to the booking list
  void _applyFilters() {
    final currentFilter = filter.value;
    final allBookings = bookingList.value;

    // If no filter is active, show all bookings
    if (!currentFilter.isActive && currentFilter.sortOrder == BookingSortOrder.dateDesc) {
      filteredBookingList.value = List<Booking>.from(allBookings)
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      return;
    }

    // Apply filters
    var filtered = allBookings.where((booking) {
      // Text search filter
      if (currentFilter.searchQuery.isNotEmpty) {
        final project = getProjectById(booking.projectId);
        final searchLower = currentFilter.searchQuery.toLowerCase();

        // Search in project title
        final projectMatch = project != null &&
            project.title.toLowerCase().contains(searchLower);

        // Search in project notes
        final notesMatch = project != null &&
            project.notes?.toLowerCase().contains(searchLower) == true;

        // Search in booking title
        final bookingTitleMatch = booking.title != null &&
            booking.title!.toLowerCase().contains(searchLower);

        // If no match found, exclude this booking
        if (!projectMatch && !notesMatch && !bookingTitleMatch) {
          return false;
        }
      }

      // Date range filter
      if (currentFilter.dateRange != null) {
        final startDate = DateTime(
          currentFilter.dateRange!.start.year,
          currentFilter.dateRange!.start.month,
          currentFilter.dateRange!.start.day,
        );

        final endDate = DateTime(
          currentFilter.dateRange!.end.year,
          currentFilter.dateRange!.end.month,
          currentFilter.dateRange!.end.day,
          23, 59, 59,
        );

        // Check if booking overlaps with the date range
        if (booking.endDate.isBefore(startDate) || booking.startDate.isAfter(endDate)) {
          return false;
        }
      }

      // Project filter
      if (currentFilter.projectId != null && booking.projectId != currentFilter.projectId) {
        return false;
      }

      // Member filter
      if (currentFilter.memberId != null && booking.assignedGearToMember != null) {
        // Check if the member is assigned to any gear in this booking
        final memberAssigned = booking.assignedGearToMember!.values.contains(currentFilter.memberId);
        if (!memberAssigned) {
          return false;
        }
      }

      // Gear filter
      if (currentFilter.gearId != null && !booking.gearIds.contains(currentFilter.gearId)) {
        return false;
      }

      // Studio filter
      if (currentFilter.studioId != null && booking.studioId != currentFilter.studioId) {
        return false;
      }

      // Include this booking in the results
      return true;
    }).toList();

    // Apply sorting
    switch (currentFilter.sortOrder) {
      case BookingSortOrder.dateAsc:
        filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case BookingSortOrder.dateDesc:
        filtered.sort((a, b) => b.startDate.compareTo(a.startDate));
        break;
      case BookingSortOrder.projectAsc:
        filtered.sort((a, b) {
          final projectA = getProjectById(a.projectId)?.title ?? '';
          final projectB = getProjectById(b.projectId)?.title ?? '';
          return projectA.compareTo(projectB);
        });
        break;
      case BookingSortOrder.projectDesc:
        filtered.sort((a, b) {
          final projectA = getProjectById(a.projectId)?.title ?? '';
          final projectB = getProjectById(b.projectId)?.title ?? '';
          return projectB.compareTo(projectA);
        });
        break;
      case BookingSortOrder.durationAsc:
        filtered.sort((a, b) {
          final durationA = a.endDate.difference(a.startDate).inMinutes;
          final durationB = b.endDate.difference(b.startDate).inMinutes;
          return durationA.compareTo(durationB);
        });
        break;
      case BookingSortOrder.durationDesc:
        filtered.sort((a, b) {
          final durationA = a.endDate.difference(a.startDate).inMinutes;
          final durationB = b.endDate.difference(b.startDate).inMinutes;
          return durationB.compareTo(durationA);
        });
        break;
    }

    // Update the filtered list
    filteredBookingList.value = filtered;
  }

  // Update the filter and apply it
  void updateFilter(BookingFilter newFilter) {
    filter.value = newFilter;
    _applyFilters();
  }

  // Reset all filters
  void resetFilters() {
    filter.value = const BookingFilter();
    _applyFilters();
  }

  // Load projects from database
  Future<void> _loadProjects() async {
    try {
      // Use retry logic for database operations
      final projects = await loadProjects();

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

      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if there's a database error
      projectList.value = [];
    }
  }

  // This method can be overridden in tests
  Future<List<Project>> loadProjects() async {
    return await RetryService.retry<List<Project>>(
      operation: () => DBService.getAllProjects(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Load members from database
  Future<void> _loadMembers() async {
    try {
      // Use retry logic for database operations
      final members = await loadMembers();

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

      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if there's a database error
      memberList.value = [];
    }
  }

  // This method can be overridden in tests
  Future<List<Member>> loadMembers() async {
    return await RetryService.retry<List<Member>>(
      operation: () => DBService.getAllMembers(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Load gear from database
  Future<void> _loadGear() async {
    try {
      // Use retry logic for database operations
      final gear = await loadGear();

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

      // Set an empty list instead of rethrowing
      // This allows the app to continue functioning even if there's a database error
      gearList.value = [];
    }
  }

  // This method can be overridden in tests
  Future<List<Gear>> loadGear() async {
    return await RetryService.retry<List<Gear>>(
      operation: () => DBService.getAllGear(),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // This method can be overridden in tests
  Future<int> createBookingInDB(Booking booking) async {
    return await RetryService.retry<int>(
      operation: () => DBService.insertBooking(booking),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Create a new booking
  Future<bool> createBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for booking conflicts
      if (await hasBookingConflicts(booking)) {
        errorMessage.value = 'Booking conflicts with existing bookings';

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            'Booking conflicts with existing bookings',
            type: ErrorType.conflict,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }

      // Use retry logic for database operations
      final id = await createBookingInDB(booking);

      // Reload bookings
      await _loadBookings();

      // Show success message if context is available
      if (context != null && id > 0) {
        ErrorService.showSuccessSnackBar(context!, 'Booking created successfully');
      }

      return id > 0;
    } catch (e, stackTrace) {
      final errorMsg = 'Error creating booking: ${e.toString()}';
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
        LogService.error('Error creating booking', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // This method can be overridden in tests
  Future<int> updateBookingInDB(Booking booking) async {
    return await RetryService.retry<int>(
      operation: () => DBService.updateBooking(booking),
      maxAttempts: 3,
      strategy: RetryStrategy.exponential,
      initialDelay: const Duration(milliseconds: 500),
      retryCondition: RetryService.isRetryableError,
    );
  }

  // Update an existing booking
  Future<bool> updateBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for booking conflicts (excluding this booking)
      if (await hasBookingConflicts(booking, excludeBookingId: booking.id)) {
        errorMessage.value = 'Booking conflicts with existing bookings';

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            'Booking conflicts with existing bookings',
            type: ErrorType.conflict,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }

      // Use retry logic for database operations
      final id = await updateBookingInDB(booking);

      // Reload bookings
      await _loadBookings();

      // Show success message if context is available
      if (context != null && id > 0) {
        ErrorService.showSuccessSnackBar(context!, 'Booking updated successfully');
      }

      return id > 0;
    } catch (e, stackTrace) {
      final errorMsg = 'Error updating booking: ${e.toString()}';
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
        LogService.error('Error updating booking', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reschedule a booking to a new date/time
  /// This moves the booking while preserving its duration
  Future<bool> rescheduleBooking(Booking booking, DateTime newStartDate) async {
    // Calculate the duration of the original booking
    final duration = booking.endDate.difference(booking.startDate);

    // Create a new end date based on the new start date and the original duration
    final newEndDate = newStartDate.add(duration);

    // Create a new booking with the updated dates
    final rescheduledBooking = booking.copyWith(
      startDate: newStartDate,
      endDate: newEndDate,
    );

    // Update the booking
    return await updateBooking(rescheduledBooking);
  }

  // Delete a booking
  Future<bool> deleteBooking(int id) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Use retry logic for database operations
      final result = await RetryService.retry<int>(
        operation: () => DBService.deleteBooking(id),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Reload bookings
      await _loadBookings();

      // Show success message if context is available
      if (context != null && result > 0) {
        ErrorService.showSuccessSnackBar(context!, 'Booking deleted successfully');
      }

      return result > 0;
    } catch (e, stackTrace) {
      final errorMsg = 'Error deleting booking: ${e.toString()}';
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
        LogService.error('Error deleting booking', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a booking conflicts with existing bookings
  Future<bool> hasBookingConflicts(Booking booking, {int? excludeBookingId}) async {
    try {
      // Use retry logic for database operations
      final bookings = await RetryService.retry<List<Booking>>(
        operation: () => DBService.getAllBookings(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Filter out the booking being updated
      final otherBookings = bookings.where((b) => b.id != excludeBookingId).toList();

      // Check for time conflicts
      for (final otherBooking in otherBookings) {
        // Check if the booking overlaps with another booking
        if (_bookingsOverlap(booking, otherBooking)) {
          // Check if they share any gear
          final sharedGear = booking.gearIds.where((id) => otherBooking.gearIds.contains(id)).toList();

          if (sharedGear.isNotEmpty) {
            final conflictMsg = 'Conflict: Gear is already booked during this time';
            errorMessage.value = conflictMsg;

            // Use contextual error handler if context is available
            if (context != null) {
              ContextualErrorHandler.handleError(
                context!,
                conflictMsg,
                type: ErrorType.conflict,
                feedbackLevel: ErrorFeedbackLevel.silent, // Silent because we're handling it in the UI
              );
            }

            return true; // Conflict found
          }

          // Check if they both use the same studio
          if (booking.studioId != null &&
              otherBooking.studioId != null &&
              booking.studioId == otherBooking.studioId) {
            // Get studio name for better error message
            final studio = getStudioById(booking.studioId!);
            final conflictMsg = 'Conflict: ${studio?.name ?? 'Studio'} is already booked during this time';
            errorMessage.value = conflictMsg;

            // Use contextual error handler if context is available
            if (context != null) {
              ContextualErrorHandler.handleError(
                context!,
                conflictMsg,
                type: ErrorType.conflict,
                feedbackLevel: ErrorFeedbackLevel.silent, // Silent because we're handling it in the UI
              );
            }

            return true; // Conflict found
          }
        }
      }

      return false; // No conflicts found
    } catch (e, stackTrace) {
      final errorMsg = 'Error checking booking conflicts: ${e.toString()}';
      LogService.error('Error checking booking conflicts', e, stackTrace);
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
      }

      return true; // Assume conflict on error to be safe
    }
  }

  // Check if two bookings overlap in time
  bool _bookingsOverlap(Booking a, Booking b) {
    // a starts before b ends AND a ends after b starts
    return a.startDate.isBefore(b.endDate) && a.endDate.isAfter(b.startDate);
  }

  // Get bookings for a specific date range
  List<Booking> getBookingsInRange(DateTime start, DateTime end) {
    return bookingList.value.where((booking) {
      // booking starts before range ends AND booking ends after range starts
      return booking.startDate.isBefore(end) && booking.endDate.isAfter(start);
    }).toList();
  }

  // Get bookings for a specific day
  List<Booking> getBookingsForDay(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return getBookingsInRange(startOfDay, endOfDay);
  }

  // Check if a day has any bookings
  bool hasBookingsOnDay(DateTime day) {
    return getBookingsForDay(day).isNotEmpty;
  }

  // Get color for a booking based on project
  Color getColorForBooking(Booking booking) {
    // If booking has a custom color, use it
    if (booking.color != null) {
      return Color(int.parse(booking.color!.substring(1, 7), radix: 16) + 0xFF000000);
    }

    // If booking has a studio, use the studio color
    if (booking.studioId != null) {
      final studio = getStudioById(booking.studioId!);
      if (studio != null && studio.color != null) {
        return Color(int.parse(studio.color!.substring(1, 7), radix: 16) + 0xFF000000);
      }
    }

    // Fall back to project-based color
    final project = getProjectById(booking.projectId);
    if (project != null) {
      // Use a hash-based approach to generate a color
      return Color((project.hashCode & 0xFFFFFF) | 0xFF000000);
    }

    return BLKWDSColors.slateGrey;
  }

  // Get bookings for a specific project
  List<Booking> getBookingsForProject(int projectId) {
    return bookingList.value.where((booking) => booking.projectId == projectId).toList();
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

  // Get studio by ID
  Studio? getStudioById(int id) {
    try {
      return studioList.value.firstWhere((studio) => studio.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get color for booking based on its status
  Color getStatusColorForBooking(Booking booking) {
    return BLKWDSDateUtils.getColorForBooking(booking);
  }

  // Dispose controller
  void dispose() {
    bookingList.dispose();
    projectList.dispose();
    memberList.dispose();
    gearList.dispose();
    studioList.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    filter.dispose();
    filteredBookingList.dispose();
  }
}
