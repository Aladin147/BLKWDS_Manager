import 'package:flutter/material.dart';

/// StudioSettings
/// Model class for studio global settings
class StudioSettings {
  /// Unique ID for the settings
  final int? id;
  
  /// Opening time for studios
  final TimeOfDay openingTime;
  
  /// Closing time for studios
  final TimeOfDay closingTime;
  
  /// Minimum booking duration in minutes
  final int minBookingDuration;
  
  /// Maximum booking duration in minutes
  final int maxBookingDuration;
  
  /// Minimum advance booking time in hours
  final int minAdvanceBookingTime;
  
  /// Maximum advance booking time in days
  final int maxAdvanceBookingTime;
  
  /// Cleanup time between bookings in minutes
  final int cleanupTime;
  
  /// Whether to allow overlapping bookings
  final bool allowOverlappingBookings;
  
  /// Whether to enforce studio hours
  final bool enforceStudioHours;
  
  /// Constructor
  const StudioSettings({
    this.id,
    this.openingTime = const TimeOfDay(hour: 9, minute: 0),
    this.closingTime = const TimeOfDay(hour: 22, minute: 0),
    this.minBookingDuration = 60,
    this.maxBookingDuration = 480,
    this.minAdvanceBookingTime = 1,
    this.maxAdvanceBookingTime = 90,
    this.cleanupTime = 30,
    this.allowOverlappingBookings = false,
    this.enforceStudioHours = true,
  });
  
  /// Create a StudioSettings object from a map (for database operations)
  factory StudioSettings.fromMap(Map<String, dynamic> map) {
    return StudioSettings(
      id: map['id'] as int?,
      openingTime: _timeFromString(map['openingTime'] as String),
      closingTime: _timeFromString(map['closingTime'] as String),
      minBookingDuration: map['minBookingDuration'] as int,
      maxBookingDuration: map['maxBookingDuration'] as int,
      minAdvanceBookingTime: map['minAdvanceBookingTime'] as int,
      maxAdvanceBookingTime: map['maxAdvanceBookingTime'] as int,
      cleanupTime: map['cleanupTime'] as int,
      allowOverlappingBookings: (map['allowOverlappingBookings'] as int) == 1,
      enforceStudioHours: (map['enforceStudioHours'] as int) == 1,
    );
  }
  
  /// Convert StudioSettings object to a map (for database operations)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'openingTime': '${openingTime.hour}:${openingTime.minute}',
      'closingTime': '${closingTime.hour}:${closingTime.minute}',
      'minBookingDuration': minBookingDuration,
      'maxBookingDuration': maxBookingDuration,
      'minAdvanceBookingTime': minAdvanceBookingTime,
      'maxAdvanceBookingTime': maxAdvanceBookingTime,
      'cleanupTime': cleanupTime,
      'allowOverlappingBookings': allowOverlappingBookings ? 1 : 0,
      'enforceStudioHours': enforceStudioHours ? 1 : 0,
    };
    
    // Add ID if it exists
    if (id != null) map['id'] = id;
    
    return map;
  }
  
  /// Create a copy of this StudioSettings with modified fields
  StudioSettings copyWith({
    int? id,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    int? minBookingDuration,
    int? maxBookingDuration,
    int? minAdvanceBookingTime,
    int? maxAdvanceBookingTime,
    int? cleanupTime,
    bool? allowOverlappingBookings,
    bool? enforceStudioHours,
  }) {
    return StudioSettings(
      id: id ?? this.id,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      minBookingDuration: minBookingDuration ?? this.minBookingDuration,
      maxBookingDuration: maxBookingDuration ?? this.maxBookingDuration,
      minAdvanceBookingTime: minAdvanceBookingTime ?? this.minAdvanceBookingTime,
      maxAdvanceBookingTime: maxAdvanceBookingTime ?? this.maxAdvanceBookingTime,
      cleanupTime: cleanupTime ?? this.cleanupTime,
      allowOverlappingBookings: allowOverlappingBookings ?? this.allowOverlappingBookings,
      enforceStudioHours: enforceStudioHours ?? this.enforceStudioHours,
    );
  }
  
  /// Helper method to convert a string to TimeOfDay
  static TimeOfDay _timeFromString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
  
  /// Format TimeOfDay as a string
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Get the default settings
  static StudioSettings get defaults => const StudioSettings();
}
