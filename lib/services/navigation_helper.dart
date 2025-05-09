import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../routes/app_routes.dart';
import '../theme/blkwds_animations.dart';
import '../models/booking_v2.dart';
import '../models/gear.dart';
import '../models/member.dart';
import '../models/project.dart';
import '../screens/booking_panel/booking_panel_controller.dart';

/// NavigationHelper
/// A helper class to standardize navigation service access
class NavigationHelper {
  /// Get the navigation service instance
  static NavigationService get service => NavigationService.instance;

  /// Navigate to dashboard
  static Future<T?> navigateToDashboard<T>({bool clearStack = true}) {
    return service.navigateToDashboard(clearStack: clearStack);
  }

  /// Navigate to booking panel
  static Future<T?> navigateToBookingPanel<T>({String? filter}) {
    return service.navigateToBookingPanel(filter: filter);
  }

  /// Navigate to calendar
  static Future<T?> navigateToCalendar<T>() {
    return service.navigateToCalendar();
  }

  /// Navigate to settings
  static Future<T?> navigateToSettings<T>() {
    return service.navigateToSettings();
  }

  /// Navigate to add gear
  static Future<T?> navigateToAddGear<T>() {
    return service.navigateToAddGear();
  }

  /// Navigate to member management
  static Future<T?> navigateToMemberManagement<T>() {
    return service.navigateToMemberManagement();
  }

  /// Navigate to member detail
  static Future<T?> navigateToMemberDetail<T>(Member member) {
    return service.navigateToMemberDetail(member);
  }

  /// Navigate to add/edit member form
  static Future<T?> navigateToMemberForm<T>({Member? member}) {
    return service.navigateToMemberForm(member: member);
  }

  /// Navigate to project management
  static Future<T?> navigateToProjectManagement<T>() {
    return service.navigateToProjectManagement();
  }

  /// Navigate to project detail
  static Future<T?> navigateToProjectDetail<T>(Project project) {
    return service.navigateToProjectDetail(project);
  }

  /// Navigate to add/edit project form
  static Future<T?> navigateToProjectForm<T>({Project? project}) {
    return service.navigateToProjectForm(project: project);
  }

  /// Navigate to gear management
  static Future<T?> navigateToGearManagement<T>() {
    return service.navigateToGearManagement();
  }

  /// Navigate to gear detail
  static Future<T?> navigateToGearDetail<T>(Gear gear) {
    return service.navigateToGearDetail(gear);
  }

  /// Navigate to add/edit gear form
  static Future<T?> navigateToGearForm<T>({Gear? gear}) {
    return service.navigateToGearForm(gear: gear);
  }

  /// Navigate to studio management
  static Future<T?> navigateToStudioManagement<T>() {
    return service.navigateToStudioManagement();
  }

  /// Navigate to activity log
  static Future<T?> navigateToActivityLog<T>({dynamic controller}) {
    return service.navigateToActivityLog(controller: controller);
  }

  /// Navigate to booking detail
  static Future<T?> navigateToBookingDetail<T>(Booking booking, BookingPanelController controller) {
    return service.navigateToBookingDetail(booking, controller);
  }

  /// Navigate to booking detail from list
  static Future<T?> navigateToBookingDetailFromList<T>(Booking booking, BookingPanelController controller) {
    return service.navigateToBookingDetailFromList(booking, controller);
  }

  /// Navigate to app config
  static Future<T?> navigateToAppConfig<T>() {
    return service.navigateToAppConfig();
  }

  /// Navigate to app info
  static Future<T?> navigateToAppInfo<T>() {
    return service.navigateToAppInfo();
  }

  /// Navigate to database integrity
  static Future<T?> navigateToDatabaseIntegrity<T>() {
    return service.navigateToNamed<T>(
      AppRoutes.databaseIntegrity,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to style demo
  static Future<T?> navigateToStyleDemo<T>() {
    return service.navigateToNamed<T>(
      AppRoutes.styleDemo,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to performance test
  static Future<T?> navigateToPerformanceTest<T>() {
    return service.navigateToNamed<T>(
      AppRoutes.performanceTest,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate to device info screen
  static Future<T?> navigateToDeviceInfo<T>() {
    return service.navigateToNamed<T>(
      AppRoutes.deviceInfo,
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }

  /// Navigate back
  static void goBack<T>({T? result}) {
    service.goBack(result: result);
  }

  /// Check if can go back
  static bool canGoBack() {
    return service.canGoBack();
  }

  /// Get current route name
  static String? getCurrentRouteName() {
    return service.getCurrentRouteName();
  }

  /// Navigate to a new screen with animation
  static Future<T?> navigateTo<T>(
    Widget page, {
    BLKWDSPageTransitionType transitionType = BLKWDSPageTransitionType.rightToLeft,
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
  }) {
    return service.navigateTo<T>(
      page,
      transitionType: transitionType,
      replace: replace,
      clearStack: clearStack,
      arguments: arguments,
    );
  }
}
