import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../theme/blkwds_colors.dart';

/// SettingsController
/// Handles state management and business logic for the Settings screen
class SettingsController {
  // Value notifiers for reactive UI updates
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> successMessage = ValueNotifier<String?>(null);

  // Theme settings
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  // App information
  final String appVersion = '1.0.0';
  final String appBuildNumber = '1';
  final String appCopyright = '© ${DateTime.now().year} BLKWDS Studios';

  // Shared preferences keys
  static const String _themeModeKey = 'theme_mode';

  // Initialize controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      await _loadPreferences();
    } catch (e) {
      errorMessage.value = 'Error initializing settings: $e';
      print('Error initializing settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load preferences from shared preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null) {
        themeMode.value = ThemeMode.values[themeModeIndex];
      }
    } catch (e) {
      print('Error loading preferences: $e');
      rethrow;
    }
  }

  // Save preferences to shared preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save theme mode
      await prefs.setInt(_themeModeKey, themeMode.value.index);
    } catch (e) {
      print('Error saving preferences: $e');
      rethrow;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _savePreferences();
  }

  // Export data to JSON
  Future<String?> exportData() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      // Get all data
      final members = await DBService.getAllMembers();
      final projects = await DBService.getAllProjects();
      final gear = await DBService.getAllGear();
      final bookings = await DBService.getAllBookings();

      // Create export data
      final exportData = {
        'members': members.map((m) => m.toJson()).toList(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'gear': gear.map((g) => g.toJson()).toList(),
        'bookings': bookings.map((b) => b.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': appVersion,
      };

      // Convert to JSON
      final jsonData = jsonEncode(exportData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'blkwds_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonData);

      successMessage.value = 'Data exported successfully to ${file.path}';
      return file.path;
    } catch (e) {
      errorMessage.value = 'Error exporting data: $e';
      print('Error exporting data: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Import data from JSON
  Future<bool> importData(String filePath) async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      // Read file
      final file = File(filePath);
      final jsonData = await file.readAsString();

      // Parse JSON
      final importData = jsonDecode(jsonData);

      // Validate data
      if (!_validateImportData(importData)) {
        errorMessage.value = 'Invalid import data format';
        return false;
      }

      // Clear existing data
      await DBService.clearAllData();

      // Import members
      final members = (importData['members'] as List)
          .map((m) => Member.fromJson(m))
          .toList();
      for (final member in members) {
        await DBService.insertMember(member);
      }

      // Import projects
      final projects = (importData['projects'] as List)
          .map((p) => Project.fromJson(p))
          .toList();
      for (final project in projects) {
        await DBService.insertProject(project);
      }

      // Import gear
      final gear = (importData['gear'] as List)
          .map((g) => Gear.fromJson(g))
          .toList();
      for (final item in gear) {
        await DBService.insertGear(item);
      }

      // Import bookings
      final bookings = (importData['bookings'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
      for (final booking in bookings) {
        await DBService.insertBooking(booking);
      }

      successMessage.value = 'Data imported successfully';
      return true;
    } catch (e) {
      errorMessage.value = 'Error importing data: $e';
      print('Error importing data: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Validate import data
  bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('members') &&
        data.containsKey('projects') &&
        data.containsKey('gear') &&
        data.containsKey('bookings');
  }

  // Export data to CSV
  Future<List<String>?> exportToCsv() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final List<String> filePaths = [];

      // Export members
      final members = await DBService.getAllMembers();
      final membersFile = File('${directory.path}/blkwds_members_$timestamp.csv');
      final membersData = _convertMembersToCsv(members);
      await membersFile.writeAsString(membersData);
      filePaths.add(membersFile.path);

      // Export projects
      final projects = await DBService.getAllProjects();
      final projectsFile = File('${directory.path}/blkwds_projects_$timestamp.csv');
      final projectsData = _convertProjectsToCsv(projects);
      await projectsFile.writeAsString(projectsData);
      filePaths.add(projectsFile.path);

      // Export gear
      final gear = await DBService.getAllGear();
      final gearFile = File('${directory.path}/blkwds_gear_$timestamp.csv');
      final gearData = _convertGearToCsv(gear);
      await gearFile.writeAsString(gearData);
      filePaths.add(gearFile.path);

      // Export bookings
      final bookings = await DBService.getAllBookings();
      final bookingsFile = File('${directory.path}/blkwds_bookings_$timestamp.csv');
      final bookingsData = _convertBookingsToCsv(bookings);
      await bookingsFile.writeAsString(bookingsData);
      filePaths.add(bookingsFile.path);

      successMessage.value = 'Data exported to CSV successfully';
      return filePaths;
    } catch (e) {
      errorMessage.value = 'Error exporting to CSV: $e';
      print('Error exporting to CSV: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Convert members to CSV
  String _convertMembersToCsv(List<Member> members) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Name,Email,Phone');

    // Data
    for (final member in members) {
      buffer.writeln('${member.id},${_escapeCsv(member.name)},${_escapeCsv(member.email ?? '')},${_escapeCsv(member.phone ?? '')}');
    }

    return buffer.toString();
  }

  // Convert projects to CSV
  String _convertProjectsToCsv(List<Project> projects) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Title,Description,Client');

    // Data
    for (final project in projects) {
      buffer.writeln('${project.id},${_escapeCsv(project.title)},${_escapeCsv(project.description ?? '')},${_escapeCsv(project.client ?? '')}');
    }

    return buffer.toString();
  }

  // Convert gear to CSV
  String _convertGearToCsv(List<Gear> gear) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Name,Category,Description,Serial Number,Purchase Date,Is Out');

    // Data
    for (final item in gear) {
      final purchaseDate = item.purchaseDate != null
          ? item.purchaseDate!.toIso8601String()
          : '';

      buffer.writeln('${item.id},${_escapeCsv(item.name)},${_escapeCsv(item.category)},${_escapeCsv(item.description ?? '')},${_escapeCsv(item.serialNumber ?? '')},$purchaseDate,${item.isOut}');
    }

    return buffer.toString();
  }

  // Convert bookings to CSV
  String _convertBookingsToCsv(List<Booking> bookings) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Project ID,Start Date,End Date,Recording Studio,Production Studio,Gear IDs');

    // Data
    for (final booking in bookings) {
      final gearIds = booking.gearIds.join(';');

      buffer.writeln('${booking.id},${booking.projectId},${booking.startDate.toIso8601String()},${booking.endDate.toIso8601String()},${booking.isRecordingStudio},${booking.isProductionStudio},$gearIds');
    }

    return buffer.toString();
  }

  // Escape CSV values
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // Reset app data
  Future<bool> resetAppData() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      // Clear all data
      await DBService.clearAllData();

      // Add default data
      await _addDefaultData();

      successMessage.value = 'App data reset successfully';
      return true;
    } catch (e) {
      errorMessage.value = 'Error resetting app data: $e';
      print('Error resetting app data: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Add default data
  Future<void> _addDefaultData() async {
    // Add default members
    await DBService.insertMember(Member(
      id: 1,
      name: 'Alex Johnson',
      email: 'alex@example.com',
      phone: '555-123-4567',
    ));

    // Add default projects
    await DBService.insertProject(Project(
      id: 1,
      title: 'Brand Commercial',
      description: 'Commercial shoot for Brand X',
      client: 'Brand X',
    ));

    // Add default gear
    await DBService.insertGear(Gear(
      id: 1,
      name: 'Canon R6',
      category: 'Camera',
      description: 'Canon EOS R6 Mirrorless Camera',
      serialNumber: 'CR6123456',
      purchaseDate: DateTime(2022, 1, 15),
      isOut: false,
    ));
  }

  // Dispose resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    themeMode.dispose();
  }
}
