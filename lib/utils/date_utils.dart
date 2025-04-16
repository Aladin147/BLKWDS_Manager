import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/blkwds_colors.dart';

/// Date utilities for the application
class BLKWDSDateUtils {
  /// Get the color for a booking based on its status
  static Color getColorForBooking(Booking booking) {
    final now = DateTime.now();

    // Check if booking is in the past
    if (booking.endDate.isBefore(now)) {
      return BLKWDSColors.slateGrey; // Past booking
    }

    // Check if booking is in progress
    if (booking.startDate.isBefore(now) && booking.endDate.isAfter(now)) {
      return BLKWDSColors.blkwdsGreen; // In progress
    }

    // Check if booking is today
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(booking.startDate.year, booking.startDate.month, booking.startDate.day);

    if (bookingDate.isAtSameMomentAs(today)) {
      return BLKWDSColors.accentTeal; // Today
    }

    // Check if booking is tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    if (bookingDate.isAtSameMomentAs(tomorrow)) {
      return BLKWDSColors.accentPurple; // Tomorrow
    }

    // Check if booking is this week
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));
    if (bookingDate.isAfter(tomorrow) && bookingDate.isBefore(endOfWeek) || bookingDate.isAtSameMomentAs(endOfWeek)) {
      return BLKWDSColors.infoBlue; // This week
    }

    // Future booking
    return BLKWDSColors.mustardOrange;
  }

  // Legacy method removed

  /// Format a duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }
}
