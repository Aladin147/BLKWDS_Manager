/// FeatureFlags
/// Controls feature availability throughout the application
/// Used for feature toggling during development and migration
class FeatureFlags {
  /// Whether to use the new studio-based booking system
  /// When true, the application will use BookingV2 and Studio models
  /// When false, the application will use the original Booking model with boolean flags
  static const bool useStudioSystem = false;

  /// Whether to show the studio management screen in the navigation
  static const bool showStudioManagement = true;

  /// Whether to use the new gear card with integrated notes
  static const bool useGearCardWithNote = true;

  /// Whether to show the migration UI for converting old bookings to the new system
  static const bool showMigrationUI = true;
}
