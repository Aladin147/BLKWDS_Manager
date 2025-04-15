import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'log_service.dart';
import 'error_type.dart';
import 'exceptions/exceptions.dart';

/// Error analytics service
///
/// Provides error tracking, analytics, and reporting functionality
class ErrorAnalyticsService {
  /// Maximum number of errors to keep in memory
  static const int _maxErrorsInMemory = 100;

  /// Maximum number of errors to keep in the error log file
  static const int _maxErrorsInFile = 1000;

  /// In-memory error log
  static final List<ErrorRecord> _errorLog = [];

  /// Error counts by type
  static final Map<ErrorType, int> _errorCounts = {};

  /// Error counts by source
  static final Map<String, int> _errorSourceCounts = {};

  /// Flag indicating whether the service has been initialized
  static bool _initialized = false;

  /// Initialize the error analytics service
  ///
  /// This should be called at application startup
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Load error log from file
      await _loadErrorLog();

      // Mark as initialized
      _initialized = true;

      LogService.info('Error analytics service initialized');
    } catch (e, stackTrace) {
      LogService.error('Failed to initialize error analytics service', e, stackTrace);
    }
  }

  /// Track an error
  ///
  /// [error] is the error object
  /// [stackTrace] is the stack trace
  /// [source] is the source of the error (e.g., class name or feature)
  /// [userId] is the ID of the user who experienced the error
  /// [metadata] is additional information about the error
  static Future<void> trackError(
    Object error, {
    StackTrace? stackTrace,
    String source = 'unknown',
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    // Ensure the service is initialized
    if (!_initialized) {
      await initialize();
    }

    try {
      // Determine error type
      final errorType = _determineErrorType(error);

      // Create error record
      final errorRecord = ErrorRecord(
        timestamp: DateTime.now(),
        errorType: errorType,
        message: _getErrorMessage(error),
        stackTrace: stackTrace?.toString() ?? '',
        source: source,
        userId: userId,
        metadata: metadata,
      );

      // Add to in-memory log
      _addToErrorLog(errorRecord);

      // Update error counts
      _updateErrorCounts(errorType, source);

      // Save to file
      await _saveErrorLog();

      // Log the error
      LogService.info('Error tracked: ${errorRecord.message}');
    } catch (e, stackTrace) {
      LogService.error('Failed to track error', e, stackTrace);
    }
  }

  /// Get error counts by type
  ///
  /// Returns a map of error types to counts
  static Map<ErrorType, int> getErrorCountsByType() {
    return Map.unmodifiable(_errorCounts);
  }

  /// Get error counts by source
  ///
  /// Returns a map of error sources to counts
  static Map<String, int> getErrorCountsBySource() {
    return Map.unmodifiable(_errorSourceCounts);
  }

  /// Get recent errors
  ///
  /// [limit] is the maximum number of errors to return
  /// Returns a list of recent error records
  static List<ErrorRecord> getRecentErrors({int limit = 10}) {
    return _errorLog.take(limit).toList();
  }

  /// Get errors by type
  ///
  /// [type] is the error type to filter by
  /// [limit] is the maximum number of errors to return
  /// Returns a list of error records of the specified type
  static List<ErrorRecord> getErrorsByType(ErrorType type, {int limit = 10}) {
    return _errorLog
        .where((error) => error.errorType == type)
        .take(limit)
        .toList();
  }

  /// Get errors by source
  ///
  /// [source] is the error source to filter by
  /// [limit] is the maximum number of errors to return
  /// Returns a list of error records from the specified source
  static List<ErrorRecord> getErrorsBySource(String source, {int limit = 10}) {
    return _errorLog
        .where((error) => error.source == source)
        .take(limit)
        .toList();
  }

  /// Get error frequency by time period
  ///
  /// [period] is the time period to group by
  /// Returns a map of time periods to error counts
  static Map<String, int> getErrorFrequency(ErrorTimePeriod period) {
    final result = <String, int>{};
    final now = DateTime.now();

    for (final error in _errorLog) {
      final key = _getTimePeriodKey(error.timestamp, now, period);
      result[key] = (result[key] ?? 0) + 1;
    }

    return result;
  }

  /// Export error log to JSON
  ///
  /// Returns a JSON string containing the error log
  static String exportErrorLogToJson() {
    return jsonEncode(_errorLog.map((e) => e.toJson()).toList());
  }

  /// Clear error log
  ///
  /// Clears the in-memory error log and error counts
  static Future<void> clearErrorLog() async {
    _errorLog.clear();
    _errorCounts.clear();
    _errorSourceCounts.clear();

    // Save empty log to file
    await _saveErrorLog();

    LogService.info('Error log cleared');
  }

  /// Add an error record to the in-memory log
  ///
  /// [errorRecord] is the error record to add
  static void _addToErrorLog(ErrorRecord errorRecord) {
    // Add to the beginning of the list (most recent first)
    _errorLog.insert(0, errorRecord);

    // Trim the log if it exceeds the maximum size
    if (_errorLog.length > _maxErrorsInMemory) {
      _errorLog.removeRange(_maxErrorsInMemory, _errorLog.length);
    }
  }

  /// Update error counts
  ///
  /// [errorType] is the type of the error
  /// [source] is the source of the error
  static void _updateErrorCounts(ErrorType errorType, String source) {
    // Update error type count
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;

    // Update error source count
    _errorSourceCounts[source] = (_errorSourceCounts[source] ?? 0) + 1;
  }

  /// Load error log from file
  ///
  /// Loads the error log from the application documents directory
  static Future<void> _loadErrorLog() async {
    try {
      final file = await _getErrorLogFile();

      // Check if file exists
      if (await file.exists()) {
        // Read file content
        final content = await file.readAsString();

        // Parse JSON
        final List<dynamic> jsonList = jsonDecode(content);

        // Clear existing log
        _errorLog.clear();
        _errorCounts.clear();
        _errorSourceCounts.clear();

        // Add error records
        for (final json in jsonList) {
          final errorRecord = ErrorRecord.fromJson(json);
          _addToErrorLog(errorRecord);
          _updateErrorCounts(errorRecord.errorType, errorRecord.source);
        }

        LogService.info('Error log loaded from file: ${_errorLog.length} errors');
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to load error log from file', e, stackTrace);
    }
  }

  /// Save error log to file
  ///
  /// Saves the error log to the application documents directory
  static Future<void> _saveErrorLog() async {
    try {
      final file = await _getErrorLogFile();

      // Convert error log to JSON
      final jsonList = _errorLog
          .take(_maxErrorsInFile)
          .map((e) => e.toJson())
          .toList();

      // Write to file
      await file.writeAsString(jsonEncode(jsonList));

      LogService.info('Error log saved to file: ${jsonList.length} errors');
    } catch (e, stackTrace) {
      LogService.error('Failed to save error log to file', e, stackTrace);
    }
  }

  /// Get error log file
  ///
  /// Returns a File object for the error log file
  static Future<File> _getErrorLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(path.join(directory.path, 'error_log.json'));
  }

  /// Determine error type from error object
  ///
  /// [error] is the error object
  /// Returns the determined error type
  static ErrorType _determineErrorType(Object error) {
    if (error is BLKWDSException) {
      return error.type;
    } else if (error is FormatException) {
      return ErrorType.format;
    } else if (error is ArgumentError) {
      return ErrorType.input;
    } else if (error is StateError) {
      return ErrorType.state;
    } else if (error is Exception) {
      // Try to determine the type from the exception class name
      final className = error.runtimeType.toString().toLowerCase();
      if (className.contains('database') || className.contains('sql')) {
        return ErrorType.database;
      } else if (className.contains('network') || className.contains('socket')) {
        return ErrorType.network;
      } else if (className.contains('file') || className.contains('io')) {
        return ErrorType.fileSystem;
      } else if (className.contains('permission')) {
        return ErrorType.permission;
      } else if (className.contains('format')) {
        return ErrorType.format;
      } else if (className.contains('conflict')) {
        return ErrorType.conflict;
      } else if (className.contains('notfound') || className.contains('not_found')) {
        return ErrorType.notFound;
      } else if (className.contains('validation')) {
        return ErrorType.validation;
      } else if (className.contains('auth')) {
        return ErrorType.auth;
      }
    }

    return ErrorType.unknown;
  }

  /// Get error message from error object
  ///
  /// [error] is the error object
  /// Returns a user-friendly error message
  static String _getErrorMessage(Object error) {
    if (error is BLKWDSException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return error.toString();
    }
  }

  /// Get time period key for error frequency
  ///
  /// [timestamp] is the error timestamp
  /// [now] is the current time
  /// [period] is the time period to group by
  /// Returns a string key for the time period
  static String _getTimePeriodKey(
    DateTime timestamp,
    DateTime now,
    ErrorTimePeriod period,
  ) {
    switch (period) {
      case ErrorTimePeriod.hourly:
        return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:00';
      case ErrorTimePeriod.daily:
        return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
      case ErrorTimePeriod.weekly:
        // Calculate the start of the week (Monday)
        final startOfWeek = timestamp.subtract(Duration(days: timestamp.weekday - 1));
        return '${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';
      case ErrorTimePeriod.monthly:
        return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
    }
  }
}

