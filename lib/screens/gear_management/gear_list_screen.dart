import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/device_performance_service.dart';
import '../../services/navigation_helper.dart';
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

  // Paginated gear items (for display)
  List<Gear> _paginatedGear = [];

  // Loading state
  bool _isLoading = true;

  // Error message
  String? _errorMessage;

  // Search query
  String _searchQuery = '';

  // Pagination
  final ScrollController _scrollController = ScrollController();
  bool _shouldUsePagination = false;
  int _paginationPageSize = 20;
  int _currentPage = 0;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;

  // Category and status filters removed to simplify UI

  @override
  void initState() {
    super.initState();

    // Check device performance to determine if pagination should be used
    final performanceService = DevicePerformanceService();
    _shouldUsePagination = performanceService.shouldUsePagination;
    _paginationPageSize = performanceService.paginationPageSize;

    // Add scroll listener for pagination
    if (_shouldUsePagination) {
      _scrollController.addListener(_scrollListener);
    }

    _loadGear();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreItems) {
      _loadMoreItems();
    }
  }

  // Load gear from the database
  Future<void> _loadGear() async {
    // Clear the cache to ensure we get fresh data
    CacheService().remove('all_gear');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gear = await DBService.getAllGear();

      if (mounted) {
        setState(() {
          _gear = gear;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to load gear', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = ErrorService.getUserFriendlyMessage(
            ErrorType.database,
            e.toString(),
          );
          _isLoading = false;
        });

        // Show error snackbar
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Apply search filter only
  void _applyFilters() {
    setState(() {
      _filteredGear = _gear.where((gear) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            gear.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            gear.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (gear.serialNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (gear.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        return matchesSearch;
      }).toList();

      // Reset pagination
      _currentPage = 0;
      _hasMoreItems = true;
      _loadPaginatedItems();
    });
  }

  // Load paginated items
  void _loadPaginatedItems() {
    if (!_shouldUsePagination) {
      // If pagination is disabled, show all filtered items
      _paginatedGear = List.from(_filteredGear);
      return;
    }

    final startIndex = 0;
    final endIndex = (_currentPage + 1) * _paginationPageSize;

    if (startIndex >= _filteredGear.length) {
      _hasMoreItems = false;
      return;
    }

    _paginatedGear = _filteredGear.sublist(
      startIndex,
      endIndex > _filteredGear.length ? _filteredGear.length : endIndex
    );

    _hasMoreItems = endIndex < _filteredGear.length;
  }

  // Load more items for pagination
  Future<void> _loadMoreItems() async {
    if (!_hasMoreItems || !_shouldUsePagination) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for smoother UX
    await Future.delayed(const Duration(milliseconds: 300));

    _currentPage++;

    final startIndex = _currentPage * _paginationPageSize;
    final endIndex = (_currentPage + 1) * _paginationPageSize;

    if (startIndex >= _filteredGear.length) {
      setState(() {
        _hasMoreItems = false;
        _isLoadingMore = false;
      });
      return;
    }

    final newItems = _filteredGear.sublist(
      startIndex,
      endIndex > _filteredGear.length ? _filteredGear.length : endIndex
    );

    setState(() {
      _paginatedGear.addAll(newItems);
      _hasMoreItems = endIndex < _filteredGear.length;
      _isLoadingMore = false;
    });
  }

  // Category filter removed to simplify UI

  // Navigate to gear detail screen
  void _navigateToGearDetail(Gear gear) async {
    await NavigationHelper.navigateToGearDetail(gear);
    _loadGear();
  }

  // Navigate to gear form screen for adding a new gear
  void _navigateToAddGear() async {
    await NavigationHelper.navigateToGearForm();
    _loadGear();
  }

  // Navigate to gear form screen for editing a gear
  void _navigateToEditGear(Gear gear) async {
    await NavigationHelper.navigateToGearForm(gear: gear);
    _loadGear();
  }

  // Delete a gear
  Future<void> _deleteGear(Gear gear) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Gear',
        content: 'Are you sure you want to delete ${gear.name}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => Navigator.pop(context, false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => Navigator.pop(context, true),
        isPrimaryDestructive: true,
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
        SnackbarService.showSuccess(
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
                  SnackbarService.showError(
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
        SnackbarService.showError(
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
        SnackbarService.showError(
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
        SnackbarService.showError(
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
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Check Out Gear',
        contentWidget: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a member to check out ${gear.name} to:',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return BLKWDSEnhancedListTile(
                      title: member.name,
                      subtitle: member.role,
                      leadingIcon: Icons.person,
                      onTap: () => Navigator.pop(context, member),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => Navigator.pop(context),
      ),
    );

    if (selectedMember == null || !mounted) {
      return;
    }

    // Check out gear
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear the cache before the operation to ensure fresh data
      CacheService().remove('all_gear');

      final success = await DBService.checkOutGear(
        gear.id!,
        selectedMember.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            '${gear.name} checked out to ${selectedMember.name}',
          );
        }

        // Update the local gear item to reflect the change immediately
        final updatedGear = gear.copyWith(isOut: true, lastNote: note);

        // Update the gear in the local list
        setState(() {
          final index = _gear.indexWhere((g) => g.id == gear.id);
          if (index >= 0) {
            _gear[index] = updatedGear;
          }

          final filteredIndex = _filteredGear.indexWhere((g) => g.id == gear.id);
          if (filteredIndex >= 0) {
            _filteredGear[filteredIndex] = updatedGear;
          }
        });
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showError(
            context,
            'Failed to check out gear',
          );
        }
      }

      // Reload gear from database to ensure UI is up to date
      _loadGear();
    } catch (e, stackTrace) {
      LogService.error('Failed to check out gear', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = ErrorService.getUserFriendlyMessage(
            ErrorType.database,
            e.toString(),
          );
          _isLoading = false;
        });

        // Show error snackbar
        SnackbarService.showError(
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
        SnackbarService.showError(
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
      // Clear the cache before the operation to ensure fresh data
      CacheService().remove('all_gear');

      final success = await DBService.checkInGear(
        gear.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            '${gear.name} checked in successfully',
          );
        }

        // Update the local gear item to reflect the change immediately
        final updatedGear = gear.copyWith(isOut: false, lastNote: note);

        // Update the gear in the local list
        setState(() {
          final index = _gear.indexWhere((g) => g.id == gear.id);
          if (index >= 0) {
            _gear[index] = updatedGear;
          }

          final filteredIndex = _filteredGear.indexWhere((g) => g.id == gear.id);
          if (filteredIndex >= 0) {
            _filteredGear[filteredIndex] = updatedGear;
          }
        });
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showError(
            context,
            'Failed to check in gear',
          );
        }
      }

      // Reload gear from database to ensure UI is up to date
      _loadGear();
    } catch (e, stackTrace) {
      LogService.error('Failed to check in gear', e, stackTrace);
      if (mounted) {
        setState(() {
          _errorMessage = ErrorService.getUserFriendlyMessage(
            ErrorType.database,
            e.toString(),
          );
          _isLoading = false;
        });

        // Show error snackbar
        SnackbarService.showError(
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
                BLKWDSEnhancedFormField(
                  label: 'Search Gear',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                // Category and status filters removed to simplify UI
              ],
            ),
          ),

          // Gear list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: BLKWDSColors.blkwdsGreen))
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
                                    _applyFilters();
                                  });
                                },
                              )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _shouldUsePagination
                                ? _paginatedGear.length + (_hasMoreItems ? 1 : 0)
                                : _filteredGear.length,
                            itemBuilder: (context, index) {
                              // Show loading indicator at the end when loading more items
                              if (_shouldUsePagination && index == _paginatedGear.length && _hasMoreItems) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final gear = _shouldUsePagination
                                  ? _paginatedGear[index]
                                  : _filteredGear[index];
                              return _buildGearCard(gear);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: BLKWDSEnhancedFloatingActionButton(
        onPressed: _navigateToAddGear,
        tooltip: 'Add Gear',
        icon: Icons.add,
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
