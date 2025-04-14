/// Constants
/// App-wide constants
class Constants {
  // App Info
  static const String appName = 'BLKWDS Manager';
  static const String appVersion = '0.1.0';
  
  // Gear Categories
  static const List<String> gearCategories = [
    'Camera',
    'Lens',
    'Audio',
    'Lighting',
    'Stabilizer',
    'Support',
    'Power',
    'Storage',
    'Other',
  ];
  
  // Member Roles
  static const List<String> memberRoles = [
    'Director',
    'Producer',
    'Cinematographer',
    'Sound Engineer',
    'Gaffer',
    'Editor',
    'Production Assistant',
    'Other',
  ];
  
  // Status Messages
  static const String checkoutSuccess = 'Gear checked out successfully';
  static const String checkinSuccess = 'Gear checked in successfully';
  static const String bookingSuccess = 'Booking created successfully';
  static const String exportSuccess = 'Data exported successfully to: ';
  
  // Error Messages
  static const String generalError = 'An error occurred. Please try again.';
  static const String databaseError = 'Database error. Please restart the app.';
  static const String gearNotFound = 'Gear not found';
  static const String memberNotFound = 'Member not found';
  static const String projectNotFound = 'Project not found';
  static const String bookingNotFound = 'Booking not found';
  static const String gearAlreadyCheckedOut = 'This gear is already checked out';
  static const String gearAlreadyCheckedIn = 'This gear is already checked in';
  static const String bookingConflict = 'There is a booking conflict for this time period';
}
