import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';

import '../../widgets/blkwds_widgets.dart';
import 'booking_detail_screen.dart';
import 'booking_list_controller.dart';
import 'booking_panel_controller.dart';
import 'models/booking_filter.dart';
import 'models/booking_list_view_options.dart';
import 'widgets/booking_filter_bar.dart';

import 'widgets/booking_form.dart';
import 'widgets/booking_list_header.dart';
import 'widgets/booking_list_item.dart';

/// BookingListScreen
/// Enhanced screen for displaying and managing bookings
class BookingListScreen extends StatefulWidget {
  final BookingPanelController controller;

  const BookingListScreen({
    super.key,
    required this.controller,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  // Controllers
  late final BookingListController _listController;

  // State variables
  bool _showEditForm = false;
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize list controller
    _listController = BookingListController(widget.controller);
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  // Show edit booking form
  void _showEditBookingForm(Booking booking) {
    setState(() {
      _showEditForm = true;
      _selectedBooking = booking;
    });
  }

  // Hide edit booking form
  void _hideEditBookingForm() {
    setState(() {
      _showEditForm = false;
      _selectedBooking = null;
    });
  }

  // Save booking
  Future<void> _saveBooking(Booking booking) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.updateBooking(booking);

      if (success) {
        setState(() {
          _isLoading = false;
          _showEditForm = false;
          _selectedBooking = null;
        });

        if (mounted) {
          SnackbarService.showSuccessSnackBar(
            context,
            'Booking updated successfully',
          );
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to update booking';
          _isLoading = false;
        });

        if (mounted) {
          SnackbarService.showErrorSnackBar(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error updating booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error updating booking: $e';
        _isLoading = false;
      });

      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Delete booking
  Future<void> _deleteBooking(Booking booking) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
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
      final success = await widget.controller.deleteBooking(booking.id!);

      if (success) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          SnackbarService.showSuccessSnackBar(
            context,
            'Booking deleted successfully',
          );
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to delete booking';
          _isLoading = false;
        });

        if (mounted) {
          SnackbarService.showErrorSnackBar(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error deleting booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error deleting booking: $e';
        _isLoading = false;
      });

      if (mounted) {
        SnackbarService.showErrorSnackBar(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Navigate to booking detail
  void _navigateToBookingDetail(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(
          booking: booking,
          controller: widget.controller,
        ),
      ),
    ).then((result) {
      // Refresh data if booking was updated or deleted
      if (result == true) {
        widget.controller.initialize();
      }
    });
  }

