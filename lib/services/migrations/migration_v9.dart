import 'package:sqflite/sqflite.dart';
import '../log_service.dart';

/// Migration for database version 9
/// Ensures all bookings use studioId instead of boolean flags
class MigrationV9 {
  /// Migrate the database to version 9
  static Future<void> migrate(Database db) async {
    LogService.info('Running migration to version 9: Consolidating booking model');
    
    try {
      // Begin transaction
      await db.transaction((txn) async {
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
      });
      
      LogService.info('Migration to version 9 completed successfully');
    } catch (e, stackTrace) {
      LogService.error('Error during migration to version 9', e, stackTrace);
      rethrow;
    }
  }
}
