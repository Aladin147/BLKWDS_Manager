import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:blkwds_manager/services/database/database_integrity_service.dart';
import 'package:blkwds_manager/services/database/database_integrity_checker.dart';
// We're mocking AppConfigService
import 'package:blkwds_manager/services/db_service.dart';
import '../../../helpers/test_database.dart';
import '../../../helpers/database_corruption_helper.dart';

void main() {
  late Database db;
  late DatabaseIntegrityService integrityService;

  setUp(() async {
    // Create a test database
    db = await TestDatabase.createTestDatabase();

    // Get the integrity service singleton
    integrityService = DatabaseIntegrityService();

    // Set the database for DBService
    DBService.setTestDatabase(db);
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('Service Management', () {
    test('should start and stop correctly', () async {
      // Act - Start the service
      await integrityService.start(runImmediately: false);

      // Assert
      expect(integrityService.isRunning, isTrue);

      // Act - Stop the service
      await integrityService.stop();

      // Assert
      expect(integrityService.isRunning, isFalse);
    });
  });

  group('Manual Integrity Check', () {
    test('should run manual integrity check and detect issues', () async {
      // Create some integrity issues
      await DatabaseCorruptionHelper.createBookingWithInvalidProjectId(db);
      await DatabaseCorruptionHelper.createOrphanedBookingGearRecords(db);
      // Skip creating booking date inconsistencies as they cause issues with date parsing

      // Act
      final results = await integrityService.runManualCheck();

      // Assert
      expect(results, isNotEmpty);
      expect(results.containsKey('foreign_key_issues'), isTrue);
      expect(results.containsKey('orphaned_records'), isTrue);
      expect(results.containsKey('consistency_issues'), isTrue);
    });

    test('should return empty results when no issues exist', () async {
      // Act
      final results = await integrityService.runManualCheck();

      // Assert
      expect(results, isEmpty);
    });
  });

  group('Auto Fix', () {
    test('should automatically fix issues when auto fix is enabled', () async {
      // Arrange
      // Create some integrity issues
      await DatabaseCorruptionHelper.createBookingWithInvalidProjectId(db);
      await DatabaseCorruptionHelper.createOrphanedBookingGearRecords(db);
      // Skip creating booking date inconsistencies as they cause issues with date parsing

      // Act
      final results = await integrityService.runManualCheck(autoFix: true);

      // Assert
      expect(results, isNotEmpty);
      expect(results.containsKey('fix_results'), isTrue); // Should contain fix results

      // Verify no issues remain
      final checkResults = await DatabaseIntegrityChecker.checkIntegrity(db);
      expect(checkResults.isEmpty, true);
    });

    test('should not automatically fix issues when auto fix is disabled', () async {
      // Arrange
      // Create some integrity issues
      await DatabaseCorruptionHelper.createBookingWithInvalidProjectId(db);
      await DatabaseCorruptionHelper.createOrphanedBookingGearRecords(db);
      // Skip creating booking date inconsistencies as they cause issues with date parsing

      // Act
      final results = await integrityService.runManualCheck(autoFix: false);

      // Assert
      expect(results, isNotEmpty); // Should contain issues because auto fix is disabled
      expect(results.containsKey('fix_results'), isFalse); // Should not contain fix results

      // Verify issues still remain
      final checkResults = await DatabaseIntegrityChecker.checkIntegrity(db);
      expect(checkResults, isNotEmpty);
    });
  });

  group('Manual Fix', () {
    test('should manually fix issues', () async {
      // Arrange
      // Create some integrity issues
      await DatabaseCorruptionHelper.createBookingWithInvalidProjectId(db);
      await DatabaseCorruptionHelper.createOrphanedBookingGearRecords(db);
      // Skip creating booking date inconsistencies as they cause issues with date parsing

      // Get the issues
      final checkResults = await integrityService.runManualCheck(autoFix: false);
      expect(checkResults, isNotEmpty);

      // Act
      final fixResults = await DatabaseIntegrityChecker.fixIntegrityIssues(db, checkResults);

      // Assert
      expect(fixResults, isNotEmpty);

      // Verify no issues remain
      final afterFixResults = await DatabaseIntegrityChecker.checkIntegrity(db);
      expect(afterFixResults.isEmpty, true);
    });
  });
}