  // Show view options dialog
  void _showViewOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Options'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final viewOptions = _listController.viewOptions.value;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grouping options
                  Text(
                    'Group By',
                    style: BLKWDSTypography.titleSmall,
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Wrap(
                    spacing: BLKWDSConstants.spacingSmall,
                    children: BookingGroupBy.values.map((groupBy) {
                      return ChoiceChip(
                        label: Text(groupBy.label),
                        selected: viewOptions.groupBy == groupBy,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _listController.updateViewOptions(
                                viewOptions.copyWith(groupBy: groupBy),
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingMedium),

                  // View density options
                  Text(
                    'View Density',
                    style: BLKWDSTypography.titleSmall,
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Wrap(
                    spacing: BLKWDSConstants.spacingSmall,
                    children: BookingViewDensity.values.map((density) {
                      return ChoiceChip(
                        label: Text(density.label),
                        selected: viewOptions.viewDensity == density,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _listController.updateViewOptions(
                                viewOptions.copyWith(viewDensity: density),
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingMedium),

                  // Other options
                  SwitchListTile(
                    title: const Text('Show Past Bookings'),
                    value: viewOptions.showPastBookings,
                    onChanged: (value) {
                      setState(() {
                        _listController.updateViewOptions(
                          viewOptions.copyWith(showPastBookings: value),
                        );
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Show Details'),
                    value: viewOptions.showDetails,
                    onChanged: (value) {
                      setState(() {
                        _listController.updateViewOptions(
                          viewOptions.copyWith(showDetails: value),
                        );
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show save preset dialog
  void _showSavePresetDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Filter Preset'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'Enter a name for this preset',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                final success = await _listController.savePreset(textController.text);

                if (mounted) {
                  Navigator.pop(context);

                  if (success) {
                    SnackbarService.showSuccessSnackBar(
                      context,
                      'Preset saved successfully',
                    );
                  } else {
                    SnackbarService.showErrorSnackBar(
                      context,
                      'Failed to save preset',
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }

  // Show presets dialog
  void _showPresetsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Presets'),
        content: ValueListenableBuilder<List<SavedFilterPreset>>(
          valueListenable: _listController.savedPresets,
          builder: (context, presets, child) {
            if (presets.isEmpty) {
              return const Text('No saved presets');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];

                  return ListTile(
                    title: Text(preset.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final success = await _listController.deletePreset(preset.id);

                        if (mounted && success) {
                          SnackbarService.showSuccessSnackBar(
                            context,
                            'Preset deleted',
                          );
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _listController.applyPreset(preset);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Bulk delete selected bookings
  Future<void> _bulkDeleteBookings() async {
    final selectedCount = _listController.viewState.value.selectedBookingIds.length;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookings'),
        content: Text('Are you sure you want to delete $selectedCount selected bookings?'),
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

    final success = await _listController.bulkDeleteBookings();

    if (mounted) {
      if (success) {
        SnackbarService.showSuccessSnackBar(
          context,
          'Deleted $selectedCount bookings',
        );
      } else {
        SnackbarService.showErrorSnackBar(
          context,
          'Failed to delete some bookings',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_showEditForm) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Booking'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _hideEditBookingForm,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: BookingForm(
              controller: widget.controller,
              booking: _selectedBooking,
              onSave: _saveBooking,
              onCancel: _hideEditBookingForm,
            ),
        ),
      );
    }

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Column(
            children: [
              // Filter bar
              BookingFilterBar(
                controller: widget.controller,
                onFilterChanged: () {
                  // This will trigger a rebuild of the list
                  setState(() {});
                },
              ),

              // View options and actions bar
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              ValueListenableBuilder<bool>(
                valueListenable: _listController.isInSelectionMode,
                builder: (context, isInSelectionMode, child) {
                  if (isInSelectionMode) {
                    // Selection mode toolbar
                    return ValueListenableBuilder<BookingListViewState>(
                      valueListenable: _listController.viewState,
                      builder: (context, viewState, child) {
                        final selectedCount = viewState.selectedBookingIds.length;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BLKWDSConstants.spacingMedium,
                            vertical: BLKWDSConstants.spacingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: BLKWDSColors.backgroundLight,
                            borderRadius: BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$selectedCount selected',
                                style: BLKWDSTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                onPressed: selectedCount > 0 ? _bulkDeleteBookings : null,
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.close),
                                label: const Text('Cancel'),
                                onPressed: () => _listController.clearSelection(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    // Normal toolbar
                    return Row(
                      children: [
                        // View options button
                        IconButton(
                          icon: const Icon(Icons.view_list),
                          tooltip: 'View Options',
                          onPressed: _showViewOptionsDialog,
                        ),

                        // Save preset button
                        IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: 'Save Preset',
                          onPressed: _showSavePresetDialog,
                        ),

                        // Load preset button
                        IconButton(
                          icon: const Icon(Icons.bookmark),
                          tooltip: 'Load Preset',
                          onPressed: _showPresetsDialog,
                        ),

                        const Spacer(),

                        // Select all button
                        TextButton.icon(
                          icon: const Icon(Icons.select_all),
                          label: const Text('Select All'),
                          onPressed: () => _listController.selectAllBookings(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Booking list
        Expanded(
          child: ValueListenableBuilder<List<BookingGroup>>(
            valueListenable: _listController.groupedBookings,
            builder: (context, groups, child) {
              if (groups.isEmpty) {
                return const Center(
                  child: Text('No bookings found'),
                );
              }

              return ValueListenableBuilder<BookingListViewState>(
                valueListenable: _listController.viewState,
                builder: (context, viewState, child) {
                  return ValueListenableBuilder<BookingListViewOptions>(
                    valueListenable: _listController.viewOptions,
                    builder: (context, viewOptions, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                        itemCount: groups.length,
                        itemBuilder: (context, groupIndex) {
                          final group = groups[groupIndex];
                          final isExpanded = viewState.expandedGroups.contains(group.id);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group header
                              if (viewOptions.groupBy != BookingGroupBy.none)
                                BookingListHeader(
                                  group: group,
                                  isExpanded: isExpanded,
                                  onToggleExpanded: () => _listController.toggleGroupExpanded(group.id),
                                  onFilterByGroup: viewOptions.groupBy == BookingGroupBy.project
                                      ? () {
                                          // Filter by project
                                          final projectId = int.tryParse(group.id.split('-').last);
                                          if (projectId != null) {
                                            widget.controller.updateFilter(
                                              widget.controller.filter.value.copyWith(
                                                projectId: projectId,
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                ),

                              // Bookings in group
                              if (isExpanded || viewOptions.groupBy == BookingGroupBy.none)
                                ...group.bookings.map((booking) {
                                  final isSelected = viewState.selectedBookingIds.contains(booking.id);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
                                    child: BookingListItem(
                                      booking: booking,
                                      controller: widget.controller,
                                      onEdit: () => _showEditBookingForm(booking),
                                      onDelete: () => _deleteBooking(booking),
                                      onTap: (booking) => _navigateToBookingDetail(booking),
                                      onLongPress: (booking) {
                                        if (booking.id != null) {
                                          _listController.toggleBookingSelected(booking.id!);
                                        }
                                      },
                                      isSelected: isSelected,
                                      viewDensity: viewOptions.viewDensity,
                                      showDetails: viewOptions.showDetails,
                                    ),
                                  );
                                }).toList(),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
