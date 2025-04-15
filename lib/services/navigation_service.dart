import 'package:flutter/material.dart';
import '../theme/blkwds_animations.dart';
import '../services/log_service.dart';

/// Navigation service for BLKWDS Manager
///
/// Provides consistent navigation with animated transitions throughout the app
class NavigationService {
  // Singleton instance
  static final NavigationService _instance = NavigationService._internal();
  
  // Factory constructor
  factory NavigationService() => _instance;
  
  // Internal constructor
  NavigationService._internal();
  
  // Global navigator key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
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
      '/dashboard',
      transitionType: BLKWDSPageTransitionType.fade,
      clearStack: clearStack,
    );
  }
  
  /// Navigate to booking panel
  Future<T?> navigateToBookingPanel<T>() async {
    return navigateToNamed<T>(
      '/booking-panel',
      transitionType: BLKWDSPageTransitionType.bottomToTop,
    );
  }
  
  /// Navigate to calendar
  Future<T?> navigateToCalendar<T>() async {
    return navigateToNamed<T>(
      '/calendar',
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }
  
  /// Navigate to settings
  Future<T?> navigateToSettings<T>() async {
    return navigateToNamed<T>(
      '/settings',
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }
  
  /// Navigate to add gear
  Future<T?> navigateToAddGear<T>() async {
    return navigateToNamed<T>(
      '/add-gear',
      transitionType: BLKWDSPageTransitionType.rightToLeft,
    );
  }
}
