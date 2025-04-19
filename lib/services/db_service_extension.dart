import '../models/models.dart';
import '../services/db_service.dart';

/// Extension methods for DBService
/// These methods extend the functionality of DBService without modifying the original class
extension DBServiceExtension on DBService {
  /// Get all activity logs
  static Future<List<ActivityLog>> getAllActivityLogs() async {
    final db = await DBService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_log',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }
}
