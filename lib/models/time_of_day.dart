/// CustomTimeOfDay
/// A simple class to represent a time of day
class CustomTimeOfDay {
  /// The hour component of the time
  final int hour;

  /// The minute component of the time
  final int minute;

  /// Constructor
  const CustomTimeOfDay({
    required this.hour,
    required this.minute,
  });

  /// Create a CustomTimeOfDay from a string in the format 'HH:MM'
  factory CustomTimeOfDay.fromString(String timeString) {
    final parts = timeString.split(':');
    return CustomTimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Convert to a string in the format 'HH:MM'
  @override
  String toString() {
    return '$hour:$minute';
  }

  /// Convert to a formatted string in the format 'h:mm a'
  String format() {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Create a copy with updated values
  CustomTimeOfDay copyWith({
    int? hour,
    int? minute,
  }) {
    return CustomTimeOfDay(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomTimeOfDay &&
      other.hour == hour &&
      other.minute == minute;
  }

  /// Hash code
  @override
  int get hashCode {
    return hour.hashCode ^ minute.hashCode;
  }
}
