import 'dart:io';

/// This script helps identify files that need style migration
/// and provides statistics on component usage.
void main() {
  print('BLKWDS Manager Style Migration Helper');
  print('=====================================\n');

  // Get all Dart files in the lib directory
  final libDir = Directory('lib');
  final dartFiles = _findDartFiles(libDir);
  print('Found ${dartFiles.length} Dart files in the lib directory.\n');

  // Analyze button usage
  final buttonFiles = _findFilesWithPattern(dartFiles, 'BLKWDSButton');
  print('Files using BLKWDSButton: ${buttonFiles.length}');
  
  // Analyze card usage
  final cardFiles = _findFilesWithPattern(dartFiles, 'BLKWDSCard');
  print('Files using BLKWDSCard: ${cardFiles.length}');
  
  // Analyze text styling
  final textStyleFiles = _findFilesWithPattern(dartFiles, 'BLKWDSTypography');
  print('Files using BLKWDSTypography: ${textStyleFiles.length}\n');

  // Identify high-priority files (those using multiple components)
  final highPriorityFiles = _findHighPriorityFiles(dartFiles);
  print('High-priority files for migration (using multiple components):');
  for (final file in highPriorityFiles) {
    print('- ${file.path.replaceAll('\\', '/')}');
  }
  print('');

  // Generate migration status report
  _generateMigrationStatusReport(dartFiles);
}

/// Find all Dart files in a directory and its subdirectories
List<File> _findDartFiles(Directory dir) {
  final files = <File>[];
  
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  
  return files;
}

/// Find files containing a specific pattern
List<File> _findFilesWithPattern(List<File> files, String pattern) {
  final matchingFiles = <File>[];
  
  for (final file in files) {
    final content = file.readAsStringSync();
    if (content.contains(pattern)) {
      matchingFiles.add(file);
    }
  }
  
  return matchingFiles;
}

/// Find high-priority files for migration (those using multiple components)
List<File> _findHighPriorityFiles(List<File> files) {
  final highPriorityFiles = <File>[];
  
  for (final file in files) {
    final content = file.readAsStringSync();
    int score = 0;
    
    if (content.contains('BLKWDSButton')) score++;
    if (content.contains('BLKWDSCard')) score++;
    if (content.contains('BLKWDSTypography')) score++;
    
    // Files with a score of 2 or more are high priority
    if (score >= 2) {
      highPriorityFiles.add(file);
    }
  }
  
  // Sort by path for readability
  highPriorityFiles.sort((a, b) => a.path.compareTo(b.path));
  
  return highPriorityFiles;
}

/// Generate a migration status report
void _generateMigrationStatusReport(List<File> files) {
  final screenFiles = files.where((file) => 
    file.path.contains('screen.dart') || 
    file.path.contains('_screen') ||
    file.path.contains('/screens/')
  ).toList();
  
  print('Screen files that need migration:');
  for (final file in screenFiles) {
    final content = file.readAsStringSync();
    final hasLegacyComponents = 
      content.contains('BLKWDSButton') || 
      content.contains('BLKWDSCard') ||
      content.contains('BLKWDSTypography');
    
    if (hasLegacyComponents) {
      final relativePath = file.path.replaceAll('\\', '/').replaceAll('lib/', '');
      print('- $relativePath');
    }
  }
  
  print('\nRun this script periodically to track migration progress.');
}
