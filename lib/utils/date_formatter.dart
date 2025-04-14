import 'package:intl/intl.dart';

/// DateFormatter
/// Utility class for formatting dates
class DateFormatter {
  /// Format a date as a short date (e.g., "Apr 15, 2025")
  static String formatShortDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format a date as a long date (e.g., "April 15, 2025")
  static String formatLongDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  /// Format a date as a time (e.g., "10:30 AM")
  static String formatTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  /// Format a date as a date and time (e.g., "Apr 15, 2025 10:30 AM")
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Format a date range (e.g., "Apr 15, 10:30 AM - 2:30 PM")
  static String formatDateTimeRange(DateTime start, DateTime end) {
    final bool sameDay = start.year == end.year && 
                         start.month == end.month && 
                         start.day == end.day;
    
    if (sameDay) {
      return '${DateFormat.yMMMd().format(start)}, ${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}';
    } else {
      return '${DateFormat.yMMMd().add_jm().format(start)} - ${DateFormat.yMMMd().add_jm().format(end)}';
    }
  }

  /// Format a relative date (e.g., "Today", "Yesterday", "2 days ago")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else {
      final difference = today.difference(dateOnly).inDays;
      
      if (difference < 7) {
        return '$difference days ago, ${DateFormat.jm().format(date)}';
      } else {
        return DateFormat.yMMMd().add_jm().format(date);
      }
    }
  }
}
