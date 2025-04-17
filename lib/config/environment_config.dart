import '../services/log_service.dart';

/// Environment types for the application
enum Environment {
  /// Development environment
  development,

  /// Testing environment
  testing,

  /// Production environment
  production,
}

/// EnvironmentConfig
/// Handles environment detection and configuration
class EnvironmentConfig {
  /// The current environment
  static final Environment currentEnvironment = _determineEnvironment();

  /// Determine the current environment based on build flags and configuration
  static Environment _determineEnvironment() {
    try {
      // Check for environment override from build flags
      const String envOverride = String.fromEnvironment('ENVIRONMENT');

      if (envOverride.isNotEmpty) {
        LogService.info('Environment override detected: $envOverride');

        switch (envOverride.toLowerCase()) {
          case 'development':
            return Environment.development;
          case 'testing':
            return Environment.testing;
          case 'production':
            return Environment.production;
        }
      }

      // Use Dart's built-in constant to detect if we're in release mode
      const bool isReleaseMode = bool.fromEnvironment('dart.vm.product');

      // Default logic: release mode = production environment
      final environment = isReleaseMode ? Environment.production : Environment.development;
      LogService.info('Detected environment: ${environment.name}');
      return environment;
    } catch (e, stackTrace) {
      // If anything goes wrong, default to development environment
      LogService.error('Error determining environment, defaulting to development', e, stackTrace);
      return Environment.development;
    }
  }

  /// Check if the current environment is production
  static bool get isProduction => currentEnvironment == Environment.production;

  /// Check if the current environment is development
  static bool get isDevelopment => currentEnvironment == Environment.development;

  /// Check if the current environment is testing
  static bool get isTesting => currentEnvironment == Environment.testing;

  /// Get a string representation of the current environment
  static String get environmentName => currentEnvironment.name;
}
