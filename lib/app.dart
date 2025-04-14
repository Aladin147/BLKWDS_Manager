import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/blkwds_theme.dart';
import 'utils/constants.dart';
import 'screens/screens.dart';

/// BLKWDSApp
/// The main application widget
class BLKWDSApp extends StatefulWidget {
  const BLKWDSApp({super.key});

  @override
  State<BLKWDSApp> createState() => _BLKWDSAppState();
}

class _BLKWDSAppState extends State<BLKWDSApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode');
      if (themeModeIndex != null) {
        setState(() {
          _themeMode = ThemeMode.values[themeModeIndex];
        });
      }
    } catch (e) {
      print('Error loading theme mode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: BLKWDSTheme.lightTheme,
      darkTheme: BLKWDSTheme.darkTheme,
      themeMode: _themeMode,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
