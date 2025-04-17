import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import 'widgets/gear_card_with_note.dart';

/// GearListScreen
/// Displays a list of all gear with search and filtering capabilities
class GearListScreen extends StatefulWidget {
  const GearListScreen({super.key});

  @override
  State<GearListScreen> createState() => _GearListScreenState();
}

class _GearListScreenState extends State<GearListScreen> {
  // List of all gear
  List<Gear> _gear = [];

  // Filtered list of gear
  List<Gear> _filteredGear = [];

  // Loading state
  bool _isLoading = true;

  // Error message
  String? _errorMessage;

  // Search query
  String _searchQuery = '';

  // Selected category filter
  String? _selectedCategory;

  // Selected status filter
  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadGear();
  }

  // Load gear from the database
  Future<void> _loadGear() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gear = await DBService.getAllGear();
      setState(() {
        _gear = gear;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load gear', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Apply search and filters
  void _applyFilters() {
    setState(() {
      _filteredGear = _gear.where((gear) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            gear.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            gear.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (gear.serialNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (gear.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Apply category filter
        final matchesCategory = _selectedCategory == null ||
            gear.category == _selectedCategory;

        // Apply status filter
        final matchesStatus = _selectedStatus == null ||
            gear.isOut == _selectedStatus;

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  // Get unique categories from gear
  List<String> get _uniqueCategories {
    final categories = _gear.map((gear) => gear.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Navigate to gear detail screen
  void _navigateToGearDetail(Gear gear) async {
    await NavigationService().navigateToGearDetail(gear);
    _loadGear();
  }

  // Navigate to gear form screen for adding a new gear
  void _navigateToAddGear() async {
    await NavigationService().navigateToGearForm();
    _loadGear();
  }

  // Navigate to gear form screen for editing a gear
  void _navigateToEditGear(Gear gear) async {
    await NavigationService().navigateToGearForm(gear: gear);
    _loadGear();
  }

  // Delete a gear
  Future<void> _deleteGear(Gear gear) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gear'),
        content: Text('Are you sure you want to delete ${gear.name}?'),
        actions: [
          BLKWDSButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: BLKWDSButtonType.secondary,
            isSmall: true,
          ),
          BLKWDSButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            type: BLKWDSButtonType.danger,
            isSmall: true,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DBService.deleteGear(gear.id!);

      // Show success snackbar with undo option
      if (mounted) {
        SnackbarService.showSuccessSnackBar(
          context,
          '${gear.name} deleted',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await DBService.insertGear(gear);
                _loadGear();
              } catch (e, stackTrace) {
                LogService.error('Failed to restore gear', e, stackTrace);
                if (mounted) {
                  SnackbarService.showErrorSnackBar(
                    context,
                    'Failed to restore gear',
                  );
                }
              }
            },
          ),
        );
      }

      _loadGear();
    } catch (e, stackTrace) {
      LogService.error('Failed to delete gear', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Check out gear to a member
  Future<void> _checkoutGear(Gear gear, String? note) async {
    if (gear.isOut) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          'This gear is already checked out',
        );
      }
      return;
    }

    // Get all members
    final members = await DBService.getAllMembers();
    if (members.isEmpty) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          'No members available for checkout',
        );
      }
      return;
    }

    if (!mounted) return;

    // Show member selection dialog
    final selectedMember = await showDialog<Member>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Out Gear'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a member to check out ${gear.name} to:'),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      title: Text(member.name),
                      subtitle: member.role != null ? Text(member.role!) : null,
                      onTap: () => Navigator.pop(context, member),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          BLKWDSButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            type: BLKWDSButtonType.secondary,
            isSmall: true,
          ),
        ],
      ),
    );

    if (selectedMember == null || !mounted) return;

    // Check out gear
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DBService.checkOutGear(
        gear.id!,
        selectedMember.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccessSnackBar(
            context,
            '${gear.name} checked out to ${selectedMember.name}',
          );
        }
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showErrorSnackBar(
            context,
            'Failed to check out gear',
          );
        }
      }

      _loadGear();
    } catch (e, stackTrace) {
      LogService.error('Failed to check out gear', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Check in gear
  Future<void> _checkinGear(Gear gear, String? note) async {
    if (!gear.isOut) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          'This gear is already checked in',
        );
      }
      return;
    }

    // Check in gear
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await DBService.checkInGear(
        gear.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccessSnackBar(
            context,
            '${gear.name} checked in successfully',
          );
        }
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showErrorSnackBar(
            context,
            'Failed to check in gear',
          );
        }
      }

      _loadGear();
    } catch (e, stackTrace) {
      LogService.error('Failed to check in gear', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gear Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadGear,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              children: [
                // Search field
                BLKWDSTextField(
                  label: 'Search Gear',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                // Category and status filters
                Row(
                  children: [
                    // Category filter dropdown
                    Expanded(
                      flex: 2,
                      child: BLKWDSDropdown<String?>(
                        label: 'Filter by Category',
                        value: _selectedCategory,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ..._uniqueCategories.map((category) {
                            return DropdownMenuItem<String?>(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingMedium),
                    // Status filter dropdown
                    Expanded(
                      flex: 2,
                      child: BLKWDSDropdown<bool?>(
                        label: 'Filter by Status',
                        value: _selectedStatus,
                        items: const [
                          DropdownMenuItem<bool?>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: true,
                            child: Text('Checked Out'),
                          ),
                          DropdownMenuItem<bool?>(
                            value: false,
                            child: Text('Available'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gear list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: BLKWDSColors.errorRed,
                              size: 48,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            Text(
                              'Error Loading Gear',
                              style: BLKWDSTypography.titleLarge,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: BLKWDSTypography.bodyMedium,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            BLKWDSButton(
                              label: 'Retry',
                              onPressed: _loadGear,
                              type: BLKWDSButtonType.primary,
                            ),
                          ],
                        ),
                      )
                    : _filteredGear.isEmpty
                        ? _gear.isEmpty
                            ? FallbackWidget.empty(
                                message: 'No gear items in your inventory yet',
                                icon: Icons.videocam_off,
                                onPrimaryAction: _navigateToAddGear,
                                primaryActionLabel: 'Add Gear',
                                secondaryActionLabel: 'Learn More',
                                onSecondaryAction: () {
                                  SnackbarService.showInfo(
                                    context,
                                    'Gear items represent your equipment inventory that can be checked in/out and assigned to bookings.',
                                  );
                                },
                              )
                            : FallbackWidget.noData(
                                message: 'No gear matches your current filters',
                                icon: Icons.filter_alt_off,
                                onRetry: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = null;
                                    _selectedStatus = null;
                                    _applyFilters();
                                  });
                                },
                              )
                        : ListView.builder(
                            itemCount: _filteredGear.length,
                            itemBuilder: (context, index) {
                              final gear = _filteredGear[index];
                              return _buildGearCard(gear);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGear,
        tooltip: 'Add Gear',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build a card for a gear item
  Widget _buildGearCard(Gear gear) {
    return GearCardWithNote(
      gear: gear,
      onCheckout: _checkoutGear,
      onCheckin: _checkinGear,
      onEdit: _navigateToEditGear,
      onDelete: _deleteGear,
      onTap: _navigateToGearDetail,
    );
  }
}
