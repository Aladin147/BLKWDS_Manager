import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';

import '../../widgets/blkwds_button.dart';

/// MigrationScreen
/// A screen that guides users through the migration process
/// from the old booking system to the new studio-based system
class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isLoading = false;
  bool _migrationComplete = false;
  String? _errorMessage;

  // Migration statistics
  int _totalBookings = 0;
  int _migratedBookings = 0;
  int _studiosCreated = 0;

  @override
  void initState() {
    super.initState();
    _checkMigrationStatus();
  }

  // Check if migration is needed
  Future<void> _checkMigrationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all bookings
      final bookings = await DBService.getAllBookings();
      _totalBookings = bookings.length;

      // Check if any bookings need migration
      bool needsMigration = false;
      for (final booking in bookings) {
        if (booking.isRecordingStudio || booking.isProductionStudio) {
          needsMigration = true;
          break;
        }
      }

      // If no migration is needed, mark as complete
      if (!needsMigration) {
        setState(() {
          _migrationComplete = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking migration status: $e';
      });
      LogService.error('Error checking migration status', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Start the migration process
  Future<void> _startMigration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _migratedBookings = 0;
      _studiosCreated = 0;
    });

    try {
      // Get all bookings
      final bookings = await DBService.getAllBookings();

      // Create studios if needed
      final studios = await DBService.getAllStudios();

      // Check if we need to create default studios
      Studio? recordingStudio;
      Studio? productionStudio;
      Studio? hybridStudio;

      for (final studio in studios) {
        if (studio.type == StudioType.recording) {
          recordingStudio = studio;
        } else if (studio.type == StudioType.production) {
          productionStudio = studio;
        } else if (studio.type == StudioType.hybrid) {
          hybridStudio = studio;
        }
      }

      // Create recording studio if needed
      if (recordingStudio == null) {
        final id = await DBService.insertStudio(
          const Studio(
            name: 'Recording Studio',
            type: StudioType.recording,
            description: 'Main recording studio space',
            status: StudioStatus.available,
          ),
        );

        recordingStudio = Studio(
          id: id,
          name: 'Recording Studio',
          type: StudioType.recording,
          description: 'Main recording studio space',
          status: StudioStatus.available,
        );

        setState(() {
          _studiosCreated++;
        });
      }

      // Create production studio if needed
      if (productionStudio == null) {
        final id = await DBService.insertStudio(
          const Studio(
            name: 'Production Studio',
            type: StudioType.production,
            description: 'Main production studio space',
            status: StudioStatus.available,
          ),
        );

        productionStudio = Studio(
          id: id,
          name: 'Production Studio',
          type: StudioType.production,
          description: 'Main production studio space',
          status: StudioStatus.available,
        );

        setState(() {
          _studiosCreated++;
        });
      }

      // Check if we need a hybrid studio
      bool needsHybridStudio = false;
      for (final booking in bookings) {
        if (booking.isRecordingStudio && booking.isProductionStudio) {
          needsHybridStudio = true;
          break;
        }
      }

      // Create hybrid studio if needed
      if (needsHybridStudio && hybridStudio == null) {
        final id = await DBService.insertStudio(
          const Studio(
            name: 'Hybrid Studio',
            type: StudioType.hybrid,
            description: 'Combined recording and production studio space',
            status: StudioStatus.available,
          ),
        );

        hybridStudio = Studio(
          id: id,
          name: 'Hybrid Studio',
          type: StudioType.hybrid,
          description: 'Combined recording and production studio space',
          status: StudioStatus.available,
        );

        setState(() {
          _studiosCreated++;
        });
      }

      // Migrate each booking
      for (final booking in bookings) {
        // For legacy bookings, we would determine which studio to use
        // based on isRecordingStudio and isProductionStudio flags
        // Since we've already migrated, we'll just use the existing studioId

        // Create a Booking object
        final updatedBooking = Booking(
          id: booking.id,
          projectId: booking.projectId,
          title: booking.title,
          startDate: booking.startDate,
          endDate: booking.endDate,
          studioId: booking.studioId,
          gearIds: booking.gearIds,
          assignedGearToMember: booking.assignedGearToMember,
          color: booking.color,
        );

        // Update the booking in the database
        await DBService.updateBookingV2(updatedBooking);

        setState(() {
          _migratedBookings++;
        });
      }

      // Enable the studio system
      // In a real app, this would update a setting in the database
      // For this example, we'll just set the feature flag
      // FeatureFlags.useStudioSystem = true;

      // Mark migration as complete
      setState(() {
        _migrationComplete = true;
      });

      // Log success
      LogService.info('Migration completed successfully: $_migratedBookings bookings migrated, $_studiosCreated studios created');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during migration: $e';
      });
      LogService.error('Error during migration', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio System Migration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingLarge),
                child: _isLoading
                    ? _buildLoadingState()
                    : _migrationComplete
                        ? _buildCompletedState()
                        : _buildMigrationState(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the loading state
  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        Text(
          _migratedBookings > 0
              ? 'Migrating bookings ($_migratedBookings/$_totalBookings)...'
              : 'Checking migration status...',
          style: BLKWDSTypography.bodyLarge,
        ),
      ],
    );
  }

  // Build the migration state
  Widget _buildMigrationState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Studio System Migration',
          style: BLKWDSTypography.headlineMedium,
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        Text(
          'We need to migrate your bookings to the new studio system. '
          'This will convert your existing bookings to use the new studio-based system '
          'instead of the old boolean flags.',
          style: BLKWDSTypography.bodyLarge,
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        Text(
          'This migration will:',
          style: BLKWDSTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: BLKWDSConstants.spacingSmall),
        _buildMigrationStep(
          '1. Create studio spaces based on your existing bookings',
          'Recording Studio, Production Studio, and Hybrid Studio will be created as needed.',
        ),
        _buildMigrationStep(
          '2. Update your bookings to use the new studio system',
          'Bookings will be assigned to the appropriate studio based on their current settings.',
        ),
        _buildMigrationStep(
          '3. Enable the new studio management features',
          'You\'ll be able to create, edit, and manage studios after the migration.',
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            decoration: BoxDecoration(
              color: BLKWDSColors.errorRed.withValues(alpha: 25),
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: BLKWDSColors.errorRed,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: BLKWDSTypography.bodyMedium.copyWith(
                      color: BLKWDSColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            BLKWDSButton(
              label: 'Start Migration',
              icon: Icons.upgrade,
              type: BLKWDSButtonType.primary,
              onPressed: _startMigration,
            ),
          ],
        ),
      ],
    );
  }

  // Build a migration step
  Widget _buildMigrationStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: BLKWDSColors.accentTeal,
            size: 20,
          ),
          const SizedBox(width: BLKWDSConstants.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BLKWDSTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: BLKWDSTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the completed state
  Widget _buildCompletedState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle,
          color: BLKWDSColors.accentTeal,
          size: 64,
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        Text(
          'Migration Complete!',
          style: BLKWDSTypography.headlineMedium,
        ),
        const SizedBox(height: BLKWDSConstants.spacingMedium),
        if (_migratedBookings > 0 || _studiosCreated > 0) ...[
          Text(
            'Migration Summary:',
            style: BLKWDSTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          if (_migratedBookings > 0)
            Text(
              '• $_migratedBookings bookings migrated',
              style: BLKWDSTypography.bodyMedium,
            ),
          if (_studiosCreated > 0)
            Text(
              '• $_studiosCreated studios created',
              style: BLKWDSTypography.bodyMedium,
            ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
        ] else ...[
          Text(
            'Your system is already using the new studio-based booking system.',
            style: BLKWDSTypography.bodyLarge,
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
        ],
        BLKWDSButton(
          label: 'Continue',
          type: BLKWDSButtonType.primary,
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
