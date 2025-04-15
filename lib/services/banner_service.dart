import 'package:flutter/material.dart';
import '../widgets/blkwds_error_banner.dart';

/// Banner service
///
/// A service for displaying persistent banners in the application
class BannerService {
  /// The global key for the banner overlay
  static final GlobalKey<_BannerOverlayState> _bannerKey = GlobalKey<_BannerOverlayState>();

  /// Show an error banner
  ///
  /// [message] is the error message to display
  /// [onRetry] is the callback when the retry button is pressed
  /// [onDismiss] is the callback when the dismiss button is pressed
  /// [showRetryButton] is whether to show a retry button
  /// [showDismissButton] is whether to show a dismiss button
  static void showError(
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = true,
    bool showDismissButton = true,
  }) {
    _bannerKey.currentState?.showBanner(
      BLKWDSErrorBanner.error(
        message: message,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => hideBanner(),
        showRetryButton: showRetryButton,
        showDismissButton: showDismissButton,
      ),
    );
  }

  /// Show a warning banner
  ///
  /// [message] is the warning message to display
  /// [onRetry] is the callback when the retry button is pressed
  /// [onDismiss] is the callback when the dismiss button is pressed
  /// [showRetryButton] is whether to show a retry button
  /// [showDismissButton] is whether to show a dismiss button
  static void showWarning(
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = true,
    bool showDismissButton = true,
  }) {
    _bannerKey.currentState?.showBanner(
      BLKWDSErrorBanner.warning(
        message: message,
        onRetry: onRetry,
        onDismiss: onDismiss ?? () => hideBanner(),
        showRetryButton: showRetryButton,
        showDismissButton: showDismissButton,
      ),
    );
  }

  /// Show an info banner
  ///
  /// [message] is the info message to display
  /// [onDismiss] is the callback when the dismiss button is pressed
  /// [showDismissButton] is whether to show a dismiss button
  static void showInfo(
    String message, {
    VoidCallback? onDismiss,
    bool showDismissButton = true,
  }) {
    _bannerKey.currentState?.showBanner(
      BLKWDSErrorBanner.info(
        message: message,
        onDismiss: onDismiss ?? () => hideBanner(),
        showDismissButton: showDismissButton,
      ),
    );
  }

  /// Hide the current banner
  static void hideBanner() {
    _bannerKey.currentState?.hideBanner();
  }

  /// Get the banner overlay widget
  ///
  /// This should be placed at the top of the widget tree
  static Widget getBannerOverlay({required Widget child}) {
    return BannerOverlay(
      key: _bannerKey,
      child: child,
    );
  }
}

/// Banner overlay widget
///
/// A widget that displays a banner at the top of the screen
class BannerOverlay extends StatefulWidget {
  /// The child widget
  final Widget child;

  /// Create a new BannerOverlay
  ///
  /// [child] is the child widget
  const BannerOverlay({
    super.key,
    required this.child,
  });

  @override
  State<BannerOverlay> createState() => _BannerOverlayState();
}

class _BannerOverlayState extends State<BannerOverlay> {
  /// The current banner widget
  Widget? _banner;

  /// Show a banner
  ///
  /// [banner] is the banner widget to show
  void showBanner(Widget banner) {
    setState(() {
      _banner = banner;
    });
  }

  /// Hide the current banner
  void hideBanner() {
    setState(() {
      _banner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      // Show banner at the top if it exists
      bottomSheet: _banner == null
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.transparent,
              child: _banner!,
            ),
    );
  }
}
