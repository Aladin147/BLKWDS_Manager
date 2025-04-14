import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../theme/blkwds_colors.dart';

/// BookingPanelController
/// Handles state management and business logic for the Booking Panel screen
class BookingPanelController {
  // Value notifiers for reactive UI updates
  final ValueNotifier<List<Booking>> bookingList = ValueNotifier<List<Booking>>([]);
  final ValueNotifier<List<Project>> projectList = ValueNotifier<List<Project>>([]);
  final ValueNotifier<List<Member>> memberList = ValueNotifier<List<Member>>([]);
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  // Initialize controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await _loadBookings();
      await _loadProjects();
      await _loadMembers();
      await _loadGear();
    } catch (e) {
      errorMessage.value = 'Error initializing data: $e';
      print('Error initializing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load bookings from database
  Future<void> _loadBookings() async {
    try {
      final bookings = await DBService.getAllBookings();
      bookingList.value = bookings;
    } catch (e) {
      print('Error loading bookings: $e');
      rethrow;
    }
  }

  // Load projects from database
  Future<void> _loadProjects() async {
    try {
      final projects = await DBService.getAllProjects();
      projectList.value = projects;
    } catch (e) {
      print('Error loading projects: $e');
      rethrow;
    }
  }

  // Load members from database
  Future<void> _loadMembers() async {
    try {
      final members = await DBService.getAllMembers();
      memberList.value = members;
    } catch (e) {
      print('Error loading members: $e');
      rethrow;
    }
  }

  // Load gear from database
  Future<void> _loadGear() async {
    try {
      final gear = await DBService.getAllGear();
      gearList.value = gear;
    } catch (e) {
      print('Error loading gear: $e');
      rethrow;
    }
  }

  // Create a new booking
  Future<bool> createBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for booking conflicts
      if (await hasBookingConflicts(booking)) {
        errorMessage.value = 'Booking conflicts with existing bookings';
        return false;
      }

      // Insert booking
      final id = await DBService.insertBooking(booking);

      // Reload bookings
      await _loadBookings();

      return id > 0;
    } catch (e) {
      errorMessage.value = 'Error creating booking: $e';
      print('Error creating booking: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing booking
  Future<bool> updateBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for booking conflicts (excluding this booking)
      if (await hasBookingConflicts(booking, excludeBookingId: booking.id)) {
        errorMessage.value = 'Booking conflicts with existing bookings';
        return false;
      }

      // Update booking
      final id = await DBService.updateBooking(booking);

      // Reload bookings
      await _loadBookings();

      return id > 0;
    } catch (e) {
      errorMessage.value = 'Error updating booking: $e';
      print('Error updating booking: $e');
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
      // Delete booking
      final result = await DBService.deleteBooking(id);

      // Reload bookings
      await _loadBookings();

      return result > 0;
    } catch (e) {
      errorMessage.value = 'Error deleting booking: $e';
      print('Error deleting booking: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a booking conflicts with existing bookings
  Future<bool> hasBookingConflicts(Booking booking, {int? excludeBookingId}) async {
    try {
      // Get all bookings
      final bookings = await DBService.getAllBookings();

      // Filter out the booking being updated
      final otherBookings = bookings.where((b) => b.id != excludeBookingId).toList();

      // Check for time conflicts
      for (final otherBooking in otherBookings) {
        // Check if the booking overlaps with another booking
        if (_bookingsOverlap(booking, otherBooking)) {
          // Check if they share any gear
          final sharedGear = booking.gearIds.where((id) => otherBooking.gearIds.contains(id)).toList();

          if (sharedGear.isNotEmpty) {
            return true; // Conflict found
          }

          // Check if they both use the recording studio
          if (booking.isRecordingStudio && otherBooking.isRecordingStudio) {
            return true; // Conflict found
          }

          // Check if they both use the production studio
          if (booking.isProductionStudio && otherBooking.isProductionStudio) {
            return true; // Conflict found
          }
        }
      }

      return false; // No conflicts found
    } catch (e) {
      print('Error checking booking conflicts: $e');
      rethrow;
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

  // Dispose controller
  void dispose() {
    bookingList.dispose();
    projectList.dispose();
    memberList.dispose();
    gearList.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
