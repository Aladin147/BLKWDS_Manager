import 'package:flutter/material.dart';
import 'theme/blkwds_theme.dart';
import 'utils/constants.dart';
import 'screens/dashboard/dashboard_screen.dart';

/// BLKWDSApp
/// The main application widget
class BLKWDSApp extends StatelessWidget {
  const BLKWDSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: BLKWDSTheme.lightTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
