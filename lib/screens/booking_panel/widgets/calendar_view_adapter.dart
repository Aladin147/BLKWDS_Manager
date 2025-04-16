import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../utils/booking_converter.dart';
import '../booking_panel_controller.dart';
import '../booking_panel_controller_v2.dart';

/// CalendarViewAdapter
/// Adapter class to provide a unified interface for both Booking and BookingV2 models
/// This allows the CalendarView to work with either model based on feature flags
class CalendarViewAdapter {
  final BookingPanelController? _controllerV1;
  final BookingPanelControllerV2? _controllerV2;

  /// Constructor that takes either a v1 or v2 controller
  CalendarViewAdapter({
    BookingPanelController? controllerV1,
    BookingPanelControllerV2? controllerV2,
  }) : _controllerV1 = controllerV1,
       _controllerV2 = controllerV2,
       assert(controllerV1 != null || controllerV2 != null, 'At least one controller must be provided');

  /// Get bookings for a specific day
  Future<List<dynamic>> getBookingsForDay(DateTime day) async {
    if (_controllerV2 != null) {
      return _controllerV2.getBookingsForDay(day);
    } else if (_controllerV1 != null) {
      return _controllerV1.getBookingsForDay(day);
    }
    return [];
  }

  /// Check if a booking has conflicts
  Future<bool> hasBookingConflicts(dynamic booking, {int? excludeBookingId}) async {
    if (booking is BookingV2 && _controllerV2 != null) {
      return _controllerV2.hasBookingConflicts(booking, excludeBookingId: excludeBookingId);
    } else if (booking is Booking && _controllerV1 != null) {
      return _controllerV1.hasBookingConflicts(booking, excludeBookingId: excludeBookingId);
    } else if (booking is Booking && _controllerV2 != null) {
      // Convert Booking to BookingV2 and check conflicts
      final bookingV2 = await BookingConverter.toBookingV2(booking);
      return _controllerV2.hasBookingConflicts(bookingV2, excludeBookingId: excludeBookingId);
    } else if (booking is BookingV2 && _controllerV1 != null) {
      // Convert BookingV2 to Booking and check conflicts
      final bookingV1 = await BookingConverter.toBooking(booking);
      return _controllerV1.hasBookingConflicts(bookingV1, excludeBookingId: excludeBookingId);
    }
    return false;
  }

  /// Get project by ID
  Project? getProjectById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.getProjectById(id);
    } else if (_controllerV1 != null) {
      return _controllerV1.getProjectById(id);
    }
    return null;
  }

  /// Get studio by ID
  Studio? getStudioById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.getStudioById(id);
    }
    return null;
  }

  /// Reschedule a booking
  Future<bool> rescheduleBooking(dynamic booking, DateTime newStartDate) async {
    if (booking is BookingV2 && _controllerV2 != null) {
      return _controllerV2.rescheduleBooking(booking, newStartDate);
    } else if (booking is Booking && _controllerV1 != null) {
      return _controllerV1.rescheduleBooking(booking, newStartDate);
    } else if (booking is Booking && _controllerV2 != null) {
      // Convert Booking to BookingV2, reschedule, and convert back
      final bookingV2 = await BookingConverter.toBookingV2(booking);
      return _controllerV2.rescheduleBooking(bookingV2, newStartDate);
    } else if (booking is BookingV2 && _controllerV1 != null) {
      // Convert BookingV2 to Booking, reschedule, and convert back
      final bookingV1 = await BookingConverter.toBooking(booking);
      return _controllerV1.rescheduleBooking(bookingV1, newStartDate);
    }
    return false;
  }

  /// Get color for a booking
  Color getColorForBooking(dynamic booking) {
    if (booking is BookingV2 && _controllerV2 != null) {
      return _controllerV2.getColorForBooking(booking);
    } else if (booking is Booking && _controllerV1 != null) {
      return _controllerV1.getColorForBooking(booking);
    }
    return Colors.grey;
  }

  /// Check if a booking is a V2 booking
  bool isBookingV2(dynamic booking) {
    return booking is BookingV2;
  }

  /// Get studio type for a booking
  String? getStudioTypeForBooking(dynamic booking) {
    if (booking is BookingV2 && booking.studioId != null && _controllerV2 != null) {
      final studio = _controllerV2.getStudioById(booking.studioId!);
      if (studio != null) {
        switch (studio.type) {
          case StudioType.recording:
            return 'Recording';
          case StudioType.production:
            return 'Production';
          case StudioType.hybrid:
            return 'Hybrid';
        }
      }
    } else if (booking is Booking) {
      final types = <String>[];
      if (booking.isRecordingStudio) types.add('Recording');
      if (booking.isProductionStudio) types.add('Production');
      if (types.isNotEmpty) {
        return types.join(', ');
      }
    }
    return null;
  }
}
