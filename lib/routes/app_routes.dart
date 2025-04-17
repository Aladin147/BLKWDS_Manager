import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../services/log_service.dart';
import '../screens/booking_panel/booking_panel_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/database_integrity_screen.dart';
import '../screens/settings/app_config_screen.dart';
import '../screens/settings/app_info_screen.dart';
import '../screens/add_gear/add_gear_screen.dart';
import '../screens/member_management/member_list_screen.dart';
import '../screens/member_management/member_detail_screen.dart';
import '../screens/member_management/member_form_screen.dart';
import '../screens/project_management/project_list_screen.dart';
import '../screens/project_management/project_detail_screen.dart';
import '../screens/project_management/project_form_screen.dart';
import '../screens/gear_management/gear_list_screen.dart';
import '../screens/gear_management/gear_detail_screen.dart';
import '../screens/gear_management/gear_form_screen.dart';
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
  static const String memberDetail = '/member-detail';
  static const String memberForm = '/member-form';
  static const String projectManagement = '/project-management';
  static const String projectDetail = '/project-detail';
  static const String projectForm = '/project-form';
  static const String gearManagement = '/gear-management';
  static const String gearDetail = '/gear-detail';
  static const String gearForm = '/gear-form';
  static const String studioManagement = '/studio-management';
  static const String activityLog = '/activity-log';
  static const String databaseIntegrity = '/database-integrity';
  static const String appConfig = '/app-config';
  static const String appInfo = '/app-info';

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
    databaseIntegrity: (context) => const DatabaseIntegrityScreen(),
    appConfig: (context) => const AppConfigScreen(),
    appInfo: (context) => const AppInfoScreen(),
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

      case memberDetail:
        final member = args?['member'];
        if (member == null) {
          LogService.error('Member detail route called without member');
          return _buildRoute(
            settings,
            const MemberListScreen(),
            BLKWDSPageTransitionType.fade,
          );
        }
        return _buildRoute(
          settings,
          MemberDetailScreen(member: member),
          BLKWDSPageTransitionType.rightToLeft,
        );

      case memberForm:
        final member = args?['member'];
        return _buildRoute(
          settings,
          MemberFormScreen(member: member),
          member == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
        );

      case projectDetail:
        final project = args?['project'];
        if (project == null) {
          LogService.error('Project detail route called without project');
          return _buildRoute(
            settings,
            const ProjectListScreen(),
            BLKWDSPageTransitionType.fade,
          );
        }
        return _buildRoute(
          settings,
          ProjectDetailScreen(project: project),
          BLKWDSPageTransitionType.rightToLeft,
        );

      case projectForm:
        final project = args?['project'];
        return _buildRoute(
          settings,
          ProjectFormScreen(project: project),
          project == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
        );

      case gearDetail:
        final gear = args?['gear'];
        if (gear == null) {
          LogService.error('Gear detail route called without gear');
          return _buildRoute(
            settings,
            const GearListScreen(),
            BLKWDSPageTransitionType.fade,
          );
        }
        return _buildRoute(
          settings,
          GearDetailScreen(gear: gear),
          BLKWDSPageTransitionType.rightToLeft,
        );

      case gearForm:
        final gear = args?['gear'];
        return _buildRoute(
          settings,
          GearFormScreen(gear: gear),
          gear == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
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

          // Default case is handled by BLKWDSPageTransitionType.fade
        }
      },
    );
  }
}
