import 'package:sqflite/sqflite.dart';
import '../migration.dart';
import '../../log_service.dart';

/// Migration from v5 to v6
/// Converts existing bookings to use the studio system
class MigrationV5ToV6 implements Migration {
  @override
  int get fromVersion => 5;

  @override
  int get toVersion => 6;

  @override
  String get description => 'Converts existing bookings to use the studio system';

  @override
  Future<bool> execute(Database db) async {
    LogService.info('Running migration v5 to v6');

    bool success = false;
    await db.transaction((txn) async {
      try {
        // Get all studios
        final studioMaps = await txn.query('studio');

        // Find recording and production studios
        int? recordingStudioId;
        int? productionStudioId;

        for (final studioMap in studioMaps) {
          final type = studioMap['type'] as String;
          if (type == 'recording') {
            recordingStudioId = studioMap['id'] as int;
          } else if (type == 'production') {
            productionStudioId = studioMap['id'] as int;
          }
        }

        // If studios don't exist, create them
        if (recordingStudioId == null) {
          recordingStudioId = await txn.insert('studio', {
            'name': 'Recording Studio',
            'type': 'recording',
            'description': 'Main recording studio space',
            'status': 'available',
          });
          LogService.info('Created Recording Studio with ID $recordingStudioId');
        }

        if (productionStudioId == null) {
          productionStudioId = await txn.insert('studio', {
            'name': 'Production Studio',
            'type': 'production',
            'description': 'Main production studio space',
            'status': 'available',
          });
          LogService.info('Created Production Studio with ID $productionStudioId');
        }

        // Get all bookings
        final bookingMaps = await txn.query('booking');

        // Create a hybrid studio if needed
        int? hybridStudioId;
        bool needsHybridStudio = false;

        for (final bookingMap in bookingMaps) {
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int?) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int?) == 1;

          if (isRecordingStudio == true && isProductionStudio == true) {
            needsHybridStudio = true;
            break;
          }
        }

        if (needsHybridStudio) {
          // Check if hybrid studio already exists
          for (final studioMap in studioMaps) {
            final type = studioMap['type'] as String;
            if (type == 'hybrid') {
              hybridStudioId = studioMap['id'] as int;
              break;
            }
          }

          if (hybridStudioId == null) {
            hybridStudioId = await txn.insert('studio', {
              'name': 'Hybrid Studio',
              'type': 'hybrid',
              'description': 'Combined recording and production studio space',
              'status': 'available',
            });
            LogService.info('Created Hybrid Studio with ID $hybridStudioId');
          }
        }

        // Update each booking with the appropriate studio ID
        int bookingsUpdated = 0;
        for (final bookingMap in bookingMaps) {
          final bookingId = bookingMap['id'] as int;
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int?) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int?) == 1;

          int? studioId;
          if (isRecordingStudio == true && isProductionStudio == true) {
            studioId = hybridStudioId;
          } else if (isRecordingStudio == true) {
            studioId = recordingStudioId;
          } else if (isProductionStudio == true) {
            studioId = productionStudioId;
          }

          if (studioId != null) {
            await txn.update(
              'booking',
              {'studioId': studioId},
              where: 'id = ?',
              whereArgs: [bookingId],
            );
            bookingsUpdated++;
          }
        }

        LogService.info('Updated $bookingsUpdated bookings with studio IDs');
        LogService.info('Migration v5 to v6 completed successfully');
        success = true;
      } catch (e, stackTrace) {
        LogService.error('Error during migration v5 to v6', e, stackTrace);
        rethrow;
      }
    });

    return success;
  }
}
