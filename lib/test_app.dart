import 'package:flutter/material.dart';
import 'dart:io';
import 'theme/blkwds_colors.dart';
// Typography is imported via blkwds_theme.dart
import 'theme/blkwds_constants.dart';

/// A simple test app to verify basic functionality on Android
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: BLKWDSColors.primary,
        scaffoldBackgroundColor: BLKWDSColors.backgroundDark,
        colorScheme: ColorScheme.dark(
          primary: BLKWDSColors.primary,
          secondary: BLKWDSColors.accentTeal,
          // Using surface instead of deprecated background
          surface: BLKWDSColors.backgroundDark,
        ),
      ),
      home: const TestHomePage(),
    );
  }
}

class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State<TestHomePage> createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  String _platformInfo = 'Loading...';
  String _directoryInfo = 'Loading...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get platform info
      final platformInfo = 'Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\\n'
          'Is Android: ${Platform.isAndroid}\\n'
          'Is Windows: ${Platform.isWindows}';

      // Get directory info
      final tempDir = await Directory.systemTemp.create(recursive: true);
      final appDocDir = await _getApplicationDocumentsDirectory();
      final directoryInfo = 'Temp Directory: ${tempDir.path}\\n'
          'App Documents Directory: ${appDocDir?.path ?? "Not available"}';

      setState(() {
        _platformInfo = platformInfo;
        _directoryInfo = directoryInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _platformInfo = 'Error getting platform info: $e';
        _directoryInfo = 'Error getting directory info: $e';
        _isLoading = false;
      });
    }
  }

  Future<Directory?> _getApplicationDocumentsDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory = Directory('/data/data/${Platform.environment['PACKAGE_NAME'] ?? 'com.blkwds.manager'}/app_flutter');
        if (await directory.exists()) {
          return directory;
        }
        return await directory.create(recursive: true);
      } else if (Platform.isWindows) {
        final directory = Directory('${Platform.environment['APPDATA']}\\BLKWDS_Manager');
        if (await directory.exists()) {
          return directory;
        }
        return await directory.create(recursive: true);
      }
    } catch (e) {
      // Using comment instead of print for logging in production code
      // Error getting app documents directory: $e
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLKWDS Test App'),
        backgroundColor: BLKWDSColors.primary,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(BLKWDSConstants.contentPaddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Platform Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BLKWDSColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BLKWDSColors.backgroundMedium,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _platformInfo,
                      style: const TextStyle(
                        color: BLKWDSColors.textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Directory Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BLKWDSColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BLKWDSColors.backgroundMedium,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _directoryInfo,
                      style: const TextStyle(
                        color: BLKWDSColors.textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BLKWDSColors.primary,
                    ),
                    child: const Text('Refresh Information'),
                  ),
                ],
              ),
            ),
    );
  }
}
