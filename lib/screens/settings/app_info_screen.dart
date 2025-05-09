import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../widgets/blkwds_widgets.dart';

/// AppInfoScreen
/// Screen for displaying app information
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'App Information',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo
            Center(
              child: Padding(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
                child: Image.asset(
                  'assets/logo/blkwds_logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),

            // App name
            Center(
              child: BLKWDSEnhancedText.headingLarge(
                VersionService.appName,
                isPrimary: true,
              ),
            ),

            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Version information
            BLKWDSEnhancedCard(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BLKWDSEnhancedText.titleLarge(
                    'Version Information',
                  ),
                  const Divider(),
                  _buildInfoRow('Version', VersionService.version),
                  _buildInfoRow('Build Number', VersionService.buildNumber),
                  _buildInfoRow('Full Version', VersionService.fullVersion),
                  _buildInfoRow('Package Name', VersionService.packageName),
                ],
              ),
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // App configuration
            BLKWDSEnhancedCard(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BLKWDSEnhancedText.titleLarge(
                    'App Configuration',
                  ),
                  const Divider(),
                  _buildInfoRow('Database Name', AppConfigService.config.database.databaseName),
                  _buildInfoRow('Database Version', AppConfigService.config.database.databaseVersion.toString()),
                  _buildInfoRow('Theme Mode', AppConfigService.config.ui.themeMode.toString()),
                ],
              ),
            ),

            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Copyright information
            BLKWDSEnhancedCard(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BLKWDSEnhancedText.titleLarge(
                    'Legal Information',
                  ),
                  const Divider(),
                  _buildInfoRow('Copyright', VersionService.copyright),
                  _buildInfoRow('License', 'Proprietary - All Rights Reserved'),
                ],
              ),
            ),

            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Update button
            Center(
              child: BLKWDSEnhancedButton(
                label: 'Check for Updates',
                icon: Icons.update,
                type: BLKWDSEnhancedButtonType.primary,
                backgroundColor: BLKWDSColors.mustardOrange,
                foregroundColor: BLKWDSColors.deepBlack,
                onPressed: () {
                  SnackbarService.showInfo(
                    context,
                    'You are using the latest version of ${VersionService.appName}',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build an info row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: BLKWDSEnhancedText.bodyMedium(
              label,
              color: BLKWDSColors.textSecondary,
              isBold: true,
            ),
          ),
          Expanded(
            child: BLKWDSEnhancedText.bodyMedium(
              value,
            ),
          ),
        ],
      ),
    );
  }
}
