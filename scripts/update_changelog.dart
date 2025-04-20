import 'dart:io';

/// A simple script to help with updating the changelog.
/// 
/// Usage: dart scripts/update_changelog.dart
void main() {
  // Get the current date in YYYY-MM-DD format
  final now = DateTime.now();
  final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  
  // Read the current changelog
  final changelogFile = File('changelog.md');
  if (!changelogFile.existsSync()) {
    print('Error: changelog.md not found');
    exit(1);
  }
  
  final changelogContent = changelogFile.readAsStringSync();
  
  // Get the latest version number
  final versionRegex = RegExp(r'\[1\.0\.0-rc(\d+)\]');
  final match = versionRegex.firstMatch(changelogContent);
  if (match == null) {
    print('Error: Could not find version number in changelog');
    exit(1);
  }
  
  final currentVersion = int.parse(match.group(1)!);
  final newVersion = currentVersion + 1;
  
  // Create the new version entry
  final newEntry = '''
## [1.0.0-rc$newVersion] - $date

**Added:**
- 

**Fixed:**
- 

**Improved:**
- 

**Changed:**
- 
''';
  
  // Insert the new entry at the top of the changelog
  final insertIndex = changelogContent.indexOf('## [');
  if (insertIndex == -1) {
    print('Error: Could not find insertion point in changelog');
    exit(1);
  }
  
  final newChangelogContent = changelogContent.substring(0, insertIndex) + 
                             newEntry + 
                             '\n' + 
                             changelogContent.substring(insertIndex);
  
  // Write the new changelog
  changelogFile.writeAsStringSync(newChangelogContent);
  
  print('Changelog updated with new version 1.0.0-rc$newVersion');
  print('Please fill in the details and commit the changes');
}
