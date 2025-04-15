import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_animations.dart';
import '../../widgets/blkwds_widgets.dart';
import 'gear_detail_screen.dart';
import 'gear_form_screen.dart';

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
  void _navigateToGearDetail(Gear gear) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: GearDetailScreen(gear: gear),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadGear());
  }

  // Navigate to gear form screen for adding a new gear
  void _navigateToAddGear() {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: const GearFormScreen(),
        transitionType: BLKWDSPageTransitionType.bottomToTop,
      ),
    ).then((_) => _loadGear());
  }

  // Navigate to gear form screen for editing a gear
  void _navigateToEditGear(Gear gear) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: GearFormScreen(gear: gear),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadGear());
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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
  Future<void> _checkoutGear(Gear gear) async {
    if (gear.isOut) {
      // Show error snackbar
      SnackbarService.showErrorSnackBar(
        context,
        'This gear is already checked out',
      );
      return;
    }

    // Get all members
    final members = await DBService.getAllMembers();
    if (members.isEmpty) {
      // Show error snackbar
      SnackbarService.showErrorSnackBar(
        context,
        'No members available for checkout',
      );
      return;
    }

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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedMember == null) return;

    // Show note dialog
    final TextEditingController noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note (Optional)'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter a note for this checkout',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );

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
  Future<void> _checkinGear(Gear gear) async {
    if (!gear.isOut) {
      // Show error snackbar
      SnackbarService.showErrorSnackBar(
        context,
        'This gear is already checked in',
      );
      return;
    }

    // Show note dialog
    final TextEditingController noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note (Optional)'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter a note for this check-in',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('Add Note'),
          ),
        ],
      ),
    );

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
                      child: DropdownButtonFormField<String?>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                            borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                            borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.inputHorizontalPadding,
                            vertical: BLKWDSConstants.inputVerticalPadding / 2,
                          ),
                          filled: true,
                          fillColor: BLKWDSColors.inputBackground,
                        ),
                        dropdownColor: BLKWDSColors.backgroundMedium,
                        style: TextStyle(color: BLKWDSColors.textPrimary),
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
                      child: DropdownButtonFormField<bool?>(
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                            borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                            borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.inputHorizontalPadding,
                            vertical: BLKWDSConstants.inputVerticalPadding / 2,
                          ),
                          filled: true,
                          fillColor: BLKWDSColors.inputBackground,
                        ),
                        dropdownColor: BLKWDSColors.backgroundMedium,
                        style: TextStyle(color: BLKWDSColors.textPrimary),
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
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.videocam_off,
                                  color: BLKWDSColors.slateGrey,
                                  size: 48,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                Text(
                                  _gear.isEmpty
                                      ? 'No Gear Found'
                                      : 'No Gear Matches Filters',
                                  style: BLKWDSTypography.titleLarge,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSButton(
                                  label: 'Add Gear',
                                  onPressed: _navigateToAddGear,
                                  type: BLKWDSButtonType.primary,
                                ),
                              ],
                            ),
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: InkWell(
        onTap: () => _navigateToGearDetail(gear),
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gear name, category, and actions
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: gear.isOut ? BLKWDSColors.statusOut : BLKWDSColors.statusIn,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  // Gear info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gear.name,
                          style: BLKWDSTypography.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          gear.category,
                          style: BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      // Check out/in button
                      IconButton(
                        icon: Icon(
                          gear.isOut ? Icons.check_circle : Icons.logout,
                          color: gear.isOut ? BLKWDSColors.statusIn : BLKWDSColors.statusOut,
                        ),
                        tooltip: gear.isOut ? 'Check In' : 'Check Out',
                        onPressed: () => gear.isOut ? _checkinGear(gear) : _checkoutGear(gear),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit',
                        onPressed: () => _navigateToEditGear(gear),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete',
                        onPressed: () => _deleteGear(gear),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Serial number if available
              if (gear.serialNumber != null && gear.serialNumber!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        size: 16,
                        color: BLKWDSColors.textSecondary,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Text(
                        'S/N: ${gear.serialNumber}',
                        style: BLKWDSTypography.bodySmall.copyWith(
                          color: BLKWDSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Status note if available
              if (gear.lastNote != null && gear.lastNote!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.note,
                        size: 16,
                        color: BLKWDSColors.textSecondary,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          gear.lastNote!,
                          style: BLKWDSTypography.bodySmall.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
