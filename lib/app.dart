import 'package:flutter/material.dart';
import 'theme/blkwds_theme.dart';
import 'utils/constants.dart';
import 'screens/screens.dart';
import 'services/services.dart';
import 'theme/blkwds_animations.dart';
import 'theme/blkwds_constants.dart';
import 'theme/blkwds_colors.dart';
import 'theme/blkwds_typography.dart';
import 'widgets/blkwds_widgets.dart';

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

  // Get navigation service instance
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: BLKWDSTheme.theme,
      home: const DashboardScreen(),
      navigatorKey: _navigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      // Define named routes
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/booking-panel': (context) => const BookingPanelScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/add-gear': (context) => const AddGearScreen(),
      },
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
              const Icon(
                Icons.error_outline,
                color: BLKWDSColors.errorRed,
                size: BLKWDSConstants.iconSizeLarge,
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
              ElevatedButton(
                onPressed: () {
                  _navigationService.navigateToDashboard(clearStack: true);
                },
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