/// Error time period
///
/// Defines the time period for error frequency analysis
enum ErrorTimePeriod {
  /// Hourly frequency
  hourly,

  /// Daily frequency
  daily,

  /// Weekly frequency
  weekly,

  /// Monthly frequency
  monthly,
}

/// Error record
///
/// Represents a recorded error
class ErrorRecord {
  /// Timestamp when the error occurred
  final DateTime timestamp;

  /// Type of the error
  final ErrorType errorType;

  /// Error message
  final String message;

  /// Stack trace
  final String stackTrace;

  /// Source of the error (e.g., class name or feature)
  final String source;

  /// ID of the user who experienced the error
  final String? userId;

  /// Additional information about the error
  final Map<String, dynamic>? metadata;

  /// Create a new error record
  ///
  /// [timestamp] is when the error occurred
  /// [errorType] is the type of the error
  /// [message] is the error message
  /// [stackTrace] is the stack trace
  /// [source] is the source of the error
  /// [userId] is the ID of the user who experienced the error
  /// [metadata] is additional information about the error
  ErrorRecord({
    required this.timestamp,
    required this.errorType,
    required this.message,
    required this.stackTrace,
    required this.source,
    this.userId,
    this.metadata,
  });

  /// Create an error record from JSON
  ///
  /// [json] is the JSON object
  /// Returns a new error record
  factory ErrorRecord.fromJson(Map<String, dynamic> json) {
    return ErrorRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorType: ErrorType.values.firstWhere(
        (e) => e.toString() == json['errorType'],
        orElse: () => ErrorType.unknown,
      ),
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      source: json['source'] as String,
      userId: json['userId'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convert to JSON
  ///
  /// Returns a JSON representation of the error record
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'errorType': errorType.toString(),
      'message': message,
      'stackTrace': stackTrace,
      'source': source,
      'userId': userId,
      'metadata': metadata,
    };
  }
}
