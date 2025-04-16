import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../services/contextual_error_handler.dart';
import '../../services/error_service.dart';
import '../../services/error_type.dart';
import '../../services/retry_service.dart';
import '../../services/retry_strategy.dart';

/// SettingsController
/// Handles state management and business logic for the Settings screen
class SettingsController {
  // Build context for error handling
  BuildContext? context;
  // Value notifiers for reactive UI updates
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> successMessage = ValueNotifier<String?>(null);

  // Theme settings
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

  // App information
  final String appVersion = '1.0.0-rc1';
  final String appBuildNumber = '1';
  final String appCopyright = '© ${DateTime.now().year} BLKWDS Studios';

  // Shared preferences keys
  static const String _themeModeKey = 'theme_mode';

  // Set the context for error handling
  void setContext(BuildContext context) {
    this.context = context;
  }

  // Initialize controller
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      await _loadPreferences();
    } catch (e, stackTrace) {
      errorMessage.value = ErrorService.handleError(e, stackTrace: stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.state,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error initializing settings', e, stackTrace);
      }
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
    } catch (e, stackTrace) {
      LogService.error('Error loading preferences', e, stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.state,
          feedbackLevel: ErrorFeedbackLevel.silent, // Silent because we're rethrowing
        );
      }

      rethrow;
    }
  }

  // Save preferences to shared preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save theme mode
      await prefs.setInt(_themeModeKey, themeMode.value.index);
    } catch (e, stackTrace) {
      LogService.error('Error saving preferences', e, stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.state,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      }

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
      // Get all data using retry logic
      final members = await RetryService.retry<List<Member>>(
        operation: () => DBService.getAllMembers(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      final projects = await RetryService.retry<List<Project>>(
        operation: () => DBService.getAllProjects(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      final gear = await RetryService.retry<List<Gear>>(
        operation: () => DBService.getAllGear(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      final bookings = await RetryService.retry<List<Booking>>(
        operation: () => DBService.getAllBookings(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

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

      // Show success message if context is available
      if (context != null) {
        ErrorService.showSuccessSnackBar(context!, 'Data exported successfully');
      }

      return file.path;
    } catch (e, stackTrace) {
      final errorMsg = 'Error exporting data: ${e.toString()}';
      errorMessage.value = errorMsg;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.fileSystem,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error exporting data', e, stackTrace);
      }

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

        // Use contextual error handler if context is available
        if (context != null) {
          ContextualErrorHandler.handleError(
            context!,
            'Invalid import data format',
            type: ErrorType.format,
            feedbackLevel: ErrorFeedbackLevel.snackbar,
          );
        }

        return false;
      }

      // Clear existing data with retry logic
      await RetryService.retry<void>(
        operation: () => DBService.clearAllData(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Import members
      final members = (importData['members'] as List)
          .map((m) => Member.fromJson(m))
          .toList();
      for (final member in members) {
        await RetryService.retry<int>(
          operation: () => DBService.insertMember(member),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        );
      }

      // Import projects
      final projects = (importData['projects'] as List)
          .map((p) => Project.fromJson(p))
          .toList();
      for (final project in projects) {
        await RetryService.retry<int>(
          operation: () => DBService.insertProject(project),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        );
      }

      // Import gear
      final gear = (importData['gear'] as List)
          .map((g) => Gear.fromJson(g))
          .toList();
      for (final item in gear) {
        await RetryService.retry<int>(
          operation: () => DBService.insertGear(item),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        );
      }

      // Import bookings
      final bookings = (importData['bookings'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
      for (final booking in bookings) {
        await RetryService.retry<int>(
          operation: () => DBService.insertBooking(booking),
          maxAttempts: 3,
          strategy: RetryStrategy.exponential,
          initialDelay: const Duration(milliseconds: 500),
          retryCondition: RetryService.isRetryableError,
        );
      }

      successMessage.value = 'Data imported successfully';

      // Show success message if context is available
      if (context != null) {
        ErrorService.showSuccessSnackBar(context!, 'Data imported successfully');
      }

      return true;
    } catch (e, stackTrace) {
      final errorMsg = 'Error importing data: ${e.toString()}';
      errorMessage.value = errorMsg;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.fileSystem,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error importing data', e, stackTrace);
      }

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

      // Export members with retry logic
      final members = await RetryService.retry<List<Member>>(
        operation: () => DBService.getAllMembers(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
      final membersFile = File('${directory.path}/blkwds_members_$timestamp.csv');
      final membersData = _convertMembersToCsv(members);
      await membersFile.writeAsString(membersData);
      filePaths.add(membersFile.path);

      // Export projects with retry logic
      final projects = await RetryService.retry<List<Project>>(
        operation: () => DBService.getAllProjects(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
      final projectsFile = File('${directory.path}/blkwds_projects_$timestamp.csv');
      final projectsData = _convertProjectsToCsv(projects);
      await projectsFile.writeAsString(projectsData);
      filePaths.add(projectsFile.path);

      // Export gear with retry logic
      final gear = await RetryService.retry<List<Gear>>(
        operation: () => DBService.getAllGear(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
      final gearFile = File('${directory.path}/blkwds_gear_$timestamp.csv');
      final gearData = _convertGearToCsv(gear);
      await gearFile.writeAsString(gearData);
      filePaths.add(gearFile.path);

      // Export bookings with retry logic
      final bookings = await RetryService.retry<List<Booking>>(
        operation: () => DBService.getAllBookings(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
      final bookingsFile = File('${directory.path}/blkwds_bookings_$timestamp.csv');
      final bookingsData = _convertBookingsToCsv(bookings);
      await bookingsFile.writeAsString(bookingsData);
      filePaths.add(bookingsFile.path);

      successMessage.value = 'Data exported to CSV successfully';

      // Show success message if context is available
      if (context != null) {
        ErrorService.showSuccessSnackBar(context!, 'Data exported to CSV successfully');
      }

      return filePaths;
    } catch (e, stackTrace) {
      final errorMsg = 'Error exporting to CSV: ${e.toString()}';
      errorMessage.value = errorMsg;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.fileSystem,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error exporting to CSV', e, stackTrace);
      }

      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Convert members to CSV
  String _convertMembersToCsv(List<Member> members) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Name,Role');

    // Data
    for (final member in members) {
      buffer.writeln('${member.id},${_escapeCsv(member.name)},${_escapeCsv(member.role ?? '')}');
    }

    return buffer.toString();
  }

  // Convert projects to CSV
  String _convertProjectsToCsv(List<Project> projects) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Title,Client,Notes');

    // Data
    for (final project in projects) {
      buffer.writeln('${project.id},${_escapeCsv(project.title)},${_escapeCsv(project.client ?? '')},${_escapeCsv(project.notes ?? '')}');
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
      // Clear all data with retry logic
      await RetryService.retry<void>(
        operation: () => DBService.clearAllData(),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Add default data
      await _addDefaultData();

      successMessage.value = 'App data reset successfully';

      // Show success message if context is available
      if (context != null) {
        ErrorService.showSuccessSnackBar(context!, 'App data reset successfully');
      }

      return true;
    } catch (e, stackTrace) {
      final errorMsg = 'Error resetting app data: ${e.toString()}';
      errorMessage.value = errorMsg;

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.database,
          feedbackLevel: ErrorFeedbackLevel.snackbar,
        );
      } else {
        LogService.error('Error resetting app data', e, stackTrace);
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Add default data
  Future<void> _addDefaultData() async {
    try {
      // Add default members with retry logic
      await RetryService.retry<int>(
        operation: () => DBService.insertMember(Member(
          id: 1,
          name: 'Alex Johnson',
          role: 'Director',
        )),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Add default projects with retry logic
      await RetryService.retry<int>(
        operation: () => DBService.insertProject(Project(
          id: 1,
          title: 'Brand Commercial',
          client: 'Brand X',
          notes: 'Commercial shoot for Brand X',
        )),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );

      // Add default gear with retry logic
      await RetryService.retry<int>(
        operation: () => DBService.insertGear(Gear(
          id: 1,
          name: 'Canon R6',
          category: 'Camera',
          description: 'Canon EOS R6 Mirrorless Camera',
          serialNumber: 'CR6123456',
          purchaseDate: DateTime(2022, 1, 15),
          isOut: false,
        )),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 500),
        retryCondition: RetryService.isRetryableError,
      );
    } catch (e, stackTrace) {
      LogService.error('Error adding default data', e, stackTrace);

      // Use contextual error handler if context is available
      if (context != null) {
        ContextualErrorHandler.handleError(
          context!,
          e,
          stackTrace: stackTrace,
          type: ErrorType.database,
          feedbackLevel: ErrorFeedbackLevel.silent, // Silent because we're handling it in the parent method
        );
      }

      rethrow;
    }
  }

  // Dispose resources
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    successMessage.dispose();
    themeMode.dispose();
  }
}
