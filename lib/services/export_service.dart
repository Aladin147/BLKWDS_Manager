import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import '../models/models.dart';

/// ExportService
/// Handles exporting data to CSV files
class ExportService {
  /// Export activity logs to CSV
  static Future<String?> exportActivityLogs(List<ActivityLog> logs) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Gear ID',
        'Member ID',
        'Action',
        'Timestamp',
        'Note',
      ]);

      // Add data rows
      for (final log in logs) {
        csvData.add([
          log.id,
          log.gearId,
          log.memberId ?? '',
          log.checkedOut ? 'Check Out' : 'Check In',
          log.timestamp.toString(),
          log.note ?? '',
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('activity_logs.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      return outputPath;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error exporting activity logs: $e');
      return null;
    }
  }

  /// Export gear inventory to CSV
  static Future<String?> exportGearInventory(List<Gear> gearList) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Name',
        'Category',
        'Status',
        'Last Note',
      ]);

      // Add data rows
      for (final gear in gearList) {
        csvData.add([
          gear.id,
          gear.name,
          gear.category,
          gear.isOut ? 'OUT' : 'IN',
          gear.lastNote ?? '',
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('gear_inventory.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      return outputPath;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error exporting gear inventory: $e');
      return null;
    }
  }

  /// Export bookings to CSV
  static Future<String?> exportBookings(List<Booking> bookings) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Project ID',
        'Start Date',
        'End Date',
        'Recording Studio',
        'Production Studio',
      ]);

      // Add data rows
      for (final booking in bookings) {
        csvData.add([
          booking.id,
          booking.projectId,
          booking.startDate.toString(),
          booking.endDate.toString(),
          booking.isRecordingStudio ? 'Yes' : 'No',
          booking.isProductionStudio ? 'Yes' : 'No',
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('bookings.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      return outputPath;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error exporting bookings: $e');
      return null;
    }
  }

  /// Get save location from user
  static Future<String?> _getSaveLocation(String defaultFileName) async {
    try {
      // Use file_selector to get save location
      final file_selector.XTypeGroup csvTypeGroup = file_selector.XTypeGroup(
        label: 'CSV',
        extensions: ['csv'],
      );

      // Use the file_selector's getSavePath function
      final String? outputPath = await file_selector.getSavePath(
        suggestedName: defaultFileName,
        acceptedTypeGroups: [csvTypeGroup],
      );

      return outputPath;
    } catch (e) {
      // Use a logger in production code instead of print
      // print('Error getting save location: $e');

      // Fallback to default location
      final Directory directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$defaultFileName';
    }
  }
}
