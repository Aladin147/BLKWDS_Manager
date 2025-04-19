import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';

/// Migration from v8 to v9
/// Ensures all bookings use studioId instead of boolean flags
class MigrationV8ToV9 implements Migration {
  @override
  int get fromVersion => 8;

  @override
  int get toVersion => 9;

  @override
  String get description => 'Ensures all bookings use studioId instead of boolean flags';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v8 to v9');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Find bookings that use boolean flags but don't have studioId set
        final bookingsToUpdate = await txn.query(
          'booking',
          where: '(isRecordingStudio = 1 OR isProductionStudio = 1) AND studioId IS NULL',
        );
        
        LogService.info('Found ${bookingsToUpdate.length} bookings to update');
        
        // Update each booking
        for (final booking in bookingsToUpdate) {
          final isRecordingStudio = booking['isRecordingStudio'] == 1;
          final isProductionStudio = booking['isProductionStudio'] == 1;
          
          // Determine studioId based on boolean flags
          int? studioId;
          if (isRecordingStudio) {
            studioId = 1; // Recording studio has ID 1
          } else if (isProductionStudio) {
            studioId = 2; // Production studio has ID 2
          }
          
          if (studioId != null) {
            await txn.update(
              'booking',
              {'studioId': studioId},
              where: 'id = ?',
              whereArgs: [booking['id']],
            );
            
            LogService.debug('Updated booking ${booking['id']} to use studioId $studioId');
          }
        }
        
        LogService.info('Successfully updated all bookings to use studioId');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v8 to v9', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
