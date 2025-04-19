import 'package:flutter/material.dart';
import 'theme/blkwds_theme.dart';
import 'utils/constants.dart';
import 'screens/screens.dart';
import 'services/services.dart';
import 'services/navigation_helper.dart';
import 'theme/blkwds_animations.dart';
import 'theme/blkwds_constants.dart';
import 'theme/blkwds_colors.dart';
import 'theme/blkwds_typography.dart';
import 'widgets/blkwds_widgets.dart';
import 'routes/app_routes.dart';

/// BLKWDSApp
/// The main application widget
class BLKWDSApp extends StatefulWidget {
  const BLKWDSApp({super.key});

  @override
  State<BLKWDSApp> createState() => _BLKWDSAppState();
}

class _BLKWDSAppState extends State<BLKWDSApp> {
  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = _handleFlutterError;
  }

  // Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    LogService.error(
      'Flutter framework error',
      details.exception,
      details.stack,
    );
    // Let Flutter show the error in debug mode
    FlutterError.dumpErrorToConsole(details);
  }

  // Use NavigationHelper for navigation

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: BLKWDSTheme.theme,
      initialRoute: AppRoutes.dashboard,
      navigatorKey: NavigationService.instance.navigatorKey,
      scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      // Define named routes
      routes: AppRoutes.routes,
      // Generate routes for dynamic routes or routes with parameters
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Add error handling for navigation/routing errors
      onUnknownRoute: (settings) {
        LogService.error('Unknown route: ${settings.name}');
        return BLKWDSPageRoute(
          page: const DashboardScreen(),
          transitionType: BLKWDSPageTransitionType.fade,
        );
      },
      // Add error handling for widget errors
      builder: (context, widget) {
        // Add error handling widget
        Widget errorWidget = widget ?? const SizedBox.shrink();

        // Catch errors in the widget tree
        ErrorWidget.builder = (FlutterErrorDetails details) {
          LogService.error(
            'Error in widget tree',
            details.exception,
            details.stack,
          );
          return _buildErrorWidget(context, details.exception.toString());
        };

        // Wrap with ErrorBoundary and BannerService overlay
        return BannerService.getBannerOverlay(
          child: ErrorBoundary(
            errorSource: 'app',
            fallbackWidget: _buildErrorWidget(context, 'An unexpected error occurred in the application'),
            child: errorWidget,
          ),
        );
      },
    );
  }

  // Build a user-friendly error widget
  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.contentPaddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BLKWDSEnhancedIconContainer(
                icon: Icons.error_outline,
                size: BLKWDSEnhancedIconContainerSize.large,
                backgroundColor: BLKWDSColors.errorRed.withAlpha(51),
                iconColor: BLKWDSColors.errorRed,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Text(
                'Something went wrong',
                style: BLKWDSTypography.headlineMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingXSmall),
              Text(
                ErrorService.getUserFriendlyMessage(ErrorType.unknown, errorMessage),
                textAlign: TextAlign.center,
                style: BLKWDSTypography.bodyMedium,
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              BLKWDSEnhancedButton(
                label: 'Return to Dashboard',
                onPressed: () {
                  NavigationHelper.navigateToDashboard(clearStack: true);
                },
                type: BLKWDSEnhancedButtonType.primary,
                icon: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
