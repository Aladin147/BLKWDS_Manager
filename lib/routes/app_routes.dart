import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/booking_panel/booking_panel_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/add_gear/add_gear_screen.dart';
import '../screens/member_management/member_list_screen.dart';
import '../screens/project_management/project_list_screen.dart';
import '../screens/gear_management/gear_list_screen.dart';
import '../screens/studio_management/studio_management_screen.dart';
import '../screens/activity_log/activity_log_screen.dart';
import '../theme/blkwds_animations.dart';

/// AppRoutes
/// Defines all named routes for the application
class AppRoutes {
  // Route names
  static const String dashboard = '/dashboard';
  static const String bookingPanel = '/booking-panel';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String addGear = '/add-gear';
  static const String memberManagement = '/member-management';
  static const String projectManagement = '/project-management';
  static const String gearManagement = '/gear-management';
  static const String studioManagement = '/studio-management';
  static const String activityLog = '/activity-log';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
    dashboard: (context) => const DashboardScreen(),
    bookingPanel: (context) => const BookingPanelScreen(),
    calendar: (context) => const CalendarScreen(),
    settings: (context) => const SettingsScreen(),
    addGear: (context) => const AddGearScreen(),
    memberManagement: (context) => const MemberListScreen(),
    projectManagement: (context) => const ProjectListScreen(),
    gearManagement: (context) => const GearListScreen(),
    studioManagement: (context) => const StudioManagementScreen(),
    // Activity log needs a controller, so we'll handle it in onGenerateRoute
  };

  // Generate route for dynamic routes or routes with parameters
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments as Map<String, dynamic>?;
    
    // Handle specific routes that need parameters
    switch (settings.name) {
      case activityLog:
        final controller = args?['controller'];
        return _buildRoute(
          settings,
          ActivityLogScreen(controller: controller),
          BLKWDSPageTransitionType.rightToLeft,
        );
      
      case bookingPanel:
        final filter = args?['filter'];
        return _buildRoute(
          settings,
          BookingPanelScreen(initialFilter: filter),
          BLKWDSPageTransitionType.bottomToTop,
        );
        
      default:
        // If the route is not found, return to dashboard
        return _buildRoute(
          settings,
          const DashboardScreen(),
          BLKWDSPageTransitionType.fade,
        );
    }
  }

  // Build a route with the specified transition
  static Route<dynamic> _buildRoute(
    RouteSettings settings,
    Widget page,
    BLKWDSPageTransitionType transitionType,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case BLKWDSPageTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          
          case BLKWDSPageTransitionType.rightToLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
            
          case BLKWDSPageTransitionType.leftToRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
            
          case BLKWDSPageTransitionType.bottomToTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
            
          case BLKWDSPageTransitionType.topToBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
            
          case BLKWDSPageTransitionType.scale:
            return ScaleTransition(
              scale: animation,
              child: child,
            );
            
          default:
            return FadeTransition(opacity: animation, child: child);
        }
      },
    );
  }
}
