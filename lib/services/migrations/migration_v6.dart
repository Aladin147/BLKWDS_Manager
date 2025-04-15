import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../log_service.dart';
import '../../models/models.dart';

/// Migration V6
/// Converts existing bookings to use the studio system
class MigrationV6 {
  static Future<void> migrate(Database db) async {
    LogService.info('Running migration v6: Converting bookings to use studios');

    await db.transaction((txn) async {
      try {
        // Get all studios
        final studioMaps = await txn.query('studio');
        final studios = studioMaps.map((map) => Studio.fromMap(map)).toList();
        
        // Find recording and production studios
        Studio? recordingStudio;
        Studio? productionStudio;
        
        for (final studio in studios) {
          if (studio.type == StudioType.recording) {
            recordingStudio = studio;
          } else if (studio.type == StudioType.production) {
            productionStudio = studio;
          }
        }
        
        // If studios don't exist, create them
        if (recordingStudio == null) {
          final id = await txn.insert('studio', {
            'name': 'Recording Studio',
            'type': 'recording',
            'description': 'Main recording studio space',
            'status': 'available',
          });
          recordingStudio = Studio(
            id: id,
            name: 'Recording Studio',
            type: StudioType.recording,
            description: 'Main recording studio space',
            status: StudioStatus.available,
          );
          LogService.info('Created Recording Studio with ID $id');
        }
        
        if (productionStudio == null) {
          final id = await txn.insert('studio', {
            'name': 'Production Studio',
            'type': 'production',
            'description': 'Main production studio space',
            'status': 'available',
          });
          productionStudio = Studio(
            id: id,
            name: 'Production Studio',
            type: StudioType.production,
            description: 'Main production studio space',
            status: StudioStatus.available,
          );
          LogService.info('Created Production Studio with ID $id');
        }
        
        // Get all bookings
        final bookingMaps = await txn.query('booking');
        
        // Create a hybrid studio if needed
        Studio? hybridStudio;
        bool needsHybridStudio = false;
        
        for (final bookingMap in bookingMaps) {
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int) == 1;
          
          if (isRecordingStudio && isProductionStudio) {
            needsHybridStudio = true;
            break;
          }
        }
        
        if (needsHybridStudio) {
          // Check if hybrid studio already exists
          bool hybridExists = false;
          for (final studio in studios) {
            if (studio.type == StudioType.hybrid) {
              hybridStudio = studio;
              hybridExists = true;
              break;
            }
          }
          
          if (!hybridExists) {
            final id = await txn.insert('studio', {
              'name': 'Hybrid Studio',
              'type': 'hybrid',
              'description': 'Combined recording and production studio space',
              'status': 'available',
            });
            hybridStudio = Studio(
              id: id,
              name: 'Hybrid Studio',
              type: StudioType.hybrid,
              description: 'Combined recording and production studio space',
              status: StudioStatus.available,
            );
            LogService.info('Created Hybrid Studio with ID $id');
          }
        }
        
        // Update each booking with the appropriate studio ID
        int bookingsUpdated = 0;
        for (final bookingMap in bookingMaps) {
          final bookingId = bookingMap['id'] as int;
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int) == 1;
          
          int? studioId;
          if (isRecordingStudio && isProductionStudio) {
            studioId = hybridStudio?.id;
          } else if (isRecordingStudio) {
            studioId = recordingStudio.id;
          } else if (isProductionStudio) {
            studioId = productionStudio.id;
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
        LogService.info('Migration v6 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v6', e, stackTrace);
        rethrow;
      }
    });
  }
}
