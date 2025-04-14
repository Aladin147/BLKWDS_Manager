import 'package:flutter/foundation.dart';
import 'log_level.dart';

/// LogService
/// A centralized logging service for the application
class LogService {
  // Using LogLevel enum from log_level.dart

  /// Current log level
  /// Only logs with this level or higher will be displayed
  static LogLevel _currentLevel = LogLevel.debug;

  /// Set the current log level
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Log a debug message
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.debug)) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  /// Log an info message
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.info)) {
      _log('INFO', message, error, stackTrace);
    }
  }

  /// Log a warning message
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.warning)) {
      _log('WARNING', message, error, stackTrace);
    }
  }

  /// Log an error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, error, stackTrace);
    }
  }

  /// Check if a log level should be displayed
  static bool _shouldLog(LogLevel level) {
    return level.index >= _currentLevel.index;
  }

  /// Log a message with the given level
  static void _log(String levelString, String message, [Object? error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $levelString: $message';

    if (error != null) {
      debugPrint('$logMessage\nError: $error');
    } else {
      debugPrint(logMessage);
    }

    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }
  }
}
