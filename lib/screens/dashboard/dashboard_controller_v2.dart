import 'package:flutter/foundation.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../utils/constants.dart';
import '../../utils/booking_converter.dart';

/// DashboardControllerV2
/// Handles business logic and database operations for the dashboard screen
/// This version supports the new BookingV2 model with studio system
class DashboardControllerV2 {
  // State notifiers
  final ValueNotifier<List<Gear>> gearList = ValueNotifier<List<Gear>>([]);
  final ValueNotifier<List<Member>> memberList = ValueNotifier<List<Member>>([]);
  final ValueNotifier<List<Project>> projectList = ValueNotifier<List<Project>>([]);
  final ValueNotifier<List<BookingV2>> bookingList = ValueNotifier<List<BookingV2>>([]);
  final ValueNotifier<List<Studio>> studioList = ValueNotifier<List<Studio>>([]);
  final ValueNotifier<List<ActivityLog>> recentActivity = ValueNotifier<List<ActivityLog>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

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
      ]);
    } catch (e) {
      errorMessage.value = '${Constants.databaseError} ${e.toString()}';
      LogService.error('Error initializing dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  // Load gear from database
  Future<void> _loadGear() async {
    try {
      final gear = await DBService.getAllGear();
      gearList.value = gear;
    } catch (e) {
      LogService.error('Error loading gear', e);
      rethrow;
    }
  }

  // Load members from database
  Future<void> _loadMembers() async {
    try {
      final members = await DBService.getAllMembers();
      memberList.value = members;
    } catch (e) {
      LogService.error('Error loading members', e);
      rethrow;
    }
  }

  // Load projects from database
  Future<void> _loadProjects() async {
    try {
      final projects = await DBService.getAllProjects();
      projectList.value = projects;
    } catch (e) {
      LogService.error('Error loading projects', e);
      rethrow;
    }
  }

  // Load bookings from database
  Future<void> _loadBookings() async {
    try {
      final bookings = await DBService.getAllBookingsV2();
      bookingList.value = bookings;
    } catch (e) {
      LogService.error('Error loading bookings', e);
      rethrow;
    }
  }

  // Load studios from database
  Future<void> _loadStudios() async {
    try {
      final studios = await DBService.getAllStudios();
      studioList.value = studios;
    } catch (e) {
      LogService.error('Error loading studios', e);
      rethrow;
    }
  }

  // Load recent activity from database
  Future<void> _loadRecentActivity() async {
    try {
      final activity = await DBService.getRecentActivityLogs();
      recentActivity.value = activity;
    } catch (e) {
      LogService.error('Error loading activity logs', e);
      rethrow;
    }
  }

  // Check out gear to a member
  Future<bool> checkOutGear(Gear gear, Member member, {String? note}) async {
    if (gear.id == null) {
      errorMessage.value = Constants.gearNotFound;
      return false;
    }

    if (member.id == null) {
      errorMessage.value = Constants.memberNotFound;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check out gear in database
      final success = await DBService.checkOutGear(gear.id!, member.id!, note: note);

      if (success) {
        // Reload data
        await Future.wait([
          _loadGear(),
          _loadRecentActivity(),
        ]);
        return true;
      } else {
        errorMessage.value = Constants.gearAlreadyCheckedOut;
        return false;
      }
    } catch (e) {
      errorMessage.value = '${Constants.generalError} ${e.toString()}';
      LogService.error('Error checking out gear', e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Check in gear
  Future<bool> checkInGear(Gear gear, {String? note}) async {
    if (gear.id == null) {
      errorMessage.value = Constants.gearNotFound;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check in gear in database
      final success = await DBService.checkInGear(gear.id!, note: note);

      if (success) {
        // Reload data
        await Future.wait([
          _loadGear(),
          _loadRecentActivity(),
        ]);
        return true;
      } else {
        errorMessage.value = Constants.gearAlreadyCheckedIn;
        return false;
      }
    } catch (e) {
      errorMessage.value = '${Constants.generalError} ${e.toString()}';
      LogService.error('Error checking in gear', e);
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

  // Get studio by ID
  Studio? getStudioById(int id) {
    try {
      return studioList.value.firstWhere((studio) => studio.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get bookings for today
  List<BookingV2> getTodayBookings() {
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

  // Convert BookingV2 to Booking for compatibility
  Future<Booking> convertToBookingV1(BookingV2 bookingV2) async {
    return await BookingConverter.toBooking(bookingV2);
  }

  // Convert a list of BookingV2 to a list of Booking for compatibility
  Future<List<Booking>> convertToBookingV1List(List<BookingV2> bookingsV2) async {
    return await BookingConverter.toBookingList(bookingsV2);
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
  }
}
