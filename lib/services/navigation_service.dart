import 'package:flutter/material.dart';
import '../theme/blkwds_animations.dart';
import '../services/log_service.dart';
import '../routes/app_routes.dart';
import '../models/member.dart';
import '../models/project.dart';
import '../models/gear.dart';
import '../models/booking_v2.dart';
import '../screens/booking_panel/booking_panel_controller.dart';
import '../screens/booking_panel/booking_detail_screen_adapter.dart';
import '../screens/booking_panel/booking_detail_screen.dart';

/// Navigation service for BLKWDS Manager
///
/// Provides consistent navigation with animated transitions throughout the app
class NavigationService {
  // Singleton instance
  static final NavigationService _instance = NavigationService._internal();

  // Public accessor for the singleton instance
  static NavigationService get instance => _instance;

  // Factory constructor
  factory NavigationService() => _instance;

  // Internal constructor
  NavigationService._internal();

  // Global navigator key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'NavigationServiceKey');

  // Get navigator state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to a new screen with animation
  Future<T?> navigateTo<T>(
    Widget page, {
    BLKWDSPageTransitionType transitionType = BLKWDSPageTransitionType.rightToLeft,
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
  }) async {
    try {
      final route = BLKWDSPageRoute<T>(
        page: page,
        transitionType: transitionType,
        settings: RouteSettings(arguments: arguments),
      );

      if (clearStack) {
        return await navigator?.pushAndRemoveUntil(route, (route) => false);
      } else if (replace) {
        return await navigator?.pushReplacement(route);
      } else {
        return await navigator?.push(route);
      }
    } catch (e) {
      LogService.error('Navigation error: $e');
      return null;
    }
  }

  /// Navigate back
  void goBack<T>({T? result}) {
    if (navigator?.canPop() ?? false) {
      navigator?.pop(result);
    } else {
      LogService.warning('Cannot go back - no routes to pop');
    }
  }

  /// Navigate to a named route with animation
  Future<T?> navigateToNamed<T>(
    String routeName, {
    BLKWDSPageTransitionType transitionType = BLKWDSPageTransitionType.rightToLeft,
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
  }) async {
    try {
      if (clearStack) {
        return await navigator?.pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
          arguments: arguments,
        );
      } else if (replace) {
        return await navigator?.pushReplacementNamed(
          routeName,
          arguments: arguments,
        );
      } else {
        return await navigator?.pushNamed(routeName, arguments: arguments);
      }
    } catch (e) {
      LogService.error('Navigation error: $e');
      return null;
    }
  }

  /// Get current route name
  String? getCurrentRouteName() {
    String? currentRoute;
    navigator?.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute;
  }

  /// Check if can go back
  bool canGoBack() {
    return navigator?.canPop() ?? false;
  }

  /// Navigate to dashboard
  Future<T?> navigateToDashboard<T>({bool clearStack = true}) async {
    return navigateToNamed<T>(
      AppRoutes.dashboard,
      transitionType: BLKWDSPageTransitionType.fade,
      clearStack: clearStack,
    );
  }

  /// Navigate to booking panel
  Future<T?> navigateToBookingPanel<T>({String? filter}) async {
    return navigateToNamed<T>(
      AppRoutes.bookingPanel,
      transitionType: BLKWDSPageTransitionType.bottomToTop,
      arguments: filter != null ? {'filter': filter} : null,
    );
  }

  /// Navigate to booking detail
  Future<T?> navigateToBookingDetail<T>(Booking booking, BookingPanelController controller) async {
    return navigateTo<T>(
      BookingDetailScreenAdapter(
        booking: booking,
        controller: controller,
      ),
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to booking detail from list
  Future<T?> navigateToBookingDetailFromList<T>(Booking booking, BookingPanelController controller) async {
    return navigateTo<T>(
      BookingDetailScreen(
        booking: booking,
        controller: controller,
      ),
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to calendar
  Future<T?> navigateToCalendar<T>() async {
    return navigateToNamed<T>(
      AppRoutes.calendar,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to settings
  Future<T?> navigateToSettings<T>() async {
    return navigateToNamed<T>(
      AppRoutes.settings,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to add gear
  Future<T?> navigateToAddGear<T>() async {
    return navigateToNamed<T>(
      AppRoutes.addGear,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to member management
  Future<T?> navigateToMemberManagement<T>() async {
    return navigateToNamed<T>(
      AppRoutes.memberManagement,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to member detail
  Future<T?> navigateToMemberDetail<T>(Member member) async {
    return navigateToNamed<T>(
      AppRoutes.memberDetail,
      arguments: {'member': member},
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to add/edit member form
  Future<T?> navigateToMemberForm<T>({Member? member}) async {
    return navigateToNamed<T>(
      AppRoutes.memberForm,
      arguments: member != null ? {'member': member} : null,
      transitionType: member == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to project management
  Future<T?> navigateToProjectManagement<T>() async {
    return navigateToNamed<T>(
      AppRoutes.projectManagement,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to project detail
  Future<T?> navigateToProjectDetail<T>(Project project) async {
    return navigateToNamed<T>(
      AppRoutes.projectDetail,
      arguments: {'project': project},
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to add/edit project form
  Future<T?> navigateToProjectForm<T>({Project? project}) async {
    return navigateToNamed<T>(
      AppRoutes.projectForm,
      arguments: project != null ? {'project': project} : null,
      transitionType: project == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to gear management
  Future<T?> navigateToGearManagement<T>() async {
    return navigateToNamed<T>(
      AppRoutes.gearManagement,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to gear detail
  Future<T?> navigateToGearDetail<T>(Gear gear) async {
    return navigateToNamed<T>(
      AppRoutes.gearDetail,
      arguments: {'gear': gear},
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to add/edit gear form
  Future<T?> navigateToGearForm<T>({Gear? gear}) async {
    return navigateToNamed<T>(
      AppRoutes.gearForm,
      arguments: gear != null ? {'gear': gear} : null,
      transitionType: gear == null ? BLKWDSPageTransitionType.bottomToTop : BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to studio management
  Future<T?> navigateToStudioManagement<T>() async {
    return navigateToNamed<T>(
      AppRoutes.studioManagement,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to activity log
  Future<T?> navigateToActivityLog<T>({dynamic controller}) async {
    return navigateToNamed<T>(
      AppRoutes.activityLog,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
      arguments: controller != null ? {'controller': controller} : null,
    );
  }

  /// Navigate to app config
  Future<T?> navigateToAppConfig<T>() async {
    return navigateToNamed<T>(
      AppRoutes.appConfig,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to app info
  Future<T?> navigateToAppInfo<T>() async {
    return navigateToNamed<T>(
      AppRoutes.appInfo,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to database integrity
  Future<T?> navigateToDatabaseIntegrity<T>() async {
    return navigateToNamed<T>(
      AppRoutes.databaseIntegrity,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to style demo
  Future<T?> navigateToStyleDemo<T>() async {
    return navigateToNamed<T>(
      AppRoutes.styleDemo,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }
}
