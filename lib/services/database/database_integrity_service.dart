import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../log_service.dart';
import '../db_service.dart';
import '../app_config_service.dart';
import 'database_integrity_checker.dart';

/// Database integrity service
///
/// This class provides a service for running database integrity checks periodically.
class DatabaseIntegrityService {
  /// Singleton instance
  static final DatabaseIntegrityService _instance = DatabaseIntegrityService._internal();

  /// Factory constructor
  factory DatabaseIntegrityService() => _instance;

  /// Internal constructor
  DatabaseIntegrityService._internal();

  /// Timer for periodic integrity checks
  Timer? _timer;

  /// Whether the service is running
  bool _isRunning = false;

  /// Last check results
  Map<String, dynamic>? _lastCheckResults;

  /// Last check time
  DateTime? _lastCheckTime;

  /// Get whether the service is running
  bool get isRunning => _isRunning;

  /// Get the last check results
  Map<String, dynamic>? get lastCheckResults => _lastCheckResults;

  /// Get the last check time
  DateTime? get lastCheckTime => _lastCheckTime;

  /// Start the integrity check service
  ///
  /// This method starts the integrity check service with the specified interval.
  /// If the service is already running, it will be stopped and restarted.
  ///
  /// [checkIntervalHours] is the interval between checks in hours.
  /// [runImmediately] determines whether to run a check immediately.
  Future<void> start({
    int checkIntervalHours = 24,
    bool runImmediately = false,
  }) async {
    // Stop the service if it's already running
    if (_isRunning) {
      await stop();
    }

    // Convert hours to milliseconds
    final checkIntervalMs = checkIntervalHours * 60 * 60 * 1000;

    // Start the timer
    _timer = Timer.periodic(
      Duration(milliseconds: checkIntervalMs),
      (_) => _runIntegrityCheck(),
    );

    _isRunning = true;
    LogService.info('Database integrity service started with interval of $checkIntervalHours hours');

    // Run a check immediately if requested
    if (runImmediately) {
      await _runIntegrityCheck();
    }
  }

  /// Stop the integrity check service
  ///
  /// This method stops the integrity check service.
  Future<void> stop() async {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    _isRunning = false;
    LogService.info('Database integrity service stopped');
  }

  /// Run a manual integrity check
  ///
  /// This method runs a manual integrity check.
  /// It returns the results of the check.
  Future<Map<String, dynamic>> runManualCheck({
    bool autoFix = false,
  }) async {
    return _runIntegrityCheck(autoFix: autoFix);
  }

  /// Run an integrity check
  ///
  /// This method runs an integrity check and optionally fixes any issues found.
  /// It returns the results of the check.
  Future<Map<String, dynamic>> _runIntegrityCheck({
    bool autoFix = false,
  }) async {
    try {
      LogService.info('Running database integrity check');

      // Get the database
      final db = await DBService.database;

      // Check if auto-fix is enabled in app config
      final appConfig = await AppConfigService.getConfig();
      final autoFixEnabled = appConfig.database.databaseIntegrityAutoFix;

      // Run the integrity check
      final checkResults = await DatabaseIntegrityChecker.checkIntegrity(db);

      // Update last check time and results
      _lastCheckTime = DateTime.now();
      _lastCheckResults = checkResults;

      // Log the results
      if (checkResults.isEmpty) {
        LogService.info('Database integrity check completed: No issues found');
      } else {
        LogService.warning('Database integrity check completed: Found issues');

        // Log details of issues found
        if (checkResults.containsKey('foreign_key_issues')) {
          final issues = checkResults['foreign_key_issues'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            LogService.warning('Found ${entry.value.length} foreign key issues in table ${entry.key}');
          }
        }

        if (checkResults.containsKey('orphaned_records')) {
          final issues = checkResults['orphaned_records'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            LogService.warning('Found ${entry.value.length} orphaned records in table ${entry.key}');
          }
        }

        if (checkResults.containsKey('consistency_issues')) {
          final issues = checkResults['consistency_issues'] as Map<String, List<Map<String, dynamic>>>;
          for (final entry in issues.entries) {
            LogService.warning('Found ${entry.value.length} consistency issues in table ${entry.key}');
          }
        }

        // Fix issues if auto-fix is enabled
        if ((autoFix || autoFixEnabled) && checkResults.isNotEmpty) {
          LogService.info('Auto-fixing database integrity issues');
          final fixResults = await DatabaseIntegrityChecker.fixIntegrityIssues(db, checkResults);

          // Log fix results
          if (fixResults.isEmpty) {
            LogService.info('No issues were fixed');
          } else {
            LogService.info('Fixed database integrity issues:');
            for (final entry in fixResults.entries) {
              if (entry.value is List) {
                LogService.info('- ${entry.key}: Fixed ${(entry.value as List).length} issues');
              } else if (entry.value is Map) {
                LogService.info('- ${entry.key}: Fixed ${(entry.value as Map).length} issues');
              }
            }
          }

          // Add fix results to check results
          checkResults['fix_results'] = fixResults;
        }
      }

      return checkResults;
    } catch (e, stackTrace) {
      LogService.error('Error running database integrity check', e, stackTrace);
      return {'error': e.toString()};
    }
  }
}
