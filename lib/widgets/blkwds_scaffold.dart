import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import 'blkwds_home_button.dart';

/// A standardized scaffold for BLKWDS Manager screens
class BLKWDSScaffold extends StatelessWidget {
  /// The title displayed in the app bar
  final String title;
  
  /// The body of the scaffold
  final Widget body;
  
  /// Whether to show the home button in the app bar
  final bool showHomeButton;
  
  /// Actions to display in the app bar
  final List<Widget>? actions;
  
  /// The floating action button to display
  final Widget? floatingActionButton;
  
  /// The bottom navigation bar to display
  final Widget? bottomNavigationBar;
  
  /// The drawer to display
  final Widget? drawer;
  
  /// The bottom sheet to display
  final Widget? bottomSheet;
  
  /// Creates a standardized scaffold
  const BLKWDSScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showHomeButton = true,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BLKWDSColors.backgroundDark,
      appBar: AppBar(
        title: Text(title),
        leading: showHomeButton ? const BLKWDSHomeButton() : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      bottomSheet: bottomSheet,
    );
  }
}
