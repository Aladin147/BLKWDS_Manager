import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../log_service.dart';

/// Migration to add title column to booking table
class MigrationV5 {
  static const int version = 5;

  static Future<void> migrate(Database db) async {
    LogService.info('Running migration v5: Adding title column to booking table');

    // Add title column to booking table
    await db.execute('''
      ALTER TABLE booking ADD COLUMN title TEXT;
    ''');

    // Update existing bookings with default titles
    final List<Map<String, dynamic>> bookings = await db.query('booking');
    
    for (final booking in bookings) {
      final bookingId = booking['id'] as int;
      final projectId = booking['projectId'] as int;
      
      // Get project title
      final List<Map<String, dynamic>> projects = await db.query(
        'project',
        where: 'id = ?',
        whereArgs: [projectId],
      );
      
      String title = 'Booking';
      if (projects.isNotEmpty) {
        title = 'Booking for ${projects.first['title']}';
      }
      
      // Update booking with title
      await db.update(
        'booking',
        {'title': title},
        where: 'id = ?',
        whereArgs: [bookingId],
      );
    }

    LogService.info('Migration v5 completed successfully');
  }
}
