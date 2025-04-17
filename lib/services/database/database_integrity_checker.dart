import 'package:sqflite/sqflite.dart';
import '../log_service.dart';
import '../schema_definitions.dart';
import 'errors/errors.dart';

/// Database integrity checker
///
/// This class provides methods for checking and fixing database integrity issues.
class DatabaseIntegrityChecker {
  /// Check database integrity
  ///
  /// This method performs a comprehensive check of database integrity.
  /// It checks for orphaned records, foreign key constraints, and data consistency.
  ///
  /// Returns a map of integrity issues found.
  static Future<Map<String, dynamic>> checkIntegrity(Database db) async {
    try {
      final results = <String, dynamic>{};

      // Check foreign key constraints
      final foreignKeyIssues = await checkForeignKeyConstraints(db);
      if (foreignKeyIssues.isNotEmpty) {
        results['foreign_key_issues'] = foreignKeyIssues;
      }

      // Check for orphaned records
      final orphanedRecords = await checkOrphanedRecords(db);
      if (orphanedRecords.isNotEmpty) {
        results['orphaned_records'] = orphanedRecords;
      }

      // Check data consistency
      final consistencyIssues = await checkDataConsistency(db);
      if (consistencyIssues.isNotEmpty) {
        results['consistency_issues'] = consistencyIssues;
      }

      return results;
    } catch (e, stackTrace) {
      LogService.error('Error checking database integrity', e, stackTrace);
      throw DatabaseError(
        'Failed to check database integrity: ${e.toString()}',
        'checkIntegrity',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check foreign key constraints
  ///
  /// This method checks if all foreign key constraints are satisfied.
  /// It returns a map of tables with foreign key constraint violations.
  static Future<Map<String, List<Map<String, dynamic>>>> checkForeignKeyConstraints(Database db) async {
    try {
      final results = <String, List<Map<String, dynamic>>>{};

      // Define the foreign key relationships to check
      final relationships = [
        // project_member table
        {
          'table': 'project_member',
          'column': 'projectId',
          'references': {'table': 'project', 'column': 'id'},
        },
        {
          'table': 'project_member',
          'column': 'memberId',
          'references': {'table': 'member', 'column': 'id'},
        },

        // booking table
        {
          'table': 'booking',
          'column': 'projectId',
          'references': {'table': 'project', 'column': 'id'},
        },
        {
          'table': 'booking',
          'column': 'studioId',
          'references': {'table': 'studio', 'column': 'id'},
          'nullable': true,
        },

        // booking_gear table
        {
          'table': 'booking_gear',
          'column': 'bookingId',
          'references': {'table': 'booking', 'column': 'id'},
        },
        {
          'table': 'booking_gear',
          'column': 'gearId',
          'references': {'table': 'gear', 'column': 'id'},
        },
        {
          'table': 'booking_gear',
          'column': 'assignedMemberId',
          'references': {'table': 'member', 'column': 'id'},
          'nullable': true,
        },

        // status_note table
        {
          'table': 'status_note',
          'column': 'gearId',
          'references': {'table': 'gear', 'column': 'id'},
        },

        // activity_log table
        {
          'table': 'activity_log',
          'column': 'gearId',
          'references': {'table': 'gear', 'column': 'id'},
        },
        {
          'table': 'activity_log',
          'column': 'memberId',
          'references': {'table': 'member', 'column': 'id'},
          'nullable': true,
        },
      ];

      // Check each relationship
      for (final relationship in relationships) {
        final table = relationship['table'] as String;
        final column = relationship['column'] as String;
        final referencesTable = (relationship['references'] as Map)['table'] as String;
        final referencesColumn = (relationship['references'] as Map)['column'] as String;
        final nullable = relationship['nullable'] as bool? ?? false;

        // Skip if the column is nullable and we're only checking for non-null values
        String whereClause = '';
        if (nullable) {
          whereClause = '$column IS NOT NULL AND ';
        }

        // Find records that violate the foreign key constraint
        final query = '''
          SELECT t.* FROM $table t
          WHERE $whereClause NOT EXISTS (
            SELECT 1 FROM $referencesTable r
            WHERE r.$referencesColumn = t.$column
          )
        ''';

        final violations = await db.rawQuery(query);

        if (violations.isNotEmpty) {
          results[table] = violations;
          LogService.warning('Found ${violations.length} foreign key violations in $table.$column -> $referencesTable.$referencesColumn');
        }
      }

      return results;
    } catch (e, stackTrace) {
      LogService.error('Error checking foreign key constraints', e, stackTrace);
      throw DatabaseError(
        'Failed to check foreign key constraints: ${e.toString()}',
        'checkForeignKeyConstraints',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check for orphaned records
  ///
  /// This method checks for orphaned records in the database.
  /// It returns a map of tables with orphaned records.
  static Future<Map<String, List<Map<String, dynamic>>>> checkOrphanedRecords(Database db) async {
    try {
      final results = <String, List<Map<String, dynamic>>>{};

      // Define the orphaned record checks
      final orphanChecks = [
        // Check for bookings without associated projects
        {
          'table': 'booking',
          'description': 'Bookings without associated projects',
          'query': '''
            SELECT b.* FROM booking b
            LEFT JOIN project p ON b.projectId = p.id
            WHERE p.id IS NULL
          ''',
        },

        // Check for booking_gear entries without associated bookings
        {
          'table': 'booking_gear',
          'description': 'Booking gear entries without associated bookings',
          'query': '''
            SELECT bg.* FROM booking_gear bg
            LEFT JOIN booking b ON bg.bookingId = b.id
            WHERE b.id IS NULL
          ''',
        },

        // Check for booking_gear entries without associated gear
        {
          'table': 'booking_gear',
          'description': 'Booking gear entries without associated gear',
          'query': '''
            SELECT bg.* FROM booking_gear bg
            LEFT JOIN gear g ON bg.gearId = g.id
            WHERE g.id IS NULL
          ''',
        },

        // Check for project_member entries without associated projects
        {
          'table': 'project_member',
          'description': 'Project member entries without associated projects',
          'query': '''
            SELECT pm.* FROM project_member pm
            LEFT JOIN project p ON pm.projectId = p.id
            WHERE p.id IS NULL
          ''',
        },

        // Check for project_member entries without associated members
        {
          'table': 'project_member',
          'description': 'Project member entries without associated members',
          'query': '''
            SELECT pm.* FROM project_member pm
            LEFT JOIN member m ON pm.memberId = m.id
            WHERE m.id IS NULL
          ''',
        },

        // Check for status_note entries without associated gear
        {
          'table': 'status_note',
          'description': 'Status notes without associated gear',
          'query': '''
            SELECT sn.* FROM status_note sn
            LEFT JOIN gear g ON sn.gearId = g.id
            WHERE g.id IS NULL
          ''',
        },

        // Check for activity_log entries without associated gear
        {
          'table': 'activity_log',
          'description': 'Activity logs without associated gear',
          'query': '''
            SELECT al.* FROM activity_log al
            LEFT JOIN gear g ON al.gearId = g.id
            WHERE g.id IS NULL
          ''',
        },
      ];

      // Execute each check
      for (final check in orphanChecks) {
        final table = check['table'] as String;
        final description = check['description'] as String;
        final query = check['query'] as String;

        final orphans = await db.rawQuery(query);

        if (orphans.isNotEmpty) {
          if (!results.containsKey(table)) {
            results[table] = [];
          }
          results[table]!.addAll(orphans);
          LogService.warning('Found ${orphans.length} orphaned records: $description');
        }
      }

      return results;
    } catch (e, stackTrace) {
      LogService.error('Error checking for orphaned records', e, stackTrace);
      throw DatabaseError(
        'Failed to check for orphaned records: ${e.toString()}',
        'checkOrphanedRecords',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check data consistency
  ///
  /// This method checks for data consistency issues in the database.
  /// It returns a map of tables with consistency issues.
  static Future<Map<String, List<Map<String, dynamic>>>> checkDataConsistency(Database db) async {
    try {
      final results = <String, List<Map<String, dynamic>>>{};

      // Define the consistency checks
      final consistencyChecks = [
        // Check for bookings with end date before start date
        {
          'table': 'booking',
          'description': 'Bookings with end date before start date',
          'query': '''
            SELECT * FROM booking
            WHERE datetime(endDate) < datetime(startDate)
          ''',
        },

        // Check for bookings with invalid studio type
        {
          'table': 'booking',
          'description': 'Bookings with invalid studio type',
          'query': '''
            SELECT b.* FROM booking b
            WHERE (b.isRecordingStudio = 0 AND b.isProductionStudio = 0)
          ''',
        },

        // Check for gear with isOut=1 but no activity log entry
        {
          'table': 'gear',
          'description': 'Gear marked as checked out but no activity log entry',
          'query': '''
            SELECT g.* FROM gear g
            WHERE g.isOut = 1 AND NOT EXISTS (
              SELECT 1 FROM activity_log al
              WHERE al.gearId = g.id AND al.checkedOut = 1
              ORDER BY datetime(al.timestamp) DESC
              LIMIT 1
            )
          ''',
        },

        // Check for gear with isOut=0 but last activity log entry is checkout
        {
          'table': 'gear',
          'description': 'Gear marked as checked in but last activity log entry is checkout',
          'query': '''
            SELECT g.* FROM gear g
            WHERE g.isOut = 0 AND EXISTS (
              SELECT 1 FROM activity_log al
              WHERE al.gearId = g.id AND al.checkedOut = 1
              ORDER BY datetime(al.timestamp) DESC
              LIMIT 1
            ) AND NOT EXISTS (
              SELECT 1 FROM activity_log al
              WHERE al.gearId = g.id AND al.checkedOut = 0 AND
              datetime(al.timestamp) > (
                SELECT datetime(timestamp) FROM activity_log
                WHERE gearId = g.id AND checkedOut = 1
                ORDER BY datetime(timestamp) DESC
                LIMIT 1
              )
            )
          ''',
        },

        // Check for overlapping bookings for the same studio
        {
          'table': 'booking',
          'description': 'Overlapping bookings for the same studio',
          'query': '''
            SELECT b1.* FROM booking b1
            JOIN booking b2 ON b1.studioId = b2.studioId AND b1.id != b2.id
            WHERE b1.studioId IS NOT NULL AND
            (
              (datetime(b1.startDate) BETWEEN datetime(b2.startDate) AND datetime(b2.endDate)) OR
              (datetime(b1.endDate) BETWEEN datetime(b2.startDate) AND datetime(b2.endDate)) OR
              (datetime(b1.startDate) <= datetime(b2.startDate) AND datetime(b1.endDate) >= datetime(b2.endDate))
            )
          ''',
        },
      ];

      // Execute each check
      for (final check in consistencyChecks) {
        final table = check['table'] as String;
        final description = check['description'] as String;
        final query = check['query'] as String;

        final issues = await db.rawQuery(query);

        if (issues.isNotEmpty) {
          if (!results.containsKey(table)) {
            results[table] = [];
          }
          results[table]!.addAll(issues);
          LogService.warning('Found ${issues.length} consistency issues: $description');
        }
      }

      return results;
    } catch (e, stackTrace) {
      LogService.error('Error checking data consistency', e, stackTrace);
      throw DatabaseError(
        'Failed to check data consistency: ${e.toString()}',
        'checkDataConsistency',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fix integrity issues
  ///
  /// This method fixes integrity issues found by checkIntegrity.
  /// It returns a map of fixed issues.
  static Future<Map<String, dynamic>> fixIntegrityIssues(
    Database db,
    Map<String, dynamic> issues,
  ) async {
    try {
      final results = <String, dynamic>{};

      // Begin transaction for atomicity
      return await db.transaction((txn) async {
        // Fix foreign key issues
        if (issues.containsKey('foreign_key_issues')) {
          final foreignKeyIssues = issues['foreign_key_issues'] as Map<String, List<Map<String, dynamic>>>;
          final fixedForeignKeyIssues = await _fixForeignKeyIssues(txn, foreignKeyIssues);
          if (fixedForeignKeyIssues.isNotEmpty) {
            results['fixed_foreign_key_issues'] = fixedForeignKeyIssues;
          }
        }

        // Fix orphaned records
        if (issues.containsKey('orphaned_records')) {
          final orphanedRecords = issues['orphaned_records'] as Map<String, List<Map<String, dynamic>>>;
          final fixedOrphanedRecords = await _fixOrphanedRecords(txn, orphanedRecords);
          if (fixedOrphanedRecords.isNotEmpty) {
            results['fixed_orphaned_records'] = fixedOrphanedRecords;
          }
        }

        // Fix consistency issues
        if (issues.containsKey('consistency_issues')) {
          final consistencyIssues = issues['consistency_issues'] as Map<String, List<Map<String, dynamic>>>;
          final fixedConsistencyIssues = await _fixConsistencyIssues(txn, consistencyIssues);
          if (fixedConsistencyIssues.isNotEmpty) {
            results['fixed_consistency_issues'] = fixedConsistencyIssues;
          }
        }

        return results;
      });
    } catch (e, stackTrace) {
      LogService.error('Error fixing integrity issues', e, stackTrace);
      throw DatabaseError(
        'Failed to fix integrity issues: ${e.toString()}',
        'fixIntegrityIssues',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fix foreign key issues
  ///
  /// This method fixes foreign key issues found by checkForeignKeyConstraints.
  /// It returns a map of fixed issues.
  static Future<Map<String, dynamic>> _fixForeignKeyIssues(
    Transaction txn,
    Map<String, List<Map<String, dynamic>>> issues,
  ) async {
    final results = <String, dynamic>{};

    // For each table with issues
    for (final entry in issues.entries) {
      final table = entry.key;
      final records = entry.value;

      // Delete the records that violate foreign key constraints
      for (final record in records) {
        // Get the primary key column and value
        final primaryKeyColumn = _getPrimaryKeyColumn(table);
        final primaryKeyValue = record[primaryKeyColumn];

        if (primaryKeyValue != null) {
          await txn.delete(
            table,
            where: '$primaryKeyColumn = ?',
            whereArgs: [primaryKeyValue],
          );

          LogService.info('Deleted record from $table with $primaryKeyColumn = $primaryKeyValue due to foreign key violation');

          if (!results.containsKey(table)) {
            results[table] = [];
          }
          (results[table] as List).add(record);
        }
      }
    }

    return results;
  }

  /// Fix orphaned records
  ///
  /// This method fixes orphaned records found by checkOrphanedRecords.
  /// It returns a map of fixed issues.
  static Future<Map<String, dynamic>> _fixOrphanedRecords(
    Transaction txn,
    Map<String, List<Map<String, dynamic>>> issues,
  ) async {
    final results = <String, dynamic>{};

    // For each table with issues
    for (final entry in issues.entries) {
      final table = entry.key;
      final records = entry.value;

      // Delete the orphaned records
      for (final record in records) {
        // Get the primary key column and value
        final primaryKeyColumn = _getPrimaryKeyColumn(table);
        final primaryKeyValue = record[primaryKeyColumn];

        if (primaryKeyValue != null) {
          await txn.delete(
            table,
            where: '$primaryKeyColumn = ?',
            whereArgs: [primaryKeyValue],
          );

          LogService.info('Deleted orphaned record from $table with $primaryKeyColumn = $primaryKeyValue');

          if (!results.containsKey(table)) {
            results[table] = [];
          }
          (results[table] as List).add(record);
        }
      }
    }

    return results;
  }

  /// Fix consistency issues
  ///
  /// This method fixes consistency issues found by checkDataConsistency.
  /// It returns a map of fixed issues.
  static Future<Map<String, dynamic>> _fixConsistencyIssues(
    Transaction txn,
    Map<String, List<Map<String, dynamic>>> issues,
  ) async {
    final results = <String, dynamic>{};

    // For each table with issues
    for (final entry in issues.entries) {
      final table = entry.key;
      final records = entry.value;

      // Fix the consistency issues based on the table
      for (final record in records) {
        final primaryKeyColumn = _getPrimaryKeyColumn(table);
        final primaryKeyValue = record[primaryKeyColumn];

        if (primaryKeyValue == null) continue;

        switch (table) {
          case 'booking':
            // Fix bookings with end date before start date
            if (record['startDate'] != null && record['endDate'] != null) {
              final startDate = DateTime.parse(record['startDate'] as String);
              final endDate = DateTime.parse(record['endDate'] as String);

              if (endDate.isBefore(startDate)) {
                // Swap start and end dates
                await txn.update(
                  table,
                  {
                    'startDate': endDate.toIso8601String(),
                    'endDate': startDate.toIso8601String(),
                  },
                  where: '$primaryKeyColumn = ?',
                  whereArgs: [primaryKeyValue],
                );

                LogService.info('Fixed booking with end date before start date: $primaryKeyValue');

                if (!results.containsKey('booking_date_swapped')) {
                  results['booking_date_swapped'] = [];
                }
                (results['booking_date_swapped'] as List).add(record);
              }
            }

            // Fix bookings with invalid studio type
            if (record['isRecordingStudio'] == 0 && record['isProductionStudio'] == 0) {
              await txn.update(
                table,
                {'isRecordingStudio': 1},
                where: '$primaryKeyColumn = ?',
                whereArgs: [primaryKeyValue],
              );

              LogService.info('Fixed booking with invalid studio type: $primaryKeyValue');

              if (!results.containsKey('booking_type_fixed')) {
                results['booking_type_fixed'] = [];
              }
              (results['booking_type_fixed'] as List).add(record);
            }
            break;

          case 'gear':
            // Fix gear with isOut=1 but no activity log entry
            if (record['isOut'] == 1) {
              final activityLogs = await txn.query(
                'activity_log',
                where: 'gearId = ? AND checkedOut = 1',
                whereArgs: [primaryKeyValue],
                orderBy: 'timestamp DESC',
                limit: 1,
              );

              if (activityLogs.isEmpty) {
                // Update gear to be checked in
                await txn.update(
                  table,
                  {'isOut': 0},
                  where: '$primaryKeyColumn = ?',
                  whereArgs: [primaryKeyValue],
                );

                LogService.info('Fixed gear marked as checked out but no activity log entry: $primaryKeyValue');

                if (!results.containsKey('gear_checkout_fixed')) {
                  results['gear_checkout_fixed'] = [];
                }
                (results['gear_checkout_fixed'] as List).add(record);
              }
            }

            // Fix gear with isOut=0 but last activity log entry is checkout
            if (record['isOut'] == 0) {
              final checkoutLogs = await txn.query(
                'activity_log',
                where: 'gearId = ? AND checkedOut = 1',
                whereArgs: [primaryKeyValue],
                orderBy: 'timestamp DESC',
                limit: 1,
              );

              if (checkoutLogs.isNotEmpty) {
                final lastCheckoutTime = checkoutLogs.first['timestamp'] as String;

                final checkinLogs = await txn.query(
                  'activity_log',
                  where: 'gearId = ? AND checkedOut = 0 AND datetime(timestamp) > datetime(?)',
                  whereArgs: [primaryKeyValue, lastCheckoutTime],
                  orderBy: 'timestamp DESC',
                  limit: 1,
                );

                if (checkinLogs.isEmpty) {
                  // Create a check-in activity log entry
                  await txn.insert(
                    'activity_log',
                    {
                      'gearId': primaryKeyValue,
                      'memberId': null,
                      'checkedOut': 0,
                      'timestamp': DateTime.now().toIso8601String(),
                      'note': 'Automatically checked in by integrity checker',
                    },
                  );

                  LogService.info('Fixed gear marked as checked in but last activity log entry is checkout: $primaryKeyValue');

                  if (!results.containsKey('gear_checkin_fixed')) {
                    results['gear_checkin_fixed'] = [];
                  }
                  (results['gear_checkin_fixed'] as List).add(record);
                }
              }
            }
            break;
        }
      }
    }

    return results;
  }

  /// Get the primary key column for a table
  ///
  /// This method returns the primary key column for a table.
  static String _getPrimaryKeyColumn(String table) {
    switch (table) {
      case 'project_member':
      case 'booking_gear':
        // These tables have composite primary keys
        return table == 'project_member' ? 'projectId' : 'bookingId';
      default:
        // Most tables use 'id' as the primary key
        return 'id';
    }
  }
}
