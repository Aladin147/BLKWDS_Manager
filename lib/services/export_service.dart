import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import '../models/models.dart';
import 'log_service.dart';

/// ExportService
/// Handles exporting data to CSV files
class ExportService {
  /// Export all data to CSV files
  /// Returns a list of file paths where the CSV files were saved
  static Future<List<String>> exportAllData({
    required List<Member> members,
    required List<Project> projects,
    required List<Gear> gear,
    required List<Booking> bookings,
    required List<Studio> studios,
    required List<ActivityLog> activityLogs,
  }) async {
    final List<String> filePaths = [];

    try {
      // Export members
      final membersPath = await exportMembers(members);
      if (membersPath != null) filePaths.add(membersPath);

      // Export projects
      final projectsPath = await exportProjects(projects);
      if (projectsPath != null) filePaths.add(projectsPath);

      // Export gear
      final gearPath = await exportGearInventory(gear);
      if (gearPath != null) filePaths.add(gearPath);

      // Export bookings
      final bookingsPath = await exportBookings(bookings);
      if (bookingsPath != null) filePaths.add(bookingsPath);

      // Export studios
      final studiosPath = await exportStudios(studios);
      if (studiosPath != null) filePaths.add(studiosPath);

      // Export activity logs
      final logsPath = await exportActivityLogs(activityLogs);
      if (logsPath != null) filePaths.add(logsPath);

      return filePaths;
    } catch (e, stackTrace) {
      LogService.error('Error exporting all data to CSV', e, stackTrace);
      return filePaths; // Return any files that were successfully exported
    }
  }

  /// Export members to CSV
  static Future<String?> exportMembers(List<Member> members) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Name',
        'Role',
      ]);

      // Add data rows
      for (final member in members) {
        csvData.add([
          member.id,
          member.name,
          member.role ?? '',
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('members.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      LogService.info('Exported ${members.length} members to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting members to CSV', e, stackTrace);
      return null;
    }
  }

  /// Export projects to CSV
  static Future<String?> exportProjects(List<Project> projects) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Title',
        'Client',
        'Description',
        'Notes',
        'Member IDs',
      ]);

      // Add data rows
      for (final project in projects) {
        csvData.add([
          project.id,
          project.title,
          project.client ?? '',
          project.description ?? '',
          project.notes ?? '',
          project.memberIds.join(', '),
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('projects.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      LogService.info('Exported ${projects.length} projects to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting projects to CSV', e, stackTrace);
      return null;
    }
  }

  /// Export studios to CSV
  static Future<String?> exportStudios(List<Studio> studios) async {
    try {
      // Create CSV data
      final List<List<dynamic>> csvData = [];

      // Add header row
      csvData.add([
        'ID',
        'Name',
        'Type',
        'Description',
        'Features',
        'Hourly Rate',
        'Status',
        'Color',
      ]);

      // Add data rows
      for (final studio in studios) {
        csvData.add([
          studio.id,
          studio.name,
          studio.type.label,
          studio.description ?? '',
          studio.features.join(', '),
          studio.hourlyRate?.toString() ?? '',
          studio.status.label,
          studio.color ?? '',
        ]);
      }

      // Convert to CSV string
      final String csv = const ListToCsvConverter().convert(csvData);

      // Get save location from user
      final String? outputPath = await _getSaveLocation('studios.csv');

      if (outputPath == null) {
        return null;
      }

      // Write to file
      final File file = File(outputPath);
      await file.writeAsString(csv);

      LogService.info('Exported ${studios.length} studios to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting studios to CSV', e, stackTrace);
      return null;
    }
  }
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

      LogService.info('Exported ${logs.length} activity logs to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting activity logs to CSV', e, stackTrace);
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
        'Description',
        'Serial Number',
        'Purchase Date',
        'Status',
        'Last Note',
      ]);

      // Add data rows
      for (final gear in gearList) {
        csvData.add([
          gear.id,
          gear.name,
          gear.category,
          gear.description ?? '',
          gear.serialNumber ?? '',
          gear.purchaseDate?.toIso8601String() ?? '',
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

      LogService.info('Exported ${gearList.length} gear items to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting gear inventory to CSV', e, stackTrace);
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
        'Title',
        'Project ID',
        'Studio ID',
        'Start Date',
        'End Date',
        'Recording Studio',
        'Production Studio',
        'Notes',
        'Color',
      ]);

      // Add data rows
      for (final booking in bookings) {
        csvData.add([
          booking.id,
          booking.title ?? '',
          booking.projectId,
          booking.studioId ?? '',
          booking.startDate.toString(),
          booking.endDate.toString(),
          booking.isRecordingStudio ? 'Yes' : 'No',
          booking.isProductionStudio ? 'Yes' : 'No',
          booking.notes ?? '',
          booking.color ?? '',
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

      LogService.info('Exported ${bookings.length} bookings to $outputPath');
      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error exporting bookings to CSV', e, stackTrace);
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

      // Use the file_selector's getSaveLocation function
      final file_selector.FileSaveLocation? saveLocation = await file_selector.getSaveLocation(
        suggestedName: defaultFileName,
        acceptedTypeGroups: [csvTypeGroup],
      );

      final String? outputPath = saveLocation?.path;

      return outputPath;
    } catch (e, stackTrace) {
      LogService.error('Error getting save location', e, stackTrace);

      // Fallback to default location
      try {
        final Directory directory = await getApplicationDocumentsDirectory();
        final String path = '${directory.path}/$defaultFileName';
        LogService.info('Using fallback save location: $path');
        return path;
      } catch (e2, stackTrace2) {
        LogService.error('Error getting fallback save location', e2, stackTrace2);
        return null;
      }
    }
  }
}
