import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_typography.dart';
import '../theme/blkwds_constants.dart';

/// A simple splash screen to show while the app is initializing
class SplashScreen extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const SplashScreen({
    Key? key,
    this.message,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: BLKWDSColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.business,
                    size: 100,
                    color: BLKWDSColors.primary,
                  );
                },
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),

              // App name
              Text(
                'BLKWDS Manager',
                style: BLKWDSTypography.headlineLarge.copyWith(
                  color: BLKWDSColors.textLight,
                ),
              ),

              const SizedBox(height: BLKWDSConstants.spacingLarge),

              // Loading indicator
              if (showProgress)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(BLKWDSColors.primary),
                ),

              // Status message
              if (message != null) ...[
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  message!,
                  style: BLKWDSTypography.bodyMedium.copyWith(
                    color: BLKWDSColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
