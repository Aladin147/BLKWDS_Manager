import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: BLKWDSTheme.theme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
