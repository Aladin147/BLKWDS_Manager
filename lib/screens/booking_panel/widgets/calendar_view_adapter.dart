import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';

import '../booking_panel_controller.dart';

/// CalendarViewAdapter
/// Adapter class to provide a unified interface for the calendar view
class CalendarViewAdapter {
  final BookingPanelController? _controller;

  /// Constructor that takes a controller
  CalendarViewAdapter({
    required BookingPanelController? controller,
  }) : _controller = controller;

  /// Get bookings for a specific day
  Future<List<dynamic>> getBookingsForDay(DateTime day) async {
    if (_controller == null) return [];
    return _controller.getBookingsForDay(day);
  }

  /// Check if a booking has conflicts
  Future<bool> hasBookingConflicts(dynamic booking, {int? excludeBookingId}) async {
    if (_controller == null) return false;
    return _controller.hasBookingConflicts(booking, excludeBookingId: excludeBookingId);
  }

  /// Get project by ID
  Project? getProjectById(int id) {
    if (_controller == null) return null;
    return _controller.getProjectById(id);
  }

  /// Get studio by ID
  Studio? getStudioById(int id) {
    if (_controller == null) return null;
    return _controller.getStudioById(id);
  }

  /// Reschedule a booking
  Future<bool> rescheduleBooking(dynamic booking, DateTime newStartDate) async {
    if (_controller == null) return false;
    return _controller.rescheduleBooking(booking, newStartDate);
  }

  /// Get color for a booking
  Color getColorForBooking(dynamic booking) {
    if (_controller == null) return BLKWDSColors.accentTeal;
    return _controller.getColorForBooking(booking);
  }

  /// Check if a booking is a V2 booking
  bool isBookingV2(dynamic booking) {
    // Legacy method - always return true now that we only have one booking type
    return true;
  }

  /// Get studio type for a booking
  String? getStudioTypeForBooking(dynamic booking) {
    if (_controller == null || booking.studioId == null) return null;
    final studio = _controller.getStudioById(booking.studioId!);
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
    return null;
  }
}
